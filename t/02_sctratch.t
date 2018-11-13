use Test::More;
# use Data::Printer;
use_ok( Pg::BulkCopy );

my %args = (
	dbname => 'pgbulkcopy',
	dbhost => 'localhost',
	dbuser => 'postgres',
	dbpass => 'postgres',
	errorfile => '/tmp/pgbulk.error',
	);

my $pgc = Pg::BulkCopy->new(  %args );
$pgc->process( 't/loadbad1.csv', 'load1', 'csv');
is ($pgc->load( '/tmp/pgbulkcopywork.csv', 'load1', 'csv'),
	11, 'count rows loaded');

done_testing();

=pod 

loopmax 12
loadq copy load1 from '/tmp/pgbulkcopywork.csv' with ( format 'csv' )
line 1 DBD::Pg::st execute failed: ERROR:  missing data for column "adate"
CONTEXT:  COPY load1, line 4: "this is a bad line" at /home/brainbuz/projects/Pg-BulkCopy/lib/Pg/BulkCopy.pm line 68.
