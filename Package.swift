// swift-tools-version:5.0
import PackageDescription

#if os(Linux)
let package = Package(
    name: "gattserver",
    products: [
        .executable(
            name: "gattserver",
            targets: ["gattserver"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/ComputeCycles/GATT", .branch("swift5")),
        .package(url: "https://github.com/ComputeCycles/BluetoothLinux", .branch("swift5"))
    ],
    targets: [
        .target(
            name: "gattserver",
            dependencies: ["GATT", "BluetoothLinux"]
        )
    ]
)
#elseif os(macOS)
let package = Package(
    name: "gattserver",
    products: [
        .executable(
            name: "gattserver",
            targets: ["gattserver"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/ComputeCycles/GATT", .branch("swift5")),
        .package(url: "https://github.com/ComputeCycles/BluetoothDarwin", .branch("swift5"))
    ],
    targets: [
        .target(
            name: "gattserver",
            dependencies: ["DarwinGATT", "BluetoothDarwin"]
        )
    ]
)
#endif
