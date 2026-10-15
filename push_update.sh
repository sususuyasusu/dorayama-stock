#!/bin/bash
# どら山 在庫ダッシュボードのサイト本体(index/manifest/icons等)を公開リポジトリへ反映（Mac mini で実行）
set -u
cd "$HOME/dw-stock-dashboard" || exit 3
TOKEN=$(awk '/oauth_token:/{print $2; exit}' "$HOME/.config/gh/hosts.yml")
git add -A
if git diff --cached --quiet; then echo "no change"; exit 0; fi
git -c user.name="dorayama-mini" -c user.email="y.suzuki1122@gmail.com" \
  commit -q -m "ホーム画面アプリ化(PWA)＋アイコン追加 $(date '+%Y-%m-%d %H:%M')"
git push "https://x-access-token:$TOKEN@github.com/sususuyasusu/dorayama-stock.git" main 2>&1 \
  | sed -E "s#x-access-token:[^@]*@#x-access-token:TOKEN@#g"
echo "pushed"
