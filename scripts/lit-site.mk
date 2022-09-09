
# how to use this makefile
# ------------------------
#
# initialize a new git repository and add lit as a submodule
# - git@github.com:benjaminogles/lit
#
# md4c is also expected as a submodule to provide md2html
# if that is already in your path then override MD4C_SUBMODULE_PATH to be empty
# - git@github.com:mity/md4c
#
# create a src directory to hold the website source files
# the src directory itself contains source files for the site entry point
# each subdirectory contains the source files for the page /subdirectory/path/index.html
#
# the makefile for your project should include this one and
# set the target specific variables
# - PAGE_AUTHOR
# - PAGE_METAS
# - PAGE_HEADERS
# - PAGE_FOOTERS
# for each $(TARGET_DIR)/subdirectory/path/index.html

# these variables may be given by the command line
# all other variables are only used for readability of the make file
TOOLS_DIR :=
TARGET_DIR := build
SOURCE_DIR := src
LIT_SUBMODULE_PATH := lit
MD4C_SUBMODULE_PATH := md4c

# tell make to delete targets when recipes fail
.DELETE_ON_ERROR:

# specify the default target explicitly
.DEFAULT_GOAL := all

# targets that are actually commands
.PHONY: all clean

# set up tools we need to build the site
LIT2MD := $(LIT_SUBMODULE_PATH)/lit2md
LIT2HTML := $(LIT_SUBMODULE_PATH)/lit2html

ifdef MD4C_SUBMODULE_PATH
TOOLS_DIR := subbuild
MD2HTML := $(TOOLS_DIR)/bin/md2html

# md2html lives in a submodule
$(MD4C_SUBMODULE_PATH)/md2html:
	git submodule update --init $(MD4C_SUBMODULE_PATH)
	cmake -B $(MD4C_SUBMODULE_PATH)/build -S $(MD4C_SUBMODULE_PATH) -DCMAKE_INSTALL_PREFIX=$(TOOLS_DIR)

# build and install it into the tools directory
$(MD2HTML): | $(MD4C_SUBMODULE_PATH)/md2html
	make -C $(MD4C_SUBMODULE_PATH)/build install

# lit scripts use md2html
export PATH := $(TOOLS_DIR)/bin:$(PATH)
export LD_LIBRARY_PATH := $(TOOLS_DIR)/lib:$(LD_LIBRARY_PATH)
$(LIT2MD) $(LIT2HTML): | $(MD2HTML)
	echo "$@ will use $(MD2HTML)"
endif

# map each source directory to its target location
SOURCE_DIRS := $(shell find "$(SOURCE_DIR)" -type d)
TARGET_DIRS := $(patsubst $(SOURCE_DIR)%,$(TARGET_DIR)%,$(SOURCE_DIRS))

# default goal builds all pages
all: $(addsuffix /index.html,$(TARGET_DIRS))

# recipe to build a single page from a directory
define target_page_rules =

# map input directory and files to target locations
SRC_DIR := $(1)
TGT_DIR := $(patsubst $(SOURCE_DIR)%,$(TARGET_DIR)%,$(1))
SRC_FILES := $(wildcard $(1)/[0-9]*)
TGT_FILES = $(addsuffix .md,$(patsubst $(SOURCE_DIR)%,$(TARGET_DIR)%,$(wildcard $(1)/[0-9]*)))

# providing the target directory is simple
$$(TGT_DIR):
	mkdir -p $$@

# lit2html is used to build a page and install it to a target location with links to assets
$$(TGT_DIR)/index.html $$(TGT_FILES): | $$(TGT_DIR) $(TARGET_DIR)/css $(LIT2HTML)

# a page depends directly on its source files and html fragments
$$(TGT_DIR)/index.html: $$(TGT_FILES)
$$(TGT_DIR)/index.html: $(wildcard fragments/*.html)

# put together all markdown and html fragments to build the page
$$(TGT_DIR)/index.html:
	$(LIT2HTML) \
		-a "$$(PAGE_AUTHOR)" \
		-t "$$(PAGE_TITLE)" \
		-d "$$(PAGE_DESCRIPTION)" \
		$$(foreach m,$$(PAGE_METAS),-m $$(m)) \
		$$(foreach h,$$(PAGE_HEADERS),-h $$(h)) \
		$$(foreach f,$$(PAGE_FOOTERS),-f $$(f)) \
		-o $$@ $$(filter %.md,$$^)

# markdown source files can be copied to their target locations
$$(filter %.md.md,$$(TGT_FILES)): $(TARGET_DIR)/%.md: $(SOURCE_DIR)/%
	cp "$$<" "$$@"

# other markdown targets are created by lit2md
$$(filter-out %.md.md,$$(TGT_FILES)): | $(LIT2MD)

$$(filter-out %.md.md,$$(TGT_FILES)): $(TARGET_DIR)/%.md: $(SOURCE_DIR)/%
	$(LIT2MD) -o "$$@" $$<

endef

# evaluate the above template for each source directory
$(foreach d,$(SOURCE_DIRS),$(eval $(call target_page_rules,$(d))))

clean:
	[ -d "$(TARGET_DIR)" ] && rm -r "$(TARGET_DIR)"
	[ -d "$(TOOLS_DIR)" ] && rm -r "$(TOOLS_DIR)"
