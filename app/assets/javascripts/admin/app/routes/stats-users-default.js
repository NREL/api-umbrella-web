import StatsUsersRoute from '/api-umbrella-admin/routes/stats-users';

var StatsUsersDefaultRoute = StatsUsersRoute.extend({
  renderTemplate: function() {
    this.render('stats/users', { controller: 'statsUsersDefault' });
  }
});

export default StatsUsersDefaultRoute;
