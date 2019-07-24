#!/bin/bash
# Tool to download specifc genomes from NCBI and to create
# a NCBI BLAST database with them for use with the Genome Cleaner
# Tool.
# Supported choices are:
#   bacteria - NCBI RefSeq complete bacterial/archaeal genomes
#   plasmids - NCBI RefSeq plasmid sequences
#   viruses - NCBI RefSeq complete viral DNA and RNA genomes
#   human - NCBI RefSeq GRCh38 human reference genome

set -u  # Protect against uninitialized vars.
set -e  # Stop on error

CONT_GENOME_DIR="$PWD/cont_genome"
NCBI_SERVER="ftp.ncbi.nih.gov"
FTP_SERVER="ftp://$NCBI_SERVER"
RSYNC_SERVER="rsync://$NCBI_SERVER"
THIS_DIR=$PWD

mkdir -p "$CONT_GENOME_DIR" # Create directory if it does no exist.

DB=$(whiptail --title "Genome Cleaner: Step 1" --checklist \
"Choose the contaminant databases to download" 30 78 15 \
"Adapters" "Adapters         " off \
"Archaea" "Archaea           " off \
"Bacteria" "Bacteria         " off \
"Fungi" "Fungi         " off \
"Human" "Human         " off \
"Protozoa" "Protozoa         " off \
"Plasmids" "Plasmids         " off \
"UniVec_Core" "UniVec_Core         " off \
"Viruses" "Viruses         " off 3>&1 1>&2 2>&3)

# echo "you chose $DB"
# exit

whiptail --textbox /dev/stdin 40 80 <<<"$(echo "You have chosen the following options: $DB")"

