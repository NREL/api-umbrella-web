import Ember from 'ember';
import ApiSettings from '/api-umbrella-admin/models/api-settings';
import ApiUserRole from '/api-umbrella-admin/models/api-user-role';
import APIUmbrellaRESTAdapter from '/api-umbrella-admin/adapters/apiumbrella';

var ApiUser = Ember.Model.extend(Ember.Validations.Mixin, {
  id: Ember.attr(),
  apiKey: Ember.attr(),
  apiKeyHidesAt: Ember.attr(),
  apiKeyPreview: Ember.attr(),
  firstName: Ember.attr(),
  lastName: Ember.attr(),
  email: Ember.attr(),
  emailVerified: Ember.attr(),
  website: Ember.attr(),
  useDescription: Ember.attr(),
  registrationSource: Ember.attr(),
  termsAndConditions: Ember.attr(),
  sendWelcomeEmail: Ember.attr(),
  throttleByIp: Ember.attr(),
  roles: Ember.attr(),
  enabled: Ember.attr(),
  createdAt: Ember.attr(),
  updatedAt: Ember.attr(),
  creator: Ember.attr(),
  updater: Ember.attr(),
  registrationIp: Ember.attr(),
  registrationUserAgent: Ember.attr(),
  registrationReferer: Ember.attr(),
  registrationOrigin: Ember.attr(),

  settings: Ember.belongsTo('ApiSettings', { key: 'settings', embedded: true }),

  validations: {
    firstName: {
      presence: true,
    },
    lastName: {
      presence: true,
    },
    email: {
      presence: true,
    },
  },

  init: function() {
    this._super();

    // Set defaults for new records.
    this.setDefaults();

    // For existing records, we need to set the defaults after loading.
    this.on('didLoad', this, this.setDefaults);
  },

  setDefaults: function() {
    if(this.get('throttleByIp') === undefined) {
      this.set('throttleByIp', false);
    }

    if(this.get('enabled') === undefined) {
      this.set('enabled', true);
    }

    if(!this.get('settings')) {
      this.set('settings', ApiSettings.create());
    }

    if(!this.get('registrationSource') && this.get('isNew')) {
      this.set('registrationSource', 'web_admin');
    }
  },

  rolesString: function(key, value) {
    // Setter
    if(arguments.length > 1) {
      var roles = value.split(',');
      this.set('roles', roles);
    }

    // Getter
    var rolesString = '';
    if(this.get('roles')) {
      rolesString = this.get('roles').join(',');
    }

    return rolesString;
  }.property('roles'),

  didSaveRecord: function() {
    // Clear the cached roles on save, so the list of available roles is always
    // correct for subsequent form renderings in this current session.
    ApiUserRole.clearCache();
  },
});
ApiUser.url = '/api-umbrella/v1/users';
ApiUser.rootKey = 'user';
ApiUser.collectionKey = 'data';
ApiUser.primaryKey = 'id';
ApiUser.camelizeKeys = true;
ApiUser.adapter = APIUmbrellaRESTAdapter.create();

export default ApiUser;
