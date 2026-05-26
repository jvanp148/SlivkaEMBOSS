# Use Miniconda as the base image
FROM continuumio/miniconda3

# Set a working directory
WORKDIR /app

# Install supervisord
RUN apt-get update && apt-get install -y supervisor default-jre-headless

COPY environment.yml /tmp/environment.yml

# Install slivka-bio using Conda
RUN conda install anaconda-client -n base -y 
RUN conda env create -f /tmp/environment.yml


RUN conda install -n compbio-services bioconda::emboss -y
RUN conda install -n compbio-services bioconda::anarci -y

# Copy Slivka config
COPY ./settings.yml /opt/conda/envs/compbio-services/var/slivka-bio/

# Copy supervisord config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Mark services directory as extrernally mounted volume
VOLUME /opt/conda/envs/compbio-services/var/slivka-bio/services

# Expose the port Slivka is running on
EXPOSE 8000

# Run supervisord
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
