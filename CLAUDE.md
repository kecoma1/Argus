# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

**Argus** is a market data processing toolkit. Currently contains one module: `forex-factory/`, which parses the Forex Factory economic calendar from a Chrome DevTools snapshot into CSV and queries it as JSON.

## Commands

```bash
# Run all integration tests
./tests/run-forex-factory.sh

# Parse a raw snapshot (.txt) into CSV
node forex-factory/parse-forexfactory-snapshot.js <input.txt> <output.csv>

# Query the CSV — returns JSON array of events
python3 forex-factory/forex-factory.py --csv=<path.csv> --today
python3 forex-factory/forex-factory.py --csv=<path.csv> --date=DD/MM/YYYY
python3 forex-factory/forex-factory.py --csv=<path.csv> --date=DD/MM/YYYY --high
```

No package manager or build step — pure Node.js stdlib and Python 3 stdlib only.

## Architecture

### Data flow

```
forexfactory-calendar-snapshot.txt   (raw Chrome DevTools MCP capture)
    ↓  parse-forexfactory-snapshot.js  (Node.js)
forexfactory-calendar.csv            (6 columns: Date, Currency, Impact, Actual, Forecast, Previous)
    ↓  forex-factory.py               (Python 3)
JSON array                           (filtered by date and/or impact level)
```

### Module layout

Each module under the repo root keeps its own `README.md` with full CLI docs.

- **`forex-factory/parse-forexfactory-snapshot.js`** — reads the structured text snapshot line-by-line with regex, extracts event fields, writes CSV.
- **`forex-factory/forex-factory.py`** — reads CSV, filters rows by date/impact via `argparse`, outputs JSON.
- **`tests/run-forex-factory.sh`** — bash integration test: iterates dates in the CSV, validates JSON output shape and filter cardinality.

## Coding Style

- 2-space indentation (JS, JSON, Markdown)
- `camelCase` for variables/functions, `PascalCase` for classes, `kebab-case` for filenames
- No linter configured yet — keep style consistent with existing files
