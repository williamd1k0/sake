SHELL = /bin/sh

# Default configs
SITE_CONF := site.yml
INCLUDES :=
EXCLUDES :=
SRC := src
DATA :=
OUT := out
CACHE := .cache
MD_FLAGS += --gfm --unsafe

# User-defined configs
sinclude build.mk

ifneq "${MAKECMDGOALS}" "init"
ifneq "${INCLUDES}" ""
ALL_INCLUDES := $(patsubst %, ${CACHE}/%, $(shell fd -tf . ${INCLUDES}))
endif
GLOBAL_EXCLUDES := *.meta
VARS_SOURCES := ${CACHE}/site.json
ifneq "${DATA}" ""
DATA_SOURCES := $(shell fd -tf -e yml . ${DATA})
DATA_TARGETS := $(patsubst ${DATA}/%.yml, ${CACHE}/data/%.json, ${DATA_SOURCES})
VARS_SOURCES += ${CACHE}/data.json
endif
VARS_TARGET := ${CACHE}/vars.json
ALL_EXCLUDES := $(patsubst %, -E '%', ${GLOBAL_EXCLUDES} ${EXCLUDES})
COPY_SOURCES := $(shell fd -tf . ${SRC} -E '*.j2' ${ALL_EXCLUDES})
TEMPLATE_SOURCES = $(patsubst %.md,%.html,$(patsubst %.j2, %, $(shell fd -tf -e j2 . ${SRC} ${ALL_EXCLUDES})))
TARGETS = $(patsubst ${SRC}/%,${OUT}/%, ${COPY_SOURCES} ${TEMPLATE_SOURCES})
endif

optreq = $(shell test -f $1 && echo $1)
log1 = printf "[$1] %s\n" '$2'
log2 = printf "[$1] %s > %s\n" '$2' '$3'

all: ${VARS_TARGET} ${ALL_INCLUDES} ${TARGETS}

${CACHE}/site.json: ${SITE_CONF}
	mkdir -p ${CACHE} && yj $< | jq '. | { site: . }' > $@

${CACHE}/data/%.json: ${DATA}/%.yml
	mkdir -p ${CACHE}/data && yj $< | jq '. | { $(patsubst %.yml, %, "${<F}"): . }' > $@

${CACHE}/data.json: ${DATA_TARGETS}
	jq -s add $^ | jq '. | { data: . }' > $@

${VARS_TARGET}: ${VARS_SOURCES}
	jq -s add $^ > $@

${CACHE}/%: %
	mkdir -p '$(@D)' && cp -r '$<' '$@'

define PROCESS_META
echo > ${CACHE}/page.json
if test -f "$(patsubst %.j2,%.meta,$<)"; then \
	$(call log1,meta,$(patsubst %.j2,%.meta,$<)); \
	yj '$(patsubst %.j2,%.meta,$<)' | jq '. | { page: . }' > ${CACHE}/page.json; \
fi
jq -s add ${VARS_TARGET} ${CACHE}/page.json > ${CACHE}/input.json
endef

define PROCESS_TEMPLATE
$(call log2,jinja,$<,$@)
jinja2 --format json '${CACHE}/input.j2' '${CACHE}/input.json' > ${CACHE}/output
mkdir -p '$(@D)'
cp '${CACHE}/output' '$@'
endef

${OUT}/%: ${SRC}/%.j2 $(call optreq,${SRC}/%.meta) ${VARS_TARGET} ${ALL_INCLUDES}
	$(PROCESS_META)
	cp '$<' ${CACHE}/input.j2
	$(PROCESS_TEMPLATE)

${OUT}/%.html: ${SRC}/%.md.j2 $(call optreq,${SRC}/%.md.meta) ${VARS_TARGET} ${ALL_INCLUDES}
	$(PROCESS_META)
	$(call log2,comrak,$<,$@)
	comrak ${MD_FLAGS} '$<' -o ${CACHE}/input.j2
	$(PROCESS_TEMPLATE)

${OUT}/%: ${SRC}/%
	$(call log2,copy,$<,$@)
	mkdir -p '$(@D)' && cp '$<' '$@'

init:
	if test ! -f "${SITE_CONF}"; then \
		$(call log1,create,${SITE_CONF}); \
		printf "%s\n" \
		'title: New Sake Site' \
		'baseurl: ' \
		> ${SITE_CONF}; \
	fi
	if test ! -f "build.mk"; then \
		$(call log1,create,build.mk); \
		printf "%s\n" \
		'SITE_CONF := ${SITE_CONF}' \
		'INCLUDES := ${INCLUDES}' \
		'EXCLUDES := ${EXCLUDES}' \
		'SRC := ${SRC}' \
		'DATA := ${DATA}' \
		'OUT := ${OUT}' \
		'CACHE := ${CACHE}' \
		> "build.mk"; \
	fi
	if test ! -d "${SRC}"; then \
		$(call log1,create,${SRC}/hello.txt.j2); \
		mkdir -p ${SRC}; \
		printf "%s\n" \
		'Hello, {{ site.title }}' \
		> ${SRC}/hello.txt.j2; \
	fi

.PHONY: init all
.SILENT:
