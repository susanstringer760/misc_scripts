#!/usr/bin/perl
#
# create fake instruments and add to
# zith9_mpex_facility_status db

use DBI;

my $gv_platform_id = 350;
my $c130_platform_id = 130;

#my %platform_hash;
my $platform_ref = {};
my $sql;

# GV
my @gv_instrument_arr = (1 .. 15);
@gv_instrument_arr = map("gv_instrument$_", @gv_instrument_arr);
my @gv_instrument_values;
for ($i=0; $i<=$#gv_instrument_arr;$i++) {
  $instrument = $gv_instrument_arr[$i];
  if ( $i >= 0 && $i < 5 ) {
    $category_id = 58,
  } elsif ( $i >= 5 && $i < 12 ) {
    $category_id = 59,
  } else {
    $category_id = 60,
  }
  my $ref = {
    'instrument_name'=>$instrument,
    'category_id'=>$category_id,
    'platform_id'=>$gv_platform_id
  };
  push(@gv_instrument_values, $ref);
}
print "GV\n";
foreach $hash (@gv_instrument_values) {
  print $hash->{'instrument_name'}."\n";
  $sql = "insert into instrument (instrument_name) values ('$instrument')";
  print "\tcategory id: ".$hash->{'category_id'}."\n";
  print "\tplatform id: ".$hash->{'platform_id'}."\n";
  $sql = "insert
}
print "**************\n";

# C130
my @c130_instrument_arr = (1 .. 20);
@c130_instrument_arr = map("c130_instrument$_", @c130_instrument_arr);
my @c130_instrument_values;
for ($i=0; $i<=$#c130_instrument_arr;$i++) {
  $instrument = $c130_instrument_arr[$i];
  $platform_id = 130;
  if ( $i >= 0 && $i < 9 ) {
    $category_id = 58,
  } elsif ( $i >= 9 && $i < 15 ) {
    $category_id = 59,
  } else {
    $category_id = 60,
  }
  my $ref = {
    'instrument_name'=>$instrument,
    'category_id'=>$category_id,
    'platform_id'=>$c130_platform_id,
  };
  push(@c130_instrument_values, $ref);
}

print "C130\n";
foreach $hash (@c130_instrument_values) {
  print $hash->{'instrument_name'}."\n";
  print "\tcategory id: ".$hash->{'category_id'}."\n";
  print "\tplatform id: ".$hash->{'platform_id'}."\n";
}
print "**************\n";

exit();


my $platform1_arr_ref = [];
for ($i=0;$i<=$#instrument1_arr;$i++) {
  $instrument = $instrument1_arr[$i];
  if ( $i < 7 ) {
    $platform = "platform1";
  } else {
    $platform = "platform2";
  }
  print "$instrument and $platform\n";
}
exit();
$platform_arr_ref->[0] = {
  'platform'=>'platform1',
  'instrument'=>'instrument1',
  'category_id'=>11
};
print "asdfasdf: ".$platform_arr_ref->[0]->{'platform'}."\n";
print "zxcvzxcv: ".$platform_arr_ref->[0]->{'instrument'}."\n";
print "asdfasdf: ".$platform_arr_ref->[0]->{'category_id'}."\n";
exit();


$platform_hash{'platform1'} = \@instrument1_arr;
$platform_hash{'platform2'} = \@instrument2_arr;
$platform_hash{'platform3'} = \@instrument3_arr;
$platform_hash{'platform4'} = \@instrument4_arr;

foreach $platform (sort(keys(%platform_hash))) {
  print "$platform\n";
  my $arr_ref = $platform_hash{$platform};
  foreach $instrument (@$arr_ref) {
    print "\t$instrument\n";
  }
}

my $name = $instrument->{'instrument_name'};
my $short_name = $instrument->{'instrument_short_name'};
my $comment = $instrument->{'comment'};
next() if ( !$name );
$short_name = '' if ( !$short_name );
$comment = '' if ( !$comment);

#first, make sure it's not a duplicate instrument
my $id_sql = "SELECT id FROM instrument WHERE name='$name' AND short_name='$short_name'";
my $id = $dbh->selectrow_array($id_sql);
#don't try to enter duplicate record
next() if ( $id );
    

sub insert_instrument {

  my $name = shift;
  my $short_name = '';

  # first, make sure it's not a duplicate instrument
  my $id_sql = "SELECT id FROM instrument WHERE name='$name' AND short_name='$short_name'";
  my $id = $dbh->selectrow_array($id_sql);
  # don't try to enter duplicate record
  next() if ( $id );
  my $sql = "INSERT INTO instrument (name,short_name) VALUES ('$name','$short_name')";
  print "$sql\n";
  exit();
  #$dbh->do($instrument_sql) or die "Couldn't execute sql: $instrument_sql$dbh->errstr";

}
sub get_instrument_id {

  my $name = shift;
  my $short_name = '';
  my $id_sql = "SELECT id FROM instrument WHERE name='$name' AND short_name='$short_name'";
  my $instrument_id = $dbh->selectrow_array($id_sql);

  return $instrument_id;

}
sub insert_facility_status {

  my $project_id = shift;
  my $platform_id = shift;
  my $instrument_id = shift;
  my $status = shift;
  my $comment = shift;
  my $category_id = shift;

  #first, make sure it's not a duplicate instrument
  my $id_sql = "SELECT id FROM instrument WHERE name='$name' AND short_name='$short_name'";
  my $id = $dbh->selectrow_array($id_sql);
  #don't try to enter duplicate record
  next() if ( $id );
  my $sql = "INSERT INTO instrument (name,short_name) VALUES ('$name','$short_name')";
  $dbh->do($instrument_sql) or die "Couldn't execute sql: $instrument_sql$dbh->errstr";

}
