import StatsDrilldownController from '/api-umbrella-admin/controllers/stats-drilldown';

var StatsDrilldownDefaultController = StatsDrilldownController.extend({
  renderTemplate: function() {
    this.render('stats/drilldown');
  }
});

export default StatsDrilldownDefaultController;
