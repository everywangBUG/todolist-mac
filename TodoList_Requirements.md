# TodoList macOS 应用需求文档

## 1. 项目概述

### 1.1 项目背景
本项目是一个基于 Swift 语言开发的 macOS 原生待办事项应用，旨在帮助用户高效管理日常任务，提升时间管理效率。

### 1.2 产品定位
- **目标用户**: 需要管理日常任务的 macOS 用户
- **核心价值**: 简洁高效的任务管理体验
- **竞争优势**: 原生性能、优雅界面、离线可用

### 1.3 文档目的
本文档描述 TodoList macOS 应用的完整需求，作为开发、测试和验收的依据。

---

## 2. 功能需求

### 2.1 任务管理

| 需求编号 | 功能点 | 描述 | 优先级 |
| :--- | :--- | :--- | :--- |
| FR-001 | 创建任务 | 用户可以添加新的待办任务，包含标题和描述 | 高 |
| FR-002 | 查看任务列表 | 显示所有任务的列表视图 | 高 |
| FR-003 | 编辑任务 | 修改任务的标题和描述 | 高 |
| FR-004 | 删除任务 | 删除选中的任务 | 高 |
| FR-005 | 标记完成 | 将任务标记为已完成/未完成 | 高 |
| FR-006 | 任务搜索 | 通过关键词搜索任务 | 中 |

### 2.2 任务分类

| 需求编号 | 功能点 | 描述 | 优先级 |
| :--- | :--- | :--- | :--- |
| FR-007 | 创建分类 | 创建自定义任务分类（如：工作、生活、学习） | 中 |
| FR-008 | 分类管理 | 编辑、删除分类 | 中 |
| FR-009 | 任务关联分类 | 将任务分配到指定分类 | 中 |
| FR-010 | 分类筛选 | 按分类筛选任务列表 | 中 |

### 2.3 优先级管理

| 需求编号 | 功能点 | 描述 | 优先级 |
| :--- | :--- | :--- | :--- |
| FR-011 | 设置优先级 | 为任务设置高/中/低优先级 | 中 |
| FR-012 | 优先级排序 | 按优先级排序任务列表 | 中 |

### 2.4 截止日期

| 需求编号 | 功能点 | 描述 | 优先级 |
| :--- | :--- | :--- | :--- |
| FR-013 | 设置截止日期 | 为任务设置截止日期 | 中 |
| FR-014 | 截止提醒 | 截止日期前提醒用户 | 低 |

### 2.5 数据持久化

| 需求编号 | 功能点 | 描述 | 优先级 |
| :--- | :--- | :--- | :--- |
| FR-015 | 本地存储 | 使用 Core Data 存储任务数据 | 高 |
| FR-016 | 数据导入导出 | 支持任务数据的导入导出（JSON格式） | 低 |

---

## 3. 非功能需求

### 3.1 性能需求

| 需求编号 | 描述 | 要求 |
| :--- | :--- | :--- |
| NFR-001 | 启动时间 | 应用启动时间 ≤ 2秒 |
| NFR-002 | 列表加载 | 1000条任务加载时间 ≤ 1秒 |
| NFR-003 | 响应延迟 | 操作响应延迟 ≤ 100ms |

### 3.2 兼容性需求

| 需求编号 | 描述 | 要求 |
| :--- | :--- | :--- |
| NFR-004 | macOS版本 | 支持 macOS 12.0+ |
| NFR-005 | 硬件适配 | 支持 Intel 和 Apple Silicon 芯片 |

### 3.3 安全性需求

| 需求编号 | 描述 | 要求 |
| :--- | :--- | :--- |
| NFR-006 | 数据加密 | 敏感数据本地加密存储 |
| NFR-007 | 备份恢复 | 支持数据备份到 iCloud |

---

## 4. 技术架构

### 4.1 技术栈

