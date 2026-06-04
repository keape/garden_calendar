# 🌱 Garden Calendar

> The app for the wise gardener.

Garden Calendar is an iOS app that helps you manage your vegetable garden with precision. Track every plant across multiple garden plots, follow a smart activity calendar, and let the app automatically adjust your irrigation schedule when rain is on the way.

---

## Features

### Multiple Garden Plots
Create and manage multiple separate gardens (*orti*), each with its own location. GPS coordinates power the weather integration.

### Plant Tracking
Add every plant you grow with:
- Custom name
- Sowing date
- Growth cycle duration (in days)
- Automatic estimated harvest date
- Growth progress indicator (0–100%)
- Optional notes and photo URL

### Smart Activity Calendar
All your garden tasks appear on an interactive monthly calendar with color-coded dots:

| Color | Activity type |
|-------|--------------|
| 🟢 Green | Sowing / Transplanting |
| 🟠 Orange | Harvesting |
| 🔵 Blue | Irrigation |
| 🔴 Red | Treatment / Fertilization |
| ⚫ Gray | Pruning / Weeding |
| 🟣 Purple | Reminder |

Switch between **Calendar** and **Agenda** view. Tap any day to see full activity details and mark tasks as done.

### Rain-Aware Irrigation
The app fetches a 16-day precipitation forecast via [Open-Meteo](https://open-meteo.com/) for each garden's GPS location. When rain falls on or the day before a scheduled irrigation:
- The irrigation is automatically marked as absorbed by rain
- The next occurrence is rescheduled forward by the recurrence interval
- A toast notification tells you how many irrigations were moved

Rain badges (cloud icon + mm) appear directly on calendar days.

### Suggested Activities
When you add a plant from the built-in species catalog, the app generates a schedule of suggested activities (irrigation, fertilization, harvest, etc.) based on scientifically-informed timing offsets and recurrence intervals for each species. You can override defaults per plant.

### Garden Journal
Log any real-world event in seconds with the Quick Journal (3-step flow):
1. Select plant
2. Choose action (sowing, irrigation, harvesting, pruning, grafting…)
3. Pick date and add an optional note

Journal entries appear on the calendar alongside scheduled activities.

### Filters
On the calendar and agenda, filter by:
- Garden plot
- Activity type
- Individual plant

---

## Requirements

- iOS 17 or later
- iPhone (optimized for all screen sizes)
- An account (free registration via email)

---

## Privacy

- Your data is stored in your own Supabase-backed account and never shared with third parties.
- Location data is used only to fetch weather forecasts for your gardens and is never transmitted beyond the Open-Meteo weather API.
- No analytics or tracking SDKs are included.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Platform | SwiftUI (iOS 17+) |
| Backend / Auth | [Supabase](https://supabase.com) |
| Weather | [Open-Meteo](https://open-meteo.com) (free, no API key required) |
| Language | Swift 5.9 |

---

## Getting Started

1. Download the app and create a free account.
2. Tap **+** on the Gardens screen to add your first garden plot. If you grant location access, coordinates are filled automatically.
3. Open your garden and add your first plant. Choose a species from the catalog to get a ready-made activity schedule.
4. Open the Calendar tab — your activities are already there. Tap a day to mark tasks as done or add notes.
5. Log real events any time from the Journal button.

---

## Feedback & Issues

Found a bug or have a suggestion? Open an issue on this repository.
