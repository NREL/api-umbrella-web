import StatsMapRoute from '/api-umbrella-admin/routes/stats-map';

var StatsMapDefaultRoute = StatsMapRoute.extend({
  renderTemplate: function() {
    this.render('stats/map', { controller: 'statsMapDefault' });
  }
});

export default StatsMapDefaultRoute;
