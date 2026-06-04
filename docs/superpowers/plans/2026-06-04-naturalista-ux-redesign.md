# Naturalista UX Redesign — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Apply the "Naturalista" visual theme (warm cream #F8F2E8, Lora + DM Sans fonts, green botanical palette) to all screens of the Garden Calendar iOS app, converting DayDetailSheet to a NavigationStack push view.

**Architecture:** Foundation-first — AppTheme tokens and fonts land first so every subsequent view picks up the palette automatically. CalendarView then switches from `.sheet` to `.navigationDestination` for the day detail. Remaining views are restyled in order of user-facing importance.

**Tech Stack:** SwiftUI, iOS 17+, Supabase (unchanged), Google Fonts (Lora, DM Sans — OFL license)

---

> **Pre-flight note:** `ContentView.swift` already has 3 tabs (Calendario / Orti / Impostazioni) — no tab changes needed. `OrtoDetailView.swift` already has the Piante section — only restyling needed. `NuovaAttivitaSheet` requires `pianta: PiantaColtivata`, so the "Aggiungi attività" CTA will use `QuickJournalView` (restyled) which has no required pianta parameter.

---

## Task 1: Download fonts and register in Xcode project

**Files:**
- Create: `GardenCalendar/Resources/Fonts/Lora-Bold.ttf`
- Create: `GardenCalendar/Resources/Fonts/DMSans-Regular.ttf`
- Create: `GardenCalendar/Resources/Fonts/DMSans-Medium.ttf`
- Create: `GardenCalendar/Resources/Fonts/DMSans-SemiBold.ttf`
- Modify: `GardenCalendar/Info.plist`
- Modify: `GardenCalendar.xcodeproj/project.pbxproj`

- [ ] **Step 1: Create Fonts directory**

```bash
mkdir -p "/Users/keape/Library/Mobile Documents/com~apple~CloudDocs/app sviluppate e html/garden-calendar-ios/GardenCalendar/Resources/Fonts"
```

- [ ] **Step 2: Download Lora Bold TTF from Google Fonts**

```bash
# Uses old User-Agent to force TTF download instead of woff2
LORA_URL=$(curl -s "https://fonts.googleapis.com/css2?family=Lora:wght@700" \
  -H "User-Agent: Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)" \
  | grep -oE "https://fonts.gstatic.com[^)']+" | head -1)
curl -L "$LORA_URL" -o "/Users/keape/Library/Mobile Documents/com~apple~CloudDocs/app sviluppate e html/garden-calendar-ios/GardenCalendar/Resources/Fonts/Lora-Bold.ttf"
```

- [ ] **Step 3: Download DM Sans TTF variants from Google Fonts**

```bash
FONTS_DIR="/Users/keape/Library/Mobile Documents/com~apple~CloudDocs/app sviluppate e html/garden-calendar-ios/GardenCalendar/Resources/Fonts"
UA="Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)"

# Regular (400)
URL=$(curl -s "https://fonts.googleapis.com/css2?family=DM+Sans:wght@400" -H "User-Agent: $UA" | grep -oE "https://fonts.gstatic.com[^)']+" | head -1)
curl -L "$URL" -o "$FONTS_DIR/DMSans-Regular.ttf"

# Medium (500)
URL=$(curl -s "https://fonts.googleapis.com/css2?family=DM+Sans:wght@500" -H "User-Agent: $UA" | grep -oE "https://fonts.gstatic.com[^)']+" | head -1)
curl -L "$URL" -o "$FONTS_DIR/DMSans-Medium.ttf"

# SemiBold (600)
URL=$(curl -s "https://fonts.googleapis.com/css2?family=DM+Sans:wght@600" -H "User-Agent: $UA" | grep -oE "https://fonts.gstatic.com[^)']+" | head -1)
curl -L "$URL" -o "$FONTS_DIR/DMSans-SemiBold.ttf"
```

- [ ] **Step 4: Verify files downloaded correctly (each should be >20 KB)**

```bash
ls -lh "/Users/keape/Library/Mobile Documents/com~apple~CloudDocs/app sviluppate e html/garden-calendar-ios/GardenCalendar/Resources/Fonts/"
```

Expected: 4 `.ttf` files, each 30–120 KB.

- [ ] **Step 5: Add fonts to Xcode project via xcodeproj gem**

