# (C) Copyright NuoDB, Inc. 2012-2018
# Redistribution and use permitted under the terms of the 3-clause BSD license.

use ExtUtils::MakeMaker;
use DBI::DBD;
use Getopt::Long;
use warnings;

my ($nuodb_includes, $nuodb_libs);
my $opt_result = GetOptions (
    'nuodb-includes=s' => \$nuodb_includes,
    'nuodb-libs=s' => \$nuodb_libs
    );

$nuodb_includes = '/opt/nuodb/include' unless defined $nuodb_includes;
$nuodb_libs = '/opt/nuodb/lib64' unless defined $nuodb_libs;

print "Using: \$nuodb_includes = $nuodb_includes ; \$nuodb_libs = $nuodb_libs\n";

WriteMakefile(
    NAME            => 'DBD::NuoDB',
    ABSTRACT        => 'Perl DBD DBI driver for NuoDB',
    AUTHOR          => 'NuoDB, Inc. <drivers@nuodb.com>',
    VERSION_FROM    => 'lib/DBD/NuoDB.pm',
    PREREQ_PM       => { 'DBI::DBD' => '0' },
    XS              => {'NuoDB.xs' => 'NuoDB.c'},
    C               => ['dbdimp.cpp', 'NuoDB.c'],
    OBJECT          => 'dbdimp.o NuoDB.o',
    LIBS            => ["-L$nuodb_libs -lNuoRemote"],
    dist            => {
        SUFFIX      => '.gz',
        COMPRESS    => 'gzip -9f'
    },
    realclean       => { FILES => '*.xsi' },
    CONFIGURE       => sub {
        my $dbi_arch_dir = dbd_dbi_arch_dir();
        if (exists($opts{INC})) {
            return {INC => "-I$nuodb_includes -I$dbi_arch_dir $opts{INC}"};
        } else {
            return {INC => "-I$nuodb_includes -I$dbi_arch_dir"};
        }
    },
    CC              => $^O eq 'darwin' ? 'clang++' : 'g++',
    LD              => $^O eq 'darwin' ? 'clang++' : 'g++',
    LDDLFLAGS       => $^O eq 'darwin' ? "-arch x86_64 -bundle -undefined dynamic_lookup -L$nuodb_libs -Xlinker -rpath -Xlinker $nuodb_libs" : '',
    LDFLAGS         => $^O eq 'darwin' ? "-arch x86_64 -L$nuodb_libs" : '',
);
