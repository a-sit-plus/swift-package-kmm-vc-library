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
      url: "https://github.com/a-sit-plus/kmm-vc-library/releases/download/3.0.2/VcLibKmm-release.xcframework.zip",
      checksum: "438adc99e1670493ba3045d8d7d499595744ceab0cf3a3677c2f23148afb2dde"
    ),
    .binaryTarget(
      name: "VcLibAriesKmm",
      url: "https://github.com/a-sit-plus/kmm-vc-library/releases/download/3.0.2/VcLibAriesKmm-release.xcframework.zip",
      checksum: "04e6b06960662bc04c8af112a162a196c37ec239fe6a124e5d9cbb3cbc1f1a0a"
    ),
    .binaryTarget(
      name: "VcLibOpenIdKmm",
      url: "https://github.com/a-sit-plus/kmm-vc-library/releases/download/3.0.2/VcLibOpenIdKmm-release.xcframework.zip",
      checksum: "00954a615823a04972a2917dd310bf301e757836069a8ba6e0f2f670752b6fac"
    )
  ]
)