```bash
gem install xcodeproj 2>/dev/null || true

ruby << 'RUBY'
require 'xcodeproj'

project_path = "/Users/keape/Library/Mobile Documents/com~apple~CloudDocs/app sviluppate e html/garden-calendar-ios/GardenCalendar.xcodeproj"
project = Xcodeproj::Project.open(project_path)

target = project.targets.find { |t| t.name == "GardenCalendar" }

# Find or create Resources/Fonts group
resources_group = project.main_group.find_subpath("GardenCalendar/Resources", true)
fonts_group = resources_group.find_subpath("Fonts") || resources_group.new_group("Fonts", "Fonts")

font_files = ["Lora-Bold.ttf", "DMSans-Regular.ttf", "DMSans-Medium.ttf", "DMSans-SemiBold.ttf"]
font_files.each do |filename|
  path = "GardenCalendar/Resources/Fonts/#{filename}"
  # Skip if already added
  next if fonts_group.files.any? { |f| f.path == filename }
  file_ref = fonts_group.new_file(filename)
  file_ref.last_known_file_type = "file"
  target.resources_build_phase.add_file_reference(file_ref)
  puts "Added #{filename}"
end

project.save
puts "Project saved."
RUBY
```

Expected output: `Added Lora-Bold.ttf` × 4, `Project saved.`

- [ ] **Step 6: Register fonts in Info.plist**

```bash
PLIST="/Users/keape/Library/Mobile Documents/com~apple~CloudDocs/app sviluppate e html/garden-calendar-ios/GardenCalendar/Info.plist"
/usr/libexec/PlistBuddy -c "Add :UIAppFonts array" "$PLIST" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :UIAppFonts:0 string Lora-Bold.ttf" "$PLIST"
/usr/libexec/PlistBuddy -c "Add :UIAppFonts:1 string DMSans-Regular.ttf" "$PLIST"
/usr/libexec/PlistBuddy -c "Add :UIAppFonts:2 string DMSans-Medium.ttf" "$PLIST"
/usr/libexec/PlistBuddy -c "Add :UIAppFonts:3 string DMSans-SemiBold.ttf" "$PLIST"
/usr/libexec/PlistBuddy -c "Print :UIAppFonts" "$PLIST"
```

Expected: prints array with 4 font names.

- [ ] **Step 7: Verify build compiles (font errors appear at launch, not compile time)**

```bash
cd "/Users/keape/Library/Mobile Documents/com~apple~CloudDocs/app sviluppate e html/garden-calendar-ios"
xcodebuild -scheme GardenCalendar -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -5
```

Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 8: Commit**

```bash
cd "/Users/keape/Library/Mobile Documents/com~apple~CloudDocs/app sviluppate e html/garden-calendar-ios"
git add GardenCalendar/Resources/Fonts/ GardenCalendar/Info.plist GardenCalendar.xcodeproj/project.pbxproj
git commit -m "feat: add Lora + DM Sans fonts to Xcode bundle"
```

---

## Task 2: AppTheme — new color tokens + Font helpers

**Files:**
- Modify: `GardenCalendar/Theme/AppTheme.swift`

- [ ] **Step 1: Add new tokens to AppTheme**

In `AppTheme.swift`, inside `enum AppTheme`, add after the existing `// MARK: Surfaces` section:

```swift
    // MARK: Naturalista Surfaces

    /// Warm cream background — main app background.
    static let backgroundCream = Color(red: 0.973, green: 0.949, blue: 0.910)

    /// Warm secondary surface — calendar area, segmented bg.
    static let cardSecondaryWarm = Color(red: 0.933, green: 0.910, blue: 0.863)

    // MARK: Naturalista Text

    /// Deep botanical green — primary text.
    static let textPrimary = Color(red: 0.102, green: 0.227, blue: 0.102)

    /// Warm olive — secondary text.
    static let textSecondary = Color(red: 0.420, green: 0.420, blue: 0.290)

    // MARK: Naturalista CTA

    /// Dark forest green — full-width CTA pill.
    static let ctaDarkGreen = Color(red: 0.180, green: 0.239, blue: 0.180)
```

Also change the existing surface definitions:

```swift
    // MARK: Surfaces

    /// Card and input background.
    static let cardBackground = Color.white

    /// Secondary card / calendar background.
    static let cardSecondary = Color(red: 0.933, green: 0.910, blue: 0.863)
```

- [ ] **Step 2: Add Font helpers at the bottom of AppTheme.swift**

After the `extension Color` block, add:

```swift
// MARK: - Font Helpers

extension Font {
    static func lora(_ size: CGFloat) -> Font {
        .custom("Lora-Bold", size: size)
    }

    static func dmSans(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        switch weight {
        case .medium:   return .custom("DMSans-Medium", size: size)
        case .semibold: return .custom("DMSans-SemiBold", size: size)
        default:        return .custom("DMSans-Regular", size: size)
        }
    }
}
```

