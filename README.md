# refseq_ANI_pctid
Get pctid and ANI using sequencing data downloaded from RefSeq

## Step 1: Download the table of all bacteria assemblies
Download the table of all bacteria assemblies from RefSeq: https://ftp.ncbi.nlm.nih.gov/genomes/refseq/bacteria/assembly_summary.txt

## Step 2: Make a table that contains ftp path data
After downloading `assembly_summary.txt`, remove the first line, and delete the “# “ from the beginning of the header. Use Kyle's script (`scripts/refseq_assemblies.Rmd`) to create `accession_ftp_path.tsv` (accession, ftp path to rna fasta, and the subfolder that contains the file) and `unique_subfolders.tsv` (the list of unique subfolders) 

## Step 3: Download `*_rna_from_genome.fna.gz` files (~ 15 hours)
Set up a root directory (say `/scr1/users/leej39/RefSeq_rna_200k`). Use `script/download_rna_fna.bash` to download rna fasta files to respective subfolder. **About 200K files are to be downloaded, so it is recommended to use multiple subfolders to store files.** It takes ~15 hours.

## Step 4: Extract 16S region (~ 3 hours)
Create a conda environment (say genomeComp, using `environment.yml`), under which you can use `pyani` and `okfasta` (https://github.com/kylebittinger/okfasta):
```
conda env create -f environment.yml
```
Edit `config.yml` appropriately (root directory, admin email, paths to `unique_subfolders.tsv` and `run_okfasta.bash`) and run the snakemake pipeline (e.g. `run_snakemake.bash config.yml`). This will
- copy `*_rna_from_genome.fna.gz` files to the folder `unzipped_rna_fna` (for safety),
- unzip `*_rna_from_genome.fna.gz` files in the folder `unzipped_rna_fna`,
- run `okfasta` to extract 16S region and save the result in the folder `16S_fna` under the root directory as `*_16S.fna`, and
- combine all `*_16S.fna` files into a single file `all_16S.fa` under the root directory.

## Step 5: Use `vsearch` to get 16S similarity
To be continued...
