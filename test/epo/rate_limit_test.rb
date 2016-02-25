require 'test_helper'

module Epo
  class RateLimitTest < Minitest::Test
    # #limit_reached

    def test_limit_reached_is_true_if_header_x_rejection_reason_is_set
      limit = Epo::Ops::RateLimit.new('x-rejection-reason' => 'empty')
      assert limit.limit_reached?
    end

    def test_limit_reached_is_false_if_header_x_rejection_reason_is_set
      limit = Epo::Ops::RateLimit.new({})
      refute limit.limit_reached?
    end

    # #rejection_reason

    def test_return_the_right_rejection_reason
      limit = Epo::Ops::RateLimit.new('x-rejection-reason' => 'RegisteredQuotaPerWeek')
      assert_equal :weekly_quota, limit.rejection_reason

      limit = Epo::Ops::RateLimit.new('x-rejection-reason' => 'IndividualQuotaPerHour')
      assert_equal :hourly_quota, limit.rejection_reason
    end

    # #horly_quota

    def test_return_the_hourly_quota_if_it_is_set
      limit = Epo::Ops::RateLimit.new('x-individualquotaperhour-used' => '12345')
      assert_equal 12_345, limit.hourly_quota
    end

    def test_return_nil_if_the_hourly_quota_isnt_set
      limit = Epo::Ops::RateLimit.new({})
      assert_equal nil, limit.hourly_quota
    end

    # #weekly_quota

    def test_return_the_weekly_quota_if_it_is_set
      limit = Epo::Ops::RateLimit.new('x-registeredquotaperweek-used' => '12345')
      assert_equal 12_345, limit.weekly_quota
    end

    def test_return_nil_if_the_weekly_quota_isnt_set
      limit = Epo::Ops::RateLimit.new({})
      assert_equal nil, limit.weekly_quota
    end

    # #reset_at

    def test_return_the_next_monday_if_rejection_reason_is_the_weekly_quota
      limit = Epo::Ops::RateLimit.new('x-rejection-reason' => 'RegisteredQuotaPerWeek')
      assert_equal limit.reset_at, Time.now.to_i + 604_800
    end

    def test_return_10_minutes_from_now_if_ejection_reason_is_the_hourly_quota
      limit = Epo::Ops::RateLimit.new('x-rejection-reason' => 'IndividualQuotaPerHour')
      assert_equal limit.reset_at, Time.now.to_i + 600
    end

    def test_return_1_minute_from_now_if_the_reason_is_unknown
      limit = Epo::Ops::RateLimit.new('x-rejection-reason' => 'Foobar')
      assert_equal limit.reset_at, Time.now.to_i + 60
    end
  end
end
