# Graph Report - garden-calendar-ios  (2026-05-29)

## Corpus Check
- 47 files · ~16,675 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 413 nodes · 516 edges · 41 communities (29 shown, 12 thin omitted)
- Extraction: 94% EXTRACTED · 6% INFERRED · 0% AMBIGUOUS · INFERRED: 31 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Orto Data Model|Orto Data Model]]
- [[_COMMUNITY_Calendar UI Views|Calendar UI Views]]
- [[_COMMUNITY_Day Detail & Activity|Day Detail & Activity]]
- [[_COMMUNITY_UI Theme & Color System|UI Theme & Color System]]
- [[_COMMUNITY_Admin Dashboard Functions|Admin Dashboard Functions]]
- [[_COMMUNITY_Core Data Models|Core Data Models]]
- [[_COMMUNITY_Wiki & Knowledge Pipeline|Wiki & Knowledge Pipeline]]
- [[_COMMUNITY_Rain & Irrigation Logic|Rain & Irrigation Logic]]
- [[_COMMUNITY_Repository & Error Handling|Repository & Error Handling]]
- [[_COMMUNITY_Authentication Views|Authentication Views]]
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

## God Nodes (most connected - your core abstractions)
1. `SupabaseRepository` - 40 edges
2. `CodingKeys` - 16 edges
3. `AppTheme` - 15 edges
4. `CodingKeys` - 14 edges
5. `CodingKeys` - 14 edges
6. `QuickJournalView` - 12 edges
7. `PiantaDetailView` - 12 edges
8. `CodingKeys` - 11 edges
9. `AuthManager` - 11 edges
10. `DayDetailSheet` - 10 edges

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

## Communities (41 total, 12 thin omitted)

### Community 0 - "Orto Data Model"
Cohesion: 0.05
Nodes (41): CodingKey, CodingKeys, createdAt, id, luogo, nome, updatedAt, userId (+33 more)

### Community 1 - "Calendar UI Views"
Cohesion: 0.08
Nodes (11): CalendarGridView, DayActivityRow, DayDetailSheet, AppTheme, AppTheme (ActivityColorDot local copy), WeatherIcon, Activity Color System, QuickJournalView (+3 more)

### Community 2 - "Day Detail & Activity"
Cohesion: 0.08
Nodes (3): DayDetailSheet.rescheduleActivity(_:), OrtoDetailView.deletePiante(at:), SupabaseRepository

### Community 3 - "UI Theme & Color System"
Cohesion: 0.13
Nodes (14): ActivityColorDot, Plant Catalog with Activity Templates, OrtoDetailView, PiantaRowView, AggiungiPiantaView, AggiungiPiantaView.generateTemplateActivities(for:), TemplateActivity, ActivityTaskRow (+6 more)

### Community 4 - "Admin Dashboard Functions"
Cohesion: 0.17
Nodes (22): Activity Color Coding Convention, Admin Role Pattern (JWT is_admin metadata), Admin Dashboard Edge Function, Extract Plant Care Edge Function, resolveColor() (extract-plant-care), LLM Agronomist System Prompt, addDays() Helper, Schedule Activities Edge Function (+14 more)

### Community 5 - "Core Data Models"
Cohesion: 0.09
Nodes (21): Encodable, CodingKeys, color, createdAt, data, done, id, nome (+13 more)

### Community 6 - "Wiki & Knowledge Pipeline"
Cohesion: 0.12
Nodes (4): Admin Dashboard (HTML), LoginView, SignUpView, AuthManager

### Community 7 - "Rain & Irrigation Logic"
Cohesion: 0.09
Nodes (20): Rain-based Irrigation Adjustment, Decodable, LocalizedError, CacheEntry, precipitationSum, RainAdjuster.computeOverrides(activities:rainDays:), Daily, Date (+12 more)

