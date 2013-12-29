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

#open(OUT, ">$out_fname") || die "cannot open $out_fname";
#print OUT "$project:\n";

# connect to the db
my $dbh = connectDatabase($db_name, $db_user, $db_password );

my (%date_size_hash, %category_size_hash);
# all the categores for the project
my @categories = fetch_categories($dbh);

# stuff dates into hash
my $date_list_ref = get_date_list($begin_date,$end_date);
my %date_hash;
foreach $date (@$date_list_ref) {
  $date_hash{$date} = 'valid';
}

foreach $category (@categories) {
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
foreach $category (keys(%category_size_hash)) {
  my $sum = 0;
  foreach $size (@{$category_size_hash{$category}}) {
    $sum += $size;
  }
  print "$category = $sum\n";
}

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
