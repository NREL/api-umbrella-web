import StatsBaseRoute from '/api-umbrella-admin/routes/stats-base';
import StatsMap from '/api-umbrella-admin/models/stats-map';

var StatsMapRoute = StatsBaseRoute.extend({
  init: function() {
    _.defaults(this.defaultQueryParams, {
      region: 'world',
    });
  },

  model: function(params) {
    this._super(params);
    return StatsMap.find(this.get('query.params'));
  },

  queryChange: function() {
    var newQueryParams = this.get('query.params');
    if(newQueryParams && !_.isEmpty(newQueryParams)) {
      var activeQueryParams = this.get('activeQueryParams');
      if(!_.isEqual(newQueryParams, activeQueryParams)) {
        this.transitionTo('stats.map', $.param(newQueryParams));
      }
    }
  }.observes('query.params.query', 'query.params.search', 'query.params.start_at', 'query.params.end_at', 'query.params.region'),
});

export default StatsMapRoute;