### Community 8 - "Repository & Error Handling"
Cohesion: 0.12
Nodes (15): App Description (Italian), App Information, App Store Connect, App Store Icon Requirements, Apple Sign-In, Bundle ID, Garden Calendar iOS — App Store Connect Preparation, Going Live Checklist (+7 more)

### Community 9 - "Authentication Views"
Cohesion: 0.17
Nodes (12): CodingKeys, createdAt, dataRaccoltaPrevista, dataSemina, fotoUrl, growthDays, id, nomePersonalizzato (+4 more)

### Community 10 - "Community 10"
Cohesion: 0.12
Nodes (12): authHeader, baseDate, color, corsHeaders, endDate, plantLifespan, scheduledActivities, ScheduleRequest (+4 more)

### Community 11 - "Attività CodingKeys"
Cohesion: 0.40
Nodes (4): Backlog, Done, In Progress, TASKS — Garden Calendar iOS

### Community 12 - "LLM Plant Care Extraction"
Cohesion: 0.17
Nodes (10): activitiesWithColors, authHeader, corsHeaders, ExtractRequest, LLMResponse, openRouterKey, payload, supabaseAdmin (+2 more)

### Community 13 - "Settings & Theme Mode"
Cohesion: 0.29
Nodes (6): CaseIterable, SettingsView, ThemeMode, automatic, dark, light

### Community 14 - "App Entry & Navigation"
Cohesion: 0.29
Nodes (7): GardenCalendarApp (@main entry point), AuthManager (referenced in ContentView), CalendarGridView, ContentView, LoginView, OrtoListView, SettingsView

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
Cohesion: 0.11
Nodes (19): Codable, Wiki Note to Knowledge Base LLM Pipeline, Hashable, Identifiable, Orto, Orto.Create, Orto.Update, PiantaColtivata (+11 more)

### Community 39 - "Community 39"
Cohesion: 0.29
Nodes (6): code:block1 (Volume: SimDevices  UUID: 62CB4BB8-A9C7-4185-9181-40D4B13E4E), Contesto tecnico rilevante, Cosa abbiamo fatto, Decisioni prese, Fix Simulator su Volume Lexar Esterno, Prossimi passi

### Community 40 - "Community 40"
Cohesion: 0.40
Nodes (4): Cosa abbiamo fatto, Debug simulatore iOS su disco esterno Lexar, Decisioni prese, Prossimi passi

## Knowledge Gaps
- **158 isolated node(s):** `build.sh script`, `PostToolUse`, `PreToolUse`, `ref`, `name` (+153 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **12 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `SupabaseRepository` connect `Day Detail & Activity` to `Orto Data Model`, `Calendar UI Views`, `UI Theme & Color System`, `Community 38`, `Rain & Irrigation Logic`, `Wiki & Knowledge Pipeline`, `Settings & Theme Mode`?**
  _High betweenness centrality (0.225) - this node is a cross-community bridge._
- **Why does `Orto` connect `Community 38` to `Day Detail & Activity`, `Core Data Models`?**
  _High betweenness centrality (0.082) - this node is a cross-community bridge._
- **Why does `Attivita` connect `Community 38` to `Community 10`, `Core Data Models`?**
  _High betweenness centrality (0.066) - this node is a cross-community bridge._
- **Are the 10 inferred relationships involving `SupabaseRepository` (e.g. with `DayActivityRow.toggleDone()` and `DayDetailSheet.rescheduleActivity(_:)`) actually correct?**
  _`SupabaseRepository` has 10 INFERRED edges - model-reasoned connections that need verification._
- **What connects `build.sh script`, `PostToolUse`, `PreToolUse` to the rest of the system?**
  _159 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Orto Data Model` be split into smaller, more focused modules?**
  _Cohesion score 0.05226480836236934 - nodes in this community are weakly interconnected._
- **Should `Calendar UI Views` be split into smaller, more focused modules?**
  _Cohesion score 0.0766488413547237 - nodes in this community are weakly interconnected._