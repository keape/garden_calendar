# Naturalista UX Redesign

**Data:** 2026-06-04  
**Tema:** A — Naturalista (Caldo e botanico)  
**Approccio:** Foundation-first (A)

---

## 1. Obiettivo

Applicare il tema visivo "Naturalista" a tutte le schermate dell'app Garden Calendar iOS. Il tema si caratterizza per sfondo crema #F8F2E8, tipografia serif Lora per i titoli, DM Sans per il body, palette verde botanico, e layout pulito ispirato al mockup fornito.

---

## 2. Decisioni chiave

| Dimensione | Decisione |
|---|---|
| Font titoli | Lora Bold (da aggiungere al bundle Xcode) |
| Font body | DM Sans Regular/Medium/SemiBold (da aggiungere) |
| Sfondo app | #F8F2E8 (backgroundCream) |
| Tab bar | 3 tab: Calendario · Orti · Impostazioni |
| Piante | Sub-navigazione dentro OrtoDetailView |
| Lista del giorno | NavigationStack push (non più bottom sheet) |
| CTA giorno | "+ Aggiungi attività" pill verde scuro, sostituisce journal entry |

---

## 3. Sistema di design

### 3.1 Palette — nuovi token AppTheme

```swift
static let backgroundCream   = Color(red: 0.973, green: 0.949, blue: 0.910) // #F8F2E8
static let cardSecondaryWarm = Color(red: 0.933, green: 0.910, blue: 0.863) // #EEE8DC
static let textPrimary       = Color(red: 0.102, green: 0.227, blue: 0.102) // #1A3A1A
static let textSecondary     = Color(red: 0.420, green: 0.420, blue: 0.290) // #6B6B4A
static let ctaDarkGreen      = Color(red: 0.180, green: 0.239, blue: 0.180) // #2E3D2E
```

Token esistenti che cambiano semantica:
- `cardBackground` → `Color.white` (era systemGray6)
- `cardSecondary` → `cardSecondaryWarm` (era systemGray5)

### 3.2 Tipografia

| Ruolo | Font | Peso | Dimensione |
|---|---|---|---|
| Titolo schermata | Lora | Bold | 28–30pt |
| Titolo sezione | Lora | Bold | 20–22pt |
| Body principale | DM Sans | Medium | 15pt |
| Testo secondario | DM Sans | Regular | 12pt |
| Chip / Label | DM Sans | SemiBold | 11pt |
| Caption | DM Sans | Regular | 10pt |

Font files da aggiungere al progetto Xcode:
- `Lora-Bold.ttf` (Google Fonts, OFL license)
- `DMSans-Regular.ttf`, `DMSans-Medium.ttf`, `DMSans-SemiBold.ttf`

Registrazione in `Info.plist` sotto key `UIAppFonts`.

Helper da aggiungere in `AppTheme.swift`:
```swift
extension Font {
    static func lora(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .custom("Lora-Bold", size: size)
    }
    static func dmSans(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let name: String
        switch weight {
        case .medium:    name = "DMSans-Medium"
        case .semibold:  name = "DMSans-SemiBold"
        default:         name = "DMSans-Regular"
        }
        return .custom(name, size: size)
    }
}
```

---

## 4. Struttura navigazione

### Tab bar (3 tab)

```
ContentView
├── Tab 1: CalendarGridView         (Calendario)
├── Tab 2: OrtoListView             (Orti)
└── Tab 3: SettingsView             (Impostazioni)
```

`PiantaListView` non è più un tab. Viene embedded come sezione dentro `OrtoDetailView`.

### Flusso Calendario

```
CalendarGridView
  └── tap giorno → NavigationStack push → DayDetailView
```

`DayDetailSheet.swift` viene rinominato `DayDetailView.swift`. Non è più uno sheet; CalendarGridView usa `.navigationDestination(isPresented: $showDayDetail)` con `selectedDate: Date?` come state separato (già esistenti entrambi) — `Date` non è `Identifiable` quindi si evita `navigationDestination(item:)`.

### Flusso Orti

