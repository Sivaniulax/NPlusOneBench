# Records every query and every instantiated record while a block runs.
class QueryLog
  IGNORED = %w[SCHEMA TRANSACTION].freeze
  attr_reader :queries, :rows_loaded

  def initialize
    @queries = []
    @rows_loaded = 0
  end

  def record
    sql_sub = ActiveSupport::Notifications.subscribe("sql.active_record") do |*, payload|
      next if IGNORED.include?(payload[:name]) || payload[:cached]
      @queries << payload[:sql]
    end
    inst_sub = ActiveSupport::Notifications.subscribe("instantiation.active_record") do |*, payload|
      @rows_loaded += payload[:record_count]
    end
    yield
  ensure
    ActiveSupport::Notifications.unsubscribe(sql_sub)
    ActiveSupport::Notifications.unsubscribe(inst_sub)
  end

  # Same statement shape run again and again, e.g. one SELECT per parent row.
  def repeated
    queries.map { |q| fingerprint(q) }.tally.select { |_, n| n >= 3 }
  end

  def n_plus_one?
    repeated.keys.any? { |q| q.start_with?("SELECT") }
  end

  private

  def fingerprint(sql)
    sql.gsub(/'(?:[^']|'')*'/, "?").gsub(/\b\d+(\.\d+)?\b/, "?").gsub(/\s+/, " ").strip
  end
end
