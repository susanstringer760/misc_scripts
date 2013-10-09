#!/usr/bin/perl

# parse sas html facility status file

use Getopt::Std;
use DBI;

if ( $#ARGV < 0 ) {
  print "$0:\n";
  print "\t-f: name of file to parse\n";
  print "\t-n: database name\n";
  print "\t-u: database user\n";
  print "\t-p: database password\n";
  exit();
}

getopt('fnup');
my $fname = $opt_f; 
my $db_name = $opt_n; 
my $db_user = $opt_u; 
my $db_password = $opt_p; 

if ( $db_name eq '' ) { print "ERROR: database name (-n) not specified\n";exit(); }
if ( $db_user eq '' ) { print "ERROR: database user (-u) not specified\n";exit(); }
if ( $db_password eq '' ) { print "ERROR: database password (-p) not specified\n";exit(); }

##### CONSTANTS #####

# list of categories
my $category_hash;
$category_hash{'navigation'} = [];
$category_hash{'state_parameters'} = [];
$category_hash{'aerosols'} = [];
$category_hash{'irradiance'} = [];
$category_hash{'chemistry'} = [];
$category_hash{'oxides_of_nitrogen'} = [];
$category_hash{'metadata'} = [];

my $project_id = 371;
my $platform_id = 130;
my $instrument_status = 'up';
my $instrument_id;

###################

# get the info from the html file
my $category_hash_ref = parseHtml($fname,\%category_hash);
# report metadata
my $metadata_hash = $category_hash_ref->{'metadata'}->[0];
my $report_date = $metadata_hash->{'report_date'};
$report_date =~ s/\//\-/g;
$report_date .= ":00";
my $report_author = $metadata_hash->{'report_author'};
my $submitted_at = $metadata_hash->{'submitted_at'};
my $remaining_hours = $metadata_hash->{'remaining_hours'};
my $general_comments = $metadata_hash->{'general_comments'};

# insert into db
my $dbh = connectToDB($db_name,$db_user,$db_password);

# now, insert into instrument into db
foreach $category (keys(%category_hash)) {
  #print "category: $category\n";
  foreach $instrument (@{$category_hash_ref->{$category}}) {
    my $name = $instrument->{'instrument_name'};
    print "processing instrument: $name\n";
    my $short_name = $instrument->{'instrument_short_name'};
    my $comment = $instrument->{'comment'};
    #my $instrument_sql = "insert into instrument (name,short_name) values
    next() if ( !$name ); 
    $short_name = '' if ( !$short_name ); 
    $comment = '' if ( !$comment); 

    # first, make sure it's not a duplicate instrument
    my $id_sql = "SELECT id FROM instrument WHERE name='$name' AND short_name='$short_name'";
    my $id = $dbh->selectrow_array($id_sql);
    # don't try to enter duplicate record
    my $skip_instrument = false;
    if ( $id ) {
      $skip_instrument = true;
    #} else {
    #  print "creating new instrument where name = $name\n";
    }
    if ( $skip_instrument eq 'false' ) {
      my $instrument_sql = "INSERT INTO instrument (name,short_name) VALUES ('$name','$short_name')";
      print "creating new instrument where name = $name\n";
      $dbh->do($instrument_sql) or die "Couldn't execute sql: $instrument_sql: $dbh->errstr";
      my $id_sql = "SELECT id FROM instrument WHERE name='$name' AND short_name='$short_name'";
      $instrument_id = $dbh->selectrow_array($id_sql);
      print "creating new instrument where name = $name\n";
    } else {
      $instrument_id = $id;
      print "$instrument_id already exists = $name\n";
    }

    # now, create catalog_facility_status row
    # make sure it's not a duplicate
    #my $facility_status_dup_sql = "SELECT project_id,platform_id,instrument_id,report_date FROM catalog_facility_status where instrument_id = $instrument_id";
    my $facility_status_dup_sql = "SELECT project_id,platform_id,instrument_id,report_date FROM catalog_facility_status where project_id = $project_id AND platform_id=$platform_id AND instrument_id=$instrument_id AND report_date='$report_date'";
    my @db_dup_arr = $dbh->selectrow_array($facility_status_dup_sql);
    print "testing for $project_id,$platform_id,$instrument_id,$report_date: $#db_dup_arr\n";
    if ( $#db_dup_arr < 0 ) {
      print "creating new catalog_facility_status entry where instrument_id = $instrument_id\n";
      my $facility_status_sql = "INSERT INTO catalog_facility_status (project_id,platform_id,instrument_id,status,comment, report_date) VALUES ($project_id,$platform_id,$instrument_id,'$instrument_status', '$comment', '$report_date')";
      print "$facility_status_sql\n";
      $dbh->do($facility_status_sql) or die "Couldn't execute sql: $facility_status_sql: $dbh->errstr";
      print "*********************\n";
    #  last;
    } else {
      print "duplicate record for catalog_facility_status table\n";
      print "*********************\n";
    }
  } # end instrument
}

