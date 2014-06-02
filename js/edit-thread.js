+function() {
    var title = $('#title');
    title.click(function() {
	$(this).attr('contenteditable','true').focus();
    });
    $(document).click(function(e) {
	if($(e.target).attr('id') != 'title'
	  && title.attr('contenteditable') == 'true') {
	    title.removeAttr('contenteditable');
	    $('#save-notify').show();
	    $.post('/api/modify-title',{th:window.tid,title:title.text()},function() {
		$('#save-notify').hide();
	    });
	}
    });
    title.keypress(function(e) {
	if(e.keyCode == 10 || e.keyCode == 13) {
	    e.preventDefault();
	    $(this).removeAttr('contenteditable').blur();
	    $('#save-notify').show();
	    $.post('/api/modify-title',{th:window.tid,title:$(this).text()},function() {
		$('#save-notify').hide();
	    });
	}
    });
}();
    
