import SwiftUI

struct ImportExportView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var taskVM = TaskViewModel()
    @StateObject private var categoryVM = CategoryViewModel()

    @State private var isExporting = false
    @State private var isImporting = false
    @State private var resultMessage: String?
    @State private var isError = false

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            content
            Spacer()
            if let message = resultMessage {
                resultBar(message: message)
            }
        }
        .frame(minWidth: 450, minHeight: 350)
    }

    private var header: some View {
        HStack {
            Text("数据导入导出")
                .font(.headline)
            Spacer()
            Button("关闭") { dismiss() }
                .keyboardShortcut(.cancelAction)
        }
        .padding()
    }

    private var content: some View {
        VStack(spacing: 20) {
            exportSection
            Divider()
            importSection
            Divider()
            statsSection
        }
        .padding()
    }

    private var exportSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("导出数据", systemImage: "square.and.arrow.up")
                .font(.system(size: 14, weight: .semibold))

            Text("将所有任务和分类导出为 JSON 文件，用于备份或迁移数据。")
                .font(.caption)
                .foregroundColor(.secondary)

            Button(action: performExport) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("导出到文件")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isExporting)
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
    }

    private var importSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("导入数据", systemImage: "square.and.arrow.down")
                .font(.system(size: 14, weight: .semibold))

            Text("从 JSON 文件导入任务和分类。已存在的任务（相同 ID）将被跳过，不会重复导入。")
                .font(.caption)
                .foregroundColor(.secondary)

            Button(action: performImport) {
                HStack {
                    Image(systemName: "square.and.arrow.down")
                    Text("从文件导入")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .disabled(isImporting)
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
    }

    private var statsSection: some View {
        HStack(spacing: 24) {
            statItem(title: "任务总数", value: "\(taskVM.tasks.count)", icon: "list.bullet", color: .blue)
            statItem(title: "已完成", value: "\(taskVM.tasks.filter { $0.isCompleted }.count)", icon: "checkmark.circle", color: .green)
            statItem(title: "分类数", value: "\(categoryVM.categories.count)", icon: "folder", color: .orange)
        }
    }

    private func statItem(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
    }

    private func resultBar(message: String) -> some View {
        HStack {
            Image(systemName: isError ? "xmark.circle.fill" : "checkmark.circle.fill")
                .foregroundColor(isError ? .red : .green)
            Text(message)
                .font(.caption)
                .lineLimit(2)
            Spacer()
            Button {
                resultMessage = nil
            } label: {
                Image(systemName: "xmark")
                    .font(.caption2)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(isError ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
    }

    private func performExport() {
        isExporting = true
        resultMessage = nil

        if let url = DataTransferService.shared.exportToFile() {
            isError = false
            resultMessage = "导出成功！文件已保存到：\(url.lastPathComponent)"
        } else {
            isError = true
            resultMessage = "导出失败或已取消"
        }
        isExporting = false
    }

    private func performImport() {
        isImporting = true
        resultMessage = nil

        let result = DataTransferService.shared.importFromFile()
        isError = !result.success
        resultMessage = result.summary

        if result.success {
            taskVM.loadTasks()
            categoryVM.loadCategories()
        }
        isImporting = false
    }
}
