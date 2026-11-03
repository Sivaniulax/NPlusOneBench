"""Generate ActiveRecord models for every BIRD database from schema.json.

One folder per database under harness/models/<db_id>/, one class per table.
Each question only touches one database, so the harness loads one folder at
a time (financial has `card`, card_games has `cards`; both would be Card).

FKs come from the SQLite originals (105) rather than Postgres (87).
"""
import json
import re
from collections import Counter, defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SCHEMA = ROOT / "data" / "processed" / "schema.json"
OUT = ROOT / "harness" / "models"

# names that read badly with the simple rules below
CLASS_NAMES = {
    "status": "Status",
    "frpm": "Frpm",
    "satscores": "Satscore",
    "posthistory": "PostHistory",
    "postlinks": "PostLink",
    "gasstations": "GasStation",
    "yearmonth": "YearMonth",
    "transactions_1k": "Transaction",
    "constructorresults": "ConstructorResult",
    "constructorstandings": "ConstructorStanding",
    "driverstandings": "DriverStanding",
    "laptimes": "LapTime",
    "pitstops": "PitStop",
    "qualifying": "Qualifying",
    "player_attributes": "PlayerAttribute",
    "team_attributes": "TeamAttribute",
    "foreign_data": "ForeignData",
    "set_translations": "SetTranslation",
    "zip_code": "ZipCode",
    "trans": "Trans",
}


def singular(table):
    if table.endswith("ies"):
        return table[:-3] + "y"
    if table.endswith(("sses", "ches")):
        return table[:-2]
    if table.endswith("s") and not table.endswith("ss"):
        return table[:-1]
    return table


def plural(table):
    word = snake(class_name(table))
    if word.endswith(("data", "trans")):
        return word
    if re.search(r"[^aeiou]y$", word):
        return word[:-1] + "ies"
    if word.endswith(("s", "x", "ch", "sh")):
        return word + "es"
    return word + "s"


def class_name(table):
    return CLASS_NAMES.get(table) or "".join(p.capitalize() for p in singular(table).split("_"))


def snake(col):
    s = re.sub(r"[^0-9a-zA-Z]+", "_", col).strip("_")
    s = re.sub(r"(?<=[a-z0-9])(?=[A-Z])", "_", s).lower()
    s = re.sub(r"_+", "_", s)
    # Ruby names can't start with a digit: "2013_14_calpads_..." -> "calpads_..._2013_14"
    m = re.match(r"^([0-9_]+)_(.+)$", s)
    return f"{m.group(2)}_{m.group(1)}" if m else s


def pg_col(columns, name):
    """SQLite FK names keep their case; Postgres folded most of them."""
    by_lower = {c["name"].lower(): c["name"] for c in columns}
    return by_lower[name.lower()]


def assoc_base(col):
    c = col.lower()
    m = re.fullmatch(r"(.+)_id(\d+)", c)  # atom_id2 -> atom2
    if m:
        return m.group(1) + m.group(2)
    for suffix in ("_api_id", "_id", "id"):
        if c.endswith(suffix) and len(c) - len(suffix) >= 3:
            return c[: -len(suffix)]
    return None


def ruby_list(cols):
    return "[" + ", ".join(f'"{c}"' for c in cols) + "]"


