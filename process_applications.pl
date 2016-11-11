#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: process_applications.pl
#
#        USAGE: ./process_applications.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 11/11/2016 10:01:59
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

use Data::Dumper;
use FindBin;
use lib "$FindBin::Bin/local/lib/perl5";
use feature ':5.10'; # loads all features available in perl 5.10
use Text::CSV;
use Mojo::Loader qw(data_section);
use Mojo::Template;
use Mojo::Util qw/ encode slurp spurt /;

# Read the output path and filename from STDIN
my $output_file = shift @ARGV;

# Work with the CSV
my $csv = Text::CSV->new ( { binary => 1 } )  # should set binary attribute.
                or die "Cannot use CSV: ".Text::CSV->error_diag ();
 
open my $fh, "<:encoding(utf8)", "applications.csv" or die "applications.csv: $!";

$csv->column_names (qw/ id name team email phone pitch mandate storytelling medium hurdles whynow whyyou funds more updates startdate submitdate network /);
my $hr = $csv->getline_hr ($fh);

my $applications = $csv->getline_hr_all ($fh);
$csv->eof or $csv->error_diag();
close $fh;

# Use a template to output HTML
my $template = data_section __PACKAGE__, 'template';
my $mt       = Mojo::Template->new;
my $output_html = $mt->render( $template, $applications );
$output_html = encode 'UTF-8', $output_html;

# Write the template output to a filehandle if one was provided
if ( $output_file ) {
    spurt $output_html, $output_file;
} else {
    say $output_html;
}

__DATA__
@@ template
% my $count = 0;
% my ($data) = @_;
% for my $app ( @$data ) {
% $count++;
<h2>Application Number <%= $count %> </h2>
<small>(Unique ID: <%= $app->{'id'} %>)</small>
<br />
<small>Submitted on: <%= $app->{'submitdate'} %></small>
<br />
<b>Tell us about the project in one sentence:</b> <%= $app->{'pitch'} %>
<br />
<b>Tell us how you think the project fits with Uncharted's mandate of "bold adventurous storytelling"?</b>
<%= $app->{'mandate'} %>
<br />
<b>How do you imagine telling this story?</b>
<%= $app->{'storytelling'} %>
<br />
<b>Which medium will you be using to tell the story and why?</b>
<%= $app->{'medium'} %>
<br />
<b>What hurdles do you anticipate and how will you overcome them?</b>
<%= $app->{'hurdles'} %>
<br />
<b>Why this? Why now?</b>
<%= $app->{'whynow'} %>
<br />
<b>Why you?</b>
<%= $app->{'whyyou'} %>
<br />
<b>How will you use the funds?</b>
<%= $app->{'funds'} %>
<br />
<b>Did we miss anything? Tell us more...</b>
<%= $app->{'more'} %>
<br />
<hr />
% }
