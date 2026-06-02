import SwiftUI
import CoreLocation

struct OrtoDetailView: View {
    @State private var orto: Orto
    @Environment(SupabaseRepository.self) private var repository

    @State private var piante: [PiantaColtivata] = []
    @State private var showAddPianta = false
    @State private var showEditOrto = false
    @State private var editNome = ""
    @State private var editLuogo = ""
    @State private var resolvedLatitude: Double?
    @State private var resolvedLongitude: Double?
    @State private var isGeocoding = false
    @State private var locationHelper = LocationHelper()
    @State private var errorMessage: String?
    @State private var showDeleteOrtoConfirm = false
    @Environment(\.dismiss) private var dismiss

    init(orto: Orto) {
        _orto = State(initialValue: orto)
    }

    var body: some View {
        List {
            Section {
                VStack(spacing: 8) {
                    Image(systemName: "tree.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(AppTheme.primaryGreen)

                    Text(orto.nome)
                        .font(.title.bold())

                    if let luogo = orto.luogo, !luogo.isEmpty {
                        Label(luogo, systemImage: "mappin")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Label("\(piante.count) piante", systemImage: "leaf")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }

            Section {
                if piante.isEmpty {
                    emptyPiante
                } else {
                    ForEach(piante) { pianta in
                        NavigationLink(value: pianta) {
                            PiantaRowView(pianta: pianta)
                        }
                    }
                    .onDelete { indexSet in
                        deletePiante(at: indexSet)
                    }
                }
            } header: {
                HStack {
                    Text("Piante")
                    Spacer()
                    Button(action: { showAddPianta = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(AppTheme.primaryGreen)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(orto.nome)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Modifica") {
                    editNome = orto.nome
                    editLuogo = orto.luogo ?? ""
                    resolvedLatitude = orto.latitudine
                    resolvedLongitude = orto.longitudine
                    showEditOrto = true
                }
            }
        }
        .navigationDestination(for: PiantaColtivata.self) { pianta in
            PiantaDetailView(pianta: pianta)
        }
        .sheet(isPresented: $showAddPianta) {
            AggiungiPiantaView(ortoId: orto.id)
        }
        .sheet(isPresented: $showEditOrto) {
            editOrtoSheet
        }
        .task { await loadPiante() }
        .refreshable { await loadPiante() }
        .alert("Errore", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
    }

    // MARK: - Edit Sheet

    private var editOrtoSheet: some View {
        NavigationStack {
            Form {
                Section("Dettagli orto") {
                    TextField("Nome orto", text: $editNome)
                        .autocorrectionDisabled()
                }

                Section("Posizione") {
                    HStack {
                        TextField("Cerca città...", text: $editLuogo)
                            .autocorrectionDisabled()
                            .onSubmit { Task { await geocodeCityName() } }
                        if isGeocoding {
                            ProgressView().scaleEffect(0.75)
                        }
                    }

                    Button {
                        locationHelper.requestLocation()
                    } label: {
                        Label(
                            locationHelper.isLocating ? "Rilevamento GPS..." : "Usa posizione attuale",
                            systemImage: "location.fill"
                        )
                    }
                    .disabled(locationHelper.isLocating)

                    if let lat = resolvedLatitude, let lon = resolvedLongitude {
                        Label(String(format: "%.4f°, %.4f°", lat, lon), systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    Button(action: saveEdit) {
                        Text("Salva")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.primaryGreen)
                    .disabled(editNome.trimmingCharacters(in: .whitespaces).isEmpty)
                }

                Section {
                    Button(role: .destructive) {
                        showDeleteOrtoConfirm = true
                    } label: {
                        Text("Elimina orto")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("Modifica orto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Annulla") { showEditOrto = false }
                }
            }
            .alert("Elimina orto", isPresented: $showDeleteOrtoConfirm) {
                Button("Elimina", role: .destructive) {
                    showEditOrto = false
                    deleteOrto()
                }
                Button("Annulla", role: .cancel) {}
            } message: {
                Text("Eliminare l'orto \"\(orto.nome)\"? Le piante collegate non verranno eliminate.")
            }
            .onChange(of: locationHelper.location) { _, location in
                guard let location else { return }
                Task { await reverseGeocode(location) }
            }
        }
        .presentationDetents([.medium, .large])
    }

    // MARK: - Empty State

    private var emptyPiante: some View {
        VStack(spacing: 12) {
            Image(systemName: "leaf")
                .font(.system(size: 36))
                .foregroundStyle(.secondary.opacity(0.5))

            Text("Aggiungi la tua prima pianta")
                .font(.headline)
                .foregroundStyle(.secondary)

            Button(action: { showAddPianta = true }) {
                Label("Aggiungi pianta", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.primaryGreen)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    // MARK: - Helpers

    private func loadPiante() async {
        do { piante = try await repository.fetchPiante(ortoId: orto.id) } catch {}
    }

    private func deletePiante(at offsets: IndexSet) {
        let ids = offsets.map { piante[$0].id }
        piante.remove(atOffsets: offsets)
        Task {
            for id in ids { try? await repository.deletePianta(id: id) }
        }
    }

    private func deleteOrto() {
        Task {
            do {
                try await repository.deleteOrto(id: orto.id)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func saveEdit() {
        let nome = editNome.trimmingCharacters(in: .whitespaces)
        let luogo = editLuogo.trimmingCharacters(in: .whitespaces)
        guard !nome.isEmpty else { return }
        var lat = resolvedLatitude
        var lon = resolvedLongitude
        showEditOrto = false
        Task {
            if lat == nil && !luogo.isEmpty {
                let placemarks = try? await CLGeocoder().geocodeAddressString(luogo)
                if let loc = placemarks?.first?.location {
                    lat = loc.coordinate.latitude
                    lon = loc.coordinate.longitude
                }
            }
            do {
                let updated = try await repository.updateOrto(
                    id: orto.id,
                    orto: Orto.Update(
                        nome: nome,
                        luogo: luogo.isEmpty ? nil : luogo,
                        latitudine: lat,
                        longitudine: lon
                    )
                )
                orto = updated
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func geocodeCityName() async {
        let text = editLuogo.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        isGeocoding = true
        defer { isGeocoding = false }
        let placemarks = try? await CLGeocoder().geocodeAddressString(text)
        if let loc = placemarks?.first?.location {
            resolvedLatitude = loc.coordinate.latitude
            resolvedLongitude = loc.coordinate.longitude
        } else {
            resolvedLatitude = nil
            resolvedLongitude = nil
        }
    }

    private func reverseGeocode(_ location: CLLocation) async {
        isGeocoding = true
        defer { isGeocoding = false }
        resolvedLatitude = location.coordinate.latitude
        resolvedLongitude = location.coordinate.longitude
        let placemarks = try? await CLGeocoder().reverseGeocodeLocation(location)
        if let placemark = placemarks?.first {
            editLuogo = placemark.locality ?? placemark.administrativeArea ?? placemark.country ?? ""
        }
    }
}

// MARK: - Pianta Row

struct PiantaRowView: View {
    let pianta: PiantaColtivata

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "leaf.fill")
                .font(.title2)
                .foregroundStyle(AppTheme.primaryGreen)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(pianta.nomePersonalizzato)
                    .font(.headline)

                HStack(spacing: 8) {
                    Text("\(pianta.growthDays) giorni")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if pianta.progressoCiclo >= 1.0 {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                }

                ProgressView(value: pianta.progressoCiclo)
                    .tint(AppTheme.primaryGreen)
            }

            Spacer()

            Text("\(pianta.giorniTrascorsi)g")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        OrtoDetailView(orto: Orto(
            id: UUID(), userId: UUID(), nome: "Il mio orto", luogo: "Balcone",
            latitudine: nil, longitudine: nil, createdAt: Date(), updatedAt: Date()
        ))
        .environment(SupabaseRepository.shared)
    }
}
