import SwiftUI
import PhotosUI

struct DiagnosiView: View {
    @Environment(SupabaseRepository.self) private var repository
    @Environment(AuthManager.self) private var authManager
    @Environment(LanguageManager.self) private var lang

    @State private var piante: [PiantaColtivata] = []
    @State private var selectedPianta: PiantaColtivata?
    @State private var selectedImage: UIImage?
    @State private var photoItem: PhotosPickerItem?
    @State private var showCamera = false
    @State private var isLoading = false
    @State private var diagnosis: String?
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    plantPicker

                    photoSection

                    analyzeButton

                    if isLoading {
                        ProgressView(lang.diagnosis.analyzing)
                            .padding()
                    }

                    if let diagnosis {
                        resultCard(diagnosis)
                    }
                }
                .padding()
            }
            .background(AppTheme.backgroundCream)
            .navigationTitle(lang.diagnosis.navTitle)
            .navigationBarTitleDisplayMode(.large)
            .task { await loadPiante() }
            .sheet(isPresented: $showCamera) {
                CameraPicker { image in
                    selectedImage = image
                }
                .ignoresSafeArea()
            }
            .onChange(of: photoItem) { _, newItem in
                guard let newItem else { return }
                Task { await loadPickedPhoto(newItem) }
            }
            .alert(lang.common.error, isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button(lang.common.ok, role: .cancel) {}
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    // MARK: - Sections

    private var plantPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(lang.diagnosis.selectPlant)
                .font(.dmSans(15, weight: .medium))
                .foregroundStyle(AppTheme.textSecondary)

            if piante.isEmpty {
                Text(lang.diagnosis.noPlants)
                    .font(.dmSans(15))
                    .foregroundStyle(AppTheme.textSecondary)
            } else {
                Picker(lang.diagnosis.selectPlant, selection: $selectedPianta) {
                    Text(lang.diagnosis.selectPlant).tag(PiantaColtivata?.none)
                    ForEach(piante) { pianta in
                        Text(pianta.nomePersonalizzato).tag(PiantaColtivata?.some(pianta))
                    }
                }
                .pickerStyle(.menu)
                .tint(AppTheme.primaryGreen)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var photoSection: some View {
        VStack(spacing: 12) {
            if let selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 260)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            HStack(spacing: 12) {
                Button {
                    showCamera = true
                } label: {
                    Label(lang.diagnosis.takePhoto, systemImage: "camera.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.primaryGreen)

                PhotosPicker(selection: $photoItem, matching: .images, photoLibrary: .shared()) {
                    Label(lang.diagnosis.chooseFromLibrary, systemImage: "photo.on.rectangle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private var analyzeButton: some View {
        Button {
            Task { await analyze() }
        } label: {
            Text(lang.diagnosis.analyzeButton)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(AppTheme.ctaDarkGreen)
        .disabled(selectedPianta == nil || selectedImage == nil || isLoading)
    }

    private func resultCard(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(lang.diagnosis.resultTitle)
                .font(.lora(18))
                .foregroundStyle(AppTheme.textPrimary)
            Text(text)
                .font(.dmSans(15))
                .foregroundStyle(AppTheme.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Actions

    private func loadPiante() async {
        guard let userId = authManager.user?.id else { return }
        do {
            piante = try await repository.fetchAllPiante(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func loadPickedPhoto(_ item: PhotosPickerItem) async {
        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else { return }
            selectedImage = image
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func analyze() async {
        guard let pianta = selectedPianta, let image = selectedImage else {
            errorMessage = lang.diagnosis.errorMissingPlantOrPhoto
            return
        }
        guard let jpeg = image.jpegData(compressionQuality: 0.6) else { return }

        isLoading = true
        diagnosis = nil
        defer { isLoading = false }

        do {
            let base64 = "data:image/jpeg;base64,\(jpeg.base64EncodedString())"
            let response = try await repository.diagnosePlant(piantaId: pianta.id, imageBase64: base64)
            diagnosis = response.diagnosis
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
