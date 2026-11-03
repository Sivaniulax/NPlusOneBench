# Runs ActiveRecord answers for one database.
#
#   ruby harness/run.rb <db_id> < tasks.jsonl > results.jsonl
#
# Each task line: {"id": ..., "code": "..."}. The code's last expression is
# the answer. Everything runs in a read-only transaction that is rolled back.
require_relative "lib/bench"
require_relative "lib/query_log"
require "timeout"

TASK_TIMEOUT_S = 60

db_id = ARGV.fetch(0)
Bench.connect
Bench.load_models(db_id)
$stdout.sync = true

def run_task(code)
  log = QueryLog.new
  out = {}
  started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  begin
    ActiveRecord::Base.transaction do
      ActiveRecord::Base.connection.execute("SET TRANSACTION READ ONLY")
      log.record do
        value = Timeout.timeout(TASK_TIMEOUT_S) { TOPLEVEL_BINDING.dup.eval(code, "answer.rb") }
        out[:rows] = Bench.to_rows(value)
      end
      raise ActiveRecord::Rollback
    end
  rescue Timeout::Error
    out[:error] = "Timeout"
  rescue ScriptError, StandardError => e
    out[:error] = "#{e.class}: #{e.message.lines.first&.strip}"
  end
  out.merge(
    ms: ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started) * 1000).round(1),
    query_count: log.queries.size,
    rows_loaded: log.rows_loaded,
    n_plus_one: log.n_plus_one?,
    repeated: log.repeated,
    queries: log.queries.first(50),
  )
end

$stdin.each_line do |line|
  task = JSON.parse(line)
  puts JSON.generate({ id: task["id"] }.merge(run_task(task["code"])))
end
