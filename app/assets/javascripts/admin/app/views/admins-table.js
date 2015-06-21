import Ember from 'ember';
import DataTablesHelpers from '/api-umbrella-admin/data-tables-helpers';

var AdminsTableView = Ember.View.extend({
  tagName: 'table',

  classNames: ['table', 'table-striped', 'table-bordered', 'table-condensed'],

  didInsertElement: function() {
    var dataTable = this.$().DataTable({
      serverSide: true,
      ajax: '/api-umbrella/v1/admins.json',
      pageLength: 50,
      order: [[0, 'asc']],
      columns: [
        {
          data: 'username',
          name: 'Username',
          title: 'Username',
          defaultContent: '-',
          render: _.bind(function(email, type, data) {
            if(type === 'display' && email && email !== '-') {
              var link = '#/admins/' + data.id + '/edit';
              return '<a href="' + link + '">' + _.escape(email) + '</a>';
            }

            return email;
          }, this),
        },
        {
          data: 'email',
          name: 'E-mail',
          title: 'E-mail',
          defaultContent: '-',
          render: DataTablesHelpers.renderEscaped,
        },
        {
          data: 'name',
          name: 'Name',
          title: 'Name',
          defaultContent: '-',
          render: DataTablesHelpers.renderEscaped,
        },
        {
          data: 'group_names',
          name: 'Groups',
          title: 'Groups',
          render: DataTablesHelpers.renderListEscaped,
        },
        {
          data: 'last_sign_in_at',
          type: 'date',
          name: 'Last Signed In',
          title: 'Last Signed In',
          defaultContent: '-',
          render: DataTablesHelpers.renderTime,
        },
        {
          data: 'created_at',
          type: 'date',
          name: 'Created',
          title: 'Created',
          defaultContent: '-',
          render: DataTablesHelpers.renderTime,
        }
      ]
    });
    dataTable.on('draw.dt', function() {
      this.get('controller').send('paramsChange', dataTable.ajax.params());
    }.bind(this));
  },
});

export default AdminsTableView;