```
OrtoListView
  └── tap orto → OrtoDetailView
        └── sezione "Piante" con lista PiantaColtivata
              └── tap pianta → PiantaDetailView
```

`OrtoDetailView` aggiunge una `Section` o `List` di piante filtrate per `orto.id`, attualmente assente o priva di piante visibili.

---

## 5. Modifiche per schermata

### 5.1 AppTheme.swift
- Aggiunge token `backgroundCream`, `cardSecondaryWarm`, `textPrimary`, `textSecondary`, `ctaDarkGreen`
- Aggiunge extension `Font.lora()` e `Font.dmSans()`
- Aggiorna `cardBackground` → `Color.white`

### 5.2 CalendarGridView.swift
- `NavigationStack` mantiene `.navigationTitle` ma con `.large` display mode e font Lora (via `UINavigationBar.appearance`)
- Sfondo: `backgroundCream` su tutto il body
- Segmented control: stile custom pill (rimpiazza `.segmented` nativo con due `Button` in `HStack` su sfondo `cardSecondaryWarm`)
- Filter chip: invariati nella logica, aggiornati nei colori
- Calendario: area `calendarContent` su sfondo `cardSecondaryWarm`
- `.sheet(isPresented: $showDayDetail)` → `.navigationDestination(isPresented: $showDayDetail)` che presenta `DayDetailView`
- `selectedDate: Date?` e `showDayDetail: Bool` già esistono — nessun nuovo state necessario

### 5.3 DayDetailView.swift (ex DayDetailSheet)
- Non più `View` wrapped in `NavigationStack` come sheet — diventa view normale per push
- Rimuove `.presentationDetents`
- Header: data in formato "LUN · 2 GIUGNO 2026" (DM Sans 11pt, textSecondary)
- Titolo: "Attività del giorno" (Lora Bold 22pt)
- Progress bar: `GeometryReader` o `ProgressView` con colore primaryGreen, label "X / Y" a destra
- Activity list: `ScrollView` + `VStack` (non più `List` — rimuove separatori di sistema)
- `DayActivityRow`: aggiunge orario a destra, checkbox restyling (vedi §5.4)
- Rimuove sezioni "Journal" e "Suggerimenti AI" come sezioni separate — tutte le attività in lista unica
- Rimuove pulsante "Aggiungi journal entry" ambra
- Aggiunge CTA `Button` full-width "＋ Aggiungi attività" con stile pill `ctaDarkGreen`
- CTA apre `NuovaAttivitaSheet` (già esistente nel progetto)
- Toolbar: rimuove "Chiudi" — il back button del NavigationStack è sufficiente

### 5.4 DayActivityRow (in DayDetailView.swift)
- Layout: `[icona 36pt] [nome + sottotitolo] [Spacer] [ora] [checkbox]`
- Background: `Color.white`, `cornerRadius(12)`, shadow lieve
- Icona: circle fill con colore attività opacity 0.15, icona SF Symbols al centro
- Nome: DM Sans Medium 13pt, `textPrimary`
- Sottotitolo: `"\(activity.nome.capitalized) · \(ortoNome)"` — DM Sans Regular 10pt, `textSecondary`
- Ora: se `activity.data` ha componente ora non mezzanotte → formatta "HH:mm"; altrimenti stringa vuota
- Checkbox: circle vuoto (todo) o circle fill verde (done) — tap chiama `toggleDone()`

### 5.5 OrtoListView.swift
- Background: `backgroundCream` (rimpiazza `.insetGrouped`)
- `List` → `ScrollView + VStack` con card bianche `cornerRadius(12)` e shadow
- `OrtoRow`: stesso layout, colori aggiornati

### 5.6 OrtoDetailView.swift
- Aggiunge sezione piante: `Section("Piante")` con `ForEach` su piante filtrate per `orto.id`
- Fetch piante: aggiunge `@State private var piante: [PiantaColtivata] = []` e `loadPiante()` in `.task`
- NavigationDestination per `PiantaColtivata` → `PiantaDetailView`
- Restyling tema crema

