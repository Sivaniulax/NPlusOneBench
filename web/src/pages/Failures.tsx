import { useState } from 'react'
import { Link } from 'react-router-dom'
import Loading from '../components/Loading'
import { useModels, useTaxonomy, type Model } from '../lib/data'

const GROUPS: [string, string][] = [
  ['ar', 'ActiveRecord answers that were wrong'],
  ['sql', 'SQL answers that were wrong'],
  ['perf', 'Correct or not, slow in production'],
  ['style', 'Style'],
]

export default function Failures() {
  const { data: models, error } = useModels()
  if (!models) return <Loading error={error} />
  return (
    <>
      <h1>Failures</h1>
      {models.length === 0 ? <p className="muted">No results.</p> : <ByModel models={models} />}
    </>
  )
}

function ByModel({ models }: { models: Model[] }) {
  const { data: tax, error } = useTaxonomy()
  const [id, setId] = useState(models[0].id)
  if (!tax) return <Loading error={error} />
  const cats = tax[id] ?? {}

  return (
    <>
      <div className="filters">
        <select value={id} onChange={(e) => setId(e.target.value)}>
          {models.map((m) => <option key={m.id} value={m.id}>{m.name}</option>)}
        </select>
      </div>
      {GROUPS.map(([prefix, title]) => {
        const entries = Object.entries(cats).filter(([k]) => k.startsWith(prefix + ': ')).sort((a, b) => b[1].count - a[1].count)
        if (!entries.length) return null
        return (
          <section key={prefix}>
            <h2>{title}</h2>
            <div className="table-wrap">
              <table>
                <tbody>
                  {entries.map(([k, v]) => (
                    <tr key={k}>
                      <td>{k.slice(prefix.length + 2)}</td>
                      <td className="num">{v.count}</td>
                      <td className="examples">
                        {v.examples.map((q) => <Link key={q} to={`/questions/${q}`}>#{q}</Link>)}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </section>
        )
      })}
    </>
  )
}
