require 'rubygems'
require 'sinatra'
require 'sinatra/namespace'
require 'json'
require 'data_mapper'
require './lib/import_methods'

#Setup Database connection
  DataMapper::Logger.new($stdout, :debug)
  DataMapper.setup(:default, ENV['db_credentials'] || 'postgres://demo_api:dev@localhost/demo_api_db')
  
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
    
    def ensure_non_conflicting_date_time
        if Appointment.all(:start_time => (self.start_time..self.end_time), :end_time => (self.start_time..self.end_time)).empty?
          [true]
        else
          [false, "Conflicting appointment times for #{self.start_time.strftime('%m/%d/%y')}"]
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
        Appointment.all(:start_time => (start_t..end_t), :end_time => (start_t..end_t)).to_json
      end
    end
    
    # CREATE
    post '/?' do
      appointment = Appointment.new(params[:appointment])
      if appointment.save
        status 201
        appointment.to_json
      else
        error_response
      end
    end
    
    # UPDATE
    namespace '/:id' do
      before do
        @appointment = Appointment.get(params[:id])
        status 200 # Subject to change
      end
      
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
        { :error => @appointment.errors.full_messages }.to_json
      end
    
    #   CATCH ALL INVALID REQUESTS
    get '/*' do
      url = "#{request.scheme}://#{request.host}/"
      { :error => "Invalid API request. Please review the documentation at #{url}" }.to_json
    end
    
  end