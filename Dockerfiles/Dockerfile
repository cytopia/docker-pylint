FROM alpine:3.16 as builder

RUN set -x \
	&& apk add --no-cache \
		gcc \
		libffi-dev \
		make \
		musl-dev \
		openssl-dev \
		py3-pip \
		python3 \
		python3-dev

ARG VERSION
RUN set -x \
	&& if [ "${VERSION}" = "latest" ]; then \
		pip3 install --no-cache-dir --no-compile pylint; \
	else \
		pip3 install --no-cache-dir --no-compile pylint~=${VERSION}.0; \
	fi \
	\
	&& pylint --version \
	\
	&& find /usr/lib/ -name '__pycache__' -print0 | xargs -0 -n1 rm -rf \
	&& find /usr/lib/ -name '*.pyc' -print0 | xargs -0 -n1 rm -rf


FROM alpine:3.16 as production
ARG VERSION
# https://github.com/opencontainers/image-spec/blob/master/annotations.md
#LABEL "org.opencontainers.image.created"=""
#LABEL "org.opencontainers.image.version"=""
#LABEL "org.opencontainers.image.revision"=""
LABEL "maintainer"="cytopia <cytopia@everythingcli.org>"
LABEL "org.opencontainers.image.authors"="cytopia <cytopia@everythingcli.org>"
LABEL "org.opencontainers.image.vendor"="cytopia"
LABEL "org.opencontainers.image.licenses"="MIT"
LABEL "org.opencontainers.image.url"="https://github.com/cytopia/docker-pylint"
LABEL "org.opencontainers.image.documentation"="https://github.com/cytopia/docker-pylint"
LABEL "org.opencontainers.image.source"="https://github.com/cytopia/docker-pylint"
LABEL "org.opencontainers.image.ref.name"="pylint ${VERSION}"
LABEL "org.opencontainers.image.title"="pylint ${VERSION}"
LABEL "org.opencontainers.image.description"="pylint ${VERSION}"

RUN set -x \
	&& apk add --no-cache \
		python3 \
	&& ln -sf /usr/bin/python3 /usr/bin/python \
	&& find /usr/lib/ -name '__pycache__' -print0 | xargs -0 -n1 rm -rf \
	&& find /usr/lib/ -name '*.pyc' -print0 | xargs -0 -n1 rm -rf

COPY --from=builder /usr/lib/python3.10/site-packages/ /usr/lib/python3.10/site-packages/
COPY --from=builder /usr/bin/pylint /usr/bin/pylint

WORKDIR /data
ENTRYPOINT ["pylint"]
CMD ["--version"]
