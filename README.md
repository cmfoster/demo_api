# Demo API
=========================

Ruby 2.0.0p353
--------------

#### Setup
**gem install:**
```
sinatra
data_mapper
dm-postgres-adapter
sinatra-contrib
json
```
##### Testing
**gem install:**
```
rspec
timecop
```
Or Just
`bundle install`
Hopefully I've included all of the right gems.

***

### API Methods

**Output/input formats supported:**
JSON

#### Appointments:

**List**
`/appointments/list (int start_time, int end_time) GET`
Entering a start_time or end_time is not required and will return all appointments.
*Status: 200*

**Create**
`/appointments POST`
Example request data:
```
  {
    appointment:
      {
        first_name: Curtis,
        last_name:  Foster,
        start_time: <DateTime>,
        end_time:   <DateTime>,
        comments:   Pretty much hired.
      }
  }
```
*Status: 201*

**Update**
`/appointments/update/{id} PUT`
Example request data:
```
        {
          appointment:
            {
              first_name: Curtis,
              last_name:  Foster,
              start_time: <DateTime>,
              end_time:   <DateTime>,
              comments:   Rescheduled to 30 minutes later. Pretty much hired.
            }
        }
```
*Status: 200*

**Delete**
`/appointments/{id} DELETE`
*Status: 200*
