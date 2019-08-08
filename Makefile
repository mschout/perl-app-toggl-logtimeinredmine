PREFIX ?= /usr/local
VERSION = "v0.1.0"
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
