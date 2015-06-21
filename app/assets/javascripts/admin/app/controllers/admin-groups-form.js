import Ember from 'ember';
import Save from '/api-umbrella-admin/save';
import ApiScope from '/api-umbrella-admin/models/api-scope';
import AdminPermission from '/api-umbrella-admin/models/admin-permission';

var AdminGroupsFormController = Ember.ObjectController.extend(Save, {
  apiScopeOptions: function() {
    return ApiScope.find();
  }.property(),

  permissionOptions: function() {
    return AdminPermission.find();
  }.property(),

  actions: {
    submit: function() {
      this.save({
        transitionToRoute: 'admin_groups',
        message: 'Successfully saved the admin group "' + _.escape(this.get('model.name')) + '"',
      });
    },
  },
});

export default AdminGroupsFormController;
