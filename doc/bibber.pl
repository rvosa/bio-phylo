#!/usr/bin/perl
use strict;
use warnings;

# the general idea is that we might need to pre-process our pod document a little bit:
# - change comment prefix from '#' to '%'
# - change embedded citations from [foo] to \cite{foo}
# ...it remains to be seen whether this is a sensible approach...

while(<>) {
	s/\[(.+?)\]/\\cite{$1}/g;
	s/#/%/g;
	print;
}