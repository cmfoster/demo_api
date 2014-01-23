require File.expand_path '../spec_helper.rb', __FILE__

describe "List appointments" do
  before do
    Timecop.freeze(DateTime.parse('2014-01-01T00:00:00'))
  end

  context "without parameters" do
    let!(:appt1) { Appointment.create(:first_name => 'c', :last_name => 'f', :start_time => DateTime.now + (1*24*60*60) , :end_time => DateTime.now + (1*24*60*60 + 60*30) ) }
    before do
      get '/appointments/list', { "Content-Type" => "application/json" }
    end
    subject { last_response }

    it { should be_ok }

    it "should show 1 records" do
      JSON.parse(last_response.body).should have(1).items
    end
  end

  context "with parameters" do
    let!(:appt1) { Appointment.create(:first_name => 'c', :last_name => 'f', :start_time => DateTime.parse('2014-01-01T01:00:00') , :end_time => DateTime.parse('2014-01-01T01:30:00') ) }
    let!(:appt2) { Appointment.create(:first_name => 'd', :last_name => 'e', :start_time => DateTime.parse('2014-01-01T01:30:01'), :end_time => DateTime.parse('2014-01-01T02:00:00') ) }
    let!(:appt3) { Appointment.create(:first_name => 'f', :last_name => 'h', :start_time => DateTime.parse('2014-01-01T02:30:01') , :end_time => DateTime.parse('2014-01-01T03:00:00') ) }

    it "should return 1 appointment" do
      get "/appointments/list/2014-01-01T01:00:00/2014-01-01T01:30:00"
      JSON.parse(last_response.body).should have(1).items
    end

    it "should return 2 appointments (Overlaping times)" do
      get "/appointments/list/2014-01-01T01:15:00/2014-01-01T01:45:00"
      JSON.parse(last_response.body).should have(2).items
    end

    it "should return 3 appointments" do
      get "/appointments/list/2014-01-01T00:50:00/2014-01-01T02:30:01"
      JSON.parse(last_response.body).should have(3).items
    end
  end
end

describe "Create Appointments" do
  before do
    Timecop.freeze(DateTime.parse('2014-01-01T00:00:00'))
    @invalid_appt_attributes = { :first_name => 'Curtis', :last_name => 'Foster', :start_time => DateTime.parse('2013-12-31T01:00:00') , :end_time => DateTime.parse('2013-12-31T01:30:00') }
    @valid_appt_attributes   = { :first_name => 'Curtis', :last_name => 'Foster', :start_time => DateTime.parse('2014-01-01T01:00:00') , :end_time => DateTime.parse('2014-01-01T01:30:00') }
  end

  it "with valid start/end times" do
    post '/appointments', {:appointment => @valid_appt_attributes}, { "Content-Type" => "application/json" }

    JSON.parse(last_response.body)["first_name"].should == "Curtis"
    last_response.status.should eq(201)
  end


  it "with invalid (in the past) start/end times" do
    post '/appointments/', {:appointment => @invalid_appt_attributes}, { "Content-Type" => "application/json" }
    last_response.status.should eq(409)
    last_response.body.should include("Start and end times must be in the future")
  end

end

describe "Update Appointment" do
  before do
    Timecop.freeze(DateTime.parse('2014-01-01T00:00:00'))
  end

  let!(:appointment) { Appointment.create(:first_name => 'd', :last_name => 'e', :start_time => DateTime.parse('2014-01-01T01:30:01'), :end_time => DateTime.parse('2014-01-01T02:00:00') ) }

  context "successfully" do
    before { put "/appointments/#{appointment.id}/", { :appointment => { :comments => "Success!" } }, { "content-Type" => "application/json" } }

    subject { last_response }

    it { should be_ok }

    it "with a new comment" do
      JSON.parse(last_response.body)["comments"].should eq("Success!")
    end
  end

  context "unsuccessfully" do
    before { put "/appointments/#{appointment.id}/", { :appointment => { :start_time => DateTime.parse('2013-12-31T23:59:59') } }, { "content-Type" => "application/json" } }

    subject { last_response }

    it { subject.status.should eq(409) }
    it { subject.body.should include("Start and end times must be in the future") }
  end
end

describe "Delete Appointment" do
  let!(:appointment) { Appointment.create(:first_name => 'd', :last_name => 'e', :start_time => DateTime.parse('2014-01-01T01:30:01'), :end_time => DateTime.parse('2014-01-01T02:00:00') ) }

  subject { last_response }

  before do
    delete "/appointments/#{appointment.id}"
  end

  it { should be_ok }

  it "and it should be removed" do
    Appointment.get(appointment.id).should be_nil
  end

end