- [ ] **Step 3: Also expose new tokens in the Color extension**

In the existing `extension Color` block, add:

```swift
    static let backgroundCream   = AppTheme.backgroundCream
    static let cardSecondaryWarm = AppTheme.cardSecondaryWarm
    static let textPrimary       = AppTheme.textPrimary
    static let textSecondary     = AppTheme.textSecondary
    static let ctaDarkGreen      = AppTheme.ctaDarkGreen
```

- [ ] **Step 4: Build**

```bash
cd "/Users/keape/Library/Mobile Documents/com~apple~CloudDocs/app sviluppate e html/garden-calendar-ios"
xcodebuild -scheme GardenCalendar -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -5
```

Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 5: Commit**

```bash
git add GardenCalendar/Theme/AppTheme.swift
git commit -m "feat: add Naturalista color tokens and Lora/DM Sans font helpers"
```

---

## Task 3: CalendarView — restyling + sheet → navigationDestination

**Files:**
- Modify: `GardenCalendar/Views/Calendario/CalendarView.swift`

- [ ] **Step 1: Replace the `.sheet` with `.navigationDestination` and update background**

In `CalendarGridView.body`, make these changes:

```swift
var body: some View {
    NavigationStack {
        VStack(spacing: 0) {
            // Custom segmented control (replaces .pickerStyle(.segmented))
            HStack(spacing: 0) {
                ForEach(ViewMode.allCases, id: \.self) { mode in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { viewMode = mode }
                    } label: {
                        Text(mode.rawValue)
                            .font(.dmSans(14, weight: viewMode == mode ? .semibold : .regular))
                            .foregroundStyle(viewMode == mode ? AppTheme.textPrimary : AppTheme.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                viewMode == mode
                                    ? AppTheme.cardBackground
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    : Color.clear
                            )
                    }
                }
            }
            .padding(3)
            .background(AppTheme.cardSecondaryWarm)
            .clipShape(RoundedRectangle(cornerRadius: 11))
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 4)

            filterBar

            if viewMode == .calendar {
                calendarContent
            } else {
                agendaContent
            }
        }
        .background(AppTheme.backgroundCream)
        .navigationTitle("Calendario")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Oggi") {
                    withAnimation {
                        currentMonth = Date()
                        selectedDate = Date()
                    }
                }
                .font(.dmSans(14, weight: .semibold))
                .foregroundStyle(AppTheme.primaryGreen)
                .disabled(calendar.isDate(currentMonth, equalTo: Date(), toGranularity: .month))
            }
        }
        .navigationDestination(isPresented: $showDayDetail) {
            if let date = selectedDate {
                DayDetailView(
                    selectedDate: date,
                    activities: filteredActivities.filter {
                        calendar.isDate($0.data, inSameDayAs: date)
                    }
                )
            }
        }
    }
    .task { await loadFiltersData() }
    .task { await loadMonth() }
    .onChange(of: currentMonth) { _, _ in Task { await loadMonth() } }
    .onChange(of: showDayDetail) { _, isShowing in
        if !isShowing { Task { await loadMonth() } }
    }
    .onChange(of: filterOrtoId) { _, _ in
        if let piantaId = filterPiantaId,
           !visiblePiante.contains(where: { $0.id == piantaId }) {
            filterPiantaId = nil
        }
    }
    .overlay(alignment: .top) {
        // rain toast unchanged
        if showRainToast {
            HStack(spacing: 8) {
                Image(systemName: "cloud.rain.fill")
                    .foregroundStyle(AppTheme.rainBlue)
                Text("\(rainRescheduledCount) irrigazion\(rainRescheduledCount == 1 ? "e" : "i") spostat\(rainRescheduledCount == 1 ? "a" : "e") per pioggia")
                    .font(.dmSans(14, weight: .medium))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.regularMaterial, in: Capsule())
            .padding(.top, 8)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
    .animation(.spring(duration: 0.4), value: showRainToast)
}
```

- [ ] **Step 2: Update `calendarContent` background**

Replace:
```swift
private var calendarContent: some View {
    VStack(spacing: 0) {
        VStack(spacing: 0) {
            monthNavigator
            weekDayHeader
            calendarGrid
            legendView
        }
        .background(AppTheme.cardSecondary)
        Spacer()
    }
}
```

