#!/bin/bash

latex main.tex
bibtex main
latex main.tex
latex main.tex
dvips main.dvi
ps2pdf main.ps
open main.pdf