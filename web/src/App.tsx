import { NavLink, Route, Routes } from 'react-router-dom'
import { useModels } from './lib/data'
import Failures from './pages/Failures'
import Leaderboard from './pages/Leaderboard'
import Overview from './pages/Overview'
import Playground from './pages/Playground'
import QuestionDetail from './pages/QuestionDetail'
import Questions from './pages/Questions'

export default function App() {
  const { data: models } = useModels()
  const hasRuns = (models?.length ?? 0) > 0

  return (
    <>
      <header className="site-header">
        <NavLink to="/" className="brand">NPlusOneBench</NavLink>
        <nav>
          <NavLink to="/" end>Overview</NavLink>
          {hasRuns && <NavLink to="/leaderboard">Leaderboard</NavLink>}
          <NavLink to="/questions">Questions</NavLink>
          {hasRuns && <NavLink to="/failures">Failures</NavLink>}
          {hasRuns && <NavLink to="/playground">Playground</NavLink>}
        </nav>
      </header>
      <main>
        <Routes>
          <Route path="/" element={<Overview />} />
          <Route path="/leaderboard" element={<Leaderboard />} />
          <Route path="/questions" element={<Questions />} />
          <Route path="/questions/:id" element={<QuestionDetail />} />
          <Route path="/failures" element={<Failures />} />
          <Route path="/playground" element={<Playground />} />
          <Route path="*" element={<p>Page not found.</p>} />
        </Routes>
      </main>
      <footer className="site-footer">
        Data: <a href="https://github.com/bird-bench/mini_dev">BIRD Mini-Dev</a> (CC BY-SA 4.0) ·{' '}
        <a href="https://github.com/Sivaniulax/NPlusOneBench">source</a>
      </footer>
    </>
  )
}
