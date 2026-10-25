"""発注履歴全体を月別・商品別に集計。個人名・メモは公開しない。"""
from collections import defaultdict

def summarize(hist_by_id, items, updated, error=None):
    if error:
        return {'updated': updated, 'error': '発注履歴を取得できませんでした。次回更新をお待ちください。', 'months': {}}
    catalog = {str(x['id']): x for x in items}
    months = {}
    invalid = 0
    for pid, events in hist_by_id.items():
        for e in events:
            if e['kind'] != '発注':
                continue
            dt = e.get('_t')
            if dt is None:
                invalid += 1
                continue
            month = dt.strftime('%Y-%m')
            m = months.setdefault(month, {'products': {}, 'daily': {}, 'count': 0})
            item = catalog.get(str(pid), {})
            r = m['products'].setdefault(str(pid), {'id': str(pid), 'name': item.get('name', str(pid)), 'cat': item.get('cat', '現在の商品マスタ外'), 'sup': item.get('sup', '不明'), 'count': 0, 'qty': 0, 'qtyKnown': 0, 'days': []})
            day = dt.strftime('%Y-%m-%d')
            r.setdefault('daily', {})[day] = r.setdefault('daily', {}).get(day, 0) + 1
            r['count'] += 1
            if day not in r['days']:
                r['days'].append(day)
            try:
                q = float(str(e['qty']).replace(',', '').strip())
                if q < 0 or not __import__('math').isfinite(q):
                    raise ValueError()
                r['qty'] += q
                r['qtyKnown'] += 1
            except (ValueError, TypeError):
                pass
            m['daily'][day] = m['daily'].get(day, 0) + 1
            m['count'] += 1
    for m in months.values():
        m['products'] = list(m['products'].values())
        for r in m['products']:
            r['days'].sort()
    return {'updated': updated, 'months': months, 'invalidDates': invalid, 'basis': '種別が発注の履歴行数。受領・入庫は除外。数量・ロットから発注を推定しない。'}
