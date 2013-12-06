require(['handlebars', 'text!template/cases/header.hbs'], function(Handlebars, CaseHeader){
  var template = Handlebars.compile(CaseHeader),
      content  = template({title: 'New Case',
                           subtitle: 'Step 1 of 4: Candidate Information'});

  $('header.page-title').html(content);
});

