import SwiftUI

struct PiantaDetailView: View {
    @State private var pianta: PiantaColtivata
    @Environment(SupabaseRepository.self) private var repository
    @Environment(LanguageManager.self) private var lang
    @State private var attivita: [Attivita] = []
    @State private var attivitaSelezionata: Attivita?
    @State private var showNuovaAttivita = false
    @State private var showModificaAttivita = false
    @State private var raccolti: [Raccolto] = []
    @State private var showNuovoRaccolto = false

    init(pianta: PiantaColtivata) {
        _pianta = State(initialValue: pianta)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection
                    .padding(.horizontal)

                progressSection
                    .padding(.horizontal)

                activitiesSection
                    .padding(.horizontal)

                raccoltiSection
                    .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(AppTheme.backgroundCream)
        .navigationTitle(pianta.nomePersonalizzato)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(lang.plants.editButton) { showModificaAttivita = true }
            }
        }
        .task { await loadData() }
        .refreshable { await loadData() }
        .sheet(item: $attivitaSelezionata, onDismiss: { Task { await loadData() } }) { att in
            ModificaIntervalloSheet(pianta: pianta, attivita: att, tutteAttivita: attivita)
                .environment(repository)
        }
        .sheet(isPresented: $showNuovaAttivita, onDismiss: { Task { await loadData() } }) {
            NuovaAttivitaSheet(pianta: pianta)
                .environment(repository)
        }
        .sheet(isPresented: $showModificaAttivita, onDismiss: { Task { await loadData() } }) {
            ModificaPiantaSheet(pianta: pianta, attivita: attivita)
                .environment(repository)
        }
        .sheet(isPresented: $showNuovoRaccolto, onDismiss: { Task { await loadData() } }) {
            NuovoRaccoltoSheet(pianta: pianta)
                .environment(repository)
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.primaryGreen.opacity(0.25), AppTheme.primaryGreen.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 180)

                Image(systemName: "leaf.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(AppTheme.primaryGreen)
            }

            HStack(spacing: 16) {
                Label("\(pianta.giorniTrascorsi)g / \(pianta.growthDays)g", systemImage: "clock")
                    .font(.dmSans(15, weight: .medium))
                    .foregroundStyle(AppTheme.textSecondary)

                Label(String(format: lang.plants.activitiesCountFormat, attivita.count), systemImage: "checklist")
                    .font(.dmSans(15, weight: .medium))
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
    }

    // MARK: - Progress Section

    private var progressSection: some View {
        VStack(spacing: 4) {
            ProgressView(value: pianta.progressoCiclo)
                .tint(pianta.progressoCiclo >= 1.0 ? AppTheme.accentAmbra : AppTheme.primaryGreen)
                .scaleEffect(x: 1, y: 2, anchor: .center)

            HStack {
                Text(pianta.dataSemina, style: .date)
                    .font(.dmSans(12))
                    .foregroundStyle(AppTheme.textSecondary)
                Spacer()
                Text(pianta.progressoCiclo >= 1.0 ? lang.plants.completedLabel : "\(Int(pianta.progressoCiclo * 100))%")
                    .font(.dmSans(12, weight: .semibold))
                    .foregroundStyle(AppTheme.primaryGreen)
                Spacer()
                Text(pianta.dataRaccoltaPrevista, style: .date)
                    .font(.dmSans(12))
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.03), radius: 4, y: 2)
    }

    // MARK: - Activities Section

    private var activitiesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(lang.plants.activitiesSectionTitle)
                    .font(.dmSans(15, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                Spacer()
                Button { showNuovaAttivita = true } label: {
                    Image(systemName: "plus")
                }
            }

            if attivita.isEmpty {
                Text(lang.plants.noActivitiesPlant)
                    .font(.dmSans(15))
                    .foregroundStyle(AppTheme.textSecondary)
                    .padding(.vertical, 8)
            }

            let today = Calendar.current.startOfDay(for: Date())
            let future = attivita.filter { !$0.done && $0.data >= today }
            let past = attivita.filter { $0.done || $0.data < today }

            if !future.isEmpty {
                Text(lang.plants.scheduledSection)
                    .font(.dmSans(12, weight: .semibold))
                    .foregroundStyle(AppTheme.primaryGreen)

                ForEach(future) { att in
                    AttivitaRow(
                        attivita: att,
                        onToggle: { toggleDone(att) },
                        onInfo: { attivitaSelezionata = att }
                    )
                }
            }

            if !past.isEmpty {
                Text(lang.plants.pastSection)
                    .font(.dmSans(12, weight: .semibold))
                    .foregroundStyle(AppTheme.textSecondary)

                ForEach(past) { att in
                    AttivitaRow(
                        attivita: att,
                        onToggle: { toggleDone(att) },
                        onInfo: { attivitaSelezionata = att }
                    )
                }
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.03), radius: 4, y: 2)
    }

    // MARK: - Raccolti Section

    private var raccoltiSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(lang.plants.harvestSectionTitle)
                    .font(.dmSans(15, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                Spacer()
                Button { showNuovoRaccolto = true } label: {
                    Image(systemName: "plus")
                }
            }

            if raccolti.isEmpty {
                Text(lang.plants.noHarvests)
                    .font(.dmSans(15))
                    .foregroundStyle(AppTheme.textSecondary)
                    .padding(.vertical, 8)
            } else {
                ForEach(totaliPerAnno, id: \.anno) { totale in
                    HStack {
                        Text(String(totale.anno))
                            .font(.dmSans(12, weight: .semibold))
                            .foregroundStyle(AppTheme.primaryGreen)
                        Spacer()
                        Text(totale.descrizione)
                            .font(.dmSans(12, weight: .semibold))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }

                Divider()

                ForEach(raccolti) { raccolto in
                    RaccoltoRow(raccolto: raccolto, onDelete: { deleteRaccolto(raccolto) })
                }
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.03), radius: 4, y: 2)
    }

    /// Totali per anno (per confrontare le stagioni), raggruppati per unità.
    private var totaliPerAnno: [(anno: Int, descrizione: String)] {
        let calendar = Calendar.current
        let perAnno = Dictionary(grouping: raccolti) { calendar.component(.year, from: $0.data) }
        return perAnno
            .map { anno, items in
                let perUnita = Dictionary(grouping: items, by: \.unita)
                    .map { unita, list in
                        let totale = list.reduce(0) { $0 + $1.quantita }
                        return "\(totale.formatted(.number.precision(.fractionLength(0...1)))) \(unita)"
                    }
                    .sorted()
                return (anno: anno, descrizione: perUnita.joined(separator: " · "))
            }
            .sorted { $0.anno > $1.anno }
    }

    // MARK: - Helpers

    private func loadData() async {
        do {
            async let attivitaFetch = repository.fetchAttivita(piantaId: pianta.id)
            async let piantaFetch = repository.fetchPianta(id: pianta.id)
            async let raccoltiFetch = repository.fetchRaccolti(piantaId: pianta.id)
            let (fetchedAttivita, fetchedPianta, fetchedRaccolti) = try await (attivitaFetch, piantaFetch, raccoltiFetch)
            attivita = fetchedAttivita
            pianta = fetchedPianta
            raccolti = fetchedRaccolti
        } catch {}
    }

    private func deleteRaccolto(_ raccolto: Raccolto) {
        raccolti.removeAll { $0.id == raccolto.id }
        Task { try? await repository.deleteRaccolto(id: raccolto.id) }
    }

    private func toggleDone(_ att: Attivita) {
        if let i = attivita.firstIndex(where: { $0.id == att.id }) {
            attivita[i].done.toggle()
        }
        Task { try? await repository.setDone(id: att.id, done: !att.done) }
    }
}

