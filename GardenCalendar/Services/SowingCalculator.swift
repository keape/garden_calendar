import Foundation

/// Finestra di semina/raccolta (o fioritura) calcolata per una pianta in una posizione specifica.
struct SowingWindow: Sendable {
    let seminaEsterno: [Int]
    let seminaInterno: [Int]
    /// Mesi di raccolta (piante da orto: ortaggio/aromatica/frutto).
    let raccolta: [Int]
    /// Mesi di fioritura (piante ornamentali: fiore).
    let fioritura: [Int]
}

/// Calcola la finestra di semina/raccolta di una pianta a partire dai suoi requisiti agronomici
/// e dalle normali climatiche mensili del giardino. Se mancano dati agronomici o climatici,
/// ricade sui mesi baseline salvati sulla pianta (validi per clima italiano/temperato).
enum SowingCalculator {
    static func compute(for plant: PlantKnowledge, normals: MonthlyClimateNormals?) -> SowingWindow {
        guard let normals,
              let tempGermMin = plant.tempGermMin,
              !normals.meanTemp.isEmpty else {
            // Fallback: baseline salvata (o array vuoti se assente)
            return SowingWindow(
                seminaEsterno: plant.seminaMesiEsterno,
                seminaInterno: plant.seminaMesiInterno,
                raccolta: plant.mesiRaccolta ?? [],
                fioritura: plant.mesiFioritura ?? []
            )
        }

        let tempTollMin = plant.tempTollMin ?? tempGermMin

        // Semina esterno: mese abbastanza caldo per germinare E oltre la soglia di tolleranza al freddo
        // (tMin medio del mese > soglia tolleranza, cioè niente gelate attese).
        let seminaEsterno = (1...12).filter { month in
            guard let mean = normals.meanTemp[month] else { return false }
            let minOk = normals.meanMinTemp[month].map { $0 > tempTollMin } ?? true
            return mean >= tempGermMin && minOk
        }.sorted()

        // Semina interno/protetta: solo vincolo di temperatura media (protetta dal gelo),
        // utile per anticipare 1-2 mesi rispetto all'esterno.
        let seminaInterno = (1...12).filter { month in
            guard let mean = normals.meanTemp[month] else { return false }
            return mean >= tempGermMin
        }.sorted()

        let growthMonths = max(1, Int((Double(plant.growthDays) / 30.0).rounded()))
        let esitoMesi = Set(seminaEsterno.map { shiftMonth($0, by: growthMonths) })

        let isOrnamentale = plant.tipo == .fiore
        let raccolta = isOrnamentale ? [] : esitoMesi.sorted()
        let fioritura = isOrnamentale ? esitoMesi.sorted() : []

        return SowingWindow(
            seminaEsterno: seminaEsterno,
            seminaInterno: seminaInterno,
            raccolta: raccolta,
            fioritura: fioritura
        )
    }

    private static func shiftMonth(_ month: Int, by delta: Int) -> Int {
        let zeroBased = (month - 1 + delta) % 12
        return (zeroBased < 0 ? zeroBased + 12 : zeroBased) + 1
    }
}
