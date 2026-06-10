# Graph Report - garden-calendar-ios  (2026-06-04)

## Corpus Check
- 64 files · ~26,698 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 592 nodes · 702 edges · 59 communities (45 shown, 14 thin omitted)
- Extraction: 95% EXTRACTED · 5% INFERRED · 0% AMBIGUOUS · INFERRED: 34 edges (avg confidence: 0.84)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `ec4c8bd2`
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
- [[_COMMUNITY_Community 56|Community 56]]
- [[_COMMUNITY_Community 57|Community 57]]
- [[_COMMUNITY_Community 58|Community 58]]
- [[_COMMUNITY_Community 59|Community 59]]

## God Nodes (most connected - your core abstractions)
1. `SupabaseRepository` - 47 edges
2. `CodingKeys` - 18 edges
3. `CodingKeys` - 16 edges
4. `AppTheme` - 15 edges
5. `CodingKeys` - 14 edges
6. `OrtoDetailView` - 14 edges
7. `DayDetailSheet` - 13 edges
8. `PiantaDetailView` - 13 edges
9. `QuickJournalView` - 12 edges
10. `CalendarGridView` - 12 edges

## Surprising Connections (you probably didn't know these)
- `Admin Dashboard (HTML)` --references--> `SupabaseRepository`  [INFERRED]
  admin-dashboard.html → GardenCalendar/Services/SupabaseRepository.swift
- `Admin Dashboard (HTML)` --references--> `AuthManager`  [INFERRED]
  admin-dashboard.html → GardenCalendar/Services/AuthManager.swift
- `Forward Scheduling Logic` --references--> `Attivita Table (Calendar Activities)`  [INFERRED]
  supabase/functions/schedule-activities/index.ts → supabase-schema.sql
- `App Store Connect Preparation` --references--> `AuthManager.signInWithApple(idToken:)`  [EXTRACTED]
  appstore-prep.md → GardenCalendar/Services/AuthManager.swift
- `SupabaseConfig` --references--> `Linked Supabase Project (kusprtmfxrsnjycyzlgs)`  [INFERRED]
  GardenCalendar/SupabaseConfig.swift → supabase/.temp/linked-project.json

## Hyperedges (group relationships)
- **Wiki Note → LLM Extraction → Plant Knowledge Pipeline** — supabase_schema_wiki_notes, functions_extract_plant_care_index, openrouter_deepseek, supabase_schema_plant_knowledge [EXTRACTED 1.00]
- **Plant Sowing → Schedule Activities → Calendar** — supabase_schema_piante_coltivate, functions_schedule_activities_index, supabase_schema_attivita [EXTRACTED 1.00]
- **iOS Auth-Gated Navigation Pattern** — gardencalendar_contentview_authmanager, gardencalendar_contentview_contentview, gardencalendar_contentview_loginview [EXTRACTED 1.00]
- **Authentication Flow: Login, SignUp, AuthManager** — auth_loginview_loginview, auth_signupview_signupview, services_authmanager_authmanager [EXTRACTED 1.00]
- **Activity Color Rendering: AppTheme, ActivityColorDot, DayActivityRow** — theme_apptheme_apptheme, components_activitycolordot_activitycolordot, calendario_daydetailsheet_dayactivityrow [INFERRED 0.95]
- **Plant Lifecycle: PiantaListView, OrtoDetailView, AggiungiPiantaView** — piante_piantalistview_piantalistview, orto_ortodetailview_ortodetailview, piante_aggiungipianta_aggiungipianta_view [INFERRED 0.85]

## Communities (59 total, 14 thin omitted)

### Community 1 - "Calendar UI Views"
Cohesion: 0.05
Nodes (14): Admin Dashboard (HTML), LoginView, SignUpView, DayActivityRow, DayDetailSheet, AppTheme, AppTheme (ActivityColorDot local copy), WeatherIcon (+6 more)

