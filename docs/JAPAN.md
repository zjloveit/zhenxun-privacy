# 日本向け設定（地震速報）

## データソース

| 種別 | Wolfx API | 出典 |
|------|-----------|------|
| 地震情報一覧 | `https://api.wolfx.jp/jma_eqlist.json` | 気象庁（最大50件） |
| 緊急地震速報 | `https://api.wolfx.jp/jma_eew.json` | 気象庁 EEW |
| WebSocket | `wss://ws-api.wolfx.jp/jma_eew` | リアルタイム EEW |

公式ドキュメント：https://wolfx.jp/apidoc

**注意**：Wolfx は第三者サービスです。気象庁の公式アプリ（「緊急地震速報」等）に代わるものではありません。

## App Store（日本）

- 表示名：**地震速報**
- 言語：日本語 UI
- プライバシー：第三者 API・AdMob を明記
- 緊急地震速報の文言で「非公式」「推定」と明記（アプリ内済み）

## テスト

1. [Wolfx](https://wolfx.jp/) でアプリ未公開の場合、テスト端末を登録
2. 実機で WebSocket 接続を確認（ホーム画面の接続状態）
3. 訓練報（`isTraining`）・取消（`isCancel`）は通知対象外

## 広告

AdMob のまま利用可能。日本向けは AdMob のみでも運用可能（Sigmob 等は任意）。
