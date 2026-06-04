# 国内 AdMob 变现配置指南

## 1. 注册 AdMob

1. 打开 [Google AdMob](https://admob.google.com/)（需能访问 Google 服务）
2. 添加应用 → 选择 **iOS** → 填写 Bundle ID：`com.dizhenyujing.app`
3. 创建 **横幅广告** 单元，分别用于首页、速报、设置（或共用一个单元）

## 2. 替换代码中的广告 ID

编辑 `地震预警/Services/AdConfig.swift`：

- `productionAppID`
- `productionBannerHome` / `productionBannerEventList` / `productionBannerSettings`

编辑 `地震预警/Resources/Info.plist`：

- `GADApplicationIdentifier` → 改为与 `productionAppID` **相同** 的应用 ID

Release 构建时 `DEBUG` 宏关闭后会自动使用生产 ID。

## 3. 在 Xcode 中拉取 SDK

首次打开工程后：

**File → Packages → Resolve Package Versions**

若未看到 Google Mobile Ads，在 **Project → Package Dependencies** 中确认已添加：

`https://github.com/googleads/swift-package-manager-google-mobile-ads.git`

## 4. 提升国内填充率（重要）

大陆用户单独用 AdMob 时填充率可能偏低，建议在 AdMob 后台开通 **中介（Mediation）** 并接入：

| 平台 | 说明 |
|------|------|
| **穿山甲 Pangle** | 字节跳动，国内填充主力 |
| **优量汇 GDT** | 腾讯 |
| **百度、快手** | 按 AdMob 后台可选 |

路径：AdMob → 中介 → 添加广告来源 → 按文档集成各 SDK Adapter。

## 5. 上架合规

- App Store **App 隐私** 问卷：声明广告标识符、定位（若用于广告）
- 提供 **隐私政策** 网页，说明 AdMob / 第三方广告收集
- 预警全屏界面 **已禁止** 展示广告；勿在倒计时期间加插屏

## 6. 测试

Debug 构建使用 Google 官方测试 ID，界面会显示 “Test Ad” 或 “测试广告”。

真机验收收入前请改用正式 ID，并避免自己点击广告（会被封号）。
