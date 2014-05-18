package Render;

use strict;
use warnings;

use Text::Markdown::Hoedown;

our @EXPORT = qw(render);

my $cb = Text::Markdown::Hoedown::Renderer::HTML->new(HOEDOWN_HTML_ESCAPE,99);
my $md = Text::Markdown::Hoedown::Markdown->new(
    HOEDOWN_EXT_FENCED_CODE|HOEDOWN_EXT_STRIKETHROUGH|HOEDOWN_EXT_NO_INTRA_EMPHASIS,
    99,$cb);

sub render {
    my $post = shift;    
    my $content = $post->{content};
#    $content =~ s/\n/\n\n/g;
    my $rendered = $md->render($content);
    $rendered =~ s/(<code>.*)\n\n(.*<\/code>)/\$1\n\$2/g;
    return $rendered;
}
    
1;
