#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
SCRIPT="$ROOT_DIR/forex-factory/fetch/forex-factory.py"
CSV_FILE="forex-factory/fetch/forexfactory-calendar.csv"
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

def run_command(label, command):
    try:
        output = subprocess.check_output(command, text=True)
        rows = json.loads(output)
        assert isinstance(rows, list), f'{label}: output is not a list'
        for row in rows:
            assert row.get('Date'), f'{label}: missing Date field'
            assert row.get('Currency'), f'{label}: missing Currency field'
            assert row.get('Impact') in {'low', 'medium', 'high'}, f'{label}: invalid Impact field'
        print(f'✓ {label}')
        return rows
    except Exception as exc:
        print(f'✗ {label}')
        raise exc

for date_value in sample_dates:
    rows = run_command(date_value, ['python3', script, f'--csv={csv_path}', '--date', date_value])
    assert rows, f'{date_value}: expected at least one row'

base_date = sample_dates[1] if len(sample_dates) > 1 else sample_dates[0]
all_rows = run_command(f'{base_date} base', ['python3', script, f'--csv={csv_path}', '--date', base_date])
high_rows = run_command(f'{base_date} high', ['python3', script, f'--csv={csv_path}', '--date', base_date, '--high'])
medium_rows = run_command(f'{base_date} medium', ['python3', script, f'--csv={csv_path}', '--date', base_date, '--medium'])
low_rows = run_command(f'{base_date} low', ['python3', script, f'--csv={csv_path}', '--date', base_date, '--low'])

assert len(high_rows) <= len(all_rows), 'High filter returned more rows than base query'
assert len(medium_rows) <= len(all_rows), 'Medium filter returned more rows than base query'
assert len(low_rows) <= len(all_rows), 'Low filter returned more rows than base query'

# --out flag: write to file and verify contents match stdout
import tempfile, os
out_path = os.path.join(tempfile.gettempdir(), 'forex-factory-test-out.json')
stdout_output = subprocess.check_output(
    ['python3', script, f'--csv={csv_path}', '--date', base_date], text=True
)
subprocess.check_call(
    ['python3', script, f'--csv={csv_path}', '--date', base_date, f'--out={out_path}']
)
with open(out_path, encoding='utf-8') as fh:
    file_output = fh.read()
assert json.loads(stdout_output) == json.loads(file_output), '--out file content differs from stdout'
os.remove(out_path)
print(f'✓ --out flag')

print(f'Validated {len(sample_dates)} dates, impact filters, and --out for {base_date}.')
PY
