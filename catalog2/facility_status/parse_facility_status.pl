#!/usr/bin/perl

# parse sas html facility status file

use Getopt::Std;

if ( $#ARGV < 0 ) {
  print "$0:\n";
  print "\t-f: name of file to parse\n";
  exit();
}

getopt('f');
my $fname = $opt_f; 

# list of categories
my $category_hash;
$category_hash{'navigation'} = [];
$category_hash{'state_parameters'} = [];
$category_hash{'aerosols'} = [];
$category_hash{'irradiance'} = [];
$category_hash{'chemistry'} = [];
$category_hash{'oxides_of_nitrogen'} = [];

# get the info from the html file
my $category_hash_ref = parse_html($fname,\%category_hash);
foreach $category (keys(%category_hash)) {
  print "category: $category\n";
  foreach $instrument (@{$category_hash_ref->{$category}}) {
    print "\tname: ".$instrument->{'instrument_name'}."\n";
    print "\tshort name: ".$instrument->{'instrument_short_name'}."\n";
    print "\tcomment: ".$instrument->{'comment'}."\n";
    print "***********\n";
  }
}

sub parse_html
{

  my $html_fname = shift;
  my $category_hash_ref = shift;

  my %category_hash;
  #my $hash_ref = {};
  my ($instrument_name,$instrument_short_name);

  my @arr = ();
  open(HTML, $fname) or die "cannot open $fname";
  while (<HTML>) {
    chop;
    next if (/DOCTYPE/);
    next if (/PUBLIC/);
    next if (/html|head|title|body|table|meta|font|ul/);
    push(@arr, $_);
  }
  
  
  for ($i=0; $i<$#arr; $i++) {
  
    $instrument_flag = false;
    $comment_flag = false;
  
    $line = $arr[$i];
  
    # get report metadata
    $report_date = $arr[$i+1] if ( $line =~ /Date of report/ );
    $report_author = $arr[$i+1] if ( $line =~ /Author of report/ );
    $submitted_at = $arr[$i+1] if ( $line =~ /Submitted at/ );
    $remaining_hours = $arr[$i+1] if ( $line =~ /Remaining flight hours/ );
    $general_comments = $arr[$i+1] if ( $line =~ /General Comments/ );
  
    # get the category information
    $category = 'navigation' if ($line =~ /Navigation/);
    $category = 'state_parameters' if ($line =~ /State Parameters/);
    $category = 'aerosols' if ( $line =~ /\s*Aerosols$/ );
    #$category = 'aerosols' if ($line =~ /^\s*Aerosols\s*$]$/);
    $category = 'irradiance' if ($line =~ /Irradiance/);
    $category = 'chemistry' if ($line =~ /Chemistry/);
    $category = 'oxides_of_nitrogen' if ($line =~ /Oxides of Nitrogen/);
  
    my $hash_ref = {};
    if ( $line =~ /<b>\s*([\w\d\-\_\s\(\)\;\,]+)\s*<\/b>/ ) {
      $instrument_name = $1;
      $instrument_name =~ /(.*)\s*\(([\w\d\-\_\s]+)\)*/;
      $instrument_short_name = $2;
      $comment = $arr[$i+4];
      # get rid of any leading spaces
      $instrument_name =~ s/^(\s*)(.*)/$2/;
      $instrument_short_name =~ s/^(\s*)(.*)/$2/;
      $comment =~ s/^(\s*)(.*)/$2/;
      $hash_ref->{'instrument_name'} = $instrument_name;
      $hash_ref->{'instrument_short_name'} = $instrument_short_name;
      $hash_ref->{'comment'} = $comment;
      $instrument_flag = true;
    }
    if ( $instrument_flag eq 'true') {
      push(@{$category_hash_ref->{$category}}, $hash_ref);
      my @arr = @{$category_hash_ref->{$category}};
    }
  
  }

  return $category_hash_ref;
  
}
exit();
