FROM ubuntu:20.04
RUN apt-get update && \
    apt-get install -y vim && \
    apt-get install -y wget && apt-get install -y curl
RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install tzdata
RUN apt-get -y install python3-pip
RUN pip3 install --upgrade pip
RUN apt-get -y install libpython3.8-dev
RUN apt-get install -y git
RUN pip3 install Cython numpy matplotlib
RUN pip3 install pandas
RUN git clone https://github.com/ultralytics/yolov5 # clone repo
RUN pip3 install -U -r yolov5/requirements.txt # install dependencies
RUN pip3 install facenet-pytorch
RUN apt-get install python3
RUN apt-get update
RUN apt install -y libsm6 libxext6 ffmpeg libfontconfig1 libxrender1 libgl1-mesa-glx
RUN pip3 install utils gunicorn flask
COPY 3700214610015.jpg /yolov5
COPY loadimagesfrombytes.py /yolov5
COPY detect_custom.py /yolov5
COPY app.py /yolov5
COPY product_final.pt /yolov5
WORKDIR /yolov5

# Expose port
EXPOSE 5000
EXPOSE 8000

#ENTRYPOINT [ "python3" ]
#CMD ["app.py"]
CMD ["gunicorn", "app:app", "--bind", "0.0.0.0:8000"]

