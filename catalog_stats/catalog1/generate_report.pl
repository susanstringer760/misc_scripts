#!/usr/bin/perl

use DBI;
use Getopt::Std;
use Sys::Hostname;
require "catalog_stats.include.pl";
require "catalog_stats.config";

# get file counts from db

# variables from config 
my $db_user =  db_user();
my $db_password = db_password();
my $hostname = hostname();
my $html_base_path = html_base_path();

if ( $#ARGV < 0 ) {
  print "USAGE: $0\n";
  print "\t-p: project name\n";
  print "\t-o: output filename (full path)\n";
  print "\t-b: begin date (YYYYMMDD)\n";
  print "\t-e: end date (YYYYMMDD)\n";
  print "\t-n: data base name\n";
  exit();
}

getopt('poben');

if ( !$opt_p ) {
  print "ERROR: project name (-p) must be specified..\n";
  exit();
}

if ( !$opt_o ) {
  print "ERROR: full path of output filename (-o) must be specified..\n";
  exit();
}

if ( !$opt_n ) {
  print "ERROR: database name (-n) must be specified..";
  exit();
}

# project begin and end dates
my $begin_date = $opt_b;
my $end_date = $opt_e;

# output filename 
my $out_fname = $opt_o;
my $date = `date '+%Y%m%d'`;
chop($date);

# project name
my $project = $opt_p;

# flag to ensure we are running on the
# host where the db resides
my $target_host = $valid_hostname;
my $host_is_valid = check_host($target_host);
if ($host_is_valid eq false) {
  print "ERROR: $target_host invalid..\n";
  exit();
}

# name of db
my $db_name = $opt_n;

my $out_fname = "$opt_o.$date";

open(OUT, ">$out_fname") || die "cannot open $out_fname";

# connect to the db
my $dbh = connectDatabase($db_name, $db_user, $db_password );

my (%date_size_hash, %category_size_hash);
# all the categores for the project
my @categories = fetch_categories($dbh);

# stuff dates into hash
my $date_list_ref = get_date_list($begin_date,$end_date);

#***********************************
# get file size for each category 
#***********************************
my %date_hash;
foreach $date (@$date_list_ref) {
  $date_hash{$date} = 'valid';
}

foreach $category (@categories) {
    #next();
    my $category_dir = "$html_base_path/$project/$category";
    my $du_cmd = "du -h $category_dir";
    my $status = `$du_cmd`;
    if ( $status ) {
      my @dir_list = split(/\n/, $status);
      foreach $dir (@dir_list) {
        next if ($dir =~ /oldfiles/);
        my ($size,$path) = split(/\s+/, $dir);
	$path =~ /(.*)\/(\d{8})/; 
	my $date = $2;
	next if (!$date);
        next if ($date_hash{$date} ne 'valid'); 
        my $size_unit = chop($size);
        $gb = $size if ($size_unit eq "G");
        $gb = mb2gb($size) if ($size_unit eq "M");
        $gb = kb2gb($size) if ($size_unit eq "K");
	#print "$date $path: adding $gb to size_hash for $category\n";
        push(@{$category_size_hash{$category}}, $gb);
      }
      #print "****************\n";
    }
}
#***********************************
# get number of report images
#***********************************
my $report_dir = "$html_base_path/$project/report";
my $image_count = 0;
foreach $date (@$date_list_ref) {
  #my $cmd = "find $dir -name '$date*report*image*' -print | wc -l";
  my $find_cmd = "find $report_dir -name 'report.*.$date*.*.image*.*' -print | wc -l";
  my $num_images = `$find_cmd`;
  chop($num_images);
  $image_count += $num_images;
  #print OUT "number of images for $dir is: $num_images\n" if ( $num_images > 0 );
  #print OUT "no images for $dir\n" if ($num_images <= 0);
}

#***********************************
# get number of files 
#***********************************
my %file_count_hash;
my $total_num_files = 0;
foreach $category (@categories) {
  my $sql = "select count(*) from files where (begin >= $begin_date and begin <= $end_date) and url_dir like '/$project/$category/%' and filename like '$category%'";
  my $array_ref = $dbh->selectrow_arrayref($sql);
  my $num_files = $array_ref->[0];
  $total_num_files += $num_files;
  $file_count_hash{$category} = $num_files;
}
#***********************************
# print out report 
#***********************************
my $title = uc($project);
$begin_date =~ /(\d{4})(\d{2})(\d{2})/;
$title .= " $1-$2-$3  to ";
$end_date =~ /(\d{4})(\d{2})(\d{2})/;
$title .= "$1-$2-$3";
print OUT "$title:\n";
my $total_size = 0;
foreach $category (sort(keys(%category_size_hash))) {
  my $sum = 0;
  foreach $size (@{$category_size_hash{$category}}) {
    $sum += $size;
  }
  $sum = sprintf("%.2f", $sum);
  $total_size += $sum;
  if ( $category eq 'report') {
    print OUT "   $category: $file_count_hash{$category} reports ($image_count images) = $sum GB\n";
  } else {
    print OUT "   $category: $file_count_hash{$category} products = $sum GB\n";
  }
}
print OUT "   TOTAL: $total_num_files products = $total_size GB\n";
close(OUT);

#***********************************
sub fetch_categories {
  my $dbh = shift;
  my @arr;
  my $sql = "select distinct category from dataset";
  my $sth = $dbh->prepare($sql)
     or die "can't prepare $sql: $dbh->errstr\n";
  $sth->execute() or die "can't execute the query: $sth->errstr\n";
  my $rows = $sth->rows;
  #my $ref = $sth->fetchrow_arrayref;
  my $ref = $sth->fetchall_arrayref;
  for ($i=0; $i <= $#$ref; $i++) {
    push(@arr, $ref->[$i][0]);
  } # end for
  $sth->finish() or die "can't finish: $sth->errstr\n";
  return @arr;
  
}

sub mb2gb {

  # convert mb to gb
  my $mb = shift;
  return sprintf("%.5f", ($mb/1024));

}

sub kb2gb {
  # convert kb to gb
  my $kb = shift;
  return sprintf("%.5f", ($kb/(1024*1024)));

}
