import StatsLogsRoute from '/api-umbrella-admin/routes/stats-logs';

var StatsLogsDefaultRoute = StatsLogsRoute.extend({
  renderTemplate: function() {
    this.render('stats/logs', { controller: 'statsLogsDefault' });
  }
});

export default StatsLogsDefaultRoute;
