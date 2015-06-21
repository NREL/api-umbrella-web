import Ember from 'ember';

var HideModalView = Ember.View.extend({
  render: function() {
  },

  didInsertElement: function() {
    $('.modal').modal('hide');
  }
});

export default HideModalView;
