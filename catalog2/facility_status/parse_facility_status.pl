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

my $category_hash;
my $arr_ref = [];
$category_hash->{'navigation'} = [];
$category_hash->{'state_parameters'} = [];
$category_hash->{'aerosols'} = [];
$category_hash->{'irradiance'} = [];
$category_hash->{'chemistry'} = [];
$category_hash->{'oxides_of_nitrogen'} = [];

for ($i=0; $i<$#arr; $i++) {
  $line = $arr[$i];
  next if ($line =~ /^\s*$/);

  # remove html elements
  $line =~ s/(<\w+>)//g;
  $line =~ s/\<\/\w+\>//g;

  # get report metadata
  $report_date = $arr[$i+1] if ( $line =~ /Date of report/ );
  $report_author = $arr[$i+1] if ( $line =~ /Author of report/ );
  $submitted_at = $arr[$i+1] if ( $line =~ /Submitted at/ );
  $remaining_hours = $arr[$i+1] if ( $line =~ /Remaining flight hours/ );
  $general_comments = $arr[$i+1] if ( $line =~ /General Comments/ );

  # get the category information
  $category = 'navigation' if ($line =~ /Navigation/);
  $category = 'state_parameters' if ($line =~ /State Parameters/);
  $category = 'aerosols' if ($line =~ /Aerosols/);
  $category = 'irradiance' if ($line =~ /Irradiance/);
  $category = 'chemistry' if ($line =~ /Chemistry/);
  $category = 'oxides_of_nitrogen' if ($line =~ /Oxides of Nitrogen/);
  next if ($category eq '');
  my $hash_ref = {};
  $arr_ref = $category_hash{$category};
  if ( $line =~ /\s+\d{1,}.$/) {
    $instrument = $arr[$i+1];
    $instrument =~ s/<b>|<\/b>//g;
    $hash_ref->{'instrument'} = $instrument;
    $comment = $arr[$i+5];
    $comment =~ s/<b>|<\/b>//g;
    $hash_ref->{'comment'} = $comment;
    print "adding $instrument and $comment to $hash_ref\n";
    push(@$arr_ref, $hash_ref);
  }
  next();
  $category_hash->{$category} = $arr_ref;
}
exit();
foreach $category (keys(%$category_hash)) {
  my $xx = $category_hash->{$category};
  print "asdfas: $category = $#$xx\n";
  next();
  foreach $xx (@$arr_ref) {
    print "\t: $xx\n";
  }
}
exit();
my @xx = keys(%$category_hash);
print "asdfasdf: @xx\n";
exit();
print "after: $category_hash\n";
exit();
print "Report date: $report_date\n";
print "Report author: $report_author\n";
print "Submitted at: $submitted_at\n";
print "Remaining hours: $remaining_hours\n";
print "General comments: $general_comments\n";

close(HTML);

sub get_category_array_ref {

  my $search_for = shift;

  # get the category information
  $category = 'navigation' if ($line =~ /Navigation/);
  $category = 'state_parameters' if ($line =~ /State Parameters/);
  $category = 'aerosols' if ($line =~ /Aerosols/);
  $category = 'irradiance' if ($line =~ /Irradiance/);
  $category = 'chemistry' if ($line =~ /Chemistry/);
  $category = 'oxides_of_nitrogen' if ($line =~ /Oxides of Nitrogen/);

  # get a reference to the array
}