With:
```swift
private var calendarContent: some View {
    VStack(spacing: 0) {
        VStack(spacing: 0) {
            monthNavigator
            weekDayHeader
            calendarGrid
            legendView
        }
        .background(AppTheme.cardSecondaryWarm)
        Spacer()
    }
}
```

- [ ] **Step 3: Update `legendView` background**

Change `.background(AppTheme.cardBackground)` at the end of `legendView` to:
```swift
.background(AppTheme.backgroundCream)
```

- [ ] **Step 4: Update `filterChip` colors**

Replace the `filterChip` function:
```swift
private func filterChip(label: String, isActive: Bool) -> some View {
    HStack(spacing: 4) {
        Text(label)
            .font(.dmSans(11, weight: isActive ? .semibold : .regular))
        Image(systemName: "chevron.down")
            .font(.system(size: 9, weight: .medium))
    }
    .foregroundColor(isActive ? .white : AppTheme.textPrimary)
    .padding(.horizontal, 10)
    .padding(.vertical, 6)
    .background(isActive ? AppTheme.primaryGreen : AppTheme.cardBackground)
    .clipShape(Capsule())
    .overlay(
        Capsule()
            .stroke(isActive ? Color.clear : Color.secondary.opacity(0.3), lineWidth: 1)
    )
}
```

- [ ] **Step 5: Build**

```bash
cd "/Users/keape/Library/Mobile Documents/com~apple~CloudDocs/app sviluppate e html/garden-calendar-ios"
xcodebuild -scheme GardenCalendar -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -5
```

Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 6: Run in Simulator and verify**

Open Simulator with iPhone 16. Verify:
- Background is warm cream (not gray)
- "Calendario" title is large
- Segmented control is pill-style on warm background
- Tap a day → pushes DayDetailView (may crash until Task 4 renames the struct — acceptable)

- [ ] **Step 7: Commit**

```bash
git add GardenCalendar/Views/Calendario/CalendarView.swift
git commit -m "feat: apply Naturalista theme to CalendarView, convert sheet to push navigation"
```

---

## Task 4: DayDetailView — rename, restructure as push view

**Files:**
- Modify: `GardenCalendar/Views/Calendario/DayDetailSheet.swift` (content replacement; keep filename or rename)
- Note: Rename struct `DayDetailSheet` → `DayDetailView` throughout this file

> `NuovaAttivitaSheet` requires a `pianta` param, so the "Aggiungi attività" CTA will present `QuickJournalView` for now. This maintains add-activity functionality without breaking changes.

- [ ] **Step 1: Replace DayDetailSheet.swift content**

Replace the entire file content with:

