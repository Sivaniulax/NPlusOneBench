---
license: cc-by-sa-4.0
task_categories:
  - text-generation
language:
  - en
tags:
  - text-to-sql
  - activerecord
  - ruby-on-rails
  - orm
  - n+1
pretty_name: NPlusOneBench
size_categories:
  - n<1K
configs:
  - config_name: questions
    data_files: questions.jsonl
  - config_name: answers
    data_files: answers.jsonl
---

# NPlusOneBench

Natural-language database questions with gold SQL for PostgreSQL, generated Rails ActiveRecord models for each database, and model answers in both SQL and ActiveRecord with correctness and query-profile labels.

Derived from [BIRD Mini-Dev](https://github.com/bird-bench/mini_dev): 498 questions over 11 databases (75 tables, 3.9 million rows).

## Files

| File | Contents |
|---|---|
| `questions.jsonl` | question_id, db_id, difficulty, question, evidence, gold_sql, gold_fixed, gold_rows, schema_sql |
| `answers.jsonl` | One row per model and question: SQL and Ruby answers, correctness of each, query count, records loaded, N+1 and raw-SQL flags, N+1 retry results |
| `models/<db_id>/*.rb` | ActiveRecord models generated from the schema, with associations from the source foreign keys |

## Differences from BIRD Mini-Dev

- Questions 137 and 138 are duplicated in Mini-Dev and appear once here.
- The PostgreSQL gold SQL for question 788 is corrected to match the SQLite gold SQL and the evidence text (`gold_fixed: true`).
- Every gold result was verified against the original SQLite gold result.

## Scoring

Result sets are compared as unordered sets of rows with a relative tolerance of 1e-4 on floating-point values. An ActiveRecord answer is labelled N+1 when the same query shape, with literals removed, runs three or more times.

## License

CC BY-SA 4.0, following BIRD Mini-Dev.
