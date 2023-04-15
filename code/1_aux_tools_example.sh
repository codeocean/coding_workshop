#!/usr/bin/env bash

export CO_LOG_LEVEL="DEBUG"

for fastq in $(find -L ../data -name "*.fastq.gz")
do
    set_log_msg "Current fastq is $fastq" "INFO"
    
    fastq_direction=$(get_read_direction $fastq)
    fastq_pattern=$(get_read_pattern $fastq $fastq_direction)
    fastq_prefix=$(get_read_prefix $fastq)
    rev_fastq=$(get_rev_fastq $fastq)

    set_log_msg "fastq_direction: $fastq_direction" "INFO"
    set_log_msg "fastq_pattern: $fastq_pattern" "INFO"
    set_log_msg "fastq_prefix: $fastq_prefix" "INFO"
    set_log_msg "rev_fastq: $rev_fastq" "INFO"
    
    echo "Current fastq is $fastq"
    echo "fastq_direction: $fastq_direction"
    echo "fastq_pattern: $fastq_pattern"
    echo "fastq_prefix: $fastq_prefix"
    echo "rev_fastq: $rev_fastq"
done