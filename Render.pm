package Render;

use strict;
use warnings;

use Text::Markdown::Hoedown;

our @EXPORT = qw(render);

sub render {
    my $post = shift;    
    my $content = $post->{content};
    my $rendered = markdown($content,
			    extensions => HOEDOWN_EXT_FENCED_CODE|HOEDOWN_EXT_STRIKETHROUGH|HOEDOWN_EXT_NO_INTRA_EMPHASIS,
			    html_options => HOEDOWN_HTML_ESCAPE);
    return $rendered;
}
    
1;
