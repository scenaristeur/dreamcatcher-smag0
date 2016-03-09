Template.registerHelper('pluralize', function(n, thing) {
  // pluraliser assez simpliste
  if (n === 1) {
    return '1 ' + thing;
  } else {
    return n + ' ' + thing + 's';
  }
});

Handlebars.registerHelper('trimString', function(passedString, startstring, endstring) {
   var theString = passedString.substring( startstring, endstring );
   return new Handlebars.SafeString(theString)
});