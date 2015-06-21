import AdminGroupsBaseRoute from '/api-umbrella-admin/routes/admin-groups-base';
import AdminGroup from '/api-umbrella-admin/models/admin-group';

var AdminGroupsNewRoute = AdminGroupsBaseRoute.extend({
  model: function() {
    return AdminGroup.create();
  },
});

export default AdminGroupsNewRoute;
