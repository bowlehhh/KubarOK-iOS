// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KubarOKCore",
    products: [
        .library(
            name: "KubarOKCore",
            targets: ["KubarOKCore"]
        ),
        .executable(
            name: "KubarOKAPITest",
            targets: ["KubarOKAPITest"]
        ),
        .executable(
            name: "KubarOKAuthTest",
            targets: ["KubarOKAuthTest"]
        ),
        .executable(
            name: "KubarOKRegistrationTest",
            targets: ["KubarOKRegistrationTest"]
        ),
        .executable(
            name: "KubarOKAuthFlowTest",
            targets: ["KubarOKAuthFlowTest"]
        ),
    ],
    targets: [
        .target(
            name: "KubarOKCore"
        ),
        .executableTarget(
            name: "KubarOKAPITest",
            dependencies: ["KubarOKCore"]
        ),
        .executableTarget(
            name: "KubarOKAuthTest",
            dependencies: ["KubarOKCore"]
        ),
        .executableTarget(
            name: "KubarOKRegistrationTest",
            dependencies: ["KubarOKCore"]
        ),
        .executableTarget(
            name: "KubarOKAuthFlowTest",
            dependencies: ["KubarOKCore"]
        ),
        .testTarget(
            name: "KubarOKCoreTests",
            dependencies: ["KubarOKCore"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
