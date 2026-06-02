import SwiftUI

struct PiantaDetailView: View {
    @State private var pianta: PiantaColtivata
    @Environment(SupabaseRepository.self) private var repository
    @State private var attivita: [Attivita] = []
    @State private var attivitaSelezionata: Attivita?

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
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(pianta.nomePersonalizzato)
        .navigationBarTitleDisplayMode(.large)
        .task { await loadData() }
        .refreshable { await loadData() }
        .sheet(item: $attivitaSelezionata, onDismiss: { Task { await loadData() } }) { att in
            ModificaIntervalloSheet(pianta: pianta, attivita: att, tutteAttivita: attivita)
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
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Label("\(attivita.count) attività", systemImage: "checklist")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
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
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(pianta.progressoCiclo >= 1.0 ? "Completato! 🎉" : "\(Int(pianta.progressoCiclo * 100))%")
                    .font(.caption2.bold())
                    .foregroundStyle(AppTheme.primaryGreen)
                Spacer()
                Text(pianta.dataRaccoltaPrevista, style: .date)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
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
            Text("📋 Attività")
                .font(.headline)

            if attivita.isEmpty {
                Text("Nessuna attività registrata per questa pianta.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            }

            let today = Calendar.current.startOfDay(for: Date())
            let future = attivita.filter { !$0.done && $0.data >= today }
            let past = attivita.filter { $0.done || $0.data < today }

            if !future.isEmpty {
                Text("In programma")
                    .font(.subheadline.bold())
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
                Text("Completate / Passate")
                    .font(.subheadline.bold())
                    .foregroundStyle(.secondary)

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

    // MARK: - Helpers

    private func loadData() async {
        do {
            async let attivitaFetch = repository.fetchAttivita(piantaId: pianta.id)
            async let piantaFetch = repository.fetchPianta(id: pianta.id)
            let (fetchedAttivita, fetchedPianta) = try await (attivitaFetch, piantaFetch)
            attivita = fetchedAttivita
            pianta = fetchedPianta
        } catch {}
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
                    .font(.subheadline)
                    .strikethrough(attivita.done)

                Text(attivita.data, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if attivita.recurrenceDays != nil {
                    Label("Ricorrente", systemImage: "repeat")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
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
    }
}
