+function() {
    var dropdown_links = $('.nav-dropdown-link');
    dropdown_links.click(function() {
	
	parent = $(this).parent();
	menu = parent.find('.nav-dropdown-menu');
	menu.slideToggle("fast","swing");
    });

    $(document).click(function(e) {
	if (!$(e.target).hasClass('nav-dropdown-link'))
	    $('.nav-dropdown-menu').slideUp("fast","swing");
    });
}();
