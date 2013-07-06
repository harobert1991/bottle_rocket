require 'test_helper'

module BottleRocket
  module Containers

    class AmountContainerTest < TestCase

      before do
        @amount_container = AmountContainer.new(:minutes, 1)
      end

      it 'has value' do
        assert_equal 1, @amount_container.value
      end

      it 'has unit' do
        assert_equal :minutes, @amount_container.unit
      end

      it 'has a 1 value' do
        [-1, 1].each do |n|
          amount_container = AmountContainer.new(:minutes, n)

          assert amount_container.one?
        end
      end

      it 'has no 1 value' do
        [-2, 0, 2].each do |n|
          amount_container = AmountContainer.new(:minutes, n)

          refute amount_container.one?
        end
      end

      it 'creates html' do
        assert_equal '<span class="minutes-1">1</span>', @amount_container.to_html
      end
    end

  end
end