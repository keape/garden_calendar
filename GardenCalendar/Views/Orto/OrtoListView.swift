import SwiftUI
import CoreLocation

struct OrtoListView: View {
    @Environment(SupabaseRepository.self) private var repository
    @Environment(AuthManager.self) private var authManager

    @State private var orti: [Orto] = []
    @State private var showNewOrto = false
    @State private var newNome = ""
    @State private var newLuogo = ""
    @State private var ortoToDelete: Orto?
    @State private var showDeleteConfirm = false
    @State private var errorMessage: String?
    @State private var locationHelper = LocationHelper()
    @State private var resolvedLatitude: Double?
    @State private var resolvedLongitude: Double?
    @State private var isGeocoding = false

    var body: some View {
        NavigationStack {
            Group {
                if orti.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(orti) { orto in
                            NavigationLink(value: orto) {
                                OrtoRow(orto: orto)
                            }
                        }
                        .onDelete { indexSet in
                            if let index = indexSet.first {
                                ortoToDelete = orti[index]
                                showDeleteConfirm = true
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("I miei orti")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showNewOrto = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationDestination(for: Orto.self) { orto in
                OrtoDetailView(orto: orto)
            }
            .sheet(isPresented: $showNewOrto) {
                newOrtoSheet
            }
            .alert("Elimina orto", isPresented: $showDeleteConfirm, presenting: ortoToDelete) { orto in
                Button("Elimina", role: .destructive) {
                    deleteOrto(orto)
                }
                Button("Annulla", role: .cancel) {}
            } message: { orto in
                Text("Eliminare l'orto \"\(orto.nome)\"? Le piante collegate non verranno eliminate.")
            }
            .task { await loadOrti() }
            .onAppear { Task { await loadOrti() } }
            .refreshable { await loadOrti() }
            .alert("Errore", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        ContentUnavailableView {
            Label("Crea il tuo primo orto", systemImage: "figure.gardening")
        } description: {
            Text("Organizza le tue piante in orti e giardini per tenerle sotto controllo.")
        } actions: {
            Button(action: { showNewOrto = true }) {
                Label("Nuovo orto", systemImage: "plus")
                    .fontWeight(.semibold)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.primaryGreen)
        }
    }

    // MARK: - New Orto Sheet

    private var newOrtoSheet: some View {
        NavigationStack {
            Form {
                Section("Dettagli orto") {
                    TextField("Nome orto", text: $newNome)
                        .autocorrectionDisabled()
                }

                Section("Posizione") {
                    HStack {
                        TextField("Cerca città...", text: $newLuogo)
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
                    Button(action: saveNewOrto) {
                        Text("Salva")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.primaryGreen)
                    .disabled(newNome.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .navigationTitle("Nuovo orto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Annulla") { showNewOrto = false }
                }
            }
            .onChange(of: locationHelper.location) { _, location in
                guard let location else { return }
                Task { await reverseGeocode(location) }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Helpers

    private func loadOrti() async {
        guard let userId = authManager.user?.id else { return }
        do {
            orti = try await repository.fetchOrti(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func saveNewOrto() {
        let nome = newNome.trimmingCharacters(in: .whitespaces)
        let luogo = newLuogo.trimmingCharacters(in: .whitespaces)
        guard let userId = authManager.user?.id else { return }
        var lat = resolvedLatitude
        var lon = resolvedLongitude
        showNewOrto = false
        newNome = ""
        newLuogo = ""
        resolvedLatitude = nil
        resolvedLongitude = nil
        Task {
            // Geocodifica se l'utente ha scritto la città senza premere Return
            if lat == nil && !luogo.isEmpty {
                let placemarks = try? await CLGeocoder().geocodeAddressString(luogo)
                if let loc = placemarks?.first?.location {
                    lat = loc.coordinate.latitude
                    lon = loc.coordinate.longitude
                }
            }
            do {
                let nuovo = try await repository.createOrto(
                    userId: userId,
                    orto: Orto.Create(nome: nome, luogo: luogo.isEmpty ? nil : luogo, latitudine: lat, longitudine: lon)
                )
                orti.append(nuovo)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func geocodeCityName() async {
        let text = newLuogo.trimmingCharacters(in: .whitespaces)
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
            newLuogo = placemark.locality ?? placemark.administrativeArea ?? placemark.country ?? ""
        }
    }

    private func deleteOrto(_ orto: Orto) {
        orti.removeAll { $0.id == orto.id }
        Task { try? await repository.deleteOrto(id: orto.id) }
    }
}

// MARK: - Orto Row

struct OrtoRow: View {
    let orto: Orto

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "tree.fill")
                .font(.title2)
                .foregroundStyle(AppTheme.primaryGreen)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(orto.nome)
                    .font(.headline)

                if let luogo = orto.luogo, !luogo.isEmpty {
                    Label(luogo, systemImage: "mappin")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    OrtoListView()
        .environment(SupabaseRepository.shared)
        .environment(AuthManager.shared)
}
