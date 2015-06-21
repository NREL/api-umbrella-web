import Ember from 'ember';
import Save from '/api-umbrella-admin/save';

var ApiScopesFormController = Ember.ObjectController.extend(Save, {
  actions: {
    submit: function() {
      this.save({
        transitionToRoute: 'api_scopes',
        message: 'Successfully saved the API scope "' + _.escape(this.get('model.name')) + '"',
      });
    },
  },
});

export default ApiScopesFormController;
