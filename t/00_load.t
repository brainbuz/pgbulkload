use Test::More;
use Data::Printer;
use_ok( Pg::BulkCopy );

my %args = (
	dbname => 'pgbulkcopy',
	dbhost => 'localhost',
	dbuser => 'postgres',
	dbpass => 'postgres',
	errorfile => '/tmp/pgbulk.error',
	);

my $pgc = Pg::BulkCopy->new(  %args );

isa_ok( $pgc, 'Pg::BulkCopy' );
can_ok( $pgc, 'new' );
can_ok( $pgc, 'evict' );

done_testing();

p $pgc;