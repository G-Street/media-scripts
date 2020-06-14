#!/usr/bin/env perl

# Run using perl -X ~/Desktop/html-parser.pl
	
use strict;
use warnings;

# package MyParser;
# use base qw(HTML::Parser);
#
# # This parser only looks at opening tags
#     sub start {
# 	my ($self, $tagname, $attr, $attrseq, $origtext) = @_;
# 	if ($tagname eq 'a') {
# 	    print "URL found: ", $attr->{ href }, "\n";
# 	}
#     }
#
# package main;
# my $parser = MyParser->new;
# $parser->parse_file("/Users/jakeireland/Desktop/One Piece – HorribleSubs.html");

use HTML::TokeParser::Simple;

my $p = HTML::TokeParser::Simple->new(file => '/Users/jakeireland/Desktop/One Piece – HorribleSubs.html');

my $level;

while (my $tag = $p->get_tag('div')) {
    my $class = $tag->get_attr('class');
    next unless defined($class) and $class eq 'episode-container'; #dl-type hs-magnet-link; rls-link link-1080p

    $level += 1;
    
    my $anchor = $p->get_tag('a');
    my $href = $anchor->get_attr('href');
    
    while (my $token = $p->get_token) {
        # next unless defined($href);
        # $level += 1 if $token->is_start_tag('div');
        # $level -= 1 if $token->is_end_tag('div');
        print $token->as_is, "\n";
        # print $href , "\n";
        unless ($level) {
            last;
        }
    }
}



# while ( my $div = $parser->get_tag('div') ) {
#     my $id = $div->get_attr('id');
#     next unless defined($id) and $id eq 'listSubtitlesFilm';
#
#     my $anchor = $parser->get_tag('a');
#     my $href = $anchor->get_attr('href');
#     next unless defined($href)
#         and $href =~ m!/subtitles-(\d{2,8})\.aspx\z!;
#     push @dnldLinks, [$parser->get_trimmed_text('/a'), $1];
# }