| 分类 | 技术 | 版本 |
| :--- | :--- | :--- |
| 语言 | Swift | 5.7+ |
| 框架 | AppKit | macOS SDK |
| 数据库 | Core Data | - |
| UI框架 | SwiftUI | 3.0+ |

### 4.2 架构设计

**架构风格**: MVVM (Model-View-ViewModel)

```
┌─────────────────────────────────────────────────────────┐
│                      View Layer                         │
│  [TaskListView] [TaskDetailView] [CategoryView]       │
└───────────────────────────┬─────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                   ViewModel Layer                       │
│  [TaskViewModel] [CategoryViewModel] [SearchViewModel] │
└───────────────────────────┬─────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                    Model Layer                          │
│  [Task] [Category] [Priority] [DueDate]                │
└───────────────────────────┬─────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                    Data Layer                           │
│  [CoreDataManager] [TaskRepository] [BackupManager]    │
└─────────────────────────────────────────────────────────┘
```

### 4.3 核心数据模型

#### 4.3.1 Task（任务）

| 属性名 | 类型 | 约束 | 说明 |
| :--- | :--- | :--- | :--- |
| id | UUID | 主键，非空 | 任务唯一标识 |
| title | String | 非空，最大255字符 | 任务标题 |
| description | String | 可选 | 任务描述 |
| isCompleted | Bool | 默认false | 完成状态 |
| priority | Int16 | 默认0 | 优先级（0=低，1=中，2=高） |
| dueDate | Date | 可选 | 截止日期 |
| createdAt | Date | 非空 | 创建时间 |
| updatedAt | Date | 非空 | 更新时间 |
| category | Category | 可选 | 关联分类 |

#### 4.3.2 Category（分类）

| 属性名 | 类型 | 约束 | 说明 |
| :--- | :--- | :--- | :--- |
| id | UUID | 主键，非空 | 分类唯一标识 |
| name | String | 非空，最大100字符 | 分类名称 |
| color | String | 默认"#007AFF" | 分类颜色 |
| tasks | Set<Task> | 可选 | 关联任务列表 |

---

## 5. 用户界面设计

### 5.1 主界面布局

```
┌───────────────────────────────────────────────────────┐
│  ┌─────────────────┐  ┌─────────────────────────────┐ │
│  │   分类侧边栏    │  │           工具栏            │ │
│  │   • 全部任务    │  │ [搜索框] [添加任务] [排序]   │ │
│  │   • 工作        │  └─────────────────────────────┘ │
│  │   • 生活        │                                  │
│  │   • 学习        │  ┌─────────────────────────────┐ │
│  │   • 已完成      │  │       任务列表区域          │ │
│  └─────────────────┘  │                             │ │
│                       │  [ ] 任务标题1              │ │
│                       │  [✓] 任务标题2              │ │
│                       │  [ ] 任务标题3（高优先级）   │ │
│                       │                             │ │
│                       └─────────────────────────────┘ │
└───────────────────────────────────────────────────────┘
```

### 5.2 界面原型说明

| 页面 | 功能 | 设计要点 |
| :--- | :--- | :--- |
| 主页面 | 任务列表展示 | 左侧分类导航，右侧任务列表 |
| 添加/编辑弹窗 | 创建和编辑任务 | 模态弹窗，包含标题、描述、优先级、截止日期、分类选择 |
| 分类管理 | 管理任务分类 | 弹窗形式，支持增删改 |

---

## 6. API 接口设计

### 6.1 Core Data 实体操作

#### Task 实体 CRUD 操作

| 操作 | 方法名 | 参数 | 返回值 |
| :--- | :--- | :--- | :--- |
| 创建 | `createTask(title:description:priority:dueDate:category:)` | title: String, description: String?, priority: Int16, dueDate: Date?, category: Category? | Task? |
| 查询全部 | `fetchAllTasks()` | 无 | [Task] |
| 按分类查询 | `fetchTasksByCategory(_ category: Category)` | category: Category | [Task] |
| 按条件查询 | `fetchTasks(predicate:)` | predicate: NSPredicate | [Task] |
| 更新 | `updateTask(_ task: Task, title:description:priority:dueDate:category:)` | task: Task, 其他同上 | Bool |
| 删除 | `deleteTask(_ task: Task)` | task: Task | Bool |

