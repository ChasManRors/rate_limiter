Problem Statement:

Design and implement a rate-limiter to protect an API endpoint from abuse.
The desired behavior is that each client should be able to make at most 600 req/min.
When this limit is exceeded, the API should return HTTP status 429.


For the current state of the code

  Rspec tests rely on a running redis server (redis-server --loglevel warning)


  Calling Example:


    def index
      return head(:too_many_requests) rate_limiter.over_limit?
      ...
    end


  private

    def rate_limiter
      RateLimiter.new
    end


Which controller action to limit is hard coded.


The Redis server uses default params => runs locally


It turns out that there are existing ruby gems which might provide a better starting place for future enhancements of this work.

  Ex: https://github.com/rkotov93/rails_rate_limiter





For future versions:

1) Changes to calling conventions

  Below kludge can be removed once a Ruby Macro is in place in ApplicationController

  private

    def rate_limiter
      RateLimiter.new
    end


  Later the controller APIs should look more like this:

  ratelimiter :index, :create ...



2) Redis would be stubbed for the tests so a real version of redis would not be needed
   The actual time period (60 seconds) could be used instead of the 1 second time period used by tests



3) A small rails API can be created for further exploration and testing




4) Reference URLs



How to Build an API With Ruby on Rails
https://medium.com/swlh/how-to-build-an-api-with-ruby-on-rails-28e27d47455a

Reference info 
https://guides.rubyonrails.org/api_app.html#changing-an-existing-application

A Redis Playground
https://try.redis.io/

How to return status codes from rails api controllers
https://api.rubyonrails.org/classes/ActionController/Head.html

HTTP status code 429 - :too_many_requests
http://www.railsstatuscodes.com/too_many_requests.html