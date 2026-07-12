# Merge PR #2 (5 feature) e pulizia branch

**Data:** 2026-06-10
**Progetto:** garden-calendar-ios
**Durata:** media
**Tipo:** feature
**Status:** complete
**Tags:** [git, github, widgetkit, supabase, xcode]

## Cosa abbiamo fatto

- Mergiata PR #2 (notifiche locali, avviso gelata, widget home screen, storico raccolti, cache offline) in main → commit 0ed35c7
- Cancellato branch remoto `claude/practical-liskov-144414` da GitHub
- Aggiornato main locale: bloccato da modifiche Xcode non committate (icona app + DEVELOPMENT_TEAM nel pbxproj) → stash, ff-merge, pop
- Risolto conflitto pbxproj: tenuto DEVELOPMENT_TEAM 4A5H2U7Q42 e CODE_SIGN_ENTITLEMENTS, rimosso CODE_SIGNING_REQUIRED=NO
- Spiegato: i 2 branch locali residui appartengono a worktree di sessioni Claude Code attive, spariscono chiudendole

## Decisioni prese

- Rimosso `CODE_SIGNING_REQUIRED = NO` dal pbxproj: era hack per build CI senza firma, inutile ora che c'è il team di sviluppo reale
- Mantenuto `CODE_SIGN_ENTITLEMENTS` su entrambe le configurazioni: necessario per App Group del widget

## Prossimi passi

- Committare modifiche in staging su main (icona app, AppIcon.png, ExportOptions.plist) — in attesa di ok
- Pulire file duplicati iCloud Drive "nome 2.swift" sparsi nel repo — in attesa di ok

## Contesto tecnico rilevante

- `GardenCalendar.xcodeproj/project.pbxproj` — conflitto stash pop risolto a mano
- `git push origin --delete claude/practical-liskov-144414` per branch remoto
- main = origin/main = 0ed35c7
