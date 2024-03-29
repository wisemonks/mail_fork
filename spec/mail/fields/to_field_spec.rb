# encoding: utf-8
# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Mail::ToField do
  # 
  #    The "To:" field contains the address(es) of the primary recipient(s)
  #    of the message.

  describe "initialization" do

    it "should initialize" do
      expect { Mail::ToField.new("Mikel") }.not_to raise_error
    end

    it "should accept a string without the field name" do
      t = Mail::ToField.new('Mikel Lindsaar <mikel@test.lindsaar.net>, "Bob Smith" <bob@me.com>')
      expect(t.name).to eq 'To'
      expect(t.value).to eq 'Mikel Lindsaar <mikel@test.lindsaar.net>, "Bob Smith" <bob@me.com>'
    end

  end

  describe "instance methods" do
    it "should return an address" do
      t = Mail::ToField.new('Mikel Lindsaar <mikel@test.lindsaar.net>')
      expect(t.formatted).to eq ['Mikel Lindsaar <mikel@test.lindsaar.net>']
    end

    it "should return two addresses" do
      t = Mail::ToField.new('Mikel Lindsaar <mikel@test.lindsaar.net>, Ada Lindsaar <ada@test.lindsaar.net>')
      expect(t.formatted.first).to eq 'Mikel Lindsaar <mikel@test.lindsaar.net>'
      expect(t.addresses.last).to eq 'ada@test.lindsaar.net'
    end

    it "should return one address and a group" do
      t = Mail::ToField.new('sam@me.com, my_group: mikel@me.com, bob@you.com;')
      expect(t.addresses[0]).to eq 'sam@me.com'
      expect(t.addresses[1]).to eq 'mikel@me.com'
      expect(t.addresses[2]).to eq 'bob@you.com'
    end

    it "should return the formatted line on to_s" do
      t = Mail::ToField.new('sam@me.com, my_group: mikel@me.com, bob@you.com;')
      expect(t.value).to eq 'sam@me.com, my_group: mikel@me.com, bob@you.com;'
    end

    it "should return the encoded line" do
      t = Mail::ToField.new('sam@me.com, my_group: mikel@me.com, bob@you.com;')
      expect(t.encoded).to eq "To: sam@me.com, \r\n\smy_group: mikel@me.com, \r\n\sbob@you.com;\r\n"
    end

    it "should return the decoded line" do
      t = Mail::ToField.new('sam@me.com, my_group: mikel@me.com, bob@you.com;')
      expect(t.decoded).to eq "sam@me.com, my_group: mikel@me.com, bob@you.com;"
    end

    it "should get multiple address out from a group list" do
      t = Mail::ToField.new('sam@me.com, my_group: mikel@me.com, bob@you.com;')
      expect(t.addresses).to eq ["sam@me.com", "mikel@me.com", "bob@you.com"]
    end

    it "should handle commas in the address" do
      t = Mail::ToField.new('"Long, stupid email address" <mikel@test.lindsaar.net>')
      expect(t.addresses).to eq ["mikel@test.lindsaar.net"]
    end

    it "should handle commas in the address for multiple fields" do
      t = Mail::ToField.new('"Long, stupid email address" <mikel@test.lindsaar.net>, "Another, really, really, long, stupid email address" <bob@test.lindsaar.net>')
      expect(t.addresses).to eq ["mikel@test.lindsaar.net", "bob@test.lindsaar.net"]
    end

  end


  describe "unicode address" do
    it "should allow unicode local part jp" do
      t = Mail::ToField.new('Mikel Lindsár <マイケル@test.lindsaar.net>')
      expect(t.encoded).to eq "To: =?UTF-8?B?TWlrZWwgTGluZHPDoXI=?= <=?UTF-8?B?44Oe44Kk44Kx44Or?=@test.lindsaar.net>\r\n"
      expect(t.display_names).to eq ['Mikel Lindsár']
      expect(t.addresses).to eq ['マイケル@test.lindsaar.net']
      expect(t.addrs.first.local).to eq 'マイケル'
    end

    it "should allow unicode local" do
      t = Mail::ToField.new('"Mikel Lindsár" <lindsär@test.com>')
      expect(t.encoded).to eq "To: =?UTF-8?B?TWlrZWwgTGluZHPDoXI=?= <=?UTF-8?B?bGluZHPDpHI=?=@test.com>\r\n"
      expect(t.display_names).to eq ['Mikel Lindsár']
      expect(t.addrs.first.address).to eq 'lindsär@test.com'
    end

    it "should allow unicode local (simple)" do
      t = Mail::ToField.new('ölsen@ms.com')
      expect(t.encoded).to eq "To: =?UTF-8?B?w7Zsc2Vu?=@ms.com\r\n"
    end

    it "should allow unicode local (complex)" do
      t = Mail::ToField.new('<"mik@test.<æ>"@ms.com>')
      expect(t.encoded).to eq "To: =?UTF-8?B?Im1pa0B0ZXN0LjzDpj4i?=@ms.com\r\n"
      expect(t.addrs.first.local).to eq '"mik@test.<æ>"'
    end

    it "should allow emoji local" do
      t = Mail::ToField.new(', 😍@me.eu')
      expect(t.encoded).to eq "To: =?UTF-8?B?8J+YjQ==?=@me.eu\r\n"
    end
  end

  it "should not crash if it can't understand a name" do
    t = Mail.new('To: <"Undisclosed-Recipient:"@msr19.hinet.net;>')
    expect { t.encoded }.not_to raise_error
    expect(t.encoded).to match(/To\:\s<"Undisclosed\-Recipient\:"@msr19\.hinet\.net;>\r\n/)
  end

end
