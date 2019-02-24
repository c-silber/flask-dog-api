FROM ubuntu:latest

MAINTAINER Caroline "goldiesilber23@gmail.com"

EXPOSE 8080
RUN apt-get update -y
RUN apt-get install wget -y
RUN apt-get install unzip -y
RUN apt-get install -y python-pip python-dev build-essential
RUN apt-get install -y libsm6 libxext6 libxrender-dev

COPY /src /
WORKDIR /

RUN mkdir bottleneck_features && cd bottleneck_features \
&& wget https://s3-us-west-1.amazonaws.com/udacity-aind/dog-project/DogInceptionV3Data.npz

RUN wget https://s3-us-west-1.amazonaws.com/udacity-aind/dog-project/dogImages.zip
RUN unzip dogImages.zip

RUN pip install -r requirements.txt

ENV S3_BUCKET=flask-dog-project
ENV S3_KEY=AKIAIFL7DO2KU2TBT4HA
ENV S3_SECRET_ACCESS_KEY=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

ENTRYPOINT ["python"]

CMD ["wsgi.py"]
