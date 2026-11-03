require "active_record"
require "bigdecimal"
require "json"

# The bird dump stores timestamps as +08 and the gold SQL uses wall-clock
# literals, so Ruby has to agree with the database on the zone.
ENV["TZ"] = "Asia/Shanghai"
ActiveRecord.default_timezone = :local

module Bench
  STATEMENT_TIMEOUT_MS = 30_000
  MAX_ROWS = 10_000

  def self.connect(database: ENV.fetch("BIRD_DB", "bird"))
    ActiveRecord::Base.establish_connection(
      adapter: "postgresql",
      database: database,
      host: ENV["PGHOST"],
      username: ENV["PGUSER"],
      password: ENV["PGPASSWORD"],
      variables: { timezone: "Asia/Shanghai", statement_timeout: STATEMENT_TIMEOUT_MS },
    )
  end

  def self.load_models(db_id)
    dir = File.expand_path("../models/#{db_id}", __dir__)
    raise ArgumentError, "no models for #{db_id}" unless Dir.exist?(dir)
    Dir[File.join(dir, "*.rb")].sort.each { |f| require f }
  end

  # Turn whatever the answer returns into rows (arrays of plain values),
  # so it can be compared with the gold result set.
  def self.to_rows(value)
    value = value.to_a if value.is_a?(ActiveRecord::Relation)
    rows =
      case value
      when Hash then value.map { |k, v| [*Array(k), *Array(v)] }
      when Array then value.map { |v| row(v) }
      else [row(value)]
      end
    rows.first(MAX_ROWS).map { |r| r.map { |c| cell(c) } }
  end

  def self.row(v)
    case v
    when ActiveRecord::Base then v.attributes.values
    when Array then v
    when Hash then v.values
    else [v]
    end
  end

  def self.cell(c)
    case c
    when BigDecimal then c.to_f
    when Time, DateTime then c.strftime("%Y-%m-%d %H:%M:%S")
    when Date then c.iso8601
    when true then 1
    when false then 0
    when Numeric, String, nil then c
    else c.to_s
    end
  end
end

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  # several tables have a plain `type` column; it isn't STI
  self.inheritance_column = nil
end
