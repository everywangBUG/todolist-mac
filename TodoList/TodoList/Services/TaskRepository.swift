import CoreData
import Foundation

class TaskRepository {
    static let shared = TaskRepository()
    private let manager = CoreDataManager.shared

    private init() {}

    // MARK: - Task CRUD

    func createTask(title: String, description: String?, priority: Int16 = 0, dueDate: Date? = nil, category: CategoryEntity? = nil) -> TaskEntity? {
        guard let task = NSEntityDescription.insertNewObject(forEntityName: "Task", into: manager.context) as? TaskEntity else {
            return nil
        }
        task.id = UUID()
        task.title = title
        task.desc = description
        task.isCompleted = false
        task.priority = priority
        task.dueDate = dueDate
        task.createdAt = Date()
        task.updatedAt = Date()
        task.category = category
        manager.saveContext()
        return task
    }

    func fetchAllTasks() -> [TaskEntity] {
        let request = TaskEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskEntity.createdAt, ascending: false)]
        do {
            return try manager.context.fetch(request)
        } catch {
            print("Error fetching tasks: \(error)")
            return []
        }
    }

    func fetchTasksByCategory(_ category: CategoryEntity) -> [TaskEntity] {
        let request = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "category == %@", category)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskEntity.createdAt, ascending: false)]
        do {
            return try manager.context.fetch(request)
        } catch {
            print("Error fetching tasks by category: \(error)")
            return []
        }
    }

    func fetchTasks(predicate: NSPredicate) -> [TaskEntity] {
        let request = TaskEntity.fetchRequest()
        request.predicate = predicate
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskEntity.createdAt, ascending: false)]
        do {
            return try manager.context.fetch(request)
        } catch {
            print("Error fetching tasks with predicate: \(error)")
            return []
        }
    }

    func updateTask(_ task: TaskEntity, title: String? = nil, description: String? = nil, priority: Int16? = nil, dueDate: Date? = nil, category: CategoryEntity? = nil, isCompleted: Bool? = nil) -> Bool {
        if let title = title { task.title = title }
        if let description = description { task.desc = description }
        if let priority = priority { task.priority = priority }
        if let dueDate = dueDate { task.dueDate = dueDate }
        if let category = category { task.category = category }
        if let isCompleted = isCompleted { task.isCompleted = isCompleted }
        task.updatedAt = Date()
        manager.saveContext()
        return true
    }

    func deleteTask(_ task: TaskEntity) -> Bool {
        manager.context.delete(task)
        manager.saveContext()
        return true
    }

    func copyTaskToToday(_ task: TaskEntity) -> TaskEntity? {
        let today = Calendar.current.startOfDay(for: Date())
        guard let copied = createTask(
            title: task.title ?? "",
            description: task.desc,
            priority: task.priority,
            dueDate: today,
            category: task.category
        ) else {
            return nil
        }
        return copied
    }

    // MARK: - Category CRUD

    func createCategory(name: String, color: String = "#007AFF") -> CategoryEntity? {
        guard let category = NSEntityDescription.insertNewObject(forEntityName: "Category", into: manager.context) as? CategoryEntity else {
            return nil
        }
        category.id = UUID()
        category.name = name
        category.color = color
        manager.saveContext()
        return category
    }

    func fetchAllCategories() -> [CategoryEntity] {
        let request = CategoryEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CategoryEntity.name, ascending: true)]
        do {
            return try manager.context.fetch(request)
        } catch {
            print("Error fetching categories: \(error)")
            return []
        }
    }

    func updateCategory(_ category: CategoryEntity, name: String? = nil, color: String? = nil) -> Bool {
        if let name = name { category.name = name }
        if let color = color { category.color = color }
        manager.saveContext()
        return true
    }

    func deleteCategory(_ category: CategoryEntity) -> Bool {
        manager.context.delete(category)
        manager.saveContext()
        return true
    }
}