// MARK: - Attività Row

struct AttivitaRow: View {
    let attivita: Attivita
    let onToggle: () -> Void
    let onInfo: () -> Void
    @Environment(LanguageManager.self) private var lang

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: attivita.done ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(attivita.done ? .green : .secondary)
                    .font(.title3)
            }
            .buttonStyle(.plain)

            ActivityColorDot(activityName: attivita.nome, size: 10)

            VStack(alignment: .leading, spacing: 2) {
                Text(attivita.nome.capitalized)
                    .font(.dmSans(15, weight: .medium))
                    .foregroundStyle(AppTheme.textPrimary)
                    .strikethrough(attivita.done)

                Text(attivita.data, style: .date)
                    .font(.dmSans(12))
                    .foregroundStyle(AppTheme.textSecondary)

                if attivita.recurrenceDays != nil {
                    Label(lang.plants.recurringLabel, systemImage: "repeat")
                        .font(.dmSans(12))
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }

            Spacer()

            Button(action: onInfo) {
                Image(systemName: "info.circle")
                    .foregroundStyle(.secondary)
                    .font(.body)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Raccolto Row

struct RaccoltoRow: View {
    let raccolto: Raccolto
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "basket.fill")
                .foregroundStyle(AppTheme.accentAmbra)
                .font(.body)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(raccolto.quantita.formatted(.number.precision(.fractionLength(0...1)))) \(raccolto.unita)")
                    .font(.dmSans(15, weight: .medium))
                    .foregroundStyle(AppTheme.textPrimary)

                Text(raccolto.data, style: .date)
                    .font(.dmSans(12))
                    .foregroundStyle(AppTheme.textSecondary)

                if let note = raccolto.note, !note.isEmpty {
                    Text(note)
                        .font(.dmSans(12))
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundStyle(.secondary)
                    .font(.body)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Nuovo Raccolto Sheet

struct NuovoRaccoltoSheet: View {
    let pianta: PiantaColtivata
    @Environment(SupabaseRepository.self) private var repository
    @Environment(\.dismiss) private var dismiss
    @Environment(LanguageManager.self) private var lang

    @State private var data = Date()
    @State private var quantita: Double = 1
    @State private var unita = "kg"
    @State private var note = ""
    @State private var isSaving = false
    @State private var saveFailed = false

    private let unitaOptions = ["kg", "g", "pezzi", "mazzi", "cesti"]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker(lang.plants.datePicker, selection: $data, in: ...Date(), displayedComponents: .date)
                        .font(.dmSans(15))

                    HStack {
                        Text(lang.plants.quantityLabel)
                            .font(.dmSans(15))
                        Spacer()
                        TextField(lang.plants.quantityPlaceholder, value: $quantita, format: .number.precision(.fractionLength(0...2)))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                            .font(.dmSans(15))
                    }

                    Picker(lang.plants.unitPicker, selection: $unita) {
                        ForEach(unitaOptions, id: \.self) { Text($0) }
                    }
                    .font(.dmSans(15))

                    TextField(lang.plants.optionalNotesPlaceholder, text: $note, axis: .vertical)
                        .font(.dmSans(15))
                } footer: {
                    if saveFailed {
                        Text(lang.plants.saveFailedMsg)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle(lang.plants.newHarvestNavTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(lang.common.cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(lang.common.save) { save() }
                        .disabled(quantita <= 0 || isSaving)
                }
            }
        }
    }

    private func save() {
        isSaving = true
        saveFailed = false
        Task {
            do {
                _ = try await repository.createRaccolto(RaccoltoCreate(
                    piantaId: pianta.id,
                    data: data,
                    quantita: quantita,
                    unita: unita,
                    note: note.isEmpty ? nil : note
                ))
                dismiss()
            } catch {
                saveFailed = true
                isSaving = false
            }
        }
    }
}

#Preview {
    NavigationStack {
        PiantaDetailView(pianta: PiantaColtivata(
            id: UUID(),
            ortoId: UUID(),
            specieId: nil,
            nomePersonalizzato: "Pomodoro",
            dataSemina: Calendar.current.date(byAdding: .day, value: -30, to: Date())!,
            growthDays: 90,
            note: nil,
            fotoUrl: nil,
            activityOverrides: nil,
            createdAt: Date(),
            updatedAt: Date()
        ))
        .environment(SupabaseRepository.shared)
        .environment(LanguageManager.shared)
    }
}
