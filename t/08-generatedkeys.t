use strict;
use Test::More tests => 1;

use FindBin qw($Bin);
use lib $Bin;
use NuoDBTest;
use DBI;
use Data::Dumper;

my $dbh = DBI->connect($dbconnect, $user, $password, {PrintError => 1, RaiseError => 1, schema => 'test' });

my $identity = 'i_'.(time()).$$;

$dbh->do('CREATE SEQUENCE '.$identity);
$dbh->do('CREATE TABLE t1 (f1 INTEGER GENERATED ALWAYS AS IDENTITY ('.$identity.'))');
my ($id) = $dbh->selectrow_array("INSERT INTO t1 VALUES ( DEFAULT )");
ok($DBI::err == 0);
$dbh->do("DROP TABLE IF EXISTS t1");
