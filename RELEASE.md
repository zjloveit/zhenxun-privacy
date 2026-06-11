# Release 构建与上架

## 打包步骤

1. Xcode 顶部选 **Any iOS Device (arm64)**
2. **Product → Archive**（自动使用 **Release** 配置）
3. Organizer → **Distribute App** → App Store Connect → Upload

## 本版本 Release 已移除

- 测试广告 ID 与 Debug 广告开关
- 演示预警按钮
- 广告加载调试面板
- Wolfx 开发者链接
- SwiftUI Preview 代码块

## 版本号

- 用户可见版本：`1.0.0`（Info.plist `CFBundleShortVersionString`）
- 构建号：`2`（每次上传 App Store 前递增 `CFBundleVersion`）

## 开发调试

日常开发仍可用 **Debug** 配置 Run；仅 Archive 用于上架。

开发文档保留在仓库 `docs/`，不会打入 App 安装包。
