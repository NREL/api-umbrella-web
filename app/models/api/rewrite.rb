class Api::Rewrite
  include Mongoid::Document

  # Fields
  field :matcher_type, :type => String
  field :http_method, :type => String
  field :frontend_matcher, :type => String
  field :backend_replacement, :type => String

  # Relations
  embedded_in :api

  # Validations
  validates :matcher_type,
    :inclusion => { :in => %w(route regex) }
  validates :http_method,
    :inclusion => { :in => %w(any GET POST PUT DELETE HEAD TRACE OPTIONS CONNECT PATCH) }

  # Mass assignment security
  attr_accessible :_id,
    :matcher_type,
    :http_method,
    :frontend_matcher,
    :backend_replacement
end
