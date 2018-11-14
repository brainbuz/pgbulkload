use Test::More;
use Test::Exception;
use Data::Printer;
use Path::Tiny;
use_ok( Pg::BulkLoad );

use feature qw/signatures postderef/;
no warnings qw/experimental uninitialized/;

my %args = (
	dbname => 'pgbulkcopy',
	dbhost => 'localhost',
	dbuser => 'postgres',
	dbpass => 'postgres',
	errorfile => '/tmp/pgbulk.error',
	);

my $pgc = Pg::BulkLoad->new(  %args );

sub test_some_data ( $file, $format, $insert_count ) {
	$pgc->{db}->query( 'truncate load1');
	is ($pgc->load( $file, 'load1', $format ),
		$insert_count, "$file inserted $insert_count rows.");
	is( $pgc->{db}->query('select count(*) from load1')->array->[0] ,
		$insert_count,
		"confirm insert $insert_count rows" );
}

test_some_data ( 'test/load1.csv', 'csv', 11);
test_some_data ( 'test/load1.csv2', 'csv', 11);
test_some_data ( 'test/load1.tsv', 'text', 11);
note( 'testing a file with some bad lines');
test_some_data ( 'test/loadbad1.csv', 'csv', 11);

undef $pgc; # force close of error file.

my $err1 = path('/tmp/pgbulk.error')->slurp;
like( $err1, qr/this is a bad line/, "Evicted: this is a bad line ");
like( $err1, qr/another bad line/, "Evicted: another bad line ");

note( 'testing a file with too many errors');
$args{errorlimit} = 5;
my $pgc2 = Pg::BulkLoad->new(  %args );
$pgc2->{db}->query( 'truncate load1');
my $insertcount = 0;
dies_ok(
	sub {$pgc2->load( 'test/loadbad2.csv', 'load1', 'csv' )} ,
	'Set badrow errorlimit and file with too many, died!');
undef $pgc2;
my $err2 = path('/tmp/pgbulk.error')->slurp;
like( $err2, qr/gadfly/, "Evicted: bad line with word gadfly ");
like( $err2, qr/Exceeded Error limit with 5 Errors/, 
		"error file says it Exceeded Error limit with 5 Errors");


# $pgc->process( 't/loadbad1.csv', 'load1', 'csv');



# my $r = $pgc->{db}->query('select count(*) from load1')->array->[0];
# p $r;




done_testing();

=pod 

loopmax 12
loadq copy load1 from '/tmp/pgbulkcopywork.csv' with ( format 'csv' )
line 1 DBD::Pg::st execute failed: ERROR:  missing data for column "adate"
CONTEXT:  COPY load1, line 4: "this is a bad line" at /home/brainbuz/projects/Pg-BulkLoad/lib/Pg/BulkLoad.pm line 68.
