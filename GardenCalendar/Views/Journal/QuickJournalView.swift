import SwiftUI

struct QuickJournalView: View {
    @Environment(SupabaseRepository.self) private var repository
    @Environment(AuthManager.self) private var authManager
    @Environment(\.dismiss) private var dismiss
    @Environment(LanguageManager.self) private var lang

    @State private var step = 1

    // Step 1: Pianta
    @State private var selectedPlant: PiantaColtivata? = nil
    @State private var piante: [PiantaColtivata] = []

    // Step 2: Azione
    @State private var selectedAction = "semina"

    // Step 3: Data + Nota
    @State private var eventDate = Date()
    @State private var note = ""

    // Alert
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isSaving = false
    @State private var alertIsSuccess = false

    init(preselectedDate: Date = Date()) {
        self._eventDate = State(initialValue: preselectedDate)
    }

    private let actions: [(name: String, icon: String)] = [
        ("semina", "leaf.fill"),
        ("trapianto", "arrow.triangle.branch"),
        ("irrigazione", "drop.fill"),
        ("concimazione", "flask.fill"),
        ("raccolta", "basket.fill"),
        ("potatura", "scissors"),
        ("trattamento", "cross.case.fill"),
        ("sarchiatura", "leaf.arrow.triangle.circlepath"),
        ("innesto", "point.topleft.down.curvedto.point.bottomright.up"),
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Progress steps
                HStack(spacing: 0) {
                    ForEach(1...3, id: \.self) { s in
                        stepIndicator(number: s, title: stepTitle(s), isActive: step >= s, isCurrent: step == s)
                        if s < 3 {
                            Rectangle()
                                .fill(step > s ? AppTheme.primaryGreen : Color.gray.opacity(0.3))
                                .frame(height: 2)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)

                // Step content
                TabView(selection: $step) {
                    selectPlantStep
                        .tag(1)

                    selectActionStep
                        .tag(2)

                    detailsStep
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: step)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(lang.journal.navTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if step > 1 {
                        Button(action: { withAnimation { step -= 1 } }) {
                            Image(systemName: "chevron.left")
                                .foregroundStyle(AppTheme.primaryGreen)
                        }
                    } else {
                        Button(lang.common.cancel) { dismiss() }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if step < 3 {
                        Button(lang.journal.nextButton) {
                            withAnimation { step += 1 }
                        }
                        .disabled(step == 1 && selectedPlant == nil)
                        .fontWeight(.semibold)
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertIsSuccess ? lang.plants.savedTitle : lang.common.error),
                    message: Text(alertMessage),
                    dismissButton: .default(Text(lang.common.ok)) {
                        if alertIsSuccess { dismiss() }
                    }
                )
            }
            .task { await loadPiante() }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Step Titles

    private func stepTitle(_ number: Int) -> String {
        switch number {
        case 1: return LanguageManager.shared.journal.stepPlant
        case 2: return LanguageManager.shared.journal.stepAction
        case 3: return LanguageManager.shared.journal.stepDetails
        default: return ""
        }
    }

    // MARK: - Step Indicator

    private func stepIndicator(number: Int, title: String, isActive: Bool, isCurrent: Bool) -> some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(isActive ? AppTheme.primaryGreen : Color.gray.opacity(0.2))
                    .frame(width: 32, height: 32)

                if isActive && !isCurrent {
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .foregroundStyle(.white)
                } else {
                    Text("\(number)")
                        .font(.caption.bold())
                        .foregroundStyle(isActive ? .white : .secondary)
                }
            }

            Text(title)
                .font(.system(size: 10))
                .foregroundStyle(isActive ? AppTheme.primaryGreen : .secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Step 1: Select Plant

    private var selectPlantStep: some View {
        ScrollView {
            VStack(spacing: 12) {
                if piante.isEmpty {
                    ContentUnavailableView(
                        lang.journal.noPlantsTitle,
                        systemImage: "leaf",
                        description: Text(lang.journal.noPlantsDesc)
                    )
                } else {
                    ForEach(piante) { pianta in
                        Button(action: {
                            selectedPlant = pianta
                            withAnimation { step = 2 }
                        }) {
                            HStack {
                                Image(systemName: "leaf.fill")
                                    .foregroundStyle(AppTheme.primaryGreen)
                                    .font(.title3)

                                Text(pianta.nomePersonalizzato)
                                    .font(.headline)
                                    .foregroundStyle(.primary)

                                Spacer()

                                if selectedPlant?.id == pianta.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(AppTheme.primaryGreen)
                                }

                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .background(AppTheme.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
            }
            .padding()
        }
        .tag(1)
    }

    // MARK: - Step 2: Select Action

    private var selectActionStep: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(actions, id: \.name) { action in
                    Button(action: {
                        selectedAction = action.name
                        withAnimation { step = 3 }
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: action.icon)
                                .font(.title2)
                                .foregroundStyle(selectedAction == action.name ? .white : AppTheme.color(for: action.name))

                            Text(action.name.capitalized)
                                .font(.caption)
                                .foregroundStyle(selectedAction == action.name ? .white : .primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(selectedAction == action.name ? AppTheme.color(for: action.name) : AppTheme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedAction == action.name ? Color.clear : Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    }
                }
            }
            .padding()
        }
        .tag(2)
    }

    // MARK: - Step 3: Details

    private var detailsStep: some View {
        Form {
            Section(lang.journal.sectionPlant) {
                HStack {
                    Image(systemName: "leaf.fill").foregroundStyle(AppTheme.primaryGreen)
                    Text(selectedPlant?.nomePersonalizzato ?? "N/D")
                }
            }

            Section(lang.journal.sectionAction) {
                HStack {
                    Image(systemName: actions.first(where: { $0.name == selectedAction })?.icon ?? "leaf.fill")
                        .foregroundStyle(AppTheme.color(for: selectedAction))
                    Text(selectedAction.capitalized)
                }
            }

            Section(lang.journal.sectionDate) {
                DatePicker(lang.journal.dateEventLabel, selection: $eventDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
            }

            Section(lang.journal.sectionNote) {
                TextEditor(text: $note)
                    .frame(minHeight: 80)
            }

            Section {
                Button(action: saveEntry) {
                    Group {
                        if isSaving {
                            ProgressView().tint(.white)
                        } else {
                            Text(lang.journal.saveEntryButton).fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.primaryGreen)
                .disabled(isSaving)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }
        }
        .tag(3)
    }

    // MARK: - Save

    private func saveEntry() {
        guard let plant = selectedPlant else { return }
        isSaving = true
        Task {
            do {
                _ = try await repository.createAttivita(attivita: Attivita.Create(
                    piantaId: plant.id,
                    nome: selectedAction,
                    data: Calendar.current.startOfDay(for: eventDate),
                    done: false,
                    rainAdjusted: false,
                    rainRescheduled: false,
                    userEvent: true,
                    sourceAction: nil,
                    note: note.trimmingCharacters(in: .whitespaces).isEmpty ? nil : note.trimmingCharacters(in: .whitespaces),
                    color: colorForAction(selectedAction),
                    recurrenceDays: nil
                ))
                alertIsSuccess = true
                alertMessage = LanguageManager.shared.journal.savedSuccess
                showAlert = true
            } catch {
                alertIsSuccess = false
                alertMessage = error.localizedDescription
                showAlert = true
            }
            isSaving = false
        }
    }

    private func colorForAction(_ action: String) -> String {
        switch action.lowercased() {
        case "semina", "trapianto": return "verde"
        case "raccolta": return "arancione"
        case "irrigazione": return "blu"
        case "concimazione", "trattamento": return "rosso"
        default: return "grigio"
        }
    }

    private func loadPiante() async {
        guard let userId = authManager.user?.id else { return }
        do { piante = try await repository.fetchAllPiante(userId: userId) } catch {}
    }
}

#Preview {
    QuickJournalView()
        .environment(SupabaseRepository.shared)
        .environment(AuthManager.shared)
        .environment(LanguageManager.shared)
}
