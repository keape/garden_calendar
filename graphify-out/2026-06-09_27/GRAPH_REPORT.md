# Graph Report - practical-liskov-144414  (2026-06-09)

## Corpus Check
- 75 files · ~36,140 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 822 nodes · 982 edges · 83 communities (66 shown, 17 thin omitted)
- Extraction: 96% EXTRACTED · 4% INFERRED · 0% AMBIGUOUS · INFERRED: 39 edges (avg confidence: 0.84)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `e35a4b54`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- [[_COMMUNITY_Orto Data Model|Orto Data Model]]
- [[_COMMUNITY_Calendar UI Views|Calendar UI Views]]
- [[_COMMUNITY_Day Detail & Activity|Day Detail & Activity]]
- [[_COMMUNITY_UI Theme & Color System|UI Theme & Color System]]
- [[_COMMUNITY_Admin Dashboard Functions|Admin Dashboard Functions]]
- [[_COMMUNITY_Core Data Models|Core Data Models]]
- [[_COMMUNITY_Wiki & Knowledge Pipeline|Wiki & Knowledge Pipeline]]
- [[_COMMUNITY_Community 7|Community 7]]
- [[_COMMUNITY_Repository & Error Handling|Repository & Error Handling]]
- [[_COMMUNITY_Community 9|Community 9]]
- [[_COMMUNITY_Community 10|Community 10]]
- [[_COMMUNITY_Attività CodingKeys|Attività CodingKeys]]
- [[_COMMUNITY_LLM Plant Care Extraction|LLM Plant Care Extraction]]
- [[_COMMUNITY_Settings & Theme Mode|Settings & Theme Mode]]
- [[_COMMUNITY_App Entry & Navigation|App Entry & Navigation]]
- [[_COMMUNITY_Add Plant View|Add Plant View]]
- [[_COMMUNITY_VSCode Deno Config|VSCode Deno Config]]
- [[_COMMUNITY_App Icon Assets|App Icon Assets]]
- [[_COMMUNITY_Supabase Project Config|Supabase Project Config]]
- [[_COMMUNITY_Asset Catalog Metadata|Asset Catalog Metadata]]
- [[_COMMUNITY_Extract Plant Imports|Extract Plant Imports]]
- [[_COMMUNITY_Preview Asset Metadata|Preview Asset Metadata]]
- [[_COMMUNITY_Schedule Activities Imports|Schedule Activities Imports]]
- [[_COMMUNITY_App Store & Apple Sign-In|App Store & Apple Sign-In]]
- [[_COMMUNITY_App Entry Point|App Entry Point]]
- [[_COMMUNITY_Supabase Configuration|Supabase Configuration]]
- [[_COMMUNITY_Build & Package Config|Build & Package Config]]
- [[_COMMUNITY_Admin CORS Config|Admin CORS Config]]
- [[_COMMUNITY_Login Auth Flow|Login Auth Flow]]
- [[_COMMUNITY_Signup Auth Flow|Signup Auth Flow]]
- [[_COMMUNITY_Calendar Data Fetch|Calendar Data Fetch]]
- [[_COMMUNITY_Admin Deno Config|Admin Deno Config]]
- [[_COMMUNITY_Build Script|Build Script]]
- [[_COMMUNITY_VSCode Extensions|VSCode Extensions]]
- [[_COMMUNITY_Community 36|Community 36]]
- [[_COMMUNITY_Community 37|Community 37]]
- [[_COMMUNITY_Community 38|Community 38]]
- [[_COMMUNITY_Community 39|Community 39]]
- [[_COMMUNITY_Community 40|Community 40]]
- [[_COMMUNITY_Community 41|Community 41]]
- [[_COMMUNITY_Community 42|Community 42]]
- [[_COMMUNITY_Community 43|Community 43]]
- [[_COMMUNITY_Community 44|Community 44]]
- [[_COMMUNITY_Community 45|Community 45]]
- [[_COMMUNITY_Community 46|Community 46]]
- [[_COMMUNITY_Community 47|Community 47]]
- [[_COMMUNITY_Community 48|Community 48]]
- [[_COMMUNITY_Community 49|Community 49]]
- [[_COMMUNITY_Community 50|Community 50]]
- [[_COMMUNITY_Community 51|Community 51]]
- [[_COMMUNITY_Community 52|Community 52]]
- [[_COMMUNITY_Community 53|Community 53]]
- [[_COMMUNITY_Community 54|Community 54]]
- [[_COMMUNITY_Community 55|Community 55]]
- [[_COMMUNITY_Community 56|Community 56]]
- [[_COMMUNITY_Community 57|Community 57]]
- [[_COMMUNITY_Community 58|Community 58]]
- [[_COMMUNITY_Community 59|Community 59]]
- [[_COMMUNITY_Community 60|Community 60]]
- [[_COMMUNITY_Community 61|Community 61]]
- [[_COMMUNITY_Community 62|Community 62]]
- [[_COMMUNITY_Community 63|Community 63]]
- [[_COMMUNITY_Community 64|Community 64]]
- [[_COMMUNITY_Community 65|Community 65]]
- [[_COMMUNITY_Community 66|Community 66]]
- [[_COMMUNITY_Community 67|Community 67]]
- [[_COMMUNITY_Community 68|Community 68]]
- [[_COMMUNITY_Community 70|Community 70]]
- [[_COMMUNITY_Community 71|Community 71]]
- [[_COMMUNITY_Community 72|Community 72]]
- [[_COMMUNITY_Community 73|Community 73]]
- [[_COMMUNITY_Community 74|Community 74]]
- [[_COMMUNITY_Community 75|Community 75]]
- [[_COMMUNITY_Community 76|Community 76]]
- [[_COMMUNITY_Community 77|Community 77]]
- [[_COMMUNITY_Community 79|Community 79]]
- [[_COMMUNITY_Community 83|Community 83]]
- [[_COMMUNITY_Community 84|Community 84]]
- [[_COMMUNITY_Community 86|Community 86]]
- [[_COMMUNITY_Community 87|Community 87]]

