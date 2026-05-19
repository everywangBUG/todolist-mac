import Foundation
import CoreData
import AppKit
import UniformTypeIdentifiers

struct ExportData: Codable {
    var version: String = "1.0"
    var exportDate: Date = Date()
    var categories: [ExportCategory]
    var tasks: [ExportTask]
}

struct ExportCategory: Codable {
    var id: UUID
    var name: String
    var color: String
}

struct ExportTask: Codable {
    var id: UUID
    var title: String
    var desc: String?
    var isCompleted: Bool
    var priority: Int16
    var dueDate: Date?
    var createdAt: Date?
    var updatedAt: Date?
    var categoryName: String?
}

class DataTransferService {
    static let shared = DataTransferService()
    private let repository = TaskRepository.shared

    private init() {}

    func exportToJson() -> Data? {
        let tasks = repository.fetchAllTasks()
        let categories = repository.fetchAllCategories()

        let exportCategories = categories.map { cat -> ExportCategory in
            ExportCategory(
                id: cat.id ?? UUID(),
                name: cat.name ?? "",
                color: cat.color ?? "#007AFF"
            )
        }

        let exportTasks = tasks.map { task -> ExportTask in
            ExportTask(
                id: task.id ?? UUID(),
                title: task.title ?? "",
                desc: task.desc,
                isCompleted: task.isCompleted,
                priority: task.priority,
                dueDate: task.dueDate,
                createdAt: task.createdAt,
                updatedAt: task.updatedAt,
                categoryName: task.category?.name
            )
        }

        let data = ExportData(
            categories: exportCategories,
            tasks: exportTasks
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        do {
            return try encoder.encode(data)
        } catch {
            print("Export encoding error: \(error.localizedDescription)")
            return nil
        }
    }

    func exportToFile() -> URL? {
        guard let data = exportToJson() else { return nil }

        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "TodoList_Export_\(formatDate(Date())).json"
        panel.title = "导出任务数据"
        panel.message = "选择导出文件的保存位置"

        guard panel.runModal() == .OK, let url = panel.url else { return nil }

        do {
            try data.write(to: url, options: .atomic)
            return url
        } catch {
            print("Export file write error: \(error.localizedDescription)")
            return nil
        }
    }

    func importFromData(_ data: Data) -> ImportResult {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let exportData: ExportData
        do {
            exportData = try decoder.decode(ExportData.self, from: data)
        } catch {
            return ImportResult(success: false, taskCount: 0, categoryCount: 0, error: "数据格式错误: \(error.localizedDescription)")
        }

        var importedCategories = 0
        var importedTasks = 0
        var categoryMap: [String: CategoryEntity] = [:]

        for catData in exportData.categories {
            let existing = repository.fetchAllCategories().first { $0.name == catData.name }
            if let existing = existing {
                categoryMap[catData.name] = existing
            } else {
                if let newCat = repository.createCategory(name: catData.name, color: catData.color) {
                    categoryMap[catData.name] = newCat
                    importedCategories += 1
                }
            }
        }

        let existingTasks = repository.fetchAllTasks()
        let existingTaskIds = Set(existingTasks.compactMap { $0.id })

        for taskData in exportData.tasks {
            if existingTaskIds.contains(taskData.id) {
                continue
            }

            let category = taskData.categoryName.flatMap { categoryMap[$0] }
            if let _ = repository.createTask(
                title: taskData.title,
                description: taskData.desc,
                priority: taskData.priority,
                dueDate: taskData.dueDate,
                category: category
            ) {
                importedTasks += 1
            }
        }

        return ImportResult(
            success: true,
            taskCount: importedTasks,
            categoryCount: importedCategories,
            error: nil
        )
    }

    func importFromFile() -> ImportResult {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.title = "导入任务数据"
        panel.message = "选择要导入的 JSON 文件"
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false

        guard panel.runModal() == .OK, let url = panel.url else {
            return ImportResult(success: false, taskCount: 0, categoryCount: 0, error: "未选择文件")
        }

        do {
            let data = try Data(contentsOf: url)
            return importFromData(data)
        } catch {
            return ImportResult(success: false, taskCount: 0, categoryCount: 0, error: "读取文件失败: \(error.localizedDescription)")
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        return formatter.string(from: date)
    }
}

struct ImportResult {
    let success: Bool
    let taskCount: Int
    let categoryCount: Int
    let error: String?

    var summary: String {
        if success {
            return "导入成功！导入了 \(taskCount) 个任务和 \(categoryCount) 个分类"
        } else {
            return "导入失败：\(error ?? "未知错误")"
        }
    }
}
