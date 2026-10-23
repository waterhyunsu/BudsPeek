// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "BudsPeek",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "BudsPeek", targets: ["BudsPeek"])
    ],
    targets: [
        .target(name: "BudsPeekCore", path: "Sources/BudsPeekCore", publicHeadersPath: "include"),
        .executableTarget(
            name: "BudsPeek",
            dependencies: ["BudsPeekCore"],
            linkerSettings: [
                .linkedFramework("IOBluetooth"),
                .linkedFramework("CoreBluetooth")
            ]
        )
    ],
    cxxLanguageStandard: .cxx17
)