def build(db):
    tables = {}
    for t, info in db.items():
        cols = [c["name"] for c in info["columns"]]
        pk = info["pg_primary_key"] or [pg_col(info["columns"], c) for c in info["sqlite_pk"]]
        tables[t] = {"cols": cols, "pk": pk, "belongs": [], "has_many": []}

    # belongs_to side
    for t, info in db.items():
        seen = set()
        taken = set(tables[t]["cols"])
        fks = sorted(info["foreign_keys"], key=lambda f: assoc_base(f["column"]) is None)
        refs = Counter(fk["ref_table_pg"] for fk in fks)
        for fk in fks:
            target = fk["ref_table_pg"]
            col = pg_col(info["columns"], fk["column"])
            ref = fk["ref_column"]
            ref = pg_col(db[target]["columns"], ref) if ref else tables[target]["pk"][0]
            if (col, target, ref) in seen:
                continue  # yearmonth lists the same FK twice
            seen.add((col, target, ref))
            name = assoc_base(col)
            if not name:
                # match.away_player_3 -> away_player_3_player, member.zip -> zip_code
                name = f"{snake(col)}_{singular(target)}" if refs[target] > 1 else singular(target)
            if name in taken:
                name = f"{name}_record"  # trans has a plain `account` column
            taken.add(name)
            tables[t]["belongs"].append({"name": name, "target": target, "fk": col, "ref": ref})

    # has_many side; name it after the FK when one table points here more than once
    for t, info in tables.items():
        per_target = Counter(b["target"] for b in info["belongs"])
        for b in info["belongs"]:
            if t == b["target"]:
                name = f"child_{plural(t)}"
            elif per_target[b["target"]] == 1:
                name = plural(t)
            else:
                name = f"{plural(t)}_as_{b['name']}"
            tables[b["target"]]["has_many"].append({"name": name, "source": t, "fk": b["fk"], "ref": b["ref"]})
    return tables


def annotation(t, info, columns):
    """Column list in the style of the annotate gem, which most Rails apps have."""
    width = max(len(c["name"]) for c in columns)
    lines = ["# == Schema Information", "#", f"# Table name: {t}", "#"]
    for c in columns:
        attrs = [] if c["nullable"] else ["not null"]
        if c["name"] in info["pk"]:
            attrs.append("primary key")
        tail = f", {', '.join(attrs)}" if attrs else ""
        lines.append(f"#  {c['name']:<{width}}  :{c['type']}{tail}")
    return lines + ["#"]


def render(t, info, tables, columns):
    cls = class_name(t)
    lines = annotation(t, info, columns)
    lines += [f"class {cls} < ApplicationRecord", f'  self.table_name = "{t}"']
    pk = info["pk"]
    if len(pk) == 1:
        if pk[0] != "id":
            lines.append(f'  self.primary_key = "{pk[0]}"')
    elif len(pk) > 1:
        lines.append(f"  self.primary_key = {ruby_list(pk)}")
    else:
        lines.append("  # no primary key in the source data")

    odd = [(snake(c), c) for c in info["cols"] if not re.fullmatch(r"[a-z_][a-z0-9_]*", c)]
    if odd:
        lines.append("")
        lines += [f'  alias_attribute :{a}, "{c}"' for a, c in odd]

    rels = []
    for b in info["belongs"]:
        opts = [f'class_name: "{class_name(b["target"])}"', f'foreign_key: "{b["fk"]}"']
        if b["ref"] != (tables[b["target"]]["pk"] or [None])[0]:
            opts.append(f'primary_key: "{b["ref"]}"')
        rels.append(f"  belongs_to :{b['name']}, {', '.join(opts)}, optional: true")
    for h in info["has_many"]:
        opts = [f'class_name: "{class_name(h["source"])}"', f'foreign_key: "{h["fk"]}"']
        if h["ref"] != (info["pk"] or [None])[0]:
            opts.append(f'primary_key: "{h["ref"]}"')
        rels.append(f"  has_many :{h['name']}, {', '.join(opts)}")
    if rels:
        lines.append("")
        lines += rels
    lines.append("end")
    return "\n".join(lines) + "\n"


def file_name(cls):
    return re.sub(r"(?<!^)(?=[A-Z])", "_", cls).lower() + ".rb"


def main():
    schema = json.loads(SCHEMA.read_text())
    total = defaultdict(int)
    for db_id, db in schema["databases"].items():
        tables = build(db)
        names = [class_name(t) for t in tables]
        assert len(names) == len(set(names)), f"class name clash in {db_id}"
        out = OUT / db_id
        out.mkdir(parents=True, exist_ok=True)
        for old in out.glob("*.rb"):
            old.unlink()
        for t, info in tables.items():
            (out / file_name(class_name(t))).write_text(render(t, info, tables, db[t]["columns"]))
            total["models"] += 1
            total["belongs_to"] += len(info["belongs"])
            total["has_many"] += len(info["has_many"])
    print(f"Wrote {total['models']} models ({total['belongs_to']} belongs_to, "
          f"{total['has_many']} has_many) to {OUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
