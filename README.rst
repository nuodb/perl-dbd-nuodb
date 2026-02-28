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

The tests included with the module assume that a NuoDB database is already
running.  If you don't have a NuoDB domain available you can create one using
the Docker image on DockerHub.  See `Quick Start Guides / Docker`_.

The tests use the values of the environment variables ``NUODB_HOST``,
``NUODB_DBNAME``, ``NUODB_USER``, and ``NUODB_PASSWORD`` to access the
database.  The default values for these variables if not set are
``localhost``, ``test``, ``dba``, and ``goalie`` respectively.

Once the database is running, test the module with::

    make test

Installing
----------

Run the following commands to install the module::

    sudo make install

Example
=======

Here is an example:

.. code:: perl

    use DBI;
    my $dbh = DBI->connect("dbi:NuoDB:$database\@$host:$port",
                           $username, $password, {schema => $schema});
    my $sth = $dbh->prepare("SELECT 'one' FROM DUAL");
    $sth->execute();
    my ($value) = $sth->fetchrow_array();

Known Limitations
=================

The following features have been implemented:

* DSNs in the form dbi:NuoDB:*database@host:port?property=value*
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

The NuoDB DBI DBD driver is licensed under a `BSD 3-Clause License <https://github.com/nuodb/perl-dbd-nuodb/blob/master/LICENSE>`_.

.. _NuoDB: https://www.nuodb.com/
.. _Documentation: https://doc.nuodb.com/nuodb/latest/introduction-to-nuodb/
.. _Perl DBI: https://dbi.perl.org/
.. _Quick Start Guides / Docker: https://doc.nuodb.com/nuodb/latest/quick-start-guide/docker/
