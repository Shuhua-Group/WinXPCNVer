#!/usr/bin/env perl
#
use File::Basename;
use Getopt::Long;
use Pod::Usage;

our vars($vst_1, $vst_2, $operation, $help);
GetOptions(
	"vst_1|1=s" => \$vst_1,
	"vst_2|2=s" => \$vst_2,
	"op|o=s"    => \$operation,
	"help|h"    => \$help,
)
	or pod2usage(-verbose => 0);
pod2usage(-verbose => 1) if (defined $help);
pod2usage(-verbose => 0) if ((! defined $vst_1) or (! defined $vst_2) or (! defined $operation));
if($operation =~ /(^a)|(^ad)|(^add)|(^\+$)/i){
	$operation = 'add';
}elsif($operation =~ /(^m)|(^mi)|(^min)|(^-$)/i){
	$operation = 'minus';
}else{
	pod2usage(-verbose => 0)
}

my ($vst_1_fn, $dir, $suffix_1) = fileparse($vst_1, ".txt");
my ($vst_2_fn, undef, $suffix_2) = fileparse($vst_2, ".txt");

my %probesetmap;
my @vst_prime;

open VST1,"<$vst_1";
open VST2,"<$vst_2";
while(($l1=<VST1>) and ($l2=<VST2>)){
	my @l1 = split /\s+/, $l1;
	my @l2 = split /\s+/, $l2;
	die("The probeset of the Vst files should be exactly the same!\nError Line: \n$vst_1:\n${l1}$vst_2:\n${l2}") if ($l1[0] ne $l2[0]);
	if(!exists $probesetmap{$l1[0]}){
		push @vst_prime, (join "\t",(@l1[0..3]));
		$probesetmap{$l1[0]} = $vst_prime[-1];
		my $vst_prime;
		if($operation eq 'add'){
			$vst_prime = $l1[4] + $l2[4];
		}elsif($operation eq 'minus'){
			$vst_prime = $l1[4] - $l2[4];
		}else{
			pod2usage(-verbose => 0);
		}
		$vst_prime[-1] .= sprintf ("\t%.5f\n", $vst_prime);
	}else{
		print "$l1[0] repeats!\n";
	}
}
close VST1;
close VST2;
my $vst_prime= $dir . "${vst_1_fn}.${vst_2_fn}.$operation.Vst_prime.txt";
open VP,">$vst_prime";
print VP @vst_prime;
close VP;
print "Congratulations! Calculate Vst_prime for $vst_1_fn $operation $vst_2_fn!\n";


__END__

=head1 NAME

Vst_prime_calculator - Calculate Vst_prime between two populations.

=head1 SYNOPSIS
	
Vst_prime_calculator.pl --vst_1 vst_1.txt --vst_2 vst_2.txt --op {a|add|m|minus|+|-} 

  Algorithm:  Vst_prime = vst_1 +/- vst_2
  
=head1 OPTIONS

Vst_prime_calculator.pl --vst_1 vst_1.txt --vst_2 vst_2.txt --op {a|add|m|minus|+|-}

=over 2

Arguments:

	--vst_1|-1 vst_1.txt	
		the first file of vst between two populations
	--vst_2|-2 vst_2.txt
		the second file of vst between two populations
	--op|-o {a|add|m|minus|+|-}	
		specify the operation to apply to the two vst files. only 'add', 'a', 'minus', 'm', '+', or '-' are allowed.

	Algorithm:  Vst_prime = vst_1 +/- vst_2 

Options:	

	--help|-h 
	  print this help document.

=back

=head1 DESCRIPTION

	Vst_prime_calculator.pl	

=head1 AUTHOR
	
	Any problems please contact:
	louhaiyi@picb.ac.cn
	furuiqing@picb.ac.cn
	xushuhua@picb.ac.cn

=head1 SEE ALSO

	TSD paper

=head1 COPYRIGHT

	

=cut			

