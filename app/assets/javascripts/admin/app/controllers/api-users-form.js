import Ember from 'ember';
import Save from '/api-umbrella-admin/save';
import ApiUserRole from '/api-umbrella-admin/models/api-user-role';

var ApiUsersFormController = Ember.ObjectController.extend(Save, {
  throttleByIpOptions: [
    { id: false, name: 'Rate limit by API key' },
    { id: true, name: 'Rate limit by IP address' },
  ],

  enabledOptions: [
    { id: true, name: 'Enabled' },
    { id: false, name: 'Disabled' },
  ],

  roleOptions: function() {
    return ApiUserRole.find();
    // Don't cache this property, so we can rely on refreshing the underlying
    // model to refresh the options.
  }.property().cacheable(false),

  actions: {
    submit: function() {
      this.save({
        transitionToRoute: 'api_users',
        message: function(model) {
          var message = 'Successfully saved the user "' + _.escape(model.get('email')) + '"';
          if(model.get('apiKey')) {
            message += '<br>API Key: <code>' + _.escape(model.get('apiKey')) + '</code>';
          }

          return message;
        },
      });
    },
  },
});

export default ApiUsersFormController;
