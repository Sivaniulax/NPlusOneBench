import { Link } from 'react-router-dom'
import Loading from '../components/Loading'
import { DIFFICULTIES, useDataset } from '../lib/data'

const fmt = new Intl.NumberFormat('en')

export default function Overview() {
  const { data: ds, error } = useDataset()

  return (
    <>
      <h1>When LLMs write ActiveRecord instead of SQL</h1>
      <p className="lead">
        Is the ORM code as correct as the SQL, and is it safe to run in production?
        Models answer the 500 BIRD Mini-Dev questions both ways. We check the answers
        and count the queries each one fires.
      </p>

      {!ds ? <Loading error={error} /> : (
        <>
          <div className="stats">
            <Stat label="questions" value={ds.questions} />
            <Stat label="databases" value={Object.keys(ds.databases).length} />
            <Stat label="foreign keys" value={ds.totals.foreign_keys} />
            <Stat label="rows" value={fmt.format(ds.totals.rows)} />
          </div>

          <h2>Difficulty</h2>
          <Bars rows={DIFFICULTIES.map((d) => [d, ds.difficulty[d]])} total={ds.questions} />

          <h2>What the gold SQL uses</h2>
          <p className="muted">Share of gold queries using each feature. Most need joins, so most test associations.</p>
          <Bars
            rows={Object.entries(ds.sql_feature_pct).sort((a, b) => b[1] - a[1])}
            total={100}
            suffix="%"
          />

          <h2>Gold audit</h2>
          <p>
            Every Postgres gold query was run and compared with the original SQLite answer.{' '}
            <strong>{ds.gold_audit.ok ?? 0}</strong> of {ds.questions} match.
            {ds.gold_audit.mismatch ? <> {ds.gold_audit.mismatch} don't (<Link to="/questions?status=mismatch">see which</Link>).</> : null}
            {ds.gold_unverified.length > 0 && <> {ds.gold_unverified.length} couldn't be checked because the SQLite query timed out.</>}
          </p>

          <h2>Databases</h2>
          <div className="table-wrap">
            <table>
              <thead>
                <tr><th>database</th><th className="num">questions</th><th className="num">tables</th><th className="num">FKs</th><th className="num">rows</th></tr>
              </thead>
              <tbody>
                {Object.entries(ds.databases).map(([db, s]) => (
                  <tr key={db}>
                    <td><Link to={`/questions?db=${db}`}>{db}</Link></td>
                    <td className="num">{ds.per_database[db]}</td>
                    <td className="num">{s.tables}</td>
                    <td className="num">{s.foreign_keys}</td>
                    <td className="num">{fmt.format(s.rows)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </>
      )}
    </>
  )
}

function Stat({ label, value }: { label: string; value: string | number }) {
  return (
    <div className="stat">
      <div className="stat-value">{value}</div>
      <div className="stat-label">{label}</div>
    </div>
  )
}

function Bars({ rows, total, suffix = '' }: { rows: [string, number][]; total: number; suffix?: string }) {
  return (
    <div className="bars">
      {rows.map(([label, n]) => (
        <div className="bar-row" key={label}>
          <span className="bar-label">{label.replace('_', ' ')}</span>
          <span className="bar-track"><span className="bar-fill" style={{ width: `${(n / total) * 100}%` }} /></span>
          <span className="bar-value">{n}{suffix}</span>
        </div>
      ))}
    </div>
  )
}
