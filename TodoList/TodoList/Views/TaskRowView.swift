import SwiftUI

struct TaskRowView: View {
    let task: TaskEntity
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onCopyToToday: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            toggleButton
            taskInfo
            Spacer()
            actionButtons
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }

    // MARK: - Toggle Button

    private var toggleButton: some View {
        Button(action: onToggle) {
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(task.isCompleted ? .green : .gray)
                .font(.title3)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Task Info

    private var taskInfo: some View {
        VStack(alignment: .leading, spacing: 2) {
            titleRow
            if let desc = task.desc, !desc.isEmpty {
                Text(desc)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            metadataRow
        }
    }

    private var titleRow: some View {
        HStack(spacing: 6) {
            Text(task.title ?? "")
                .font(.system(size: 14, weight: .medium))
                .strikethrough(task.isCompleted)
                .foregroundColor(task.isCompleted ? .secondary : .primary)

            if let category = task.category, let name = category.name {
                categoryBadge(category: category, name: name)
            }
        }
    }

    private func categoryBadge(category: CategoryEntity, name: String) -> some View {
        HStack(spacing: 2) {
            Circle()
                .fill(Color(hex: category.color ?? "#007AFF"))
                .frame(width: 6, height: 6)
            Text(name)
                .font(.caption2)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 1)
        .background(Color(hex: category.color ?? "#007AFF").opacity(0.15))
        .cornerRadius(4)
    }

    private var metadataRow: some View {
        HStack(spacing: 8) {
            PriorityBadge(priority: task.priority)

            if let dueDate = task.dueDate {
                HStack(spacing: 2) {
                    Image(systemName: "calendar")
                        .font(.caption2)
                    Text(dueDate, style: .date)
                        .font(.caption2)
                }
                .foregroundColor(dueDate < Date() && !task.isCompleted ? .red : .secondary)
            }
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: 4) {
            Button(action: onCopyToToday) {
                Image(systemName: "doc.on.doc")
                    .font(.caption)
            }
            .buttonStyle(.plain)
            .foregroundColor(.accentColor)
            .help("复制到今天")

            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .font(.caption)
            }
            .buttonStyle(.plain)
            .foregroundColor(.accentColor)

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.caption)
            }
            .buttonStyle(.plain)
            .foregroundColor(.red)
        }
        .opacity(0.6)
    }
}

// MARK: - PriorityBadge

struct PriorityBadge: View {
    let priority: Int16

    var body: some View {
        let info = priorityInfo
        Text(info.text)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 4)
            .padding(.vertical, 1)
            .background(info.color.opacity(0.15))
            .foregroundColor(info.color)
            .cornerRadius(3)
    }

    private var priorityInfo: (text: String, color: Color) {
        switch priority {
        case 2: return ("高", .red)
        case 1: return ("中", .orange)
        default: return ("低", .gray)
        }
    }
}
