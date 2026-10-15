#!/bin/bash
# どら山 在庫ダッシュボードを GitHub Pages へ初回公開（Mac mini 上で実行）
# トークンは画面に出さない。既存なら作成をスキップして push/pages へ進む。
set -u
OWNER=sususuyasusu
REPO=dorayama-stock
DIR=~/dw-stock-dashboard
TOKEN=$(awk '/oauth_token:/{print $2; exit}' ~/.config/gh/hosts.yml)
if [ -z "$TOKEN" ]; then echo "ERROR: no token"; exit 2; fi
AUTH="Authorization: token $TOKEN"
API=https://api.github.com

echo "== create repo =="
code=$(curl -sS -o /tmp/dw_repo.json -w "%{http_code}" -X POST -H "$AUTH" -H "Accept: application/vnd.github+json" \
  $API/user/repos \
  -d '{"name":"dorayama-stock","description":"どら山 在庫ダッシュボード（店舗vs最低のバー可視化・スマホ向け）","private":false,"has_issues":false,"has_wiki":false,"has_projects":false}')
echo "http=$code"
python3 -c "import json;d=json.load(open('/tmp/dw_repo.json'));print('repo:',d.get('full_name') or d.get('message'))" 2>/dev/null

echo "== push =="
cd $DIR || exit 3
git remote remove origin 2>/dev/null
git remote add origin https://github.com/$OWNER/$REPO.git
git -c credential.helper= push "https://x-access-token:$TOKEN@github.com/$OWNER/$REPO.git" main 2>&1 | sed -E "s#x-access-token:[^@]*@#x-access-token:TOKEN@#g"

echo "== enable pages =="
pcode=$(curl -sS -o /tmp/dw_pages.json -w "%{http_code}" -X POST -H "$AUTH" -H "Accept: application/vnd.github+json" \
  $API/repos/$OWNER/$REPO/pages \
  -d '{"source":{"branch":"main","path":"/"}}')
echo "http=$pcode"
python3 -c "import json;d=json.load(open('/tmp/dw_pages.json'));print('pages:',d.get('html_url') or d.get('message'))" 2>/dev/null
echo "DONE expected URL: https://$OWNER.github.io/$REPO/"
