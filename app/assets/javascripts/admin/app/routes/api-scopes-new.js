import ApiScopesBaseRoute from '/api-umbrella-admin/routes/api-scopes-base';
import ApiScope from '/api-umbrella-admin/models/api-scope';

var ApiScopesNewRoute = ApiScopesBaseRoute.extend({
  model: function() {
    return ApiScope.create();
  },
});

export default ApiScopesNewRoute;
