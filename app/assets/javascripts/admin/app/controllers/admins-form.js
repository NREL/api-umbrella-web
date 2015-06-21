import Ember from 'ember';
import Save from '/api-umbrella-admin/save';
import AdminGroup from '/api-umbrella-admin/models/admin-group';

var AdminsFormController = Ember.ObjectController.extend(Save, {
  groupOptions: function() {
    return AdminGroup.find();
  }.property(),

  currentAdmin: function() {
    return currentAdmin;
  }.property(),

  actions: {
    submit: function() {
      this.save({
        transitionToRoute: 'admins',
        message: 'Successfully saved the admin "' + _.escape(this.get('model.username')) + '"',
      });
    },
  },
});

export default AdminsFormController;
