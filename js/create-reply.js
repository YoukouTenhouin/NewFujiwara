function createReply(floor,replyto) {
    var origval = $('#replyto').val();
    $('#replyto').val(origval + ',' + replyto);
    var reply_text = "回复" + floor +"楼:";
    text = $('#reply-area').val();
    if (text.length == 0 || text[text.length-1] == '\n') {
	$('#reply-area').val(text+reply_text+'\n');
    } else {
	$('#reply-area').val(text+'\n'+reply_text+'\n');
    }
    $('#reply-area').focus();
}
