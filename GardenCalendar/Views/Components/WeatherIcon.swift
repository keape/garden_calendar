import SwiftUI

/// Icona meteo basata su SF Symbols.
/// Mostra il simbolo appropriato per le condizioni meteorologiche,
/// opzionalmente colorato in base alla pioggia prevista.
struct WeatherIcon: View {
    /// Numero di giorni piovosi previsti (0 = sereno, >0 = pioggia progressiva)
    var rainDays: Int = 0
    var size: CGFloat = 24

    private var iconName: String {
        switch rainDays {
        case 0:
            return "sun.max.fill"
        case 1:
            return "cloud.sun.fill"
        case 2:
            return "cloud.fill"
        case 3:
            return "cloud.rain.fill"
        case 4:
            return "cloud.heavyrain.fill"
        case 5...:
            return "cloud.bolt.rain.fill"
        default:
            return "cloud.fill"
        }
    }

    private var iconColor: Color {
        switch rainDays {
        case 0:
            return .orange
        case 1:
            return .yellow
        case 2:
            return .gray
        case 3...:
            return AppTheme.rainBlue
        default:
            return .secondary
        }
    }

    var body: some View {
        Image(systemName: iconName)
            .font(.system(size: size))
            .symbolRenderingMode(.monochrome)
            .foregroundStyle(iconColor)
    }
}

#Preview {
    VStack(spacing: 12) {
        WeatherIcon(rainDays: 0, size: 32)
        WeatherIcon(rainDays: 1, size: 32)
        WeatherIcon(rainDays: 2, size: 32)
        WeatherIcon(rainDays: 3, size: 32)
        WeatherIcon(rainDays: 5, size: 32)
    }
    .padding()
}
