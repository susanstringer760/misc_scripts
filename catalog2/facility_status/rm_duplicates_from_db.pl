#!/usr/bin/perl

# script to rm duplicate records from
# database dump

use Getopt::Std;

if ( $#ARGV < 0 ) {
  print "$0:\n";
  print "\t-i: input db dump fname\n";
  print "\t-o: output db dump fname\n";
}

my ($in_fname, $out_fname);
getopt('io');
$in_fname = $opt_i;
$out_fname = $opt_o;

if ( !$in_fname ) {
  print "ERROR: input db dump filename (-i) must be specified\n";
  exit();
}
if ( !$out_fname ) {
  $out_fname = $in_fname;
  $in_fname .= ".ori";
}
print "in: $in_fname\n";
print "out: $out_fname\n";
exit();


my $dump_fname = "zith9_mpex_prodcopy.20130827.ctm-dev.sql";
my $out_fname = "corrected_$dump_fname";

open(OUT, ">$out_fname") or die "cannot open $out_fname";

# list of tables that have duplicate records
my @table_list;
push(@table_list, "test1");
push(@table_list, "catalog_facility_status");
push(@table_list, "test2");

#my $line = "INSERT INTO `catalog_facility_status` VALUES (1,373,350,NULL,'up','flyboy','2013-05-21 22:20:39',0,4,'2013-05-21 22:20:39',4,'2013-05-21 22:20:39'),(2,373,130,1,'up','ready','2013-05-21 22:25:18',0,4,'2013-05-21 22:25:18',4,'2013-05-21 22:25:18'),(3,373,130,1,'up','','2013-05-21 22:25:26',0,4,'2013-05-21 22:25:26',4,'2013-05-21 22:25:26'),(4,373,130,1,'up','','2013-05-19 01:01:01',0,4,'2013-05-21 22:25:41',4,'2013-05-24 19:36:30'),(5,373,350,NULL,'down','hard down day','2013-05-21 22:25:59',0,4,'2013-05-21 22:25:59',4,'2013-05-21 22:25:59'),(6,373,350,1,'up',NULL,'2013-05-21 22:26:11',0,4,'2013-05-21 22:26:11',4,'2013-05-21 22:26:11'),(7,3373,350,2,'provisional',NULL,'2013-05-21 22:26:14',0,4,'2013-05-21 22:26:14',4,'2013-05-21 22:26:14'),(9,373,350,1,'up','still up','2013-05-24 19:32:43',0,4,'2013-05-24 19:32:43',4,'2013-05-24 19:32:43');";
my $line = "INSERT INTO `catalog_facility_status` VALUES (1,373,350,NULL,'up','flyboy','2013-05-21 22:20:39',0,4,'2013-05-21 22:20:39',4,'2013-05-21 22:20:39'),(2,373,130,1,'up','ready','2013-05-21 22:25:18',0,4,'2013-05-21 22:25:18',4,'2013-05-21 22:25:18'),(3,373,130,1,'up','','2013-05-21 22:25:26',0,4,'2013-05-21 22:25:26',4,'2013-05-21 22:25:26'),(4,373,130,1,'up','','2013-05-19 01:01:01',0,4,'2013-05-21 22:25:41',4,'2013-05-24 19:36:30'),(5,373,350,NULL,'down','hard down day','2013-05-21 22:25:59',0,4,'2013-05-21 22:25:59',4,'2013-05-21 22:25:59'),(6,373,350,1,'up',NULL,'2013-05-21 22:26:11',0,4,'2013-05-21 22:26:11',4,'2013-05-21 22:26:11'),(7,373,350,1,' up',NULL,'2013-05-21 22:26:11',0,4,'2013-05-21 22:26:11',4,'2013-05-21 22:26:11'),(8,373,350,2,'provisional',NULL,'2013-05-21 22:26:14',0,4,'2013-05-21 22:26:14',4,'2013-05-21 22:26:14'),(9,373,350,1,'up','still up','2013-05-24 19:32:43',0,4,'2013-05-24 19:32:43',4,'2013-05-24 19:32:43');";

my @record_id;
my (%column_hash, %id_hash);
my (@records);
#if ($dup_line =~ /INSERT INTO \`(\w+\_*)\`/) {
if ($line =~ /INSERT INTO \`(\w+\_*)\`/) {
  # get table name
  my $table = $1;
  $table =~ s/\s+//g;
  if ( array_match(\@table_list, $table) ) {
    my ($cmd,$values) = split(/VALUES/, $line);
    # get an array of records
    @records = split(/\),\(/, $values);
    foreach $record (@records) {
      $record =~ s/^\s*\(//g;
      $record =~ s/\)\s*\;//g;
      $record =~ /(\d+)\,(.*)/;
      my $id = $1;
      my $values = $2;
      # remove spaces from values
      # so we can determine if duplicate
      # exists
      my $key = $values;
      $key =~ s/\s+//g;
      #print "$id = $key\n";
      #push(@body_arr, $body);
      #print "adding $values to column_hash $key\n";
      $column_hash{$key} = $values;
      #print "adding $id to column_hash $key\n\n";
      $id_hash{$key} = $id;
    }
  }
  my $value_str = '';
  my $ori_num_records = $#records;
  @records = keys(%column_hash);
  my $new_num_records = $#records;
  print "asdf: $ori_num_records and $new_num_records\n";
  if ( $ori_num_records != $new_num_records ) {
    print "found duplicate records in $table\n";
  }
  exit();
  print "asdf: $ori_num_records and $new_num_records\n";exit();
  foreach $row (keys(%column_hash)) {
    $record = "($id_hash{$row},$column_hash{$row}),";
    $value_str .= $record;
  }
  print "asdf: $value_str\n";
  exit();
  print "**********\n";
  print "INSERT INTO `$table` VALUES ";
  my @records = keys(%column_hash);
print "there are: $#records records\n";
exit();
  my $num_records = $#records;
  my $count = 0;
  my @record_arr = keys(%column_hash);
  print "before: $record_arr[0]\n"; 
  my @value_arr = map ("$id_hash{$_},$body_hash{$_}", @record_arr);
  print "before: $value_arr[0]\n"; 
  exit();
  #foreach $record (keys(%body_hash)) {
    #push(@record_arr, "$id_hash{$record},$body_hash{$record});
    #last if ($count == $num_records);
    #print "($id_hash{$record},$body_hash{$record}),"\n";
  #}
  exit();
print "before: $#records\n";
my @xx = keys(%record_hash);
print "after: $#xx\n";
}

exit();


my $dump_fname = "zith9_mpex_prodcopy.20130827.ctm-dev.sql";

#if ( $#ARGV < 0 ) {
#  print "$0:\n";
#  print "\t-f: name of database dump\n";
#  exit();
#}
#getopt('f');
#my $dump_fname = $opt_f; 

open(DUMP, $dump_fname) or die "cannot open $dump_fname";

while (<DUMP>) {
  chop;
  
}

close(DUMP);

sub array_match {

  my $arr_ref = shift;
  my $match_str = shift;
  my @arr = @$arr_ref;

  # convert array to a hash with the array elements as the hash keys and the values are simply 1
  my %hash = map {$_ => 1} @arr;

  # check if the hash contains $match
  if (defined $hash{$match_str}) { 
    return 1;
  } else {
    return 0;
  }

}
