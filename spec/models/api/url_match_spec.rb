require 'spec_helper'

describe Api::UrlMatch do
  it 'nils-out bucket name if it is blank' do
    match = FactoryGirl.build(:api_url_match)
    expect(match.rate_limit_bucket_name).to be_nil
    match.rate_limit_bucket_name = ""
    match.valid?
    expect(match.rate_limit_bucket_name).to be_nil
    match.rate_limit_bucket_name = "      "
    match.valid?
    expect(match.rate_limit_bucket_name).to be_nil
  end
end
