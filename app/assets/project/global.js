require.config({
  baseUrl: '/assets',
  shim: {
    'jquery': {
      exports: 'jquery'
    },
    'handlebars': {
      exports: 'Handlebars'
    },
    'select2': {
      exports: 'jquery'
    }
  },

  paths: {
    views: 'views',
    "jquery":               "bower/jquery/jquery",
    "backbone":             "bower/backbone-amd/backbone",
    "underscore":           "bower/underscore-amd/underscore",
    "requirejs":            "bower/requirejs/require",
    "text":                 "bower/text/text",
    "handlebars":           "bower/handlebars/handlebars",
    "modernizr":            "bower/modernizr/modernizr",
    "select2":              "bower/select2/select2",
    "jqueryui-touch-punch": "bower/jqueryui-touch-punch/jquery.ui.touch-punch",
    "jquery-form":          "bower/jquery-form/jquery.form",
    // "json2":             "bower/json2/json2",
    // "jquery.ui":         "bower/jquery.ui/modernizr",
  }
});

define([], function(){
  window.Tenure = {
    models: {},
    views: {},
    collections: {},
    helpers: {},
    modules: {}
  };

  return Tenure;
});
