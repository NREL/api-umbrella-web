import Ember from 'ember';
import APIUmbrellaRESTAdapter from '/api-umbrella-admin/adapters/apiumbrella';

var ApiUserRole = Ember.Model.extend({
  id: Ember.attr(),
});
ApiUserRole.url = '/api-umbrella/v1/user_roles';
ApiUserRole.rootKey = 'user_roles';
ApiUserRole.collectionKey = 'user_roles';
ApiUserRole.primaryKey = 'id';
ApiUserRole.camelizeKeys = true;
ApiUserRole.adapter = APIUmbrellaRESTAdapter.create();

export default ApiUserRole;
