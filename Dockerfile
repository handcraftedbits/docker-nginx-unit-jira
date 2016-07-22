FROM handcraftedbits/nginx-unit-java:8.92.14
MAINTAINER HandcraftedBits <opensource@handcraftedbits.com>

ARG JIRA_VERSION=7.1.9

ENV JIRA_HOME /opt/data/jira

COPY data /

RUN apk update && \
  apk add ca-certificates wget && \

  cd /opt && \
  wget https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-software-${JIRA_VERSION}.tar.gz && \
  tar -xzvf atlassian-jira-software-${JIRA_VERSION}.tar.gz && \
  rm atlassian-jira-software-${JIRA_VERSION}.tar.gz && \
  mv atlassian-jira-software-${JIRA_VERSION}-standalone jira && \

  apk del ca-certificates wget

EXPOSE 8080

CMD ["/bin/bash", "/opt/container/script/run-jira.sh"]
