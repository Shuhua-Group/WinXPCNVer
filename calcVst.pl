#!/usr/bin/env perl
#
#use strict;
use File::Basename;
use Getopt::Long;
use Pod::Usage;

our vars($tpop_lsum, $rpop_lsum, $help);
GetOptions(
	"tpop_lsum|t=s" => \$tpop_lsum,
	"rpop_lsum|r=s" => \$rpop_lsum,
	"help|h"        => \$help,
)
	or pod2usage(-verbose => 0);
pod2usage(-verbose => 1) if(defined $help);
pod2usage(-verbose => 0) if ((! defined $tpop_lsum) or (! defined $rpop_lsum));

my ($tpop_fn, $dir, $t_suffix) = fileparse($tpop_lsum, ".locus_summary");
my ($rpop_fn, undef, $r_suffix) = fileparse($rpop_lsum, ".locus_summary");
die("Please give the '.locus_summary' suffixed-file directly!\n") if (($t_suffix ne qw/.locus_summary/) or ($r_suffix ne qw/.locus_summary/));

open RLSUM,"<$rpop_lsum";
my $anno_line;
while(($anno_line = <RLSUM>) =~ /^#+/){}
my @header = split /\s+/, $anno_line;
my $rpop_size = @header - 4;
my @rpop_sampleid = @header[4..$#header];
open TLSUM,"<$tpop_lsum";
my $anno_line;
while(($anno_line = <TLSUM>) =~ /^#+/){}
my @header = split /\s+/, $anno_line;
my $tpop_size = @header - 4;
my @tpop_sampleid = @header[4..$#header];

my @probeset;
my %probesetmap;
my @Vst;

while(($rline = <RLSUM>) and ($tline = <TLSUM>)){
	my @rline = split /\s+/, $rline;
	my @tline = split /\s+/, $tline;
	die("The probeset of the two summary files should be exactly the same!\n Erorr Line: \n$rpop_lsum:\n${rline}$tpop_lsum:\n${tline}\n") if ($rline[0] ne $tline[0]);
	next if($rline[1] =~ /x|y|(mt)|(23)|(24)/i);	# ignore sex-chromosomes
	push @probeset, $rline[0];
	if(!exists $probesetmap{$rline[0]}){
		$probesetmap{$rline[0]} = (join "\t", (@rline[0..3]));
		push @Vst, (shift @rline);
		$Vst[-1] .= ("\t" . (shift @rline)) for (1..3);
		shift @tline for (0..3);
		my @prob2inten = (@rline,@tline);
		my $Vt_r_t = &variance(@prob2inten);
		my $Vs_r = &variance(@rline);
		my $Vs_t = &variance(@tline);
		my $Vs_r_t = ($Vs_r * ($rpop_size/($rpop_size + $tpop_size))) + ($Vs_t * ($tpop_size/($rpop_size + $tpop_size)));
		my $Vst_r_t = ($Vt_r_t - $Vs_r_t)/$Vt_r_t;
		$Vst[-1] .= sprintf ("\t%.5f\n", $Vst_r_t);
	}else{
		print "$rline[0] repeats!\n";
		pop @probeset;
	}
}
close RLSUM;
close TLSUM;

my $Vst_file = $dir . "${tpop_fn}_${rpop_fn}.Vst.txt";
open VST,">$Vst_file";
print VST @Vst;
close VST;
print "Calculate Vst for $tpop_fn and $rpop_fn\n";



sub mean{
	my $num = @_;
	my $sum = 0;
	$sum += $_ for (@_);
	return $sum/$num;
}

sub variance{								#estimation of variance, by (n-1)
	my $num = @_;
	my $mean = &mean(@_);
	my $square_sum = 0;
	$square_sum += (($_ - $mean) * ($_ - $mean)) for (@_);
	return $square_sum/($num - 1);
}



__END__

=head1 NAME

calcVst - Calculate Vst between two populations.

=head1 SYNOPSIS
	
calcVst.pl --tpop_lsum test.pop.locus_summary --rpop_lsum ref.pop.locus_summary 

=head1 OPTIONS

calcVst.pl --tpop_lsum test.pop.locus_summary --rpop_lsum ref.pop.locus_summary 

=over 2

Arguments:

	--tpop_lsum|-t test.pop.locus_summary 
		the locus_summary of the test population
	--rpop_lsum|-r reference.pop.locus_summary
		the locus_summary of the reference population

	Frankly, the order is not so important. :) 

Options:	

	--help|-h 
	  print this help document.

=back

=head1 DESCRIPTION

	calcVst.pl	

=head1 AUTHOR
	
	Any problems please contact:
	louhaiyi@picb.ac.cn
	furuiqing@picb.ac.cn
	xushuhua@picb.ac.cn

=head1 SEE ALSO

	TSD paper

=head1 COPYRIGHT

	

=cut			
