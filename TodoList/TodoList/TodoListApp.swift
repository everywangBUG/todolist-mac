import SwiftUI

struct TodoListApp: App {
    let persistenceController = CoreDataManager.shared

    var body: some Scene {
        WindowGroup {
            TaskListView()
                .frame(minWidth: 800, minHeight: 500)
        }
        .windowStyle(.titleBar)
        .commands {
            CommandMenu("任务") {
                Button("新建任务") {
                    NotificationCenter.default.post(name: .init("ShowAddTask"), object: nil)
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
    }
}