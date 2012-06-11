require File.dirname(__FILE__) + '/../base'

module Rubyquiz

  module Solitaire

    class Deck

      def initialize
        @deck = (1..52).to_a + ('A'..'B').to_a
      end

      def move_A
        move_down('A')
      end

      def move_B
        2.times{ move_down('B') }
      end

      def triple_cut
        top_joker, bottom_joker = @deck.index('A') < @deck.index('B') ? ['A','B'] : ['B','A']
        above_top_joker = top_joker == @deck.first ? [] : @deck[0..@deck.index(top_joker)-1]
        below_bottom_joker = bottom_joker == @deck.last ? [] : @deck[@deck.index(top_joker)+1..-1]
        @deck = below_bottom_joker + @deck[@deck.index(top_joker)..@deck.index(bottom_joker)] + above_top_joker
        self
      end

      def count_cut
        @deck = @deck[@deck[-1]..-2] + @deck[0..@deck[-1]-1] + [@deck[-1]]
      end

      def output_letter
        card = @deck[@deck.first]
        return nil if ['A','B'].include?(card)
        return (64 + card % 26).chr
      end

      private
      def move_down(card)
        card_index = @deck.index(card)
        if card == @deck.last
          @deck.insert(1, @deck.pop)
        else
          @deck[card_index], @deck[card_index+1] = @deck[card_index+1], @deck[card_index]
        end
        self
      end

    end

    class Encrypt

      # step 1
      def self.discard_non_az_and_upcase(message)
        message.upcase.gsub(/[^A-Z]/,'')
      end

      # split the message into five character groups, using Xs to pad the last group, if needed
      def self.split_and_pad(message)
        pad_remainder = message.size % 5
        message += ("X" * (5 - pad_remainder)) unless pad_remainder == 0
        message.scan(/.{5}/).join(" ")
      end

      def self.step_1(message)
        self.split_and_pad(self.discard_non_az_and_upcase(message))
      end

    end

  end

end
