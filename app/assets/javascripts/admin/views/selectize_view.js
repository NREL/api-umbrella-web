Admin.SelectizeView = Ember.View.extend({
  didInsertElement: function() {
    this.$().find('input,select').selectize({
      plugins: ['restore_on_backspace', 'remove_button'],
      delimiter: ',',
      options: apiUserExistingRoles,
      valueField: 'id',
      labelField: 'title',
      searchField: 'title',
      sortField: 'title',
      create: true,

      // Add to body so it doesn't get clipped by parent div containers.
      dropdownParent: 'body',
    });
  }
});
