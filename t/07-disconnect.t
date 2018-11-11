use strict;
use Test::More tests => 5;

use DBI;
my $host = defined $ENV{NUODB_PORT} ? "localhost:".$ENV{NUODB_PORT} : "localhost";

my $dbh = DBI->connect('dbi:NuoDB:test@'.$host, "dba", "goalie", {PrintError => 0, RaiseError => 0});
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

