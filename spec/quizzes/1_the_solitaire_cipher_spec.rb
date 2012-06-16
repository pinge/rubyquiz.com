require File.dirname(__FILE__) + '/../spec_helper'
Dir[File.dirname(__FILE__) + "/../../rubyquiz/1_the_solitaire_cipher/*.rb"].each{ |file| require file }

module Rubyquiz

  module Solitaire

    describe Deck do

      it "should be initialized with 52 cards and 2 jokers (A and B)" do
        deck_of_cards = Deck.new
        deck_of_cards.instance_variable_get(:@deck).should == (1..52).to_a + ('A'..'B').to_a
      end

      context "moving cards (consider a circular deck)" do

        let(:deck_of_cards){ Deck.new }

        it "should be able to move down a card in the middle of the deck" do
          deck_of_cards.should_not respond_to(:move_down)
          deck_of_cards.send(:move_down, 'A')
          deck_of_cards.instance_variable_get(:@deck).should == (1..52).to_a + ('A'..'B').to_a.reverse
        end

        it "should be able to move down a card in the beginning of the deck" do
          deck_of_cards.send(:move_down, 1)
          deck_of_cards.instance_variable_get(:@deck).should == [2,1] + (3..52).to_a + ('A'..'B').to_a
        end

        it "should be able to move down a card in the end of the deck" do
          deck_of_cards.send(:move_down, 'B')
          deck_of_cards.instance_variable_get(:@deck).should == [1,'B'] + (2..52).to_a << 'A'
        end

      end

      context "moving jokers in the deck" do

        let(:deck_of_cards){ Deck.new }

        context "should be able to move the A joker down one card" do

          it "when the joker is at the beginning of the deck" do
            deck_of_cards.should respond_to(:move_A)
            deck_of_cards.instance_variable_set(:@deck, ['A'] + (1..52).to_a << 'B')
            deck_of_cards.move_A
            deck_of_cards.instance_variable_get(:@deck).should == [1,'A'] + (2..52).to_a << 'B'
          end

          it "when the joker is in the middle of the deck" do
            deck_of_cards.move_A
            deck_of_cards.instance_variable_get(:@deck).should == (1..52).to_a + ('A'..'B').to_a.reverse
          end

          it "when the joker is at the end of the deck" do
            deck_of_cards.instance_variable_set(:@deck, (1..52).to_a + ['B','A'])
            deck_of_cards.move_A
            deck_of_cards.instance_variable_get(:@deck).should == [1,'A'] + (2..52).to_a << 'B'
          end

        end

        context "moving the B joker" do

          it "when the joker is at the beginning of the deck" do
            deck_of_cards.should respond_to(:move_B)
            deck_of_cards.instance_variable_set(:@deck, ['B'] + (1..52).to_a << 'A')
            deck_of_cards.move_B
            deck_of_cards.instance_variable_get(:@deck).should == [1,2,'B'] + (3..52).to_a << 'A'
          end

          it "when the joker is in the middle of the deck" do
            deck_of_cards.instance_variable_set(:@deck, (1..20).to_a + ['B'] + (21..52).to_a + ['A'])
            deck_of_cards.move_B
            deck_of_cards.instance_variable_get(:@deck).should == (1..22).to_a + ['B'] + (23..52).to_a + ['A']
          end

          it "when the joker is just above the bottom card, move it below the top card" do
            deck_of_cards.instance_variable_set(:@deck, (1..52).to_a + ['B','A'])
            deck_of_cards.move_B
            deck_of_cards.instance_variable_get(:@deck).should == [1, 'B'] + (2..52).to_a << 'A'
          end

          it "when the joker is the bottom card, move it just below the second card" do
            deck_of_cards.instance_variable_set(:@deck, (1..52).to_a + ['A','B'])
            deck_of_cards.move_B
            deck_of_cards.instance_variable_get(:@deck).should == [1,2,'B'] + (3..52).to_a << 'A'
          end

        end

      end

      context "triple cut around the 2 jokers" do

        let(:deck_of_cards){ Deck.new }

        it "should have a method called triple_cut" do
          deck_of_cards.should respond_to(:triple_cut)
        end

        context "should be able to move all cards above the top joker to below the bottom joker and vice versa" do

          it "when joker A is at the bottom of the deck and there are cards between the two jokers" do
            deck_of_cards.instance_variable_set(:@deck, (1..10).to_a + ['B'] + (11..52).to_a + ['A'])
            deck_of_cards.triple_cut
            deck_of_cards.instance_variable_get(:@deck).should == ['B'] + (11..52).to_a + ['A'] + (1..10).to_a
          end

          it "when joker B is at the bottom of the deck and there are cards between the two jokers" do
            deck_of_cards.instance_variable_set(:@deck, (1..10).to_a + ['A'] + (11..52).to_a + ['B'])
            deck_of_cards.triple_cut
            deck_of_cards.instance_variable_get(:@deck).should == ['A'] + (11..52).to_a + ['B'] + (1..10).to_a
          end

          it "when joker A is at the top of the deck and there are cards between the two jokers" do
            deck_of_cards.instance_variable_set(:@deck, ['A'] + (1..10).to_a + ['B'] + (11..52).to_a)
            deck_of_cards.triple_cut
            deck_of_cards.instance_variable_get(:@deck).should == (11..52).to_a + ['A'] + (1..10).to_a + ['B']
          end

          it "when joker B is at the top of the deck and there are cards between the two jokers" do
            deck_of_cards.instance_variable_set(:@deck, ['B'] + (1..12).to_a + ['A'] + (13..52).to_a)
            deck_of_cards.triple_cut
            deck_of_cards.instance_variable_get(:@deck).should == (13..52).to_a + ['B'] + (1..12).to_a + ['A']
          end

          it "when joker A is above joker B, the two jokers are together and are in the middle of the deck" do
            deck_of_cards.instance_variable_set(:@deck, (1..20).to_a + ['A','B'] + (21..52).to_a)
            deck_of_cards.triple_cut
            deck_of_cards.instance_variable_get(:@deck).should == (21..52).to_a + ['A','B'] + (1..20).to_a
          end

          it "when joker B is above joker A, the two jokers are together and are in the middle of the deck" do
            deck_of_cards.instance_variable_set(:@deck, (1..30).to_a + ['B','A'] + (31..52).to_a)
            deck_of_cards.triple_cut
            deck_of_cards.instance_variable_get(:@deck).should == (31..52).to_a + ['B','A'] + (1..30).to_a
          end

          it "when joker A is above joker B, there are cards between the two jokers and the two jokers are in the middle of the deck" do
            deck_of_cards.instance_variable_set(:@deck, (1..20).to_a + ['A'] + (21..25).to_a + ['B'] + (26..52).to_a)
            deck_of_cards.triple_cut
            deck_of_cards.instance_variable_get(:@deck).should == (26..52).to_a + ['A'] + (21..25).to_a + ['B'] + (1..20).to_a
          end

          it "when joker B is above joker A, there are cards between the two jokers and the two jokers are in the middle of the deck" do
            deck_of_cards.instance_variable_set(:@deck, (1..10).to_a + ['B'] + (11..41).to_a + ['A'] + (42..52).to_a)
            deck_of_cards.triple_cut
            deck_of_cards.instance_variable_get(:@deck).should == (42..52).to_a + ['B'] + (11..41).to_a + ['A'] + (1..10).to_a
          end

        end

      end

      context "count cut using the value of the bottom card" do

        let(:deck_of_cards){ Deck.new }

        it "should be able to cut the bottom card's value in cards off the top of the deck and reinsert them just above the bottom card" do
          deck_of_cards.should respond_to(:count_cut)
          deck_of_cards.instance_variable_set(:@deck, ['B'] + (2..52).to_a + ['A',1])
          deck_of_cards.count_cut
          deck_of_cards.instance_variable_get(:@deck).should == (2..52).to_a + ['A','B',1]
        end

      end

      context "output a letter" do

        let(:deck_of_cards){ Deck.new }

        it "should find the output letter, converting the top card to it's value and count down that many cards from the
            top of the deck, with the top card itself being card number one. Look at the card immediately after your
            count and convert it to a letter" do
          deck_of_cards.should respond_to(:output_letter)
          deck_of_cards.instance_variable_set(:@deck, (2..52).to_a + ['A','B',1])
          deck_of_cards.output_letter.should == 'D'

          d = Deck.new

          ['D','W','J',nil,'X','H','Y','R','F','D','G'].each do |expected_letter|
            d.move_A
            d.move_B
            d.triple_cut
            d.count_cut
            d.output_letter.should == expected_letter
          end

        end

      end

    end

    describe "Rubyquiz::Solitaire::Encryption module" do

      it "should enable a generic Encryption/Decryption class to extend it" do

        class Crypt
          extend Rubyquiz::Solitaire::Encryption
        end

      end

      context "a Crypt class that extends the module" do

        let(:crypt){ class Crypt; extend Rubyquiz::Solitaire::Encryption end }

        it "should generate a keystream letter for any given letter in a message" do
          deck_of_cards = Deck.new
          crypt.should respond_to(:generate_keystream_letter)
          crypt.generate_keystream_letter(deck_of_cards).should == "D"
          crypt.generate_keystream_letter(deck_of_cards).should == "W"
        end

        it "should generate a keystreamed message for any given message" do
          crypt.should respond_to(:generate_keystreamed_message)
          crypt.generate_keystreamed_message("CODEI NRUBY LIVEL ONGER").should == "DWJXH YRFDG TMSHP UURXJ"
        end

        it "should convert any letter (A-Z) to a number (1-26), C to 3, W to 15, etc" do
          crypt.should respond_to(:letter_to_number)
          ("A".."Z").to_a.each_with_index do |letter,index|
            crypt.letter_to_number(letter).should == index+1
          end
        end

        it "should convert a message of letter to numbers" do
          crypt.should respond_to(:letters_to_numbers)
          crypt.letters_to_numbers("CODEI NRUBY LIVEL ONGER").should == [3,15,4,5,9,nil,14,18,21,2,25,nil,12,9,22,5,12,nil,15,14,7,5,18]
        end

        it "should convert a number (1-26) to a letter (A-Z), 3 to C, 15 to W, etc" do
          crypt.should respond_to(:number_to_letter)
          letters = ("A".."Z").to_a
          (1..26).to_a.each_with_index do |number,index|
            crypt.number_to_letter(number).should == letters[index]
          end
        end

        it "should convert a message of numbers to letters" do
          crypt.should respond_to(:numbers_to_letters)
          crypt.numbers_to_letters([3,15,4,5,9,nil,14,18,21,2,25,nil,12,9,22,5,12,nil,15,14,7,5,18]).should == "CODEI NRUBY LIVEL ONGER"
        end

      end

    end

    describe Encrypt do

      let(:encrypt){ Rubyquiz::Solitaire::Encrypt }
      let(:message){ "Code in Ruby, live longer!" }

      context "1. Discard any non A to Z characters, and uppercase all remaining letters. Split the
                message into five character groups, using Xs to pad the last group, if needed." do

        it "should discard any non A-Z characters and uppercase all remaining letters" do
          encrypt.should respond_to(:discard_non_az_and_upcase)
          encrypt.discard_non_az_and_upcase(message).should == "CODEINRUBYLIVELONGER"
        end

        it "should split the message into five character groups, using Xs to pad the last group if needed" do
          encrypt.should respond_to(:split_and_pad)
          encrypt.split_and_pad("ABCDE").should == "ABCDE"
          encrypt.split_and_pad("ABCD").should == "ABCDX"
          encrypt.split_and_pad("ABCDEF").should == "ABCDE FXXXX"
          encrypt.split_and_pad("CODEINRUBYLIVELONGER").should == "CODEI NRUBY LIVEL ONGER"
        end

        it "should have a 'normalize' method to return the step result" do
          encrypt.should respond_to(:normalize)
          encrypt.normalize(message).should == "CODEI NRUBY LIVEL ONGER"
        end

      end

      context "2. Use Solitaire to generate a keystream letter for each letter in the message." do

        it "should have a method to return the step result" do
          encrypt.should respond_to(:generate_keystreamed_message)
          encrypt.generate_keystreamed_message("CODEI NRUBY LIVEL ONGER").should == "DWJXH YRFDG TMSHP UURXJ"
        end

      end

      context "3. Convert the message from step 1. into numbers, A = 1, B = 2, etc.." do

        it "should have a method to return the step result" do
          encrypt.should respond_to(:letters_to_numbers)
          encrypt.letters_to_numbers("CODEI NRUBY LIVEL ONGER").should == [3,15,4,5,9,nil,14,18,21,2,25,nil,12,9,22,5,12,nil,15,14,7,5,18]
        end

      end

      context "4. Convert the keystream letters from step 2. using the same method" do

        it "should have a method to return the step result" do
          encrypt.letters_to_numbers("DWJXH YRFDG TMSHP UURXJ").should == [4,23,10,24,8,nil,25,18,6,4,7,nil,20,13,19,8,16,nil,21,21,18,24,10]
        end

      end

      context "5. Add the message numbers from step 3 to the keystream numbers from step 4 and subtract 26 from the
                  result if it is greater than 26. For example, 6 + 10 = 16 as expected, but 26 + 1 = 1 (27 - 26):" do

        it "should have a method to return the step result" do
          encrypt.should respond_to(:merge)
          encrypt.merge([3,15,4,5,9,nil,14,18,21,2,25,nil,12,9,22,5,12,nil,15,14,7,5,18],
                        [4,23,10,24,8,nil,25,18,6,4,7,nil,20,13,19,8,16,nil,21,21,18,24,10]){
              |v1, v2| t = v1 + v2; t / 26 > 0 ? t % 26 : t
          }.should == [7,12,14,3,17,nil,13,10,1,6,6,nil,6,22,15,13,2,nil,10,9,25,3,2]
        end

      end

      context "6. Convert the numbers from step 5 back to letters" do

        it "should have a method to return the step result" do
          encrypt.should respond_to(:numbers_to_letters)
          encrypt.numbers_to_letters([7,12,14,3,17,nil,13,10,1,6,6,nil,6,22,15,13,2,nil,10,9,25,3,2]).should == "GLNCQ MJAFF FVOMB JIYCB"
        end

      end

      context "additional messages to encrypt" do

        {
            "Code in Ruby, live longer!" => "GLNCQ MJAFF FVOMB JIYCB"
        }.each do |decrypted_message, encrypted_message|

          it "should be able to encrypt the message: #{decrypted_message}" do

            encrypt.run(decrypted_message).should == encrypted_message

          end

        end

      end

    end

    describe Decrypt do

      let(:decrypt){ Rubyquiz::Solitaire::Decrypt }
      let(:message){ "GLNCQ MJAFF FVOMB JIYCB" }
      let(:message_after_step_2){  }
      let(:message_after_step_3){  }

      context "1. Use Solitaire to generate a keystream letter for each letter in the message to be decoded. Again, I
                  detail this process below, but sender and receiver use the same key and will get the same letters:" do

        it "should have a method to return the step result" do
          decrypt.should respond_to(:generate_keystreamed_message)
          decrypt.generate_keystreamed_message(message).should == "DWJXH YRFDG TMSHP UURXJ"
        end

      end

      context "2. Convert the message to be decoded to numbers" do

        it "should have a method to return the step result" do
          decrypt.should respond_to(:letters_to_numbers)
          decrypt.letters_to_numbers(message).should == [7, 12, 14, 3, 17, nil, 13, 10, 1, 6, 6, nil, 6, 22, 15, 13, 2, nil, 10, 9, 25, 3, 2]
        end

      end

      context "3. Convert the keystream letters from step 1 to numbers" do

        it "should have a method to return the step result" do
          decrypt.should respond_to(:letters_to_numbers)
          decrypt.letters_to_numbers("DWJXH YRFDG TMSHP UURXJ").should == [4, 23, 10, 24, 8, nil, 25, 18, 6, 4, 7, nil, 20, 13, 19, 8, 16, nil, 21, 21, 18, 24, 10]
        end

      end

      context "4. Subtract the keystream numbers from step 3 from the message numbers from step 2. If the message number
                  is less than or equal to the keystream number, add 26 to the message number before subtracting.
                  For example, 22 - 1 = 21 as expected, but 1 - 22 = 5 (27 - 22)" do

        it "should have a method to return the step result" do
          decrypt.should respond_to(:merge)
          decrypt.merge([7, 12, 14, 3, 17, nil, 13, 10, 1, 6, 6, nil, 6, 22, 15, 13, 2, nil, 10, 9, 25, 3, 2],
                        [4, 23, 10, 24, 8, nil, 25, 18, 6, 4, 7, nil, 20, 13, 19, 8, 16, nil, 21, 21, 18, 24, 10]){
              |v1, v2| t = v1 - v2; t > 0 ? t : t + 26
          }.should == [3, 15, 4, 5, 9, nil, 14, 18, 21, 2, 25, nil, 12, 9, 22, 5, 12, nil, 15, 14, 7, 5, 18]
        end

      end

      context "5. Convert the numbers from step 4 back to letters" do

        it "should have a method to return the step result" do
          decrypt.should respond_to(:numbers_to_letters)
          decrypt.numbers_to_letters([3, 15, 4, 5, 9, nil, 14, 18, 21, 2, 25, nil, 12, 9, 22, 5, 12, nil, 15, 14, 7, 5, 18]).should == "CODEI NRUBY LIVEL ONGER"
        end

      end

      context "additional messages to decrypt" do

        let(:decrypt){ Rubyquiz::Solitaire::Decrypt }

        {
            "CLEPK HHNIY CFPWH FDFEH" => "YOURC IPHER ISWOR KINGX",
            "ABVAW LWZSY OORYK DUPVH" => "WELCO METOR UBYQU IZXXX"
        }.each do |encrypted_message, decrypted_message|

          it "should be able to decrypt the message: #{encrypted_message}" do

            decrypt.run(encrypted_message).should == decrypted_message

          end

        end

      end

    end

  end

end
