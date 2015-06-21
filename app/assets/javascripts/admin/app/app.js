import Ember from 'ember';

var Admin = Ember.Application.create({
  LOG_TRANSITIONS: true,
  LOG_TRANSITIONS_INTERNAL: true,

  rootElement: '#content'
});
//= require_self
//= require ./common_validations
//= require_tree ./models
//= require ./controllers/apis/nested_form_controller
//= require ./controllers/apis/sortable_controller
//= require_tree ./components
//= require_tree ./controllers
//= require_tree ./views
//= require_tree ./helpers
//= require_tree ./templates
//= require ./router
//= require_tree ./routes

//Ember.LOG_BINDINGS = true

// Set Bootbox defaults.
bootbox.animate(false);
// PNotify Defaults.
_.merge(PNotify.prototype.options, {
  styling: 'bootstrap2',
  width: '400px',
  icon: false,
  animate_speed: 'fast',
  history: {
    history: false
  },
  buttons: {
    sticker: false
  }
});
(function() {
  var versionParts = Ember.VERSION.split('.');
  var major = parseInt(versionParts[0], 10);
  var minor = parseInt(versionParts[1], 10);
  var patch = parseInt(versionParts[2], 10);
  if(major > 1 || (major === 1 && (minor > 1 || patch > 2))) {
    Ember.Logger.warn('WARNING: New Ember version detected. URL hash monkey patch possibly no longer needed or broken. Check for compatibility.');
  }

  var get = Ember.get, set = Ember.set;

  // Fix URL hash parsing across browsers. Because we're putting query
  // parameters in the URL, we expect special characters which escape
  // differently across browsers with location.hash. So this is a monkey patch
  // to use location.href instead.
  // https://github.com/emberjs/ember.js/issues/3000
  // https://github.com/emberjs/ember.js/issues/3263
  //
  // All of this should be revisited once query-params lands, since this will
  // probably clean this up: https://github.com/emberjs/ember.js/pull/3182
  Ember.HashLocation.reopen({
    getURL: function() {
      var href = get(this, 'location').href;

      var hashIndex = href.indexOf('#');
      if (hashIndex === -1) {
        return '';
      } else {
        return href.substr(hashIndex + 1);
      }
    },

    onUpdateURL: function(callback) {
      var self = this;
      var guid = Ember.guidFor(this);

      Ember.$(window).on('hashchange.ember-location-'+guid, function() {
        Ember.run(function() {
          var path = self.getURL();
          if (get(self, 'lastSetURL') === path) { return; }

          set(self, 'lastSetURL', null);

          callback(path);
        });
      });
    },
  });
})();
function eachTranslatedAttribute(object, fn) {
  var isTranslatedAttribute = /(.+)Translation$/,
      isTranslatedAttributeMatch;

  for (var key in object) {
    isTranslatedAttributeMatch = key.match(isTranslatedAttribute);
    if (isTranslatedAttributeMatch) {
      var translation = (!object[key]) ? null : polyglot.t(object[key]);
      fn.call(object, isTranslatedAttributeMatch[1], translation);
    }
  }
}
// Override existing Ember.EasyForm.processOptions to use our polyglot
// translations instead of Ember.i18n for the special *Translation fields.
//
// We could also potentially use subexpressions to call polyglot directly in
// the templates, but at least as of Ember 1.7, there are bugs with multiple
// subexpressions: https://github.com/wycats/handlebars.js/issues/748
// Perhaps revisit when we upgrade Ember.
Ember.EasyForm.processOptions = function(property, options) {
  if(options) {
    if(polyglot) {
      eachTranslatedAttribute(options.hash, function(attribute, translation) {
        options.hash[attribute] = translation;
        delete options.hash[attribute + 'Translation'];
      });
    }
    options.hash.property = property;
  } else {
    options = property;
  }

  return options;
};
Ember.EasyForm.Tooltip = Ember.EasyForm.BaseView.extend({
  tagName: 'a',
  attributeBindings: ['title', 'rel', 'data-tooltip-class'],
  template: Ember.Handlebars.compile('<i class="fa fa-question-circle"></i>'),
  rel: 'tooltip',
});
Ember.Handlebars.registerBoundHelper('formatDate', function(date, format) {
  if(!format || !_.isString(format)) {
    format = 'YYYY-MM-DD HH:mm Z';
  }

  if(date) {
    return moment(date).format(format);
  } else {
    return '';
  }
});
Ember.Handlebars.helper('formatNumber', function(number) {
  return numeral(number).format('0,0');
});
Ember.Handlebars.helper('inflect', function(word, number) {
  return inflection.inflect(word, number);
});
// i18n helper via polyglot library
Ember.Handlebars.registerHelper('t', function(property, options) {
  return polyglot.t(property, options.hash);
});
Ember.Handlebars.registerHelper('tooltip-field', function(property, options) {
  options = Ember.EasyForm.processOptions(property, options);
  options.hash.viewName = 'tooltip-field-'+options.data.view.elementId;
  return Ember.Handlebars.helpers.view.call(this, Ember.EasyForm.Tooltip, options);
});
// Use a custom template for Easy Form. This adds a tooltip and wraps that in
// the control-label div with the label.
Ember.TEMPLATES['easyForm/wrapped_input'] = Ember.Handlebars.compile('<div class="control-label">{{label-field propertyBinding="view.property" textBinding="view.label" viewBinding="view"}}{{#if view.tooltip}}{{tooltip-field titleBinding="view.tooltip" data-tooltip-classBinding="view.tooltipClass"}}{{/if}}</div><div class="{{unbound view.controlsWrapperClass}}">{{partial "easyForm/inputControls"}}</div>');
Ember.EasyForm.Config.registerInputType('selectize', Ember.EasyForm.TextField.extend({
  defaultOptions: [],

  init: function() {
    this._super();
    this.set('selectizeTextInputId', this.elementId + '_selectize_text_input');
    this.set('overrideForElementId', this.get('selectizeTextInputId'));
  },

  didInsertElement: function() {
    this._super();

    this.$input = this.$().selectize({
      plugins: ['restore_on_backspace', 'remove_button'],
      delimiter: ',',
      options: this.get('defaultOptions'),
      valueField: 'id',
      labelField: 'label',
      searchField: 'label',
      sortField: 'label',
      onChange: _.bind(this.handleSelectizeChange, this),
      create: true,

      // Add to body so it doesn't get clipped by parent div containers.
      dropdownParent: 'body',
    });

    this.selectize = this.$input[0].selectize;
    this.selectize.$control_input.attr('id', this.get('selectizeTextInputId'));
    this.selectize.$control_input.attr('data-raw-input-id', this.elementId);

    var controlId = this.elementId + '_selectize_control';
    this.selectize.$control.attr('id', controlId);
    this.selectize.$control_input.attr('data-selectize-control-id', controlId);
  },

  defaultOptionsDidChange: function() {
    this.set('defaultOptions', this.get('collection').map(_.bind(function(item) {
      return {
        id: item.get(this.get('optionValuePath')),
        label: item.get(this.get('optionLabelPath')),
      };
    }, this)));

    if(this.selectize) {
      this.get('defaultOptions').forEach(_.bind(function(option) {
        this.selectize.addOption(option);
      }, this));

      this.selectize.refreshOptions(false);
    }
  }.observes('collection.@each').on('init'),

  // Sync the selectize input with the value binding if the value changes
  // externally.
  valueDidChange: function() {
    if(this.selectize) {
      var valueString = this.get('value');
      if(valueString !== this.selectize.getValue()) {
        var values = valueString;
        if(values) {
          values = _.uniq(values.split(','));

          // Ensure the selected value is available as an option in the menu.
          // This takes into account the fact that the default options may not
          // be loaded yet, or they may not contain this specific option.
          for(var i = 0; i < values.length; i++) {
            var option = {
              id: values[i],
              label: values[i],
            };

            this.selectize.addOption(option);
          }

          this.selectize.refreshOptions(false);
        }

        this.selectize.setValue(values);
      }
    }
  }.observes('value').on('init'),

  // Update the value binding when the selectize input changes.
  handleSelectizeChange: function(value) {
    this.set('value', value);
  },

  willDestroyElement: function() {
    if(this.selectize) {
      this.selectize.destroy();
    }
  },
}));
Ember.EasyForm.Config.registerInputType('ace', Ember.EasyForm.TextArea.extend({
  attributeBindings: ['data-ace-mode'],

  init: function() {
    this._super();
    this.set('aceId', this.elementId + '_ace');
    this.set('aceTextInputId', this.elementId + '_ace_text_input');
    this.set('overrideForElementId', this.get('aceTextInputId'));
  },

  didInsertElement: function() {
    this._super();

    var aceId = this.get('aceId');
    this.$().hide();
    this.$().before('<div id="' + aceId + '" data-form-property="' + this.property + '" class="span12"></div>');

    this.editor = ace.edit(aceId);

    var editor = this.editor;
    var session = this.editor.getSession();
    var element = this.$();

    editor.setTheme('ace/theme/textmate');
    editor.setShowPrintMargin(false);
    editor.setHighlightActiveLine(false);
    session.setUseWorker(false);
    session.setTabSize(2);
    session.setMode('ace/mode/' + this.$().data('ace-mode'));
    session.setValue(this.$().val());

    var $textElement = $(editor.textInput.getElement());
    $textElement.attr('id', this.get('aceTextInputId'));
    $textElement.attr('data-raw-input-id', this.elementId);

    var contentId = this.elementId + '_ace_content';
    var $content = $(editor.container).find('.ace_content');
    $content.attr('id', contentId);
    $textElement.attr('data-ace-content-id', contentId);


    session.on('change', function() {
      element.val(session.getValue());
      element.trigger('change');
    });
  },
}));
Ember.EasyForm.Config.registerWrapper('default', {
  formClass: '',
  fieldErrorClass: 'error',
  errorClass: 'help-block',
  hintClass: 'help-block',
  inputClass: 'control-group',
  wrapControls: true,
  controlsWrapperClass: 'controls'
});
$.ajaxPrefilter(function(options) {
  options.headers = options.headers || {};
  options.headers['X-Api-Key'] = webAdminAjaxApiKey;
});
// DataTables plugin to programmatically show the processing indidicator.
// https://datatables.net/plug-ins/api#fnProcessingIndicator
jQuery.fn.dataTableExt.oApi.fnProcessingIndicator = function ( oSettings, onoff )
{
  if( typeof(onoff) === 'undefined' )
  {
    onoff=true;
  }
  this.oApi._fnProcessingDisplay( oSettings, onoff );
};
// Defaults for DataTables.
_.merge($.fn.DataTable.defaults, {
  // Don't show the DataTables processing message. We'll handle the processing
  // message logic in initComplete with blockui.
  processing: false,

  // Enable global searching.
  searching: true,

  // Re-arrange how the table and surrounding fields (pagination, search, etc)
  // are laid out.
  dom: 'rft<"row-fluid"<"span3 table-info"i><"span6 table-pagination"p><"span3 table-length"l>>',

  language: {
    // Don't have an explicit label for the search field. Use a placeholder
    // instead.
    search: '',
    searchPlaceholder: 'Search...',
  },

  preDrawCallback: function() {
    if(!this.customProcessingCallbackSet) {
      // Use blockui to provide a more obvious processing message the overlays
      // the entire table (this helps for long tables, where a simple processing
      // message might appear out of your current view).
      //
      // Set this early on during pre-draw so that the processing message shows
      // up for the first load.
      $(this).DataTable().on('processing', _.bind(function(event, settings, processing) {
        if(processing) {
          this.block({
            message: '<i class="fa fa-spinner fa-spin fa-lg"></i>',
          });
        } else {
          this.unblock();
        }
      }, this));

      this.customProcessingCallbackSet = true;
    }
  },
});
Ember.EasyForm.Input.reopen({
  didInsertElement: function() {
    var forId = this.get('input-field-' + this.elementId + '.overrideForElementId') || this.get('input-field-' + this.elementId + '.elementId');
    this.set('label-field-' + this.elementId + '.for', forId);
  },

  // Observe the "showAllValidationErrors" property and show all the inline
  // input validations when this gets set to true. This allows us to show all
  // the invalid fields on the page without actually visiting each input field
  // (useful on form submits). This is a bit of a workaround since
  // ember-easyForm doesn't currently support this:
  // https://github.com/dockyard/ember-easyForm/issues/146
  // https://github.com/dockyard/ember-easyForm/pull/143
  showAllValidationErrorsOnModelChange: function() {
    if(this.get('context.showAllValidationErrors') === true) {
      this.set('hasFocusedOut', true);
      this.set('canShowValidationError', true);
    } else {
      this.showValidationError();
    }
  }.observes('context.showAllValidationErrors'),
});
Ember.EasyForm.Form.reopen({
  submit: function(event) {
    if (event) {
      event.preventDefault();
    }

    if(!this.get('context.model.validate')) {
      this.get('controller').send(this.get('action'));
    } else {
      // Reset the error objects used for error-messages display before each
      // submit, so the messages reflect the new validations.
      this.set('context.model.clientErrors', {});
      this.set('context.model.serverErrors', {});

      this.get('context.model').validate().then(_.bind(function() {
        this.get('controller').send(this.get('action'));
      }, this)).catch(_.bind(function() {
        // On validation failure, set the errors for error-messages display and
        // scroll to the error messages display.
        this.set('context.model.clientErrors', this.get('context.model.errors'));
        $.scrollTo('#error_messages', { offset: -50, duration: 200 });

        // Display all the inline errors for at least the top-level model
        // (note, this doesn't currently propagate to embedded models/forms).
        this.set('context.model.showAllValidationErrors', true);
      }, this));
    }
  },
});

export default Admin;
