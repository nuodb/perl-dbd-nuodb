package DBD::NuoDB;
use strict;
use warnings;
use DBI;

use vars qw($VERSION $drh);

$VERSION = '0.01';

@DBD::NuoDB::ISA = qw(DynaLoader);
bootstrap DBD::NuoDB $VERSION;

sub CLONE {
	$drh = undef;
}

sub driver {
	return $drh if $drh;
	
	my($class, $attr) = @_;
	$class .= "::dr";

	$drh = DBI::_new_drh($class, {
		'Name'		=> 'NuoDB',
		'Version'	=> $VERSION,
		'Attribution'	=> 'Perl DBI DBD NuoDB driver by Philip Stoev <pstoev@nuodb.com>',
	});

	DBD::NuoDB::db->install_method('x_version');
	DBD::NuoDB::st->install_method('x_analyze');
	
	return $drh;
}

1;

package DBD::NuoDB::dr;
use strict;
use warnings;

sub connect {
	my ($drh, $dsn, $user, $auth, $attr) = @_;

	my $private_attr = {
		'Name' => $dsn
	};

	$private_attr->{schema} = $attr->{schema} if defined $attr->{schema};

	my $dbh = DBI::_new_dbh($drh, {}, $private_attr) or return undef;
	DBD::NuoDB::db::_login($dbh, $dsn, $user, $auth) or return undef;

	return $dbh;
}

1;

package DBD::NuoDB::db;
use strict;
use warnings;

sub prepare {
	my ($dbh, $statement, $attribs) = @_;

	# create a 'blank' sth
	my $sth = DBI::_new_sth($dbh, {
		'Statement' => $statement
	}) or return undef;

	# Call the driver-specific function _prepare in Driver.xs file
	# which calls the DBMS-specific function(s) to prepare a statement
	# and populate internal handle data.

	DBD::NuoDB::st::_prepare($sth, $statement, $attribs) or return undef;

	return $sth;
}

1;
