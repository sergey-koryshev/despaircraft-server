FROM gcc:11.5.0 AS mcrcon
RUN git clone https://github.com/Tiiffi/mcrcon.git
WORKDIR /mcrcon
RUN make

FROM alpine:3.22.0 AS fabric-server
ARG FABRIC_SERVER_DOWNLOAD_URL
WORKDIR /minecraft
RUN wget -O minecraft_server.jar ${FABRIC_SERVER_DOWNLOAD_URL}

FROM openjdk:21-jdk-slim-bullseye
ARG UID=25575
ARG GID=25575
RUN groupadd -g "${GID}" minecraft_group && \
    useradd -u "${UID}" -g minecraft_group -m -s /bin/bash minecraft_user
WORKDIR /minecraft
COPY ./entrypoint.sh ./
COPY --from=mcrcon /mcrcon/mcrcon /usr/local/bin/mcrcon/mcrcon
COPY --from=fabric-server /minecraft /minecraft
RUN echo "eula=true" > eula.txt
RUN chown -R minecraft_user:minecraft_group /minecraft && \
    chmod -R 775 /minecraft
RUN chmod +x /minecraft/entrypoint.sh
RUN chmod +x /usr/local/bin/mcrcon/mcrcon
USER minecraft_user
RUN java -jar minecraft_server.jar --initSettings --nogui
ENTRYPOINT [ "./entrypoint.sh" ]