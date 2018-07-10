
# Sarek CLL Postprocess

Nextflow workflow to postprocess StrelkaBP results annotated with VEP from Sarek.

Filters for LCR and IG regions and breaks into readable tsv file.

Based on [Sareks annotation workflow](https://github.com/SciLifeLab/Sarek/)

## Steps

1. Filter against LCR regions
2. Filter against Ensembl IG regions
3. Adds extra Cosmic annotation in Cosmic VCF file using snpSift
4. Splits to columns with python and pandas

## Usage

```bash
nextflow run postprocess.nf --outDir results --sampleID Sample_ID
```

## ToDo

Create profiles for what ANN columns to output in final file and attach name to them.
E.g. CLL, minimal, maximal, custom
Attach final column name with  column