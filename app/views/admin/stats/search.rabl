object false

extends "admin/stats/_interval_hits"

node :totals do
  {
    :hits => @result.total,
    :users => @result.facets[:user_email].terms.length + @result.facets[:user_email][:other],
    :ips => @result.facets[:request_ip].terms.length + @result.facets[:request_ip][:other],
  }
end

node :facets do
  {
    :users => facet_result(:user_email),
    :ips => facet_result(:request_ip),
    :content_types => facet_result(:response_content_type),
  }
end

node :logs do
  @result.results.map do |log|
    log.except(:api_key, :_type, :_score, :_index)
  end
end
