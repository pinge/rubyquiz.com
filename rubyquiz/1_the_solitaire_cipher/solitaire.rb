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
        below_bottom_joker = bottom_joker == @deck.last ? [] : @deck[@deck.index(bottom_joker)+1..-1]
        @deck = below_bottom_joker + @deck[@deck.index(top_joker)..@deck.index(bottom_joker)] + above_top_joker
        self
      end

      def count_cut
        @deck = @deck[@deck[-1]..-2] + @deck[0..@deck[-1]-1] + [@deck[-1]]
      end

      def output_letter
        card = @deck[['A','B'].include?(@deck.first) ? 53 : @deck.first]
        return nil if ['A','B'].include?(card)
        return (64 + card % 26).chr
      end

      def to_s
        @deck.inject(""){ |output,card| output << "#{card} " }
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

    module Encryption

      def generate_keystream_letter(deck)
        output_letter = nil
        while output_letter.nil? do
          deck.move_A
          deck.move_B
          deck.triple_cut
          deck.count_cut
          output_letter = deck.output_letter
        end
        output_letter
      end

      def generate_keystreamed_message(message)
        deck = Deck.new
        message.split("").inject(""){ |output,char| output << (char == " " ? " " : self.generate_keystream_letter(deck)) }
      end

      def letter_to_number(letter)
        letter.ord - "A".ord + 1
      end

      def letters_to_numbers(message)
        message.split("").inject([]){ |output,char| output << (char == " " ? nil : self.letter_to_number(char)) }
      end

      def number_to_letter(number)
        ("A".ord + number.to_i - 1).chr
      end

      def numbers_to_letters(message)
        message.inject(""){ |output,number| output << (number.nil? ? " " : self.number_to_letter(number)) }
      end

      def merge(message, keystreamed_message, &merger)
        message.each_with_index.inject([]) do |output, (value,index)|
          output << (value.nil? ? nil : merger.call(value, keystreamed_message[index]))
        end
      end

    end

    class Encrypt

      extend Encryption

      def self.discard_non_az_and_upcase(message)
        message.upcase.gsub(/[^A-Z]/,'')
      end

      def self.split_and_pad(message)
        pad_remainder = message.size % 5
        message += ("X" * (5 - pad_remainder)) unless pad_remainder == 0
        message.scan(/.{5}/).join(" ")
      end

      def self.normalize(message)
        self.split_and_pad(self.discard_non_az_and_upcase(message))
      end

      def self.run(message)
        normalized_message = self.normalize(message)
        keystreamed_message = self.generate_keystreamed_message(normalized_message)
        normalized_message_with_numbers = self.letters_to_numbers(normalized_message)
        keystreamed_message_with_numbers = self.letters_to_numbers(keystreamed_message)
        output = self.merge(keystreamed_message_with_numbers, normalized_message_with_numbers){ |v1, v2| t = v1 + v2; t / 26 > 0 ? t % 26 : t }
        self.numbers_to_letters(output)
      end

    end

    class Decrypt

      extend Encryption

      def self.run(message)
        keystreamed_message = self.generate_keystreamed_message(message)
        message_with_numbers = self.letters_to_numbers(message)
        keystreamed_message_with_numbers = self.letters_to_numbers(keystreamed_message)
        output = self.merge(message_with_numbers, keystreamed_message_with_numbers){ |v1, v2| t = v1 - v2; t > 0 ? t : t + 26 }
        self.numbers_to_letters(output)
      end

    end

  end

end
