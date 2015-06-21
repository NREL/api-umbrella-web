import Ember from 'ember';

var ApisIndexController = Ember.ArrayController.extend({
  reorderActive: false,

  actions: {
    toggleReorderApis: function() {
      this.set('reorderActive', !this.get('reorderActive'));
    },
  },
});

export default ApisIndexController;
