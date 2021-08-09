FROM pytorch/pytorch:1.7.0-cuda11.0-cudnn8-runtime

RUN apt-get update && apt-get install vim -y
RUN apt-get install psmisc
RUN pip install scipy matplotlib sklearn thop tensorboard loguru pandas openpyxl
RUN pip install pykalman tsne_torch pyecharts
RUN conda install -c CannyLab -c  tsnecuda
WORKDIR /