sub parseHtml
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
  
  my $report_hash_ref = {};
  for ($i=0; $i<$#arr; $i++) {
  
    $instrument_flag = false;
    $comment_flag = false;
  
    $line = $arr[$i];
  
    my $hash_ref = {};
      #$hash_ref->{'instrument_name'} = $instrument_name;
      #$hash_ref->{'instrument_short_name'} = $instrument_short_name;
      #$hash_ref->{'comment'} = $comment;
    # get report metadata
    if ( $line =~ /Date of report/ ) {
      $report_date = $arr[$i+1];
      $report_date =~ s/^(\s+)(.*)/$2/g;
      $report_hash_ref->{'report_date'} = $report_date;
      next();
    }
    if ( $line =~ /Author of report/ ) {
      $report_author = $arr[$i+1]; 
      $report_author =~ s/^(\s+)(.*)/$2/g;
      $report_hash_ref->{'report_author'} = $report_author;
      next();
    }
    if ( $line =~ /Submitted at/ ) {
      $submitted_at = $arr[$i+1]; 
      $submitted_at =~ s/^(\s+)(.*)/$2/g;
      $report_hash_ref->{'submitted_at'} = $submitted_at;
      next();
    }
    if ( $line =~ /Remaining flight hours/ ) {
      $remaining_hours = $arr[$i+1]; 
      $remaining_hours =~ s/^(\s+)(.*)/$2/g;
      $report_hash_ref->{'remaining_hours'} = $remaining_hours;
      next();
    }
    if ( $line =~ /General Comments/ ) {
      $general_comments = $arr[$i+1]; 
      $general_comments =~ s/^(\s+)(.*)/$2/g;
      $report_hash_ref->{'general_comments'} = $general_comments;
      next();
    }
  
    # get the category information
    $category = 'navigation' if ($line =~ /Navigation/);
    $category = 'state_parameters' if ($line =~ /State Parameters/);
    $category = 'aerosols' if ( $line =~ /\s*Aerosols$/ );
    #$category = 'aerosols' if ($line =~ /^\s*Aerosols\s*$]$/);
    $category = 'irradiance' if ($line =~ /Irradiance/);
    $category = 'chemistry' if ($line =~ /Chemistry/);
    $category = 'oxides_of_nitrogen' if ($line =~ /Oxides of Nitrogen/);
  
    #my $hash_ref = {};
    if ($line =~ /<b>(.*)(\(.*)<\/b>/) {  
      $instrument_name = $1;
      #$instrument_name =~ /(.*)\s*\(([\w\d\-\_\s]+)\)*/;
      $instrument_short_name = $2;
      $comment = $arr[$i+4];
      # get rid of any leading spaces
      $instrument_name =~ s/^(\s*)(.*)/$2/;
      $instrument_short_name =~ s/^(\s*)(.*)/$2/;
      $comment =~ s/^(\s*)(.*)/$2/;
      # remove trailing spaces
      $instrument_name =~ s/\s+$//g;
      $instrument_short_name =~ s/\s+$//g;
      $comment =~ s/\s+$//g;

      # remove () from short_name
      $instrument_short_name =~ s/\(|\)//g;

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

  # all the report global information
  push(@{$category_hash_ref->{'metadata'}}, $report_hash_ref);

  return $category_hash_ref;
  
}
sub connectToDB()
{

  my $db_name = shift;
  my $user = shift;
  my $password = shift;
  my $host = shift;

  return DBI->connect( "DBI:mysql:database=$db_name;
                       host=$host",
                       "$user",
                       "$password",
                       { PrintError => 0,
                         PrintWarn => 1,
                         RaiseError => 1,
                         HandleError => \&dbiErrorHandler,
                       } ) || die( "Unable to Connect to database" );

}
sub dbiErrorHandler {

  $error = shift;
  print "ERROR: $error\n";
  exit();

  return 1;

}


exit();
