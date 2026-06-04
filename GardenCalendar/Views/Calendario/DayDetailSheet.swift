import SwiftUI

struct DayDetailView: View {
    let selectedDate: Date
    @State private var activities: [Attivita]
    @State private var rainMm: Double = 0
    @State private var showAddActivity = false
    @State private var editingActivity: Attivita?
    @State private var showReschedulePicker = false
    @State private var rescheduleDate = Date()
    @State private var pianteLookup: [UUID: String] = [:]
    @State private var ortoLookup: [UUID: String] = [:]

    @Environment(SupabaseRepository.self) private var repository

    init(selectedDate: Date, activities: [Attivita] = []) {
        self.selectedDate = selectedDate
        self._activities = State(initialValue: activities)
    }

    private let calendar = Calendar.current

    private var doneFraction: Double {
        guard !activities.isEmpty else { return 0 }
        return Double(activities.filter(\.done).count) / Double(activities.count)
    }

    private var progressLabel: String {
        "\(activities.filter(\.done).count) / \(activities.count)"
    }

    var body: some View {
        VStack(spacing: 0) {
            Text(dateHeaderString)
                .font(.dmSans(11, weight: .medium))
                .foregroundStyle(AppTheme.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 4)

            Text("Attività del giorno")
                .font(.lora(22))
                .foregroundStyle(AppTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 4)

            VStack(alignment: .trailing, spacing: 3) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(AppTheme.cardSecondaryWarm)
                            .frame(height: 4)
                        Capsule()
                            .fill(AppTheme.primaryGreen)
                            .frame(width: geo.size.width * doneFraction, height: 4)
                    }
                }
                .frame(height: 4)

                Text(progressLabel)
                    .font(.dmSans(10))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 4)

            if activities.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "calendar.day.timeline.left")
                        .font(.system(size: 40))
                        .foregroundStyle(AppTheme.textSecondary.opacity(0.4))
                    Text("Nessuna attività per questo giorno")
                        .font(.dmSans(15, weight: .medium))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(activities) { activity in
                            NaturalistaActivityRow(
                                activity: activity,
                                piantaNome: pianteLookup[activity.piantaId],
                                ortoNome: ortoLookup[activity.piantaId]
                            )
                            .swipeActions(edge: .trailing) {
                                Button { rescheduleActivity(activity) } label: {
                                    Label("Sposta", systemImage: "arrow.right")
                                }
                                .tint(.blue)
                            }
                            .swipeActions(edge: .leading) {
                                Button { moveActivityBack(activity) } label: {
                                    Label("Indietro", systemImage: "arrow.left")
                                }
                                .tint(.orange)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
            }

            Button {
                showAddActivity = true
            } label: {
                HStack {
                    Image(systemName: "plus")
                    Text("Aggiungi attività")
                        .font(.dmSans(15, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(AppTheme.ctaDarkGreen)
                .clipShape(Capsule())
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .background(AppTheme.backgroundCream)
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadActivities() }
        .sheet(isPresented: $showAddActivity, onDismiss: { Task { await loadActivities() } }) {
            QuickJournalView()
        }
        .sheet(isPresented: $showReschedulePicker) {
            rescheduleSheet
        }
    }

    private var rescheduleSheet: some View {
        NavigationStack {
            Form {
                Section("Sposta attività") {
                    DatePicker("Nuova data", selection: $rescheduleDate, displayedComponents: .date)
                }
                Section {
                    Button(action: confirmReschedule) {
                        Text("Conferma spostamento")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle("Reschedule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Annulla") { showReschedulePicker = false }
                }
            }
        }
        .presentationDetents([.height(250)])
    }

    private var dateHeaderString: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "it_IT")
        f.dateFormat = "EEE · d MMMM yyyy"
        return f.string(from: selectedDate).uppercased()
    }

    private func rescheduleActivity(_ activity: Attivita) {
        editingActivity = activity
        rescheduleDate = activity.data
        showReschedulePicker = true
    }

    private func moveActivityBack(_ activity: Attivita) {
        let newDate = calendar.date(byAdding: .day, value: -1, to: activity.data) ?? activity.data
        Task { try? await repository.rescheduleAttivita(id: activity.id, date: newDate) }
    }

    private func confirmReschedule() {
        if let activity = editingActivity {
            Task { try? await repository.rescheduleAttivita(id: activity.id, date: rescheduleDate) }
        }
        showReschedulePicker = false
        editingActivity = nil
    }

    private func loadActivities() async {
        let all = (try? await repository.fetchAttivita(date: selectedDate)) ?? []
        activities = all.filter { calendar.isDate($0.data, inSameDayAs: selectedDate) }

        if let userId = AuthManager.shared.user?.id {
            let piante = (try? await repository.fetchAllPiante(userId: userId)) ?? []
            let orti = (try? await repository.fetchOrti(userId: userId)) ?? []
            pianteLookup = Dictionary(uniqueKeysWithValues: piante.map { ($0.id, $0.nomePersonalizzato) })

            var map: [UUID: String] = [:]
            for p in piante {
                if let orto = orti.first(where: { $0.id == p.ortoId }) {
                    map[p.id] = orto.nome
                }
            }
            ortoLookup = map

            await fetchRainStatus(orti: orti)
        }
    }

    private func fetchRainStatus(orti: [Orto]) async {
        let cal = Calendar.current
        let from = cal.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
        let to = cal.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
        let f = ISO8601DateFormatter(); f.formatOptions = [.withFullDate]
        let dateStr = f.string(from: selectedDate)

        for orto in orti {
            guard let lat = orto.latitudine, let lon = orto.longitudine else { continue }
            let days = (try? await OpenMeteoClient.shared.fetchRainDays(
                latitude: lat, longitude: lon, from: from, to: to)) ?? [:]
            if let mm = days[dateStr], mm > 0 {
                rainMm = mm
                return
            }
        }
        rainMm = 0
    }
}

// MARK: - NaturalistaActivityRow

struct NaturalistaActivityRow: View {
    let activity: Attivita
    var piantaNome: String?
    var ortoNome: String?

    @Environment(SupabaseRepository.self) private var repository

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppTheme.color(for: activity.nome).opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: iconForActivity(activity.nome))
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.color(for: activity.nome))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(piantaNome ?? activity.nome.capitalized)
                    .font(.dmSans(13, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .strikethrough(activity.done)

                HStack(spacing: 4) {
                    Text(activity.nome.capitalized)
                    if let orto = ortoNome {
                        Text("·")
                        Text(orto)
                    }
                }
                .font(.dmSans(10))
                .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer()

            if !formattedTime.isEmpty {
                Text(formattedTime)
                    .font(.dmSans(11))
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Button(action: toggleDone) {
                Image(systemName: activity.done ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(activity.done ? AppTheme.primaryGreen : Color.secondary.opacity(0.4))
                    .font(.system(size: 20))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.04), radius: 4, y: 1)
        .opacity(activity.done ? 0.7 : 1.0)
    }

    private var formattedTime: String {
        let cal = Calendar.current
        let h = cal.component(.hour, from: activity.data)
        let m = cal.component(.minute, from: activity.data)
        guard h != 0 || m != 0 else { return "" }
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: activity.data)
    }

    private func toggleDone() {
        Task { try? await repository.setDone(id: activity.id, done: !activity.done) }
    }

    private func iconForActivity(_ name: String) -> String {
        switch name.lowercased() {
        case "semina":    return "leaf.fill"
        case "trapianto": return "arrow.triangle.branch"
        case "raccolta":  return "basket.fill"
        case "irrigazione", "bevuta": return "drop.fill"
        case "concimazione": return "flask.fill"
        case "potatura":  return "scissors"
        case "sarchiatura": return "leaf.arrow.triangle.circlepath"
        case "trattamento": return "cross.case.fill"
        case "innesto":   return "point.topleft.down.curvedto.point.bottomright.up"
        default:          return "leaf.fill"
        }
    }
}

