use strict;
use Test::More tests => 3;
use DBI;

my $host = defined $ENV{AGENT_PORT} ? "localhost:".$ENV{AGENT_PORT} : "localhost";
my $dbh = DBI->connect('dbi:NuoDB:test@'.$host, "cloud", "user", {PrintError => 1, PrintWarn => 0, AutoCommit => 1, schema => 'dbi'});

my ($out) = $dbh->selectrow_array("SELECT ? FROM DUAL", undef, 123);
ok($out == 123);

$dbh->do("DROP TABLE IF EXISTS dbi_bind");
$dbh->do("CREATE TABLE dbi_bind (f1 INTEGER, f2 STRING)");
$dbh->do("INSERT INTO dbi_bind VALUES (123, 'abc')");

my $sth_int = $dbh->prepare("SELECT f1 FROM dbi_bind WHERE f1 = ?");
$sth_int->execute(123);
my ($out_int) = $sth_int->fetchrow_array();
ok($out_int == 123);

my $sth_string = $dbh->prepare("SELECT f2 FROM dbi_bind WHERE f2 = ?");
$sth_string->execute('abc');
my ($out_string) = $sth_string->fetchrow_array();
ok($out_string eq 'abc');

$dbh->do("DROP TABLE IF EXISTS dbi_bind");

#my ($out) = $dbh->selectrow_array("SELECT ? FROM DUAL", undef, "\0\r\n\0");
#print STDERR "out is |$out|\n";
#ok($out eq "\0\r\n\0");


