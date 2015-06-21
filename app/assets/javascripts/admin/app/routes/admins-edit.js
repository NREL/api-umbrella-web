import AdminsBaseRoute from '/api-umbrella-admin/routes/admins-base';
import Admin from '/api-umbrella-admin/models/admin';

var AdminsEditRoute = AdminsBaseRoute.extend({
  model: function(params) {
    // Clear the record cache, so this is always fetched from the server (to
    // account for two users simultaneously editing the same record).
    clearCache();

    return find(params.adminId);
  },
});

export default AdminsEditRoute;
