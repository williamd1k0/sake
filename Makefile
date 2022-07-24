# Default configs
SITE_CONF := site.yml
INCLUDES :=
EXCLUDES :=
SRC := src
DATA :=
OUT := out
TMP := .tmp

# User-defined configs
sinclude build.mk

ifneq "${MAKECMDGOALS}" "init"
ifneq "${INCLUDES}" ""
ALL_INCLUDES := $(patsubst %, ${TMP}/%, $(shell fd -tf . ${INCLUDES}))
endif
GLOBAL_EXCLUDES := *.meta
ifneq "${DATA}" ""
DATA_SOURCES := $(shell fd -tf -e yml . ${DATA})
DATA_TARGETS := $(patsubst ${DATA}/%.yml, ${TMP}/data/%.json, ${DATA_SOURCES})
GLOBALS_SOURCES := ${TMP}/site.json ${TMP}/data.json
else
GLOBALS_SOURCES := ${TMP}/site.json
endif
GLOBALS_TARGET := ${TMP}/globals.json
ALL_EXCLUDES := $(patsubst %, -E '%', ${GLOBAL_EXCLUDES} ${EXCLUDES})
COPY_SOURCES := $(shell fd -tf . ${SRC} -E '*.j2' ${ALL_EXCLUDES})
TEMPLATE_SOURCES = $(patsubst %.j2, %, $(shell fd -tf -e j2 . ${SRC} ${ALL_EXCLUDES}))
TARGETS = $(patsubst ${SRC}/%,${OUT}/%, ${COPY_SOURCES} ${TEMPLATE_SOURCES})
endif


all: ${GLOBALS_TARGET} ${ALL_INCLUDES} ${TARGETS}

${TMP}/site.json: ${SITE_CONF}
	@mkdir -p ${TMP}
	@yj $< | jq '. | { site: . }' > $@

${TMP}/data/%.json: ${DATA}/%.yml
	@mkdir -p ${TMP}/data
	@yj $< | jq '. | { $(patsubst %.yml, %, ${<F}): . }' > $@

${TMP}/data.json: ${DATA_TARGETS}
	@jq -s add $^ | jq '. | { data: . }' > $@

${GLOBALS_TARGET}: ${GLOBALS_SOURCES}
	@jq -s add $^ > $@

${TMP}/%: %
	@mkdir -p '$(@D)'
	@cp -r '$<' '$@'

${OUT}/%: ${SRC}/%.j2 ${GLOBALS_TARGET} ${ALL_INCLUDES}
	@printf "Processing '%s'\n" '$<'
	@echo > ${TMP}/page.json
	@if test -f '$<'.meta; then \
		yj '$<'.meta | jq '. | { page: . }' > ${TMP}/page.json; \
	fi
	@cp '$<' ${TMP}/input.j2
	@jq -s add ${GLOBALS_TARGET} ${TMP}/page.json > ${TMP}/input.json
	@jinja2 --format json '${TMP}/input.j2' '${TMP}/input.json' > ${TMP}/output
	@mkdir -p '$(@D)'
	@cp '${TMP}/output' '$@'

${OUT}/%: ${SRC}/%
	@printf "Copying '%s'\n" '$<'
	@mkdir -p '$(@D)'
	@cp '$<' '$@'

init:
	@if test ! -f "${SITE_CONF}"; then \
		printf "Creating '%s'\n" '${SITE_CONF}'; \
		printf "%s\n" \
		'title: New Sake Site' \
		'baseurl: ' \
		> ${SITE_CONF}; \
	fi
	@if test ! -f "build.mk"; then \
		printf "Creating '%s'\n" 'build.mk'; \
		printf "%s\n" \
		'SITE_CONF := ${SITE_CONF}' \
		'INCLUDES := ${INCLUDES}' \
		'EXCLUDES := ${EXCLUDES}' \
		'SRC := ${SRC}' \
		'DATA := ${DATA}' \
		'OUT := ${OUT}' \
		'TMP := ${TMP}' \
		> "build.mk"; \
	fi
	@if test ! -d "${SRC}"; then \
		printf "Creating '%s'\n" '${SRC}'; \
		mkdir -p ${SRC}; \
		printf "%s\n" \
		'Hello, {{ site.title }}' \
		> ${SRC}/hello.txt.j2; \
	fi

.PHONY: init all