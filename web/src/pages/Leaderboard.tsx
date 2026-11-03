import { useState } from 'react'
import Loading from '../components/Loading'
import { DIFFICULTIES, pct, useModels, useSummary, type Difficulty, type Model, type Stat } from '../lib/data'

export default function Leaderboard() {
  const { data: models, error } = useModels()
  if (!models) return <Loading error={error} />

  return (
    <>
      <h1>Leaderboard</h1>
      {models.length === 0
        ? <p className="muted">No results.</p>
        : <Table models={models} />}
    </>
  )
}

function Table({ models }: { models: Model[] }) {
  const { data: summary, error } = useSummary()
  const [level, setLevel] = useState<'all' | Difficulty>('all')
  if (!summary) return <Loading error={error} />

  const rows = models
    .map((m) => ({ m, s: summary[m.id]?.[level] }))
    .filter((r) => r.s)
    .sort((a, b) => b.s!.ar_correct.mean - a.s!.ar_correct.mean)

  return (
    <>
      <div className="filters">
        <select value={level} onChange={(e) => setLevel(e.target.value as 'all' | Difficulty)}>
          <option value="all">All questions</option>
          {DIFFICULTIES.map((d) => <option key={d} value={d}>{d}</option>)}
        </select>
      </div>
      <div className="table-wrap">
        <table>
          <thead>
            <tr>
              <th>model</th>
              <th className="num">SQL correct</th>
              <th className="num">ActiveRecord correct</th>
              <th className="num">AR − SQL</th>
              <th className="num">N+1</th>
              <th className="num">loads too much</th>
              <th className="num">raw SQL</th>
              <th className="num">median queries</th>
            </tr>
          </thead>
          <tbody>
            {rows.map(({ m, s }) => (
              <tr key={m.id}>
                <td>{m.name}<div className="muted small">{[m.size, m.provider].filter(Boolean).join(' · ')}</div></td>
                <td className="num"><Ci s={s!.sql_correct} /></td>
                <td className="num"><Ci s={s!.ar_correct} /></td>
                <td className="num"><Ci s={s!.ar_minus_sql} signed /></td>
                <td className="num"><Ci s={s!.n_plus_one} /></td>
                <td className="num">{pct(s!.overfetch.mean)}</td>
                <td className="num">{pct(s!.sql_fallback.mean)}</td>
                <td className="num">{s!.median_queries ?? '–'}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      <p className="muted small">
        Brackets are 95% bootstrap intervals. "AR − SQL" is paired: the same questions, answered both ways.
        N+1 means the same query shape ran 3+ times in one answer.
      </p>
    </>
  )
}

function Ci({ s, signed }: { s: Stat; signed?: boolean }) {
  const f = (x: number) => (signed && x > 0 ? '+' : '') + (x * 100).toFixed(1)
  return (
    <>
      {f(s.mean)}%<div className="muted small">[{f(s.lo)}, {f(s.hi)}]</div>
    </>
  )
}
