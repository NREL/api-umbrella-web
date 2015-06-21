import Ember from 'ember';
import APIUmbrellaRESTAdapter from '/api-umbrella-admin/adapters/apiumbrella';

var WebsiteBackend = Ember.Model.extend(Ember.Validations.Mixin, {
  id: Ember.attr(),
  frontendHost: Ember.attr(),
  backendProtocol: Ember.attr(),
  serverHost: Ember.attr(),
  serverPort: Ember.attr(Number),

  validations: {
    frontendHost: {
      presence: true,
      format: {
        with: CommonValidations.host_format_with_wildcard,
        message: polyglot.t('errors.messages.invalid_host_format'),
      },
    },
    backendProtocol: {
      presence: true,
    },
    serverHost: {
      presence: true,
      format: {
        with: CommonValidations.host_format_with_wildcard,
        message: polyglot.t('errors.messages.invalid_host_format'),
      },
    },
    serverPort: {
      presence: true,
      numericality: true,
    },
  },
});
WebsiteBackend.url = '/api-umbrella/v1/website_backends';
WebsiteBackend.rootKey = 'website_backend';
WebsiteBackend.collectionKey = 'data';
WebsiteBackend.primaryKey = 'id';
WebsiteBackend.camelizeKeys = true;
WebsiteBackend.adapter = APIUmbrellaRESTAdapter.create();

export default WebsiteBackend;
