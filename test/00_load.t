use Test::More;
use Data::Printer;
use_ok( Pg::BulkLoad );

my %args = (
	dbname => 'pgbulkcopy',
	dbhost => 'localhost',
	dbuser => 'postgres',
	dbpass => 'postgres',
	errorfile => '/tmp/pgbulk.error',
	);

my $pgc = Pg::BulkLoad->new(  %args );

isa_ok( $pgc, 'Pg::BulkLoad' );
can_ok( $pgc, 'new' );
can_ok( $pgc, 'load' );

done_testing();
