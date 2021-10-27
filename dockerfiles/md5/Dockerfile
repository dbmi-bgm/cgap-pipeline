## source file for md5 image

FROM ubuntu:16.04
MAINTAINER Soo Lee (duplexa@gmail.com), Michele Berselli (berselli.michele@gmail.com)

# general updates & installing necessary Linux components
RUN apt-get update -y && apt-get install -y wget unzip less vim bzip2 make gcc zlib1g-dev libncurses-dev git libkrb5-3 libpng12-0

# download tools
WORKDIR /usr/local/bin
COPY downloads.sh .
RUN . downloads.sh

# set path

# wrapper
COPY run.sh .
RUN chmod +x run.sh

# default command
CMD ["run.sh"]
