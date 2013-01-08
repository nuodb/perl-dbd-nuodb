use ExtUtils::MakeMaker;
use DBI::DBD;
use Getopt::Long;
use warnings;

my ($nuodb_includes, $nuodb_libs);
my $opt_result = GetOptions (
	'nuodb-includes=s' => \$nuodb_includes,
	'nuodb-libs=s' => \$nuodb_libs
);

$nuodb_includes = '/opt/nuodb/include' if not defined $nuodb_includes;
$nuodb_libs = '/opt/nuodb/lib' if not defined $nuodb_libs;

print "Using: \$nuodb_includes = $nuodb_includes ; \$nuodb_libs = $nuodb_libs\n";

WriteMakefile(
	dbd_edit_mm_attribs({
		'NAME'		=> 'DBD::NuoDB',
		'ABSTRACT'	=> 'Perl DBD DBI driver for NuoDB',
		'AUTHOR'	=> 'Philip Stoev <pstoev@nuodb.com>',
		'VERSION_FROM'	=> 'lib/DBD/NuoDB.pm',
		'C'		=> ['dbdimp.cpp', 'NuoDB.c'],
		'XS'		=> {'NuoDB.xs' => 'NuoDB.c'},
		'OBJECT'	=> 'dbdimp.o NuoDB.o',
		'LIBS'		=> ['-L'.$nuodb_libs.' -lNuoRemote'],
		'dist'		=> {
				'SUFFIX'   => '.gz',
				'COMPRESS' => 'gzip -9f'
		},
		'realclean'	=> { FILES => '*.xsi' },
		'CONFIGURE'	=> sub {
			my $dbi_arch_dir = dbd_dbi_arch_dir();
			if (exists($opts{INC})) {
				return {INC => "-I$nuodb_includes -I$dbi_arch_dir $opts{INC}"};
			} else {
				return {INC => "-I$nuodb_includes -I$dbi_arch_dir"};
			}
		},
		LD		=> 'g++',
		LDDLFLAGS	=> $^O eq 'darwin' ? '-arch x86_64 -bundle -undefined dynamic_lookup -L'.$nuodb_libs.' -Xlinker -rpath -Xlinker '.$nuodb_libs : '',
		LDFLAGS		=> $^O eq 'darwin' ? '-arch x86_64 -L'.$nuodb_libs : '',
		CC		=> 'g++'
	})
);
