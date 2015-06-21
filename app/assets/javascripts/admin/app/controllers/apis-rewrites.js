import ApisSortableController from '/api-umbrella-admin/controllers/apis-sortable';

var ApisRewritesController = ApisSortableController.extend({
  actions: {
    reorderRewrites: function() {
      this.reorderCollection('rewrites');
    },
  },
});

export default ApisRewritesController;
