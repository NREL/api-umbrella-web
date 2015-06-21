import AdminsBaseRoute from '/api-umbrella-admin/routes/admins-base';
import Admin from '/api-umbrella-admin/models/admin';

var AdminsNewRoute = AdminsBaseRoute.extend({
  model: function() {
    return create();
  },
});

export default AdminsNewRoute;
