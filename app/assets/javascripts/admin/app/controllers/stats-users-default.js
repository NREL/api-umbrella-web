import StatsUsersController from '/api-umbrella-admin/controllers/stats-users';

var StatsUsersDefaultController = StatsUsersController.extend({
  renderTemplate: function() {
    this.render('stats/users');
  }
});

export default StatsUsersDefaultController;
