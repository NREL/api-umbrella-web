import StatsDrilldownRoute from '/api-umbrella-admin/routes/stats-drilldown';

var StatsDrilldownDefaultRoute = StatsDrilldownRoute.extend({
  renderTemplate: function() {
    this.render('stats/drilldown', { controller: 'statsDrilldownDefault' });
  }
});

export default StatsDrilldownDefaultRoute;
