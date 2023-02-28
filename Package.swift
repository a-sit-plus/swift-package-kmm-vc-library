// swift-tools-version:5.3
import PackageDescription

let package = Package(
  name: "VcLibKMM",
  platforms: [
    .iOS(.v12)
  ],
  products: [
    .library(
      name: "VcLibKMM",
      targets: ["VcLibKMM"]
    )
  ],
  targets: [
    .binaryTarget(
      name: "VcLibKMM",
      url: "https://github.com/a-sit-plus/kmm-vc-library/releases/download/1.7.2/VcLibKMM-release.xcframework.zip",
      checksum: "f300ef6f17d19fdea87e9088cc9d9c99b3ee894ebab486730262b88c9e353f12"
    )
  ]
)
