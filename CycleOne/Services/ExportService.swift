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

    func generateCSV(context: NSManagedObjectContext) -> URL? {
        let request: NSFetchRequest<DayLog> = DayLog.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \DayLog.date, ascending: false)]

        do {
            let logs = try context.fetch(request)
            var csvString = "Date,Flow,Pain,Mood,Energy,Symptoms,Notes\n"

            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short

            for log in logs {
                let dateStr = log.date.map { dateFormatter.string(from: $0) } ?? ""
                let flowStr = FlowLevel(rawValue: log.flowLevel)?.description ?? ""
                let painStr = "\(log.painLevel)"
                let moodStr = Mood(rawValue: log.mood)?.description ?? ""
                let energyStr = EnergyLevel(rawValue: log.energyLevel)?.description ?? ""

                let symptoms = (log.symptoms as? Set<Symptom>)?.compactMap(\.name).joined(separator: ";") ?? ""
                let notes = log.notes?.replacingOccurrences(of: "\n", with: " ").replacingOccurrences(
                    of: ",",
                    with: " "
                ) ?? ""

                csvString += "\(dateStr),\(flowStr),\(painStr),\(moodStr),\(energyStr),\(symptoms),\(notes)\n"
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
