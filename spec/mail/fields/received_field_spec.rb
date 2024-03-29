# encoding: utf-8
# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Mail::ReceivedField do

  it "should initialize" do
    expect { Mail::ReceivedField.new("from localhost (localhost [127.0.0.1]) by xxx.xxxxx.com (Postfix) with ESMTP id 50FD3A96F for <xxxx@xxxx.com>; Tue, 10 May 2005 17:26:50 +0000 (GMT)") }.not_to raise_error
  end

  it "should be able to tell the time" do
    expect(Mail::ReceivedField.new("from localhost (localhost [127.0.0.1]) by xxx.xxxxx.com (Postfix) with ESMTP id 50FD3A96F for <xxxx@xxxx.com>; Tue, 10 May 2005 17:26:50 +0000 (GMT)").date_time.class).to eq DateTime
  end

  it "should accept a string without the field name" do
    t = Mail::ReceivedField.new('from localhost (localhost [127.0.0.1]) by xxx.xxxxx.com (Postfix) with ESMTP id 50FD3A96F for <xxxx@xxxx.com>; Tue, 10 May 2005 17:26:50 +0000 (GMT)')
    expect(t.name).to eq 'Received'
    expect(t.value).to eq 'from localhost (localhost [127.0.0.1]) by xxx.xxxxx.com (Postfix) with ESMTP id 50FD3A96F for <xxxx@xxxx.com>; Tue, 10 May 2005 17:26:50 +0000 (GMT)'
    expect(t.info).to eq 'from localhost (localhost [127.0.0.1]) by xxx.xxxxx.com (Postfix) with ESMTP id 50FD3A96F for <xxxx@xxxx.com>'
    expect(t.date_time).to eq ::DateTime.parse('10 May 2005 17:26:50 +0000 (GMT)')
  end

  it "should provide an encoded value" do
    t = Mail::ReceivedField.new('from localhost (localhost [127.0.0.1]) by xxx.xxxxx.com (Postfix) with ESMTP id 50FD3A96F for <xxxx@xxxx.com>; Tue, 10 May 2005 17:26:50 +0000 (GMT)')
    expect(t.encoded).to eq "Received: from localhost (localhost [127.0.0.1]) by xxx.xxxxx.com (Postfix) with ESMTP id 50FD3A96F for <xxxx@xxxx.com>; Tue, 10 May 2005 17:26:50 +0000\r\n"
  end

  it "should provide an encoded value with correct timezone" do
    t = Mail::ReceivedField.new('from localhost (localhost [127.0.0.1]) by xxx.xxxxx.com (Postfix) with ESMTP id 50FD3A96F for <xxxx@xxxx.com>; Tue, 10 May 2005 17:26:50 -0500 (EST)')
    expect(t.encoded).to eq "Received: from localhost (localhost [127.0.0.1]) by xxx.xxxxx.com (Postfix) with ESMTP id 50FD3A96F for <xxxx@xxxx.com>; Tue, 10 May 2005 17:26:50 -0500\r\n"
  end

  it "should provide an decoded value" do
    t = Mail::ReceivedField.new('from localhost (localhost [127.0.0.1]) by xxx.xxxxx.com (Postfix) with ESMTP id 50FD3A96F for <xxxx@xxxx.com>; Tue, 10 May 2005 17:26:50 +0000 (GMT)')
    expect(t.decoded).to eq 'from localhost (localhost [127.0.0.1]) by xxx.xxxxx.com (Postfix) with ESMTP id 50FD3A96F for <xxxx@xxxx.com>; Tue, 10 May 2005 17:26:50 +0000'
  end

  it "should handle empty name-value lists with a comment only (qmail style)" do
    t = Mail::ReceivedField.new('(qmail 24365 invoked by uid 99); 25 Jan 2011 12:31:11 -0000')
    expect(t.info).to eq '(qmail 24365 invoked by uid 99)'
  end

  it "should handle a blank value" do
    t = Mail::ReceivedField.new('')
    expect(t.decoded).to eq ''
    expect(t.encoded).to eq "Received: \r\n"
  end

  it "should handle invalid date" do
    t = Mail::ReceivedField.new("mail.example.com (192.168.1.1) by mail.example.com with (esmtp) id (qid)  for <foo@example.com>; Mon, 29 Jul 2013 25:12:46 +0900")

    expect(t.name).to eq "Received"
    expect(t.value).to eq "mail.example.com (192.168.1.1) by mail.example.com with (esmtp) id (qid)  for <foo@example.com>; Mon, 29 Jul 2013 25:12:46 +0900"
    expect(t.info).to eq "mail.example.com (192.168.1.1) by mail.example.com with (esmtp) id (qid)  for <foo@example.com>"
    expect(t.date_time).to eq nil
    expect(t.formatted_date).to eq nil
  end
end
