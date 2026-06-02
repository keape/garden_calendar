// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "GardenCalendar",
    platforms: [
        .iOS(.v18)
    ],
    dependencies: [
        .package(
            url: "https://github.com/supabase-community/supabase-swift.git",
            from: "2.0.0"
        )
    ],
    targets: [
        .target(
            name: "GardenCalendar",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift")
            ],
            path: "GardenCalendar"
        )
    ]
)
