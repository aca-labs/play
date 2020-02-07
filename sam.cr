require "crystal-rethinkdb"
require "engine-models/spec/generator"
require "http/client"
require "sam"
require "uuid"
require "yaml"

include RethinkDB::Shortcuts

desc "Drops Elasticsearch and RethinkDB"
task "drop", %w[drop:db drop:elastic] do
end

namespace "drop" do
  desc "Deletes all elastic indices tables"
  task "elastic" do |_, args|
    uri = URI.new(
      host: (args["host"]? || ENV["ES_HOST"]? || "localhost").to_s,
      port: (args["port"]? || ENV["ES_PORT"]? || 9200).to_i,
      path: "/_all",
      scheme: "http"
    )
    HTTP::Client.delete(uri)
  end

  desc "Drops all RethinkDB tables"
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

namespace "generate" do
  desc "Creates a representative set of documents in RethinkDB"
  task "documents" do
    version = UUID.random.to_s.split('-').first

    # Repository metadata
    repository_uri = "https://github.com/acaengine/private-drivers"
    repository_folder_name = "drivers"
    repository_name = repository_folder_name
    repository = ACAEngine::Model::Generator.repository(type: ACAEngine::Model::Repository::Type::Driver)
    repository.uri = repository_uri
    repository.name = repository_name
    repository.folder_name = repository_folder_name
    repository.save!

    # Driver metadata
    driver_file_name = "drivers/aca/private_helper.cr"
    driver_module_name = "PrivateHelper"
    driver_name = "spec_helper"
    driver_role = ACAEngine::Model::Driver::Role::Logic
    driver_version = SemanticVersion.new(major: 0, minor: 1, patch: 0)
    driver = ACAEngine::Model::Driver.new(
      name: driver_name,
      role: driver_role,
      commit: "head",
      version: driver_version,
      module_name: driver_module_name,
      file_name: driver_file_name,
    )
    driver.repository = repository
    driver.save!

    # Zone metadata
    zone_name = "TestZone-#{version}"
    zone = ACAEngine::Model::Zone.new(name: zone_name)
    zone.save!

    # ControlSystem metadata
    begin
      control_system_name = "TestSystem-#{version}"
      control_system = ACAEngine::Model::ControlSystem.new(name: control_system_name)
      control_system.save!
    rescue e : RethinkORM::Error::DocumentInvalid
      puts e.model.errors
      raise e
    end

    # Settings metadata
    settings_string = %(test_setting: true)
    settings_encryption_level = ACAEngine::Encryption::Level::None
    settings = ACAEngine::Model::Settings.new(encryption_level: settings_encryption_level, settings_string: settings_string)
    settings.control_system = control_system
    settings.save!

    # Module metadata
    module_name = "TestModule-#{version}"
    mod = ACAEngine::Model::Generator.module(driver: driver, control_system: control_system)
    mod.name = module_name
    mod.save!

    # Update subarrays of ControlSystem
    control_system.modules = [mod.id.as(String)]
    control_system.zones = [zone.id.as(String)]
    control_system.save!

    # Trigger metadata
    trigger_name = "TestTrigger-#{version}"
    trigger_description = "a test trigger"
    trigger = ACAEngine::Model::Trigger.new(name: trigger_name, description: trigger_description)
    trigger.control_system = control_system
    trigger.save!

    # TriggerInstance
    trigger_instance = ACAEngine::Model::TriggerInstance.new
    trigger_instance.control_system = control_system
    trigger_instance.zone = zone
    trigger_instance.trigger = trigger
    trigger_instance.save!
  end
end

Sam.help
