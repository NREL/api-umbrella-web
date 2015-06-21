import ApisSortableController from '/api-umbrella-admin/controllers/apis-sortable';

var ApisSubSettingsController = ApisSortableController.extend({
  actions: {
    reorderSubSettings: function() {
      this.reorderCollection('sub_settings');
    },
  },
});

export default ApisSubSettingsController;
