import ApiScopesBaseRoute from '/api-umbrella-admin/routes/api-scopes-base';
import ApiScope from '/api-umbrella-admin/models/api-scope';

var ApiScopesEditRoute = ApiScopesBaseRoute.extend({
  model: function(params) {
    // Clear the record cache, so this is always fetched from the server (to
    // account for two users simultaneously editing the same record).
    ApiScope.clearCache();

    return ApiScope.find(params.apiScopeId);
  },
});

export default ApiScopesEditRoute;
