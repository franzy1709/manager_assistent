$(document).ready( function(){
  $("tr.switcher").click(function(){
  	var target = $($(this).data('target'));
  	$(target).toggleClass('hide');
  })
});