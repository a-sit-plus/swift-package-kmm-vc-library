// swift-tools-version:5.3
import PackageDescription

let package = Package(
  name: "VcLibKmm",
  platforms: [
    .iOS(.v12)
  ],
  products: [
    .library(
      name: "VcLibKmm",
      targets: ["VcLibKmm"]
    ),
    .library(
      name: "VcLibAriesKmm",
      targets: ["VcLibAriesKmm"]
    ),
    .library(
      name: "VcLibOpenIdKmm",
      targets: ["VcLibOpenIdKmm"]
    )
  ],
  targets: [
    .binaryTarget(
      name: "VcLibKmm",
      url: "https://github.com/a-sit-plus/kmm-vc-library/releases/download/3.0.0/VcLibKmm-release.xcframework.zip",
      checksum: "2a1f7b0d24557bb915d40b5de7fd212bb8d193928956ab2369533ab995aaf6be"
    ),
    .binaryTarget(
      name: "VcLibAriesKmm",
      url: "https://github.com/a-sit-plus/kmm-vc-library/releases/download/3.0.0/VcLibAriesKmm-release.xcframework.zip",
      checksum: "53d915b74a52dfbe0ed6d59f77ff9f171907c13807d602495b1be9ce9ce41fc5"
    ),
    .binaryTarget(
      name: "VcLibOpenIdKmm",
      url: "https://github.com/a-sit-plus/kmm-vc-library/releases/download/3.0.0/VcLibOpenIdKmm-release.xcframework.zip",
      checksum: "fe24227493b9e6714475049c114e9f2c523f0cdc4436d3714d1623ccc33538a7"
    )
  ]
)
