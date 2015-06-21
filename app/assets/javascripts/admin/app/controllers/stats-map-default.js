import StatsMapController from '/api-umbrella-admin/controllers/stats-map';

var StatsMapDefaultController = StatsMapController.extend({
  renderTemplate: function() {
    this.render('stats/users');
  }
});

export default StatsMapDefaultController;
