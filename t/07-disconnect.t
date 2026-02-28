use strict;
use Test::More tests => 5;

use FindBin qw($Bin);
use lib $Bin;
use NuoDBTest;
use DBI;

my $dbh = DBI->connect($dbconnect, $user, $password, {PrintError => 0, RaiseError => 0});
$dbh->disconnect();

my $result = $dbh->selectall_arrayref("USE test");
ok(not defined $result);
ok($dbh->errstr() eq 'Connection is not available.');

$dbh->{AutoCommit} = 1;
ok($dbh->errstr() eq 'Connection is not available.');

$dbh->commit();
ok($dbh->errstr() eq 'Connection is not available.');

$dbh->rollback();
ok($dbh->errstr() eq 'Connection is not available.');

