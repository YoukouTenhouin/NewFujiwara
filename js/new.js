$.fn.preText = function () {
    var ce = $("<pre />").html(this.html());
    ce.find("div").replaceWith(function() { return "\n" + this.innerHTML; });
    ce.find("p").replaceWith(function() { return this.innerHTML + "<br>"; });
    ce.find("br").replaceWith("\n");    
    return ce.text();
};

function generateUUID() {
    var d = new Date().getTime();
    var uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
        var r = (d + Math.random()*16)%16 | 0;
        d = Math.floor(d/16);
        return (c=='x' ? r : (r&0x7|0x8)).toString(16);
    });
    return uuid;
}   

(function(){
    window.edited = false;
    $("#category-dropdown-selected").click(function (e) {
	$("#category-dropdown").toggle();
    });
    if(window.localStorage) {
	var current_draft;
	if (window.localStorage['current'])
	    current_draft = window.localStorage['current'];
	else {
	    current_draft = generateUUID();
	}
	$("#new-draft-button").click(function() {
	    delete window.localStorage['current'];
	    window.location.reload();
	});
	Object.keys(window.localStorage).forEach(function(c) {
	    var match = c.match(/drafts_(.+)/);
	    if(match&&match[1] != window.localStorage['current']) {
		var draft = JSON.parse(window.localStorage[c]);
		var uuid = match[1];
		var li = $("<li>"),a=$("<a href=\"javascript:;\">");
		li.click(function() {
		    window.localStorage['current'] = uuid;
		    window.location.reload();
		});
		a.text(draft['title']);
		a.appendTo(li);
		li.appendTo($("#drafts-menu"));
	    }
	});
	setInterval(function () {
	    if(window.edited) {
		window.edited = false;
		var title = $("#thread-title").text();
		var dropdown_cid = $("#category-dropdown-selected").data("cid");		    
		var dropdown_text = $("#category-dropdown-selected").text();
		var tags = $("#editor-tags").text();		    
		var content = $("#editor-contentarea").preText();
		var draft_obj = Object();
		window.localStorage.setItem('saved',true);
		if(!$("#thread-title").hasClass('editor-placeholder'))
		    draft_obj['title'] = title;
		if(!$("#category-dropdown-selected").hasClass('editor-placeholder')) {
		    draft_obj['dropdown_cid'] = dropdown_cid;
		    draft_obj['dropdown_text'] = dropdown_text;
		}
		if(!$("#editor-tags").hasClass('editor-placeholder'))
		    draft_obj['tags'] = tags;
		if(!$("#editor-contentarea").hasClass('editor-placeholder'))
		    draft_obj['content'] = content;
		
		if(!window.localStorage['current'])
		    window.localStorage['current'] = current_draft;

		if(title||tags||content)
		    window.localStorage['drafts_'+current_draft] = JSON.stringify(draft_obj);
		else {
		    delete window.localStorage['current'];
		    delete window.localStorage['drafts_'+current_draft];
		}
	    }
	},1000);
	if(!window.localStorage['drafts']) 
	    window.localStorage['drafts'] = Object();

	if(window.localStorage['current']) {
	    var draft = JSON.parse(window.localStorage['drafts_' + window.localStorage['current']]);
	    var title = draft['title'];
	    var dropdown_cid = draft['dropdown_cid'];
	    var dropdown_text = draft['dropdown_text'];
	    var tags = draft['tags'];
	    var content = draft['content'];
	    if(title)
		$("#thread-title").text(title).removeClass('editor-placeholder');
	    if(dropdown_cid&&dropdown_text) {
		$('#category-dropdown-selected').removeClass('editor-placeholder');
		$('#category-dropdown-selected').data('cid',dropdown_cid);
		$('#category-dropdown-selected').text(dropdown_text);
	    }
	    if(tags)
		$('#editor-tags').text(tags).removeClass('editor-placeholder');
	    if(content)
		$('#editor-contentarea').text(content).removeClass('editor-placeholder');
	}
    }
    $(document).click(function (e) {
	if ($(e.target).attr("id") != "category-dropdown-selected") {
	    $("#category-dropdown").hide();
	}
    });
    $("#category-dropdown li").click(function() {
	$("#category-dropdown-selected").removeClass("editor-placeholder");
	$("#category-dropdown-selected").text($(this).text());
	$("#category-dropdown-selected").data("cid",$(this).data("cid"));
	window.edited = true;
	$("#category-dropdown").hide();
    });
    $(".editable").attr("contenteditable","true");
    $(".editable").keypress(function(e) {
	window.edited = true;
    });
    $(".editable").click(function() {
	if($(this).hasClass("editor-placeholder"))
	    $(this).text("").removeClass("editor-placeholder").focus();
    });
    $(".editable").blur(function() {
	if($(this).text().trim() == "") {
	    $(this).text($(this).data("placeholder")).addClass("editor-placeholder");
	}
    });
    $(".editable-single-line").keypress(function(e) {
	if(e.keyCode == 10 || e.keyCode == 13) {
	    e.preventDefault();
	}
    });
    $('#remove-button').click(function() {
	if(confirm('Are you sure you want to remove this draft?')) {
	    var current = window.localStorage['current'];
	    delete window.localStorage['current'];
	    delete window.localStorage['drafts_' + current];
	    window.location.reload()
	}
    });
    $('#publish-button').click(function() {
	var title = $("#thread-title").text();
	var dropdown_cid = $("#category-dropdown-selected").data("cid");
	var dropdown_text = $("#category-dropdown-selected").text();
	var tags = $("#editor-tags").text();
	var content = $("#editor-contentarea").preText();
	$("#input-title").val(title);
	$("#input-cid").val(dropdown_cid);
	$("#input-tags").val(tags);
	$("#input-content").text(content);
	if(window.localStorage) {
	    var current = window.localStorage['current'];
	    delete window.localStorage['current'];
	    delete window.localStorage['drafts_' + current];
	}
	$("#hidden_form").submit();
    });
}).call();
