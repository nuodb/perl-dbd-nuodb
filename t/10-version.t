use strict;
use Test::More tests => 2;

use DBI;

my $host = defined $ENV{NUODB_PORT} ? "localhost:".$ENV{NUODB_PORT} : "localhost";

my $dbh = DBI->connect('dbi:NuoDB:test@'.$host, "dba", "goalie", {PrintError => 0, RaiseError => 0, schema => 'dbi' });

my $version1 = DBD::NuoDB::db::version($dbh);
ok(length($version1) > 1);

my $version2 = $dbh->x_version();
ok(length($version2) > 1);
