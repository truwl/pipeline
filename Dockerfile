# MG-RAST dockerfiles

FROM	debian
MAINTAINER The MG-RAST team

RUN apt-get update && apt-get install -y \
    git \
	unzip \
	wget \
	make \
	python-dev \
	python-pip \ 					
	libpq-dev \
	libpng-dev \
	perl-modules \
	libcwd-guard-perl \
	libdbi-perl \
	libdbd-pg-perl \
	libdata-dump-streamer-perl \
	libdatetime-perl \
	libdigest-md5-perl \
	libdigest-md5-file-perl \
	libfile-slurp-perl \
	libfilehandle-fmode-perl \
	libjson-perl \
	libstring-random-perl \
	libtemplate-perl \
	libwww-perl \
	libgetopt-long-descriptive-perl \
	liburi-encode-perl \
	libunicode-escape-perl \
	liblist-allutils-perl \
	libposix-strptime-perl \
	libberkeleydb-perl \
	libemail-simple-perl \
	libemail-sender-perl \
   	python-numpy \
	python-scipy \
	python-leveldb \
	python-biopython

### add pipeline repo code
COPY . /root/pipeline
RUN mv /root/pipeline/mgrast_env.sh /root/
RUN cd /root/pipeline/awecmd \
    && for X in *; do ln -f -s /root/pipeline/awecmd/$X /usr/local/bin/$X; done \
    && cd /root/pipeline/bin \
    && for X in *; do ln -f -s /root/pipeline/bin/$X /usr/local/bin/$X; done

### install superblat (from binary in local dir) and BLAT from src
ADD superblat /root/bin/superblat
RUN chmod +x /root/bin/superblat
RUN cd /root \
	&& wget "http://users.soe.ucsc.edu/~kent/src/blatSrc35.zip" \
	&& unzip blatSrc35.zip && export C_INCLUDE_PATH=/root/include \
	&& export MACHTYPE=x86_64-pc-linux-gnu \
	&& cd blatSrc \
	&& make BINDIR=/root/bin \
	&& cd .. \
	&& rm -rf blatSrc blatSrc35.zip

### install thrid party tools from apt-get
RUN apt-get install -y bowtie2 cd-hit cdbfasta jellyfish		

### install FragGeneScan from our patched source in github
RUN cd /root \
	&& git clone https://github.com/wltrimbl/FGS.git FragGeneScan \
	&& cd FragGeneScan \
	&& make \
	&& mkdir bin \
	&& mv train bin/. \
	&& mv *.pl bin/. \
	&& mv FragGeneScan bin/. \
	&& cd .. \
	&& echo "export PATH=/root/FragGeneScan/bin:\$PATH" >> /root/mgrast_env.sh

### install usearch binary from local dir
ADD usearch /root/bin/usearch
RUN chmod +x /root/bin/usearch

#
# If you you need a specific commit:
#
# RUN cd /root/pipeline/ && git pull && git reset --hard [ENTER HERE THE COMMIT HASH YOU WANT]