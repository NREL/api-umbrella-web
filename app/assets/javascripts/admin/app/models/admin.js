import Ember from 'ember';
import APIUmbrellaRESTAdapter from '/api-umbrella-admin/adapters/apiumbrella';

var Admin = Ember.Model.extend({
  id: Ember.attr(),
  username: Ember.attr(),
  email: Ember.attr(),
  name: Ember.attr(),
  superuser: Ember.attr(),
  groupIds: Ember.attr(),
  signInCount: Ember.attr(),
  lastSignInAt: Ember.attr(),
  lastSignInIp: Ember.attr(),
  lastSignInProvider: Ember.attr(),
  authenticationToken: Ember.attr(),
  createdAt: Ember.attr(),
  updatedAt: Ember.attr(),
  creator: Ember.attr(),
  updater: Ember.attr(),
});
url = '/api-umbrella/v1/admins';
rootKey = 'admin';
collectionKey = 'data';
primaryKey = 'id';
camelizeKeys = true;
adapter = APIUmbrellaRESTAdapter.create();

export default Admin;
