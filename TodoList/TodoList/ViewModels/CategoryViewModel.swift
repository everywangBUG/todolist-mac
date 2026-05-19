import Foundation
import Combine

class CategoryViewModel: ObservableObject {
    @Published var categories: [CategoryEntity] = []

    private let repository = TaskRepository.shared

    init() {
        loadCategories()
    }

    func loadCategories() {
        categories = repository.fetchAllCategories()
    }

    func addCategory(name: String, color: String = "#007AFF") {
        _ = repository.createCategory(name: name, color: color)
        loadCategories()
    }

    func updateCategory(_ category: CategoryEntity, name: String, color: String) {
        _ = repository.updateCategory(category, name: name, color: color)
        loadCategories()
    }

    func deleteCategory(_ category: CategoryEntity) {
        _ = repository.deleteCategory(category)
        loadCategories()
    }
}
