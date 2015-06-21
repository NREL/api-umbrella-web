import Ember from 'ember';

var CheckboxListItemView = Ember.Checkbox.extend({
  checked: function() {
    var checkedValues = this.get('checkedValues') || [];
    var value = this.get('content.id');
    return _.contains(checkedValues, value);
  }.property('content', 'checkedValues.@each'),

  click: function() {
    var checkedValues = this.get('checkedValues') || [];
    var value = this.get('content.id');

    if(this.get('checked')) {
      checkedValues.push(value);
    } else {
      checkedValues = _.without(checkedValues, value);
    }

    checkedValues = _.uniq(checkedValues).sort();
    this.set('checkedValues', checkedValues);
  }
});

export default CheckboxListItemView;