## God Nodes (most connected - your core abstractions)
1. `SupabaseRepository` - 47 edges
2. `CodingKeys` - 19 edges
3. `CodingKeys` - 17 edges
4. `AppTheme` - 17 edges
5. `CodingKeys` - 15 edges
6. `OrtoDetailView` - 15 edges
7. `QuickJournalView` - 14 edges
8. `CalendarGridView` - 14 edges
9. `PiantaDetailView` - 14 edges
10. `DayDetailSheet` - 13 edges

## Surprising Connections (you probably didn't know these)
- `Admin Dashboard (HTML)` --references--> `SupabaseRepository`  [INFERRED]
  admin-dashboard.html → GardenCalendar/Services/SupabaseRepository.swift
- `Orto` --semantically_similar_to--> `Orto`  [INFERRED] [semantically similar]
  GardenCalendar/Views/Orto/OrtoListView.swift → /Users/keape/Library/Mobile Documents/com~apple~CloudDocs/app sviluppate e html/garden-calendar-ios/GardenCalendar/Models/Orto.swift
- `Admin Dashboard (HTML)` --references--> `AuthManager`  [INFERRED]
  admin-dashboard.html → /Users/keape/Library/Mobile Documents/com~apple~CloudDocs/app sviluppate e html/garden-calendar-ios/GardenCalendar/Services/AuthManager.swift
- `AppTheme (ActivityColorDot local copy)` --semantically_similar_to--> `AppTheme`  [INFERRED] [semantically similar]
  GardenCalendar/Views/Components/ActivityColorDot.swift → /Users/keape/Library/Mobile Documents/com~apple~CloudDocs/app sviluppate e html/garden-calendar-ios/GardenCalendar/Theme/AppTheme.swift
- `Forward Scheduling Logic` --references--> `Attivita Table (Calendar Activities)`  [INFERRED]
  supabase/functions/schedule-activities/index.ts → supabase-schema.sql