### Community 2 - "Day Detail & Activity"
Cohesion: 0.06
Nodes (4): DayDetailSheet.rescheduleActivity(_:), payload, OrtoDetailView.deletePiante(at:), SupabaseRepository

### Community 3 - "UI Theme & Color System"
Cohesion: 0.06
Nodes (23): ActivityColorDot, Plant Catalog with Activity Templates, GardenCalendarApp (@main entry point), AuthManager (referenced in ContentView), CalendarGridView, ContentView, LoginView, OrtoListView (+15 more)

### Community 4 - "Admin Dashboard Functions"
Cohesion: 0.17
Nodes (22): Activity Color Coding Convention, Admin Role Pattern (JWT is_admin metadata), Admin Dashboard Edge Function, Extract Plant Care Edge Function, resolveColor() (extract-plant-care), LLM Agronomist System Prompt, addDays() Helper, Schedule Activities Edge Function (+14 more)

### Community 5 - "Core Data Models"
Cohesion: 0.29
Nodes (3): CLLocationManagerDelegate, NSObject, LocationHelper

### Community 6 - "Wiki & Knowledge Pipeline"
Cohesion: 0.17
Nodes (12): CodingKeys, attivitaSuggerite, color, createdAt, growthDays, id, nome, offsetDays (+4 more)

### Community 7 - "Community 7"
Cohesion: 0.14
Nodes (14): CodingKeys, color, createdAt, data, done, id, nome, note (+6 more)

### Community 8 - "Repository & Error Handling"
Cohesion: 0.12
Nodes (15): App Description (Italian), App Information, App Store Connect, App Store Icon Requirements, Apple Sign-In, Bundle ID, Garden Calendar iOS — App Store Connect Preparation, Going Live Checklist (+7 more)

### Community 9 - "Community 9"
Cohesion: 0.33
Nodes (5): SettingsView, ThemeMode, automatic, dark, light