```swift
import SwiftUI

struct DayDetailView: View {
    let selectedDate: Date
    @State private var activities: [Attivita]
    @State private var rainMm: Double = 0
    @State private var showAddActivity = false
    @State private var editingActivity: Attivita?
    @State private var showReschedulePicker = false
    @State private var rescheduleDate = Date()
    @State private var pianteLookup: [UUID: String] = [:]
    @State private var ortoLookup: [UUID: String] = [:]

    @Environment(SupabaseRepository.self) private var repository

    init(selectedDate: Date, activities: [Attivita] = []) {
        self.selectedDate = selectedDate
        self._activities = State(initialValue: activities)
    }

    private let calendar = Calendar.current

    // MARK: - Computed

    private var doneFraction: Double {
        guard !activities.isEmpty else { return 0 }
        return Double(activities.filter(\.done).count) / Double(activities.count)
    }

    private var progressLabel: String {
        "\(activities.filter(\.done).count) / \(activities.count)"
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // Date header
            Text(dateHeaderString)
                .font(.dmSans(11, weight: .medium))
                .foregroundStyle(AppTheme.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 4)

            // Title
            Text("Attività del giorno")
                .font(.lora(22))
                .foregroundStyle(AppTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 4)

            // Progress bar
            VStack(alignment: .trailing, spacing: 3) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(AppTheme.cardSecondaryWarm)
                            .frame(height: 4)
                        Capsule()
                            .fill(AppTheme.primaryGreen)
                            .frame(width: geo.size.width * doneFraction, height: 4)
                    }
                }
                .frame(height: 4)

                Text(progressLabel)
                    .font(.dmSans(10))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 4)

            // Activity list
            if activities.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "calendar.day.timeline.left")
                        .font(.system(size: 40))
                        .foregroundStyle(AppTheme.textSecondary.opacity(0.4))
                    Text("Nessuna attività per questo giorno")
                        .font(.dmSans(15, weight: .medium))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(activities) { activity in
                            NaturalistaActivityRow(
                                activity: activity,
                                piantaNome: pianteLookup[activity.piantaId],
                                ortoNome: ortoLookup[activity.piantaId]
                            )
                            .swipeActions(edge: .trailing) {
                                Button { rescheduleActivity(activity) } label: {
                                    Label("Sposta", systemImage: "arrow.right")
                                }
                                .tint(.blue)
                            }
                            .swipeActions(edge: .leading) {
                                Button { moveActivityBack(activity) } label: {
                                    Label("Indietro", systemImage: "arrow.left")
                                }
                                .tint(.orange)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
            }

            // CTA
            Button {
                showAddActivity = true
            } label: {
                HStack {
                    Image(systemName: "plus")
                    Text("Aggiungi attività")
                        .font(.dmSans(15, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(AppTheme.ctaDarkGreen)
                .clipShape(Capsule())
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .background(AppTheme.backgroundCream)
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadActivities() }
        .sheet(isPresented: $showAddActivity, onDismiss: { Task { await loadActivities() } }) {
            QuickJournalView()
        }
        .sheet(isPresented: $showReschedulePicker) {
            rescheduleSheet
        }
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

    private var dateHeaderString: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "it_IT")
        f.dateFormat = "EEE · d MMMM yyyy"
        return f.string(from: selectedDate).uppercased()
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

    private func confirmReschedule() {
        if let activity = editingActivity {
            Task { try? await repository.rescheduleAttivita(id: activity.id, date: rescheduleDate) }
        }
        showReschedulePicker = false
        editingActivity = nil
    }

    private func loadActivities() async {
        let all = (try? await repository.fetchAttivita(date: selectedDate)) ?? []
        activities = all.filter { calendar.isDate($0.data, inSameDayAs: selectedDate) }

        if let userId = AuthManager.shared.user?.id {
            let piante = (try? await repository.fetchAllPiante(userId: userId)) ?? []
            let orti = (try? await repository.fetchOrti(userId: userId)) ?? []
            pianteLookup = Dictionary(uniqueKeysWithValues: piante.map { ($0.id, $0.nomePersonalizzato) })

            // Map piantaId → ortoNome via pianta.ortoId
            var map: [UUID: String] = [:]
            for p in piante {
                if let orto = orti.first(where: { $0.id == p.ortoId }) {
                    map[p.id] = orto.nome
                }
            }
            ortoLookup = map

            await fetchRainStatus(orti: orti)
        }
    }

    private func fetchRainStatus(orti: [Orto]) async {
        let cal = Calendar.current
        let from = cal.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
        let to = cal.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
        let f = ISO8601DateFormatter(); f.formatOptions = [.withFullDate]
        let dateStr = f.string(from: selectedDate)

        for orto in orti {
            guard let lat = orto.latitudine, let lon = orto.longitudine else { continue }
            let days = (try? await OpenMeteoClient.shared.fetchRainDays(
                latitude: lat, longitude: lon, from: from, to: to)) ?? [:]
            if let mm = days[dateStr], mm > 0 {
                rainMm = mm
                return
            }
        }
        rainMm = 0
    }
}

// MARK: - NaturalistaActivityRow

struct NaturalistaActivityRow: View {
    let activity: Attivita
    var piantaNome: String?
    var ortoNome: String?

    @Environment(SupabaseRepository.self) private var repository

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(AppTheme.color(for: activity.nome).opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: iconForActivity(activity.nome))
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.color(for: activity.nome))
            }

            // Text
            VStack(alignment: .leading, spacing: 2) {
                Text(piantaNome ?? activity.nome.capitalized)
                    .font(.dmSans(13, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .strikethrough(activity.done)

                HStack(spacing: 4) {
                    Text(activity.nome.capitalized)
                    if let orto = ortoNome {
                        Text("·")
                        Text(orto)
                    }
                }
                .font(.dmSans(10))
                .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer()

            // Time
            if !formattedTime.isEmpty {
                Text(formattedTime)
                    .font(.dmSans(11))
                    .foregroundStyle(AppTheme.textSecondary)
            }

            // Checkbox
            Button(action: toggleDone) {
                Image(systemName: activity.done ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(activity.done ? AppTheme.primaryGreen : Color.secondary.opacity(0.4))
                    .font(.system(size: 20))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.04), radius: 4, y: 1)
        .opacity(activity.done ? 0.7 : 1.0)
    }

    private var formattedTime: String {
        let cal = Calendar.current
        let h = cal.component(.hour, from: activity.data)
        let m = cal.component(.minute, from: activity.data)
        guard h != 0 || m != 0 else { return "" }
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: activity.data)
    }

    private func toggleDone() {
        Task { try? await repository.setDone(id: activity.id, done: !activity.done) }
    }

    private func iconForActivity(_ name: String) -> String {
        switch name.lowercased() {
        case "semina":    return "leaf.fill"
        case "trapianto": return "arrow.triangle.branch"
        case "raccolta":  return "basket.fill"
        case "irrigazione", "bevuta": return "drop.fill"
        case "concimazione": return "flask.fill"
        case "potatura":  return "scissors"
        case "sarchiatura": return "leaf.arrow.triangle.circlepath"
        case "trattamento": return "cross.case.fill"
        case "innesto":   return "point.topleft.down.curvedto.point.bottomright.up"
        default:          return "leaf.fill"
        }
    }
}

#Preview {
    NavigationStack {
        DayDetailView(selectedDate: Date(), activities: [])
            .environment(SupabaseRepository.shared)
    }
}
```