### 5.7 PiantaListView.swift
- Non più tab standalone — usato solo embedded in OrtoDetailView o rimane come view riusabile
- Il file rimane, ma `ContentView` rimuove il tab che puntava a questa view

### 5.8 PiantaDetailView.swift
- Solo restyling tema crema, nessun cambiamento strutturale

### 5.9 SettingsView.swift
- `Form` rimane ma con `.scrollContentBackground(.hidden)` + background `backgroundCream`
- Font titoli sezione → DM Sans SemiBold

### 5.10 LoginView.swift / SignUpView.swift
- Background: `backgroundCream`
- Titolo app: Lora Bold
- Campi input: border `cardSecondaryWarm`, sfondo white
- Pulsanti CTA: `primaryGreen` pill

### 5.11 ContentView.swift
- `TabView` da 4 tab → 3 tab: rimuove tab Piante
- Aggiunge `.toolbarBackground(Color.backgroundCream, for: .tabBar)`

---

## 6. File da creare / modificare

| File | Azione |
|---|---|
| `GardenCalendar/Theme/AppTheme.swift` | Modifica — nuovi token + font helpers |
| `GardenCalendar/Views/Calendario/CalendarView.swift` | Modifica |
| `GardenCalendar/Views/Calendario/DayDetailSheet.swift` | Rinomina → `DayDetailView.swift`, modifica |
| `GardenCalendar/Views/Orto/OrtoListView.swift` | Modifica |
| `GardenCalendar/Views/Orto/OrtoDetailView.swift` | Modifica |
| `GardenCalendar/Views/Piante/PiantaListView.swift` | Modifica (rimuove navigazione tab) |
| `GardenCalendar/Views/Piante/PiantaDetailView.swift` | Modifica (restyling) |
| `GardenCalendar/Views/Settings/SettingsView.swift` | Modifica |
| `GardenCalendar/Views/Auth/LoginView.swift` | Modifica |
| `GardenCalendar/Views/Auth/SignUpView.swift` | Modifica |
| `GardenCalendar/GardenCalendarApp.swift` o `ContentView.swift` | Modifica (3 tab) |
| `GardenCalendar/Resources/Fonts/Lora-Bold.ttf` | Crea (aggiunge file) |
| `GardenCalendar/Resources/Fonts/DMSans-Regular.ttf` | Crea |
| `GardenCalendar/Resources/Fonts/DMSans-Medium.ttf` | Crea |
| `GardenCalendar/Resources/Fonts/DMSans-SemiBold.ttf` | Crea |
| `GardenCalendar/Info.plist` | Modifica — registra UIAppFonts |
| `GardenCalendar.xcodeproj/project.pbxproj` | Modifica — aggiunge font files al target |

---

## 7. Sequenza di implementazione (Foundation-first)

1. **Step 1 — Font setup:** Scarica font, aggiungili al bundle Xcode, registra in Info.plist, verifica build
2. **Step 2 — AppTheme:** Aggiungi token colore + Font helpers, aggiorna `cardBackground`
3. **Step 3 — ContentView:** Riduci a 3 tab, rimuovi tab Piante
4. **Step 4 — CalendarView:** Restyling + converti sheet → navigationDestination
5. **Step 5 — DayDetailView:** Rinomina file, ristruttura come push view, nuovi activity rows, CTA
6. **Step 6 — OrtoListView + OrtoDetailView:** Restyling + aggiunge sezione Piante
7. **Step 7 — Restanti view:** PiantaDetail, Settings, Login, SignUp — solo restyling

Ogni step è verificabile nel Simulator prima di procedere al successivo.

---

## 8. Vincoli e note

- `NuovaAttivitaSheet.swift` già esiste nel progetto — usato dal CTA senza modifiche strutturali
- `QuickJournalView` diventa inutilizzata dopo Step 5 — può essere eliminata o mantenuta dormiente
- La logica meteo (rain toast, rainDays) non cambia — solo restyling
- Il modello dati `Attivita` non cambia — l'ora viene estratta da `activity.data` (componente time)
- Font Google Fonts (Lora, DM Sans) sono OFL — liberi per uso commerciale
