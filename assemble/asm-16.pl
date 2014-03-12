#!/usr/bin/perl

# 16-bit endianless assembler

use warnings;
use strict;


# This program takes a file containing endianless assembly as its
# first argument, and outputs on stdout an assembled version of the code.

# This assembler is not meant to demonstrate proper programming practice.
# Variables have badly chosen names and the code is badly documented.
# If I had time, I'd make this code cleaner, but it works as is.

# This code does some operations twice over the input file that could be
# avoided with some more complicated algorithms and data structures.

my $infile;
my %vars; #vars and addys
my %locs; # locs and their addys
my $addy = 0; # current address in the file

$infile = $ARGV[0];



open INF, $infile or die $!;

# first pass, we search for all variables and locations
# for each variable, we store their name as a key in %vars, and the address
# as the value in the hash


while (<INF>) {
    s/;.*//;  #ignore comments
    next if /^(\s)*$/; #skip blank lines
    
     
    s/^(\s)*//;
    if (/(.+):/) {
        die "duplicate loc '$1'" if $locs{$addy};
        $locs{$1} = $addy;
    }
    if (/(\w+)(\s+)DB/) {
        die "duplicate var '$1'" if $vars{$addy};
        $vars{$1} = $addy;
        $addy++;
    }

    if (/(NAND|ADD|ST|JNC)(\s+)(\w+)/){
        $addy++;
    }
}

$addy = 0;
my $stra;

close INF;
open INF, $infile or die $!;

while (<INF>) {
    my $oline = $_;
    my $goodline = 0;
    my $opcode;
    s/;.*//;  #ignore comments
    next if /^(\s)*$/; #skip blank lines
    chomp;          #remove newlines
    s/^(\s)*//;
    if (/(NAND|ADD|ST)(\s+)(\w+)/){
       my $addr = $vars{ $3 };
       die "bad var '$3'" if !exists($vars{$3});
       if ($1 eq "NAND"){
           $opcode = $addr;
       }
       if ($1 eq "ADD"){
           $opcode = 16384 + $addr;
       }
       if ($1 eq "ST"){
           $opcode = 32768 + $addr;
       }
       $goodline = 1;
   }


   if (/(JNC)(\s+)(\w+)/){
       die "bad loc '$3'" if !exists($locs{$3});
       my $l = $locs { $3};
       $opcode = 49152 + $l;
       $goodline = 1;
   }

   $stra = sprintf("%x", $addy);

   if(length($stra) == 1){
       $stra = "0" . $stra;
   }

   if (/(.+):/) {
        print "  ; ", uc($stra) . " " . $oline;
        next
    }

    if (/(\w+)(\s+)DB(\s+)(\w+)/) {
        my $val=$4;
        if(length($val) == 1){
            $val = "000" . $val;
        }
        if(length($val) == 2){
            $val = "00" . $val;
        }
        if(length($val) == 3){
            $val = "0" . $val;
        }

        print $val . "; ", uc($stra) . " " . $oline;
        $addy ++;
        next
    }


    if ($goodline == 0){
       next
   }
   $addy++;
   $opcode = sprintf("%x", $opcode);
   
   if(length($opcode) eq 3){
       $opcode = "0" . $opcode;
   }
   if(length($opcode) eq 2){
       $opcode = "00" . $opcode;
   }
   if(length($opcode) eq 1){
       $opcode = "000" . $opcode;
   }


   print uc($opcode) . ";" . " " . uc($stra) . " " . $oline;

   $goodline = 0;
}
#$addy--;
#print "00\n" x (63 - $addy);

