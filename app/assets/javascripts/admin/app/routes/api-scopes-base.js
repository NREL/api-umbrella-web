import Ember from 'ember';

var ApiScopesBaseRoute = Ember.Route.extend({
  setupController: function(controller, model) {
    controller.set('model', model);

    $('ul.nav li').removeClass('active');
    $('ul.nav li.nav-users').addClass('active');
  },
});

export default ApiScopesBaseRoute;
