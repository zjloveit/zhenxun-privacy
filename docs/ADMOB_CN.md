# 国内 AdMob 变现配置指南

## 1. 注册 AdMob

1. 打开 [Google AdMob](https://admob.google.com/)（需能访问 Google 服务）
2. 添加应用 → 选择 **iOS** → 填写 Bundle ID：`com.dizhenyujing.app`
3. 创建 **横幅广告** 单元，分别用于首页、速报、设置（或共用一个单元）

**个人开发者** 可使用 AdMob 个人账户；不要求企业执照。

## 2. 替换代码中的广告 ID

编辑 `地震预警/Services/AdConfig.swift`：

- `productionAppID`（已配置则跳过）
- 各横幅单元 ID

编辑 `地震预警/Resources/Info.plist`：

- `GADApplicationIdentifier` → 与 AdMob **应用 ID** 相同

## 3. 在 Xcode 中拉取 SDK

**File → Packages → Resolve Package Versions**

依赖：`https://github.com/googleads/swift-package-manager-google-mobile-ads.git`

## 4. 国内填充率（个人开发者）

- **穿山甲、优量汇** 等国内联盟通常 **不支持纯个人**，见 [MEDIATION_CN.md](./MEDIATION_CN.md)。
- 个人上架阶段：**以 AdMob 为主**即可；空白横幅在国内较常见，有流量后可能改善。
- 可在 AdMob **中介** 中尝试 **Unity Ads** 等国际源（个人相对容易开通）。

## 5. 上架合规

- App Store **App 隐私** 问卷：声明广告标识符、定位（若用于广告）
- 提供 **隐私政策** 网页，说明 AdMob / 第三方广告收集
- 预警全屏界面 **不展示** 广告

## 6. 测试

Debug 可使用 Google 测试 ID（若工程内保留测试开关）。正式包用正式 ID，勿自己点击广告。
