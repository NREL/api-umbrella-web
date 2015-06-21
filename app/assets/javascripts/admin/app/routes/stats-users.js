import StatsBaseRoute from '/api-umbrella-admin/routes/stats-base';

var StatsUsersRoute = StatsBaseRoute.extend({
  model: function(params) {
    this._super(params);
    return {};
  },

  queryChange: function() {
    var newQueryParams = this.get('query.params');
    if(newQueryParams && !_.isEmpty(newQueryParams)) {
      var activeQueryParams = this.get('activeQueryParams');
      if(!_.isEqual(newQueryParams, activeQueryParams)) {
        this.transitionTo('stats.users', $.param(newQueryParams));
      }
    }
  }.observes('query.params.query', 'query.params.search', 'query.params.start_at', 'query.params.end_at'),
});

export default StatsUsersRoute;
