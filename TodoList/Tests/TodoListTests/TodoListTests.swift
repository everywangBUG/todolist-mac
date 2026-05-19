import XCTest
@testable import TodoList

final class TodoListTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Clean up any existing data before each test
        let repository = TaskRepository.shared
        let tasks = repository.fetchAllTasks()
        tasks.forEach { _ = repository.deleteTask($0) }
        let categories = repository.fetchAllCategories()
        categories.forEach { _ = repository.deleteCategory($0) }
    }

    // MARK: - Task Tests

    func testCreateTask() {
        let repository = TaskRepository.shared
        let task = repository.createTask(title: "Test Task", description: "Test Description", priority: 1, dueDate: nil, category: nil)

        XCTAssertNotNil(task)
        XCTAssertEqual(task?.title, "Test Task")
        XCTAssertEqual(task?.desc, "Test Description")
        XCTAssertEqual(task?.priority, 1)
        XCTAssertFalse(task?.isCompleted ?? true)
        XCTAssertNotNil(task?.id)
        XCTAssertNotNil(task?.createdAt)
    }

    func testFetchAllTasks() {
        let repository = TaskRepository.shared
        _ = repository.createTask(title: "Task 1", description: nil, priority: 0, dueDate: nil, category: nil)
        _ = repository.createTask(title: "Task 2", description: nil, priority: 0, dueDate: nil, category: nil)

        let tasks = repository.fetchAllTasks()
        XCTAssertGreaterThanOrEqual(tasks.count, 2)
    }

    func testUpdateTask() {
        let repository = TaskRepository.shared
        let task = repository.createTask(title: "Original", description: nil, priority: 0, dueDate: nil, category: nil)

        XCTAssertNotNil(task)
        _ = repository.updateTask(task!, title: "Updated", priority: 2)

        let tasks = repository.fetchAllTasks()
        let updatedTask = tasks.first { $0.id == task?.id }
        XCTAssertEqual(updatedTask?.title, "Updated")
        XCTAssertEqual(updatedTask?.priority, 2)
    }

    func testDeleteTask() {
        let repository = TaskRepository.shared
        let task = repository.createTask(title: "To Delete", description: nil, priority: 0, dueDate: nil, category: nil)

        XCTAssertNotNil(task)
        let taskId = task?.id
        _ = repository.deleteTask(task!)

        let tasks = repository.fetchAllTasks()
        XCTAssertNil(tasks.first { $0.id == taskId })
    }

    func testToggleTaskCompletion() {
        let repository = TaskRepository.shared
        let task = repository.createTask(title: "Toggle Test", description: nil, priority: 0, dueDate: nil, category: nil)

        XCTAssertNotNil(task)
        XCTAssertFalse(task!.isCompleted)

        _ = repository.updateTask(task!, isCompleted: true)
        let tasks = repository.fetchAllTasks()
        let updatedTask = tasks.first { $0.id == task?.id }
        XCTAssertTrue(updatedTask?.isCompleted ?? false)
    }

    // MARK: - Category Tests

    func testCreateCategory() {
        let repository = TaskRepository.shared
        let category = repository.createCategory(name: "Work", color: "#FF0000")

        XCTAssertNotNil(category)
        XCTAssertEqual(category?.name, "Work")
        XCTAssertEqual(category?.color, "#FF0000")
        XCTAssertNotNil(category?.id)
    }

    func testFetchAllCategories() {
        let repository = TaskRepository.shared
        _ = repository.createCategory(name: "Personal", color: "#00FF00")
        _ = repository.createCategory(name: "Work", color: "#0000FF")

        let categories = repository.fetchAllCategories()
        XCTAssertGreaterThanOrEqual(categories.count, 2)
    }

    func testUpdateCategory() {
        let repository = TaskRepository.shared
        let category = repository.createCategory(name: "Old Name", color: "#000000")

        XCTAssertNotNil(category)
        _ = repository.updateCategory(category!, name: "New Name", color: "#FFFFFF")

        let categories = repository.fetchAllCategories()
        let updatedCategory = categories.first { $0.id == category?.id }
        XCTAssertEqual(updatedCategory?.name, "New Name")
        XCTAssertEqual(updatedCategory?.color, "#FFFFFF")
    }

    func testDeleteCategory() {
        let repository = TaskRepository.shared
        let category = repository.createCategory(name: "To Delete", color: "#000000")

        XCTAssertNotNil(category)
        let categoryId = category?.id
        _ = repository.deleteCategory(category!)

        let categories = repository.fetchAllCategories()
        XCTAssertNil(categories.first { $0.id == categoryId })
    }

    // MARK: - Task with Category Tests

    func testTaskWithCategory() {
        let repository = TaskRepository.shared
        let category = repository.createCategory(name: "Work", color: "#007AFF")
        let task = repository.createTask(title: "Work Task", description: nil, priority: 1, dueDate: nil, category: category)

        XCTAssertNotNil(task)
        XCTAssertEqual(task?.category?.name, "Work")
        XCTAssertEqual(task?.category?.color, "#007AFF")
    }

    func testFetchTasksByCategory() {
        let repository = TaskRepository.shared
        let workCategory = repository.createCategory(name: "Work", color: "#007AFF")
        let personalCategory = repository.createCategory(name: "Personal", color: "#34C759")

        _ = repository.createTask(title: "Work Task 1", description: nil, priority: 0, dueDate: nil, category: workCategory)
        _ = repository.createTask(title: "Work Task 2", description: nil, priority: 0, dueDate: nil, category: workCategory)
        _ = repository.createTask(title: "Personal Task", description: nil, priority: 0, dueDate: nil, category: personalCategory)

        let workTasks = repository.fetchTasksByCategory(workCategory!)
        XCTAssertEqual(workTasks.count, 2)

        let personalTasks = repository.fetchTasksByCategory(personalCategory!)
        XCTAssertEqual(personalTasks.count, 1)
    }

    // MARK: - ViewModel Tests

    func testTaskViewModelLoadTasks() {
        let viewModel = TaskViewModel()
        let initialCount = viewModel.tasks.count

        let repository = TaskRepository.shared
        _ = repository.createTask(title: "VM Test Task", description: nil, priority: 0, dueDate: nil, category: nil)

        viewModel.loadTasks()
        XCTAssertEqual(viewModel.tasks.count, initialCount + 1)
    }

    func testTaskViewModelAddTask() {
        let viewModel = TaskViewModel()
        let initialCount = viewModel.tasks.count

        viewModel.addTask(title: "New Task", description: "Description", priority: 1, dueDate: nil, category: nil)
        XCTAssertEqual(viewModel.tasks.count, initialCount + 1)
    }

    func testTaskViewModelSearchFilter() {
        let viewModel = TaskViewModel()
        viewModel.addTask(title: "Apple Task", description: nil, priority: 0, dueDate: nil, category: nil)
        viewModel.addTask(title: "Banana Task", description: nil, priority: 0, dueDate: nil, category: nil)

        viewModel.searchText = "Apple"
        XCTAssertEqual(viewModel.filteredTasks.count, 1)
        XCTAssertEqual(viewModel.filteredTasks.first?.title, "Apple Task")
    }

    func testCategoryViewModelLoadCategories() {
        let viewModel = CategoryViewModel()
        let initialCount = viewModel.categories.count

        let repository = TaskRepository.shared
        _ = repository.createCategory(name: "Test Category", color: "#FF0000")

        viewModel.loadCategories()
        XCTAssertEqual(viewModel.categories.count, initialCount + 1)
    }

    func testCategoryViewModelAddCategory() {
        let viewModel = CategoryViewModel()
        let initialCount = viewModel.categories.count

        viewModel.addCategory(name: "New Category", color: "#00FF00")
        XCTAssertEqual(viewModel.categories.count, initialCount + 1)
    }
}
