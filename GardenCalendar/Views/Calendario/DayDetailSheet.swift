import SwiftUI

struct DayDetailSheet: View {
    let selectedDate: Date
    @State private var activities: [Attivita]

    @Environment(SupabaseRepository.self) private var repository
    @Environment(\.dismiss) private var dismiss

    init(selectedDate: Date, activities: [Attivita] = []) {
        self.selectedDate = selectedDate
        self._activities = State(initialValue: activities)
    }
    @State private var showQuickJournal = false
    @State private var editingActivity: Attivita?
    @State private var showReschedulePicker = false
    @State private var rescheduleDate = Date()
    @State private var pianteLookup: [UUID: String] = [:]

    private let calendar = Calendar.current

    private var journalActivities: [Attivita] {
        activities.filter { $0.userEvent }
    }

    private var aiActivities: [Attivita] {
        let trapiantoPiantaIds = Set(
            journalActivities
                .filter { $0.nome.lowercased() == "trapianto" }
                .map { $0.piantaId }
        )
        return activities.filter { !$0.userEvent }.filter { activity in
            !(activity.nome.lowercased() == "semina" && trapiantoPiantaIds.contains(activity.piantaId))
        }
    }

    var body: some View {
        NavigationStack {
            List {
                // Header data
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(formattedDate)
                                .font(.title.bold())

                            Text(dayRelativeString)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        WeatherIcon(rainDays: activities.contains { $0.rainAdjusted || $0.rainRescheduled } ? 3 : 0, size: 28)
                    }
                    .padding(.vertical, 4)
                }

                // 📝 Journal eventi
                if !journalActivities.isEmpty {
                    Section("📝 Dal tuo journal") {
                        ForEach(journalActivities) { activity in
                            DayActivityRow(activity: activity, piantaNome: pianteLookup[activity.piantaId])
                                .swipeActions(edge: .trailing) {
                                    Button(action: { rescheduleActivity(activity) }) {
                                        Label("Sposta", systemImage: "arrow.right")
                                    }
                                    .tint(.blue)
                                }
                                .swipeActions(edge: .leading) {
                                    Button(action: { moveActivityBack(activity) }) {
                                        Label("Indietro", systemImage: "arrow.left")
                                    }
                                    .tint(.orange)
                                }
                        }
                    }
                }

                // 💡 Suggerimenti AI
                if !aiActivities.isEmpty {
                    Section("💡 Suggerimenti AI") {
                        ForEach(aiActivities) { activity in
                            DayActivityRow(activity: activity, piantaNome: pianteLookup[activity.piantaId])
                                .swipeActions(edge: .trailing) {
                                    Button(action: { rescheduleActivity(activity) }) {
                                        Label("Sposta", systemImage: "arrow.right")
                                    }
                                    .tint(.blue)
                                }
                                .swipeActions(edge: .leading) {
                                    Button(action: { moveActivityBack(activity) }) {
                                        Label("Indietro", systemImage: "arrow.left")
                                    }
                                    .tint(.orange)
                                }
                        }
                    }
                }

                // Nessuna attività
                if activities.isEmpty {
                    Section {
                        VStack(spacing: 12) {
                            Image(systemName: "calendar.day.timeline.left")
                                .font(.system(size: 40))
                                .foregroundStyle(.secondary.opacity(0.5))

                            Text("Nessuna attività per questo giorno")
                                .font(.headline)
                                .foregroundStyle(.secondary)

                            Text("Aggiungi un evento rapido per iniziare.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                    }
                }

                // Bottone aggiungi journal
                Section {
                    Button(action: { showQuickJournal = true }) {
                        Label("Aggiungi journal entry", systemImage: "plus.circle.fill")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.accentAmbra)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Dettaglio giorno")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Chiudi") { dismiss() }
                }
            }
            .sheet(isPresented: $showQuickJournal, onDismiss: { Task { await loadActivities() } }) {
                QuickJournalView()
            }
            .task { await loadActivities() }
            .sheet(isPresented: $showReschedulePicker) {
                rescheduleSheet
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Reschedule Sheet

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

    // MARK: - Helpers

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE d MMMM"
        formatter.locale = Locale(identifier: "it_IT")
        return formatter.string(from: selectedDate).capitalized
    }

    private var dayRelativeString: String {
        if calendar.isDateInToday(selectedDate) { return "Oggi" }
        if calendar.isDateInYesterday(selectedDate) { return "Ieri" }
        if calendar.isDateInTomorrow(selectedDate) { return "Domani" }
        return ""
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

    private func loadActivities() async {
        let all = (try? await repository.fetchAttivita(date: selectedDate)) ?? []
        activities = all.filter { Calendar.current.isDate($0.data, inSameDayAs: selectedDate) }

        if let userId = AuthManager.shared.user?.id {
            let piante = (try? await repository.fetchAllPiante(userId: userId)) ?? []
            pianteLookup = Dictionary(uniqueKeysWithValues: piante.map { ($0.id, $0.nomePersonalizzato) })
        }
    }

    private func confirmReschedule() {
        if let activity = editingActivity {
            Task { try? await repository.rescheduleAttivita(id: activity.id, date: rescheduleDate) }
        }
        showReschedulePicker = false
        editingActivity = nil
    }
}

// MARK: - Day Activity Row

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
    DayDetailSheet(selectedDate: Date(), activities: [])
        .environment(SupabaseRepository.shared)
}
