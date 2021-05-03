# Some header info

# Snakmake specific ---------------------------------------------------
# @Usage: snakemake :w

# Dry run: snakemake -n
# Generate DAG


# Library -------------------------------------------------------------
import sys
import os
import json
import csv
import pandas as pd
import numpy as np
import matplotlib as plt

# Required software ---------------------------------------------------
BASEDIR="/home/aglucaci"
#HYPHYMP = "../hyphy-develop/HYPHYMP"
HYPHYMP = BASEDIR + "/hyphy-develop/hyphy"
#HYPHYMPI = "../hyphy-develop/HYPHYMPI"
LIBPATH = BASEDIR + "/hyphy-develop/res"
PRE = BASEDIR + "/hyphy-analyses/codon-msa/pre-msa.bf"
POST = BASEDIR + "/hyphy-analyses/codon-msa/post-msa.bf"
MAFFT = "/usr/bin/mafft"
PYTHON = "/usr/bin/python3"
ALN_PROFILER = BASEDIR + "/SNAKEMAKE_Tests/AlignmentProfiler.py"

# Declares ------------------------------------------------------------
NONE=0

# Rule All ------------------------------------------------------------
# This is the target, meaning the FINAL file I want.
# anythng in this list, needs to be created and 
# snakemake will work backwards to figure out
# how to make it.
rule all: 
    input:
        "data/BDNF_codon_aligned.fasta",
        "data/aln_stats.txt"

# Rules ---------------------------------------------------------------
rule pre_msa:
  input:
    in_fas = "data/BDNF_codons.fasta",
  output:
    out_prot = "data/BDNF_codons.fasta_protein.fas",
    out_nuc = "data/BDNF_codons.fasta_nuc.fas"
  shell:
    "{HYPHYMP} LIBPATH={LIBPATH} {PRE} --input {input.in_fas}"
# end rule -- pre_msa

rule mafft_align:
  input:
    in_prot = rules.pre_msa.output.out_prot 
  output:
    out_prot = "data/BDNF_codons.fasta_protein.fas.msa"
  shell:
    #"mafft --auto --quiet {input.in_prot} > {output.out_prot} 2> mafft_errors.log"
    "{MAFFT} --auto --quiet {input.in_prot} > {output.out_prot} 2> mafft_errors.log"
#end rule -- mafft_align

rule post_mafft:
  input:
    in_prot = rules.mafft_align.output.out_prot,
    in_nuc = rules.pre_msa.output.out_nuc
  output:
    out_compressed = "data/BDNF_codon_aligned.fasta",
    duplicates = "data/BDNF_codon_aligned.fasta.duplicates.json"
  shell:
    "{HYPHYMP} LIBPATH={LIBPATH} {POST} --protein-msa {input.in_prot} --nucleotide-sequences {input.in_nuc} --compressed Yes --duplicates {output.duplicates} --output {output.out_compressed}"
#end rule -- post_mafft

rule aln_stats:
   input:
      in_aln = rules.post_mafft.output.out_compressed
   output:
      out_stats_text = "data/aln_stats.txt"
      #out_stats_images = ""
   shell:
      #"{PYTHON} AlignmentProfiler.py {input.in_aln}"
      "{PYTHON} {ALN_PROFILER} {input.in_aln}"
#end rule -- aln_stats








# END OF FILE ---------------------------------------------------------