for dbname in $DB; 
do
whiptail --textbox /dev/stdin 40 80 <<<"$(echo "handling $dbname")"
	case "$dbname" in

	  \"Adapters\")
	    mkdir -p "$CONT_GENOME_DIR/Adapters"
	    cd "$CONT_GENOME_DIR/Adapters"
		echo "this section uses the included adapters.fasta file. Please feel free to add your own adapters to it"
	    ;;
	  \"Archaea\")
	    mkdir -p "$CONT_GENOME_DIR/Archaea"
	    cd "$CONT_GENOME_DIR/Archaea"
	    if [ ! -e ".downloaded" ]
	    then
	      whiptail --textbox /dev/stdin 40 80 <<<"$(wget --spider --no-remove-listing $FTP_SERVER/refseq/release/archaea/)"
	      files=($(grep genomic.fna.gz .listing | awk '{print $NF}'))
	      rm .listing
	       # For each of these files, download them and keep showing the progress
		for file in "${files[@]}"
		do
		wget --progress=dot "$FTP_SERVER/refseq/release/archaea/$file" 2>&1 |grep "%" | sed -u -e "s,\.,,g;s,\%,,g" | awk '{print $2}'; done | whiptail --title 'Downloading' --gauge 'file' 6 78 0
	      echo -n "Unpacking..."
	      gunzip *.genomic.fna.gz
	      echo " complete."
	      touch ".downloaded"
	    else
	      echo "Skipping download of archaeal genomes, already downloaded here."
	    fi
	    ;;
	  \"Bacteria\")
	    mkdir -p "$CONT_GENOME_DIR/Bacteria"
	    cd "$CONT_GENOME_DIR/Bacteria"
	    if [ ! -e ".downloaded" ]
	    then
	      wget $FTP_SERVER/refseq/release/bacteria/*.genomic.fna.gz
	      echo -n "Unpacking..."
	      gunzip *.genomic.fna.gz
	      echo " complete."
	      touch ".downloaded"
	    else
	      echo "Skipping download of bacterial genomes, already downloaded here."
	    fi
	    ;;
		\"Fungi\")
	    mkdir -p "$CONT_GENOME_DIR/Fungi"
	    cd "$CONT_GENOME_DIR/Fungi"
	    if [ ! -e ".downloaded" ]
	    then
		wget $FTP_SERVER/refseq/release/fungi/*.genomic.fna.gz
	      	echo -n "Unpacking..."
	      	gunzip *.genomic.fna.gz
	      	echo " complete."
	      	touch ".downloaded"
	    else
	      echo "Skipping download of fungal genomes, already downloaded here."
	    fi
	    ;;
	  \"Human\")
	    mkdir -p "$CONT_GENOME_DIR/Human"
	    cd "$CONT_GENOME_DIR/Human"
	    if [ ! -e ".downloaded" ]
	    then
	      # get list of CHR_* directories
	      wget --spider --no-remove-listing $FTP_SERVER/genomes/H_sapiens/
	      directories=$(perl -nle '/^d/ and /(CHR_\w+)\s*$/ and print $1' .listing)
	      rm .listing

	      # For each CHR_* directory, get GRCh* fasta gzip file name, d/l, unzip, and add
	      for directory in $directories
	      do
		wget --spider --no-remove-listing $FTP_SERVER/genomes/H_sapiens/$directory/
		file=$(perl -nle '/^-/ and /\b(hs_ref_GRCh\w+\.fa\.gz)\s*$/ and print $1' .listing)
		[ -z "$file" ] && exit 1
		rm .listing
		wget $FTP_SERVER/genomes/H_sapiens/$directory/$file
		gunzip "$file"
	      done
	      touch ".downloaded"
	    else
	      echo "Skipping download of human genome, already downloaded here."
	    fi
	    ;;		
	  \"Protozoa\")
	    mkdir -p "$CONT_GENOME_DIR/Protozoa"
	    cd "$CONT_GENOME_DIR/Protozoa"
	    if [ ! -e ".downloaded" ]
	    then
	      wget $FTP_SERVER/refseq/release/protozoa/*.genomic.fna.gz
	      echo -n "Unpacking..."
	      gunzip *.genomic.fna.gz
	      echo " complete."
	      touch ".downloaded"
	    else
	      echo "Skipping download of plasmids, already downloaded here."
	    fi
	    ;;
	  \"Plasmids\")
	    mkdir -p "$CONT_GENOME_DIR/Plasmids"
	    cd "$CONT_GENOME_DIR/Plasmids"
	    if [ ! -e ".downloaded" ]
	    then
	      wget $FTP_SERVER/refseq/release/plasmid/*.genomic.fna.gz
	      echo -n "Unpacking..."
	      gunzip *.genomic.fna.gz
	      echo " complete."
	      touch ".downloaded"
	    else
	      echo "Skipping download of plasmids, already downloaded here."
	    fi
	    ;;
	  \"UniVec_Core\")
	    mkdir -p "$CONT_GENOME_DIR/UniVec_Core"
	    cd "$CONT_GENOME_DIR/UniVec_Core"
	    if [ ! -e ".downloaded" ]
	    then
	      wget $FTP_SERVER/pub/UniVec/UniVec_Core
	      echo -n "no unpacking needed"
	      echo " complete."
	      touch ".downloaded"
	    else
	      echo "Skipping download of UniVec_Core sequences, already downloaded here."
	    fi
	    ;;
		\"Viruses\")
	    mkdir -p "$CONT_GENOME_DIR/Viruses"
	    cd "$CONT_GENOME_DIR/Viruses"
	    if [ ! -e ".downloaded" ]
	    then
	      wget $FTP_SERVER/refseq/release/viral/*.genomic.fna.gz
	      echo -n "Unpacking..."
	      gunzip *.genomic.fna.gz
	      echo " complete."
	      touch ".downloaded"
	    else
	      echo "Skipping download of viral genomes, already downloaded here."
	    fi
	    ;;
	  *)
	    echo "Unsupported library.  Valid options are: "
	    echo "bacteria plasmids virus human"
	    ;;
	esac
done
