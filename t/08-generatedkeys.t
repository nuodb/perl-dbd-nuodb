use strict;
use Test::More tests => 1;

use DBI;
use Data::Dumper;

my $host = defined $ENV{AGENT_PORT} ? "localhost:".$ENV{AGENT_PORT} : "localhost";

my $dbh = DBI->connect('dbi:NuoDB:test@'.$host, "cloud", "user", {PrintError => 1, RaiseError => 1, schema => 'dbi' });

$dbh->do('CREATE TABLE t1 (f1 INTEGER GENERATED ALWAYS AS IDENTITY (i_'.(time()).$$.'))');
my ($id) = $dbh->selectrow_array("INSERT INTO t1 VALUES ( DEFAULT )");
ok($id == 1);
$dbh->do("DROP TABLE IF EXISTS t1");

