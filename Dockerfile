FROM alpine:3.11 as builder

RUN set -x \
	&& apk add --no-cache \
		bc \
		gcc \
		libffi-dev \
		make \
		musl-dev \
		openssl-dev \
		python3 \
		python3-dev

ARG VERSION=latest
RUN set -x \
	&& if [ "${VERSION}" = "latest" ]; then \
		pip3 install --no-cache-dir --no-compile pylint; \
	else \
		pip3 install --no-cache-dir --no-compile "pylint>=${VERSION},<$(echo "${VERSION}+0.1" | bc)"; \
	fi \
	&& find /usr/lib/ -name '__pycache__' -print0 | xargs -0 -n1 rm -rf \
	&& find /usr/lib/ -name '*.pyc' -print0 | xargs -0 -n1 rm -rf


FROM alpine:3.11 as production
LABEL \
	maintainer="cytopia <cytopia@everythingcli.org>" \
	repo="https://github.com/cytopia/docker-pylint"
RUN set -x \
	&& apk add --no-cache python3 \
	&& ln -sf /usr/bin/python3 /usr/bin/python \
	&& find /usr/lib/ -name '__pycache__' -print0 | xargs -0 -n1 rm -rf \
	&& find /usr/lib/ -name '*.pyc' -print0 | xargs -0 -n1 rm -rf
COPY --from=builder /usr/lib/python3.8/site-packages/ /usr/lib/python3.8/site-packages/
COPY --from=builder /usr/bin/pylint /usr/bin/pylint
WORKDIR /data
ENTRYPOINT ["pylint"]
CMD ["--version"]