// MARK: - Day Activity Row (used by CalendarView agenda)

struct DayActivityRow: View {
    let activity: Attivita
    var piantaNome: String? = nil
    @Environment(SupabaseRepository.self) private var repository

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppTheme.color(for: activity.nome).opacity(0.15))
                    .frame(width: 36, height: 36)

                Image(systemName: iconForActivity(activity.nome))
                    .font(.caption)
                    .foregroundStyle(AppTheme.color(for: activity.nome))
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(activity.nome.capitalized)
                        .font(.subheadline.weight(.medium))
                        .strikethrough(activity.done)

                    if activity.recurrenceDays != nil {
                        Image(systemName: "repeat")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                if let nome = piantaNome {
                    Text(nome)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.primary.opacity(0.75))
                }

                Text(activity.data, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if activity.userEvent {
                    Text("Journal")
                        .font(.caption2)
                        .foregroundStyle(AppTheme.accentAmbra)
                }
            }

            Spacer()

            Button(action: toggleDone) {
                Image(systemName: activity.done ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(activity.done ? .green : .secondary)
                    .font(.title3)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
        .opacity(activity.done ? 0.6 : 1.0)
    }

    private func toggleDone() {
        Task { try? await repository.setDone(id: activity.id, done: !activity.done) }
    }

    private func iconForActivity(_ name: String) -> String {
        switch name.lowercased() {
        case "semina": return "leaf.fill"
        case "trapianto": return "arrow.triangle.branch"
        case "raccolta": return "basket.fill"
        case "irrigazione", "bevuta": return "drop.fill"
        case "concimazione": return "flask.fill"
        case "potatura": return "scissors"
        case "sarchiatura": return "leaf.arrow.triangle.circlepath"
        case "trattamento": return "cross.case.fill"
        case "innesto": return "point.topleft.down.curvedto.point.bottomright.up"
        default: return "leaf.fill"
        }
    }
}

#Preview {
    NavigationStack {
        DayDetailView(selectedDate: Date(), activities: [])
            .environment(SupabaseRepository.shared)
    }
}
