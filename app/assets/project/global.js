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
    "text":                 "bower/requirejs-text/text",
    "handlebars":           "bower/handlebars/handlebars",
    "json2":                "bower/json2/json2",
    "modernizr":            "bower/modernizr/modernizr",
    "select2":              "bower/select2/select2",
    "jqueryui-touch-punch": "bower/jqueryui-touch-punch/jquery.ui.touch-punch",
    "jquery-form":          "bower/jquery-form/jquery.form",
    // "jquery.ui":         "bower/jquery.ui/modernizr",
  }
});

define([], function(){
  if (!window.Tenure) window.Tenure = {
    api: {
      committee_members: {},
      committees: {},
      CLOR: {}, // Confidential letters of recommendation
      packets: {},
      required_docs: {},
      workflow_steps: {}
    },
    models: {},
    views: {},
    collections: {},
    helpers: {},
    modules: {},
    ui: {}
  };

  return Tenure;
});
