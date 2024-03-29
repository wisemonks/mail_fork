# encoding: utf-8
# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Mail::ResentDateField do
  it "should initialize" do
    expect { Mail::ResentDateField.new("12 Aug 2009 00:00:02 GMT") }.not_to raise_error
  end

  it "should be able to tell the time" do
    expect(Mail::ResentDateField.new("12 Aug 2009 00:00:02 GMT").date_time.class).to eq DateTime
  end

  it "should accept a string without the field name" do
    t = Mail::ResentDateField.new('12 Aug 2009 00:00:02 GMT')
    expect(t.name).to eq 'Resent-Date'
    expect(t.value).to eq 'Wed, 12 Aug 2009 00:00:02 +0000'
    expect(t.date_time).to eq ::DateTime.parse('12 Aug 2009 00:00:02 GMT')
  end

  it "should give today's date if no date is specified" do
    now = DateTime.now
    expect(DateTime).to receive(:now).at_least(:once).and_return(now)
    t = Mail::ResentDateField.new
    expect(t.name).to eq 'Resent-Date'
    expect(t.date_time).to eq ::DateTime.parse(now.to_s)
  end

end
