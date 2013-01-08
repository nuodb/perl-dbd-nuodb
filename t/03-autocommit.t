use strict;
use Test::More tests => 9;
BEGIN { use_ok('DBD::NuoDB') };

use DBI;
my $host = defined $ENV{AGENT_PORT} ? "localhost:".$ENV{AGENT_PORT} : "localhost";

# First, autocommit is ON

{
	my $dbh_autocommit = DBI->connect('dbi:NuoDB:test@'.$host, "cloud", "user", {PrintError => 1, PrintWarn => 0, AutoCommit => 1, schema => 'dbi'});
	ok(defined $dbh_autocommit);

	$dbh_autocommit->do("DROP TABLE IF EXISTS t1");
	$dbh_autocommit->do("CREATE TABLE t1 (f1 INTEGER)");
	$dbh_autocommit->do("INSERT INTO t1 VALUES (1),(2)");

	my $dbh_second = DBI->connect('dbi:NuoDB:test@'.$host, "cloud", "user", {PrintError => 1, PrintWarn => 0, AutoCommit => 1, schema => 'dbi'});
	my ($count_second) = $dbh_second->selectrow_array("SELECT COUNT(*) FROM t1");
	ok($count_second == 2);

	$dbh_autocommit->do("ROLLBACK");	# Should have no effect
	$dbh_autocommit->rollback();
	my ($count_autocommit) = $dbh_autocommit->selectrow_array("SELECT COUNT(*) FROM t1");
	ok($count_autocommit == 2);

	$dbh_autocommit->do("DROP TABLE t1");
}

# Then, it is OFF

{
	my $dbh_noautocommit = DBI->connect('dbi:NuoDB:test@'.$host, "cloud", "user", {PrintError => 1, PrintWarn => 0, AutoCommit => 0, schema => 'dbi'});
	ok(defined $dbh_noautocommit);

	$dbh_noautocommit->do("DROP TABLE IF EXISTS t1");
	$dbh_noautocommit->do("CREATE TABLE t1 (f1 INTEGER)");
	$dbh_noautocommit->commit();
	$dbh_noautocommit->do("INSERT INTO t1 VALUES (1),(2)");

	my $dbh_second = DBI->connect('dbi:NuoDB:test@'.$host, "cloud", "user", {PrintError => 1, PrintWarn => 0, AutoCommit => 1, schema => 'dbi'});
	my ($count_second) = $dbh_second->selectrow_array("SELECT COUNT(*) FROM t1");
	ok($count_second == 0);

	$dbh_noautocommit->rollback();
	my ($count_noautocommit) = $dbh_noautocommit->selectrow_array("SELECT COUNT(*) FROM t1");
	ok($count_noautocommit == 0);

	$dbh_noautocommit->do("INSERT INTO t1 VALUES (1),(2)");
	$dbh_noautocommit->commit();
	my ($count_second2) = $dbh_second->selectrow_array("SELECT COUNT(*) FROM t1");
	ok($count_second2 == 2);

	$dbh_noautocommit->do("INSERT INTO t1 VALUES (3),(4)");
	$dbh_noautocommit->disconnect();
	my ($count_second3) = $dbh_second->selectrow_array("SELECT COUNT(*) FROM t1");
	ok($count_second3 == 2);

	$dbh_second->do("DROP TABLE t1");
}
