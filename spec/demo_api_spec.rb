require File.expand_path '../spec_helper.rb', __FILE__
  
describe "List appointments" do
  context "without parameters" do
    let(:appt1) { Appointment.create(:first_name => 'c', :last_name => 'f', :start_time => DateTime.now - 1, :end_time => DateTime.now - 0.5) }
    before do
      get '/appointments/list', { "Content-Type" => "application/json" }
    end
    
    it "should have OK(200) status" do
      last_response.should be_ok
    end
  
    it "should show 1 records" do
      JSON.parse(last_response.body).should have(1).items
    end
  end
  
  context "with parameters" do
    
    it "should return 1 appointment" do
      get "/appointments/list/2011-04-13T09:00:00-05:00/2011-04-13T09:10:00-05:00"
      JSON.parse(last_response.body).should have(1).items
    end
    
    it "should return 2 appointments" do
      get "/appointments/list/2011-04-13T09:00:00-05:00/2011-04-13T13:20:00-05:00"
      JSON.parse(last_response.body).should have(2).items
    end
    
    it "should return 3 appointments" do
      get "/appointments/list/2011-04-13T09:00:00-05:00/2011-04-13T15:05:00-05:00"
      JSON.parse(last_response.body).should have(3).items
    end
  end
end

describe "Create Appointments" do
  let(:valid_appointment) { { :appointment => { :first_name => 'Curtis', :last_name => 'Foster', :start_time => DateTime.now + 1, :end_time => DateTime.now + 1.1 } }.to_json }
  let(:appointment_in_the_past) { { :appointment => { :first_name => 'Curtis', :last_name => 'Foster', :start_time => DateTime.now - 1, :end_time => DateTime.now - 1.1 } }.to_json }
  before do
    post '/appointments', valid_appointment, { "Content-Type" => "application/json" }
  end
  
  it "with valid start/end times" do
    JSON.parse(last_response.body).first_name.should == "Curtis"
    last_response.should be_created
  end
end
