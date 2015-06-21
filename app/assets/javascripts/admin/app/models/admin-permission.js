import Ember from 'ember';
import APIUmbrellaRESTAdapter from '/api-umbrella-admin/adapters/apiumbrella';

var AdminPermission = Ember.Model.extend({
  id: Ember.attr(),
  name: Ember.attr()
});
AdminPermission.url = '/api-umbrella/v1/admin_permissions';
AdminPermission.rootKey = 'admin_permission';
AdminPermission.collectionKey = 'admin_permissions';
AdminPermission.primaryKey = 'id';
AdminPermission.camelizeKeys = true;
AdminPermission.adapter = APIUmbrellaRESTAdapter.create();

export default AdminPermission;
