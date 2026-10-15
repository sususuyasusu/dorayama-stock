# どら山 在庫ダッシュボード

店舗在庫と最低ラインを横バーで見える化する、スマホ向けの一覧ページ。

- 公開URL: https://sususuyasusu.github.io/dorayama-stock/
- データ: `data.json`（商品マスタから自動生成。品名・カテゴリー・倉庫/店舗/最低・配送状況・お届け予定・賞味期限のみ。発注先や連絡先は含めない）
- 更新: Mac mini が商品マスタを読んで `data.json` を定期更新→push（裏方の `build_data.py`。このリポジトリには含めない）
- 在庫アプリ（AppSheet）本体: https://www.appsheet.com/start/c1321275-432b-435c-a679-4406e892d7a6
