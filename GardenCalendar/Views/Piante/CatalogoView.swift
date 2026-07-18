import SwiftUI

/// Catalogo/knowledge base delle piante censite (`PlantKnowledge`): sfoglia, filtra per
/// categoria, mostra solo le "seminabili ora", apre la scheda dettaglio e permette di
/// aggiungere la pianta scelta a un orto dell'utente.
struct CatalogoView: View {
    @Environment(SupabaseRepository.self) private var repository
    @Environment(AuthManager.self) private var authManager
    @Environment(LanguageManager.self) private var lang

    @State private var catalogo: [PlantKnowledge] = []
    @State private var orti: [Orto] = []
    @State private var searchText = ""
    @State private var categoriaFiltro: PlantType? = nil
    @State private var soloSeminabiliOra = false
    @State private var normals: MonthlyClimateNormals?

    @State private var detailKnowledge: PlantKnowledge? = nil
    @State private var pendingKnowledge: PlantKnowledge? = nil
    @State private var showChooseOrto = false
    @State private var addPiantaContext: AddPiantaContext? = nil

    private struct AddPiantaContext: Identifiable {
        let id = UUID()
        let knowledge: PlantKnowledge
        let orto: Orto?
    }

    private var columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]

    /// Mese corrente (1-12), corretto per l'emisfero del primo orto disponibile (fallback senza normali climatiche).
    private var meseEffettivo: Int {
        let mese = Calendar.current.component(.month, from: Date())
        let lat = orti.first?.latitudine ?? 45
        guard lat < 0 else { return mese }
        return ((mese - 1 + 6) % 12) + 1
    }

    private var filteredCatalogo: [PlantKnowledge] {
        var risultato = catalogo
        if let categoriaFiltro {
            risultato = risultato.filter { $0.tipo == categoriaFiltro }
        }
        if soloSeminabiliOra {
            let interno = orti.first?.interno ?? false
            let mese = normals != nil ? Calendar.current.component(.month, from: Date()) : meseEffettivo
            risultato = risultato.filter { pk in
                let window = SowingCalculator.compute(for: pk, normals: normals)
                let mesi = interno ? window.seminaInterno : window.seminaEsterno
                return mesi.contains(mese)
            }
        }
        guard !searchText.isEmpty else { return risultato }
        return risultato.filter {
            $0.specieNome.localizedCaseInsensitiveContains(searchText)
                || ($0.specieNomeScentifico?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBar
                    .padding(.horizontal)
                    .padding(.top, 8)

                categoryFilterBar
                    .padding(.top, 8)

                Toggle(lang.plants.seedableNowFilter, isOn: $soloSeminabiliOra)
                    .font(.dmSans(13, weight: .medium))
                    .toggleStyle(.switch)
                    .tint(AppTheme.primaryGreen)
                    .padding(.horizontal)
                    .padding(.top, 8)

                if filteredCatalogo.isEmpty {
                    Spacer()
                    ContentUnavailableView {
                        Label(lang.plants.emptyTitle, systemImage: "leaf")
                    } description: {
                        Text(lang.plants.emptyDesc)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(filteredCatalogo) { pk in
                                Button(action: { detailKnowledge = pk }) {
                                    CatalogoCardView(knowledge: pk)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .background(AppTheme.backgroundCream)
            .navigationTitle(lang.plants.catalogNavTitle)
            .sheet(item: $detailKnowledge) { knowledge in
                PlantDetailSheet(knowledge: knowledge, onAdd: { k in
                    handleAdd(k)
                }, orto: orti.first)
                .environment(lang)
            }
            .confirmationDialog(lang.plants.chooseGardenTitle, isPresented: $showChooseOrto, presenting: pendingKnowledge) { knowledge in
                ForEach(orti) { orto in
                    Button(orto.nome) {
                        addPiantaContext = AddPiantaContext(knowledge: knowledge, orto: orto)
                    }
                }
            }
            .sheet(item: $addPiantaContext) { context in
                AggiungiPiantaView(ortoId: context.orto?.id, orto: context.orto, initialKnowledge: context.knowledge)
                    .environment(lang)
            }
            .task { await loadData() }
            .refreshable { await loadData() }
        }
    }

    // MARK: - Search & Filters

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField(lang.plants.catalogSearchPlaceholder, text: $searchText)
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
    }

    private var categoryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                categoryChip(label: lang.plants.categoryAllFilter, isSelected: categoriaFiltro == nil) {
                    categoriaFiltro = nil
                }
                ForEach(PlantType.allCases, id: \.self) { tipo in
                    categoryChip(label: tipo.emoji + " " + tipo.displayName, isSelected: categoriaFiltro == tipo) {
                        categoriaFiltro = tipo
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private func categoryChip(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.dmSans(12, weight: .medium))
                .foregroundStyle(isSelected ? Color.white : AppTheme.textPrimary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(isSelected ? AppTheme.primaryGreen : AppTheme.cardBackground)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.secondary.opacity(0.2), lineWidth: isSelected ? 0 : 1))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Add to garden

    private func handleAdd(_ knowledge: PlantKnowledge) {
        if orti.count <= 1 {
            addPiantaContext = AddPiantaContext(knowledge: knowledge, orto: orti.first)
        } else {
            pendingKnowledge = knowledge
            showChooseOrto = true
        }
    }

    // MARK: - Data

    private func loadData() async {
        do { catalogo = try await repository.fetchCatalogo() } catch {}
        if let userId = authManager.user?.id {
            do { orti = try await repository.fetchOrti(userId: userId) } catch {}
        }
        if let lat = orti.first?.latitudine, let lon = orti.first?.longitudine {
            normals = try? await ClimateNormalsClient.shared.fetchNormals(latitude: lat, longitude: lon)
        }
    }
}

// MARK: - Card

private struct CatalogoCardView: View {
    let knowledge: PlantKnowledge

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

                if let urlStr = knowledge.imageUrl, let url = URL(string: urlStr) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable()
                                .scaledToFill()
                        case .failure:
                            Text(emojiForPlant(knowledge.specieNome))
                                .font(.system(size: 40))
                        default:
                            ProgressView()
                        }
                    }
                    .frame(height: 100)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Text(emojiForPlant(knowledge.specieNome))
                        .font(.system(size: 40))
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(knowledge.specieNome)
                    .font(.dmSans(15, weight: .medium))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(1)

                if let tipo = knowledge.tipo {
                    Text(tipo.emoji + " " + tipo.displayName)
                        .font(.dmSans(12))
                        .foregroundStyle(AppTheme.textSecondary)
                }
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
    CatalogoView()
        .environment(SupabaseRepository.shared)
        .environment(AuthManager.shared)
        .environment(LanguageManager.shared)
}
