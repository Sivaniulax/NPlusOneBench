import { useState } from 'react'
import { Link, useParams } from 'react-router-dom'
import Badge from '../components/Badge'
import Code from '../components/Code'
import Loading from '../components/Loading'
import { useModels, useQuestions, useRuns, type Model } from '../lib/data'

export default function QuestionDetail() {
  const { id } = useParams()
  const { data: questions, error } = useQuestions()
  const { data: models } = useModels()

  if (!questions) return <Loading error={error} />
  const q = questions.find((x) => String(x.question_id) === id)
  if (!q) return <p>No question #{id}. <Link to="/questions">Back to the list</Link></p>

  const idx = questions.indexOf(q)
  const prev = questions[idx - 1]
  const next = questions[idx + 1]

  return (
    <>
      <p className="crumbs">
        <Link to="/questions">Questions</Link>
        <span className="pager">
          {prev && <Link to={`/questions/${prev.question_id}`}>← #{prev.question_id}</Link>}
          {next && <Link to={`/questions/${next.question_id}`}>#{next.question_id} →</Link>}
        </span>
      </p>
      <h1>{q.question}</h1>
      <p className="q-meta">
        <span>#{q.question_id}</span>
        <Link to={`/questions?db=${q.db_id}`}>{q.db_id}</Link>
        <Badge kind={q.difficulty}>{q.difficulty}</Badge>
      </p>
      {q.evidence && <p className="evidence"><span className="muted">Evidence:</span> {q.evidence}</p>}

      <h2>Gold SQL</h2>
      <Code code={q.gold_sql} lang="sql" />
      <p className="muted">
        {q.gold_rows} row{q.gold_rows === 1 ? '' : 's'} in {q.gold_ms} ms.{' '}
        {q.sqlite_match === true && 'Matches the SQLite original.'}
        {q.sqlite_match === false && <Badge kind="bad">differs from the SQLite original</Badge>}
        {q.sqlite_match === null && 'Not cross-checked (SQLite query timed out).'}
        {q.gold_fixed && ' The Postgres gold SQL for this one was wrong and has been fixed by hand.'}
      </p>
      {q.gold_preview && q.gold_preview.length > 0 && (
        <div className="table-wrap">
          <table className="preview">
            <tbody>
              {q.gold_preview.map((r, i) => <tr key={i}>{r.map((c, j) => <td key={j}>{c}</td>)}</tr>)}
            </tbody>
          </table>
        </div>
      )}

      {models && models.length > 0 && (
        <>
          <h2>Model answers</h2>
          {models.map((m) => <ModelAnswer key={m.id} model={m} questionId={q.question_id} />)}
        </>
      )}
    </>
  )
}

function ModelAnswer({ model, questionId }: { model: Model; questionId: number }) {
  const { data: runs, error } = useRuns(model.id)
  const [tab, setTab] = useState<'ruby' | 'sql'>('ruby')
  if (!runs) return <Loading error={error} />
  const run = runs.find((r) => r.question_id === questionId)
  if (!run) return null

  return (
    <section className="answer">
      <header>
        <strong>{model.name}</strong>
        <span className="answer-flags">
          <Verdict label="SQL" ok={run.sql_correct} />
          <Verdict label="ActiveRecord" ok={run.ar_correct} />
          {run.n_plus_one && <Badge kind="bad">N+1</Badge>}
          {run.sql_fallback && <Badge kind="warn">SQL fallback</Badge>}
          {run.query_count != null && <span className="muted">{run.query_count} queries</span>}
          {run.rows_loaded != null && <span className="muted">{run.rows_loaded} rows loaded</span>}
        </span>
      </header>
      <div className="tabs">
        <button className={tab === 'ruby' ? 'on' : ''} onClick={() => setTab('ruby')}>ActiveRecord</button>
        <button className={tab === 'sql' ? 'on' : ''} onClick={() => setTab('sql')}>SQL</button>
      </div>
      {tab === 'ruby'
        ? <Code code={run.ruby ?? '(no answer)'} lang="ruby" />
        : <Code code={run.sql ?? '(no answer)'} lang="sql" />}
      {run.error && <p className="error">{run.error}</p>}
      {run.queries?.length > 0 && (
        <details>
          <summary className="muted small">Queries sent ({run.query_count})</summary>
          <ol className="query-log">{run.queries.map((q, i) => <li key={i}><code>{q}</code></li>)}</ol>
        </details>
      )}
      {run.retry_ruby && (
        <details>
          <summary className="muted small">
            After N+1 feedback: {run.retry_query_count} queries, {run.retry_ar_correct ? 'correct' : 'wrong'}
            {run.retry_n_plus_one ? ', still N+1' : ''}
          </summary>
          <Code code={run.retry_ruby} lang="ruby" />
        </details>
      )}
    </section>
  )
}

function Verdict({ label, ok }: { label: string; ok: boolean | null }) {
  if (ok == null) return <Badge kind="muted">{label} n/a</Badge>
  return <Badge kind={ok ? 'good' : 'bad'}>{label} {ok ? 'correct' : 'wrong'}</Badge>
}
