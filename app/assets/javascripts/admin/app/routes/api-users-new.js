import ApiUsersBaseRoute from '/api-umbrella-admin/routes/api-users-base';
import ApiUser from '/api-umbrella-admin/models/api-user';

var ApiUsersNewRoute = ApiUsersBaseRoute.extend({
  model: function() {
    return ApiUser.create();
  },
});

export default ApiUsersNewRoute;
