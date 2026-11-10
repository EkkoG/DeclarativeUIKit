// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "EGDeclarativeUIKit",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "EGDeclarativeUIKit", targets: ["EGDeclarativeUIKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/EkkoG/EGChainable.git", branch: "codex/spm-backport"),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.10.2"),
        .package(url: "https://github.com/SnapKit/SnapKit.git", from: "6.0.0")
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
        )
    ],
    swiftLanguageModes: [.v5]
)
