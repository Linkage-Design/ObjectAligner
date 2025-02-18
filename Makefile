################################################################################
#
#   Makefile
#
################################################################################
#
#   DESCRIPTION
#
#
#   AUTHOR
#       Jayme Wilkinson
#
#   CREATED
#       Feb 17, 2025 Initial Version
#
################################################################################
#
#   Copyright (C) 2025 Jayme Wilkinson
#
#   The software as information contained herein are propietary to, and
#   comprise valuable trade secrets of Jayme Wilkinson, whom intends
#   to preseve as trade secrets such software and information. This sofware
#   and information or any copies thereof may not be provided or otherwise
#   made available to any other person or organization.
#
################################################################################
PROJECT				= $(lastword $(subst /, ,$(shell pwd)))
PLATFORM 			= $(shell uname)
TARGET				= $(strip $(if $(MAKECMDGOALS), $(MAKECMDGOALS), release))
VERSION 			= $(shell git tag --list)

DATE				= $(shell date "+%b %d, %Y")
TIME				= $(shell date "+%H:%M:%S")

SOURCE_LOCATION		= `pwd`
BUILD_LOCATION		= build
DIST_LOCATION		= dist

SOURCES				= LICENSE  __init__.py blender_manifest.toml

VPATH				:= $(BUILD_LOCATION) $(SOURCE_LOCATION) $(DIST_LOCATION)


################################################################################
#
#	Function and Macros Definitions
#
################################################################################
CHKDIR 	= if ! test -d $(1); then mkdir -p $(1); fi

NORM	:= \033[0m
BOLD	:= \033[1m
UNDER	:= \033[4m
BLINK	:= \033[5m

YELLOW	:= \033[1;37m
RED		:= \033[1;31m
GREEN	:= \033[1;32m
YELLOW	:= \033[1;33m
BLUE	:= \033[1;34m
MAGENTA	:= \033[1;35m
CYAN	:= \033[1;36m
WHITE	:= \033[1;37m

################################################################################
#
#	Build Targets
#
################################################################################
release: BANNER
	@printf "Starting Release Build...\n"
	@$(call CHKDIR, $(BUILD_LOCATION))
	@$(foreach FILE, $(SOURCES),												\
		printf "    $(BUILD_LOCATION)/$(FILE)\n";								\
		cp $(FILE) $(BUILD_LOCATION)/$(FILE);									)
	@printf "Release Completed...\n"


dist: BANNER
	@printf "Starting Distribution Build...\n"
	@$(call CHKDIR, $(DIST_LOCATION))
	@zip $(DIST_LOCATION)/$(PROJECT)-$(VERSION).zip $(SOURCES)
	@printf "Distribution Completed...\n"


################################################################################
#
#  Clean Targets
#
################################################################################
clean: BANNER
	@$(foreach ITEM, $(shell ls -A $(BUILD_LOCATION)),							\
		rm -fv $(BUILD_LOCATION)/$(ITEM);										)
	@printf "Clean Completed...\n"


clobber: BANNER
	@rm -rf $(BUILD_LOCATION)
	@rm -rf $(DIST_LOCATION)
	@printf "Clobber Completed...\n"

###############################################################################
#
#	Informational Targets
#
###############################################################################
BANNER:
	@printf "$(CYAN)*********************************************************************************$(NORM)\n"
	@printf "$(CYAN)*$(NORM)\n"
	@printf "$(CYAN)*$(YELLOW)          Project $(WHITE)$(PROJECT)$(NORM)\n"
	@printf "$(CYAN)*$(YELLOW)         Platform $(WHITE)$(PLATFORM)$(NORM)\n"
	@printf "$(CYAN)*$(NORM)\n"
	@printf "$(CYAN)*$(YELLOW)           Target $(WHITE)$(TARGET)$(NORM)\n"
	@printf "$(CYAN)*$(YELLOW)          Version $(WHITE)$(VERSION)$(NORM)\n"
	@printf "$(CYAN)*$(NORM)\n"
	@printf "$(CYAN)*$(YELLOW)             Date $(WHITE)$(DATE)$(NORM)\n"
	@printf "$(CYAN)*$(YELLOW)             Time $(WHITE)$(TIME)$(NORM)\n"
	@printf "$(CYAN)*$(NORM)\n"
	@printf "$(CYAN)*********************************************************************************$(NORM)\n"


info: BANNER
	@printf "   $(YELLOW)SOURCE_LOCATION $(NORM)$(SOURCE_LOCATION)\n"
	@printf "    $(YELLOW)BUILD_LOCATION $(NORM)$(BUILD_LOCATION)\n"
	@printf "  $(YELLOW)RELEASE_LOCATION $(NORM)$(RELEASE_LOCATION)\n"
	@printf "     $(YELLOW)DIST_LOCATION $(NORM)$(DIST_LOCATION)\n"
	@printf "\n"
	@printf "           $(YELLOW)SOURCES$(NORM) "
	@$(foreach SOURCE, $(SOURCES), printf "$(SOURCE)\n                   ";)
	@printf "\n"
	@printf "           $(YELLOW)OBJECTS$(NORM) "
	@$(foreach OBJECT, $(OBJECTS), printf "$(OBJECT)\n                   ";)
	@printf "\n"
	@printf "             $(YELLOW)VPATH$(NORM) "
	@$(foreach ITEM, $(VPATH), echo "$(ITEM)\n                   ";)
	@printf "\n"
