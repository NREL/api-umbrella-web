import Ember from 'ember';

var CheckboxListView = Ember.CollectionView.extend({
  itemViewClass: Ember.View.extend({
    checkedValuesBinding: 'parentView.checkedValues',

    template: Ember.Handlebars.compile('<label class="checkbox">{{view CheckboxListItemView checkedValuesBinding=\'view.checkedValues\' contentBinding=\'view.content\'}} {{view.content.name}}</label>')
  }),
});

export default CheckboxListView;
