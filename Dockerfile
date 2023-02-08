# syntax=docker/dockerfile-upstream:master-labs
# FROM ubuntu:focal
FROM rocm/pytorch:rocm5.2_ubuntu20.04_py3.7_pytorch_1.11.0_navi21

# args
ARG PROJECT="jupyter-notebook-rocm"
ARG PACKAGES="git mc htop neovim git"

ARG CONDADIR="/miniconda"
ARG CONDAENV="juno"
ARG CONDA_PREFIX=${CONDADIR}/envs/${CONDAENV}
ARG CONDADEPS="requirements.yaml"
ARG CONDASETUP=Miniconda3-py310_22.11.1-1-Linux-x86_64.sh
# ARG CONDASETUP=Miniconda3-latest-Linux-x86_64.sh
ARG CONDAURL=https://repo.anaconda.com/miniconda/${CONDASETUP}

### setup env for using conda
ENV PATH="/miniconda/bin:${PATH}"
ENV LD_LIBRARY_PATH=${CONDA_PREFIX}/lib/:$LD_LIBRARY_PATH

### install packages
RUN apt update && apt install -y ${PACKAGES}

# install conda
ADD --checksum=sha256:00938c3534750a0e4069499baf8f4e6dc1c2e471c86a59caa0dd03f4a9269db6 ${CONDAURL} /
RUN chmod a+x /${CONDASETUP}
RUN /bin/bash /${CONDASETUP} -b -p ${CONDADIR} # /bin/bash workaround for defect shellscript

## update conda if current version is not up-to-date
RUN conda update -n base -c defaults conda

### setup conda environment
COPY ${CONDADEPS} /root/
RUN ${CONDADIR}/bin/conda env create -n juno -f /root/${CONDADEPS}
RUN ${CONDADIR}/bin/conda init bash
# by default activate custom conda env
RUN echo "conda activate juno" >> /root/.bashrc

# all following RUNs should run in a real login shell to mitigate conda env activation problem
SHELL [ "conda", "run", "-n", "juno", "/bin/bash", "--login", "-c" ]

# install ROCm dependencies
RUN pip3 install --upgrade torch torchvision --extra-index-url https://download.pytorch.org/whl/rocm5.2
RUN pip3 install tensorflow-rocm

# update conda to prevent error: No module named '_sysconfigdata_x86_64_conda_linux_gnu'
# TODO might be not necessary
# RUN ${CONDADIR}/bin/conda update python

## add default container user
RUN groupadd -g 1000 vscode
RUN useradd -rm -d /home/vscode -s /bin/bash -g root -G sudo -u 1000 vscode

## create vscode extension folders
RUN mkdir /home/vscode/.vscode-server
RUN mkdir /home/vscode/.vscode-server-insiders
RUN chown vscode:vscode /home/vscode/.vscode-server
RUN chown vscode:vscode /home/vscode/.vscode-server-insiders

# setup default conda environment for vscode user
USER vscode
RUN ${CONDADIR}/bin/conda init bash
# by default activate custom conda env
RUN echo "conda activate juno" >> /home/vscode/.bashrc
# workaround for unsupported AMD GPUs
RUN echo "export HSA_OVERRIDE_GFX_VERSION=10.3.0" >> /home/vscode/.bashrc

# switch back to root
USER root

# change workdir to make notebooks browsable in jupyter notebooks
WORKDIR /workspaces

## volumes
VOLUME [ "/notebooks" ]

# vscode workspace
VOLUME [ "/workspaces/${PROJECT}" ]

# vscode extensions
VOLUME [ "/home/vscode/.vscode-server"]
VOLUME [ "/home/vscode/.vscode-server-insiders"]

# pip3 cache
VOLUME [ "/root/.cache" ]

# document ports
EXPOSE 8888/tcp
EXPOSE 8889/tcp