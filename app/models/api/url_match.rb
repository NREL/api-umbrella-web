require "common_validations"

class Api::UrlMatch
  include Mongoid::Document

  # Fields
  field :_id, :type => String, :default => lambda { UUIDTools::UUID.random_create.to_s }
  field :frontend_prefix, :type => String
  field :backend_prefix, :type => String
  field :rate_limit_bucket_name, :type => String

  # Relations
  embedded_in :api

  # Validations
  before_validation :clean_fields
  validates :frontend_prefix,
    :presence => true,
    :format => {
      :with => CommonValidations::URL_PREFIX_FORMAT,
      :message => :invalid_url_prefix_format,
    }
  validates :backend_prefix,
    :presence => true,
    :format => {
      :with => CommonValidations::URL_PREFIX_FORMAT,
      :message => :invalid_url_prefix_format,
    }
  validates :rate_limit_bucket_name,
    :length => {
      :maximum => 30
    }

  # Mass assignment security
  attr_accessible :frontend_prefix,
    :backend_prefix,
    :rate_limit_bucket_name,
    :as => [:default, :admin]

  def clean_fields
    if self.rate_limit_bucket_name.blank?
      self.rate_limit_bucket_name = nil
    end
  end
end
