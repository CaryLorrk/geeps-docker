FROM nvidia/cuda:8.0-cudnn5-devel

MAINTAINER CaryLorrk "carylorrk@gmail.com"

ENV REFRESHED_AT 2017-01-16
RUN apt-get -y update

RUN apt-get -y install --no-install-recommends \
        openssh-server \
        scons \
        wget
        
RUN service ssh restart

WORKDIR /root
COPY geeps geeps
COPY ssh .ssh

ARG NUM_CORE=8

WORKDIR geeps
RUN ./scripts/install-geeps-deps-ubuntu14.sh
RUN ./scripts/install-caffe-deps-ubuntu14.sh
RUN scons -j ${NUM_CORE}
WORKDIR apps/caffe
RUN make -j ${NUM_CORE}

RUN ./data/cifar10/get_cifar10.sh


WORKDIR /root

RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config

ADD bootstrap.sh /etc/bootstrap.sh
ENTRYPOINT ["/etc/bootstrap.sh"]
CMD ["-d"]
