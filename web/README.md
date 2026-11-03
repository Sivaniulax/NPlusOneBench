# NPlusOneBench site

Static React app (Vite, TypeScript, React Router with hash routing) deployed to GitHub Pages by `.github/workflows/pages.yml`. It has no backend: every page reads JSON files from `public/data/`.

```bash
npm ci
npm run dev      # http://localhost:5173/NPlusOneBench/
npm run build    # dist/
```

## Pages

| Route | Content |
|---|---|
| `/` | Dataset overview and gold audit |
| `/leaderboard` | Per-model accuracy (SQL and ActiveRecord), N+1 rate, raw-SQL rate, query counts, 95% bootstrap intervals |
| `/questions` | Searchable question list, filterable by database, difficulty and gold status |
| `/questions/:id` | Gold SQL and result preview, each model's SQL and ActiveRecord answer, query log, N+1 retry |
| `/failures` | Failure categories per model with example questions |
| `/playground` | Step-by-step replay of a recorded answer's query log |

## Data files

Written by `scripts/06_export_site_data.py` and `scripts/10_analyze.py`. Not edited by hand.

| File | Contents |
|---|---|
| `questions.json` | question_id, db_id, difficulty, question, evidence, gold_sql, gold_status, gold_rows, gold_preview, gold_ms, sqlite_match, gold_fixed |
| `dataset.json` | Dataset profile and gold audit counts |
| `models.json` | id, name, size, provider, run_date |
| `summary.json` | Per model and difficulty: accuracies and rates with bootstrap intervals |
| `taxonomy.json` | Per model: failure category, count, example question ids |
| `runs/<model>.json` | Per question: sql, ruby, correctness, query_count, rows_loaded, n_plus_one, sql_fallback, error, queries, retry fields |
