mkdir Report
mkdir Report/VariantsTXT
mkdir Report/FilteredVCF
mkdir Report/ASCATPlots
mkdir Report/ASCATCNVs

while read p; do
  cp $p/results/Annotation/AnnotatedTxt/* Report/VariantsTXT
  cp $p/results/Annotation/CosmicVCF/* Report/FilteredVCF
  cp $p/results/VariantCalling/Ascat/$p.ASCATprofile.png Report/ASCATPlots
  cp $p/results/VariantCalling/Ascat/$p.cnvs.txt Report/ASCATCNVs
  echo $p
done <samples.txt