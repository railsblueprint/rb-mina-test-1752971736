def escape(value)
  value.to_s.gsub('"', '\"')
end

# rubocop:disable Metrics/BlockLength
namespace :settings do
  desc "Generate migration for new settings"
  task generate: :environment do
    code = Setting.unscoped.where(not_migrated: true).where(deleted_at: nil).map { |setting|
      <<-CODEEND
    if Setting.where("key": "#{setting.key}").any?
      Setting.where("key": "#{setting.key}").update_all(
        type:        "#{setting.type}",
        section:     "#{setting.section}",
        description: "#{setting.description}",
      )
    else
      Setting.create(
        "key":       "#{setting.key}",
        type:        "#{setting.type}",
        section:     "#{setting.section}",
        value:       "#{escape setting.value}",
        description: "#{setting.description}",
      )
    end
      CODEEND
    }.join

    code += Setting.unscoped.where.not(deleted_at: nil).where(not_migrated: false).map { |setting|
      <<-CODEEND
    Setting.where("key": "#{setting.key}").delete_all
      CODEEND
    }.join

    Setting.unscoped.where(not_migrated: true).update_all(not_migrated: false)
    Setting.unscoped.where.not(deleted_at: nil).delete_all

    if code.present?
      time = Time.current.strftime("%Y%m%d%H%M%S")
      timestamp = Time.now.to_i
      filename = "#{time}_create_settings#{timestamp}.rb"
      body = <<~CODEEND
        class CreateSettings#{timestamp} < ActiveRecord::Migration[#{ActiveRecord::VERSION::STRING.to_f}]
          def up
        #{code}
          end

          def down
          end
        end
      CODEEND

      File.write("db/data/#{filename}", body)
      puts "Generating file db/data/#{filename}"
    else
      puts "No new settings found"
    end
  end
end
# rubocop:enable Metrics/BlockLength
