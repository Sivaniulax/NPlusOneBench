export default function Loading({ error }: { error?: string }) {
  if (error) return <p className="error">Couldn't load data ({error}).</p>
  return <p className="muted">Loading…</p>
}
