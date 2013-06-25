require 'test_helper'
require 'date'

module TimeSpanner
  module TimeUnits

    class DayTest < TestCase
      include TimeHelpers

      before do
        starting_time = DateTime.parse('2013-04-03 00:00:00').to_time
        target_time   = DateTime.parse('2013-04-04 00:00:00').to_time

        @day = Day.new(starting_time, target_time)
      end

      it 'initializes' do
        assert @day.kind_of?(TimeUnit)
        assert_equal 7, @day.position
        assert_equal 0, @day.amount
        assert_equal 0, @day.rest
      end

      it 'calculates without rest' do
        starting_time = DateTime.parse('2013-04-03 00:00:00')
        target_time   = DateTime.parse('2013-04-05 00:00:00')
        day           = Day.new(starting_time, target_time)

        nanoseconds = DurationHelper.nanoseconds(starting_time, target_time)
        day.calculate(nanoseconds)

        assert_equal 2, day.amount
        assert_equal 0, day.rest
      end

      it 'calculates with rest' do
        starting_time = DateTime.parse('2013-04-03 00:00:00')
        target_days   = DateTime.parse('2013-04-05 00:00:00')
        target_time   = Time.at(target_days.to_time.to_r, 0.999)
        day           = Day.new(starting_time, target_time)

        nanoseconds = DurationHelper.nanoseconds(starting_time, target_time)
        day.calculate(nanoseconds)

        assert_equal 2, day.amount
        assert_equal 999, day.rest
      end

      describe 'leap days' do

        it 'calculates correctly without leap day' do
          starting_time = DateTime.parse('2013-01-01 00:00:00')
          target_time   = DateTime.parse('2014-01-01 00:00:00')
          day           = Day.new(starting_time, target_time)

          nanoseconds = DurationHelper.nanoseconds(starting_time, target_time)

          day.calculate(nanoseconds)

          assert_equal 365, day.amount
          assert_equal 0, day.rest
        end

        it 'calculates correctly on leap day' do
          starting_time = DateTime.parse('2012-01-01 00:00:00') # leap year
          target_time   = DateTime.parse('2013-01-01 00:00:00')
          day           = Day.new(starting_time, target_time)

          nanoseconds = DurationHelper.nanoseconds(starting_time, target_time)

          day.calculate(nanoseconds)

          assert_equal 365, day.amount
          assert_equal 0, day.rest
        end

      end

    end
  end
end