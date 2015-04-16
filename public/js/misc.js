$(document).ready( function() {
  $('input.form-control').focus();
  
  $('tr').click( function() {
	  var link = $(this).find('a').attr('href');
	  if(link.type != "undefined") {
    	window.location = link;
    }
  })
});