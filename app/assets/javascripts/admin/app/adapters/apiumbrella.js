import Ember from 'ember';

var APIUmbrellaRESTAdapter = Ember.RESTAdapter.extend({
  ajaxSettings: function(url, method) {
    return {
      url: url,
      type: method,
      dataType: 'json',
      headers: {
        'X-Api-Key': webAdminAjaxApiKey
      }
    };
  }
});

export default APIUmbrellaRESTAdapter;
