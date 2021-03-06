#!/bin/bash

# Process Input
# ==============================================================================

# Help function
show_help() {
   echo "Runs rrems pipeline with the following options:"
   echo "trim-galore --rrbs --fastqc (--paired if two files provided)"
   echo "bismark --quiet --bowtie2 --un --ambiguous"
   echo "bismark_methylation_extractor (--paired-end if two files provided)"
   echo
   echo "Uses CpG context output from bismark_methylation_extractor to get"
   echo "percent methylation for each CpG (combined top and bottom strands)."
   echo
   echo "Requires a forward read fastq file and a reverse read fastq file if"
   echo "paired end or a single fastqfile if single end."
   echo
   echo "Outputs a .cov file and a .bed file."
   echo
   echo "Required:"
   echo "-n    Sample name."
   echo "-r    Reference directory."
   echo "Optional"
   echo "-c    Number of cores (default 1)"
   echo "-h    Print this help."
   echo
}

# Set variables
name=
ref=
cores=1

# Process options
OPTIND=1
while getopts "hn:o:r:b:c:" option; do
    case $option in
        h) # display Help
            show_help
            exit;;
        n) # Name of sample
            name=$OPTARG;;
        r) # reference directory
            ref=$OPTARG;;
        c) # cores
            cores=$OPTARG;;
        \?) # Invalid option
            echo "Error: Invalid option"
            exit 1;;
   esac
done
shift $(( OPTIND-1 ))

# main input
r1=$1
r3=$2
to=`dirname $r1`

# Check input
if [[ -z $r1 ]]; then
    echo "Error: parameter 1 is missing, need forward reads"
    exit 1
fi
if [[ -z $r3 ]]; then
    echo "Warning: parameter 2 is missing, single end reads assumed"
fi
if [[ -z $name ]]; then
    echo "Error: name is missing, need -n value"
    exit 1
fi
if [[ -z $ref ]]; then
    echo "Error: reference directory is missing, need -r value"
    exit 1
fi




# Pipeline
# ==============================================================================

###   Trim Adapters   ###
echo "====================================================="
echo "TRIMMING ADAPTERS FOR " $name
echo "====================================================="
if [[ -z $r3 ]]; then
    # Single
    trim_galore --output_dir $to --cores $((cores<4 ? 1 : 4)) --rrbs --fastqc \
    "$r1"
else
    # Paired
    trim_galore --output_dir $to --cores $((cores<4 ? 1 : 4)) --rrbs --fastqc \
        --paired "$r1" "$r3"
fi

# Clean up output
if [[ -z $r3 ]]; then
    # Single
    mv "${r1%.fastq}"_trimmed.fq "$r1" &
    mv "${r1%.fastq}"_trimmed_fastqc.html "$r1"_fastqc_report.html &
    rm "${r1%.fastq}"_trimmed_fastqc.zip &
    wait
else
    # Paired
    mv "${r1%.fastq}"_val_1.fq "$r1" &
    mv "${r3%.fastq}"_val_2.fq "$r3" &
    mv "${r1%.fastq}"_val_1_fastqc.html "$r1"_fastqc_report.html &
    mv "${r3%.fastq}"_val_2_fastqc.html "$r3"_fastqc_report.html &
    rm "${r1%.fastq}"_val_1_fastqc.zip "${r3%.fastq}"_val_2_fastqc.zip &
    wait
fi


###   Align Reads   ###
echo "====================================================="
echo "ALIGNING READS FOR " $name
echo "====================================================="
echo ""
if [[ -z $r3 ]]; then
    # Single
    bismark --quiet --output $to --parallel $cores --bowtie2 --un --ambiguous \
        -N 1 --temp_dir TempDelme --non_bs_mm --genome_folder "$ref" "$r1"
else
    # Paired
    bismark --quiet --output $to --parallel $cores --bowtie2 --un --ambiguous \
        -N 1 --temp_dir TempDelme --non_bs_mm --genome_folder "$ref"  \
        -1 "$r1" -2 "$r3"
fi

# Clean up output
mv "${r1%.fastq}"_bismark_bt2_*_report.txt "$to/$name".bam_bismark_report.txt
mv "${r1%.fastq}"_bismark_bt2*.bam "$to/$name".bam
rm -r TempDelme

# Compress clean data
gzip "$r1" &
if ! [[ -z $r3 ]]; then gzip "$r3" & fi


###   Extract Methylation Data   ###
echo "====================================================="
echo "EXTRACTING MMETHYLATION DATA FOR " $name
echo "====================================================="
echo ""
if [[ -z $r3 ]]; then
    # Single
    bismark_methylation_extractor --output $to --multicore $cores --single-end \
        "$to/$name".bam &
else
    # Paired
    bismark_methylation_extractor --output $to --multicore $cores --paired-end \
        "$to/$name".bam &
fi
wait

# Clean up output
mv "$to/$name"_splitting_report.txt "$to/$name".bam_splitting_report.txt &
mv "$to/$name".M-bias.txt "$to/$name".bam_M-bias.txt &
countz.sh "$to"/CpG_OT_"$name".txt "$to"/CpG_OB_"$name".txt > \
    "$to/$name"_methylation.cov &
wait

rm "$to"/CHG_*_"$name".txt &
rm "$to"/CHH_*_"$name".txt &
rm "$to"/CpG_*_"$name".txt &
wait

# Make color bed file
colorbed.awk -v name=$name "$to/$name"_methylation.cov > \
    "$to/$name"_methylation.bed
