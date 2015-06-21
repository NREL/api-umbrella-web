import WebsiteBackendsBaseRoute from '/api-umbrella-admin/routes/website-backends-base';
import WebsiteBackend from '/api-umbrella-admin/models/website-backend';

var WebsiteBackendsNewRoute = WebsiteBackendsBaseRoute.extend({
  model: function() {
    return WebsiteBackend.create({
      serverPort: 80,
    });
  },
});

export default WebsiteBackendsNewRoute;
