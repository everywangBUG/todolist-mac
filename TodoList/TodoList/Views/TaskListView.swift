import SwiftUI

struct TaskListView: View {
    @StateObject private var taskVM = TaskViewModel()
    @StateObject private var categoryVM = CategoryViewModel()
    @State private var showingAddTask = false
    @State private var showingCategoryManager = false
    @State private var showingImportExport = false
    @State private var editingTask: TaskEntity? = nil
    @State private var showingAddCategory = false
    @State private var newCategoryName = ""

    private enum SidebarFilter: Hashable {
        case all
        case completed
        case category(UUID)
    }

    @State private var selectedFilter: SidebarFilter = .all

    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            detailContent
        }
        .sheet(isPresented: $showingAddTask) {
            TaskEditView(task: nil, onSave: { title, desc, priority, dueDate, category in
                taskVM.addTask(title: title, description: desc, priority: priority, dueDate: dueDate, category: category)
                showingAddTask = false
            }, onCancel: {
                showingAddTask = false
            })
        }
        .sheet(item: $editingTask) { task in
            TaskEditView(task: task, onSave: { title, desc, priority, dueDate, category in
                taskVM.updateTask(task, title: title, description: desc, priority: priority, dueDate: dueDate, category: category)
                editingTask = nil
            }, onCancel: {
                editingTask = nil
            })
        }
        .sheet(isPresented: $showingCategoryManager) {
            CategoryManagerView()
        }
        .sheet(isPresented: $showingImportExport) {
            ImportExportView()
        }
        .alert("新增分类", isPresented: $showingAddCategory) {
            TextField("分类名称", text: $newCategoryName)
            Button("取消", role: .cancel) {
                newCategoryName = ""
            }
            Button("添加") {
                if !newCategoryName.trimmingCharacters(in: .whitespaces).isEmpty {
                    categoryVM.addCategory(name: newCategoryName.trimmingCharacters(in: .whitespaces))
                    newCategoryName = ""
                }
            }
        } message: {
            Text("输入分类名称")
        }
        .onAppear {
            taskVM.loadTasks()
            categoryVM.loadCategories()
        }
    }

    // MARK: - Sidebar

    private var sidebar: some View {
        List(selection: $selectedFilter) {
            Section("筛选") {
                Label("全部任务", systemImage: "list.bullet")
                    .tag(SidebarFilter.all)
                Label("已完成", systemImage: "checkmark.circle")
                    .tag(SidebarFilter.completed)
            }

            Section {
                ForEach(categoryVM.categories) { category in
                    Label {
                        Text(category.name ?? "")
                    } icon: {
                        Circle()
                            .fill(Color(hex: category.color ?? "#007AFF"))
                            .frame(width: 8, height: 8)
                    }
                    .tag(SidebarFilter.category(category.id ?? UUID()))
                }

                Button(action: {
                    newCategoryName = ""
                    showingAddCategory = true
                }) {
                    Label {
                        Text("新增分类")
                            .foregroundColor(.secondary)
                    } icon: {
                        Image(systemName: "plus.circle")
                            .foregroundColor(.secondary)
                    }
                }
                .buttonStyle(.plain)
            } header: {
                HStack {
                    Text("分类")
                    Spacer()
                    Button(action: { showingCategoryManager = true }) {
                        Image(systemName: "folder.badge.gear")
                            .font(.caption)
                    }
                    .buttonStyle(.plain)
                    .help("管理分类")
                }
            }
        }
        .listStyle(.sidebar)
        .frame(minWidth: 180)
    }

    // MARK: - Detail Content

    private var detailContent: some View {
        VStack(spacing: 0) {
            toolbar
            Divider()
            taskList
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(navigationTitle)
                    .font(.headline)
            }
        }
    }

    private var toolbar: some View {
        HStack(spacing: 12) {
            SearchField(text: $taskVM.searchText)
                .frame(width: 200)

            Spacer()

            Picker("排序", selection: $taskVM.sortOption) {
                ForEach(TaskViewModel.SortOption.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 120)

            Button(action: { showingImportExport = true }) {
                Image(systemName: "arrow.up.arrow.down.circle")
            }
            .help("导入导出")

            Button(action: { showingAddTask = true }) {
                Image(systemName: "plus")
            }
            .help("添加任务")
        }
        .padding()
    }

    private var taskList: some View {
        List {
            ForEach(displayTasks) { task in
                TaskRowView(task: task, onToggle: {
                    taskVM.toggleComplete(task)
                }, onEdit: {
                    editingTask = task
                }, onDelete: {
                    taskVM.deleteTask(task)
                })
                .listRowInsets(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12))
            }
        }
        .listStyle(.plain)
    }

    // MARK: - Helpers

    private var selectedCategoryEntity: CategoryEntity? {
        if case .category(let id) = selectedFilter {
            return categoryVM.categories.first { $0.id == id }
        }
        return nil
    }

    private var navigationTitle: String {
        switch selectedFilter {
        case .all:
            return "全部任务"
        case .completed:
            return "已完成"
        case .category:
            return selectedCategoryEntity?.name ?? "分类"
        }
    }

    private var displayTasks: [TaskEntity] {
        let filtered = taskVM.filteredTasks

        switch selectedFilter {
        case .all:
            return filtered.filter { !$0.isCompleted }
        case .completed:
            return filtered.filter { $0.isCompleted }
        case .category(let id):
            return filtered.filter { $0.category?.id == id }
        }
    }
}

// MARK: - SearchField

struct SearchField: NSViewRepresentable {
    @Binding var text: String

    func makeNSView(context: Context) -> NSSearchField {
        let searchField = NSSearchField()
        searchField.delegate = context.coordinator
        searchField.placeholderString = "搜索任务..."
        return searchField
    }

    func updateNSView(_ nsView: NSSearchField, context: Context) {
        nsView.stringValue = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, NSSearchFieldDelegate {
        let parent: SearchField

        init(_ parent: SearchField) {
            self.parent = parent
        }

        func controlTextDidChange(_ obj: Notification) {
            if let searchField = obj.object as? NSSearchField {
                parent.text = searchField.stringValue
            }
        }
    }
}