- [ ] **Step 2: Update the reference in CalendarView.swift**

In `CalendarView.swift`, the `.navigationDestination` block already references `DayDetailView` (written in Task 3). Verify the struct name matches — both should be `DayDetailView`. No change needed if Task 3 was done correctly.

- [ ] **Step 3: Build**

```bash
cd "/Users/keape/Library/Mobile Documents/com~apple~CloudDocs/app sviluppate e html/garden-calendar-ios"
xcodebuild -scheme GardenCalendar -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | grep -E "error:|BUILD"
```

Expected: `** BUILD SUCCEEDED **` (zero errors)

If build fails with "use of unresolved identifier 'DayDetailSheet'": search codebase for remaining references to `DayDetailSheet` and replace with `DayDetailView`.

```bash
grep -r "DayDetailSheet" "/Users/keape/Library/Mobile Documents/com~apple~CloudDocs/app sviluppate e html/garden-calendar-ios/GardenCalendar" --include="*.swift"
```

- [ ] **Step 4: Run in Simulator and verify**

- Tap a calendar day → DayDetailView pushes with back button "Calendario"
- Date header visible (e.g. "LUN · 2 GIUGNO 2026")
- Progress bar shows ratio done/total
- Activity rows show icon, pianta name, activity type, orto, time (if set), checkbox
- "+ Aggiungi attività" CTA at bottom opens QuickJournalView sheet

- [ ] **Step 5: Commit**

```bash
git add GardenCalendar/Views/Calendario/DayDetailSheet.swift
git commit -m "feat: redesign DayDetailSheet as DayDetailView push with Naturalista layout"
```

---

## Task 5: OrtoListView restyling

**Files:**
- Modify: `GardenCalendar/Views/Orto/OrtoListView.swift`

- [ ] **Step 1: Update List to cards on cream background**

In `OrtoListView.body`, replace the `List` with `ScrollView + VStack`:

```swift
var body: some View {
    NavigationStack {
        Group {
            if orti.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(orti) { orto in
                            NavigationLink(value: orto) {
                                OrtoCardRow(orto: orto)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
        }
        .background(AppTheme.backgroundCream)
        .navigationTitle("I miei orti")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showNewOrto = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .navigationDestination(for: Orto.self) { orto in OrtoDetailView(orto: orto) }
        .sheet(isPresented: $showNewOrto) { newOrtoSheet }
        .alert("Elimina orto", isPresented: $showDeleteConfirm, presenting: ortoToDelete) { orto in
            Button("Elimina", role: .destructive) { deleteOrto(orto) }
            Button("Annulla", role: .cancel) {}
        } message: { orto in
            Text("Eliminare l'orto \"\(orto.nome)\"? Le piante collegate non verranno eliminate.")
        }
        .task { await loadOrti() }
        .onAppear { Task { await loadOrti() } }
        .refreshable { await loadOrti() }
        .alert("Errore", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Button("OK", role: .cancel) {}
        } message: { Text(errorMessage ?? "") }
    }
}
```

- [ ] **Step 2: Replace OrtoRow with OrtoCardRow**

Replace the existing `OrtoRow` struct with:

```swift
struct OrtoCardRow: View {
    let orto: Orto

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppTheme.primaryGreen.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: "tree.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(AppTheme.primaryGreen)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(orto.nome)
                    .font(.dmSans(15, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)

                if let luogo = orto.luogo, !luogo.isEmpty {
                    Label(luogo, systemImage: "mappin")
                        .font(.dmSans(12))
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppTheme.textSecondary.opacity(0.5))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.04), radius: 4, y: 1)
    }
}
```

