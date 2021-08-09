FROM pytorch/pytorch:1.6.0-cuda10.1-cudnn7-devel

RUN apt-get update && apt-get install vim -y
RUN apt-get install psmisc
RUN pip install scipy matplotlib sklearn thop tensorboard loguru pandas openpyxl
RUN pip install pykalman tsne_torch pyecharts
RUN conda install -c CannyLab -c  tsnecuda
WORKDIR /
