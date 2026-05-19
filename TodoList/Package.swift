// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "TodoList",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "TodoList", targets: ["TodoList"])
    ],
    targets: [
        .executableTarget(
            name: "TodoList",
            path: "TodoList",
            exclude: ["Resources/Info.plist"],
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .define("SWIFT_PACKAGE")
            ]
        ),
        .testTarget(
            name: "TodoListTests",
            dependencies: ["TodoList"]
        )
    ]
)
