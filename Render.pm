package Render;

use strict;
use warnings;

use Cache::Memcached::Fast;
use Encode;

my $_memd;

my $CACHE = 1;

sub get_memd {
    $_memd = new Cache::Memcached::Fast({
	servers => [ { address => 'localhost:11211' ,weight => 2.5 } ],
	namespace => "renderer:"
					})
	if (!$_memd);
    return $_memd;
}

use Text::Markdown::Hoedown;

sub escape_formula {
    my $formula = shift;
    $formula =~ s/([_*\\{}()])/\\$1/g;
    return $formula;
}

sub remove_extra_slash {
    my $formula = shift;
    $formula =~ s/\\([_*\\{}()])/$1/g;
    return $formula;
}

sub do_render {
    my $post = shift;    
    my $content = $post->{content};
    $content =~ s/(\\\((.+?)\\\))/escape_formula($1)/ge;
    $content =~ s/(\$(.+?)\$)/escape_formula($1)/ge;
    $content =~ s/```math(.*?)```/$1/sg;
    my $rendered = markdown(
	$content,
	extensions => HOEDOWN_EXT_FENCED_CODE|HOEDOWN_EXT_STRIKETHROUGH,
	html_options => HOEDOWN_HTML_ESCAPE);
    $rendered =~ s/(\\\((.+?)\\\))/remove_extra_slash($1)/ge;
    $rendered =~ s/(\$(.+?)\$)/remove_extra_slash($1)/ge;
    return $rendered;
}

sub render {
    my $post = shift;
    my $ret;
    if($CACHE) {
	my $cache = get_memd;
	my $cached = $cache->get($post->{id});
	if(!$cached) {
	    my $rendered = do_render($post);
	    $cache->set($post->{id},encode_utf8($rendered));
	    $ret = "<!-- cache missed --!>".$rendered;
	} else {
	    $ret = "<!-- cache hit --!>".decode_utf8($cached);
	}
    } else {
	$ret = do_render($post);
    }
    return $ret;
}
    
1;
