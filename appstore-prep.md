# Garden Calendar iOS — App Store Connect Preparation

## Bundle ID
- **Name**: Garden Calendar
- **Bundle ID**: `com.keape.garden-calendar`
- **Team**: 4A5H2U7Q42
- **Platform**: iOS 18+

## App Store Connect

### How to create the app record
1. Go to https://appstoreconnect.apple.com → Apps → "+" → "New App"
2. Platform: iOS
3. Name: "Calendario Campo" (Italian) or "Garden Calendar" (English)
4. Primary language: Italian
5. Bundle ID: com.keape.garden-calendar (create new if needed)
6. SKU: GARDENCALENDAR_1_0
7. User Access: Full access

### App Information
- **Subtitle**: Organizza il tuo orto
- **Category**: Lifestyle (or Utilities)
- **Privacy Policy**: TBD (minimal — app doesn't collect personal data beyond email for login)

### Screenshots (required)
Prepare on 6.7" (iPhone 15 Pro Max / 16 Pro Max):
1. Calendario mensile con attività colorate
2. Dettaglio giorno con attività journal e AI
3. Lista orti con piante
4. Aggiunta pianta da catalogo
5. Quick journal entry (3-step wizard)
6. Impostazioni meteo/luogo

### App Description (Italian)
"Calendario Campo ti aiuta a organizzare il tuo orto. Registra le semine, ricevi promemoria per irrigazioni e concimazioni, tieni traccia della crescita delle tue piante. 
- Calendario interattivo con attività giornaliere
- Catalogo piante con cure suggerite
- Journal veloce per registrare le attività in giardino
- Regolazione automatica delle irrigazioni in base alla pioggia
- Supporto multi-orto (giardino, balcone, serra)
- Login per sincronizzare i dati tra i tuoi dispositivi"

### Keywords (Italian)
orto, giardino, piante, semina, irrigazione, calendario, coltivazione, ortaggi, giardinaggio, natura

### Support URL
https://garden-calendar.app (TBD — can use GitHub repo or Supabase project URL)

### Marketing URL
(optional)

### Apple Sign-In
Already configured in Supabase Auth. Enable in App Store Connect under Features.

## Version Info
- **Version**: 1.0.0
- **Build**: 1
- **Copyright**: 2026 Alessandro Capobianco

## App Store Icon Requirements
- 1024x1024px PNG (no transparency)
- Background: dark green (#1a3a1a) with white leaf icon
- Use the existing favicon.svg from the web version as inspiration

## TestFlight
After creating the app record:
1. Go to TestFlight → Testers → Add emails (your email + beta testers)
2. Build must be uploaded via Xcode (wait for Xcode phase)
3. Internal Testing: no Beta App Review needed

## Going Live Checklist
- [ ] App Store Connect app record created
- [ ] Bundle ID registered
- [ ] App icon (1024x1024)
- [ ] Screenshots (6.7" + 6.5" + iPad)
- [ ] Privacy policy URL
- [ ] App description + keywords
- [ ] First build uploaded via Xcode
- [ ] TestFlight internal testers invited
- [ ] Beta testing complete
- [ ] Submit for Review
