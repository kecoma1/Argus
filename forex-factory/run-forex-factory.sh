#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$ROOT_DIR/forex-factory/forex-factory.py"
CSV_FILE="forex-factory/forexfactory-calendar.csv"
CSV_ABS="$ROOT_DIR/$CSV_FILE"

python3 - <<'PY' "$CSV_ABS" "$SCRIPT"
import csv
import json
import subprocess
import sys
from collections import OrderedDict
from datetime import datetime

csv_path = sys.argv[1]
script = sys.argv[2]

dates = OrderedDict()

with open(csv_path, newline='', encoding='utf-8') as fh:
    for row in csv.DictReader(fh):
        value = row.get('Date', '')
        parts = value.split()
        if len(parts) < 2:
            continue
        try:
            month = datetime.strptime(parts[0], '%b').month
            day = int(parts[1])
        except ValueError:
            continue
        key = f'{day:02d}/{month:02d}/2026'
        dates.setdefault(key, None)

sample_dates = list(dates.keys())[:3]
assert sample_dates, 'No dates found in CSV'

for date_value in sample_dates:
    output = subprocess.check_output(['python3', script, f'--csv={csv_path}', '--date', date_value], text=True)
    rows = json.loads(output)
    assert isinstance(rows, list), f'{date_value}: output is not a list'
    assert rows, f'{date_value}: expected at least one row'
    for row in rows:
        assert row.get('Date'), f'{date_value}: missing Date field'
        assert row.get('Currency'), f'{date_value}: missing Currency field'
        assert row.get('Impact') in {'low', 'medium', 'high'}, f'{date_value}: invalid Impact field'

base_date = sample_dates[1] if len(sample_dates) > 1 else sample_dates[0]
all_rows = json.loads(subprocess.check_output(['python3', script, f'--csv={csv_path}', '--date', base_date], text=True))
high_rows = json.loads(subprocess.check_output(['python3', script, f'--csv={csv_path}', '--date', base_date, '--high'], text=True))
medium_rows = json.loads(subprocess.check_output(['python3', script, f'--csv={csv_path}', '--date', base_date, '--medium'], text=True))
low_rows = json.loads(subprocess.check_output(['python3', script, f'--csv={csv_path}', '--date', base_date, '--low'], text=True))

assert len(high_rows) <= len(all_rows), 'High filter returned more rows than base query'
assert len(medium_rows) <= len(all_rows), 'Medium filter returned more rows than base query'
assert len(low_rows) <= len(all_rows), 'Low filter returned more rows than base query'

print(f'Validated {len(sample_dates)} dates and impact filters for {base_date}.')
PY
