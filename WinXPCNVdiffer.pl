#!/usr/bin/env perl

#use strict;
use File::Basename;
use Getopt::Long;
use Pod::Usage;

our vars($vst_prime, $winsize, $prb_cri, $prb_top, $overlap, $help);
GetOptions(
	"vst_prime|v=s" => \$vst_prime,
	"winsize:1000" => \$winsize,
	"prb_cri:3"    => \$prb_cri,
	"prb_top:3"    => \$prb_top,
	"overlap:f"    => \$overlap,
	"help|h"       => \$help,
)
	or pod2usage(-verbose => 0);
pod2usage(-verbose => 1) if (defined $help);
pod2usage(-verbose => 0) if (! defined $vst_prime);
$winsize = 1000 if (! defined $winsize);
$prb_cri = 3 if (! defined $prb_cri);
$prb_top = 3 if (! defined $prb_top);
if(defined $overlap){
	if($overlap < 1){
		print "$overlap\n";
		$overlap = sprintf ("%.0f",$winsize * $overlap);
	}else{
		$overlap = sprintf ("%.0f",$overlap);
	}
}else{
	$overlap = 0;
}
my $step = $winsize  - $overlap;
my($vst_prime_fn, $dir, $suffix) = fileparse($vst_prime, ".txt");

my @probeset;
my %vst_prime;
my %chroms;
open VSTP,"<$vst_prime";
while($line = <VSTP>){
	$line =~ s/\schr/\s/i;
	my @line = split /\s+/, $line;
	next if($line[1] =~ /x|y|(mt)|(23)|(24)/i);	# ignore sex-chromosomes
	if($line[1] < ${$vst_prime{$probeset[-1]}}[1] or (($line[1] == ${$vst_prime{$probeset[-1]}}[1]) and ($line[2] < ${$vst_prime{$probeset[-1]}}[2]))){
		die("Sort the vst_prime file by chromosomes and then positions!\n")
	}
	if(!exists $vst_prime{$line[0]}){
		push @probeset, $line[0];
		$vst_prime{$line[0]} = [@line];
		$chroms{$line[1]} = $line[1] if (!exists $chroms{$line[1]});
	}else{
		print "Repeatative id $line[0]\n";
	}
}
close VSTP;

my @win_prb_results;
for $chr (sort {$a<=>$b} keys %chroms){
	my (@chr_probeset, @chr_position, @chr_vst_prime);
	my $i_cont = 0;
	for $i ($i_cont..$#probeset){
		next if ${$vst_prime{$probeset[$i]}}[1] < $chr;
		last if ${$vst_prime{$probeset[$i]}}[1] > $chr;
		push @chr_probeset, $probeset[$i];
		push @chr_position, ${$vst_prime{$probeset[$i]}}[2];
		push @chr_vst_prime, ${$vst_prime{$probeset[$i]}}[4];
		$i_cont = $i;
	}
	for($p = 1;($p+$winsize-$chr_position[-1])<$step;$p += $step){
		my ($start, $end) = (0,0);
		$start++ until(($start<@chr_position) && ($chr_position[$start]>=$p));
		$end++ while(($end<@chr_position) && ($chr_position[$end]<=($p+$winsize)));
		$end -= 1;
		if(($end-$start) + 1 >= $prb_cri){
			my @sort_vst_prime = sort {$b <=> $a} @chr_vst_prime[$start..$end];
			push @win_prb_results, "chr$chr\t$chr_position[$start]";
			$win_prb_results[-1] .= "\t$chr_position[$end]\t";
			$win_prb_results[-1] .= (($end-$start)+1);
			$win_prb_results[-1] .= sprintf "\t%.2f\t%.4f\t", &mean(@sort_vst_prime[0..($prb_top-1)]), &sd(@sort_vst_prime[0..($prb_top-1)]);
			$win_prb_results[-1] .= (join ',', (@chr_probeset[$start..$end]));
			$win_prb_results[-1] .= "\n";
		}
	}
}

my $win_prb_output = $dir . $vst_prime_fn . ".VstW.win${winsize}.${prb_cri}prb.top${prb_top}.txt";
open WIN,">$win_prb_output";
print WIN "chr\tstart\tend\tprobe_num\tmean\tsd\tprobesets\n";
print WIN @win_prb_results;
close WIN;
print "Congratulations! Go to check your results!\n";


sub mean{
	my $num = @_;
	my $sum = 0;
	$sum += $_ for (@_);
	return $sum/$num;
}

sub sd{
	my $num = @_;
	return 0 if $num == 1;
	my $mean = &mean(@_);
	my $square_sum = 0;
	$square_sum += ($_ - $mean) * ($_ - $mean) foreach (@_);
	return sqrt ($square_sum/($num-1));
}


__END__


=head1 NAME

WinXPCNVdiffer - Window based cross populations vst scanning method.

=head1 SYNOPSIS
	
WinXPCNVdiffer.pl --vst_prime vst_prime.txt [ --winsize 1000 --prb_cri 3 --prb_top 3 --overlap 0 ]

=head1 OPTIONS

WinXPCNVdiffer.pl --vst_prime vst_prime.txt [ options ]

=over 2

Arguments:

	--vst_prime|-v vst_prime.txt
		the vst_prime results (could be the results of 'Vst_prime_3pop.pl', or 'calcVst.pl')

Options:	

	--winsize integer
	  size of the sliding window, in basepair, 1000 as default.
	--prb_cri integer
	  a window includes probes beyond(>=) the number of prb_cri should be taken into consideration, 3 as default.
	--prb_top integer
	  give the number of the top values in a window to calculate the Vst-w statistics, 3 as default.
	--overlap number  
	  give the overlap of sliding windows, could be less than 1 (means proportion of the winsize) or be an integer (means in basepairs), automatically detected. 0 as default.
	--help|-h 
	  print this help document.

=back

=head1 DESCRIPTION

	WinXPCNVdiffer 

=head1 AUTHOR
	
	Any problems please contact:
	louhaiyi@picb.ac.cn
	furuiqing@picb.ac.cn
	xushuhua@picb.ac.cn

=head1 SEE ALSO

	TSD paper

=head1 COPYRIGHT

	

=cut			

