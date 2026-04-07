//
//  ExportService.swift
//  CycleOne
//
//  Created by Antigravity on 3/23/26.
//

import CoreData
import Foundation
import OSLog

class ExportService {
    static let shared = ExportService()

    private init() {}

    private func csvField(_ value: String) -> String {
        var normalized = value
            .replacingOccurrences(of: "\r\n", with: " ")
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\r", with: " ")

        // Prevent CSV formula injection in spreadsheet apps.
        if let first = normalized.first, "=+-@".contains(first) {
            normalized = "'" + normalized
        }

        let escaped = normalized.replacingOccurrences(of: "\"", with: "\"\"")
        return "\"\(escaped)\""
    }

    static func symptomsText(from symptoms: NSSet?) -> String {
        (symptoms as? Set<Symptom>)?.compactMap { symptom in
            let displayName = SymptomType.localizedName(
                forID: symptom.id,
                fallbackName: symptom.name ?? ""
            )
            return displayName.isEmpty ? nil : displayName
        }
        .joined(separator: ";") ?? ""
    }

    func generateCSV(context: NSManagedObjectContext) -> URL? {
        let request: NSFetchRequest<DayLog> = DayLog.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \DayLog.date, ascending: false)]

        do {
            let logs = try context.fetch(request)
            let header = L10n.string(
                "export.csv.header",
                default: "Date,Flow,Pain,Mood,Energy,Symptoms,Notes"
            )
            var csvString = header + "\n"

            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short

            for log in logs {
                guard let logDate = log.date else {
                    Logger.storage.error("Skipping export row with missing date")
                    continue
                }
                let dateStr = dateFormatter.string(from: logDate)
                let flowStr = FlowLevel(rawValue: log.flowLevel)?.description ?? ""
                let painStr = "\(log.painLevel)"
                let moodStr = Mood(rawValue: log.mood)?.description ?? ""
                let energyStr = EnergyLevel(rawValue: log.energyLevel)?.description ?? ""

                let symptoms = Self.symptomsText(from: log.symptoms)
                let notes = log.notes ?? ""

                let row = [dateStr, flowStr, painStr, moodStr, energyStr, symptoms, notes]
                    .map(csvField)
                    .joined(separator: ",")
                csvString += row + "\n"
            }

            let fileDateFormatter = DateFormatter()
            fileDateFormatter.dateFormat = "yyyyMMdd"
            let fileName = "CycleOne_Export_\(fileDateFormatter.string(from: Date())).csv"
            let path = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

            try csvString.write(to: path, atomically: true, encoding: .utf8)
            return path
        } catch {
            Logger.storage.error("Failed to generate CSV: \(error.localizedDescription)")
            return nil
        }
    }
}
