var DataTablesHelpers = {
  renderEscaped: function(value, type) {
    if(type === 'display' && value) {
      return _.escape(value);
    }

    return value;
  },

  renderListEscaped: function(value, type) {
    if(type === 'display' && value) {
      if(_.isArray(value)) {
        return _.map(value, function(v) { return _.escape(v); }).join('<br>');
      } else {
        return _.escape(value);
      }
    }

    return value;
  },

  renderTime: function(value, type) {
    if(type === 'display' && value && value !== '-') {
      return moment(value).format('YYYY-MM-DD HH:mm:ss');
    }

    return value;
  },
};

export default DataTablesHelpers;
