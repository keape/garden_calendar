import SwiftUI

struct PiantaListView: View {
    @Environment(SupabaseRepository.self) private var repository
    @Environment(AuthManager.self) private var authManager

    @State private var piante: [PiantaColtivata] = []
    @State private var searchText = ""

    private var columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]

    private var filteredPiante: [PiantaColtivata] {
        guard !searchText.isEmpty else { return piante }
        return piante.filter { $0.nomePersonalizzato.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Cerca piante...", text: $searchText)
                        .autocorrectionDisabled()
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(12)
                .background(AppTheme.cardSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
                .padding(.top, 8)

                if filteredPiante.isEmpty {
                    Spacer()
                    emptyState
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(filteredPiante) { pianta in
                                NavigationLink(value: pianta) {
                                    PiantaCardView(pianta: pianta)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .background(AppTheme.backgroundCream)
            .navigationTitle("Piante")
            .navigationDestination(for: PiantaColtivata.self) { pianta in
                PiantaDetailView(pianta: pianta)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: AggiungiPiantaView()) {
                        Image(systemName: "plus")
                    }
                }
            }
            .task { await loadData() }
            .refreshable { await loadData() }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        ContentUnavailableView {
            Label("Nessuna pianta trovata", systemImage: "leaf")
        } description: {
            Text("Aggiungi la tua prima pianta per iniziare a tracciarla.")
        } actions: {
            NavigationLink(destination: AggiungiPiantaView()) {
                Label("Aggiungi pianta", systemImage: "plus")
                    .fontWeight(.semibold)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.primaryGreen)
        }
    }

    // MARK: - Helpers

    private func loadData() async {
        guard let userId = authManager.user?.id else { return }
        do { piante = try await repository.fetchAllPiante(userId: userId) } catch {}
    }
}

// MARK: - Pianta Card

struct PiantaCardView: View {
    let pianta: PiantaColtivata

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.primaryGreen.opacity(0.2), AppTheme.primaryGreen.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 100)

                Image(systemName: "leaf.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(AppTheme.primaryGreen)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(pianta.nomePersonalizzato)
                    .font(.dmSans(15, weight: .medium))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(1)

                Text("\(pianta.growthDays) giorni totali")
                    .font(.dmSans(12))
                    .foregroundStyle(AppTheme.textSecondary)

                ProgressView(value: pianta.progressoCiclo)
                    .tint(AppTheme.primaryGreen)

                Text("\(pianta.giorniTrascorsi)g / \(pianta.growthDays)g")
                    .font(.dmSans(12))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
    }
}

#Preview {
    PiantaListView()
        .environment(SupabaseRepository.shared)
        .environment(AuthManager.shared)
}
