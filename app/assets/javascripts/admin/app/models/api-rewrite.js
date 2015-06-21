import Ember from 'ember';

var ApiRewrite = Ember.Model.extend({
  id: Ember.attr(),
  sortOrder: Ember.attr(Number),
  matcherType: Ember.attr(),
  httpMethod: Ember.attr(),
  frontendMatcher: Ember.attr(),
  backendReplacement: Ember.attr(),
});
ApiRewrite.primaryKey = 'id';
ApiRewrite.camelizeKeys = true;

export default ApiRewrite;
