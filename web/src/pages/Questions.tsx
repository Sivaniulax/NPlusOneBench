import { useMemo } from 'react'
import { Link, useSearchParams } from 'react-router-dom'
import Badge from '../components/Badge'
import Loading from '../components/Loading'
import { DIFFICULTIES, useQuestions } from '../lib/data'

export default function Questions() {
  const { data: questions, error } = useQuestions()
  const [params, setParams] = useSearchParams()
  const q = params.get('q') ?? ''
  const db = params.get('db') ?? ''
  const difficulty = params.get('difficulty') ?? ''
  const status = params.get('status') ?? ''

  const set = (key: string, value: string) => {
    const next = new URLSearchParams(params)
    if (value) next.set(key, value)
    else next.delete(key)
    setParams(next, { replace: true })
  }

  const dbs = useMemo(() => [...new Set(questions?.map((x) => x.db_id))].sort(), [questions])

  const shown = useMemo(() => {
    if (!questions) return []
    const needle = q.trim().toLowerCase()
    return questions.filter((x) =>
      (!db || x.db_id === db) &&
      (!difficulty || x.difficulty === difficulty) &&
      (!status || x.gold_status === status) &&
      (!needle || x.question.toLowerCase().includes(needle) || String(x.question_id) === needle),
    )
  }, [questions, q, db, difficulty, status])

  if (!questions) return <Loading error={error} />

  return (
    <>
      <h1>Questions</h1>
      <div className="filters">
        <input type="search" placeholder="Search questions or id" value={q} onChange={(e) => set('q', e.target.value)} />
        <select value={db} onChange={(e) => set('db', e.target.value)}>
          <option value="">All databases</option>
          {dbs.map((d) => <option key={d}>{d}</option>)}
        </select>
        <select value={difficulty} onChange={(e) => set('difficulty', e.target.value)}>
          <option value="">Any difficulty</option>
          {DIFFICULTIES.map((d) => <option key={d}>{d}</option>)}
        </select>
        <select value={status} onChange={(e) => set('status', e.target.value)}>
          <option value="">Any gold status</option>
          <option value="ok">ok</option>
          <option value="mismatch">mismatch</option>
        </select>
      </div>
      <p className="muted">{shown.length} of {questions.length}</p>

      <ul className="q-list">
        {shown.map((x) => (
          <li key={x.question_id}>
            <Link to={`/questions/${x.question_id}`}>
              <span className="q-id">#{x.question_id}</span>
              <span className="q-text">{x.question}</span>
              <span className="q-meta">
                <span>{x.db_id}</span>
                <Badge kind={x.difficulty}>{x.difficulty}</Badge>
                {x.gold_status !== 'ok' && <Badge kind="bad">{x.gold_status}</Badge>}
              </span>
            </Link>
          </li>
        ))}
      </ul>
    </>
  )
}
