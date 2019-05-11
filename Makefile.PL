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

print "Using: --nuodb-includes='$nuodb_includes' --nuodb-libs='$nuodb_libs'\n";

@nuodb_includes = split(' ', $nuodb_includes);
@nuodb_libs = split(' ', $nuodb_libs);

@incs = ();
for (@nuodb_includes) {
    -d $_ && push(@incs, "-I$_");
}
@incs or die "Unable to locate the include directories: $nuodb_includes";

@libs = ();
for (@nuodb_libs) {
    -d $_ && push(@libs, $_);
}
@libs or die "Unable to locate the library directories: $nuodb_libs";
$libs = join(' ', map { "-L$_" } @libs);
$rpath = join(' ', map { "-Xlinker -rpath -Xlinker $_" } @libs);


WriteMakefile(
    NAME            => 'DBD::NuoDB',
    ABSTRACT        => 'Perl DBD DBI driver for NuoDB',
    AUTHOR          => 'NuoDB, Inc. <drivers@nuodb.com>',
    VERSION_FROM    => 'lib/DBD/NuoDB.pm',
    PREREQ_PM       => { 'DBI::DBD' => '0' },
    XS              => {'NuoDB.xs' => 'NuoDB.c'},
    C               => ['dbdimp.cpp', 'NuoDB.c'],
    OBJECT          => 'dbdimp.o NuoDB.o',
    LIBS            => ["$libs -lNuoRemote"],
    dist            => {
        SUFFIX      => '.gz',
        COMPRESS    => 'gzip -9f'
    },
    realclean       => { FILES => '*.xsi' },
    CONFIGURE       => sub {
        push(@incs, '-I'.dbd_dbi_arch_dir());
        $incs = join(' ', @incs);
        $incs .= " $opts{INC}" if exists($opts{INC});
        return {INC => $incs};
    },
    CC              => $^O eq 'darwin' ? 'clang++' : 'g++',
    LD              => $^O eq 'darwin' ? 'clang++' : 'g++',
    LDDLFLAGS       => $^O eq 'darwin' ? "-arch x86_64 -bundle -undefined dynamic_lookup $libs $rpath" : '',
    LDFLAGS         => $^O eq 'darwin' ? "-arch x86_64 $libs" : '',
);
