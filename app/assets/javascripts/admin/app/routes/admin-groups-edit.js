import AdminGroupsBaseRoute from '/api-umbrella-admin/routes/admin-groups-base';
import AdminGroup from '/api-umbrella-admin/models/admin-group';

var AdminGroupsEditRoute = AdminGroupsBaseRoute.extend({
  model: function(params) {
    // Clear the record cache, so this is always fetched from the server (to
    // account for two users simultaneously editing the same record).
    AdminGroup.clearCache();

    return AdminGroup.find(params.adminGroupId);
  },
});

export default AdminGroupsEditRoute;
