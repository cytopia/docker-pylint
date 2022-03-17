FROM alpine:3.15 as builder

RUN set -x \
	&& apk add --no-cache \
		bc \
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
		pip3 install --no-cache-dir --no-compile "pylint>=${VERSION},<$(echo "${VERSION}+0.1" | bc)"; \
	fi \
	&& find /usr/lib/ -name '__pycache__' -print0 | xargs -0 -n1 rm -rf \
	&& find /usr/lib/ -name '*.pyc' -print0 | xargs -0 -n1 rm -rf


FROM alpine:3.15 as production
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
	&& apk add --no-cache python3 py3-pip \
	&& ln -sf /usr/bin/python3 /usr/bin/python \
	&& ln -sf /usr/bin/pip3 /usr/bin/pip \
	&& find /usr/lib/ -name '__pycache__' -print0 | xargs -0 -n1 rm -rf \
	&& find /usr/lib/ -name '*.pyc' -print0 | xargs -0 -n1 rm -rf

COPY --from=builder /usr/lib/python3.9/site-packages/ /usr/lib/python3.9/site-packages/
COPY --from=builder /usr/bin/pylint /usr/bin/pylint
WORKDIR /data
ENTRYPOINT ["pylint"]
CMD ["--version"]
