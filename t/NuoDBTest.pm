package NuoDBTest;
use strict;
use warnings;
use Exporter 'import';

our @EXPORT = qw($dbname $user $password $host $dbconnect);

my $hostnm     = $ENV{NUODB_HOST}     // 'localhost';
my $port       = $ENV{NUODB_PORT}     // '48004';

our $dbname    = $ENV{NUODB_DBNAME}   // 'test';
our $user      = $ENV{NUODB_USER}     // 'dba';
our $password  = $ENV{NUODB_PASSWORD} // 'goalie';

our $host      = "$hostnm:$port";
our $dbconnect = "dbi:NuoDB:$dbname\@$host";

1;
