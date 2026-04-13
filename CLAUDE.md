# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

**Argus** is a market data processing toolkit. Currently contains one module: `forex-factory/`, which parses the Forex Factory economic calendar from a Chrome DevTools snapshot into CSV and queries it as JSON.

## Commands

```bash
# Run all integration tests
./forex-factory/fetch/run-forex-factory.sh

# Parse a raw snapshot (.txt) into CSV
node forex-factory/fetch/parse-forexfactory-snapshot.js <input.txt> <output.csv>

# Query the CSV — returns JSON array of events
python3 forex-factory/fetch/forex-factory.py --csv=<path.csv> --today
python3 forex-factory/fetch/forex-factory.py --csv=<path.csv> --date=DD/MM/YYYY --high

# Interpret news with OpenAI
python3 forex-factory/fetch/forex-factory.py --csv=<path.csv> --today | python3 forex-factory/interpret/interpreter.py
```

Dependencies: `pip install -r requirements.txt` (openai, python-dotenv). Requires `.env` with `OPENAI_API_KEY`.

## Architecture

### Data flow

```
forexfactory-calendar-snapshot.txt   (raw Chrome DevTools MCP capture)
    ↓  fetch/parse-forexfactory-snapshot.js  (Node.js)
forexfactory-calendar.csv            (6 columns: Date, Currency, Impact, Actual, Forecast, Previous)
    ↓  fetch/forex-factory.py                (Python 3)
JSON array                           (filtered by date and/or impact level)
    ↓  interpret/interpreter.py              (Python 3 + OpenAI)
Market impact analysis               (natural language)
```

### Module layout

Each module under the repo root keeps its own `README.md` with full CLI docs.

- **`forex-factory/fetch/`** — capture and query: snapshot parser (JS), CSV filter (Python), integration tests (bash).
- **`forex-factory/interpret/`** — LLM analysis: reads JSON events, calls OpenAI to describe market impact.

## Coding Style

- 2-space indentation (JS, JSON, Markdown)
- `camelCase` for variables/functions, `PascalCase` for classes, `kebab-case` for filenames
- No linter configured yet — keep style consistent with existing files
