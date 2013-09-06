# Perl DBI DBD Module for NuoDB #

[![Build Status](https://api.travis-ci.org/nuodb/perl-dbd-nuodb.png?branch=master)](http://travis-ci.org/nuodb/perl-dbd-nuodb)

This project implements a NuoDB DBD Module for Perl DBI.

## KNOWN LIMITATIONS

The following features have been implemented:

* DSNs in the form dbi:NuoDB:database@host:port
* Schema selection via the "schema" handle attribute
* Transactions, commit(), rollback() and the AutoCommit handle attribute
* prepare(), execute(), fetch() as well as the combined convenience functions such as selectall_arrayref()

The following has not been implemented yet:
* All result values are returned as strings regardless of the original data type
* Metadata methods have not been implemented
* Queries or bind values containing "\0" will most likely be truncated
* Windows has not been tested

## EXAMPLE

Here is an example use:

    use DBI;
    my $dbh = DBI->connect("dbi:NuoDB:".$database.'@'.$host.':'.$port, $username, $password, {schema => $schema});
    my $sth = $dbh->prepare("SELECT 'one' FROM DUAL");
    $sth->execute();
    my ($value) = $sth->fetchrow_array();

## PREREQUISITES ##

A recent version of DBI is required. To upgrade DBI:

    sudo perl -MCPAN -e 'force install DBI'

## BUILDING THE MODULE

Run the following commands to build the module, after having satistifed the
above prerequisites:

    perl Makefile.PL [--nuodb-libs=...] [--nuodb-includes=...]

## TESTING THE MODULE

After having built the module, above, run the following commands to prepare
an environment to test the module:

    NUODB_ROOT=/Users/rbuck/tmp/nuodb
    java -jar ${NUODB_ROOT}/jar/nuoagent.jar --broker &
    ${NUODB_ROOT}/bin/nuodb --chorus test --password bar --dba-user dba --dba-password goalie --verbose debug --archive /var/tmp/nuodb --initialize --force &
    ${NUODB_ROOT}/bin/nuodb --chorus test --password bar --dba-user dba --dba-password goalie &

Once NuoDB is running, run the following commands to test the module:

    make test

## INSTALLING THE MODULE

After having built and tested the module, above, run the following commands to
install the module:

    sudo make install

## PUBLISHING THE MODULE

### TAGGING

Tag the product using tags per the SemVer specification; our tags have a v-prefix:

    git tag -a v1.0.0 -m "SemVer Version: v1.0.0"

If you make a mistake, take it back quickly:

    git tag -d v1.0.0
    git push origin :refs/tags/v1.0.0

### PUBLISHING

Plans are to publish the module to CPAN; documentation will be added here on that
process.

[![githalytics.com alpha](https://cruel-carlota.pagodabox.com/4007bacad95973c7256bbdffb4eb5175 "githalytics.com")](http://githalytics.com/nuodb/perl-dbd-nuodb)
