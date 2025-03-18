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
#       Feb 17, 2025
#
################################################################################
#
#   Copyright (C) 2025 Linkage Design
#
#   The software as information contained herein are propietary to, and
#   comprise valuable trade secrets of Linkage Design, whom intends
#   to preseve as trade secrets such software and information. This sofware
#   and information or any copies thereof may not be provided or otherwise
#   made available to any other person or organization.
#
################################################################################
PROJECT			= $(lastword $(subst /, ,$(shell pwd)))
PLATFORM 		= $(shell uname)
TARGET			= $(strip $(if $(MAKECMDGOALS), $(MAKECMDGOALS), default))

DATE			= $(shell date "+%b %d, %Y")
TIME			= $(shell date "+%I:%M:%S %p")

COMPANY			= Linkage Design
LICENSE_FILE	= LICENSE

#  Detirmine the Version of this Project
BRANCH          = $(lastword $(subst /, ,$(shell git branch --show-current)))
LASTVERS      	= $(shell git describe --tags --abbrev=0)
VERSION 		= $(strip 														\
				      $(if $(filter main,$(BRANCH)),							\
 					      $(shell git describe --tags --abbrev=0),				\
			  		      v0.0.0												\
					  )															\
				   )

#  Define the Locations of the Source, Build, and Distribution Files
SOURCE_LOCATION     = source
BUILD_LOCATION      = build
DIST_LOCATION       = dist
TEST_LOCATION 		= $(HOME)/Library/Application\ Support/Blender/$(BLENDER_VERSION)/extensions/user_default

