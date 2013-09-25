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

my @arr = ();
open(HTML, $fname) or die "cannot open $fname";
while (<HTML>) {
  chop;
  next if (/DOCTYPE/);
  next if (/PUBLIC/);
  next if (/html|head|title|body|table|meta|font|ul/);
  push(@arr, $_);
}

my %category_hash;
my $arr_ref = [];
my $hash_ref = {};
my ($instrument_name,$instrument_short_name);

# list of categories
$category_hash{'navigation'} = [];
$category_hash{'state_parameters'} = [];
$category_hash{'aerosols'} = [];
$category_hash{'irradiance'} = [];
$category_hash{'chemistry'} = [];
$category_hash{'oxides_of_nitrogen'} = [];

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
    $hash_ref->{'instrument_name'} = $instrument_name;
    $hash_ref->{'instrument_short_name'} = $instrument_short_name;
    $instrument_flag = true;
  }
  if ( $line =~ /<b>Comment:\s*<\/b>/ ) {
    $comment = $arr[$i+2];
    $hash_ref->{'comment'} = $comment;
    $comment_flag = true;
  }
  if ( $instrument_flag eq 'true') {
    print "adding ".$hash_ref->{'instrument_name'}." to $category\n";
    push(@{$category_hash{$category}}, $hash_ref);
    my @arr = @{$category_hash{$category}};
  }

}

print "**********************\n";
foreach $category (keys(%category_hash)) {
  my @arr = @{$category_hash{$category}};
  my $num_instruments = $#arr+1;
  print "category: $category has $num_instruments instruments\n";
}
exit();
