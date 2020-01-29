require "crystal-rethinkdb"
require "http/client"
require "sam"

include RethinkDB::Shortcuts

namespace "drop" do
  desc "deletes all elastic indices tables"
  task "elastic" do |_, args|
    uri = URI.new(
      host: (args["host"]? || ENV["ES_HOST"]? || "localhost").to_s,
      port: (args["port"]? || ENV["ES_PORT"]? || 9200).to_i,
      path: "/_all",
      scheme: "http"
    )
    HTTP::Client.delete(uri)
  end

  desc "drops all RethinkDB tables"
  task "db" do |_, args|
    conn = r.connect(
      host: (args["host"]? || ENV["RETHINKDB_HOST"]? || "localhost").to_s,
      port: (args["port"]? || ENV["RETHINKDB_PORT"]? || 28015).to_i,
      db: (args["db"]? || ENV["RETHINKDB_DB"]? || "test").to_s,
      user: (args["user"]? || "admin").to_s,
      password: (args["password"]? || "").to_s,
    )

    # Drop all tables in the db
    r.table_list.for_each do |table|
      r.table(table).delete
    end.run(conn)

    conn.close
  end
end

task "drop", %w[drop:db drop:elastic] do
end

Sam.help
