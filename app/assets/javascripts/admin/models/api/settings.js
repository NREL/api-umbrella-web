Admin.ApiSettings = Ember.Model.extend({
  _id: Ember.attr(),
  appendQueryString: Ember.attr(),
  headersString: Ember.attr(),
  httpBasicAuth: Ember.attr(),
  requireHttps: Ember.attr(),
  disableApiKey: Ember.attr(),
  requiredRoles: Ember.attr(),
  hourlyRateLimit: Ember.attr(),

  headers: function(key, value) {
    console.info("HEADER: %o", arguments);
  }.property('headersString'),
});

Admin.ApiSettings.primaryKey = "_id";
Admin.ApiSettings.camelizeKeys = true;