- [ ] **Step 3: Build and verify**

```bash
cd "/Users/keape/Library/Mobile Documents/com~apple~CloudDocs/app sviluppate e html/garden-calendar-ios"
xcodebuild -scheme GardenCalendar -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | grep -E "error:|BUILD"
```

- [ ] **Step 4: Commit**

```bash
git add GardenCalendar/Views/Orto/OrtoListView.swift
git commit -m "feat: restyle OrtoListView with Naturalista card layout"
```

---

## Task 6: OrtoDetailView restyling

**Files:**
- Modify: `GardenCalendar/Views/Orto/OrtoDetailView.swift`

- [ ] **Step 1: Update List to cream background**

In `OrtoDetailView.body`, add `.scrollContentBackground(.hidden)` and `.background(AppTheme.backgroundCream)` after `.listStyle(.insetGrouped)`:

```swift
.listStyle(.insetGrouped)
.scrollContentBackground(.hidden)
.background(AppTheme.backgroundCream)
```

- [ ] **Step 2: Update navigation title font via UINavigationBar appearance**

In `OrtoDetailView.body` toolbar or `.onAppear`, the navigation title inherits from the global appearance set in Task 2. No per-view font override needed for `navigationTitle`.

- [ ] **Step 3: Update PiantaRowView progress tint and text colors**

In `PiantaRowView.body`, update font calls:

```swift
Text(pianta.nomePersonalizzato)
    .font(.dmSans(15, weight: .semibold))
    .foregroundStyle(AppTheme.textPrimary)

Text("\(pianta.growthDays) giorni")
    .font(.dmSans(12))
    .foregroundStyle(AppTheme.textSecondary)

Text("\(pianta.giorniTrascorsi)g")
    .font(.dmSans(12, weight: .semibold))
    .foregroundStyle(AppTheme.textSecondary)
```

- [ ] **Step 4: Build and commit**

```bash
cd "/Users/keape/Library/Mobile Documents/com~apple~CloudDocs/app sviluppate e html/garden-calendar-ios"
xcodebuild -scheme GardenCalendar -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | grep -E "error:|BUILD"
git add GardenCalendar/Views/Orto/OrtoDetailView.swift
git commit -m "feat: restyle OrtoDetailView with Naturalista theme"
```

---

## Task 7: PiantaListView + PiantaDetailView restyling

**Files:**
- Modify: `GardenCalendar/Views/Piante/PiantaListView.swift`
- Modify: `GardenCalendar/Views/Piante/PiantaDetailView.swift`

- [ ] **Step 1: Update PiantaListView background and search bar**

In `PiantaListView.body`, replace `.background(Color(.systemGroupedBackground))` with `.background(AppTheme.backgroundCream)`.

Update the search bar background:
```swift
.background(AppTheme.cardBackground)
```

Update `PiantaCardView` to use DM Sans fonts:
```swift
Text(pianta.nomePersonalizzato)
    .font(.dmSans(14, weight: .semibold))
    .foregroundStyle(AppTheme.textPrimary)

Text("\(pianta.growthDays) giorni totali")
    .font(.dmSans(11))
    .foregroundStyle(AppTheme.textSecondary)

Text("\(pianta.giorniTrascorsi)g / \(pianta.growthDays)g")
    .font(.dmSans(10))
    .foregroundStyle(AppTheme.textSecondary)
```

- [ ] **Step 2: Update PiantaDetailView**

Open `GardenCalendar/Views/Piante/PiantaDetailView.swift`. Find all occurrences of:
- `.background(Color(.systemGroupedBackground))` → `.background(AppTheme.backgroundCream)` 
- `.background(AppTheme.cardSecondary)` → `.background(AppTheme.cardSecondaryWarm)`
- `.font(.headline)` on primary labels → `.font(.dmSans(15, weight: .semibold))`
- `.font(.caption)` on secondary labels → `.font(.dmSans(12))`
- `.foregroundStyle(.secondary)` on secondary text → `.foregroundStyle(AppTheme.textSecondary)`

- [ ] **Step 3: Build and commit**

```bash
cd "/Users/keape/Library/Mobile Documents/com~apple~CloudDocs/app sviluppate e html/garden-calendar-ios"
xcodebuild -scheme GardenCalendar -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | grep -E "error:|BUILD"
git add GardenCalendar/Views/Piante/PiantaListView.swift GardenCalendar/Views/Piante/PiantaDetailView.swift
git commit -m "feat: restyle Piante views with Naturalista theme"
```

