# encoding: utf-8
# frozen_string_literal: true
require 'spec_helper'
#
# resent-from     =       "Resent-From:" mailbox-list CRLF

RSpec.describe Mail::ResentFromField do
  
  describe "initialization" do

    it "should initialize" do
      expect { Mail::ResentFromField.new("Mikel") }.not_to raise_error
    end

    it "should accept a string without the field name" do
      t = Mail::ResentFromField.new('Mikel Lindsaar <mikel@test.lindsaar.net>, "Bob Smith" <bob@me.com>')
      expect(t.name).to eq 'Resent-From'
      expect(t.value).to eq 'Mikel Lindsaar <mikel@test.lindsaar.net>, "Bob Smith" <bob@me.com>'
    end

  end

  describe "instance methods" do
    it "should return an address" do
      t = Mail::ResentFromField.new('Mikel Lindsaar <mikel@test.lindsaar.net>')
      expect(t.formatted).to eq ['Mikel Lindsaar <mikel@test.lindsaar.net>']
    end

    it "should return two addresses" do
      t = Mail::ResentFromField.new('Mikel Lindsaar <mikel@test.lindsaar.net>, Ada Lindsaar <ada@test.lindsaar.net>')
      expect(t.formatted.first).to eq 'Mikel Lindsaar <mikel@test.lindsaar.net>'
      expect(t.addresses.last).to eq 'ada@test.lindsaar.net'
    end

    it "should return one address and a group" do
      t = Mail::ResentFromField.new('sam@me.com, my_group: mikel@me.com, bob@you.com;')
      expect(t.addresses[0]).to eq 'sam@me.com'
      expect(t.addresses[1]).to eq 'mikel@me.com'
      expect(t.addresses[2]).to eq 'bob@you.com'
    end

    it "should return the formatted line on to_s" do
      t = Mail::ResentFromField.new('sam@me.com, my_group: mikel@me.com, bob@you.com;')
      expect(t.value).to eq 'sam@me.com, my_group: mikel@me.com, bob@you.com;'
    end

    it "should return the encoded line" do
      t = Mail::ResentFromField.new('sam@me.com, my_group: mikel@me.com, bob@you.com;')
      expect(t.encoded).to eq "Resent-From: sam@me.com, \r\n\smy_group: mikel@me.com, \r\n\sbob@you.com;\r\n"
    end

  end


end
