Demo API for Care Cloud
========

Ruby 2.0.0p353

#Setup
  gem install:
    sinatra
    data_mapper
    dm-postgres-adapter
    sinatra-contrib
    json

  Testing
    gem install:
      rspec
      timecop


Output/input formats supported:
  JSON

Appointments:

  #List
    /appointments/list (int start_time, int end_time) GET
      Entering a start_time or end_time is not required and will return all appointments.
      ==Status: 200 If successful==

  #Create
    /appointments/create POST
      Example request data:
        {
          appointment:
            {
              first_name: Curtis,
              last_name:  Foster,
              start_time: Fri Nov 01 08:05:00 -0500 2013,
              end_time:   Fri Nov 01 08:35:00 -0500 2013
              comments:   Pretty much hired.
            }
        }

      ==Status: 201 If successful==

  #Update
    /appointments/update/{id} PUT
      Example request data:
        {
          appointment:
            {
              first_name: Curtis,
              last_name:  Foster,
              start_time: Fri Nov 01 08:30:00 -0500 2013,
              end_time:   Fri Nov 01 09:00:00 -0500 2013
              comments:   Rescheduled to 30 minutes later. Pretty much hired.
            }
        }
      ==Status: 200 If successful==

  #Delete
    /appointments/{id} DELETE
    ==Status: 200 If successful==
