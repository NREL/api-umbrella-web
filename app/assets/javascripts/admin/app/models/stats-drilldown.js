import Ember from 'ember';

var StatsDrilldown = Ember.Object.extend(Ember.Evented, {
  results: null,
});
StatsDrilldown.reopenClass({
  find: function(params) {
    var promise = Ember.Deferred.create();

    $.ajax({
      url: '/api-umbrella/v1/analytics/drilldown.json',
      data: params,
    }).done(function(data) {
      var map = StatsDrilldown.create(data);
      promise.resolve(map);
    }).fail(function() {
      promise.reject();
    });

    return promise;
  },
});

export default StatsDrilldown;
