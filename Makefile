PREFIX ?= /usr/local
VERSION = "v0.2.0"
DOCKER_IMAGE = mschout/toggl-log-to-redmine

all: install

.PHONY: install
install:
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	install -m 0755 bin/toggl-log-to-redmine-wrapper $(DESTDIR)$(PREFIX)/bin/toggl-log-to-redmine

.PHONY: uninstall
uninstall:
	@$(RM) $(DESTDIR)$(PREFIX)/bin/toggl-log-to-redmine
	@docker rmi $(DOCKER_IMAGE):$(VERSION)
	@docker rmi $(DOCKER_IMAGE):latest

.PHONY: build
build:
	@docker build -t $(DOCKER_IMAGE):$(VERSION) . \
		&& docker tag $(DOCKER_IMAGE):$(VERSION) $(DOCKER_IMAGE):latest

.PHONY: publish
publish:
	@docker push $(DOCKER_IMAGE):$(VERSION) \
		&& docker push $(DOCKER_IMAGE):latest
