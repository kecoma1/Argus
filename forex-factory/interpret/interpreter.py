#!/usr/bin/env python3

import argparse
import json
import sys
from pathlib import Path

from dotenv import load_dotenv
from openai import OpenAI

ROOT = Path(__file__).resolve().parent
load_dotenv(ROOT.parent.parent / '.env')

SYSTEM_PROMPT = (
    "Eres un analista financiero experto en mercados de divisas. "
    "Se te proporcionará una lista de noticias económicas del calendario de Forex Factory. "
    "Para cada noticia, analiza el posible efecto en los mercados: "
    "qué divisa se ve afectada, en qué dirección podría moverse y por qué. "
    "Responde en español de forma clara y concisa."
)


def parse_args():
    parser = argparse.ArgumentParser(
        description='Interpret Forex Factory events using OpenAI.'
    )
    parser.add_argument(
        '--json', dest='json_file',
        help='JSON file with events. If omitted, reads from stdin.'
    )
    parser.add_argument(
        '--model', default='gpt-4o-mini',
        help='OpenAI model to use (default: gpt-4o-mini).'
    )
    return parser.parse_args()


def load_events(json_file):
    if json_file:
        path = Path(json_file)
        if not path.is_absolute():
            path = (ROOT / path).resolve()
        return json.loads(path.read_text(encoding='utf-8'))
    return json.load(sys.stdin)


def interpret(events, model):
    if not events:
        print("No hay noticias para interpretar.")
        return

    client = OpenAI()
    user_message = json.dumps(events, ensure_ascii=False, indent=2)

    response = client.chat.completions.create(
        model=model,
        messages=[
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": user_message},
        ],
    )

    print(response.choices[0].message.content)


def main():
    args = parse_args()
    events = load_events(args.json_file)
    interpret(events, args.model)


if __name__ == '__main__':
    main()
