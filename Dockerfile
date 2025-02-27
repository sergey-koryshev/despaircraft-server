FROM gcc:11-bullseye AS mcrcon
RUN git clone https://github.com/Tiiffi/mcrcon.git
WORKDIR /mcrcon
RUN make

FROM openjdk:21-jdk-bullseye
ARG FABRIC_SERVER_DOWNLOAD_URL
ENV XMX=5G
ENV XMS=5G
WORKDIR /minecraft
COPY ./entrypoint.sh ./
COPY --from=mcrcon ./mcrcon /usr/local/bin/mcrcon
RUN chmod +x entrypoint.sh
RUN curl -o minecraft_server.jar ${FABRIC_SERVER_DOWNLOAD_URL}
RUN echo "eula=true" > eula.txt
RUN java -jar minecraft_server.jar --initSettings --nogui
ENTRYPOINT [ "./entrypoint.sh" ]