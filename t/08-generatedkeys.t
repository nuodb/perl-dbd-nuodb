use strict;
use Test::More tests => 1;

use DBI;
use Data::Dumper;

my $host = defined $ENV{NUODB_PORT} ? "localhost:".$ENV{NUODB_PORT} : "localhost";

my $dbh = DBI->connect('dbi:NuoDB:test@'.$host, "dba", "goalie", {PrintError => 1, RaiseError => 1, schema => 'dbi' });

$dbh->do('CREATE TABLE t1 (f1 INTEGER GENERATED ALWAYS AS IDENTITY (i_'.(time()).$$.'))');
my ($id) = $dbh->selectrow_array("INSERT INTO t1 VALUES ( DEFAULT )");
ok($DBI::err == 0);
$dbh->do("DROP TABLE IF EXISTS t1");

