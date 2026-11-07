# askhub-sandbox

## 全員向けの事実

- AskHub の試運転用の小さい iOS アプリ（SwiftUI、iOS 17 以降）。画面はメモの一覧と追加だけ
- 画面とデータは `Sources/SandboxApp/` の下にある（`ContentView` が一覧、`MemoStore` が保存）
- Xcode のプロジェクトは `SandboxApp.xcodeproj`（`project.yml` から XcodeGen で作ったもの）。スキームは `SandboxApp`。`Sources/SandboxApp/` と `Tests/SandboxAppTests/` はフォルダごとプロジェクトに入っているので、ファイルを足してもプロジェクトのファイルを直さなくてよい
- テストは Swift Testing で `Tests/SandboxAppTests/` に置く（`MemoStoreTests` など）。保存を確かめるテストは、テストごとに別の `UserDefaults(suiteName:)` を使う
- CI は GitHub Actions の `build`（PR と develop・main への push で、iOS の Simulator でビルドとテスト）
- データは端末の中（UserDefaults）だけに置く。サーバーやログインは無い

## 人のセッション向けの手順

- 試運転のためのリポジトリなので、App Store には出さない
