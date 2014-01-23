require 'sinatra'
require 'sinatra/namespace'
require 'json'
require 'csv'
require 'data_mapper'
require './lib/import_methods'

#Setup Database connection
  DataMapper::Logger.new($stdout, :debug)
  DataMapper.setup(:default, ENV['DB_CREDENTIALS'] || 'postgres://demo_api:dev@localhost/demo_api_db')

#Setup Objects
  class Appointment
    include DataMapper::Resource
    property :id, Serial, :required => true
    property :start_time, DateTime, :required => true
    property :end_time, DateTime, :required => true
    property :first_name, String, :required => true
    property :last_name, String, :required => true
    property :comments, Text

    validates_with_method :ensure_non_conflicting_date_time
    validates_with_method :ensure_start_and_end_times_are_in_the_future

    private
      def ensure_non_conflicting_date_time
          if !attribute_dirty?(:start_time) || !attribute_dirty?(:end_time)
            [true]
          elsif Appointment.all(:start_time.lte => self.end_time, :end_time.gte => self.start_time).empty?
            [true]
          else
            [false, "Conflicting appointment times for #{self.start_time.strftime('%m/%d/%y')}"]
          end
      end

      def ensure_start_and_end_times_are_in_the_future
        if start_time > DateTime.now && end_time > DateTime.now
          [true]
        else
          [false, "Start and end times must be in the future."]
        end
      end

  end

#(DataMapper) - Validate models and initialize + Auto Migrate Changes if any.
  DataMapper.finalize
  DataMapper.auto_upgrade!

# Import Appointments from appt_data.csv
  ImportCSV.import if Appointment.count == 0

# Controller Methods

  get('/appointments/?') { "#{Appointment.count} Appointments in database" }

  namespace '/appointments' do
    before do
      content_type :json
    end

    # LIST
    namespace '/list' do
      before do
        status 200
      end

      get '/?' do
        Appointment.all.to_json
      end

      get '/:start_time/:end_time' do
        start_t, end_t = DateTime.parse(params[:start_time]), DateTime.parse(params[:end_time])

        status 200
        Appointment.all(:start_time.lte => end_t, :end_time.gte => start_t).to_json
      end
    end

    # CREATE
    post '/?' do
      @appointment = Appointment.new(params[:appointment])
      if @appointment.save
        status 201
        @appointment.to_json
      else
        error_response
      end
    end

    namespace '/:id' do
      before do
        @appointment = Appointment.get(params[:id])
        status 200
      end

      # UPDATE
      put '/?' do
        if @appointment && @appointment.update(params[:appointment])
          @appointment.to_json
        else
          error_response
        end
      end

      # DELETE
      delete do
        unless @appointment && @appointment.destroy
          error_response
        end
      end
    end

    private
      def error_response
        status (@appointment ? 409 : 404) # This should suffice for this small application
        if @appointment
          { :error => @appointment.errors.full_messages }.to_json
        else
          { :error => "Appointment not found."}.to_json
        end
      end

    #   CATCH ALL INVALID REQUESTS
    get '/*' do
      { :error => "Invalid API request. Please review the documentation at http://github.com/cmfoster/demo_api" }.to_json
    end

  end
