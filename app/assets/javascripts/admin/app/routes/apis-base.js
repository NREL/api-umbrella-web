import Ember from 'ember';

var ApisBaseRoute = Ember.Route.extend({
  setupController: function(controller, model) {
    controller.set('model', model);

    $('ul.nav li').removeClass('active');
    $('ul.nav li.nav-config').addClass('active');
  },
});

export default ApisBaseRoute;
