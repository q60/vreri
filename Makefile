NAME = vreri
TARGET = ./vreri

.PHONY: build test

all: build test

build:
	mix deps.get
	mix escript.build

test:
	$(TARGET)

install:
	install -Dm755 "$(TARGET)" "$(DESTDIR)/usr/bin/$(NAME)"

uninstall:
	rm -rfv "$(DESTDIR)/usr/bin/$(NAME)"
