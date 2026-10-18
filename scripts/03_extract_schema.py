"""Extract schema + foreign keys for the 11 Mini-Dev databases.

BIRD's PostgreSQL dump loads all 11 databases into ONE Postgres database
(`bird`, schema `public`) and may not carry FK constraints. The SQLite
originals do declare FKs, so we read them from there (PRAGMA foreign_key_list)
and map each table to its real Postgres name. The output feeds the
ActiveRecord model generator (FK -> belongs_to / has_many).

It also records, per table, the Postgres indexes (the EXPLAIN / index-use
metric depends on what indexes exist) and row counts in both Postgres and
SQLite, so a broken or partial load is caught here rather than later.

Output: data/processed/schema.json
"""
import json
import sqlite3
import sys
from pathlib import Path

import psycopg
from psycopg import sql

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "data" / "processed" / "schema.json"


def pg_tables(conn):
    rows = conn.execute(
        "SELECT table_name FROM information_schema.tables "
        "WHERE table_schema = 'public' AND table_type = 'BASE TABLE'"
    ).fetchall()
    return {r[0].lower(): r[0] for r in rows}


def pg_columns(conn, table):
    return [
        {"name": c, "type": t, "nullable": n == "YES"}
        for c, t, n in conn.execute(
            "SELECT column_name, data_type, is_nullable FROM information_schema.columns "
            "WHERE table_schema = 'public' AND table_name = %s ORDER BY ordinal_position",
            (table,),
        ).fetchall()
    ]


def pg_primary_key(conn, table):
    rows = conn.execute(
        """SELECT a.attname FROM pg_index i
           JOIN pg_attribute a ON a.attrelid = i.indrelid AND a.attnum = ANY(i.indkey)
           WHERE i.indrelid = format('public.%%I', %s::text)::regclass AND i.indisprimary""",
        (table,),
    ).fetchall()
    return [r[0] for r in rows]


def pg_indexes(conn, table):
    return [
        {"name": n, "definition": d}
        for n, d in conn.execute(
            "SELECT indexname, indexdef FROM pg_indexes WHERE schemaname = 'public' AND tablename = %s",
            (table,),
        ).fetchall()
    ]


def pg_row_count(conn, table):
    return conn.execute(sql.SQL("SELECT count(*) FROM {}").format(sql.Identifier(table))).fetchone()[0]


def pg_fk_count(conn):
    return conn.execute(
        "SELECT count(*) FROM information_schema.table_constraints "
        "WHERE table_schema='public' AND constraint_type='FOREIGN KEY'"
    ).fetchone()[0]


def sqlite_schema(path):
    db = sqlite3.connect(path)
    tables = [
        r[0]
        for r in db.execute(
            "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'"
        )
    ]
    out = {}
    for t in tables:
        pk = [r[1] for r in sorted(db.execute(f'PRAGMA table_info("{t}")'), key=lambda r: r[5]) if r[5] > 0]
        fks = [
            {"column": r[3], "ref_table": r[2], "ref_column": r[4]}
            for r in db.execute(f'PRAGMA foreign_key_list("{t}")')
        ]
        rows = db.execute(f'SELECT count(*) FROM "{t}"').fetchone()[0]
        out[t] = {"sqlite_pk": pk, "foreign_keys": fks, "sqlite_rows": rows}
    db.close()
    return out


def main(dsn="dbname=bird"):
    sqlite_files = sorted((ROOT / "data" / "raw").rglob("*.sqlite"))
    if not sqlite_files:
        sys.exit("No .sqlite files under data/raw - run scripts/01_download.sh first")

    with psycopg.connect(dsn) as conn:
        pg_names = pg_tables(conn)
        result = {"pg_fk_constraints": pg_fk_count(conn), "databases": {}}
        missing = []
        for f in sqlite_files:
            db_id = f.stem
            tables = {}
            for t, info in sqlite_schema(f).items():
                pg_name = pg_names.get(t.lower())
                if pg_name is None:
                    missing.append(f"{db_id}.{t}")
                    continue
                for fk in info["foreign_keys"]:
                    fk["ref_table_pg"] = pg_names.get((fk["ref_table"] or "").lower())
                tables[pg_name] = {
                    "sqlite_name": t,
                    "columns": pg_columns(conn, pg_name),
                    "pg_primary_key": pg_primary_key(conn, pg_name),
                    "pg_indexes": pg_indexes(conn, pg_name),
                    "pg_rows": pg_row_count(conn, pg_name),
                    **info,
                }
            result["databases"][db_id] = tables

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(result, indent=2))

    print(f"FK constraints present in Postgres: {result['pg_fk_constraints']}")
    print(f"{'database':28} tables  fks  no_pk  indexes  pg_rows")
    mismatched = []
    for db_id, tables in result["databases"].items():
        n_fk = sum(len(t["foreign_keys"]) for t in tables.values())
        no_pk = sum(1 for t in tables.values() if not t["pg_primary_key"] and not t["sqlite_pk"])
        n_idx = sum(len(t["pg_indexes"]) for t in tables.values())
        rows = sum(t["pg_rows"] for t in tables.values())
        print(f"{db_id:28} {len(tables):6} {n_fk:4} {no_pk:6} {n_idx:8} {rows:>9,}")
        mismatched += [f"{db_id}.{n} (pg {t['pg_rows']:,} vs sqlite {t['sqlite_rows']:,})"
                       for n, t in tables.items() if t["pg_rows"] != t["sqlite_rows"]]
    if mismatched:
        print(f"\nRow-count mismatches vs SQLite ({len(mismatched)}):")
        for m in mismatched:
            print("  " + m)
    else:
        print("\nRow counts match SQLite for every table.")
    if missing:
        print(f"\nSQLite tables not found in Postgres ({len(missing)}): {', '.join(missing)}")
    print(f"\nWrote {OUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main(*sys.argv[1:])
