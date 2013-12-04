define(['backbone'], function(Backbone) {
  Tenure.views.AboutView = Backbone.View.extend({
    initialize: function() {
      console.log('Inside About View!');
    }
  });

  return Tenure.views.AboutView;
});

