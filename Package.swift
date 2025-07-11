
// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "TeleprompterVIBE",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "TeleprompterVIBE",
            targets: ["TeleprompterVIBE"])
    ],
    targets: [
        .executableTarget(
            name: "TeleprompterVIBE",
            path: "Sources/TeleprompterVIBE"
        )
    ]
)
