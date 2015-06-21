import Ember from 'ember';
import ApiSettings from '/api-umbrella-admin/models/api-settings';

var ApiSubSettings = Ember.Model.extend({
  id: Ember.attr(),
  sortOrder: Ember.attr(Number),
  httpMethod: Ember.attr(),
  regex: Ember.attr(),

  settings: Ember.belongsTo('ApiSettings', { key: 'settings', embedded: true }),

  init: function() {
    this._super();

    // Set defaults for new records.
    this.setDefaults();

    // For existing records, we need to set the defaults after loading.
    this.on('didLoad', this, this.setDefaults);
  },

  setDefaults: function() {
    if(!this.get('settings')) {
      this.set('settings', ApiSettings.create());
    }
  },
});
ApiSubSettings.primaryKey = 'id';
ApiSubSettings.camelizeKeys = true;

export default ApiSubSettings;
