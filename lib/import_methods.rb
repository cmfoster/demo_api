class ImportCSV
  require 'csv'

  class << self
    def import
      begin
        appt_csv_raw = File.read('appt_data.csv')
        appt_csv = CSV.parse(appt_csv_raw, :headers => true)
        Appointment.destroy!
        appt_csv.each do |row|
          Appointment.create!(row.to_hash)
        end
        DataMapper.logger.info 'appt_data.csv Imported to database'
      rescue StandardError => e
        DataMapper.logger.error "CSV Import failed with message '#{e.message}'"
      end
    end
  end
end