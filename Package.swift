// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "EGDeclarativeUIKit",
    platforms: [.iOS("10.0")],
    products: [
        .library(name: "EGDeclarativeUIKit", targets: ["EGDeclarativeUIKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/EkkoG/EGChainable.git", from: "0.3.0"),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.5.0"),
        // SnapKit 5.7 raises its minimum to iOS 12.
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMinor(from: "5.6.0"))
    ],
    targets: [
        .target(
            name: "EGDeclarativeUIKit",
            dependencies: [
                .product(name: "EGChainable", package: "EGChainable"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxCocoa", package: "RxSwift"),
                .product(name: "SnapKit", package: "SnapKit")
            ],
            path: "DeclarativeUIKit/Classes"
        ),
        .testTarget(
            name: "EGDeclarativeUIKitTests",
            dependencies: [
                "EGDeclarativeUIKit",
                .product(name: "EGChainable", package: "EGChainable"),
                .product(name: "RxSwift", package: "RxSwift")
            ],
            path: "Example/Tests",
            exclude: ["Info.plist"]
        )
    ],
    swiftLanguageVersions: [.v5]
)
