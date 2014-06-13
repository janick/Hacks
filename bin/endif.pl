eval 'exec perl -S $0 ${1+"$@"}'
                 if 0;                                                          


# Finds mismatched `ifdef/`ifndef in SystemVerilog files.
# Defeat this script by using multi-line Verilog comments!
#
# Original author: Janick Bergeron <janick@bergeron.com>, Jan 2013
#
# This software is provided as-is and is not officially supported
#

use File::Find;

my $debug = 0;

sub usage {

    print STDERR <<USAGE;
Usage: $0

Finds mismatched `ifdef/`ifndef in SystemVerilog (*.sv) files found in the current directory and below

Options:
	-h        Print this message
USAGE

   exit 1;
}

require "getopts.pl";
&Getopts("D:h");

&usage if $opt_h || $#ARGV != -1;

sub findsub {
    return unless ( -f and -r );   # only a proper readable "file"
    if ( $_ =~ /\.sv*$/ ) {         # only files ending in "*.sv"
        open( SV, "<$_" ) or die "Can't open file $_ : $!\n";
        print "Searching file \"$_\"\n" if $debug;
        my $file = $File::Find::name;
        my @defs = ();
        while (<SV>) {
   	    s|//.*$||;
            if (m/`(ifdef|ifndef)\s/) {
                push( @defs, $. );
            }
            if (m/`endif/) {
                my $line = pop(@defs);
                if ( !defined($line) ) {
                    print "Unbalanced `endif on line $. of file \"$file\"\n";
                }
                else {
                    print "Matched pair:  $file: $line to $.\n" if $debug;
                }
            }
            if (m/`(else|elsif)/) {
                my $line = pop(@defs);
                if ( !defined($line) ) {
                    print "Unbalanced `else/elsif on line $. of file \"$file\"\n";
                }
                else {
                    print "Matched pair:  $file: $line to $.\n" if $debug;
                }
                push( @defs, $. );
            }
        }
        foreach my $line (@defs) {
            print "Unbalanced `if(n)def on line $line of file \"$file\"\n";
        }
        close SV;
    }
}

find( \&findsub, '.' );
exit 0;