#### Category 实体 CRUD 操作

| 操作 | 方法名 | 参数 | 返回值 |
| :--- | :--- | :--- | :--- |
| 创建 | `createCategory(name:color:)` | name: String, color: String | Category? |
| 查询全部 | `fetchAllCategories()` | 无 | [Category] |
| 更新 | `updateCategory(_ category: Category, name:color:)` | category: Category, name: String, color: String | Bool |
| 删除 | `deleteCategory(_ category: Category)` | category: Category | Bool |

---

## 7. 数据存储设计

### 7.1 Core Data 模型

**数据模型文件**: `TodoList.xcdatamodeld`

#### Task 实体属性

| 属性名 | 类型 | 是否可选 | 默认值 |
| :--- | :--- | :--- | :--- |
| id | UUID | 否 | - |
| title | String | 否 | - |
| description | String | 是 | nil |
| isCompleted | Boolean | 否 | false |
| priority | Integer 16 | 否 | 0 |
| dueDate | Date | 是 | nil |
| createdAt | Date | 否 | Current Date |
| updatedAt | Date | 否 | Current Date |

#### Category 实体属性

| 属性名 | 类型 | 是否可选 | 默认值 |
| :--- | :--- | :--- | :--- |
| id | UUID | 否 | - |
| name | String | 否 | - |
| color | String | 否 | #007AFF |

#### 关系

| 关系名 | 源实体 | 目标实体 | 类型 | 反向关系 |
| :--- | :--- | :--- | :--- | :--- |
| category | Task | Category | To One | tasks |
| tasks | Category | Task | To Many | category |

### 7.2 数据迁移策略

- **轻量级迁移**: 支持简单的模型变更（添加可选属性、重命名属性）
- **重量级迁移**: 复杂变更时使用自定义迁移策略

### 7.3 打包

- **打包格式**: IPA
- **打包工具**: Xcode
- **打包目标**: iOS 15.0 及以上版本
- **打包目标**: 打包到本地生成生成'.dmg'文件，方便用户安装

---

## 8. 开发计划

### 8.1 里程碑规划

| 阶段 | 时间 | 目标 |
| :--- | :--- | :--- |
| 第一阶段 | 第1-2周 | 项目初始化、Core Data 配置、基础 UI |
| 第二阶段 | 第3-4周 | 任务 CRUD 功能实现 |
| 第三阶段 | 第5-6周 | 分类管理、优先级、截止日期功能 |
| 第四阶段 | 第7-8周 | 搜索、排序、数据导入导出 |
| 第五阶段 | 第9-10周 | 测试、Bug修复、优化 |

### 8.2 资源需求

| 资源类型 | 需求 |
| :--- | :--- |
| 开发人员 | 1-2名 Swift 开发工程师 |
| 设计人员 | 1名 UI/UX 设计师 |
| 测试人员 | 1名 QA 工程师 |

---

## 9. 附录

### 9.1 优先级定义

| 优先级 | 定义 |
| :--- | :--- |
| 高 | 必须实现，核心功能 |
| 中 | 建议实现，增强体验 |
| 低 | 可选实现，锦上添花 |

### 9.2 状态定义

| 状态 | 说明 |
| :--- | :--- |
| 待开发 | 尚未开始开发 |
| 开发中 | 正在实现 |
| 测试中 | 功能完成，正在测试 |
| 已完成 | 功能完成并通过测试 |

### 9.3 参考文档

1. [Apple Developer Documentation](https://developer.apple.com/documentation/)
2. [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
3. [Core Data Programming Guide](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreData/index.html)

---

**文档版本**: v1.0  
**创建日期**: 2026-05-15  
**作者**: TodoList 开发团队