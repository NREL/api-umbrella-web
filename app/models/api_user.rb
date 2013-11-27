require "attributify_data"

class ApiUser
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Userstamp
  include Mongoid::Delorean::Trackable
  include Mongoid::EmbeddedErrors
  include ApiUmbrella::AttributifyData

  # Fields
  field :_id, type: String, default: lambda { UUIDTools::UUID.random_create.to_s }
  field :api_key
  field :first_name
  field :last_name
  field :email
  field :use_description
  field :throttle_by_ip, :type => Boolean
  field :disabled_at, :type => Time
  field :roles, :type => Array

  # Virtual fields
  attr_accessor :terms_and_conditions, :no_domain_signup

  # Relations
  embeds_one :settings, :class_name => "Api::Settings"

  # Indexes
  index({ :api_key => 1 }, { :unique => true })

  # Validations
  #
  # Provide full sentence validation errors. This doesn't really vibe with how
  # Rails intends to do things by default, but the we're super picky about
  # wording of things on the AFDC site which uses these messages. MongoMapper
  # and ActiveResource combined don't give great flexibility for error message
  # handling, so we're stuck with full sentences and changing how the errors
  # are displayed.
  validates_uniqueness_of :api_key
  validates_presence_of :first_name,
    :message => "Provide your first name."
  validates_presence_of :last_name,
    :message => "Provide your last name."
  validates_presence_of :email,
    :message => "Provide your email address."
  validates_format_of :email,
    :with => /.+@.+\..+/,
    :allow_blank => true,
    :message => "Provide a valid email address."
  validates_acceptance_of :terms_and_conditions,
    :message => "Check the box to agree to the terms and conditions.",
    :on => :create,
    :allow_nil => false

  # Callbacks
  before_validation :generate_api_key, :on => :create

  # Nested attributes
  accepts_nested_attributes_for :settings

  # Mass assignment security
  attr_accessible :first_name,
    :last_name,
    :email,
    :website,
    :use_description,
    :terms_and_conditions,
    :as => [:default, :admin]
  attr_accessible :roles_string,
    :throttle_by_ip,
    :enabled,
    :settings_attributes,
    :as => :admin

  # has_role? simply needs to return true or false whether a user has a role or not.  
  # It may be a good idea to have "admin" roles return true always
  def has_role?(role_in_question)
    if(self.roles.include?("admin"))
      true
    else
      self.roles.include?(role_in_question.to_s)
    end
  end

  def self.human_attribute_name(attribute, options = {})
    case(attribute.to_sym)
    when :email
      "Email"
    when :terms_and_conditions
      "Terms and conditions"
    else
      super
    end
  end

  def self.existing_roles
    existing_roles = ApiUser.distinct(:roles)

    api_roles = Api.all.each do |api|
      if(api.settings && api.settings.required_roles)
        existing_roles += api.settings.required_roles
      end

      if(api.sub_settings)
        api.sub_settings.each do |sub|
          if(sub.settings && sub.settings.required_roles)
            existing_roles += sub.settings.required_roles
          end
        end
      end
    end

    existing_roles.uniq!

    existing_roles
  end

  def as_json(*args)
    hash = super(*args)

    if(!self.valid?)
      hash.merge!(:errors => self.errors.full_messages)
    end

    hash
  end

  def enabled
    self.disabled_at.nil?
  end

  def enabled=(enabled)
    if(enabled.to_s == "false")
      if(self.disabled_at.nil?)
        self.disabled_at = Time.now
      end
    else
      self.disabled_at = nil
    end
  end

  def roles_string
    unless @roles_string
      @roles_string = ""
      if self.roles.present?
        @roles_string = self.roles.join(",")
      end
    end

    @roles_string
  end

  def roles_string=(string)
    @roles_string = string

    roles = nil
    if(string.present?)
      roles = string.split(",").map { |role| role.strip }
    end

    self.roles = roles
  end

  def api_key_preview
    self.api_key.truncate(9)
  end

  def api_key_hides_at
    @api_key_hides_at ||= self.created_at + 10.minutes
  end

  private

  def generate_api_key
    unless self.api_key
      # Generate a key containing A-Z, a-z, and 0-9 that's 40 chars in
      # length.
      key = ""
      while key.length < 40
        key = SecureRandom.base64(50).delete("+/=")[0,40]
      end

      self.api_key = key
    end
  end

  # After the API is saved, clear out any left-over rate_limits for settings
  # where the rate limit mode is no longer "custom."
  #
  # Ideally this would be an after_save callback inside the Settings model, but
  # turning on cascade_callbacks seems to lead to tack level too deep errors.
  def handle_rate_limit_mode
    if(self.settings.present?)
      if(self.settings.rate_limit_mode != "custom")
        self.settings.rate_limits.clear
      end
    end

    true
  end
end
