#!/bin/bash
# どら山 在庫ダッシュボードのデータを再生成して公開リポジトリへ反映（Mac mini の定時実行用）
set -u
cd "$HOME/dw-stock-dashboard" || exit 3
export DW_GCRED="$HOME/.config/dw/google_credentials.json"
LOG="$HOME/dw-stock-dashboard/refresh.log"

/usr/bin/python3 build_data.py >>"$LOG" 2>&1 || { echo "$(date '+%F %T') build FAILED" >>"$LOG"; exit 1; }

# 健全性チェック：品目数が極端に少ない場合は push しない（取得失敗の空データを公開しない）
/usr/bin/python3 -c "import json;d=json.load(open('data.json'));exit(0 if d.get('count',0)>10 else 1)" \
  || { echo "$(date '+%F %T') sanity FAILED (count<=10) -> skip push" >>"$LOG"; exit 1; }

TOKEN=$(awk '/oauth_token:/{print $2; exit}' "$HOME/.config/gh/hosts.yml")
git add data.json
if git diff --cached --quiet; then
  echo "$(date '+%F %T') no change" >>"$LOG"; exit 0
fi
git -c user.name="dorayama-mini" -c user.email="y.suzuki1122@gmail.com" \
  commit -q -m "在庫データ自動更新 $(date '+%Y-%m-%d %H:%M')" >>"$LOG" 2>&1
git push "https://x-access-token:$TOKEN@github.com/sususuyasusu/dorayama-stock.git" main >>"$LOG" 2>&1 \
  && echo "$(date '+%F %T') pushed" >>"$LOG" \
  || echo "$(date '+%F %T') push FAILED" >>"$LOG"
