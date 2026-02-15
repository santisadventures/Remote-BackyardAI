FROM linuxserver/openssh-server:latest

RUN apk add --no-cache curl jq coreutils

COPY chat.sh /usr/local/bin/santisplayground-chat
RUN chmod 0755 /usr/local/bin/santisplayground-chat

COPY chat_v2.sh /usr/local/bin/santisplayground-chat-v2
RUN chmod 0755 /usr/local/bin/santisplayground-chat-v2

COPY custom-cont-init.d/99-privacy.sh /custom-cont-init.d/99-privacy.sh
RUN chmod 0755 /custom-cont-init.d/99-privacy.sh

