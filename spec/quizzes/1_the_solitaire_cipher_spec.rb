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

        it "should be able to move all cards above the top joker to below the bottom joker and vice versa" do
          deck_of_cards.should respond_to(:triple_cut)
          deck_of_cards.move_A
          deck_of_cards.move_B
          deck_of_cards.triple_cut
          deck_of_cards.instance_variable_get(:@deck).should == ['B'] + (2..52).to_a + ['A',1]
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

        it "should have a method to return the step result" do
          encrypt.should respond_to(:step_1)
          encrypt.step_1(message).should == "CODEI NRUBY LIVEL ONGER"
        end

      end

    end

  end

end
