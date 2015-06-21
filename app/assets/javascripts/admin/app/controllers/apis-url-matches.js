import ApisSortableController from '/api-umbrella-admin/controllers/apis-sortable';

var ApisUrlMatchesController = ApisSortableController.extend({
  actions: {
    reorderUrlMatches: function() {
      this.reorderCollection('url_matches');
    },
  },
});

export default ApisUrlMatchesController;
