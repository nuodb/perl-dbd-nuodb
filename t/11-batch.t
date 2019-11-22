use strict;
use Test::More tests => 8;
BEGIN { use_ok('DBD::NuoDB') };

use DBI;
my $host = defined $ENV{NUODB_PORT} ? "localhost:".$ENV{NUODB_PORT} : "localhost";

my $dbh = DBI->connect('dbi:NuoDB:test@'.$host, "dba", "goalie", {PrintError => 1, RaiseError => 1});

$dbh->do("DROP TABLE IF EXISTS test.t1");
$dbh->do("CREATE TABLE test.t1 (f1 INTEGER PRIMARY KEY, f2 STRING)");

my $sth = $dbh->prepare("INSERT INTO test.t1 VALUES (?, ?)");

$sth->bind_param(1, 123);
$sth->bind_param(2, "abc");
ok($sth->x_add_batch());

$sth->bind_param(1, 234);
$sth->bind_param(2, "klm");
ok($sth->x_add_batch());

ok($sth->x_execute_batch());

my $rows = $dbh->selectall_arrayref("SELECT * FROM test.t1");
ok($rows->[0]->[0] == 123);
ok($rows->[1]->[0] == 234);

ok($rows->[0]->[1] eq "abc");
ok($rows->[1]->[1] eq "klm");

$dbh->do("DROP TABLE test.t1");
