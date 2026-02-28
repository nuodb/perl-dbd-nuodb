use strict;
use Test::More tests => 2;

use FindBin qw($Bin);
use lib $Bin;
use NuoDBTest;
use DBI;

my $dbh = DBI->connect($dbconnect, $user, $password, {PrintError => 0, RaiseError => 0, schema => 'dbi' });

my $version1 = DBD::NuoDB::db::version($dbh);
ok(length($version1) > 1);

my $version2 = $dbh->x_version();
ok(length($version2) > 1);
