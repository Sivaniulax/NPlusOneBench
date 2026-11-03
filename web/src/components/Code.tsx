export default function Code({ code, lang }: { code: string; lang: string }) {
  return (
    <div className="code">
      <span className="code-lang">{lang}</span>
      <pre><code>{code}</code></pre>
    </div>
  )
}
