import ApisBaseRoute from '/api-umbrella-admin/routes/apis-base';
import Api from '/api-umbrella-admin/models/api';

var ApisNewRoute = ApisBaseRoute.extend({
  model: function() {
    return Api.create({
      frontendHost: 'api.data.gov',
    });
  },
});

export default ApisNewRoute;
