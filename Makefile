ifneq (,)
.error This Makefile requires GNU Make.
endif

.PHONY: build rebuild lint test _test_version _test_run tag pull login push enter

CURRENT_DIR = $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

DIR = .
FILE = Dockerfile
IMAGE = cytopia/pylint
TAG = latest

build:
	docker build --build-arg VERSION=$(TAG) -t $(IMAGE) -f $(DIR)/$(FILE) $(DIR)

rebuild: pull
	docker build --no-cache --build-arg VERSION=$(TAG) -t $(IMAGE) -f $(DIR)/$(FILE) $(DIR)

lint:
	@docker run --rm -v $(CURRENT_DIR):/data cytopia/file-lint file-cr --text --ignore '.git/,.github/,tests/' --path .
	@docker run --rm -v $(CURRENT_DIR):/data cytopia/file-lint file-crlf --text --ignore '.git/,.github/,tests/' --path .
	@docker run --rm -v $(CURRENT_DIR):/data cytopia/file-lint file-trailing-single-newline --text --ignore '.git/,.github/,tests/' --path .
	@docker run --rm -v $(CURRENT_DIR):/data cytopia/file-lint file-trailing-space --text --ignore '.git/,.github/,tests/' --path .
	@docker run --rm -v $(CURRENT_DIR):/data cytopia/file-lint file-utf8 --text --ignore '.git/,.github/,tests/' --path .
	@docker run --rm -v $(CURRENT_DIR):/data cytopia/file-lint file-utf8-bom --text --ignore '.git/,.github/,tests/' --path .

test:
	@$(MAKE) --no-print-directory _test_version
	@$(MAKE) --no-print-directory _test_run

_test_version:
	@echo "------------------------------------------------------------"
	@echo "- Testing correct version"
	@echo "------------------------------------------------------------"
	@if [ "$(TAG)" = "latest" ]; then \
		echo "Fetching latest version from GitHub"; \
		LATEST="$$( \
			curl -L -sS  https://github.com/PyCQA/pylint/releases/ \
				| tac | tac \
				| grep -Eo "PyCQA/pylint/releases/tag/(pylint-)?[.0-9]+" \
				| head -1 \
				| sed 's/.*tag\///g' \
				| grep -Eo '[.0-9]+' \
		)"; \
		echo "Testing for latest: $${LATEST}"; \
		if ! docker run --rm $(IMAGE) --version | grep -E "$${LATEST}$$"; then \
			echo "Failed"; \
			exit 1; \
		fi; \
	else \
		echo "Testing for tag: $(TAG)"; \
		if ! docker run --rm $(IMAGE) --version | grep -E "^$(TAG)"; then \
			echo "Failed"; \
			exit 1; \
		fi; \
	fi; \
	echo "Success"; \

_test_run:
	@echo "------------------------------------------------------------"
	@echo "- Testing pep8 standard"
	@echo "------------------------------------------------------------"
	@if ! docker run --rm -v $(CURRENT_DIR)/tests:/data $(IMAGE) test.py ; then \
		echo "Failed"; \
		exit 1; \
	fi; \
	echo "Success";

tag:
	docker tag $(IMAGE) $(IMAGE):$(TAG)

pull:
	@grep -E '^\s*FROM' Dockerfile \
		| sed -e 's/^FROM//g' -e 's/[[:space:]]*as[[:space:]]*.*$$//g' \
		| xargs -n1 docker pull;

login:
	yes | docker login --username $(USER) --password $(PASS)

push:
	@$(MAKE) tag TAG=$(TAG)
	docker push $(IMAGE):$(TAG)

enter:
	docker run --rm --name $(subst /,-,$(IMAGE)) -it --entrypoint=/bin/sh $(ARG) $(IMAGE):$(TAG)
