import SwiftUI
import CoreLocation
import PhotosUI

struct OrtoDetailView: View {
    @State private var orto: Orto
    @Environment(SupabaseRepository.self) private var repository

    @State private var piante: [PiantaColtivata] = []
    @State private var showAddPianta = false
    @State private var showEditOrto = false
    @State private var editNome = ""
    @State private var editLuogo = ""
    @State private var editInterno = false
    @State private var resolvedLatitude: Double?
    @State private var resolvedLongitude: Double?
    @State private var isGeocoding = false
    @State private var locationHelper = LocationHelper()
    @State private var errorMessage: String?
    @State private var showDeleteOrtoConfirm = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isUploadingPhoto = false
    @Environment(\.dismiss) private var dismiss
    @Environment(LanguageManager.self) private var lang

    init(orto: Orto) {
        _orto = State(initialValue: orto)
    }

    var body: some View {
        List {
            Section {
                VStack(spacing: 8) {
                    if let fotoUrl = orto.fotoUrl, let url = URL(string: fotoUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                    } else {
                        Image(systemName: "tree.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(AppTheme.primaryGreen)
                    }

                    Text(orto.nome)
                        .font(.lora(22))
                        .foregroundStyle(AppTheme.textPrimary)

                    if let luogo = orto.luogo, !luogo.isEmpty {
                        Label(luogo, systemImage: "mappin")
                            .font(.dmSans(14))
                            .foregroundStyle(AppTheme.textSecondary)
                    }

                    Label(String(format: lang.garden.plantsCountFormat, piante.count), systemImage: "leaf")
                        .font(.dmSans(12))
                        .foregroundStyle(AppTheme.textSecondary)
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
                    Text(lang.garden.plantsSection)
                        .font(.dmSans(12, weight: .semibold))
                        .foregroundStyle(AppTheme.textSecondary)
                    Spacer()
                    Button(action: { showAddPianta = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(AppTheme.primaryGreen)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(AppTheme.backgroundCream)
        .navigationTitle(orto.nome)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(lang.garden.editButton) {
                    editNome = orto.nome
                    editLuogo = orto.luogo ?? ""
                    editInterno = orto.interno
                    resolvedLatitude = orto.latitudine
                    resolvedLongitude = orto.longitudine
                    showEditOrto = true
                }
            }
        }
        .navigationDestination(for: PiantaColtivata.self) { pianta in
            PiantaDetailView(pianta: pianta)
        }
        .sheet(isPresented: $showAddPianta, onDismiss: {
            Task { await loadPiante() }
        }) {
            AggiungiPiantaView(ortoId: orto.id, orto: orto)
        }
        .sheet(isPresented: $showEditOrto) {
            editOrtoSheet
        }
        .task { await loadPiante() }
        .refreshable { await loadPiante() }
        .alert(lang.common.error, isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button(lang.common.ok, role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
    }

    // MARK: - Edit Sheet

    private var editOrtoSheet: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(lang.garden.gardenNamePlaceholder, text: $editNome)
                        .autocorrectionDisabled()
                    Toggle(lang.garden.indoorToggle, isOn: $editInterno)
                        .tint(AppTheme.primaryGreen)
                } header: {
                    Text(lang.garden.gardenDetailsSection)
                } footer: {
                    if editInterno {
                        Text(lang.garden.indoorFooter)
                    }
                }

                Section {
                    HStack(spacing: 12) {
                        if let fotoUrl = orto.fotoUrl, let url = URL(string: fotoUrl) {
                            AsyncImage(url: url) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 56, height: 56)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        } else {
                            Image(systemName: "photo")
                                .font(.system(size: 24))
                                .foregroundStyle(.secondary)
                                .frame(width: 56, height: 56)
                        }

                        PhotosPicker(
                            selection: $selectedPhotoItem,
                            matching: .images
                        ) {
                            Label(
                                orto.fotoUrl == nil ? lang.plants.addPhotoButton : lang.plants.changePhotoButton,
                                systemImage: "camera"
                            )
                        }
                        .disabled(isUploadingPhoto)

                        if isUploadingPhoto {
                            Spacer()
                            ProgressView()
                        }
                    }
                } header: {
                    Text(lang.garden.photoSection)
                }

                if !editInterno {
                Section(lang.garden.locationSection) {
                    HStack {
                        TextField(lang.garden.citySearchPlaceholder, text: $editLuogo)
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
                            locationHelper.isLocating ? lang.garden.detectingGPS : lang.garden.useCurrentLocation,
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
                }

                Section {
                    Button(action: saveEdit) {
                        Text(lang.common.save)
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
                        Text(lang.garden.deleteOrtoButton)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle(lang.garden.editNavTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(lang.common.cancel) { showEditOrto = false }
                }
            }
            .alert(lang.garden.deleteTitle, isPresented: $showDeleteOrtoConfirm) {
                Button(lang.garden.deleteButton, role: .destructive) {
                    showEditOrto = false
                    deleteOrto()
                }
                Button(lang.common.cancel, role: .cancel) {}
            } message: {
                Text(String(format: lang.garden.deleteConfirmMsgFormat, orto.nome))
            }
            .onChange(of: locationHelper.location) { _, location in
                guard let location else { return }
                Task { await reverseGeocode(location) }
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                guard let newItem else { return }
                Task { await uploadPhoto(newItem) }
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

            Text(lang.garden.emptyFirstPlant)
                .font(.dmSans(16, weight: .semibold))
                .foregroundStyle(AppTheme.textSecondary)

            Button(action: { showAddPianta = true }) {
                Label(lang.garden.addPlantButton, systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.primaryGreen)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    // MARK: - Helpers

    private func loadPiante() async {
        do {
            piante = try await repository.fetchPiante(ortoId: orto.id)
        } catch {
            errorMessage = error.localizedDescription
        }
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
        let interno = editInterno
        var lat = interno ? nil : resolvedLatitude
        var lon = interno ? nil : resolvedLongitude
        let luogoFinal = interno ? "" : luogo
        showEditOrto = false
        Task {
            if !interno && lat == nil && !luogoFinal.isEmpty {
                let placemarks = try? await CLGeocoder().geocodeAddressString(luogoFinal)
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
                        luogo: luogoFinal.isEmpty ? nil : luogoFinal,
                        latitudine: lat,
                        longitudine: lon,
                        interno: interno
                    )
                )
                orto = updated
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func uploadPhoto(_ item: PhotosPickerItem) async {
        isUploadingPhoto = true
        defer { isUploadingPhoto = false }
        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let jpeg = UIImage(data: data)?.jpegData(compressionQuality: 0.7) else { return }
            let url = try await repository.uploadOrtoPhoto(ortoId: orto.id, data: jpeg)
            let updated = try await repository.updateOrto(
                id: orto.id,
                orto: Orto.Update(
                    nome: nil,
                    luogo: nil,
                    latitudine: nil,
                    longitudine: nil,
                    interno: nil,
                    fotoUrl: url
                )
            )
            orto = updated
        } catch {
            errorMessage = error.localizedDescription
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
    @Environment(LanguageManager.self) private var lang

    var body: some View {
        HStack(spacing: 12) {
            PlantIconView(pianta: pianta, size: 32)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(pianta.nomePersonalizzato)
                    .font(.dmSans(15, weight: .medium))
                    .foregroundStyle(AppTheme.textPrimary)

                if pianta.tipo == .raccolto {
                    HStack(spacing: 8) {
                        Text(String(format: lang.plants.totalDaysFormat, pianta.growthDays))
                            .font(.dmSans(12))
                            .foregroundStyle(AppTheme.textSecondary)

                        if pianta.progressoCiclo >= 1.0 {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(.green)
                        }
                    }

                    ProgressView(value: pianta.progressoCiclo)
                        .tint(AppTheme.primaryGreen)
                } else {
                    Text(lang.plants.plantedDateLabel + ": " + pianta.dataSemina.formatted(date: .abbreviated, time: .omitted))
                        .font(.dmSans(12))
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }

            Spacer()

            if pianta.tipo == .raccolto {
                Text("\(pianta.giorniTrascorsi)g")
                    .font(.dmSans(12, weight: .semibold))
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        OrtoDetailView(orto: Orto(
            id: UUID(), userId: UUID(), nome: "Il mio orto", luogo: "Balcone",
            latitudine: nil, longitudine: nil, interno: false, fotoUrl: nil, createdAt: Date(), updatedAt: Date()
        ))
        .environment(SupabaseRepository.shared)
        .environment(LanguageManager.shared)
    }
}
