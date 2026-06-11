import SwiftUI

struct CalendarGridView: View {
    @Environment(SupabaseRepository.self) private var repository
    @Environment(AuthManager.self) private var authManager
    @Environment(LanguageManager.self) private var lang

    @State private var currentMonth = Date()
    @State private var selectedDate: Date?
    @State private var showDayDetail = false
    @State private var activities: [Attivita] = []
    @State private var isLoading = true
    @State private var viewMode: ViewMode = .calendar

    // Dati per i filtri
    @State private var orti: [Orto] = []
    @State private var piante: [PiantaColtivata] = []

    // Filtri attivi
    @State private var filterOrtoId: UUID? = nil
    @State private var filterTipologia: String? = nil
    @State private var filterPiantaId: UUID? = nil

    // Meteo
    @State private var rainDays: [String: Double] = [:]
    @State private var frostDays: [String: Double] = [:]
    @State private var rainRescheduledCount = 0
    @State private var showRainToast = false
    @State private var loadError: String?
    @State private var isOffline = false

    private let calendar = Calendar.current
    private var weekDays: [String] { lang.calendar.weekDays }
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    private var tipologie: [(color: String, label: String)] {
        [
            ("green",  lang.calendar.legendSeedTransplant),
            ("orange", lang.calendar.legendHarvest),
            ("blue",   lang.calendar.legendWatering),
            ("red",    lang.calendar.legendTreatment),
            ("gray",   lang.calendar.legendPruning),
            ("purple", lang.calendar.legendReminder),
        ]
    }

    enum ViewMode: String, CaseIterable {
        case calendar = "calendar"
        case agenda = "agenda"
    }

    // MARK: - Computed

    var filteredActivities: [Attivita] {
        activities.filter { att in
            if let ortoId = filterOrtoId {
                guard let pianta = piante.first(where: { $0.id == att.piantaId }),
                      pianta.ortoId == ortoId else { return false }
            }
            if let tipo = filterTipologia {
                guard att.color.lowercased() == tipo else { return false }
            }
            if let piantaId = filterPiantaId {
                guard att.piantaId == piantaId else { return false }
            }
            return true
        }
    }

