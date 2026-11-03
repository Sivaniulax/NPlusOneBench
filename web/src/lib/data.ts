import { useEffect, useState } from 'react'

export type Difficulty = 'simple' | 'moderate' | 'challenging'

export interface Question {
  question_id: number
  db_id: string
  difficulty: Difficulty
  question: string
  evidence: string
  gold_sql: string
  gold_status: string
  gold_rows: number | null
  gold_preview: string[][] | null
  gold_ms: number | null
  sqlite_match: boolean | null
  gold_fixed: boolean
}

export interface DbStats {
  tables: number
  foreign_keys: number
  rows: number
  biggest_table: string
  biggest_rows: number
  tables_without_pk: string[]
}

export interface Dataset {
  questions: number
  difficulty: Record<Difficulty, number>
  per_database: Record<string, number>
  sql_feature_pct: Record<string, number>
  avg_joins_by_difficulty: Record<Difficulty, number>
  databases: Record<string, DbStats>
  totals: { foreign_keys: number; rows: number }
  gold_audit: Record<string, number>
  gold_unverified: number[]
}

export interface Model {
  id: string
  name: string
  size?: string
  provider?: string
  run_date?: string
}

export interface Run {
  question_id: number
  sql: string | null
  ruby: string | null
  sql_correct: boolean | null
  ar_correct: boolean | null
  query_count: number | null
  rows_loaded: number | null
  n_plus_one: boolean
  sql_fallback: boolean
  error: string | null
  queries: string[]
  retry_ruby: string | null
  retry_n_plus_one: boolean | null
  retry_query_count: number | null
  retry_ar_correct: boolean | null
}

export interface Stat {
  mean: number
  lo: number
  hi: number
  n: number
}

export interface Summary {
  n: number
  sql_correct: Stat
  ar_correct: Stat
  ar_minus_sql: Stat
  n_plus_one: Stat
  overfetch: Stat
  sql_fallback: Stat
  sql_fragment: Stat
  median_queries: number | null
  max_queries: number | null
  retry?: { n: number; fixed_n_plus_one: number; still_correct: number; was_correct: number }
}

export type ModelSummary = { all: Summary } & Partial<Record<Difficulty, Summary>>
export type Taxonomy = Record<string, { count: number; examples: number[] }>

export const DIFFICULTIES: Difficulty[] = ['simple', 'moderate', 'challenging']

const cache = new Map<string, Promise<unknown>>()

function load<T>(file: string): Promise<T> {
  if (!cache.has(file)) {
    cache.set(file, fetch(`${import.meta.env.BASE_URL}data/${file}`).then((r) => {
      if (!r.ok) throw new Error(`${file}: ${r.status}`)
      return r.json()
    }))
  }
  return cache.get(file) as Promise<T>
}

export function useData<T>(file: string) {
  const [state, setState] = useState<{ data?: T; error?: string }>({})
  useEffect(() => {
    let live = true
    load<T>(file).then(
      (data) => live && setState({ data }),
      (e: Error) => live && setState({ error: e.message }),
    )
    return () => { live = false }
  }, [file])
  return state
}

export const useQuestions = () => useData<Question[]>('questions.json')
export const useDataset = () => useData<Dataset>('dataset.json')
export const useModels = () => useData<Model[]>('models.json')
export const useRuns = (modelId: string) => useData<Run[]>(`runs/${modelId}.json`)
export const useSummary = () => useData<Record<string, ModelSummary>>('summary.json')
export const useTaxonomy = () => useData<Record<string, Taxonomy>>('taxonomy.json')

export const pct = (x: number | null | undefined) => (x == null ? '–' : `${(x * 100).toFixed(1)}%`)
