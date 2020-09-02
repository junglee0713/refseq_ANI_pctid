#!/bin/bash
ftp_path="/scr1/users/leej39/RefSeq_rna_200k/accession_ftp_path.tsv"
rna_dir="/scr1/users/leej39/RefSeq_rna_200k/rna_fna"
while IFS=$'\t' read accession path subfolder; do
    target_dir="${rna_dir}/${subfolder}"
    wget ${path} -P "${target_dir}"
done < ${ftp_path}