## Hyperedges (group relationships)
- **Wiki Note → LLM Extraction → Plant Knowledge Pipeline** — supabase_schema_wiki_notes, functions_extract_plant_care_index, openrouter_deepseek, supabase_schema_plant_knowledge [EXTRACTED 1.00]
- **Plant Sowing → Schedule Activities → Calendar** — supabase_schema_piante_coltivate, functions_schedule_activities_index, supabase_schema_attivita [EXTRACTED 1.00]
- **iOS Auth-Gated Navigation Pattern** — gardencalendar_contentview_authmanager, gardencalendar_contentview_contentview, gardencalendar_contentview_loginview [EXTRACTED 1.00]
- **Authentication Flow: Login, SignUp, AuthManager** — auth_loginview_loginview, auth_signupview_signupview, services_authmanager_authmanager [EXTRACTED 1.00]
- **Activity Color Rendering: AppTheme, ActivityColorDot, DayActivityRow** — theme_apptheme_apptheme, components_activitycolordot_activitycolordot, calendario_daydetailsheet_dayactivityrow [INFERRED 0.95]
- **Plant Lifecycle: PiantaListView, OrtoDetailView, AggiungiPiantaView** — piante_piantalistview_piantalistview, orto_ortodetailview_ortodetailview, piante_aggiungipianta_aggiungipianta_view [INFERRED 0.85]

## Communities (83 total, 17 thin omitted)

### Community 0 - "Orto Data Model"
Cohesion: 0.06
Nodes (30): 1. Obiettivo, 2. Decisioni chiave, 3.1 Palette — nuovi token AppTheme, 3.2 Tipografia, 3. Sistema di design, 4. Struttura navigazione, 5.10 LoginView.swift / SignUpView.swift, 5.11 ContentView.swift (+22 more)

### Community 1 - "Calendar UI Views"
Cohesion: 0.07
Nodes (6): DayActivityRow, DayDetailSheet, DayDetailView, NaturalistaActivityRow, WeatherIcon, QuickJournalView

### Community 2 - "Day Detail & Activity"
Cohesion: 0.05
Nodes (13): DayDetailSheet.rescheduleActivity(_:), activitiesWithColors, authHeader, corsHeaders, ExtractRequest, LLMResponse, openRouterKey, payload (+5 more)

### Community 4 - "Admin Dashboard Functions"
Cohesion: 0.17
Nodes (22): Activity Color Coding Convention, Admin Role Pattern (JWT is_admin metadata), Admin Dashboard Edge Function, Extract Plant Care Edge Function, resolveColor() (extract-plant-care), LLM Agronomist System Prompt, addDays() Helper, Schedule Activities Edge Function (+14 more)

### Community 5 - "Core Data Models"
Cohesion: 0.25
Nodes (3): CLLocationManagerDelegate, NSObject, LocationHelper

### Community 6 - "Wiki & Knowledge Pipeline"
Cohesion: 0.08
Nodes (26): Codable, Wiki Note to Knowledge Base LLM Pipeline, Identifiable, AttivitaSuggerita, CodingKeys, attivitaSuggerite, color, createdAt (+18 more)

### Community 7 - "Community 7"
Cohesion: 0.10
Nodes (17): CodingKeys, color, createdAt, data, done, id, nome, note (+9 more)

### Community 8 - "Repository & Error Handling"
Cohesion: 0.12
Nodes (15): App Description (Italian), App Information, App Store Connect, App Store Icon Requirements, Apple Sign-In, Bundle ID, Garden Calendar iOS — App Store Connect Preparation, Going Live Checklist (+7 more)

### Community 9 - "Community 9"
Cohesion: 0.07
Nodes (12): Admin Dashboard (HTML), LoginView, SignUpView, ActivityColorDot, AppTheme, AppTheme (ActivityColorDot local copy), Activity Color System, AuthManager (+4 more)

