use strict;
use Test::More tests => 9;
use DBI;
use utf8;
binmode STDERR, ":utf8";

my $host = defined $ENV{AGENT_PORT} ? "localhost:".$ENV{AGENT_PORT} : "localhost";
my $dbh = DBI->connect('dbi:NuoDB:test@'.$host, "cloud", "user", {PrintError => 0, PrintWarn => 0, AutoCommit => 1, schema => 'dbi'});

my $utf8_string = 'Това е текст';
my ($utf8_out, $utf8_len_chars, $utf8_len_octets) = $dbh->selectrow_array("
	SELECT '$utf8_string',
	CHARACTER_LENGTH('$utf8_string' USING CHARACTERS),
	CHARACTER_LENGTH('$utf8_string' USING OCTETS)
	FROM DUAL
");
ok($utf8_out eq $utf8_string);
ok(length($utf8_string) == length($utf8_out));
ok($utf8_len_chars == 12);
ok($utf8_len_octets == 22);

$dbh->prepare($utf8_string);
ok($dbh->errstr() =~ m{$utf8_string});

my $umlauts = 'ÄËÏÖÜ';
my $sth = $dbh->prepare("SELECT ? , CHARACTER_LENGTH(? USING CHARACTERS) ,  CHARACTER_LENGTH(? USING OCTETS) FROM DUAL");
$sth->execute($umlauts, $umlauts, $umlauts);
my ($out2, $out2_characters, $out2_octets) = $sth->fetchrow_array();
ok($out2_characters == 5);
ok($out2_characters == length($umlauts));
ok($out2_octets == length($umlauts) * 2);
ok($umlauts eq $out2);
