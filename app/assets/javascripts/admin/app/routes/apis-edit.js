import ApisBaseRoute from '/api-umbrella-admin/routes/apis-base';
import Api from '/api-umbrella-admin/models/api';

var ApisEditRoute = ApisBaseRoute.extend({
  model: function(params) {
    // Clear the record cache, so this is always fetched from the server (to
    // account for two users simultaneously editing the same record).
    Api.clearCache();

    return Api.find(params.apiId);
  },
});

export default ApisEditRoute;
