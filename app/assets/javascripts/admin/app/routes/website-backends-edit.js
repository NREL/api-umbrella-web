import WebsiteBackendsBaseRoute from '/api-umbrella-admin/routes/website-backends-base';
import WebsiteBackend from '/api-umbrella-admin/models/website-backend';

var WebsiteBackendsEditRoute = WebsiteBackendsBaseRoute.extend({
  model: function(params) {
    // Clear the record cache, so this is always fetched from the server (to
    // account for two users simultaneously editing the same record).
    WebsiteBackend.clearCache();

    return WebsiteBackend.find(params.websiteBackendId);
  },
});

export default WebsiteBackendsEditRoute;
