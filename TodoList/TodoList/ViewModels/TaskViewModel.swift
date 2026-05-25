import Foundation
import Combine

class TaskViewModel: ObservableObject {
    @Published var tasks: [TaskEntity] = []
    @Published var searchText: String = ""
    @Published var selectedCategory: CategoryEntity? = nil
    @Published var sortOption: SortOption = .createdAt

    private let repository = TaskRepository.shared
    private var cancellables = Set<AnyCancellable>()

    enum SortOption: String, CaseIterable, Identifiable {
        case createdAt = "创建时间"
        case priority = "优先级"
        case dueDate = "截止日期"
        case title = "标题"

        var id: String { rawValue }
    }

    var filteredTasks: [TaskEntity] {
        var result = tasks

        // 分类筛选
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }

        // 搜索筛选
        if !searchText.isEmpty {
            result = result.filter {
                ($0.title?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                ($0.desc?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }

        // 排序
        switch sortOption {
        case .createdAt:
            result.sort { ($0.createdAt ?? Date()) > ($1.createdAt ?? Date()) }
        case .priority:
            result.sort { $0.priority > $1.priority }
        case .dueDate:
            result.sort {
                guard let d1 = $0.dueDate else { return false }
                guard let d2 = $1.dueDate else { return true }
                return d1 < d2
            }
        case .title:
            result.sort { ($0.title ?? "") < ($1.title ?? "") }
        }

        return result
    }

    init() {
        loadTasks()
    }

    func loadTasks() {
        tasks = repository.fetchAllTasks()
    }

    func addTask(title: String, description: String?, priority: Int16, dueDate: Date?, category: CategoryEntity?) {
        _ = repository.createTask(title: title, description: description, priority: priority, dueDate: dueDate, category: category)
        loadTasks()
    }

    func updateTask(_ task: TaskEntity, title: String, description: String?, priority: Int16, dueDate: Date?, category: CategoryEntity?) {
        _ = repository.updateTask(task, title: title, description: description, priority: priority, dueDate: dueDate, category: category)
        loadTasks()
    }

    func deleteTask(_ task: TaskEntity) {
        _ = repository.deleteTask(task)
        loadTasks()
    }

    func toggleComplete(_ task: TaskEntity) {
        _ = repository.updateTask(task, isCompleted: !task.isCompleted)
        loadTasks()
    }

    func copyTaskToToday(_ task: TaskEntity) {
        _ = repository.copyTaskToToday(task)
        loadTasks()
    }
}
