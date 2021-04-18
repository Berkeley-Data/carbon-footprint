FROM python:3.8-alpine



RUN adduser -D webapp
USER webapp
WORKDIR /home/webapp

COPY --chown=webapp:webapp requirements.txt requirements.txt
RUN python -m venv venv

USER root
RUN apk --update add --virtual python3-dev openssl-dev \
  && venv/bin/pip install wheel setuptools_rust \
  && venv/bin/pip install -r requirements.txt

COPY --chown=webapp:webapp app app
COPY --chown=webapp:webapp test-app.py boot.sh ./


USER webapp

RUN mkdir -p ~/data

EXPOSE 8080
ENTRYPOINT [ "./boot.sh" ]