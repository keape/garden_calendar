import SwiftUI

struct CalendarGridView: View {
    @Environment(SupabaseRepository.self) private var repository
    @Environment(AuthManager.self) private var authManager

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

    private let calendar = Calendar.current
    private let weekDays = ["L", "M", "M", "G", "V", "S", "D"]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    private let tipologie: [(color: String, label: String)] = [
        ("green",  "Semina / Trapianto"),
        ("orange", "Raccolta"),
        ("blue",   "Irrigazione"),
        ("red",    "Trattamento"),
        ("gray",   "Potatura / Sarchiatura"),
        ("purple", "Promemoria"),
    ]

    enum ViewMode: String, CaseIterable {
        case calendar = "Calendario"
        case agenda = "Agenda"
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
                Picker("Vista", selection: $viewMode) {
                    ForEach(ViewMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 4)

                filterBar

                if viewMode == .calendar {
                    calendarContent
                } else {
                    agendaContent
                }
            }
            .navigationTitle("Calendario")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Oggi") {
                        withAnimation {
                            currentMonth = Date()
                            selectedDate = Date()
                        }
                    }
                    .disabled(calendar.isDate(currentMonth, equalTo: Date(), toGranularity: .month))
                }
            }
        }
        .task { await loadFiltersData() }
        .task { await loadMonth() }
        .onChange(of: currentMonth) { _, _ in Task { await loadMonth() } }
        .onChange(of: filterOrtoId) { _, _ in
            if let piantaId = filterPiantaId,
               !visiblePiante.contains(where: { $0.id == piantaId }) {
                filterPiantaId = nil
            }
        }
        .sheet(isPresented: $showDayDetail, onDismiss: { Task { await loadMonth() } }) {
            if let date = selectedDate {
                DayDetailSheet(
                    selectedDate: date,
                    activities: filteredActivities.filter { calendar.isDate($0.data, inSameDayAs: date) }
                )
            }
        }
    }

    // MARK: - Filter Bar

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Menu {
                    Button("Tutti gli orti") {
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
                        label: orti.first(where: { $0.id == filterOrtoId })?.nome ?? "Orto",
                        isActive: filterOrtoId != nil
                    )
                }

                Menu {
                    Button("Tutte le tipologie") { filterTipologia = nil }
                    ForEach(tipologie, id: \.color) { tipo in
                        Button(tipo.label) { filterTipologia = tipo.color }
                    }
                } label: {
                    filterChip(
                        label: tipologie.first(where: { $0.color == filterTipologia })?.label ?? "Tipologia",
                        isActive: filterTipologia != nil
                    )
                }

                Menu {
                    Button("Tutte le piante") { filterPiantaId = nil }
                    ForEach(visiblePiante) { pianta in
                        Button(pianta.nomePersonalizzato) { filterPiantaId = pianta.id }
                    }
                } label: {
                    filterChip(
                        label: piante.first(where: { $0.id == filterPiantaId })?.nomePersonalizzato ?? "Pianta",
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
                .font(.caption)
                .fontWeight(isActive ? .semibold : .regular)
            Image(systemName: "chevron.down")
                .font(.system(size: 9, weight: .medium))
        }
        .foregroundColor(isActive ? .white : .primary)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(isActive ? AppTheme.primaryGreen : AppTheme.cardSecondary)
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
            .background(AppTheme.cardSecondary)
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
            ForEach(weekDays, id: \.self) { day in
                Text(day)
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
        let hasRain = dayActivities.contains { $0.rainAdjusted || $0.rainRescheduled }

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

                if hasRain {
                    Text("💧").font(.system(size: 8))
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
            (AppTheme.activityGreen,  "Semina / Trapianto"),
            (AppTheme.activityOrange, "Raccolta"),
            (AppTheme.activityBlue,   "Irrigazione"),
            (AppTheme.activityRed,    "Trattamento"),
            (AppTheme.activityGray,   "Potatura / Sarchiatura"),
            (AppTheme.activityPurple, "Promemoria"),
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
        .background(AppTheme.cardBackground)
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
                    Text("Nessuna attività in programma")
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
        if isToday { label = "Oggi" }
        else if isTomorrow { label = "Domani" }
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
        guard let from = cal.date(from: components),
              let to = cal.date(byAdding: .month, value: 1, to: from) else { return }

        var rainDays: [String: Bool] = [:]
        for orto in orti {
            guard let lat = orto.latitudine, let lon = orto.longitudine else { continue }
            let days = (try? await OpenMeteoClient.shared.fetchRainDays(
                latitude: lat, longitude: lon, from: from, to: to)) ?? [:]
            for (k, v) in days where v { rainDays[k] = true }
        }

        let actions = RainAdjuster.computeRescheduling(activities: activities, rainDays: rainDays)
        guard !actions.isEmpty else { return }

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
            if rescheduleOk { try? await repository.markRainAbsorbed(id: action.absorbedId) }
        }

        activities = (try? await repository.fetchAttivita(date: currentMonth)) ?? []
    }

    private func loadFiltersData() async {
        guard let userId = authManager.user?.id else { return }
        orti = (try? await repository.fetchOrti(userId: userId)) ?? []
        piante = (try? await repository.fetchAllPiante(userId: userId)) ?? []
    }

    private func loadMonth() async {
        isLoading = true
        if orti.isEmpty { await loadFiltersData() }
        activities = (try? await repository.fetchAttivita(date: currentMonth)) ?? []
        await applyRainRescheduling()
        isLoading = false
    }
}

#Preview {
    CalendarGridView()
        .environment(SupabaseRepository.shared)
        .environment(AuthManager.shared)
}
