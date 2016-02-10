module Epo
  module Ops
    class RateLimit
      WEEKLY_QUOTA_RESET_TIME = 604_800
      HOURLY_QUOTA_RESET_TIME = 600
      BASE_RESET_TIME = 60

      attr_reader :attr

      def initialize(rate_limit)
        raise "Rate Limit data should be a Hash but is #{rate_limit.inspect} (#{rate_limit.class.name})" unless rate_limit.is_a?(Hash)
        @attr = rate_limit
      end

      def limit_reached?
        @attr['x-rejection-reason'].present?
      end

      def rejection_reason
        return nil unless @attr['x-rejection-reason']
        case @attr['x-rejection-reason']
        when 'RegisteredQuotaPerWeek' then :weekly_quota
        when 'IndividualQuotaPerHour' then :hourly_quota
        else :unknown_reason
        end
      end

      def hourly_quota
        quota = @attr['x-individualquotaperhour-used']
        quota.to_i if quota
      end

      def weekly_quota
        quota = @attr['x-registeredquotaperweek-used']
        quota.to_i if quota
      end

      def reset_at
        return unless limit_reached?

        case rejection_reason
        when :weekly_quota then Time.now.to_i + WEEKLY_QUOTA_RESET_TIME
        when :hourly_quota then Time.now.to_i + HOURLY_QUOTA_RESET_TIME
        else Time.now.to_i + BASE_RESET_TIME
        end
      end
    end
  end
end
