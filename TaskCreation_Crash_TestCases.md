# TodoList 创建任务崩溃问题测试用例

## 问题描述

用户反馈：点击创建任务后应用自动退出（崩溃）

## 问题根因分析

**已确认原因**：沙箱权限限制

**错误日志分析**：
```
CoreData: error:   Sandbox access to file-write-data denied
```

**根本原因**：未签名的 macOS 应用在沙箱环境下无法写入标准应用数据目录（如 `~/Library/Application Support/`），导致 Core Data 无法保存数据，进而引发崩溃。

## 修复方案

### 方案：修改 Core Data 存储路径

将数据库存储路径改为临时目录或其他可访问位置：

```swift
private static var applicationSupportDirectory: URL {
    let paths = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
    let appSupportDir = paths.first!
    let appDir = appSupportDir.appendingPathComponent("TodoList")
    
    do {
        try FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true, attributes: nil)
    } catch {
        print("Failed to create app support directory: \(error)")
    }
    
    return appDir
}

private static var temporaryDirectory: URL {
    FileManager.default.temporaryDirectory.appendingPathComponent("TodoList")
}
```

**修复策略**：
1. 优先尝试标准应用支持目录
2. 如果失败，自动回退到临时目录

---

## 测试用例

### 测试用例 1：应用启动测试

**测试目的**：验证应用能否正常启动

**测试步骤**：
1. 双击 TodoList.app 启动应用
2. 观察主界面是否正常显示

**预期结果**：
- 应用正常启动，显示任务列表界面

---

### 测试用例 2：创建任务功能测试

**测试目的**：验证创建任务功能是否正常

**测试步骤**：
1. 点击工具栏 "+" 按钮
2. 在"新建任务"窗口输入标题 "测试任务"
3. 点击"保存"按钮
4. 观察应用是否崩溃

**预期结果**：
- 任务成功创建并显示在列表中
- 应用不崩溃

---

### 测试用例 3：创建任务边界条件测试

| 子测试 | 操作步骤 | 预期结果 |
| :--- | :--- | :--- |
| 3.1 | 标题为空，点击保存 | 保存按钮禁用 |
| 3.2 | 仅输入标题 | 任务创建成功 |
| 3.3 | 标题+高优先级 | 任务创建成功 |
| 3.4 | 标题+截止日期 | 任务创建成功 |
| 3.5 | 标题+分类 | 任务创建成功 |

---

### 测试用例 4：数据持久化测试

**测试目的**：验证数据能否正确保存

**测试步骤**：
1. 创建任务 "持久化测试"
2. 关闭应用
3. 重新启动应用
4. 检查任务是否存在

**预期结果**：
- 任务仍然存在（如果使用临时目录，重启后数据可能丢失）

---

### 测试用例 5：编辑任务测试

**测试目的**：验证编辑任务功能

**测试步骤**：
1. 创建一个任务
2. 点击编辑按钮
3. 修改标题为 "已编辑"
4. 点击保存
5. 观察应用是否崩溃

**预期结果**：
- 任务标题更新成功

---

### 测试用例 6：删除任务测试

**测试目的**：验证删除任务功能

**测试步骤**：
1. 创建一个任务
2. 点击删除按钮
3. 确认删除
4. 观察应用是否崩溃

**预期结果**：
- 任务成功删除

---

### 测试用例 7：Core Data 模型加载测试

**测试目的**：验证 Core Data 模型能否正确加载

**测试步骤**：
1. 启动应用
2. 检查控制台日志

**预期结果**：
- 无 "Failed to locate Core Data model" 错误

---

## 问题定位方法

### 方法 1：查看系统日志

```bash
# 查看应用相关日志
log show --predicate 'processImagePath contains "TodoList"' --last 10m

# 查看崩溃日志
ls -la ~/Library/Logs/DiagnosticReports/ | grep TodoList
```

### 方法 2：直接运行查看错误

```bash
cd /Users/gene/Desktop/web/todolist-mac
./TodoList.app/Contents/MacOS/TodoList
```

### 方法 3：检查文件权限

```bash
# 检查应用支持目录权限
ls -la ~/Library/Application\ Support/

# 检查临时目录权限
ls -la /private/tmp/
```

---

## 测试执行记录

| 测试用例 | 执行时间 | 结果 | 备注 |
| :--- | :--- | :--- | :--- |
| 测试用例 1 | 2026-05-17 | 通过 | 应用正常启动 |
| 测试用例 2 | 2026-05-17 | 失败 | 创建任务时崩溃 |
| 测试用例 3 | - | 未执行 | 依赖测试用例 2 通过 |
| 测试用例 4 | - | 未执行 | 依赖测试用例 2 通过 |
| 测试用例 5 | - | 未执行 | 依赖测试用例 2 通过 |
| 测试用例 6 | - | 未执行 | 依赖测试用例 2 通过 |
| 测试用例 7 | 2026-05-17 | 通过 | 模型加载成功 |

---

## 修复验证步骤

1. **代码修复**：修改 `CoreDataManager.swift` 使用临时目录回退
2. **重新构建**：使用 Xcode 或 swift build 重新构建项目
3. **更新应用包**：替换 TodoList.app 中的可执行文件
4. **重新打包**：生成新的 .pkg 安装包
5. **测试验证**：执行上述测试用例

---

## 版本信息

- **应用版本**：1.0
- **macOS 版本**：13.0+
- **Swift 版本**：5.7+
- **问题状态**：已定位，待修复验证

---

**文档版本**：v1.1  
**创建日期**：2026-05-17  
**更新日期**：2026-05-17  
**作者**：TodoList 开发团队