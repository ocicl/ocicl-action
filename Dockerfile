FROM registry.access.redhat.com/ubi9:latest

# This image provides a Common Lisp environment based on QuickLisp and
# that you can use to run your Common Lisp applications.

MAINTAINER The ocicl hackers @ github.com/ocicl

ENV HOME=/home/ocicl \
    LC_ALL=C.utf8 \
    LANG=C.utf8 \
    LANGUAGE=C.utf8 \
    SBCL_VERSION=2.3.4 \
    LIBEV_VERSION=4.33 \
    LIBSSH2_VERSION=1.10.0

RUN rm /etc/rhsm-host && \
    mkdir ${HOME} && \
    yum install -y \
        bzip2 git make patch automake autoconf libtool gcc gcc-c++ libuv openssl-devel && \
    yum update -y && \
    yum clean -y all && \
    locale -a && \
    gcc --version

WORKDIR $HOME

# Build libev from source since it is not available in ubi8-base nor ubi8-app-stream repos
RUN curl -O "http://dist.schmorp.de/libev/Attic/libev-${LIBEV_VERSION}.tar.gz" && \
    tar xvf libev-${LIBEV_VERSION}.tar.gz && \
    cd libev-${LIBEV_VERSION} && \
    chmod +x autogen.sh && \
    ./autogen.sh && \
    ./configure --prefix=/usr && \
    make && \
    make install && \
    cd ${HOME} && \
    rm -rf libev*

# Build libssh2 from source since it is not available in ubi8-base nor ubi8-app-stream repos
RUN curl -O "https://www.libssh2.org/download/libssh2-${LIBSSH2_VERSION}.tar.gz" && \
    tar xvf libssh2-${LIBSSH2_VERSION}.tar.gz && \
    cd libssh2-${LIBSSH2_VERSION} && \
    ./configure --prefix=/usr --with-crypto=openssl && \
    make && \
    make install && \
    cd ${HOME} && \
    rm -rf libssh2* && \
    mkdir -p ${HOME}/.ssh && \
    dnf remove -y openssl-devel

RUN curl -L -O "https://downloads.sourceforge.net/project/sbcl/sbcl/2.3.4/sbcl-2.3.4-x86-64-linux-binary.tar.bz2" && \
    curl -L -O https://beta.quicklisp.org/quicklisp.lisp && \
    tar -xvf sbcl-2.3.4-x86-64-linux-binary.tar.bz2 && \
    cd sbcl-2.3.4-x86-64-linux && \
    ./install.sh && \
    cd .. && \
    rm -rf sbcl-2.3.4-x86-64-linux-binary.tar.bz2 \
       sbcl-2.3.4-x86-64-linux

RUN chown -R 1001:0 ${HOME} && \
    chmod -R g+rwX,o= ${HOME}

USER 1001

RUN touch ${HOME}/.ssh/trivial_ssh_hosts

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
