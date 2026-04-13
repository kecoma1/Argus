# Forex Factory

Herramientas para capturar, procesar y consultar el calendario de Forex Factory.

## Archivos

- `forexfactory-calendar-snapshot.txt`: snapshot capturado desde Chrome DevTools MCP.
- `parse-forexfactory-snapshot.js`: convierte el snapshot en CSV.
- `forexfactory-calendar.csv`: salida procesada del parser.
- `forex-factory.py`: filtra el CSV y devuelve JSON.

## Comandos

### 1) Convertir snapshot a CSV

```bash
node forex-factory/parse-forexfactory-snapshot.js forex-factory/forexfactory-calendar-snapshot.txt forex-factory/forexfactory-calendar.csv
```

Parámetros:
- Primer argumento: ruta del snapshot `.txt`
- Segundo argumento: ruta de salida del `.csv`

### 2) Consultar el CSV en JSON

```bash
python3 forex-factory/forex-factory.py --csv=forex-factory/forexfactory-calendar.csv --today --high
python3 forex-factory/forex-factory.py --csv=forex-factory/forexfactory-calendar.csv --date=13/04/2026 --low
python3 forex-factory/forex-factory.py --csv=forex-factory/forexfactory-calendar.csv --today
python3 forex-factory/forex-factory.py --csv=forex-factory/forexfactory-calendar.csv --date=14/04/2026
```

Parámetros de `forex-factory.py`:
- `--csv=PATH`: archivo CSV obligatorio a leer
- `--today`: filtra por el día actual
- `--date=DD/MM/YYYY`: filtra por una fecha concreta
- `--high`: solo impacto alto
- `--medium`: solo impacto medio
- `--low`: solo impacto bajo

Reglas:
- Si no pasas `--today` ni `--date`, el script usa la fecha actual.
- La salida siempre es JSON en formato array.
- Solo se puede usar un filtro de impacto a la vez.

### 3) Ejecutar tests

```bash
./tests/run-forex-factory.sh
```

El test recorre varias fechas del CSV y valida que la salida siga siendo un array JSON con campos básicos.

## Resultado esperado

Ejemplo:

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
