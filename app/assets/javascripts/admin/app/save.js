import Ember from 'ember';

// A mixin that provides the default ajax save behavior for our forms.
var Save = Ember.Mixin.create({
  save: function(options) {
    var button = $('#save_button');
    button.button('loading');

    // Force dirty to force save (ember-model's dirty tracking fails to
    // account for changes in nested, non-association objects:
    // http://git.io/sbS1mg This is mainly for ApiSettings's errorTemplates
    // and errorDataYamlStrings, but we've seen enough funkiness elsewhere,
    // it seems worth disabling for now).
    this.set('model.isDirty', true);

    this.get('model').save().then(_.bind(function() {
      button.button('reset');
      new PNotify({
        type: 'success',
        title: 'Saved',
        text: (_.isFunction(options.message)) ? options.message(this.get('model')) : options.message,
      });

      this.transitionToRoute(options.transitionToRoute);
    }, this), _.bind(function(response) {
      // Set the errors from the server response on a "serverErrors" property
      // for the error-messages component display.
      try {
        this.set('model.serverErrors', response.responseJSON.errors);
      } catch(e) {
        this.set('model.serverErrors', response.responseText);
      }

      button.button('reset');
      $.scrollTo('#error_messages', { offset: -50, duration: 200 });
    }, this));
  },
});

export default Save;