BUILD_FILES		 	= $(wildcard $(BUILD_LOCATION)/*)
SOURCE_FILES        = $(wildcard $(SOURCE_LOCATION)/*)

#  Define the VPATH
VPATH				= $(BUILD_LOCATION) $(SOURCE_LOCATION) $(DIST_LOCATION)


################################################################################
#
#	Blender Manifest Definitions
#
################################################################################
BLENDER_VERSION     = 4.3
BL_MANIFEST_FILE    = blender_manifest.toml
BL_SCHEMA_VERSION   = "1.0.0"
BL_ID				= "$(firstword $(COMPANY))$(PROJECT)"
BL_NAME				= "$(firstword $(COMPANY)) $(strip $(shell echo $(PROJECT) | sed 's/[A-Z]/ &/g'))"
BL_VERSION			= $(shell echo $(VERSION) | tr -d [a-z][A-Z])
BL_TAGLINE			= "Align the selected object(s) bounding box or origin to the world coordinate system."
BL_MAINTAINER		= "$(COMPANY) <acheck@linkage-d.com>"
BL_TYPE				= "add-on"
BL_TAGS				= ["Object"]
BL_VERSION_MIN		= "4.2.0"
BL_LICENSE			= ["SPDX:GPL-3.0-or-later"]
BL_WEBSITE			= "https://blendermarket.com/products/linkage-object-aligner"
BL_COPYRIGHT		= ["2024 $(COMPANY)"]


################################################################################
#
#	Function and Macros Definitions
#
################################################################################
CHKDIR 			= printf '\e[33m%20s\e[0m $(1)\n' "Validating Folder"; 			\
				  if ! test -d $(1); then 										\
				      mkdir -p $(1); 											\
				  fi
COPY 			= if test -f $(1); then 										\
			  		  printf '\e[33m%20s\e[0m $(1)\n' "Copying";				\
					  cp -r $(1) $(2);											\
				  fi
DELETE 			= if test -e $(1); then 										\
				      printf '\e[31m%20s\e[0m $(1)\n' "Deleting";				\
				      rm -rf $(1);												\
				  fi
BUILD_MANIFEST	= printf '\e[33m%20s\e[0m $(1)\n' "Creating Manifest";			\
				  printf 'schema_version = $(BL_SCHEMA_VERSION)\n' > $(1);		\
				  printf 'id = $(BL_ID)\n' >> $(1);	                        	\
				  printf 'version = "$(BL_VERSION)"\n' >> $(1);					\
				  printf 'name = $(BL_NAME)\n' >> $(1);							\
				  printf 'maintainer = $(BL_MAINTAINER)\n' >> $(1);				\
				  printf 'tagline = $(BL_TAGLINE)\n' >> $(1);					\
				  printf 'type = $(BL_TYPE)\n' >> $(1);							\
				  printf 'tags = $(BL_TAGS)\n' >> $(1);							\
				  printf 'blender_version_min = $(BL_VERSION_MIN)\n' >> $(1);	\
				  printf 'license = $(BL_LICENSE)\n' >> $(1);					\
				  printf 'website = $(BL_WEBSITE)\n' >> $(1);					\
				  printf 'copyright = $(BL_COPYRIGHT)\n' >> $(1);

INFO 			= printf '\e[33m%20s\e[0m %s\n' $(1) $(2);
LABEL 			= printf '\e[36m%20s\e[0m\n' $(1);
LINE			= printf '\e[37m%0.s-\e[0m' {1..80}; 							\
				  printf '\n';
PACKAGE 		= printf '\e[33m%20s\e[0m $(1)\n' "Packaging"; 					\
				  zip -jq $(DIST_LOCATION)/$(1) $(2);


################################################################################
#
#	Build Targets
#
################################################################################
default: BANNER
	@$(call LABEL,"Starting Default Target...")
	@$(call CHKDIR,$(BUILD_LOCATION))
	@$(call COPY,$(LICENSE_FILE),$(BUILD_LOCATION))
	@$(foreach FILE,$(SOURCE_FILES),											\
		$(call COPY,$(FILE),$(BUILD_LOCATION));									)
	@$(call BUILD_MANIFEST,$(BUILD_LOCATION)/$(BL_MANIFEST_FILE))
	@$(call LABEL,"Finished Default Target...")


dist: BANNER
	@$(call LABEL,"Starting Distribution Target....")
	@$(call CHKDIR,$(DIST_LOCATION))
	@$(call PACKAGE,$(PROJECT)-$(VERSION).zip,$(wildcard $(BUILD_LOCATION)/*))
	@$(call LABEL,"Distribution Target Finished...")


#  Clean Targets
clean: BANNER
	@$(call LABEL,"Starting Clean Target...")
	@$(foreach ITEM, $(shell ls -A $(BUILD_LOCATION)),							\
		$(call DELETE,$(BUILD_LOCATION)/$(ITEM));								)
	@$(call LABEL,"Clean Target Finished...")


clobber: BANNER
	@$(call LABEL,"Starting Clobber Target...")
	@$(call DELETE,$(BUILD_LOCATION))
	@$(call DELETE,$(DIST_LOCATION))
	@$(call LABEL,"Clobber Target Finished...")


#  Test Targets
test: default dist BANNER
	@$(call LABEL,"Installing local version of $(PROJECT)...")
	@$(call DELETE,$(TEST_LOCATION)/$(PROJECT))
	@unzip -q $(DIST_LOCATION)/$(PROJECT)-$(VERSION).zip -d $(TEST_LOCATION)/$(PROJECT)
	@$(call LABEL,"Launching Blender...")
	@blender


#	Informational Targets
BANNER:
	@$(call LINE)
	@$(call INFO)
	@$(call INFO,Project,$(PROJECT))
	@$(call INFO,Platform,$(PLATFORM))
	@$(call INFO)
	@$(call INFO,Target,$(TARGET))
	@$(call INFO,Version,$(VERSION))
	@$(call INFO)
	@$(call INFO,Date,"$(DATE)")
	@$(call INFO,Time,"$(TIME)")
	@$(call INFO)
	@$(call LINE)


info: BANNER
	@$(call INFO)
	@$(call INFO,SOURCE_LOCATION,$(SOURCE_LOCATION))
	@$(call INFO,BUILD_LOCATION,$(BUILD_LOCATION))
	@$(call INFO,DIST_LOCATION,$(DIST_LOCATION))
	@$(call INFO)
	@$(call INFO,SOURCE_FILES)
	@$(foreach ITEM, $(SOURCE_FILES), $(call INFO,"    ",$(ITEM)))
	@$(call INFO)
	@$(call INFO,BUILD_FILES)
	@$(foreach ITEM, $(BUILD_FILES), $(call INFO,"    ",$(ITEM)))
	@$(call INFO)
	@$(call INFO,VPATH)
	@$(foreach ITEM, $(VPATH), $(call INFO,"    ",$(ITEM)))
	@$(call INFO)
	@$(call INFO,BLENDER_VERSION,$(BLENDER_VERSION))
	@$(call INFO,BL_MANIFEST_FILE,$(BL_MANIFEST_FILE))
	@$(call INFO,BL_SCHEMA_VERSION,$(BL_SCHEMA_VERSION))
	@$(call INFO,BL_ID,$(BL_ID))
	@$(call INFO,BL_NAME,$(BL_NAME))
	@$(call INFO,BL_VERSION,$(BL_VERSION))
	@$(call INFO,BL_TAGLINE,$(BL_TAGLINE))
	@$(call INFO,BL_MAINTAINER,$(BL_MAINTAINER))
	@$(call INFO,BL_TYPE,$(BL_TYPE))
	@$(call INFO,BL_TAGS,$(BL_TAGS))
	@$(call INFO,BL_VERSION_MIN,$(BL_VERSION_MIN))
	@$(call INFO,BL_LICENSE,$(BL_LICENSE))
	@$(call INFO,BL_WEBSITE,$(BL_WEBSITE))
	@$(call INFO,BL_COPYRIGHT,$(BL_COPYRIGHT))
	@$(call LINE)
