require(['handlebars', 'text!template/cases/header.hbs'], function(Handlebars, CaseHeader){
  var template = Handlebars.compile(CaseHeader),
      content  = template({title: 'New Case',
                           subtitle: 'Step 2 of 4: Required Documents'});

  $('header.page-title').html(content);
});

