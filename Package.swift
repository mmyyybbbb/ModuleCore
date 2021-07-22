// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "ModuleCore",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(name: "ModuleCore", targets: ["ModuleCore"])
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMinor(from: "6.0.0")),
        .package(url: "https://github.com/RxSwiftCommunity/RxDataSources", .upToNextMinor(from: "5.0.0")),
        .package(url: "https://github.com/ReactorKit/ReactorKit", .upToNextMajor(from: "3.0.0")),
        .package(url: "https://github.com/devxoul/RxViewController", .upToNextMinor(from: "2.0.0"))
    ],
    targets: [
        .target(
            name: "ModuleCore",
            dependencies: ["RxCocoa",
                           "RxDataSources",
                           "ReactorKit",
                           "RxViewController"],
            path: "ModuleCore"
        )
    ]
)
