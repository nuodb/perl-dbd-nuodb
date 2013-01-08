use strict;
use Test::More tests => 1;
use DBI;

my $host = defined $ENV{AGENT_PORT} ? "localhost:".$ENV{AGENT_PORT} : "localhost";
my $dbh = DBI->connect('dbi:NuoDB:test@'.$host, "cloud", "user", {PrintError => 1, PrintWarn => 0, AutoCommit => 1, schema => 'dbi'});

my ($out) = $dbh->selectrow_array("SELECT ".$dbh->quote("Don't")." FROM DUAL");
ok($out eq "Don't");
