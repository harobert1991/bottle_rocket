require 'test_helper'
require 'date'
require 'timecop'

module Countdown
  class TimeSpanTest < TestCase

    before do
      @now = DateTime.now
    end

    it 'should calculate no time units on zero duration' do
      starting_time = Time.at(DateTime.parse("2013-06-17 12:34:56").to_time, 0.0)
      target_time   = Time.at(DateTime.parse("2013-06-17 12:34:56").to_time, 0.0)
      time_span     = TimeSpan.new(starting_time, target_time)

      assert_all_zero_except(time_span, nil)
    end

    it 'should calculate all time units (in the future)' do
      starting_time = Time.at(DateTime.parse("2013-06-17 12:34:56").to_time, 2216234.383)
      target_time   = Time.at(DateTime.parse("5447-12-12 23:11:12").to_time, 3153476.737)
      time_span     = TimeSpan.new(starting_time, target_time)

      expected = {millenniums: 3, centuries: 4, decades: 3, years: 4, months: 5, weeks: 1, days: 5, hours: 10, minutes: 36, seconds: 16, millis: 937, micros: 242, nanos: 354}
      assert_equal expected.sort, time_span.duration.sort
    end

    it 'should calculate all time units backwards when target_time is before starting_time' do
      starting_time = Time.at(DateTime.parse("5447-12-12 23:11:12").to_time, 3153476.737)
      target_time   = Time.at(DateTime.parse("2013-06-17 12:34:56").to_time, 2216234.383)
      time_span     = TimeSpan.new(starting_time, target_time)

      expected = {millenniums: -3, centuries: -4, decades: -3, years: -4, months: -5, weeks: -1, days: -5, hours: -10, minutes: -36, seconds: -16, millis: -937, micros: -242, nanos: -354}
      assert_equal expected.sort, time_span.duration.sort
    end

    describe "day helpers" do

      it 'converts days to months and days by remaining_days given 0 days' do
        starting_time = DateTime.parse("2013-01-31 00:00:00")
        target_time   = DateTime.parse("2013-01-31 00:00:00")
        time_span     = TimeSpan.new(starting_time, target_time)

        remaining_days  = 0

        assert_equal [0, 0], time_span.days_to_months_and_days(remaining_days)
      end

      it 'converts days to months and days by remaining_days given 1 day' do
        starting_time = DateTime.parse("2013-01-31 00:00:00")
        target_time   = DateTime.parse("2013-02-01 00:00:00")
        time_span     = TimeSpan.new(starting_time, target_time)

        remaining_days  = 1

        assert_equal [0, 1], time_span.days_to_months_and_days(remaining_days)
      end

      it 'converts days to months and days by remaining_days given 29 days' do
        starting_time = DateTime.parse("2012-06-02 00:00:00")
        target_time   = DateTime.parse("2012-07-01 00:00:00")
        time_span     = TimeSpan.new(starting_time, target_time)

        remaining_days  = 29

        assert_equal [0, 29], time_span.days_to_months_and_days(remaining_days) # fails with 1 day ahead [1, 1]
      end

      it 'converts days to months and days by remaining_days given 30 days' do
        starting_time = DateTime.parse("2012-06-02 00:00:00")
        target_time   = DateTime.parse("2012-07-02 00:00:00")
        time_span     = TimeSpan.new(starting_time, target_time)

        remaining_days  = 30

        assert_equal [1, 0], time_span.days_to_months_and_days(remaining_days) # fails with 1 day ahead [1, 1]
      end

      it 'converts days to months and days by remaining_days given 30 days' do
        starting_time = DateTime.parse("2012-01-16 00:00:00")
        target_time   = DateTime.parse("2012-02-16 00:00:00")
        time_span     = TimeSpan.new(starting_time, target_time)

        remaining_days  = 31

        assert_equal [1, 0], time_span.days_to_months_and_days(remaining_days) # fails with 1 day ahead [1, 1]
      end

      # Should be equal in duration compared to 'converts days to months and days by remaining_days given 30 days'
      it 'converts days to months and days by remaining_days given 1 month' do
        starting_time = DateTime.parse("2012-06-01 00:00:00")
        target_time   = DateTime.parse("2012-07-01 00:00:00")
        time_span     = TimeSpan.new(starting_time, target_time)

        remaining_days  = 30

        assert_equal [1, 0], time_span.days_to_months_and_days(remaining_days)
      end

      # This is the problem! fails with [1, 0] see test above!
      it 'converts days to months and days by remaining_days given 1 month and 1 day' do
        starting_time = DateTime.parse("2012-06-01 00:00:00")
        target_time   = DateTime.parse("2012-07-02 00:00:00")
        time_span     = TimeSpan.new(starting_time, target_time)

        remaining_days  = 31

        assert_equal [1, 1], time_span.days_to_months_and_days(remaining_days)
      end

      # This is the problem! fails with [1, 0] see test above!
      it 'converts days to months and days by remaining_days given 1 month and 2 days' do
        starting_time = DateTime.parse("2012-06-01 00:00:00")
        target_time   = DateTime.parse("2012-07-03 00:00:00")
        time_span     = TimeSpan.new(starting_time, target_time)

        remaining_days  = 32

        assert_equal [1, 2], time_span.days_to_months_and_days(remaining_days)
      end

      it 'converts days to months and days by remaining_days given 94 days' do #fails
        starting_time = DateTime.parse("2013-06-01 00:00:00")
        target_time   = DateTime.parse("2013-09-03 00:00:00")
        time_span     = TimeSpan.new(starting_time, target_time)

        remaining_days  = 94

        assert_equal [3, 2], time_span.days_to_months_and_days(remaining_days)
      end

      it 'shows day count for date' do
        time_span = TimeSpan.new(@now, @now)

        assert_equal 28, time_span.days_in_month(Date.parse("2013-02-01"))
        assert_equal 29, time_span.days_in_month(Date.parse("2012-02-01"))
        assert_equal 30, time_span.days_in_month(Date.parse("2013-06-01"))
      end

      it 'gathers days by upcoming months' do
        starting_time = DateTime.parse("2013-06-17 00:00:00")
        target_time   = DateTime.parse("2013-12-02 00:00:00")
        time_span     = TimeSpan.new(starting_time, target_time)

        assert_equal [13, 1, 31, 31, 30, 31, 30], time_span.days_by_upcoming_months(starting_time, target_time)
      end

      it 'converts date first day in month' do
        time_span = TimeSpan.new(@now, @now)

        assert_equal Date.parse("2013-02-01"), time_span.first_day_in_month(Date.parse("2013-02-13"))
      end

    end

    describe 'travels' do



    end

    describe 'duration in nanos' do

      it 'should calculate duration for 1 day in the future' do
        assert_equal 86400000000000, TimeSpan.new(@now, @now+1).duration_in_nanos
      end

      it 'should calculate positive duration for 1 day in the past' do
        assert_equal 86400000000000, TimeSpan.new(@now, @now-1).duration_in_nanos
      end

      it 'should calculate duration for same timestamp' do
        assert_equal 0, TimeSpan.new(@now, @now).duration_in_nanos
      end

      it 'should calculate duration for last week' do
        assert_equal 86400000000000, TimeSpan.new(@now-7, @now-6).duration_in_nanos
      end

    end

    describe 'collects leap years' do

      it 'collects 0 leap years on leap start year' do
        starting_time = DateTime.parse("2012-03-13 00:00:00") # leap year but after February the 29th
        target_time   = DateTime.parse("2015-06-01 00:00:00")
        time_span     = TimeSpan.new(starting_time, target_time)

        assert time_span.leap_years.empty?
        assert_equal 0, time_span.leap_count
      end

      it 'collects 0 leap years on leap target year' do
        starting_time = DateTime.parse("2011-01-01 00:00:00")
        target_time   = DateTime.parse("2012-02-27 00:00:00") # leap year but before February the 29th
        time_span     = TimeSpan.new(starting_time, target_time)

        assert time_span.leap_years.empty?
        assert_equal 0, time_span.leap_count
      end

      it 'collects 1 leap year' do
        starting_time = DateTime.parse("2016-01-01 00:00:00") # leap year
        target_time   = DateTime.parse("2017-06-01 00:00:00")
        time_span     = TimeSpan.new(starting_time, target_time)

        assert_equal [2016], time_span.leap_years
        assert_equal 1, time_span.leap_count
      end

      it 'collects 2 leap years' do
        starting_time = DateTime.parse("2012-01-01 00:00:00") # leap year
        target_time   = DateTime.parse("2016-06-01 00:00:00")
        time_span     = TimeSpan.new(starting_time, target_time)

        assert_equal [2012, 2016], time_span.leap_years
        assert_equal 2, time_span.leap_count
      end

    end

    describe 'edge cases' do

      describe 'unix epoch' do

        it 'should calculate dates before 1970' do
          starting_time = DateTime.parse("1960-01-01 00:00:00")
          target_time   = DateTime.parse("2010-01-01 00:00:00")
          time_span     = TimeSpan.new(starting_time, target_time)

          refute target_time == starting_time

          expected = {millenniums: 0, centuries: 0, decades: 5, years: 0, months: 0, weeks: 0, days: 0, hours: 0, minutes: 0, seconds: 0, millis: 0, micros: 0, nanos: 0}
          assert_equal expected.sort, time_span.duration.sort
        end

        it 'should calculate dates after 2039' do
          starting_time = DateTime.parse("1960-01-01 00:00:00")
          target_time   = DateTime.parse("2050-01-01 00:00:00")
          time_span     = TimeSpan.new(starting_time, target_time)

          refute target_time == starting_time

          expected = {millenniums: 0, centuries: 0, decades: 9, years: 0, months: 0, weeks: 0, days: 0, hours: 0, minutes: 0, seconds: 0, millis: 0, micros: 0, nanos: 0}
          assert_equal expected.sort, time_span.duration.sort
        end

      end

      describe 'time zone switches' do

        it 'switches to summer time' do
          starting_time = DateTime.parse("2013-03-31 01:59:00 CEST")
          target_time   = DateTime.parse("2013-03-31 02:01:00 CEST")
          time_span     = TimeSpan.new(starting_time, target_time)

          assert_equal 2, time_span.minutes
          assert_all_zero_except(time_span, :minutes)
        end

        it 'switches to winter time' do
          starting_time = DateTime.parse("2013-10-31 02:59:00 CEST")
          target_time   = DateTime.parse("2013-10-31 03:01:00 CEST")
          time_span     = TimeSpan.new(starting_time, target_time)

          assert_equal 2, time_span.minutes
          assert_all_zero_except(time_span, :minutes)
        end

      end

      describe 'leap years' do

        it 'has no leap year' do
          starting_time = DateTime.parse("2013-01-01 00:00:00")
          target_time   = DateTime.parse("2014-01-01 00:00:00")
          time_span     = TimeSpan.new(starting_time, target_time)

          expected = {millenniums: 0, centuries: 0, decades: 0, years: 1, months: 0, weeks: 0, days: 0, hours: 0, minutes: 0, seconds: 0, millis: 0, micros: 0, nanos: 0}
          assert_equal expected.sort, time_span.duration.sort
        end

        it 'should be 1 year on exact leap date (start is leap)' do
          starting_time = DateTime.parse("2012-02-29 00:00:00") # leap year
          target_time   = DateTime.parse("2013-02-28 00:00:00")
          time_span     = TimeSpan.new(starting_time, target_time)

          expected = {millenniums: 0, centuries: 0, decades: 0, years: 1, months: 0, weeks: 0, days: 0, hours: 0, minutes: 0, seconds: 0, millis: 0, micros: 0, nanos: 0}
          assert_equal expected.sort, time_span.duration.sort
        end

        it 'should be 1 year on exact leap date (target is leap)' do
          starting_time = DateTime.parse("2011-02-28 00:00:00")
          target_time   = DateTime.parse("2012-02-29 00:00:00") # leap year
          time_span     = TimeSpan.new(starting_time, target_time)

          expected = {millenniums: 0, centuries: 0, decades: 0, years: 1, months: 0, weeks: 0, days: 0, hours: 0, minutes: 0, seconds: 0, millis: 0, micros: 0, nanos: 0}
          assert_equal expected.sort, time_span.duration.sort
        end

        it 'has 1 leap year' do
          starting_time = DateTime.parse("2012-01-01 00:00:00") # leap year
          target_time   = DateTime.parse("2013-01-01 00:00:00")
          time_span     = TimeSpan.new(starting_time, target_time)

          expected = {millenniums: 0, centuries: 0, decades: 0, years: 1, months: 0, weeks: 0, days: 0, hours: 0, minutes: 0, seconds: 0, millis: 0, micros: 0, nanos: 0}
          assert_equal expected.sort, time_span.duration.sort
        end

        it 'has 1 leap year within 3 years' do
          starting_time = DateTime.parse("2012-01-01 00:00:00") # leap year
          target_time   = DateTime.parse("2015-01-01 00:00:00")
          time_span     = TimeSpan.new(starting_time, target_time)

          expected = {millenniums: 0, centuries: 0, decades: 0, years: 3, months: 0, weeks: 0, days: 0, hours: 0, minutes: 0, seconds: 0, millis: 0, micros: 0, nanos: 0}
          assert_equal expected.sort, time_span.duration.sort
        end

        it 'has 2 leap years within 4 years' do
          starting_time = DateTime.parse("2012-01-01 00:00:00") # leap year
          target_time   = DateTime.parse("2016-01-01 00:00:00") # leap year
          time_span     = TimeSpan.new(starting_time, target_time)

          expected = {millenniums: 0, centuries: 0, decades: 0, years: 4, months: 0, weeks: 0, days: 0, hours: 0, minutes: 0, seconds: 0, millis: 0, micros: 0, nanos: 0}
          assert_equal expected.sort, time_span.duration.sort
        end

        it 'has 3 leap years within 8 years' do
          starting_time = DateTime.parse("2012-01-01 00:00:00") # leap year
          target_time   = DateTime.parse("2020-01-01 00:00:00")
          time_span     = TimeSpan.new(starting_time, target_time)

          expected = {millenniums: 0, centuries: 0, decades: 0, years: 8, months: 0, weeks: 0, days: 0, hours: 0, minutes: 0, seconds: 0, millis: 0, micros: 0, nanos: 0}
          assert_equal expected.sort, time_span.duration.sort
        end

      end

    end

    describe 'millenniums' do

      it 'should calculate 1 millennium' do
        starting_time = DateTime.parse("1000-06-02 00:00:00")
        target_time   = DateTime.parse("2000-06-02 00:00:00")
        time_span     = TimeSpan.new(starting_time, target_time)

        assert_equal 1, time_span.millenniums
        assert_all_zero_except(time_span, :millenniums)
      end

      it 'should calculate 2 millenniums' do
        starting_time = DateTime.parse("0000-06-02 00:00:00")
        target_time   = DateTime.parse("2000-06-02 00:00:00")
        time_span     = TimeSpan.new(starting_time, target_time)

        assert_equal 2, time_span.millenniums
        assert_all_zero_except(time_span, :millenniums)
      end

    end

    describe 'centuries' do

      it 'should calculate 1 century' do
        starting_time = DateTime.parse("2000-06-02 00:00:00")
        target_time   = DateTime.parse("2100-06-02 00:00:00")
        time_span     = TimeSpan.new(starting_time, target_time)

        assert_equal 1, time_span.centuries
        assert_all_zero_except(time_span, :centuries)
      end

      it 'should calculate 2 centuries' do
        starting_time = DateTime.parse("1900-06-02 00:00:00")
        target_time   = DateTime.parse("2100-06-02 00:00:00")
        time_span     = TimeSpan.new(starting_time, target_time)

        assert_equal 2, time_span.centuries
        assert_all_zero_except(time_span, :centuries)
      end

    end

    describe 'decades' do

      it 'should calculate 1 decade' do
        starting_time = DateTime.parse("2010-06-02 00:00:00")
        target_time   = DateTime.parse("2020-06-02 00:00:00")
        time_span     = TimeSpan.new(starting_time, target_time)

        assert_equal 1, time_span.decades
        assert_all_zero_except(time_span, :decades)
      end

      it 'should calculate 2 decades' do
        starting_time = DateTime.parse("2010-06-02 00:00:00")
        target_time   = DateTime.parse("2030-06-02 00:00:00")
        time_span     = TimeSpan.new(starting_time, target_time)

        assert_equal 2, time_span.decades
        assert_all_zero_except(time_span, :decades)
      end

    end

    describe 'years' do

      it 'should calculate 1 year' do
        starting_time = DateTime.parse("2013-06-02 00:00:00")
        target_time   = DateTime.parse("2014-06-02 00:00:00")
        time_span     = TimeSpan.new(starting_time, target_time)

        assert_equal 1, time_span.years
        assert_all_zero_except(time_span, :years)
      end

      it 'should calculate 2 years' do
        starting_time = DateTime.parse("2013-06-02 00:00:00")
        target_time   = DateTime.parse("2015-06-02 00:00:00")
        time_span     = TimeSpan.new(starting_time, target_time)

        assert_equal 2, time_span.years
        assert_all_zero_except(time_span, :years)
      end

    end

    describe 'months' do

      it 'should calculate 1 month' do
        starting_time = DateTime.parse("2012-06-01 00:00:00")
        target_time   = DateTime.parse("2012-07-01 00:00:00")
        time_span     = TimeSpan.new(starting_time, target_time)

        assert_all_zero_except(time_span, :months)
        assert_equal 1, time_span.months
      end

      it 'should calculate 2 months' do
        starting_time = DateTime.parse("2012-06-01 00:00:00")
        target_time   = DateTime.parse("2012-08-01 00:00:00")
        time_span     = TimeSpan.new(starting_time, target_time)

        assert_all_zero_except(time_span, :months)
        assert_equal 2, time_span.months
      end

    end

    describe 'weeks' do

      it 'should calculate 1 week' do
        starting_time = DateTime.parse("2012-06-02 00:00:00")
        target_time   = DateTime.parse("2012-06-09 00:00:00")
        time_span     = TimeSpan.new(starting_time, target_time)

        assert_equal 1, time_span.weeks
        assert_all_zero_except(time_span, :weeks)
      end

      it 'should calculate 2 weeks' do
        starting_time = DateTime.parse("2012-06-02 00:00:00")
        target_time   = DateTime.parse("2012-06-16 00:00:00")
        time_span     = TimeSpan.new(starting_time, target_time)

        assert_equal 2, time_span.weeks
        assert_all_zero_except(time_span, :weeks)
      end

    end

    describe 'days' do

      it 'should calculate 1 day' do
        starting_time = DateTime.parse("2012-06-02 00:00:00")
        target_time   = DateTime.parse("2012-06-03 00:00:00")
        time_span     = TimeSpan.new(starting_time, target_time)

        assert_equal 1, time_span.days
        assert_all_zero_except(time_span, :days)
      end

      it 'should calculate 2 days' do
        starting_time = DateTime.parse("2012-06-02 00:00:00")
        target_time   = DateTime.parse("2012-06-04 00:00:00")
        time_span     = TimeSpan.new(starting_time, target_time)

        assert_equal 2, time_span.days
        assert_all_zero_except(time_span, :days)
      end

      it 'should calculate 0 days on whole year (not leap)' do
        starting_time = DateTime.parse("2013-06-01 00:00:00")
        target_time   = DateTime.parse("2014-06-01 00:00:00")
        time_span     = TimeSpan.new(starting_time, target_time)

        assert_equal 0, time_span.days
        assert_equal 1, time_span.years
        assert_all_zero_except(time_span, :years)
      end

    end

    describe 'hours' do

      it 'should calculate 1 hour' do
        starting_time = DateTime.parse("2012-06-02 00:00:00")
        target_time   = DateTime.parse("2012-06-02 01:00:00")
        time_span     = TimeSpan.new(starting_time, target_time)

        assert_equal 1, time_span.hours
        assert_all_zero_except(time_span, :hours)
      end

      it 'should calculate 2 hours' do
        starting_time = DateTime.parse("2012-06-02 00:00:00")
        target_time   = DateTime.parse("2012-06-02 02:00:00")
        time_span     = TimeSpan.new(starting_time, target_time)

        assert_equal 2, time_span.hours
        assert_all_zero_except(time_span, :hours)
      end

    end

    describe 'minutes' do

      it 'should calculate 1 minute' do
        starting_time = DateTime.parse("2012-06-02 00:00:00")
        target_time   = DateTime.parse("2012-06-02 00:01:00")
        time_span     = TimeSpan.new(starting_time, target_time)

        assert_equal 1, time_span.minutes
        assert_all_zero_except(time_span, :minutes)
      end

      it 'should calculate 2 minutes' do
        starting_time = DateTime.parse("2012-06-02 00:00:00")
        target_time   = DateTime.parse("2012-06-02 00:02:00")
        time_span     = TimeSpan.new(starting_time, target_time)

        assert_equal 2, time_span.minutes
        assert_all_zero_except(time_span, :minutes)
      end

    end

    describe 'seconds' do

      it 'should calculate 1 seconds' do
        starting_time = DateTime.parse("2012-06-02 00:00:00")
        target_time   = DateTime.parse("2012-06-02 00:00:01")
        time_span     = TimeSpan.new(starting_time, target_time)

        assert_equal 1, time_span.seconds
        assert_all_zero_except(time_span, :seconds)
      end

      it 'should calculate 2 seconds' do
        starting_time = DateTime.parse("2012-06-02 00:00:00")
        target_time   = DateTime.parse("2012-06-02 00:00:02")
        time_span     = TimeSpan.new(starting_time, target_time)

        assert_equal 2, time_span.seconds
        assert_all_zero_except(time_span, :seconds)
      end

    end

    describe 'milliseconds' do

      it 'should calculate 1 millisecond' do
        starting_time = Time.at @now.to_time.to_f
        target_time   = Time.at(starting_time.to_f, 1000.0)
        time_span     = TimeSpan.new(starting_time, target_time)

        refute target_time == starting_time

        assert_equal 1, time_span.millis
        assert_all_zero_except(time_span, :millis)
      end

      it 'should calculate 2 milliseconds' do
        starting_time = Time.at @now.to_time.to_f
        target_time   = Time.at(starting_time.to_f, 2000.0)
        time_span     = TimeSpan.new(starting_time, target_time)

        assert_equal 2, time_span.millis
        assert_all_zero_except(time_span, :millis)
      end

      it 'should calculate 4 milliseconds' do
        starting_time = Time.at(DateTime.parse("2013-06-17 12:34:56").to_time, 101000.0)
        target_time   = Time.at(DateTime.parse("2013-06-17 12:34:56").to_time, 618000.0)
        time_span     = TimeSpan.new(starting_time, target_time)

        assert_equal 517, time_span.millis
        assert_all_zero_except(time_span, :millis)
      end

    end

    describe 'microseconds' do

      it 'should calculate 1 microsecond' do
        starting_time = Time.at @now.to_time.to_f
        target_time   = Time.at(starting_time.to_f, 1.0)
        time_span     = TimeSpan.new(starting_time, target_time)

        refute target_time == starting_time

        assert_equal 1, time_span.micros
        assert_all_zero_except(time_span, :micros)
      end

      it 'should calculate 235 microseconds' do
        starting_time = Time.at @now.to_time.to_f
        target_time   = Time.at(starting_time.to_f, 235.0)
        time_span     = TimeSpan.new(starting_time, target_time)

        refute target_time == starting_time

        assert_equal 235, time_span.micros
        assert_all_zero_except(time_span, :micros)
      end

    end

    describe 'nanoseconds' do

      it 'should calculate 1 nanosecond' do
        starting_time = Time.at @now.to_time.to_f
        target_time   = Time.at(starting_time.to_f, 0.001)
        time_span     = TimeSpan.new(starting_time, target_time)

        refute target_time == starting_time

        assert_equal 1, time_span.nanos
        assert_all_zero_except(time_span, :nanos)
      end

      it 'should calculate 235 nanoseconds' do
        starting_time = Time.at @now.to_time.to_f
        target_time   = Time.at(starting_time.to_f, 0.235)
        time_span     = TimeSpan.new(starting_time, target_time)

        refute target_time == starting_time

        assert_equal 235, time_span.nanos
        assert_all_zero_except(time_span, :nanos)
      end

    end

    private

    def assert_all_zero_except(time_span, *time_units)
      units = [:millenniums, :decades, :decades, :years, :months, :weeks, :days, :hours, :minutes, :seconds, :millis, :micros, :nanos] - time_units
      not_zero = []
      units.each do |time_unit|
        not_zero << time_unit if time_span[time_unit] != 0
      end

      assert not_zero.empty?, "All units except #{time_units} should be 0: #{time_span.duration}"
    end

  end
end