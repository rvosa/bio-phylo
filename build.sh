# this is NOT part of the distribution, or in any way of interest
# other than on the nexml webserver. It builds a CPAN compatible
# distribution out of the source tree, places that in the downloads
# folder, then cleans up after itself. That's all.
DOWNLOADS=../downloads
if [ "$PODINHERIT" == "" ]; then
    echo "Not appending recursive pod because PODINHERIT env var not set"
fi
if [ "$PODINHERIT" != "" ]; then
    ./podinherit -dir lib -append -verbose -force
fi
perl Makefile.PL > /dev/null
make manifest &> /dev/null
make dist > /dev/null
make clean > /dev/null
if [ -d "$DOWNLOADS" ]; then
    mv Bio-Phylo*.tar.gz ../downloads
fi
if [ "$PODINHERIT" != "" ]; then
    ./podinherit -dir lib -strip -verbose -force
fi
rm Makefile.old MANIFEST.bak MANIFEST META.yml
