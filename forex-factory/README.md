# Forex Factory

Herramientas para capturar, procesar, consultar e interpretar el calendario de Forex Factory.

## Estructura

```
forex-factory/
├── fetch/                              # Captura y consulta de datos
│   ├── parse-forexfactory-snapshot.js  # Convierte snapshot a CSV
│   ├── forex-factory.py                # Filtra CSV y devuelve JSON
│   ├── forexfactory-calendar-snapshot.txt
│   ├── forexfactory-calendar.csv
│   └── run-forex-factory.sh            # Tests de integración
└── interpret/                          # Análisis con LLM
    └── interpreter.py                  # Interpreta noticias con OpenAI
```

## Comandos

### 1) Convertir snapshot a CSV

```bash
node forex-factory/fetch/parse-forexfactory-snapshot.js forex-factory/fetch/forexfactory-calendar-snapshot.txt forex-factory/fetch/forexfactory-calendar.csv
```

### 2) Consultar el CSV en JSON

```bash
python3 forex-factory/fetch/forex-factory.py --csv=forex-factory/fetch/forexfactory-calendar.csv --today
python3 forex-factory/fetch/forex-factory.py --csv=forex-factory/fetch/forexfactory-calendar.csv --date=07/04/2025 --high
```

Parámetros de `forex-factory.py`:
- `--csv=PATH`: archivo CSV obligatorio
- `--today`: filtra por el día actual
- `--date=DD/MM/YYYY`: filtra por fecha concreta
- `--high` / `--medium` / `--low`: filtra por impacto (solo uno a la vez)

### 3) Interpretar noticias

```bash
# Pipe directo desde fetch
python3 forex-factory/fetch/forex-factory.py --csv=forex-factory/fetch/forexfactory-calendar.csv --today | python3 forex-factory/interpret/interpreter.py

# Desde archivo JSON
python3 forex-factory/interpret/interpreter.py --json=events.json

# Con modelo específico
python3 forex-factory/interpret/interpreter.py --model=gpt-4o
```

Requiere un archivo `.env` en la raíz del repositorio con `OPENAI_API_KEY=sk-...`.

### 4) Ejecutar tests

```bash
./forex-factory/fetch/run-forex-factory.sh
```

## Resultado esperado

```json
[
  {
    "Date": "Apr 13 12:50am",
    "Currency": "JPY",
    "Impact": "low",
    "Actual": "2.0%",
    "Forecast": "1.6%",
    "Previous": "1.7%"
  }
]
```
