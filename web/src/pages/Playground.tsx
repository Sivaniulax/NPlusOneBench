import { useEffect, useMemo, useState } from 'react'
import Code from '../components/Code'
import Loading from '../components/Loading'
import { useModels, useQuestions, useRuns, type Model } from '../lib/data'

// Replays a cached answer's query log. Nothing runs live.
export default function Playground() {
  const { data: models, error } = useModels()
  if (!models) return <Loading error={error} />
  return (
    <>
      <h1>Playground</h1>
      <p className="muted">
        Pick a model and a question, then press play to watch the queries its ActiveRecord answer sent,
        one by one. These are recorded runs, not live calls.
      </p>
      {models.length === 0 ? <p className="muted">No results.</p> : <Player models={models} />}
    </>
  )
}

function Player({ models }: { models: Model[] }) {
  const [modelId, setModelId] = useState(models[0].id)
  const { data: runs } = useRuns(modelId)
  const { data: questions } = useQuestions()
  const [qid, setQid] = useState<number | null>(null)
  const [step, setStep] = useState(0)
  const [playing, setPlaying] = useState(false)

  const choices = useMemo(() => {
    if (!runs) return []
    // most queries first, so the N+1 ones are easy to find
    return [...runs].filter((r) => r.queries?.length).sort((a, b) => (b.query_count ?? 0) - (a.query_count ?? 0))
  }, [runs])
  const run = choices.find((r) => r.question_id === qid) ?? choices[0]
  const question = questions?.find((q) => q.question_id === run?.question_id)

  useEffect(() => {
    setStep(0)
    setPlaying(false)
  }, [modelId, qid])

  useEffect(() => {
    if (!playing || !run) return
    if (step >= run.queries.length) {
      setPlaying(false)
      return
    }
    const t = setTimeout(() => setStep((s) => s + 1), 350)
    return () => clearTimeout(t)
  }, [playing, step, run])

  if (!runs || !questions) return <Loading />
  if (!run) return <p className="note">This model has no recorded queries.</p>

  const seen = new Map<string, number>()
  const shown = run.queries.slice(0, step).map((q) => {
    const shape = q.replace(/'(?:[^']|'')*'/g, '?').replace(/\b\d+(\.\d+)?\b/g, '?')
    seen.set(shape, (seen.get(shape) ?? 0) + 1)
    return { q, repeat: seen.get(shape)! }
  })

  return (
    <>
      <div className="filters">
        <select value={modelId} onChange={(e) => setModelId(e.target.value)}>
          {models.map((m) => <option key={m.id} value={m.id}>{m.name}</option>)}
        </select>
        <select value={run.question_id} onChange={(e) => setQid(Number(e.target.value))}>
          {choices.map((r) => (
            <option key={r.question_id} value={r.question_id}>
              #{r.question_id} · {r.query_count} queries{r.n_plus_one ? ' · N+1' : ''}
            </option>
          ))}
        </select>
      </div>
      {question && <p><strong>{question.question}</strong></p>}
      <Code code={run.ruby ?? ''} lang="ruby" />
      <div className="player-bar">
        <button onClick={() => (step >= run.queries.length ? (setStep(0), setPlaying(true)) : setPlaying(!playing))}>
          {playing ? 'Pause' : step >= run.queries.length && step > 0 ? 'Replay' : 'Play'}
        </button>
        <span className="muted">{step} / {run.query_count} queries</span>
        {run.query_count != null && run.query_count > run.queries.length && (
          <span className="muted small">(log keeps the first {run.queries.length})</span>
        )}
      </div>
      <ol className="query-log">
        {shown.map(({ q, repeat }, i) => (
          <li key={i} className={repeat >= 3 ? 'hot' : ''}>
            <code>{q}</code>
            {repeat >= 2 && <span className="badge badge-bad">×{repeat}</span>}
          </li>
        ))}
      </ol>
    </>
  )
}
