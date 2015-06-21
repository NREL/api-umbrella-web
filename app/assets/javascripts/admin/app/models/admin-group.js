import Ember from 'ember';
import APIUmbrellaRESTAdapter from '/api-umbrella-admin/adapters/apiumbrella';

var AdminGroup = Ember.Model.extend(Ember.Validations.Mixin, {
  id: Ember.attr(),
  name: Ember.attr(),
  apiScopeIds: Ember.attr(),
  permissionIds: Ember.attr(),
  createdAt: Ember.attr(),
  updatedAt: Ember.attr(),
  creator: Ember.attr(),
  updater: Ember.attr(),

  validations: {
    name: {
      presence: true,
    },
  },
});
AdminGroup.url = '/api-umbrella/v1/admin_groups';
AdminGroup.rootKey = 'admin_group';
AdminGroup.collectionKey = 'data';
AdminGroup.primaryKey = 'id';
AdminGroup.camelizeKeys = true;
AdminGroup.adapter = APIUmbrellaRESTAdapter.create();

export default AdminGroup;
