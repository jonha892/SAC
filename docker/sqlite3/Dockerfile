FROM alpine:latest

RUN apk -U upgrade
RUN apk add sqlite

RUN mkdir /db
#RUN /usr/bin/sqlite3 /db/test.db
#CMD /bin/bash
#ENTRYPOINT [ "/bin/sh" ]
ENTRYPOINT [ "sqlite3" ]