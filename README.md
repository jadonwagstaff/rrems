# rrems
rrems is a pipeline for assembling reduced representation enzymatic methylation sequences. The assembled sequences are analyzed for methylation and filtered for 10X read depth. The final output is a .cov file with percent methylated at each CG (see .cov file documentation in the [Bismark user guide](http://felixkrueger.github.io/Bismark/Docs/)). 

Breifly, the rrems pipeline consists of trimming adapters using Trim Galore v0.6.7 and options --rrbs and --fastqc, alignments are done with Bismark v0.22.3 with options --bowtie2, --non_bs_mm, -N 1, CpG methylation are quantified using Bismark Methylation Extractor v0.22.3 with default options, and CpG's with less than 10 reads are removed and a color bed file for each sample is created with rounded cg percent methylation as the "score" values.


### Functions:
- rrems.sh - Run rrems on a paired-end or single-end sample.

# Usage

### rrems

```
rrems.sh -n SAMPLE_NAME -r REF_DIR [options] FORWARD_READS REVERSE_READS

Runs rrems pipeline with the following options:
trim-galore --rrbs --fastqc (--paired if two files provided)
bismark --quiet --bowtie2 --un --ambiguous
bismark_methylation_extractor (--paired-end if two files provided)

Uses CpG context output from bismark_methylation_extractor to get
percent methylation for each CpG (combined top and bottom strands).

Required arguments:
	FORWARD_READS	Fastq file name containing forward reads or single end reads.

Optional arguments:
	REVERSE_READS	Fastq file name containing reverse reads.

Required options:
	-n, Name of sample to be used as prefix for output files.
	-r, Reference directory. See bismark documentation for how to
		build a reference directory.
Options:
	-o, Output directory (default to directory of forward reads 
		input file).
	-d, Minimum read depth per cg (default 10).
	-c, Number of cores to use for file processing (default 1).
	-h, Print this help.

Outputs:
	FORWARD_READS.fastq.gz
	REVERSE_READS.fastq.gz
		Trimmed forward or reverse reads. Just forward reads if single end.
	FORWARD_READS_trimming_report.txt
	REVERSE_READS_trimming_report.txt
		Trimming report for forward or reverse reads. Just forward reads if 
		single end.
	FORWARD_READS_fastqc_report.html
	REVERSE_READS_fastqc_report.html
		Trimming report html for forward or reverse reads. Just forward reads if
		single end.
	
	
	SAMPLE_NAME.bam
		File containing aligned reads. Reads are trimmed using trim galore,
		aligned with bismark.
	SAMPLE_NAME.bam_bismark_report.txt
		Report for bismark read alignment.
	FORWARD_READS_ambiguous_reads_1.fq.gz
	REVERSE_READS_ambiguous_reads_2.fq.gz
		Ambiguous reads removed from alignment. Paired samples will have _1 
		(forward) or _2 (reverse).
	FORWARD_READS_unmapped_reads_1.fq.gz
	REVERSE_READS_unmapped_reads_2.fq.gz
		Unaligned reads. Paired samples will have _1 (forward) or _2 (reverse).
	
	SAMPLE_NAME_methylation.cov
		File containing cg methylation information per cg. File is formatted as:
		chromosome, cg_start, cg_stop, proportion methylated, cgs methylated, 
		cgs unmethylated.
	SAMPLE_NAME_methylation.bed
		Color bed file of the cgs in the SAMPLE_NAME_methylation.cov file.
```


# Installation

### Docker
Docker image can be found at [https://hub.docker.com/r/jadonwagstaff](https://hub.docker.com/r/jadonwagstaff)).

```
# download docker file
docker pull jadonwagstaff/rrems:v0.1.2

# Run Docker container interactively with access to an outside directory.
docker run -it -v YOUR_DIRECTORY jadonwagstaff/rrems:v0.1.2

# Exit container
exit
```

### Apptainer
Apptainer is a useful way to run a docker container in an environment without
root access, such as high performance compute systems. 

```
# Build sif file
apptainer build rrems_v0.1.2.sif docker://jadonwagstaff/rrems:v0.1.2

# Run sif container interactively
apptainer shell -e rrems_v0.1.2.sif

# Run a rrems command from the sif container
apptainer exec --no-home --cleanenv rrems_v0.1.2.sif rrems.sh \
	-n SAMPLE_NAME -u UMI_READS -r REF_DIR [options] FORWARD_READS REVERSE_READS
```

