export default function Badge({ kind, children }: { kind: string; children: React.ReactNode }) {
  return <span className={`badge badge-${kind}`}>{children}</span>
}
