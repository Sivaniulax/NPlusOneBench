# Build journal

Running notes for the Medium post: decisions, surprises, numbers. Add a dated entry whenever something changes.

## 2026-10-19: Data
- Picked **BIRD Mini-Dev** over porting BIRD-dev ourselves. It has 500 curated questions and an official Postgres port plus Postgres gold SQL.
- Split: 148 simple / 250 moderate / 102 challenging, across 11 databases with 105 foreign keys and about 3.9M rows.
- 81% of gold queries JOIN (21% have 2+), 51% aggregate, so most tasks test associations. CASE (19%) and CAST (23%) don't map cleanly to ActiveRecord.
- european_football_2 has 31 FKs on 7 tables (`Match` points at `Player` 22 times). It's the expected hotspot for wrong-association failures.
- Gotcha: the zip has *two* `BIRD_dev.sql` files (MySQL and Postgres). The first load script picked the MySQL one, which gave 52 syntax errors. Fixed by matching on the `MINIDEV_postgresql` folder.
- Open question: is a raw SQL fragment inside an ActiveRecord call (`.select("SUM(CASE ...)")`) valid ORM code? Leaning: allow it, but log it as "SQL fallback".
- Load script now runs `ANALYZE` after loading, so EXPLAIN costs are realistic. Schema extraction also records indexes and checks Postgres row counts against SQLite to catch partial loads.
- Profiling numbers come from `scripts/05_profile_data.py` and are saved in `data/processed/data_profile.json`, so every number here can be reproduced.
- First real load: 75 tables, 1023 MB in Postgres. The 99 "errors" were all `ALTER ... OWNER TO xiaolongli`, the dump author's own role. Harmless, but it looks alarming in the log, so the script now reports it separately.
- Python 3.14 on the new Ubuntu broke an older `psycopg` pin (no wheel). Pin versions, but check that they still install on the current interpreter.
