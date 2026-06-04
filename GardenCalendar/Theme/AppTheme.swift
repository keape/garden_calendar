import SwiftUI

// MARK: - App Theme

/// Centralized color palette for Garden Calendar.
/// All colors are defined once here and accessed via `AppTheme.*` or the `Color` extension.
enum AppTheme {
    // MARK: Brand

    /// Primary green — used for navigation, buttons, selected tabs.
    static let primaryGreen = Color(red: 0.18, green: 0.55, blue: 0.28)

    /// Warm amber accent — used for journal entries, highlights.
    static let accentAmbra = Color(red: 1.0, green: 0.76, blue: 0.03)

    // MARK: Activity Colors

    /// Green — piantare / seminare.
    static let activityGreen = Color(red: 0.18, green: 0.62, blue: 0.30)

    /// Orange — raccogliere / trapiantare.
    static let activityOrange = Color(red: 1.0, green: 0.55, blue: 0.15)

    /// Blue — irrigazione / manutenzione.
    static let activityBlue = Color(red: 0.12, green: 0.51, blue: 0.84)

    /// Red — emergenze / fitosanitario.
    static let activityRed = Color(red: 0.82, green: 0.18, blue: 0.18)

    /// Gray — attività completate / neutrali.
    static let activityGray = Color(red: 0.55, green: 0.55, blue: 0.58)

    /// Purple — promemoria / note personali.
    static let activityPurple = Color(red: 0.55, green: 0.30, blue: 0.80)

    // MARK: Weather & Nature

    /// Rain blue — pioggia / irrigazione.
    static let rainBlue = Color(red: 0.20, green: 0.47, blue: 0.73)

    // MARK: Surfaces

    /// Card and input background.
    static let cardBackground = Color.white

    /// Secondary card / login screen background.
    static let cardSecondary = Color(.systemGray5)

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

    // MARK: Activity Color Map

    /// Returns an activity color for a given category string (case-insensitive).
    /// Falls back to `activityGray` for unknown categories.
    static func colorForActivity(_ category: String) -> Color {
        switch category.lowercased() {
        // Nomi colore (usati nella legenda)
        case "verde", "green":
            return activityGreen
        case "arancione", "orange":
            return activityOrange
        case "blu", "blue":
            return activityBlue
        case "rosso", "red":
            return activityRed
        case "grigio", "gray":
            return activityGray
        case "viola", "purple":
            return activityPurple
        // Nomi attività
        case "piantare", "seminare", "semina", "piantagione":
            return activityGreen
        case "raccogliere", "raccolta", "trapiantare", "trapianto":
            return activityOrange
        case "irrigazione", "acqua", "bagnare", "manutenzione":
            return activityBlue
        case "emergenza", "fitosanitario", "malattia", "parassiti":
            return activityRed
        case "completato", "fatto", "neutro":
            return activityGray
        case "promemoria", "nota", "personale":
            return activityPurple
        default:
            return activityGray
        }
    }
}

// MARK: - Color Extension

extension Color {
    /// Primary brand green.
    static let primaryGreen = AppTheme.primaryGreen

    /// Warm amber accent.
    static let accentAmbra = AppTheme.accentAmbra

    /// Activity green (planting / sowing).
    static let activityGreen = AppTheme.activityGreen

    /// Activity orange (harvest / transplant).
    static let activityOrange = AppTheme.activityOrange

    /// Activity blue (watering / maintenance).
    static let activityBlue = AppTheme.activityBlue

    /// Activity red (emergencies / phytosanitary).
    static let activityRed = AppTheme.activityRed

    /// Activity gray (completed / neutral).
    static let activityGray = AppTheme.activityGray

    /// Activity purple (reminders / personal notes).
    static let activityPurple = AppTheme.activityPurple

    /// Rain / watering blue.
    static let rainBlue = AppTheme.rainBlue

    /// Card / input background.
    static let cardBackground = AppTheme.cardBackground

    /// Secondary card / login background.
    static let cardSecondary = AppTheme.cardSecondary

    static let backgroundCream   = AppTheme.backgroundCream
    static let cardSecondaryWarm = AppTheme.cardSecondaryWarm
    static let textPrimary       = AppTheme.textPrimary
    static let textSecondary     = AppTheme.textSecondary
    static let ctaDarkGreen      = AppTheme.ctaDarkGreen
}

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
