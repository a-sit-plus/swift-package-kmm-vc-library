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
      url: "https://github.com/a-sit-plus/kmm-vc-library/releases/download/3.2.0/VcLibKmm-release.xcframework.zip",
      checksum: "9e92f9829601ccbac7b3ece6f654c907fd39f2651ce12b4b58cfa34d8ea6db2d"
    ),
    .binaryTarget(
      name: "VcLibAriesKmm",
      url: "https://github.com/a-sit-plus/kmm-vc-library/releases/download/3.2.0/VcLibAriesKmm-release.xcframework.zip",
      checksum: "9bea7a3c921e18f1eb4fd6a765ee62df36032288d5059e62e48b4d2eefa0405e"
    ),
    .binaryTarget(
      name: "VcLibOpenIdKmm",
      url: "https://github.com/a-sit-plus/kmm-vc-library/releases/download/3.2.0/VcLibOpenIdKmm-release.xcframework.zip",
      checksum: "7e68b588b371ebc50f114ed9d983da88e54e0ef7a071db0f02cf8f5326506b88"
    )
  ]
)
