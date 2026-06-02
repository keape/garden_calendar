import SwiftUI

/// Pallino colorato per attività di giardinaggio.
/// Dimensione configurabile, colore derivato da AppTheme.coloriAttivita.
struct ActivityColorDot: View {
    let activityName: String
    var size: CGFloat = 10

    var body: some View {
        Circle()
            .fill(AppTheme.color(for: activityName))
            .frame(width: size, height: size)
    }
}

// MARK: - AppTheme activity helpers

extension AppTheme {
    static let coloriAttivita: [String: Color] = [
        "semina": activityGreen,
        "trapianto": activityGreen,
        "raccolta": activityOrange,
        "irrigazione": activityBlue,
        "trattamento": activityRed,
        "concimazione": activityRed,
        "sarchiatura": activityGray,
        "potatura": activityGray,
        "innesto": activityGray,
        "bevuta": activityBlue,
    ]

    static func color(for activityName: String) -> Color {
        let lower = activityName.lowercased()
        if let c = coloriAttivita[lower] { return c }
        if lower.contains("raccolt") { return activityOrange }
        if lower.contains("irrigaz") || lower.contains("acqua") { return activityBlue }
        if lower.contains("concim") || lower.contains("fertil") || lower.contains("trattam") { return activityRed }
        if lower.contains("potatur") || lower.contains("sarchiat") || lower.contains("innest") { return activityGray }
        if lower.contains("semina") || lower.contains("trapianto") { return activityGreen }
        return activityPurple
    }
}

#Preview {
    HStack(spacing: 12) {
        ActivityColorDot(activityName: "semina", size: 14)
        ActivityColorDot(activityName: "raccolta", size: 14)
        ActivityColorDot(activityName: "irrigazione", size: 14)
        ActivityColorDot(activityName: "trattamento", size: 14)
        ActivityColorDot(activityName: "potatura", size: 14)
    }
    .padding()
}
