import Ember from 'ember';

var ConfigPublishRecordView = Ember.View.extend({
  actions: {
    toggleConfigDiff: function(id) {
      $('[data-diff-id=' + id + ']').toggle();
    }
  }
});

export default ConfigPublishRecordView;
