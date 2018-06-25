FROM broadinstitute/gatk3:3.8-0

LABEL \
  author="Viktor Ljungström" \
  description="GATK container for filtering of CLL WGS results" \
  maintainer="viktor.ljungstrom@igp.uu.se"

# Export PATH
ENV \
GATK_HOME=/usr \
SNPEFF_VERSION=4_3r \
SNPEFF_HOME=/opt/snpEff \
PATH="/root/.pyenv/bin:${PATH}"

# Build container
ADD \
  build.sh /usr/bin/
RUN \
  build.sh