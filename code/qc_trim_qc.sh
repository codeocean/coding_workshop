#!/usr/bin/env bash

source ./config.sh

set_log_msg "FastQC Version: $(fastqc --version)" "INFO"
set_log_msg "fastp Version: $(fastp --version 2>&1)" "INFO"
set_log_msg "MultiQC Version: $(multiqc --version)" "INFO"
set_log_msg "cpus: $cpus" "INFO"
set_log_msg "$(get_dir_contents)" "INFO"

mkdir -p ../results/fastqc_pretrim
mkdir -p ../results/fastqc_posttrim
mkdir -p ../results/fastp
mkdir -p ../results/multiqc

# Copy all fastq files from data to scratch
for fastq in $(find -L ../data -name "*fastq*"); do
    cp "$fastq" "/scratch/$(basename -a "$fastq")"
done

set_log_msg "Before gzip: $(get_dir_contents "/scratch")" "INFO"

# gzip any fastq files not alread in .gz format
for fastq in $(find -L "../scratch" -name "*.fastq"); do
    set_log_msg "Currently compressing $fastq" "DEBUG"
    pigz -"${compression}" -p "${cpus}" -c "${fastq}" > "${fastq}.gz"
done

set_log_msg "After compression: $(get_dir_contents "/scratch")" "INFO"

# QC on fastq files
for fastq in $(find -L "../scratch" -name "*.fastq.gz"); do
    set_log_msg "Running FastQC on $fastq" "INFO"
    fastqc \
        -t "$cpus" \
        -o ../results/fastqc_pretrim \
        "$fastq" &
done
wait

# Trim adapters with fastp
for fwd_fastq in $(get_fwd_fastqs "../scratch"); do
    set_log_msg "Current fwd_fastq: $fwd_fastq" "INFO"
    rev_fastq=$(get_rev_fastq "$fwd_fastq")
    set_log_msg "rev_fastq: $rev_fastq" "INFO"
    file_prefix=$(get_read_prefix "$fwd_fastq")
    fwd_name=$(basename -a "$fwd_fastq")
    rev_name=$(basename -a "$rev_fastq")
    
    fastp \
        --in1 "$fwd_fastq" \
        --in2 "$rev_fastq" \
        --out1 "../results/fastp/${fwd_name}" \
        --out2 "../results/fastp/${rev_name}" \
        --report_title "$file_prefix" \
        --detect_adapter_for_pe \
        --thread "$cpus" \
        -h "../results/fastp/${file_prefix}.html" \
        -j "../results/fastp/${file_prefix}.json"
done

# Repeat FastQC on trimmed fastq files
for fastq in $(find -L ../results/fastp -name "*.fastq.gz"); do
    set_log_msg "Running FastQC on $fastq" "INFO"
    fastqc \
        -t "$cpus" \
        -o ../results/fastqc_posttrim \
        "$fastq" &
done
wait

set_log_msg "Before MultiQC: $(get_dir_contents "/results")" "DEBUG"

# Create aggregate report using MultiQC
multiqc ../results/fastqc_pretrim -o ../results/multiqc --filename fastqc_pretrim_report.html
multiqc ../results/fastqc_posttrim -o ../results/multiqc --filename fastqc_posttrim_report.html
