# frozen_string_literal: true

require 'fileutils'
require 'pry'
require 'redis'

DOES_NOT_EXIST = -2
NEVER_EXPIRE = -1
MAX_REQUESTS_PER_MINUTE = 600
# TODO: Reset MINUTES=60 to conform to parameters of test. Used 1 second here because stubbing is out of band for now.
MINUTE = 1 # number of seconds

# Create an API Rate Limiter
class RateLimiter
  attr_reader :redis, :limit, :rate_limiter_key

  def initialize
    # host = 'localhost'
    # port = 6379
    # db = 12
    # TODO figure out how to get the redis server to connect with?
    # @redis = Redis.new(:host => host, :port => port, :db => db)
    @limit = MAX_REQUESTS_PER_MINUTE # in seconds
    Redis.exists_returns_integer = true
    @redis = Redis.new
    @rate_limiter_key = "#{apikey}:#{api_endpoint}"
  end

  # Assumption, every time this check is done if not over the limit an api call will be made.
  def over_limit?
    connect
    redis.incr rate_limiter_key
    redis.get(rate_limiter_key).to_i > limit
  end

  def apikey
    '780fffeadsad452660addef45125eeaf5'
  end

  # and there is still time before time interval expires
  def connected?
    redis.exists(rate_limiter_key) == 1 &&
      redis.ttl(rate_limiter_key).to_i.positive?
  end

  # Need to write Ruby Macro for Application's Controller to allow controller actions to be specified w/i controllers
  def api_endpoint
    'index'
  end

  def connect
    redis.set(rate_limiter_key, 0, ex: MINUTE) unless connected?
  end

  def count
    return 0 unless connected? # TODO: Is this what we want to do?

    redis.get(rate_limiter_key).to_i
  end

  def disconnect
    redis.del(rate_limiter_key)
  end
end
