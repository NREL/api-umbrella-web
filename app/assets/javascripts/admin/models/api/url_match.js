Admin.ApiUrlMatch = Ember.Model.extend(Ember.Validations.Mixin,{
  id: Ember.attr(),
  sortOrder: Ember.attr(Number),
  frontendPrefix: Ember.attr(),
  backendPrefix: Ember.attr(),
  rateLimitBucketName: Ember.attr(),

  validations: {
    frontendPrefix: {
      presence: true,
      format: {
        with: CommonValidations.url_prefix_format,
        message: polyglot.t('errors.messages.invalid_url_prefix_format'),
      },
    },
    backendPrefix: {
      presence: true,
      format: {
        with: CommonValidations.url_prefix_format,
        message: polyglot.t('errors.messages.invalid_url_prefix_format'),
      },
    },
    rateLimitBucketName: {
      length: { maximum: 30 }
    },
  },

  backendPrefixWithDefault: function() {
    return this.get('backendPrefix') || this.get('frontendPrefix');
  }.property('backendPrefix', 'frontendPrefix'),
});

Admin.ApiUrlMatch.primaryKey = 'id';
Admin.ApiUrlMatch.camelizeKeys = true;
