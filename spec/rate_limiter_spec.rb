# frozen_string_literal: true

require 'spec_helper'
require_relative '../rate_limiter'

# TODO: Using and not stubbing Redis. Change latter.
describe 'RateLimiter' do
  let(:rl) { RateLimiter.new } # TODO: pass in the params for host and apikey

  # Perhaps before each make sure that redis is up?
  context 'When I have an api endpoint' do
    context 'assuming timer has not expired' do
      it 'is visible' do
        rl.should_not be_nil
      end

      it 'has the apikey available' do
        rl.apikey.should_not be_nil
      end

      it 'returns false if under limit' do
        rl = RateLimiter.new
        rl.disconnect
        rl.over_limit?.should be false
        # expect(answers).to be_falsey
      end

      it 'rl has not been connected to redis' do
        rl.disconnect if rl.connected?
        rl.connected?.should be_falsey
      end

      it 'should be connected after calling connect' do
        rl.disconnect if rl.connected?
        result = rl.connect # TODO: should this take arguments?
        expect(result).to be_truthy
      end

      it 'should be able to be disconnected' do
        rl.connect unless rl.connected?
        rl.disconnect if rl.connected?
        expect(rl.connected?).to be_falsey
      end

      it 'should increment counter when checking that (over_limit?) was called' do
        # For this simple implementation testing with #over_limit? will increment counter
        rl.connect unless rl.connected?
        rl.over_limit?
        expect { rl.over_limit? }.to change { rl.count }.by(1)
      end

      it 'should return over limit if too many calls were made' do
        # it 'should reset the rate limit for the action to 0 upon next request to over_limit?' do
        rl = RateLimiter.new
        rl.disconnect # if rl.connected?
        (600 - 1).times { rl.over_limit? }
        expect(rl.over_limit?).to be_falsey
        expect(rl.over_limit?).to be_truthy
      end
    end

    context 'assuming timer has expired' do
      it 'the count should be reset to 0' do
        rl = RateLimiter.new
        rl.disconnect # if rl.connected?
        (600 - 1).times { rl.over_limit? }
        expect(rl.over_limit?).to be_falsey
        expect(rl.over_limit?).to be_truthy

        expect(rl.over_limit?).to be_truthy
        expect(rl.over_limit?).to be_truthy
        expect(rl.over_limit?).to be_truthy
        # the timer has expired here => over_limit? is false again
        sleep 1
        expect(rl.over_limit?).to be_falsey
      end
    end
  end
end
