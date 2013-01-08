use strict;
use Test::More tests => 3;

use DBI;

my $host = defined $ENV{AGENT_PORT} ? "localhost:".$ENV{AGENT_PORT} : "localhost";

my $dbh = DBI->connect('dbi:NuoDB:test@'.$host, "cloud", "user", {PrintError => 0, RaiseError => 0, schema => 'dbi' });

my $query = 'SELECT * FROM SYSTEM.TABLES';
my $sth = $dbh->prepare($query);
my $analysis1 = DBD::NuoDB::st::analyze($sth);
ok(length($analysis1) > length($query));

my $analysis2 = $sth->x_analyze();
ok(length($analysis2) > length($query));

my $unprepared_sth = DBI::_new_sth($dbh, {});
my $analysis3 = $unprepared_sth->x_analyze();
ok(not defined $analysis3);
