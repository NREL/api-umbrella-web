import Ember from 'ember';

var ApiUsersBaseRoute = Ember.Route.extend({
  setupController: function(controller, model) {
    controller.set('model', model);

    $('ul.nav li').removeClass('active');
    $('ul.nav li.nav-users').addClass('active');
  },
});

export default ApiUsersBaseRoute;
