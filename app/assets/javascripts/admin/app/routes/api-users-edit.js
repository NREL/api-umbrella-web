import ApiUsersBaseRoute from '/api-umbrella-admin/routes/api-users-base';
import ApiUser from '/api-umbrella-admin/models/api-user';

var ApiUsersEditRoute = ApiUsersBaseRoute.extend({
  model: function(params) {
    // Clear the record cache, so this is always fetched from the server (to
    // account for two users simultaneously editing the same record).
    ApiUser.clearCache();

    return ApiUser.find(params.apiUserId);
  },
});

export default ApiUsersEditRoute;
