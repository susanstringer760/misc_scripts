#!/usr/bin/perl
#
use Time::Local;
use Date::Calc qw(Add_Delta_Days);
use Sys::Hostname;

sub check_host {

  my $host = shift;
  # first, make sure that we're on correct host 

  my $current_host = hostname;
  if ( $current_host !~ /$host/ ) {
     return false;
  }
  return true;
  
}

sub get_date_list {

  # get a list of project dates
  # (YYYYMMDD)
  my $begin = shift;
  my $end = shift;
  
  my @date_arr;

  push(@date_arr, $begin);

  my $date = $begin;

  while (1) {
    $date =~ /(\d{4})(\d{2})(\d{2})/;
    #print "processing $date\n";
    my ($year,$month,$day) = Add_Delta_Days($1, $2, $3, 1);
    my $date_str = sprintf("%4d%02d%02d", $year,$month,$day);
    #print "new date: $date_str\n";
    push(@date_arr, $date_str);
    $date = $date_str;
    last() if ( $date_str eq $end );
  }

  return \@date_arr;

}

sub connectDatabase {
  my $db_name = shift;
  my $db_user = shift;
  my $db_password = shift;
  return $dbh = DBI->connect("DBI:mysql:$db_name:localhost",$db_user,$db_password) || die( "Unable to connect to database: $db_name");
}
1;


