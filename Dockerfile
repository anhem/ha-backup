FROM ubuntu:latest

ARG SSH_KEY_FILE
ARG SSH_HOST

RUN apt-get update && apt-get -y install openssh-client
RUN useradd -rm user
WORKDIR /home/user
COPY ha-backup.sh .
RUN mkdir .ssh
COPY $SSH_KEY_FILE .ssh/
RUN ssh-keyscan $SSH_HOST > .ssh/known_hosts
RUN chown -R user:user ha-backup.sh \
    && chown -R user:user .ssh \
    && chmod 600 .ssh/known_hosts
USER user
ENTRYPOINT ["./ha-backup.sh"]