### Community 10 - "Community 10"
Cohesion: 0.29
Nodes (6): Aggiunta eliminazione orto dalla vista modifica, code:swift (private func deleteOrto() {), Contesto tecnico rilevante, Cosa abbiamo fatto, Decisioni prese, Prossimi passi

### Community 11 - "Attività CodingKeys"
Cohesion: 0.40
Nodes (4): Backlog, Done, In Progress, TASKS — Garden Calendar iOS

### Community 12 - "LLM Plant Care Extraction"
Cohesion: 0.18
Nodes (9): activitiesWithColors, authHeader, corsHeaders, ExtractRequest, LLMResponse, openRouterKey, supabaseAdmin, token (+1 more)

### Community 14 - "App Entry & Navigation"
Cohesion: 0.40
Nodes (4): ViewMode, agenda, calendar, CaseIterable

### Community 16 - "VSCode Deno Config"
Cohesion: 0.33
Nodes (5): deno.enablePaths, deno.lint, deno.unstable, [typescript], editor.defaultFormatter

### Community 17 - "App Icon Assets"
Cohesion: 0.40
Nodes (4): images, info, author, version

### Community 18 - "Supabase Project Config"
Cohesion: 0.40
Nodes (4): name, organization_id, organization_slug, ref

### Community 19 - "Asset Catalog Metadata"
Cohesion: 0.50
Nodes (3): info, author, version

### Community 20 - "Extract Plant Imports"
Cohesion: 0.50
Nodes (3): imports, @supabase/functions-js, @supabase/supabase-js

### Community 21 - "Preview Asset Metadata"
Cohesion: 0.50
Nodes (3): info, author, version

### Community 22 - "Schedule Activities Imports"
Cohesion: 0.50
Nodes (3): imports, @supabase/functions-js, @supabase/supabase-js

### Community 26 - "Build & Package Config"
Cohesion: 0.67
Nodes (3): GardenCalendar Build Script, GardenCalendar Swift Package, supabase-swift Dependency

### Community 36 - "Community 36"
Cohesion: 0.50
Nodes (3): hooks, PostToolUse, PreToolUse

### Community 38 - "Community 38"
Cohesion: 0.10
Nodes (19): LocalizedError, RainError, apiError, invalidURL, CodingKeys, activities, color, dataSemina (+11 more)

### Community 39 - "Community 39"
Cohesion: 0.29
Nodes (6): code:block1 (Volume: SimDevices  UUID: 62CB4BB8-A9C7-4185-9181-40D4B13E4E), Contesto tecnico rilevante, Cosa abbiamo fatto, Decisioni prese, Fix Simulator su Volume Lexar Esterno, Prossimi passi

### Community 40 - "Community 40"
Cohesion: 0.40
Nodes (4): Cosa abbiamo fatto, Debug simulatore iOS su disco esterno Lexar, Decisioni prese, Prossimi passi

### Community 41 - "Community 41"
Cohesion: 0.33
Nodes (5): Contesto tecnico rilevante, Cosa abbiamo fatto, Decisioni prese, Filtri calendario per orto, tipologia e pianta, Prossimi passi

### Community 42 - "Community 42"
Cohesion: 0.33
Nodes (5): Contesto tecnico rilevante, Cosa abbiamo fatto, Decisioni prese, Fix errore schema cache e decodifica date Supabase, Prossimi passi

### Community 43 - "Community 43"
Cohesion: 0.12
Nodes (16): Architettura, Casi limite, code:block1 (fetchAttivita(month)), code:swift (struct RescheduleAction {), code:swift (fetchNextIrrigation(piantaId: UUID, nome: String, after: Dat), Comportamento atteso, `computeRescheduling()` — filtri di ingresso, File modificati (+8 more)

### Community 44 - "Community 44"
Cohesion: 0.33
Nodes (5): Contesto tecnico rilevante, Cosa abbiamo fatto, Decisioni prese, Fix: Journal Entry non visibile dopo salvataggio, Prossimi passi

### Community 45 - "Community 45"
Cohesion: 0.33
Nodes (5): Contesto tecnico rilevante, Cosa abbiamo fatto, Decisioni prese, Miglioramenti UX vista Calendario, Prossimi passi

### Community 46 - "Community 46"
Cohesion: 0.33
Nodes (5): Contesto tecnico rilevante, Cosa abbiamo fatto, Decisioni prese, Fix geocoding città + modifica orto, Prossimi passi

### Community 47 - "Community 47"
Cohesion: 0.13
Nodes (13): code:swift (struct RescheduleAction {), code:bash (git add "GardenCalendar/Views/Calendario/CalendarView.swift"), code:bash (git add "GardenCalendar/Services/RainAdjuster.swift"), code:swift (func fetchNextIrrigation(piantaId: UUID, nome: String, after), code:swift (func markRainAbsorbed(id: UUID) async throws {), code:swift (func rescheduleWithRain(id: UUID, newDate: Date) async throw), code:bash (git add "GardenCalendar/Services/SupabaseRepository.swift"), code:swift (private func applyRainRescheduling() async {) (+5 more)

### Community 48 - "Community 48"
Cohesion: 0.33
Nodes (5): Contesto tecnico rilevante, Cosa abbiamo fatto, Creazione Orto con GPS e Geocoding, Decisioni prese, Prossimi passi

### Community 49 - "Community 49"
Cohesion: 0.07
Nodes (34): Codable, Wiki Note to Knowledge Base LLM Pipeline, Encodable, Hashable, Identifiable, Create, Update, CodingKeys (+26 more)

### Community 50 - "Community 50"
Cohesion: 0.13
Nodes (14): 1. Database, 2. Swift Models & Repository, 3. Edge Function `schedule-activities`, 4. UI — `ModificaIntervalloSheet`, code:sql (alter table piante_coltivate), code:json ([), code:swift (let activityOverrides: [ActivityOverride]?), code:typescript (interface ScheduleRequest {) (+6 more)

### Community 51 - "Community 51"
Cohesion: 0.10
Nodes (19): Activity Interval Override Implementation Plan, code:sql (-- Migration: aggiunge colonna activity_overrides a piante_c), code:bash (git add "GardenCalendar/Views/Piante/ModificaIntervalloSheet), code:swift (import SwiftUI), code:bash (git add "GardenCalendar/Views/Piante/PiantaDetailView.swift"), code:bash (git add supabase/migrations/20260602000001_activity_override), code:swift (import Foundation), code:bash (git add GardenCalendar/Models/PiantaColtivata.swift) (+11 more)

### Community 52 - "Community 52"
Cohesion: 0.12
Nodes (12): authHeader, baseDate, color, corsHeaders, endDate, plantLifespan, scheduledActivities, ScheduleRequest (+4 more)

### Community 53 - "Community 53"
Cohesion: 0.33
Nodes (5): Build su Simulator e pulizia device CoreSimulator, Contesto tecnico rilevante, Cosa abbiamo fatto, Decisioni prese, Prossimi passi

### Community 54 - "Community 54"
Cohesion: 0.12
Nodes (13): Rain-based Irrigation Adjustment, Decodable, CacheEntry, precipitationSum, RainAdjuster.computeOverrides(activities:rainDays:), Daily, Date, OpenMeteoClient.fetchRainDays(...) (+5 more)

### Community 56 - "Community 56"
Cohesion: 0.29
Nodes (5): Contesto tecnico rilevante, Cosa abbiamo fatto, Decisioni prese, Fix suggerimenti AI: nome pianta e contraddizione semina/trapianto, Prossimi passi

### Community 57 - "Community 57"
Cohesion: 0.33
Nodes (5): Contesto tecnico rilevante, Cosa abbiamo fatto, Decisioni prese, Fix pulsante Chiudi in DayDetailSheet, Prossimi passi

### Community 58 - "Community 58"
Cohesion: 0.20
Nodes (10): CodingKey, CodingKeys, createdAt, id, markdownContent, processed, slug, updatedAt (+2 more)

### Community 59 - "Community 59"
Cohesion: 0.12
Nodes (16): CodingKeys, activityOverrides, createdAt, dataRaccoltaPrevista, dataSemina, fotoUrl, growthDays, id (+8 more)

## Knowledge Gaps
- **245 isolated node(s):** `build.sh script`, `PostToolUse`, `PreToolUse`, `ref`, `name` (+240 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **14 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `SupabaseRepository` connect `Day Detail & Activity` to `Calendar UI Views`, `UI Theme & Color System`, `Community 38`, `Community 9`, `Settings & Theme Mode`, `Community 49`, `Community 54`?**
  _High betweenness centrality (0.161) - this node is a cross-community bridge._
- **Why does `Orto` connect `Community 49` to `Day Detail & Activity`?**
  _High betweenness centrality (0.052) - this node is a cross-community bridge._
- **Why does `Attivita` connect `Community 49` to `Community 52`?**
  _High betweenness centrality (0.037) - this node is a cross-community bridge._
- **Are the 10 inferred relationships involving `SupabaseRepository` (e.g. with `DayActivityRow.toggleDone()` and `DayDetailSheet.rescheduleActivity(_:)`) actually correct?**
  _`SupabaseRepository` has 10 INFERRED edges - model-reasoned connections that need verification._
- **What connects `build.sh script`, `PostToolUse`, `PreToolUse` to the rest of the system?**
  _246 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Calendar UI Views` be split into smaller, more focused modules?**
  _Cohesion score 0.050170068027210885 - nodes in this community are weakly interconnected._
- **Should `Day Detail & Activity` be split into smaller, more focused modules?**
  _Cohesion score 0.06417112299465241 - nodes in this community are weakly interconnected._