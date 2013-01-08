use strict;
use Test::More tests => 2;

use DBI;

my $host = defined $ENV{AGENT_PORT} ? "localhost:".$ENV{AGENT_PORT} : "localhost";

my $dbh = DBI->connect('dbi:NuoDB:test@'.$host, "cloud", "user", {PrintError => 0, RaiseError => 0, schema => 'dbi' });

my $version1 = DBD::NuoDB::db::version($dbh);
ok(length($version1) > 1);

my $version2 = $dbh->x_version();
ok(length($version2) > 1);
