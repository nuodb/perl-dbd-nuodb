=============================
Perl DBI DBD Module for NuoDB
=============================

.. image:: https://api.travis-ci.org/nuodb/perl-dbd-nuodb.png?branch=master
    :target: http://travis-ci.org/nuodb/perl-dbd-nuodb

.. contents::

This project implements a NuoDB_ DBD Module for `Perl DBI`_.  This is a
community-driven driver with limited support and testing from NuoDB.

Requirements
============

* `Perl DBI`_ module.  Use your package manager, or else CPAN: ``sudo perl -MCPAN -e 'force install DBI'``

* NuoDB_.  This driver uses the Perl XS interface with the NuoDB client shared
  library.

If you install NuoDB using your package manager, replace ``$NUODB_HOME`` below
with the standard path ``/opt/nuodb``.

If you download the NuoDB tar file package, replace ``$NUODB_HOME`` below with
the path to the unpacked directory.  In this situation you don't need to use
``sudo`` to manage the NuoDB Broker.

Building
========

Run the following command to build the module::

    perl Makefile.PL --nuodb-libs="$NUODB_HOME/lib64" --nuodb-includes="$NUODB_HOME/include"

Testing
-------

The tests included with the module assume that a NuoDB database named ``test``
exists, with a DBA user ``dba`` and password ``goalie``.

For details on starting and managing NuoDB databases, see the Documentation_.

If you have not configured and started a NuoDB Broker on your host, do so::

    DOMAIN_PWD=bird
    printf '\ndomainPassword = '"$DOMAIN_PWD"'\n' | sudo tee -a "$NUODB_HOME"/etc/default.properties >/dev/null
    sudo "$NUODB_HOME"/etc/nuoagent start

If you have already configured and started a NuoDB Broker, replace
``$DOMAIN_PWD`` with your domain password in the commands below.

Create a database ``test``::

    "$NUODB_HOME"/bin/nuodbmgr --broker localhost --password "$DOMAIN_PWD" \
        --command "start process sm database test host localhost archive /tmp/nuoarchive initialize true"
    "$NUODB_HOME"/bin/nuodbmgr --broker localhost --password "$DOMAIN_PWD" \
        --command "start process te database test host localhost options '--dba-user dba --dba-password goalie'"

Once the database is running, test the module with::

    make test

Be sure to shut down the database once your testing is complete::

    "$NUODB_HOME"/bin/nuodbmgr --broker localhost --password "$DOMAIN_PWD" \
        --command "shutdown database database test"

Installing
----------

Run the following commands to install the module::

    sudo make install

Example
=======

Here is an example:

.. code:: perl

    use DBI;
    my $dbh = DBI->connect("dbi:NuoDB:$database\@$host:$port", $username, $password, {schema => $schema});
    my $sth = $dbh->prepare("SELECT 'one' FROM DUAL");
    $sth->execute();
    my ($value) = $sth->fetchrow_array();

Known Limitations
=================

The following features have been implemented:

* DSNs in the form dbi:NuoDB:*database@host:port*
* Schema selection via the "schema" handle attribute
* Transactions, commit(), rollback() and the AutoCommit handle attribute
* prepare(), execute(), fetch() as well as the combined convenience functions
  such as selectall_arrayref()

The following have not been implemented yet:

* All result values are returned as strings regardless of the original data type
* Metadata methods have not been implemented
* Queries or bind values containing ``\0`` will most likely be truncated
* Windows has not been tested

References
==========

* NuoDB_
* NuoDB Documentation_
* `Perl DBI`_

License
=======

The NuoDB DBI DBD driver is  licensed under a `BSD 3-Clause License <https://github.com/nuodb/perl-dbd-nuodb/blob/master/LICENSE>`_.

.. _NuoDB: https://www.nuodb.com/
.. _Documentation: https://doc.nuodb.com/Latest/Default.htm
.. _Perl DBI: https://dbi.perl.org/