---

## Task 8: SettingsView restyling

**Files:**
- Modify: `GardenCalendar/Views/Settings/SettingsView.swift`

- [ ] **Step 1: Remove Form gray background**

After `.navigationTitle("Impostazioni")`, add:

```swift
.scrollContentBackground(.hidden)
.background(AppTheme.backgroundCream)
```

- [ ] **Step 2: Update section header fonts**

`Form` section headers inherit from the SwiftUI default. To apply DM Sans to section labels, wrap section headers explicitly:

For each `Section("Profilo")` style, convert to:
```swift
Section(header: Text("Profilo").font(.dmSans(11, weight: .semibold)).foregroundStyle(AppTheme.textSecondary)) {
```

Apply to all 6 sections: Profilo, Orto preferito, Meteo, Aspetto, Info, footer section.

- [ ] **Step 3: Build and commit**

```bash
cd "/Users/keape/Library/Mobile Documents/com~apple~CloudDocs/app sviluppate e html/garden-calendar-ios"
xcodebuild -scheme GardenCalendar -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | grep -E "error:|BUILD"
git add GardenCalendar/Views/Settings/SettingsView.swift
git commit -m "feat: restyle SettingsView with Naturalista cream background"
```

---

## Task 9: LoginView + SignUpView restyling

**Files:**
- Modify: `GardenCalendar/Views/Auth/LoginView.swift`
- Modify: `GardenCalendar/Views/Auth/SignUpView.swift`

- [ ] **Step 1: Read LoginView.swift to understand current structure**

```bash
cat "/Users/keape/Library/Mobile Documents/com~apple~CloudDocs/app sviluppate e html/garden-calendar-ios/GardenCalendar/Views/Auth/LoginView.swift"
```

- [ ] **Step 2: Apply to LoginView**

For each of these patterns, apply the Naturalista equivalent:
- `ZStack` or `VStack` root background → `.background(AppTheme.backgroundCream.ignoresSafeArea())`
- App title `Text` → `.font(.lora(32))`
- Primary `Text` labels → `.font(.dmSans(15, weight: .medium))` / `.foregroundStyle(AppTheme.textPrimary)`
- `TextField` / `SecureField` backgrounds → `AppTheme.cardBackground` with `cornerRadius(12)` and border `AppTheme.cardSecondaryWarm`
- Primary CTA `Button` → full-width, `AppTheme.primaryGreen`, `Capsule()` shape, `.font(.dmSans(15, weight: .semibold))`
- Secondary links → `.font(.dmSans(13))` / `.foregroundStyle(AppTheme.primaryGreen)`

- [ ] **Step 3: Apply same pattern to SignUpView**

Repeat Step 2 patterns for `SignUpView.swift`.

- [ ] **Step 4: Build**

```bash
cd "/Users/keape/Library/Mobile Documents/com~apple~CloudDocs/app sviluppate e html/garden-calendar-ios"
xcodebuild -scheme GardenCalendar -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | grep -E "error:|BUILD"
```

- [ ] **Step 5: Commit**

```bash
git add GardenCalendar/Views/Auth/LoginView.swift GardenCalendar/Views/Auth/SignUpView.swift
git commit -m "feat: restyle Auth screens with Naturalista theme"
```

---

## Task 10: Final integration verification

- [ ] **Step 1: Full build**

```bash
cd "/Users/keape/Library/Mobile Documents/com~apple~CloudDocs/app sviluppate e html/garden-calendar-ios"
xcodebuild -scheme GardenCalendar -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | grep -E "error:|warning:|BUILD"
```

- [ ] **Step 2: Run in Simulator — full flow check**

Verify each screen:
1. Login screen → cream background, Lora app title, pill CTA
2. CalendarView → cream bg, large "Calendario" title, custom segmented, warm calendar area
3. Tap day → DayDetailView pushes (back button "Calendario"), activity rows show icon + pianta + type · orto + time + checkbox, progress bar, green CTA
4. "+ Aggiungi attività" → QuickJournalView sheet opens
5. Orti tab → card rows on cream
6. Tap orto → OrtoDetailView cream, piante section visible
7. Impostazioni → cream Form

- [ ] **Step 3: Update graphify graph**

```bash
cd "/Users/keape/Library/Mobile Documents/com~apple~CloudDocs/app sviluppate e html/garden-calendar-ios"
graphify update .
```

- [ ] **Step 4: Final commit**

```bash
git add -A
git commit -m "feat: complete Naturalista UX redesign across all screens"
```
