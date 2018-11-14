# Pg::BulkLoad

Load Comma and Tab Delimited files into Postgres, skipping bad records.

## Reason

The Postgres 'COPY FROM' lacks a mechanism for skipping bad records. Sometimes we need to ingest 'dirty' data and make the best of it.

## Method and Performance

Pg::BulkLoad attempts to load your file via the COPY FROM command if it fails it parses the error for the bad line, removes and logs it, and then writes it to /tmp and attempts to load again. If your data is clean the COPY FROM command is pretty fast, however if there are a lot of bad records, for each failure Pg::BuklLoad has to rewrite the input file. If your data has a lot of bad records small batches are recommended, for clean data performance will be better with a larger batch size. The split program will quickly split larger files, but you can split them in Perl if you prefer. 

## Limitation of COPY

Since Pg::Bulkload passes all of the work to copy it is subject to the limitation that the source file must be readable via the file system to the postgres server (usually the postgres user). To avoid permissions problems Pg::Bulkload copies the file to /tmp for loading (leaving the original preserved if it has to evict records). Pg::BulkLoad needs to be run locally to the server, this means that your host for connection will almost always be localhost.

# Synopsis

    Shell> split -l 50000 -a 3 -d mydata.csv load
    Shell> myloadscript.pl load*

    === myloadscript.pl ===

    use Pg::BulkCopy;

    my %args = (
           dbname => 'pgbulkcopy',
           dbhost => 'localhost',
           dbuser => 'postgres',
           dbpass => 'postgres',
           errorfile => '/tmp/pgbulk.error',
           errorlimit => 500,
           );

    my $pgc = Pg::BulkLoad->new(  %args );

    .... # your code to read file names and possibly manipulate files contents prior to load.

    while ( @filelist ) {
        $pgc->load( $file, $_, 'csv' );
    }

## History

My first CPAN module was Pg::BulkCopy, because I had this problem. I found something better that was written in C, so I deprecated my original module which needed a rewrite. Sometimes the utility I switched to doesn't want to compile, so I got tired of that, still had my problem, so I finally rewrote Pg::BulkCopy. The old module wanted to be an import/export utility, where this new one just does one thing.

# Testing

For CPAN the module only tests that it can load (ie. that it is valid Perl and that you have the dependencies installed). To properly test it you'll need to setup a database using the sql file found in the test folder of the distribution and run the tests contained within.
