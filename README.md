# NAME

Pg::BulkLoad - Bulk Load for Postgres with ability to skip bad records.

# VERSION

version 2.06

# Pg::BulkLoad

Load Comma and Tab Delimited files into Postgres, skipping bad records.

# VERSION 2.06

# Synopsis

This example will take a table name followed by file names (wildcards allowed) from the command
line and load the data.

    Shell> split -l 50000 -a 3 -d mydata.csv load
    Shell> myloadscript.pl tablename load*

    === myloadscript.pl ===

     use Pg::BulkLoad;

     my $pgc = Pg::BulkLoad->new(
       pg => DBI->connect("dbi:Pg:dbname=$dbname", $username, $password, {AutoCommit => 0}),
       errorfile => '/tmp/pgbulk.error',
       errorlimit => 500,
     );

     my $table = shift @ARGV;
     my @files = map { `ls -b $_`} @ARGV ;
     chomp @files;
     for my $file ( @files ) { $pgc->load( $file, $table, 'csv' ) }

## new

Takes arguments in hash format:

    pg => DBD::Pg database_handle (mandatory),
    errorfile => A file to log errors to (mandatory),
    errorcount => a limit of errors before giving up (optional)

## load ($file, $table, $format )

Attempts to load your data. Takes 3 parameters:

- $file

    the file you're trying to load.

- $table

    the table to load to.

- $format

    either text or csv

## Reason

The Postgres 'COPY FROM' lacks a mechanism for skipping bad records. Sometimes we need to ingest 'dirty' data and make the best of it.

## Method and Performance

Pg::BulkLoad attempts to load your file via the COPY FROM command if it fails it removes the error for the bad line from its working copy, then attempts to load all of the records previous to the error, and then tries to load the remaining data after the failure.

If your data is clean the COPY FROM command is pretty fast, however if there are a lot of bad records, for each failure Pg::BuklLoad has to rewrite the input file. If your data has a lot of bad records small batches are recommended, for clean data performance will be better with a larger batch size. To keep this program simpler I've left chunking larger files up to the user. The split program will quickly split larger files, but you can split them in Perl if you prefer. Pg::BulkLoad does hold the entire data file in memory (to improve performance on dirty files) this will create a practical maximum file size.

## Limitation of COPY

Since Pg::Bulkload passes all of the work to copy it is subject to the limitation that the source file must be readable via the file system to the postgres server (usually the postgres user). To avoid permissions problems Pg::Bulkload copies the file to /tmp for loading (leaving the original preserved if it has to evict records). Pg::BulkLoad needs to be run locally to the server, this means that your host for connection will almost always be localhost.

## Other Considerations

The internal error counting is for the life of an instance not per data file. If you have 100 source files an error limit of 500 and there are 1000 errors in your source you will likely get about half the data loaded before this module quits. You should be prepared to deal with the consequences of a partial load.

## Extra Help for Perl Novices

### DBI Connection

The example assumes that you'll set variables for your dbname, user and password. Optionally you could make them command line parameters with this code:

    my $dbname = shift @ARGV;
    my $username = shift @ARGV;
    my $password = shift @ARGV;
    my $tablename = shift @ARGV;

Or you could assign a value to any of those. The keyword **my** is variable declaration, **@ARGV** is Perl's name for the command line arguments.

## History

My first CPAN module was Pg::BulkCopy, because I had this problem. I found something better that was written in C, so I deprecated my original module which needed a rewrite. Sometimes the utility I switched to doesn't want to compile, so I got tired of that, still had my original problem of getting a lot of data from an external source that has a certain amount of errors, and is creative in finding new ways get bad records past my preprocessor. Pg::BulkCopy wanted to be an import/export utility, Pg::BulkLoad only deals with the core issue of getting the good data loaded.

# Testing

To properly test it you'll need to export DB\_TESTING to a true value in your environment before running tests. When this variable isn't set the tests mock a database for a few of the simpler tests and skip the rest.

# AUTHOR

John Karr <brainbuz@brainbuz.org>

# COPYRIGHT AND LICENSE

This software is Copyright (c) 2018 by John Karr.

This is free software, licensed under:

    The GNU General Public License, Version 3, June 2007
