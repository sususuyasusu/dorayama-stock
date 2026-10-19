#!/usr/bin/env python3
# どら山 在庫アプリのアプリアイコンを、どら山の紋章ロゴ（門仲＋とら のアーチ印）から生成する。
# コーラル地(#D85A30)に白いロゴを中央配置。apple-touch-icon(180)/icon-192/icon-512 を書き出す。
# ロゴ原本は Dropbox の どら山/logo/logo_4.png（マーク部分のみ・黒/透過）。
import os
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
SRC_CANDIDATES = [
    "/Users/suzuki3/Library/CloudStorage/Dropbox-Detale/D& W/どら山/logo/logo_4.png",
    os.path.expanduser("~/Detale Dropbox/D& W/どら山/logo/logo_4.png"),
    os.path.join(HERE, "logo_4.png"),
]
SRC = next((p for p in SRC_CANDIDATES if os.path.exists(p)), None)
CORAL = (216, 90, 48)   # #D85A30
RATIO = 0.78            # マーク幅/キャンバス幅（マスカブル安全域）

def tinted(src, rgb):
    r, g, b, a = src.split()
    solid = Image.new("RGBA", src.size, rgb + (255,))
    solid.putalpha(a)
    return solid

def make(size, path):
    canvas = Image.new("RGBA", (size, size), CORAL + (255,))
    m = tinted(Image.open(SRC).convert("RGBA"), (255, 255, 255))
    tw = int(size * RATIO); th = int(tw * m.height / m.width)
    m = m.resize((tw, th), Image.LANCZOS)
    canvas.alpha_composite(m, ((size - tw) // 2, (size - th) // 2))
    canvas.convert("RGB").save(path, "PNG")
    print("saved", path)

if not SRC:
    raise SystemExit("logo_4.png が見つかりません")
make(180, os.path.join(HERE, "apple-touch-icon.png"))
make(192, os.path.join(HERE, "icon-192.png"))
make(512, os.path.join(HERE, "icon-512.png"))
print("done")