    var visiblePiante: [PiantaColtivata] {
        guard let ortoId = filterOrtoId else { return piante }
        return piante.filter { $0.ortoId == ortoId }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    ForEach(ViewMode.allCases, id: \.self) { mode in
                        pillSegmentButton(mode: mode)
                    }
                }
                .padding(3)
                .background(AppTheme.cardSecondaryWarm)
                .clipShape(RoundedRectangle(cornerRadius: 11))
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 4)

                filterBar

                if isOffline {
                    HStack(spacing: 8) {
                        Image(systemName: "icloud.slash")
                            .foregroundStyle(AppTheme.textSecondary)
                        Text(lang.calendar.offlineBanner)
                            .font(.dmSans(12, weight: .medium))
                            .foregroundStyle(AppTheme.textSecondary)
                        Spacer()
                        Button(lang.common.retry) {
                            Task { await loadMonth() }
                        }
                        .font(.dmSans(12, weight: .semibold))
                        .foregroundStyle(AppTheme.primaryGreen)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(AppTheme.cardSecondaryWarm)
                } else if let loadError {
                    HStack(spacing: 8) {
                        Image(systemName: "wifi.exclamationmark")
                            .foregroundStyle(.orange)
                        Text(loadError)
                            .font(.dmSans(12, weight: .medium))
                            .foregroundStyle(AppTheme.textSecondary)
                        Spacer()
                        Button(lang.common.retry) {
                            Task { await loadMonth() }
                        }
                        .font(.dmSans(12, weight: .semibold))
                        .foregroundStyle(AppTheme.primaryGreen)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.orange.opacity(0.08))
                }

                if viewMode == .calendar {
                    calendarContent
                } else {
                    agendaContent
                }
            }
            .background(AppTheme.backgroundCream)
            .navigationTitle(lang.calendar.navTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(lang.calendar.todayButton) {
                        withAnimation {
                            currentMonth = Date()
                            selectedDate = Date()
                        }
                    }
                    .font(.dmSans(14, weight: .semibold))
                    .foregroundStyle(AppTheme.primaryGreen)
                    .disabled(calendar.isDate(currentMonth, equalTo: Date(), toGranularity: .month))
                }
            }
            .navigationDestination(isPresented: $showDayDetail) {
                if let date = selectedDate {
                    DayDetailView(
                        selectedDate: date,
                        activities: filteredActivities.filter { calendar.isDate($0.data, inSameDayAs: date) }
                    )
                }
            }
        }
        .task { await loadFiltersData() }
        .task { await loadMonth() }
        .onChange(of: currentMonth) { _, _ in Task { await loadMonth() } }
        .onChange(of: showDayDetail) { _, isShowing in
            if !isShowing { Task { await loadMonth() } }
        }
        .onChange(of: filterOrtoId) { _, _ in
            if let piantaId = filterPiantaId,
               !visiblePiante.contains(where: { $0.id == piantaId }) {
                filterPiantaId = nil
            }
        }
        .overlay(alignment: .top) {
            if showRainToast {
                HStack(spacing: 8) {
                    Image(systemName: "cloud.rain.fill")
                        .foregroundStyle(AppTheme.rainBlue)
                    Text(rainRescheduledCount == 1
                        ? lang.calendar.rainToastSingular
                        : String(format: lang.calendar.rainToastPlural, rainRescheduledCount))
                        .font(.dmSans(14, weight: .medium))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.regularMaterial, in: Capsule())
                .padding(.top, 8)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(duration: 0.4), value: showRainToast)
    }

    // MARK: - Pill Segment Button

    @ViewBuilder
    private func pillSegmentButton(mode: ViewMode) -> some View {
        let isSelected = viewMode == mode
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { viewMode = mode }
        } label: {
            Text(mode == .calendar ? lang.calendar.viewCalendar : lang.calendar.viewAgenda)
                .font(.dmSans(14, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? AppTheme.textPrimary : AppTheme.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(isSelected ? AppTheme.cardBackground : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    // MARK: - Filter Bar

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Menu {
                    Button(lang.calendar.filterAllGardens) {
                        filterOrtoId = nil
                        filterPiantaId = nil
                    }
                    ForEach(orti) { orto in
                        Button(orto.nome) {
                            filterOrtoId = orto.id
                            filterPiantaId = nil
                        }
                    }
                } label: {
                    filterChip(
                        label: orti.first(where: { $0.id == filterOrtoId })?.nome ?? lang.calendar.filterGardenDefault,
                        isActive: filterOrtoId != nil
                    )
                }

                Menu {
                    Button(lang.calendar.filterAllTypes) { filterTipologia = nil }
                    ForEach(tipologie, id: \.color) { tipo in
                        Button(tipo.label) { filterTipologia = tipo.color }
                    }
                } label: {
                    filterChip(
                        label: tipologie.first(where: { $0.color == filterTipologia })?.label ?? lang.calendar.filterTypeDefault,
                        isActive: filterTipologia != nil
                    )
                }

                Menu {
                    Button(lang.calendar.filterAllPlants) { filterPiantaId = nil }
                    ForEach(visiblePiante) { pianta in
                        Button(pianta.nomePersonalizzato) { filterPiantaId = pianta.id }
                    }
                } label: {
                    filterChip(
                        label: piante.first(where: { $0.id == filterPiantaId })?.nomePersonalizzato ?? lang.calendar.filterPlantDefault,
                        isActive: filterPiantaId != nil
                    )
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 6)
        }
    }

    private func filterChip(label: String, isActive: Bool) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.dmSans(11, weight: isActive ? .semibold : .regular))
            Image(systemName: "chevron.down")
                .font(.system(size: 9, weight: .medium))
        }
        .foregroundColor(isActive ? .white : AppTheme.textPrimary)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(isActive ? AppTheme.primaryGreen : AppTheme.cardBackground)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(isActive ? Color.clear : Color.secondary.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Calendar Content

    private var calendarContent: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                monthNavigator
                weekDayHeader
                calendarGrid
                legendView
            }
            .background(AppTheme.cardSecondaryWarm)
            Spacer()
        }
    }

    // MARK: - Month Navigator

    private var monthNavigator: some View {
        HStack {
            Button {
                withAnimation { currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth }
            } label: {
                Image(systemName: "chevron.left").font(.title3)
            }

            Spacer()

            Text(monthYearString)
                .font(.title2)
                .fontWeight(.semibold)

            Spacer()

            Button {
                withAnimation { currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth }
            } label: {
                Image(systemName: "chevron.right").font(.title3)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    // MARK: - Weekday Header

    private var weekDayHeader: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(weekDays.indices, id: \.self) { index in
                Text(weekDays[index])
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
            }
        }
    }

    // MARK: - Calendar Grid

    private var calendarGrid: some View {
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        let firstWeekday = (calendar.component(.weekday, from: firstDay) - 2 + 7) % 7
        let daysInMonth = range.count
        let totalCells = firstWeekday + daysInMonth
        let rows = (totalCells + 6) / 7

        return LazyVGrid(columns: columns, spacing: 0) {
            ForEach(0..<(rows * 7), id: \.self) { index in
                let day = index - firstWeekday + 1
                if day >= 1 && day <= daysInMonth {
                    cellView(day: day)
                } else {
                    Color.clear.aspectRatio(1, contentMode: .fill)
                }
            }
        }
    }

    // MARK: - Day Cell

    private func cellView(day: Int) -> some View {
        let date = calendar.date(from: DateComponents(
            year: calendar.component(.year, from: currentMonth),
            month: calendar.component(.month, from: currentMonth),
            day: day
        ))!
        let isToday = calendar.isDateInToday(date)
        let dayActivities = filteredActivities.filter { calendar.isDate($0.data, inSameDayAs: date) }
        let dateStr: String = {
            let f = ISO8601DateFormatter(); f.formatOptions = [.withFullDate]
            return f.string(from: date)
        }()
        let hasRain = dayActivities.contains { $0.rainAdjusted || $0.rainRescheduled } || rainDays[dateStr] != nil

        return Button {
            selectedDate = date
            showDayDetail = true
        } label: {
            VStack(spacing: 2) {
                Text("\(day)")
                    .font(.callout)
                    .fontWeight(isToday ? .bold : .regular)
                    .foregroundColor(isToday ? .white : .primary)
                    .frame(width: 28, height: 28)
                    .background(isToday ? AppTheme.primaryGreen : Color.clear)
                    .clipShape(Circle())

                if !dayActivities.isEmpty {
                    HStack(spacing: 2) {
                        ForEach(Array(dayActivities.prefix(3)), id: \.id) { activity in
                            Circle()
                                .fill(activity.colorValue)
                                .frame(width: 5, height: 5)
                        }
                        if dayActivities.count > 3 {
                            Text("+\(dayActivities.count - 3)")
                                .font(.system(size: 7))
                                .foregroundColor(.secondary)
                        }
                    }
                }

                HStack(spacing: 3) {
                    if hasRain {
                        VStack(spacing: 0) {
                            Image(systemName: "cloud.rain.fill")
                                .font(.system(size: 9))
                                .symbolRenderingMode(.monochrome)
                                .foregroundStyle(AppTheme.rainBlue)
                            if let mm = rainDays[dateStr] {
                                Text(String(format: "%.0fmm", mm))
                                    .font(.system(size: 6))
                                    .foregroundStyle(AppTheme.rainBlue)
                            }
                        }
                    }
                    if let tMin = frostDays[dateStr] {
                        VStack(spacing: 0) {
                            Image(systemName: "snowflake")
                                .font(.system(size: 9))
                                .foregroundStyle(.cyan)
                            Text(String(format: "%.0f°", tMin))
                                .font(.system(size: 6))
                                .foregroundStyle(.cyan)
                        }
                    }
                }
            }
            .frame(height: 52)
            .frame(maxWidth: .infinity)
            .background(dateColor(date))
        }
    }

    private func dateColor(_ date: Date) -> Color {
        guard let selected = selectedDate else { return .clear }
        return calendar.isDate(date, inSameDayAs: selected) ? AppTheme.primaryGreen.opacity(0.1) : .clear
    }

    // MARK: - Legend

    private var legendView: some View {
        let items: [(Color, String)] = [
            (AppTheme.activityGreen,  lang.calendar.legendSeedTransplant),
            (AppTheme.activityOrange, lang.calendar.legendHarvest),
            (AppTheme.activityBlue,   lang.calendar.legendWatering),
            (AppTheme.activityRed,    lang.calendar.legendTreatment),
            (AppTheme.activityGray,   lang.calendar.legendPruning),
            (AppTheme.activityPurple, lang.calendar.legendReminder),
        ]
        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 4) {
            ForEach(items, id: \.1) { color, label in
                HStack(spacing: 6) {
                    Circle().fill(color).frame(width: 8, height: 8)
                    Text(label)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(AppTheme.backgroundCream)
    }

    // MARK: - Agenda Content

    private var agendaContent: some View {
        let today = calendar.startOfDay(for: Date())
        let upcoming = filteredActivities
            .filter { calendar.startOfDay(for: $0.data) >= today }
            .sorted { $0.data < $1.data }

        let grouped = Dictionary(grouping: upcoming) { calendar.startOfDay(for: $0.data) }
        let sortedDates = grouped.keys.sorted()

        return Group {
            if upcoming.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text(lang.calendar.noActivitiesAgenda)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            } else {
                List {
                    ForEach(sortedDates, id: \.self) { date in
                        Section(header: agendaDateHeader(date)) {
                            ForEach(grouped[date] ?? []) { activity in
                                DayActivityRow(activity: activity)
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
    }

    private func agendaDateHeader(_ date: Date) -> some View {
        let isToday = calendar.isDateInToday(date)
        let isTomorrow = calendar.isDateInTomorrow(date)
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "it_IT")
        formatter.dateFormat = "EEEE d MMMM"
        let label: String
        if isToday { label = lang.calendar.todayLabel }
        else if isTomorrow { label = lang.calendar.tomorrowLabel }
        else { label = formatter.string(from: date).capitalized }

        return HStack {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundColor(isToday ? AppTheme.primaryGreen : .secondary)
            Spacer()
        }
    }

    // MARK: - Helpers

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "it_IT")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth).capitalized
    }

    private func applyRainRescheduling() async {
        let cal = Calendar.current
        let components = cal.dateComponents([.year, .month], from: currentMonth)
        guard let monthStart = cal.date(from: components),
              let to = cal.date(byAdding: .month, value: 1, to: monthStart),
              let from = cal.date(byAdding: .day, value: -7, to: monthStart) else { return }

        var fetched: [String: Double] = [:]
        var frost: [String: Double] = [:]
        for orto in orti {
            guard let lat = orto.latitudine, let lon = orto.longitudine else { continue }
            let weather = (try? await OpenMeteoClient.shared.fetchDaily(
                latitude: lat, longitude: lon, from: from, to: to)) ?? DailyWeather()
            for (k, v) in weather.rainDays { fetched[k] = max(fetched[k] ?? 0, v) }
            for (k, v) in weather.frostDays { frost[k] = min(frost[k] ?? v, v) }
        }
        rainDays = fetched
        frostDays = frost

        let actions = RainAdjuster.computeRescheduling(activities: activities, rainDays: fetched)
        guard !actions.isEmpty else { return }

        var successCount = 0
        for action in actions {
            var nextActivity: Attivita? = activities
                .filter { $0.piantaId == action.piantaId && $0.nome == action.nome && $0.data > action.absorbedDate }
                .sorted { $0.data < $1.data }
                .first
            if nextActivity == nil {
                nextActivity = try? await repository.fetchNextIrrigation(
                    piantaId: action.piantaId, nome: action.nome, after: action.absorbedDate)
            }

            var rescheduleOk = true
            if let next = nextActivity {
                do { try await repository.rescheduleAttivita(id: next.id, date: action.newDate) }
                catch { rescheduleOk = false }
            }
            if rescheduleOk {
                try? await repository.markRainAbsorbed(id: action.absorbedId)
                successCount += 1
            }
        }

        if let refreshed = try? await repository.fetchAttivita(date: currentMonth) {
            activities = refreshed
            LocalCache.save(refreshed, key: LocalCache.monthKey(for: currentMonth))
        }

        if successCount > 0 {
            rainRescheduledCount = successCount
            withAnimation { showRainToast = true }
            Task {
                try? await Task.sleep(for: .seconds(4))
                withAnimation { showRainToast = false }
            }
        }
    }

    private func loadFiltersData() async {
        guard let userId = authManager.user?.id else { return }
        if let fetchedOrti = try? await repository.fetchOrti(userId: userId) {
            orti = fetchedOrti
            LocalCache.save(fetchedOrti, key: LocalCache.ortiKey)
        } else {
            orti = LocalCache.load([Orto].self, key: LocalCache.ortiKey) ?? []
        }
        if let fetchedPiante = try? await repository.fetchAllPiante(userId: userId) {
            piante = fetchedPiante
            LocalCache.save(fetchedPiante, key: LocalCache.pianteKey)
        } else {
            piante = LocalCache.load([PiantaColtivata].self, key: LocalCache.pianteKey) ?? []
        }
    }

    private func loadMonth() async {
        isLoading = true
        if orti.isEmpty { await loadFiltersData() }
        let cacheKey = LocalCache.monthKey(for: currentMonth)
        do {
            activities = try await repository.fetchAttivita(date: currentMonth)
            LocalCache.save(activities, key: cacheKey)
            loadError = nil
            isOffline = false
        } catch {
            if let cached = LocalCache.load([Attivita].self, key: cacheKey) {
                activities = cached
                isOffline = true
                loadError = nil
            } else {
                loadError = lang.calendar.loadErrorMsg
                isOffline = false
            }
        }
        await applyRainRescheduling()
        isLoading = false

        // Aggiorna promemoria e dati widget solo quando guardiamo il mese corrente
        if calendar.isDate(currentMonth, equalTo: Date(), toGranularity: .month) {
            await NotificationManager.shared.reschedule(activities: activities)
            WidgetDataExporter.export(activities: activities, piante: piante)
        }
    }
}

#Preview {
    CalendarGridView()
        .environment(SupabaseRepository.shared)
        .environment(AuthManager.shared)
        .environment(LanguageManager.shared)
}
