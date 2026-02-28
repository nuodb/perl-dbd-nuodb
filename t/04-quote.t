use strict;
use Test::More tests => 1;
use DBI;

use FindBin qw($Bin);
use lib $Bin;
use NuoDBTest;
my $dbh = DBI->connect($dbconnect, $user, $password, {PrintError => 1, PrintWarn => 0, AutoCommit => 1, schema => 'dbi'});

my ($out) = $dbh->selectrow_array("SELECT ".$dbh->quote("Don't")." FROM DUAL");
ok($out eq "Don't");
