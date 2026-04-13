#!/usr/bin/env python3

import argparse
import csv
import json
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parent


def parse_args():
    parser = argparse.ArgumentParser(description='Filter Forex Factory calendar CSV and emit JSON.')
    parser.add_argument('--csv', dest='csv_file', required=True, help='CSV file to read.')
    parser.add_argument('--today', action='store_true', help='Filter events for today.')
    parser.add_argument('--date', help='Filter events for DD/MM/YYYY.')
    parser.add_argument('--high', action='store_true', help='Only high impact events.')
    parser.add_argument('--medium', action='store_true', help='Only medium impact events.')
    parser.add_argument('--low', action='store_true', help='Only low impact events.')
    parser.add_argument('--out', help='Write JSON output to file instead of stdout.')
    return parser.parse_args()


def resolve_csv_path(csv_file: str) -> Path:
    csv_path = Path(csv_file)
    if not csv_path.is_absolute():
        csv_path = (ROOT / csv_path).resolve()
    return csv_path


def parse_csv_rows(csv_path: Path):
    with csv_path.open(newline='', encoding='utf-8') as fh:
        return list(csv.DictReader(fh))


def parse_row_date(value: str):
    parts = value.split()
    if len(parts) < 2:
        return None
    try:
        month = datetime.strptime(parts[0], '%b').month
        day = int(parts[1])
    except ValueError:
        return None
    return month, day


def resolve_date_filter(args):
    if args.today:
        now = datetime.now()
        return now.month, now.day
    if args.date:
        try:
            parsed = datetime.strptime(args.date, '%d/%m/%Y')
        except ValueError as exc:
            raise SystemExit(f'Invalid --date value: {args.date!r}. Expected DD/MM/YYYY.') from exc
        return parsed.month, parsed.day
    now = datetime.now()
    return now.month, now.day


def impact_filter(args):
    selected = [name for name, enabled in [('high', args.high), ('medium', args.medium), ('low', args.low)] if enabled]
    if len(selected) > 1:
        raise SystemExit('Use only one impact flag: --high, --medium, or --low.')
    if not selected:
        return None
    return selected[0]


def main():
    args = parse_args()
    csv_path = resolve_csv_path(args.csv_file)
    if not csv_path.exists():
        raise SystemExit(f'CSV file not found: {args.csv_file!r}')
    target_month, target_day = resolve_date_filter(args)
    selected_impact = impact_filter(args)

    rows = []
    for row in parse_csv_rows(csv_path):
        row_date = parse_row_date(row.get('Date', ''))
        if not row_date:
            continue
        if row_date != (target_month, target_day):
            continue
        if selected_impact and row.get('Impact', '').lower() != selected_impact:
            continue
        rows.append(row)

    output = json.dumps(rows, ensure_ascii=False, indent=2)
    if args.out:
        Path(args.out).write_text(output, encoding='utf-8')
    else:
        print(output)


if __name__ == '__main__':
    main()
