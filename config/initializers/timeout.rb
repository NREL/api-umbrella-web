if(Rails.env.development?)
  Rack::Timeout.timeout = 60 # seconds
else
  Rack::Timeout.timeout = 55 # seconds
end
