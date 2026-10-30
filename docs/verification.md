# 動作確認記録

確認日：2026-10-30（日本時間）。実行環境：Docker / Ruby 3.4.12 / Rails 8.1.4。

| 検証 | 結果 |
| --- | --- |
| SQLite モデル・結合テスト | 21 runs / 128 assertions / 0 failures / 0 errors / 0 skips |
| PostgreSQL 17 モデル・結合テスト | 21 runs / 128 assertions / 0 failures / 0 errors / 0 skips |
| PostgreSQL 本番モード | マイグレーション・サンプル作成・リセット・関連削除に成功 |
| 本番HTTPスモーク | ボード・作成・詳細・Turbo状態変更・リセットに成功。CSRFトークンなしのPOSTは422 |
| Render用起動コマンド | マイグレーション→期限切れ削除→Puma起動に成功 |
| 起動確認 | 開発 `/`、本番 `/`、本番 `/up` がHTTP 200 |
| 本番Docker | ビルド成功。master.keyを含まない非rootイメージで `/` と `/up` がHTTP 200 |
| Zeitwerk | 自動読み込み検証成功 |
| アセット | 本番プリコンパイル成功 |
| Brakeman | 0 errors / 0 security warnings |
| bundler-audit | No vulnerabilities found |
| Importmap audit | No vulnerable packages found |
| ブラウザ操作 | サンプル表示・タスク作成・状態変更・カード移動・完了率更新・リセットを確認 |
| レスポンシブ | 390pxで縦1列、1280pxで3列のKanbanを確認。390pxで横はみ出しなし |

## 再実行

通常のテスト：`bin/rails test`。

PostgreSQLでのテストは**専用の使い捨てテストDB**を使います。

```sh
RAILS_ENV=test DATABASE_URL=postgresql://USER:PASSWORD@HOST/taskflow_test bin/rails db:prepare test
```

本番HTTPスモークも**専用の使い捨てDB**に対して実行してください。テストデータの作成・削除を伴います。

```sh
export RAILS_ENV=production
export DATABASE_URL=postgresql://USER:PASSWORD@HOST/taskflow_smoke
export SECRET_KEY_BASE="$(bin/rails secret)"
bin/rails db:prepare
bin/rails runner script/production_smoke.rb
```

外部公開URLの疎通はRenderの認証後に別途確認が必要です。公開成功はまだ確認していません。
