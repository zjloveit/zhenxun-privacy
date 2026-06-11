# 地震速報ヘルパー

日本向けの地震情報・緊急地震速報（EEW）リマインダー iOS アプリ（SwiftUI）。

## 機能

- 気象庁の地震情報（Wolfx API 経由、最大50件）
- 緊急地震速報の WebSocket 受信とローカル通知
- 地図・到達時間の簡易推定
- プライバシー同意・免責表示

## 技術

- iOS 17+ / SwiftUI
- データ：[Wolfx Project](https://wolfx.jp/)（JMA）
- 広告：Google AdMob（任意）

## 重要

本アプリは**気象庁の公式アプリではありません**。第三者データに基づく情報ツールです。詳細は `docs/JAPAN.md`。

## ビルド

```bash
open 地震预警.xcodeproj
```

Bundle ID: `com.dizhenyujing.app`（変更する場合は AdMob・証明書も合わせて更新）
