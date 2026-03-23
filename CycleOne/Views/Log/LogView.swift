//
//  LogView.swift
//  CycleOne
//

import CoreData
import Foundation
import OSLog
import SwiftUI

struct LogView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: CycleViewModel
    let date: Date

    @State private var flow: FlowLevel = .none
    @State private var mood: Mood = .neutral
    @State private var notes: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Menstrual Flow")) {
                    Picker("Flow", selection: $flow) {
                        ForEach(FlowLevel.allCases, id: \.self) { level in
                            Text(level.description).tag(level)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section(header: Text("Mood")) {
                    HStack {
                        ForEach(Mood.allCases, id: \.self) { item in
                            VStack {
                                Image(systemName: item.icon)
                                    .font(.title2)
                                    .foregroundColor(mood == item ? .pink : .secondary)
                                    .onTapGesture {
                                        mood = item
                                    }
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle(date.formatted(date: .abbreviated, time: .omitted))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveLog()
                        dismiss()
                    }
                    .bold()
                }
            }
        }
    }

    private func saveLog() {
        let viewContext = PersistenceController.shared.container.viewContext

        let fetchRequest: NSFetchRequest<DayLog> = DayLog.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date == %@", date as NSDate)

        do {
            let results = try viewContext.fetch(fetchRequest)
            let log = results.first ?? DayLog(context: viewContext)

            log.id = log.id ?? UUID()
            log.date = Calendar.current.startOfDay(for: date)
            log.flowLevel = flow.rawValue
            log.mood = mood.rawValue
            log.notes = notes

            // Auto Cycle logic could go here, for now just save the log
            try viewContext.save()
            Logger.storage.info("Successfully saved log for \(date)")
        } catch {
            Logger.storage.error("Error saving log: \(error.localizedDescription)")
        }
    }
}
