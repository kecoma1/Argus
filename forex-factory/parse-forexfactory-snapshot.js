#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const inputPath = process.argv[2] || path.join(__dirname, 'forexfactory-calendar-snapshot.txt');
const outputPath =
  process.argv[3] || path.join(path.dirname(inputPath), 'forexfactory-calendar.csv');

function readSnapshot(filePath) {
  return fs.readFileSync(filePath, 'utf8').split(/\r?\n/);
}

function extractQuotedValue(line) {
  const match = line.match(/StaticText\s+"([^"]*)"/);
  return match ? match[1] : null;
}

function isWeekday(line) {
  return /StaticText\s+"(Sun|Mon|Tue|Wed|Thu|Fri|Sat)"/.test(line);
}

function isDateLine(line) {
  return /StaticText\s+"(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) \d{1,2}"/.test(line);
}

function isTimeLine(line) {
  return /StaticText\s+"(?:\d{1,2}:\d{2}(?:am|pm)|Tentative)"/.test(line);
}

function isCurrencyLine(line) {
  return /StaticText\s+"[A-Z]{3}"/.test(line);
}

function parseImpact(line) {
  if (/Low Impact Expected/.test(line)) return 'low';
  if (/Med Impact Expected/.test(line)) return 'mid';
  if (/High Impact Expected/.test(line)) return 'high';
  return '';
}

function isNumericLike(value) {
  return /^-?(?:\d+(?:\.\d+)?|\.\d+)(?:%|K|M|B|T)?$/.test(value);
}

function parseRows(lines) {
  const rows = [];
  let currentDate = '';
  let i = 0;

  while (i < lines.length) {
    const line = lines[i];

    if (/StaticText\s+"Day \d+"/.test(line) || /StaticText\s+"All"/.test(line)) {
      i += 1;
      continue;
    }

    if (isDateLine(line)) {
      currentDate = extractQuotedValue(line);
      i += 1;
      continue;
    }

    if (!isTimeLine(line)) {
      i += 1;
      continue;
    }

    const time = extractQuotedValue(line);
    const currency = extractQuotedValue(lines[i + 1] || '');
    const impact = parseImpact(lines[i + 2] || '');
    const title = extractQuotedValue(lines[i + 3] || '');

    if (!time || !currency || !impact || !title) {
      i += 1;
      continue;
    }

    i += 4;

    const values = [];
    while (i < lines.length) {
      const next = lines[i];
      if (
        isTimeLine(next) ||
        isDateLine(next) ||
        isWeekday(next) ||
        /StaticText\s+"(Actual|Forecast|Previous|Graph|Filter|Date|Currency|Impact|Alerts|Detail)"/.test(next)
      ) {
        break;
      }

      const value = extractQuotedValue(next);
      if (
        value &&
        value !== 'Open Detail' &&
        value !== 'Open Graph' &&
        isNumericLike(value)
      ) {
          values.push(value);
      }
      i += 1;
    }

    rows.push({
      date: `${currentDate} ${time}`.trim(),
      currency,
      impact,
      actual: values[0] || '',
      forecast: values[1] || '',
      previous: values[2] || '',
      title,
    });
  }

  return rows;
}

function toMarkdownTable(rows) {
  const header = ['Date', 'Currency', 'Impact', 'Actual', 'Forecast', 'Previous'];
  const escape = (value) => String(value).replace(/\|/g, '\\|');
  const lines = [
    `| ${header.join(' | ')} |`,
    `| ${header.map(() => '---').join(' | ')} |`,
  ];

  for (const row of rows) {
    lines.push(
      `| ${escape(row.date)} | ${escape(row.currency)} | ${escape(row.impact)} | ${escape(row.actual)} | ${escape(row.forecast)} | ${escape(row.previous)} |`
    );
  }

  return lines.join('\n');
}

function toCsv(rows) {
  const header = ['Date', 'Currency', 'Impact', 'Actual', 'Forecast', 'Previous'];
  const escape = (value) => {
    const text = String(value ?? '');
    if (/[",\n]/.test(text)) {
      return `"${text.replace(/"/g, '""')}"`;
    }
    return text;
  };

  const lines = [header.join(',')];
  for (const row of rows) {
    lines.push(
      [
        row.date,
        row.currency,
        row.impact,
        row.actual,
        row.forecast,
        row.previous,
      ].map(escape).join(',')
    );
  }
  return lines.join('\n');
}

const lines = readSnapshot(inputPath);
const rows = parseRows(lines);
const csv = toCsv(rows);
fs.writeFileSync(outputPath, csv);
console.log(`Wrote ${rows.length} rows to ${outputPath}`);
