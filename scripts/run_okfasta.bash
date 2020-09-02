#!/bin/bash
in_dir=$1
out_dir=$2
cd ${in_dir}
for fna in *.fna; do
    in_path="${in_dir}/${fna}"
    out_path="${out_dir}/${fna/rna_from_genomic.fna/16S.fna}"
    okfasta searchdesc \
        --input ${in_path} \
        --output ${out_path} \
        "product=16S ribosomal RNA"
done
