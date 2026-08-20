//
//  ExportDataView.swift
//  Mood Tracker
//

import SwiftUI
import UniformTypeIdentifiers

struct ExportDataView: View {
    @Environment(\.dismiss) private var dismiss
    let entries: [MoodEntry]
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("\(entries.count) mood entries")
                        .foregroundStyle(.secondary)
                } header: {
                    Text("Export Summary")
                }
                
                Section {
                    ShareLink(
                        item: generateCSV(),
                        preview: SharePreview(
                            "Mood Data",
                            image: Image(systemName: "chart.line.uptrend.xyaxis")
                        )
                    ) {
                        Label("Export as CSV", systemImage: "doc.text")
                    }
                    
                    ShareLink(
                        item: generateJSON(),
                        preview: SharePreview(
                            "Mood Data",
                            image: Image(systemName: "doc.text")
                        )
                    ) {
                        Label("Export as JSON", systemImage: "doc.text")
                    }
                } header: {
                    Text("Format")
                } footer: {
                    Text("Your mood data will be exported in the selected format. You can save it to Files, share via email, or back it up to iCloud.")
                }
            }
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func generateCSV() -> CSVFile {
        var csv = "Date,Time,Mood Score,Summary\n"
        let sortedEntries = entries.sorted { $0.date < $1.date }
        
        for entry in sortedEntries {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let date = dateFormatter.string(from: entry.date)
            
            dateFormatter.dateFormat = "HH:mm:ss"
            let time = dateFormatter.string(from: entry.date)
            
            let summary = entry.summary.replacingOccurrences(of: "\"", with: "\"\"")
            csv += "\(date),\(time),\(entry.moodScore),\"\(summary)\"\n"
        }
        
        return CSVFile(content: csv)
    }
    
    private func generateJSON() -> JSONFile {
        let sortedEntries = entries.sorted { $0.date < $1.date }
        let exportData: [[String: Any]] = sortedEntries.map { entry in
            [
                "date": ISO8601DateFormatter().string(from: entry.date),
                "moodScore": entry.moodScore,
                "summary": entry.summary
            ]
        }
        
        let jsonData = try? JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
        let jsonString = jsonData.flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
        
        return JSONFile(content: jsonString)
    }
}

struct CSVFile: Transferable {
    let content: String
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .commaSeparatedText) { csv in
            csv.content.data(using: .utf8) ?? Data()
        }
        .suggestedFileName("mood_data_\(dateString).csv")
    }
    
    private static var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}

struct JSONFile: Transferable {
    let content: String
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .json) { json in
            json.content.data(using: .utf8) ?? Data()
        }
        .suggestedFileName("mood_data_\(dateString).json")
    }
    
    private static var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}

#Preview {
    ExportDataView(entries: [])
}
