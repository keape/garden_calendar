import Foundation
import SwiftUI

/// Mappa il nome di una pianta a un'emoji identificativa.
/// Match per keyword sul nome in minuscolo; fallback generico 🌱.
func emojiForPlant(_ nome: String) -> String {
    let n = nome.lowercased()
    // Ordine: le keyword più specifiche prima di quelle generiche.
    let table: [(String, String)] = [
        ("pomodor", "🍅"),
        ("basilic", "🌿"),
        ("lattug", "🥬"),
        ("insalat", "🥬"),
        ("spinac", "🥬"),
        ("zucchin", "🥒"),
        ("zucca", "🎃"),
        ("cetriol", "🥒"),
        ("fragol", "🍓"),
        ("carot", "🥕"),
        ("peperonc", "🌶️"),
        ("peperon", "🫑"),
        ("melanzan", "🍆"),
        ("cipoll", "🧅"),
        ("aglio", "🧄"),
        ("patat", "🥔"),
        ("mais", "🌽"),
        ("granotur", "🌽"),
        ("fagiol", "🫘"),
        ("pisell", "🫛"),
        ("broccol", "🥦"),
        ("cavol", "🥦"),
        ("funghi", "🍄"),
        ("fungo", "🍄"),
        ("uva", "🍇"),
        ("limon", "🍋"),
        ("arance", "🍊"),
        ("arancio", "🍊"),
        ("mele", "🍎"),
        ("melo", "🍎"),
        ("pera", "🍐"),
        ("pero", "🍐"),
        ("pesc", "🍑"),
        ("cilieg", "🍒"),
        ("anguri", "🍉"),
        ("melon", "🍈"),
        ("olivo", "🫒"),
        ("oliv", "🫒"),
        ("rosa", "🌹"),
        ("tulipan", "🌷"),
        ("girasol", "🌻"),
        ("erbe", "🌿"),
        ("menta", "🌿"),
        ("rosmarin", "🌿"),
        ("salvia", "🌿"),
        ("prezzemol", "🌿"),
        ("fiore", "🌸"),
        ("fiori", "🌸"),
        ("cactus", "🌵"),
        ("albero", "🌳"),
        ("pianta grassa", "🌵"),
    ]
    for (key, emoji) in table where n.contains(key) {
        return emoji
    }
    return "🌱"
}

/// Icona pianta: foto custom (F5) se presente, altrimenti emoji automatica (F4).
/// Ordine fallback: foto → emoji → 🌱.
struct PlantIconView: View {
    let pianta: PiantaColtivata
    var size: CGFloat = 40

    var body: some View {
        if let urlString = pianta.fotoUrl, let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    emoji
                default:
                    ProgressView()
                }
            }
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: size * 0.22))
        } else {
            emoji
        }
    }

    private var emoji: some View {
        Text(emojiForPlant(pianta.nomePersonalizzato))
            .font(.system(size: size))
    }
}
