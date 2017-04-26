FROM ibmcom/swift-ubuntu:3.1.1
LABEL maintainer "spoole@uk.ibm.com"
RUN apt-get update && apt-get install -y curl
RUN mkdir /code
RUN mkdir /scripts
COPY wrapper.sh /scripts
COPY docker-compose.yml /scripts
WORKDIR /code
ENTRYPOINT ["bash" , "/scripts/wrapper.sh"]
CMD ["help"]
