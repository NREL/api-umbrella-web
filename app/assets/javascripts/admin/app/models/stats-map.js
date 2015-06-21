import Ember from 'ember';

var StatsMap = Ember.Object.extend(Ember.Evented, {
  regions: null,
  map_regions: null,
});
StatsMap.reopenClass({
  find: function(params) {
    var promise = Ember.Deferred.create();

    $.ajax({
      url: '/admin/stats/map.json',
      data: params,
    }).done(function(data) {
      var map = StatsMap.create(data);
      promise.resolve(map);
    }).fail(function() {
      promise.reject();
    });

    return promise;
  },
});

export default StatsMap;
