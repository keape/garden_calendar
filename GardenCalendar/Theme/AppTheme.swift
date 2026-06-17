import SwiftUI
import UIKit

// MARK: - App Theme

enum AppTheme {

    // MARK: - Helper

    /// Wraps two RGB triples into a UIColor-backed adaptive Color.
    private static func adaptive(
        _ lr: CGFloat, _ lg: CGFloat, _ lb: CGFloat,
        dark dr: CGFloat, _ dg: CGFloat, _ db: CGFloat
    ) -> Color {
        Color(UIColor { tc in
            tc.userInterfaceStyle == .dark
                ? UIColor(red: dr, green: dg, blue: db, alpha: 1)
                : UIColor(red: lr, green: lg, blue: lb, alpha: 1)
        })
    }

    // MARK: Brand

    static let primaryGreen = adaptive(
        0.18, 0.55, 0.28,
        dark: 0.24, 0.70, 0.41
    )

    static let accentAmbra = Color(red: 1.0, green: 0.76, blue: 0.03)

    // MARK: Activity Colors (fixed – coloured indicators, not text-on-bg)

    static let activityGreen  = Color(red: 0.18, green: 0.62, blue: 0.30)
    static let activityOrange = Color(red: 1.00, green: 0.55, blue: 0.15)
    static let activityBlue   = Color(red: 0.12, green: 0.51, blue: 0.84)
    static let activityRed    = Color(red: 0.82, green: 0.18, blue: 0.18)
    static let activityGray   = Color(red: 0.55, green: 0.55, blue: 0.58)
    static let activityPurple = Color(red: 0.55, green: 0.30, blue: 0.80)

    // MARK: Weather & Nature

    static let rainBlue = Color(red: 0.20, green: 0.47, blue: 0.73)

    // MARK: Surfaces

    /// Card / input background.
    static let cardBackground = adaptive(
        1.000, 1.000, 1.000,
        dark: 0.118, 0.129, 0.098
    )

    /// Secondary card – already system-adaptive.
    static let cardSecondary = Color(.systemGray5)

    /// Main app background.
    static let backgroundCream = adaptive(
        0.973, 0.949, 0.910,          // warm cream  #F8F2E8
        dark: 0.102, 0.110, 0.086     // dark olive  #1A1C16
    )

    /// Calendar area / segmented bg.
    static let cardSecondaryWarm = adaptive(
        0.933, 0.910, 0.863,          // #EDE8DC
        dark: 0.133, 0.145, 0.110     // #22251C
    )

    // MARK: Text
    //
    // Light contrast targets (on backgroundCream):
    //   textPrimary   ~10:1  ✓
    //   textSecondary  ~7.5:1 ✓  (was 4.5:1)
    //
    // Dark contrast targets (on dark backgroundCream):
    //   textPrimary   ~11:1  ✓
    //   textSecondary  ~5.8:1 ✓

    static let textPrimary = adaptive(
        0.102, 0.227, 0.102,           // deep botanical green
        dark: 0.780, 0.878, 0.686      // light sage
    )

    static let textSecondary = adaptive(
        0.280, 0.320, 0.180,           // dark olive (was 0.420, 0.420, 0.290)
        dark: 0.561, 0.659, 0.439      // medium sage
    )

    // MARK: CTA

    /// Dark forest green – full-width CTA pill. Always white text on top.
    static let ctaDarkGreen = adaptive(
        0.180, 0.239, 0.180,           // #2E3D2E  white text ~12:1
        dark: 0.227, 0.431, 0.271      // #3A6E45  white text  ~6:1
    )

    // MARK: Activity Color Map

    static func colorForActivity(_ category: String) -> Color {
        switch category.lowercased() {
        case "verde", "green":                                       return activityGreen
        case "arancione", "orange":                                  return activityOrange
        case "blu", "blue":                                          return activityBlue
        case "rosso", "red":                                         return activityRed
        case "grigio", "gray":                                       return activityGray
        case "viola", "purple":                                      return activityPurple
        case "piantare", "seminare", "semina", "piantagione":        return activityGreen
        case "raccogliere", "raccolta", "trapiantare", "trapianto":  return activityOrange
        case "irrigazione", "acqua", "bagnare", "manutenzione":      return activityBlue
        case "emergenza", "fitosanitario", "malattia", "parassiti":  return activityRed
        case "completato", "fatto", "neutro":                        return activityGray
        case "promemoria", "nota", "personale":                      return activityPurple
        default:                                                     return activityGray
        }
    }
}

// MARK: - Color Extension

extension Color {
    static let primaryGreen      = AppTheme.primaryGreen
    static let accentAmbra       = AppTheme.accentAmbra
    static let activityGreen     = AppTheme.activityGreen
    static let activityOrange    = AppTheme.activityOrange
    static let activityBlue      = AppTheme.activityBlue
    static let activityRed       = AppTheme.activityRed
    static let activityGray      = AppTheme.activityGray
    static let activityPurple    = AppTheme.activityPurple
    static let rainBlue          = AppTheme.rainBlue
    static let cardBackground    = AppTheme.cardBackground
    static let cardSecondary     = AppTheme.cardSecondary
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
