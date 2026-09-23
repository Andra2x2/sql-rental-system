"""Run the SQLite rental learning project with Python 3.10+."""
import argparse
from pathlib import Path
import sqlite3

ROOT = Path(__file__).resolve().parent


def print_queries(db):
    for statement in (ROOT / 'queries.sql').read_text(encoding='utf-8').split(';'):
        if not statement.strip():
            continue
        cursor = db.execute(statement)
        if cursor.description:
            print(' | '.join(column[0] for column in cursor.description))
            for row in cursor:
                print(' | '.join(str(value) for value in row))
            print()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('command', choices=['demo', 'init', 'report'])
    parser.add_argument('--database', type=Path, default=Path('rental.db'))
    args = parser.parse_args()
    created = False
    try:
        if args.command == 'init':
            # Exclusive creation protects an existing database, even if it is empty.
            with args.database.open('xb'):
                pass
            created = True
        elif args.command == 'report' and not args.database.is_file():
            raise ValueError('Database does not exist. Run init first.')
        db = sqlite3.connect(':memory:' if args.command == 'demo' else args.database)
        try:
            db.execute('PRAGMA foreign_keys=ON')
            if args.command in ('demo', 'init'):
                db.executescript((ROOT / 'schema.sql').read_text(encoding='utf-8'))
                db.executescript((ROOT / 'seed.sql').read_text(encoding='utf-8'))
            if args.command == 'init':
                print(f'Created {args.database} with fictional sample data.')
            else:
                print_queries(db)
        finally:
            db.close()
    except (OSError, ValueError, sqlite3.Error) as error:
        if created:
            args.database.unlink(missing_ok=True)
        parser.exit(1, f'Error: {error}\n')


if __name__ == '__main__':
    main()
