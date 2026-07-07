MARKDOWN := $(wildcard *.md)
HTML     := $(MARKDOWN:.md=.html)

.PHONY: all html test

all: html test

%.html: %.md
	docker run --rm -i docker.io/hugojosefson/markdown < $< > $@

html: $(HTML)

test:
	./test/run.sh
