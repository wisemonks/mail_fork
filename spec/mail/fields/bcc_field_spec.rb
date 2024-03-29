# encoding: utf-8
# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Mail::BccField do
  
  #    The "Bcc:" field (where the "Bcc" means "Blind Carbon Copy") contains
  #    addresses of recipients of the message whose addresses are not to be
  #    revealed to other recipients of the message.  There are three ways in
  #    which the "Bcc:" field is used.  In the first case, when a message
  #    containing a "Bcc:" field is prepared to be sent, the "Bcc:" line is
  #    removed even though all of the recipients (including those specified
  #    in the "Bcc:" field) are sent a copy of the message.  In the second
  #    case, recipients specified in the "To:" and "Cc:" lines each are sent
  #    a copy of the message with the "Bcc:" line removed as above, but the
  #    recipients on the "Bcc:" line get a separate copy of the message
  #    containing a "Bcc:" line.  (When there are multiple recipient
  #    addresses in the "Bcc:" field, some implementations actually send a
  #    separate copy of the message to each recipient with a "Bcc:"
  #    containing only the address of that particular recipient.) Finally,
  #    since a "Bcc:" field may contain no addresses, a "Bcc:" field can be
  #    sent without any addresses indicating to the recipients that blind
  #    copies were sent to someone.  Which method to use with "Bcc:" fields
  #    is implementation dependent, but refer to the "Security
  #    Considerations" section of this document for a discussion of each.

  describe "initialization" do

    it "should initialize" do
      expect { Mail::BccField.new("Mikel") }.not_to raise_error
    end

    it "should accept a string without the field name" do
      t = Mail::BccField.new('Mikel Lindsaar <mikel@test.lindsaar.net>, "Bob Smith" <bob@me.com>')
      expect(t.name).to eq 'Bcc'
      expect(t.value).to eq 'Mikel Lindsaar <mikel@test.lindsaar.net>, "Bob Smith" <bob@me.com>'
    end

  end

  describe "instance methods" do
    it "should return an address" do
      t = Mail::BccField.new('Mikel Lindsaar <mikel@test.lindsaar.net>')
      expect(t.formatted).to eq ['Mikel Lindsaar <mikel@test.lindsaar.net>']
    end

    it "should return two addresses" do
      t = Mail::BccField.new('Mikel Lindsaar <mikel@test.lindsaar.net>, Ada Lindsaar <ada@test.lindsaar.net>')
      expect(t.formatted.first).to eq 'Mikel Lindsaar <mikel@test.lindsaar.net>'
      expect(t.addresses.last).to eq 'ada@test.lindsaar.net'
    end

    it "should return one address and a group" do
      t = Mail::BccField.new('sam@me.com, my_group: mikel@me.com, bob@you.com;')
      expect(t.addresses[0]).to eq 'sam@me.com'
      expect(t.addresses[1]).to eq 'mikel@me.com'
      expect(t.addresses[2]).to eq 'bob@you.com'
    end

    it "should return the formatted line on to_s" do
      t = Mail::BccField.new('sam@me.com, my_group: mikel@me.com, bob@you.com;')
      expect(t.value).to eq 'sam@me.com, my_group: mikel@me.com, bob@you.com;'
    end

    it "should return nothing by default on encoded as Bcc should not be in the mail" do
      t = Mail::BccField.new('sam@me.com, my_group: mikel@me.com, bob@you.com;')
      expect(t.encoded).to eq ""
    end

    it "should return the encoded line for one address when requested to include in headers" do
      t = Mail::BccField.new('sam@me.com')
      t.include_in_headers = true
      expect(t.encoded).to eq "Bcc: sam@me.com\r\n"
    end

    it "should return the encoded line when requested to include in headers" do
      t = Mail::BccField.new('sam@me.com, my_group: mikel@me.com, bob@you.com;')
      t.include_in_headers = true
      expect(t.encoded).to eq "Bcc: sam@me.com, \r\n\smy_group: mikel@me.com, \r\n\sbob@you.com;\r\n"
    end

    it "should return the decoded line" do
      t = Mail::BccField.new('sam@me.com, my_group: mikel@me.com, bob@you.com;')
      expect(t.decoded).to eq "sam@me.com, my_group: mikel@me.com, bob@you.com;"
    end

  end


end
