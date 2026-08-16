// swift-tools-version: 6.3
import PackageDescription

let package = Package(
    name: "KubarOKApp",
    products: [
        .library(name: "KubarOKAppCore", targets: ["KubarOKAppCore"])
    ],
    dependencies: [
        .package(path: "../../Packages/KubarOKCore")
    ],
    targets: [
        .target(
            name: "KubarOKAppCore",
            dependencies: [
                .product(name: "KubarOKCore", package: "KubarOKCore")
            ],
            path: "Core"
        ),
        .testTarget(
            name: "KubarOKAppCoreTests",
            dependencies: [
                "KubarOKAppCore",
                .product(name: "KubarOKCore", package: "KubarOKCore")
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
