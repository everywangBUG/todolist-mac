import SwiftUI

struct CategoryManagerView: View {
    @StateObject private var categoryVM = CategoryViewModel()
    @State private var showingAddCategory = false
    @State private var newCategoryName: String = ""
    @State private var newCategoryColor: String = "#007AFF"
    @State private var editingCategory: CategoryEntity? = nil
    @State private var editName: String = ""
    @State private var editColor: String = ""

    @Environment(\.dismiss) private var dismiss

    let colorOptions = [
        "#007AFF", "#34C759", "#FF9500", "#FF3B30",
        "#AF52DE", "#5856D6", "#FF2D55", "#5AC8FA"
    ]

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            categoryList
            Divider()
            addCategorySection
        }
        .frame(minWidth: 400, minHeight: 350)
        .sheet(item: $editingCategory) { category in
            editSheet(category: category)
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("分类管理")
                .font(.headline)
            Spacer()
            Button("完成") { dismiss() }
        }
        .padding()
    }

    // MARK: - Category List

    private var categoryList: some View {
        List {
            ForEach(categoryVM.categories) { category in
                categoryRow(category)
            }
        }
        .listStyle(.plain)
    }

    private func categoryRow(_ category: CategoryEntity) -> some View {
        HStack(spacing: 10) {
            Circle()
                .fill(Color(hex: category.color ?? "#007AFF"))
                .frame(width: 12, height: 12)

            Text(category.name ?? "")
                .font(.body)

            Spacer()

            HStack(spacing: 8) {
                Button(action: {
                    editingCategory = category
                    editName = category.name ?? ""
                    editColor = category.color ?? "#007AFF"
                }) {
                    Image(systemName: "pencil")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .foregroundColor(.accentColor)

                Button(action: {
                    categoryVM.deleteCategory(category)
                }) {
                    Image(systemName: "trash")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .foregroundColor(.red)
            }
        }
        .padding(.vertical, 2)
    }

    // MARK: - Add Category Section

    private var addCategorySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("添加新分类")
                .font(.subheadline)
                .fontWeight(.medium)

            HStack(spacing: 10) {
                TextField("分类名称", text: $newCategoryName)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 150)

                colorPicker(selection: $newCategoryColor)

                Spacer()

                Button("添加") {
                    if !newCategoryName.isEmpty {
                        categoryVM.addCategory(name: newCategoryName, color: newCategoryColor)
                        newCategoryName = ""
                        newCategoryColor = "#007AFF"
                    }
                }
                .disabled(newCategoryName.isEmpty)
            }
        }
        .padding()
    }

    // MARK: - Color Picker

    private func colorPicker(selection: Binding<String>) -> some View {
        HStack(spacing: 6) {
            ForEach(colorOptions, id: \.self) { color in
                Circle()
                    .fill(Color(hex: color))
                    .frame(width: 18, height: 18)
                    .overlay(
                        Circle()
                            .stroke(Color.primary, lineWidth: selection.wrappedValue == color ? 2 : 0)
                    )
                    .onTapGesture {
                        selection.wrappedValue = color
                    }
            }
        }
    }

    // MARK: - Edit Sheet

    private func editSheet(category: CategoryEntity) -> some View {
        VStack(spacing: 16) {
            Text("编辑分类")
                .font(.headline)

            TextField("名称", text: $editName)
                .textFieldStyle(.roundedBorder)
                .frame(width: 250)

            colorPicker(selection: $editColor)

            HStack(spacing: 16) {
                Button("取消") {
                    editingCategory = nil
                }

                Button("保存") {
                    categoryVM.updateCategory(category, name: editName, color: editColor)
                    editingCategory = nil
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 350, height: 180)
    }
}