### Community 10 - "Community 10"
Cohesion: 0.25
Nodes (6): Aggiunta eliminazione orto dalla vista modifica, code:swift (private func deleteOrto() {), Contesto tecnico rilevante, Cosa abbiamo fatto, Decisioni prese, Prossimi passi

### Community 11 - "Attività CodingKeys"
Cohesion: 0.33
Nodes (4): Backlog, Done, In Progress, TASKS — Garden Calendar iOS

### Community 12 - "LLM Plant Care Extraction"
Cohesion: 0.13
Nodes (14): Features, Feedback & Issues, Filters, 🌱 Garden Calendar, Garden Journal, Getting Started, Multiple Garden Plots, Plant Tracking (+6 more)

### Community 13 - "Settings & Theme Mode"
Cohesion: 0.20
Nodes (5): CalendarGridView, ViewMode, agenda, calendar, String

### Community 14 - "App Entry & Navigation"
Cohesion: 0.22
Nodes (9): code:bash (mkdir -p "/Users/keape/Library/Mobile Documents/com~apple~Cl), code:bash (# Uses old User-Agent to force TTF download instead of woff2), code:bash (FONTS_DIR="/Users/keape/Library/Mobile Documents/com~apple~C), code:bash (ls -lh "/Users/keape/Library/Mobile Documents/com~apple~Clou), code:bash (gem install xcodeproj 2>/dev/null || true), code:bash (PLIST="/Users/keape/Library/Mobile Documents/com~apple~Cloud), code:bash (cd "/Users/keape/Library/Mobile Documents/com~apple~CloudDoc), code:bash (cd "/Users/keape/Library/Mobile Documents/com~apple~CloudDoc) (+1 more)

### Community 16 - "VSCode Deno Config"
Cohesion: 0.43
Nodes (5): deno.enablePaths, deno.lint, deno.unstable, [typescript], editor.defaultFormatter

### Community 17 - "App Icon Assets"
Cohesion: 0.40
Nodes (4): images, info, author, version

### Community 18 - "Supabase Project Config"
Cohesion: 0.53
Nodes (4): name, organization_id, organization_slug, ref

### Community 19 - "Asset Catalog Metadata"
Cohesion: 0.40
Nodes (3): info, author, version

### Community 20 - "Extract Plant Imports"
Cohesion: 0.40
Nodes (3): imports, @supabase/functions-js, @supabase/supabase-js

### Community 21 - "Preview Asset Metadata"
Cohesion: 0.40
Nodes (3): info, author, version

### Community 22 - "Schedule Activities Imports"
Cohesion: 0.40
Nodes (3): imports, @supabase/functions-js, @supabase/supabase-js

### Community 26 - "Build & Package Config"
Cohesion: 0.67
Nodes (3): GardenCalendar Build Script, GardenCalendar Swift Package, supabase-swift Dependency

### Community 36 - "Community 36"
Cohesion: 0.40
Nodes (3): hooks, PostToolUse, PreToolUse

### Community 38 - "Community 38"
Cohesion: 0.29
Nodes (5): Contesto tecnico rilevante, Cosa abbiamo fatto, Decisioni prese, Prossimi passi, Test Simulator: NuovaAttivitaSheet e ModificaPiantaSheet

### Community 39 - "Community 39"
Cohesion: 0.25
Nodes (6): code:block1 (Volume: SimDevices  UUID: 62CB4BB8-A9C7-4185-9181-40D4B13E4E), Contesto tecnico rilevante, Cosa abbiamo fatto, Decisioni prese, Fix Simulator su Volume Lexar Esterno, Prossimi passi

### Community 40 - "Community 40"
Cohesion: 0.33
Nodes (4): Cosa abbiamo fatto, Debug simulatore iOS su disco esterno Lexar, Decisioni prese, Prossimi passi

### Community 41 - "Community 41"
Cohesion: 0.29
Nodes (5): Contesto tecnico rilevante, Cosa abbiamo fatto, Decisioni prese, Filtri calendario per orto, tipologia e pianta, Prossimi passi

### Community 42 - "Community 42"
Cohesion: 0.29
Nodes (5): Contesto tecnico rilevante, Cosa abbiamo fatto, Decisioni prese, Fix errore schema cache e decodifica date Supabase, Prossimi passi

### Community 43 - "Community 43"
Cohesion: 0.11
Nodes (16): Architettura, Casi limite, code:block1 (fetchAttivita(month)), code:swift (struct RescheduleAction {), code:swift (fetchNextIrrigation(piantaId: UUID, nome: String, after: Dat), Comportamento atteso, `computeRescheduling()` — filtri di ingresso, File modificati (+8 more)

### Community 44 - "Community 44"
Cohesion: 0.29
Nodes (5): Contesto tecnico rilevante, Cosa abbiamo fatto, Decisioni prese, Fix: Journal Entry non visibile dopo salvataggio, Prossimi passi

### Community 45 - "Community 45"
Cohesion: 0.29
Nodes (5): Contesto tecnico rilevante, Cosa abbiamo fatto, Decisioni prese, Miglioramenti UX vista Calendario, Prossimi passi

### Community 46 - "Community 46"
Cohesion: 0.29
Nodes (5): Contesto tecnico rilevante, Cosa abbiamo fatto, Decisioni prese, Fix geocoding città + modifica orto, Prossimi passi

### Community 47 - "Community 47"
Cohesion: 0.12
Nodes (13): code:swift (struct RescheduleAction {), code:bash (git add "GardenCalendar/Views/Calendario/CalendarView.swift"), code:bash (git add "GardenCalendar/Services/RainAdjuster.swift"), code:swift (func fetchNextIrrigation(piantaId: UUID, nome: String, after), code:swift (func markRainAbsorbed(id: UUID) async throws {), code:swift (func rescheduleWithRain(id: UUID, newDate: Date) async throw), code:bash (git add "GardenCalendar/Services/SupabaseRepository.swift"), code:swift (private func applyRainRescheduling() async {) (+5 more)

### Community 48 - "Community 48"
Cohesion: 0.29
Nodes (5): Contesto tecnico rilevante, Cosa abbiamo fatto, Creazione Orto con GPS e Geocoding, Decisioni prese, Prossimi passi

### Community 49 - "Community 49"
Cohesion: 0.24
Nodes (4): ActivityTaskRow, AttivitaRow, JournalEventRow, PiantaDetailView

### Community 50 - "Community 50"
Cohesion: 0.12
Nodes (14): 1. Database, 2. Swift Models & Repository, 3. Edge Function `schedule-activities`, 4. UI — `ModificaIntervalloSheet`, code:sql (alter table piante_coltivate), code:json ([), code:swift (let activityOverrides: [ActivityOverride]?), code:typescript (interface ScheduleRequest {) (+6 more)

### Community 51 - "Community 51"
Cohesion: 0.09
Nodes (19): Activity Interval Override Implementation Plan, code:sql (-- Migration: aggiunge colonna activity_overrides a piante_c), code:bash (git add "GardenCalendar/Views/Piante/ModificaIntervalloSheet), code:swift (import SwiftUI), code:bash (git add "GardenCalendar/Views/Piante/PiantaDetailView.swift"), code:bash (git add supabase/migrations/20260602000001_activity_override), code:swift (import Foundation), code:bash (git add GardenCalendar/Models/PiantaColtivata.swift) (+11 more)

### Community 52 - "Community 52"
Cohesion: 0.53
Nodes (3): PiantaCardView, PiantaListView, View

### Community 53 - "Community 53"
Cohesion: 0.29
Nodes (5): Build su Simulator e pulizia device CoreSimulator, Contesto tecnico rilevante, Cosa abbiamo fatto, Decisioni prese, Prossimi passi

### Community 55 - "Community 55"
Cohesion: 0.25
Nodes (7): GardenCalendarApp (@main entry point), AuthManager (referenced in ContentView), CalendarGridView, ContentView, LoginView, OrtoListView, SettingsView

### Community 56 - "Community 56"
Cohesion: 0.25
Nodes (5): Contesto tecnico rilevante, Cosa abbiamo fatto, Decisioni prese, Fix suggerimenti AI: nome pianta e contraddizione semina/trapianto, Prossimi passi

### Community 57 - "Community 57"
Cohesion: 0.29
Nodes (5): Contesto tecnico rilevante, Cosa abbiamo fatto, Decisioni prese, Fix pulsante Chiudi in DayDetailSheet, Prossimi passi

### Community 58 - "Community 58"
Cohesion: 0.06
Nodes (40): Encodable, Hashable, CodingKeys, createdAt, id, latitudine, longitudine, luogo (+32 more)

### Community 59 - "Community 59"
Cohesion: 0.24
Nodes (6): CaseIterable, SettingsView, ThemeMode, automatic, dark, light

### Community 60 - "Community 60"
Cohesion: 0.29
Nodes (5): Contesto tecnico rilevante, Cosa abbiamo fatto, Decisioni prese, Prossimi passi, Rain-aware irrigation rescheduling + weather icon fix

### Community 62 - "Community 62"
Cohesion: 0.29
Nodes (5): Contesto tecnico rilevante, Cosa abbiamo fatto, Decisioni prese, Icona pioggia visibilità + mm reali nel calendario, Prossimi passi

### Community 63 - "Community 63"
Cohesion: 0.50
Nodes (4): Plant Catalog with Activity Templates, AggiungiPiantaView, AggiungiPiantaView.generateTemplateActivities(for:), TemplateActivity

### Community 65 - "Community 65"
Cohesion: 0.12
Nodes (12): authHeader, baseDate, color, corsHeaders, endDate, plantLifespan, scheduledActivities, ScheduleRequest (+4 more)

### Community 66 - "Community 66"
Cohesion: 0.25
Nodes (8): code:swift (var body: some View {), code:swift (private var calendarContent: some View {), code:swift (private var calendarContent: some View {), code:swift (.background(AppTheme.backgroundCream)), code:swift (private func filterChip(label: String, isActive: Bool) -> so), code:bash (cd "/Users/keape/Library/Mobile Documents/com~apple~CloudDoc), code:bash (git add GardenCalendar/Views/Calendario/CalendarView.swift), Task 3: CalendarView — restyling + sheet → navigationDestination

### Community 67 - "Community 67"
Cohesion: 0.29
Nodes (7): code:swift (// MARK: Surfaces), code:swift (// MARK: - Font Helpers), code:swift (static let backgroundCream   = AppTheme.backgroundCream), code:bash (cd "/Users/keape/Library/Mobile Documents/com~apple~CloudDoc), code:bash (git add GardenCalendar/Theme/AppTheme.swift), code:swift (// MARK: Naturalista Surfaces), Task 2: AppTheme — new color tokens + Font helpers

### Community 68 - "Community 68"
Cohesion: 0.50
Nodes (4): code:bash (cd "/Users/keape/Library/Mobile Documents/com~apple~CloudDoc), code:bash (cd "/Users/keape/Library/Mobile Documents/com~apple~CloudDoc), code:bash (git add -A), Task 10: Final integration verification

### Community 70 - "Community 70"
Cohesion: 0.40
Nodes (5): code:swift (import SwiftUI), code:bash (cd "/Users/keape/Library/Mobile Documents/com~apple~CloudDoc), code:bash (grep -r "DayDetailSheet" "/Users/keape/Library/Mobile Docume), code:bash (git add GardenCalendar/Views/Calendario/DayDetailSheet.swift), Task 4: DayDetailView — rename, restructure as push view

### Community 71 - "Community 71"
Cohesion: 0.40
Nodes (5): code:swift (var body: some View {), code:swift (struct OrtoCardRow: View {), code:bash (cd "/Users/keape/Library/Mobile Documents/com~apple~CloudDoc), code:bash (git add GardenCalendar/Views/Orto/OrtoListView.swift), Task 5: OrtoListView restyling

### Community 72 - "Community 72"
Cohesion: 0.29
Nodes (5): code:swift (.listStyle(.insetGrouped)), code:swift (Text(pianta.nomePersonalizzato)), code:bash (cd "/Users/keape/Library/Mobile Documents/com~apple~CloudDoc), Naturalista UX Redesign — Implementation Plan, Task 6: OrtoDetailView restyling

### Community 73 - "Community 73"
Cohesion: 0.50
Nodes (4): code:swift (.background(AppTheme.cardBackground)), code:swift (Text(pianta.nomePersonalizzato)), code:bash (cd "/Users/keape/Library/Mobile Documents/com~apple~CloudDoc), Task 7: PiantaListView + PiantaDetailView restyling

### Community 74 - "Community 74"
Cohesion: 0.50
Nodes (4): code:swift (.scrollContentBackground(.hidden)), code:swift (Section(header: Text("Profilo").font(.dmSans(11, weight: .se), code:bash (cd "/Users/keape/Library/Mobile Documents/com~apple~CloudDoc), Task 8: SettingsView restyling

### Community 75 - "Community 75"
Cohesion: 0.50
Nodes (4): code:bash (cat "/Users/keape/Library/Mobile Documents/com~apple~CloudDo), code:bash (cd "/Users/keape/Library/Mobile Documents/com~apple~CloudDoc), code:bash (git add GardenCalendar/Views/Auth/LoginView.swift GardenCale), Task 9: LoginView + SignUpView restyling

### Community 76 - "Community 76"
Cohesion: 0.15
Nodes (13): CodingKey, CodingKeys, temperatureMin, time, CodingKeys, activities, color, dataSemina (+5 more)

### Community 77 - "Community 77"
Cohesion: 0.29
Nodes (5): Contesto tecnico rilevante, Cosa abbiamo fatto, Decisioni prese, Naturalista UX Redesign — implementazione completa, Prossimi passi

### Community 79 - "Community 79"
Cohesion: 0.25
Nodes (6): Rain-based Irrigation Adjustment, RainAdjuster.computeOverrides(activities:rainDays:), Date, OpenMeteoClient.fetchRainDays(...), OpenMeteoClient, RainAdjuster

### Community 83 - "Community 83"
Cohesion: 0.17
Nodes (10): LocalizedError, RainError, apiError, invalidURL, RepositoryError, invalidDate, SupabaseRepository.scheduleActivities(...), ScheduledTemplateActivity (+2 more)

### Community 84 - "Community 84"
Cohesion: 0.25
Nodes (8): Decodable, CacheEntry, precipitationSum, Daily, DailyWeather, OpenMeteoClient, OpenMeteoResponse, RescheduleAction

### Community 87 - "Community 87"
Cohesion: 0.22
Nodes (4): Orto, OrtoCardRow, OrtoListView, OrtoRow

## Knowledge Gaps
- **325 isolated node(s):** `PostToolUse`, `PreToolUse`, `corsHeaders`, `@supabase/functions-js`, `@supabase/supabase-js` (+320 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **17 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `SupabaseRepository` connect `Day Detail & Activity` to `Calendar UI Views`, `UI Theme & Color System`, `Community 9`, `Settings & Theme Mode`, `Community 49`, `Community 83`, `Community 52`, `Community 87`, `Community 58`, `Community 59`, `Community 63`?**
  _High betweenness centrality (0.104) - this node is a cross-community bridge._
- **Why does `Orto` connect `Community 58` to `Day Detail & Activity`, `Wiki & Knowledge Pipeline`, `Community 87`?**
  _High betweenness centrality (0.033) - this node is a cross-community bridge._
- **Why does `CalendarGridView` connect `Settings & Theme Mode` to `Community 9`, `Day Detail & Activity`, `Community 52`, `Calendar UI Views`?**
  _High betweenness centrality (0.033) - this node is a cross-community bridge._
- **Are the 10 inferred relationships involving `SupabaseRepository` (e.g. with `DayActivityRow.toggleDone()` and `DayDetailSheet.rescheduleActivity(_:)`) actually correct?**
  _`SupabaseRepository` has 10 INFERRED edges - model-reasoned connections that need verification._
- **What connects `PostToolUse`, `PreToolUse`, `corsHeaders` to the rest of the system?**
  _326 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Orto Data Model` be split into smaller, more focused modules?**
  _Cohesion score 0.0625 - nodes in this community are weakly interconnected._
- **Should `Calendar UI Views` be split into smaller, more focused modules?**
  _Cohesion score 0.06984126984126984 - nodes in this community are weakly interconnected._