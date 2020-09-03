import configparser
import yaml
import re

rna_dir = config['all']['root'] + '/rna_fna'
unzipped_rna_dir = config['all']['root'] + '/unzipped_rna_fna'
ssu_dir = config['all']['root'] + '/16S_fna'
subfolder_fp = config['all']['subfolder_fp']
all_16S_fasta = config['all']['root'] + '/all_16S.fa'
vsearch_out = config['all']['root'] + '/vsearch.out'

workdir: config['all']['root']

######
### list of subfolders
######

subfolder_list = []
with open(subfolder_fp, 'r') as file:
    lines = file.readlines()

for line in lines:
    subfolder_list.append(line.rstrip())

rule all:
    input:
        vsearch_out

rule vsearch:
    input:
        all_16S_fasta
    output:
        vsearch_out
    params:
        id_cut=0.9
    shell:
        """
            vsearch \
                --allpairs_global {input} \
                --blast6out {output} \
                --id {params.id_cut}
        """

rule collect_16S:
    input:
        expand(ssu_dir + '/{subfolder}/.DONEokfasta',
            subfolder = subfolder_list)
    output: 
        all_16S_fasta
    params:
        ssu_dir
    shell:
        """
            cd {params}
            find {params} -name "*16S.fna" | xargs cat > {output}
        """

rule okfasta:
    input:
        unzipped_rna_dir + '/{subfolder}/.DONEunzip'
    output:
        ssu_dir + '/{subfolder}/.DONEokfasta'
    params:
        indir = unzipped_rna_dir + '/{subfolder}',
        outdir = ssu_dir + '/{subfolder}',
        script = config['okfasta']['script']
    shell:
        """
            mkdir -p {params.outdir}
            {params.script} {params.indir} {params.outdir} && touch  {output}
        """

rule unzip:
    input:
        unzipped_rna_dir + '/{subfolder}/.DONEcopying'
    output:
        unzipped_rna_dir + '/{subfolder}/.DONEunzip'
    params:
        unzipped_rna_dir + '/{subfolder}'
    shell:
        """
            cd {params}
            gunzip *.gz && touch {output}
        """

rule copy_rna_fna:
    input:
        subfolder_fp
    output:
        unzipped_rna_dir + '/{subfolder}/.DONEcopying'
    params:
        indir = rna_dir + '/{subfolder}',
        outdir = unzipped_rna_dir + '/{subfolder}'
    shell:
        """
            mkdir -p {params.outdir}
            find {params.indir} -maxdepth 1 -type f | xargs cp -t {params.outdir} && touch {output}
        """

rule make_dir:
    input:
        subfolder_fp
    output:
        ssu_dir + '/{subfolder}/.DONEmaking'
    params:
        ssu_dir + '/{subfolder}'
    shell:
        """
            mkdir -p {params} && touch {output}
        """

onsuccess:
    print('Workflow finished, no error')
    shell('mail -s "Workflow finished successfully" ' + config['all']['admin_email'] + ' < {log}')

onerror:
    print('An error occurred')
    shell('mail -s "An error occurred" ' + config['all']['admin_email'] + ' < {log}')

