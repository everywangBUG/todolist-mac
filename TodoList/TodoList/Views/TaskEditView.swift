import SwiftUI
import AppKit

struct TaskEditView: View {
    let task: TaskEntity?
    let onSave: (String, String?, Int16, Date?, CategoryEntity?) -> Void
    let onCancel: () -> Void

    @State private var title: String = ""
    @State private var description: String = ""
    @State private var priority: Int16 = 0
    @State private var hasDueDate: Bool = false
    @State private var dueDate: Date = Date()
    @State private var selectedCategory: CategoryEntity? = nil
    @State private var descriptionActive = false

    @StateObject private var categoryVM = CategoryViewModel()

    private var isEditing: Bool { task != nil }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            formContent
            Spacer()
        }
        .frame(minWidth: 400, minHeight: 450)
        .onAppear {
            if let task = task {
                title = task.title ?? ""
                description = task.desc ?? ""
                priority = task.priority
                if let dd = task.dueDate {
                    hasDueDate = true
                    dueDate = dd
                }
                selectedCategory = task.category
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text(isEditing ? "编辑任务" : "新建任务")
                .font(.headline)
            Spacer()
            Button("取消", action: onCancel)
            Button("保存") {
                onSave(
                    title,
                    description.isEmpty ? nil : description,
                    priority,
                    hasDueDate ? dueDate : nil,
                    selectedCategory
                )
            }
            .disabled(title.isEmpty)
            .keyboardShortcut(.defaultAction)
        }
        .padding()
    }

    // MARK: - Form

    private var formContent: some View {
        Form {
            Section {
                TextField("任务标题", text: $title)
                    .textFieldStyle(.roundedBorder)

                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(white: 0.98))
                    DescriptionEditor(text: $description, isActive: $descriptionActive)
                        .frame(minHeight: 60, maxHeight: 150)
                    if !descriptionActive && description.isEmpty {
                        Text("任务描述（可选）")
                            .foregroundColor(.secondary)
                            .padding(.leading, 4)
                            .padding(.top, 6)
                            .allowsHitTesting(false)
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }

            Section("优先级") {
                Picker("优先级", selection: $priority) {
                    Text("低").tag(Int16(0))
                    Text("中").tag(Int16(1))
                    Text("高").tag(Int16(2))
                }
                .pickerStyle(.segmented)
            }

            Section("截止日期") {
                Toggle("设置截止日期", isOn: $hasDueDate)
                if hasDueDate {
                    DatePicker("", selection: $dueDate, displayedComponents: .date)
                        .datePickerStyle(.field)
                }
            }

            Section("分类") {
                Picker("分类", selection: $selectedCategory) {
                    Text("无").tag(nil as CategoryEntity?)
                    ForEach(categoryVM.categories) { category in
                        HStack {
                            Circle()
                                .fill(Color(hex: category.color ?? "#007AFF"))
                                .frame(width: 8, height: 8)
                            Text(category.name ?? "")
                        }
                        .tag(category as CategoryEntity?)
                    }
                }
                .pickerStyle(.menu)
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

class DescriptionTextView: NSTextView {
    var onFocusChange: ((Bool) -> Void)?

    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        if result {
            onFocusChange?(true)
            let endLocation = (self.string as NSString).length
            self.setSelectedRange(NSRange(location: endLocation, length: 0))
            self.scrollRangeToVisible(NSRange(location: endLocation, length: 0))
        }
        return result
    }

    override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        if result {
            onFocusChange?(false)
        }
        return result
    }
}

struct DescriptionEditor: NSViewRepresentable {
    @Binding var text: String
    @Binding var isActive: Bool

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder
        scrollView.drawsBackground = false

        let textView = DescriptionTextView()
        textView.delegate = context.coordinator
        textView.drawsBackground = false
        textView.isEditable = true
        textView.isSelectable = true
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.font = NSFont.systemFont(ofSize: 13)
        textView.textContainerInset = NSSize(width: 2, height: 6)
        textView.textContainer?.lineFragmentPadding = 4
        textView.textContainer?.containerSize = NSSize(width: 0, height: CGFloat.greatestFiniteMagnitude)
        textView.textContainer?.widthTracksTextView = true
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.autoresizingMask = [.width]
        textView.onFocusChange = { focused in
            if focused {
                context.coordinator.parent.isActive = true
            } else {
                if context.coordinator.parent.text.isEmpty {
                    context.coordinator.parent.isActive = false
                }
            }
        }

        scrollView.documentView = textView

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? DescriptionTextView else { return }
        if textView.string != text {
            textView.string = text
        }
        textView.minSize = NSSize(width: 0, height: scrollView.contentSize.height)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        let parent: DescriptionEditor

        init(_ parent: DescriptionEditor) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string
            parent.isActive = textView.string.count > 0 || textView.hasMarkedText()
        }

        func textViewDidChangeSelection(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            if textView.hasMarkedText() {
                parent.isActive = true
            }
        }
    }
}