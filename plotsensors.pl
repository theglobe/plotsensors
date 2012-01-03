#!/usr/bin/perl

use strict;

my $PLOT = plotSetUp();
my @valuesTempCPU;
my @valuesTempSIO;
my @valuesTempAmbient;
my @valuesRpm;
my @valuesTempGPU;


while (1) {
    my @sensors = `sensors` or die "Could not run sensors.\n";
    
    foreach (@sensors) {
	if ($_ =~ /temp1:\s+[+-]?(\d+\.?\d+)/) {
#	    print $1."\n";
	    push @valuesTempCPU, $1;
	}
	elsif ($_ =~ /fan1:\s+[+-]?(\d+\.?\d+)/) {
	    push @valuesRpm, $1;
	}
	elsif ($_ =~ /SIO Temp:\s+[+-]?(\d+\.?\d+)/) {
	    push @valuesTempSIO, $1;
	}
	elsif ($_ =~ /temp3:\s+[+-]?(\d+\.?\d+)/) {
	    push @valuesTempAmbient, $1;
	}

    }

    my @nvQuery = `nvidia-settings -q gpucoretemp`;
    foreach (@nvQuery) {
	if ($_ =~ /Attribute 'GPUCoreTemp' \(.*\): (\d+)/) {
	    push @valuesTempGPU, $1;
	}
    }

    no_plot($PLOT, \@valuesTempCPU,\@valuesTempSIO,\@valuesTempAmbient,
	 \@valuesRpm,\@valuesTempGPU);
    @valuesTempCPU=();
    @valuesTempSIO=();
    @valuesTempAmbient=();
    @valuesRpm=();
    @valuesTempGPU=();
    sleep(1);
}

use strict;
sub plotSetUp {
    my $geometry = "1000x500";

    open(my $PLOT, "|gnuplot -geometry $geometry") or die "Could not run gnuplot.\n";
    #open(my $PLOT, ">-");
    print $PLOT "set ytics nomirror\n";
    print $PLOT "set y2tics nomirror\n";
    return $PLOT;
}

sub plot {
    my $PLOT          = @_[0];
    my @valuesCpu     = @{@_[1]};
    my @valuesRpm     = @{@_[4]};
    my @valuesSio     = @{@_[2]};
    my @valuesAmbient = @{@_[3]};
    my @valuesGpu     = @{@_[5]};


#    print join(" ",@valuesRpm)."\n";

# Don't plot if too few values
    if (scalar(@valuesCpu) < 2) {return;}

    print  $PLOT "plot '-' title 'CPU temp' with lines axis x1y1,'-' title 'Fan RPM' with lines axis x1y2,'-' title 'SIO temp' with lines axis x1y1,'-' title 'Ambient temp' with lines axis x1y1,'-' title 'GPU temp' with lines axis x1y1\n";

    foreach (@valuesCpu) {
	    print $PLOT $_."\n";
	}
    print $PLOT "e\n";

    foreach (@valuesRpm) {
	    print $PLOT $_."\n";
	}
    print $PLOT "e\n";
        foreach (@valuesSio) {
	    print $PLOT $_."\n";
	}
    print $PLOT "e\n";

     foreach (@valuesAmbient) {
	    print $PLOT $_."\n";
	}
    print $PLOT "e\n";

    foreach (@valuesGpu) {
	    print $PLOT $_."\n";
    }
    print $PLOT "e\n";
}

sub no_plot {
    my $PLOT          = @_[0];
    my @valuesCpu     = @{@_[1]};
    my @valuesRpm     = @{@_[4]};
    my @valuesSio     = @{@_[2]};
    my @valuesAmbient = @{@_[3]};
    my @valuesGpu     = @{@_[5]};
    my $time  = time();

    print "$time @valuesCpu @valuesRpm @valuesSio @valuesAmbient @valuesGpu\n";

}
