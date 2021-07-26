#!/usr/bin/env perl
#
use File::Basename;
use Getopt::Long;
use Pod::Usage;

our vars($vst_1, $vst_2, $vst_3, $help);
GetOptions(
	"vst_1|1=s" => \$vst_1,
	"vst_2|2=s" => \$vst_2,
	"vst_3|3=s" => \$vst_3,
	"help|h"    => \$help,
)
	or pod2usage(-verbose => 0);
pod2usage(-verbose => 1) if (defined $help);
pod2usage(-verbose => 0) if ((! defined $vst_1) or (! defined $vst_2) or (! defined $vst_3));

my ($vst_1_fn, $dir, $suffix_1) = fileparse($vst_1, ".txt");
my ($vst_2_fn, undef, $suffix_2) = fileparse($vst_2, ".txt");
my ($vst_3_fn, undef, $suffix_3) = fileparse($vst_3, ".txt");

my %probesetmap;
my @vst_prime;

open VST1,"<$vst_1";
open VST2,"<$vst_2";
open VST3,"<$vst_3";
while(($l1=<VST1>) and ($l2=<VST2>) and ($l3=<VST3>)){
	my @l1 = split /\s+/, $l1;
	my @l2 = split /\s+/, $l2;
	my @l3 = split /\s+/, $l3;
	die("The probeset of the three Vst files should be exactly the same!\nError Line: \n$vst_1:\n${l1}$vst_2:\n${l2}$vst_3:\n${l3}\n") if (($l1[0] ne $l2[0]) or ($l1[0] ne $l3[0]));
	if(!exists $probesetmap{$l1[0]}){
		push @vst_prime, (join "\t",(@l1[0..3]));
		$probesetmap{$l1[0]} = $vst_prime[-1];
		my $vst_prime= $l1[4] + $l2[4] - $l3[4];
		$vst_prime[-1] .= sprintf ("\t%.5f\n", $vst_prime);
	}else{
		print "$l1[0] repeats!\n";
	}
}
close VST1;
close VST2;
close VST3;

my $vst_prime= $dir . "${vst_1_fn}.${vst_2_fn}.${vst_3_fn}.vst_prime.txt";
open VP,">$vst_prime";
print VP @vst_prime;
close VP;
print "Congratulations! Calculate Vst_prime for $vst_1_fn, $vst_2_fn, and $vst_3_fn!\n";


__END__

=head1 NAME

Vst_prime_3pop - Calculate Vst_prime among three populations.

=head1 SYNOPSIS
	
Vst_prime_3pop.pl --vst_1 rpop_t1pop.vst.txt --vst_2 rpop_t2pop.vst.txt --vst_3 t1pop_t2pop.vst.txt

  Algorithm:  Vst_prime = Vst_r_t1 + Vst_r_t2 - Vst_t1_t2
  
=head1 OPTIONS

Vst_prime_3pop.pl --vst_1 rpop_t1pop.vst.txt --vst_2 rpop_t2pop.vst.txt --vst_3 t1pop_t2pop.vst.txt

=over 2

Arguments:

	--vst_1|-1 rpop_t1pop.vst.txt	
		the vst between ref population and test1 population (namely, batch.1)
	--vst_2|-2 rpop_t2pop.vst.txt	
		the vst between ref population and test2 population (namely, batch.2)
	--vst_3|-3 t1pop_t2pop.vst.txt	
		the vst between test1 population (namely, batch.1) and test2 population (namely, batch.2)

	Algorithm:  Vst_prime = Vst_r_t1 + Vst_r_t2 - Vst_t1_t2

Options:	

	--help|-h 
	  print this help document.

=back

=head1 DESCRIPTION

	Vst_prime_3pop.pl	

=head1 AUTHOR
	
	Any problems please contact:
	louhaiyi@picb.ac.cn
	furuiqing@picb.ac.cn
	xushuhua@picb.ac.cn

=head1 SEE ALSO

	TSD paper

=head1 COPYRIGHT

	

=cut			
