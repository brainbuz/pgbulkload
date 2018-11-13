use 5.028;
package Pg::BulkCopy;
use feature qw/signatures postderef/;
no warnings qw/experimental uninitialized/;
use Mojo::Pg;
use Try::Tiny;
use Path::Tiny;
use File::Copy;
use Data::Printer;

sub new ( $Class, %args ) {
	for my $required ( qw/ dbname dbhost dbuser dbpass errorfile/ ) {
		unless ( $args{$required }) {
			die "missing mandatory argument $required";
		}
	}
	my $I = \%args;

	my $pg  = Mojo::Pg->new();
	my $dsn 
	    = 'DBI:Pg:dbname='
	    . $I->{dbname}
	    . ';host='
	    . $I->{dbhost};
	$pg->dsn($dsn);
	$pg->username( $I->{dbuser} );
	$pg->password( $I->{dbpass} );
	$I->{db} = $pg->db;
	$I->{pg} = $pg;
	$I->{errcount} = 0;
	open( $I->{errors}, '>', $args{errorfile});
	bless $I;
	return $I;
}

sub error ( $I, $msg, $row ) {
	$I->{errcount}++;
	my $ERR = $I->{errors};
	say $ERR $msg;
	say $ERR $row;
	if ( defined $I->{errorlimit}) {
		if ( $I->{errcount} >= $I->{errorlimit}) {
			say $ERR  "Exceeded Errror limit with $I->{errcount} Errors";
			die "Exceeded Errror limit with $I->{errcount} Errors";
		}
	}
}

sub evict {
	return "just a place holder for the sub to remove a bad record";
}

sub load ( $I, $workfile, $table, $format ) {
	# `wc -l $workfile` =~ m/(\d+)/;
	# my $loopmax = $1 ;
	my @data = path($workfile)->lines;
	my $loopmax = scalar(@data);
	my $loopcnt = 0;
say "loopmax $loopmax";
	my $loadq = undef;
	if ( $format eq 'csv') {
		$loadq = "copy $table from '$workfile' with ( format 'csv' )";
	} else {
		$loadq = "copy $table from '$workfile' with ( format 'txt', null '' )";		
	}
say "loadq $loadq"	;
	LOADLOOP: while ( $loopcnt < $loopmax ) {
		$loopcnt++;
		try { 
			$I->{db}->query( $loadq );
			$loopmax = 0; # break free of loop on success.
		} catch { 
say $_ ;
			$_ =~ m/\, line (\d+)?:/;
			my $badline = $1 -1 ; # array offset 0
			$I->error( "Evicting Record $badline : $_", $data[$badline] );
			splice (@data, $badline, 1);
			path($workfile)->spew(@data);
		};
 
	}
	return scalar( @data );
	
}

sub process ( $I, $file, $table, $format ) {
	# copy the file to /tmp so postgres can access it and 
	# eviction doesn't alter original data.
	my $workfile = "/tmp/pgbulkcopywork.$format";
 	copy( $file, $workfile) or die "Copy failed: $!";

}


1;

=pod

copy load1 from '/home/brainbuz/projects/Pg-BulkCopy/t/load1.tsv' 
with ( format 'text', NULL '');
copy load1 from '/home/brainbuz/projects/Pg-BulkCopy/t/load1.csv' with ( format 'csv' );


copy load1 to '/tmp/load1.csv2' with (format 'csv' , force_quote( 'string' ) );
copy load1 to '/tmp/load1.tsv' with (format text, NULL '');
copy load1 to '/tmp/load1.csv' with (format 'csv');
