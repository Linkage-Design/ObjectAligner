################################################################################
#
#   Makefile
#
################################################################################
#
#   DESCRIPTION
#		This Makefile is used to build, package, and test the Linkage Design
#		Object Aligner Blender Add-on
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
PROJECT			= $(notdir $(shell pwd))
PLATFORM 		= $(shell uname)

DATE			= $(shell date "+%Y-%b-%d")
TIME			= $(shell date "+%H:%M:%S")

COMPANY			= Linkage Design
CONTACT			= <acheck@linkage-d.com>
LICENSE_FILE	= LICENSE

#  Detirmine the Version of this Project
BRANCH          = $(lastword $(subst /, ,$(shell git branch --show-current)))
VERSION 		= $(strip 														\
				      $(if $(filter main,$(BRANCH)),							\
 					      $(shell git describe --tags --abbrev=0),				\
			  		      v0.0.0												\
					  )															\
				  )
PACKAGE_FILE    = $(PROJECT)-$(VERSION).zip

#  Define the Locations of the Source, Build, and Distribution Files
SOURCE_LOCATION = source
ICON_LOCATION   = icons
BUILD_LOCATION  = build
DIST_LOCATION   = dist

BUILD_FILES		= $(wildcard $(BUILD_LOCATION)/*)
SOURCE_FILES    = $(wildcard $(SOURCE_LOCATION)/*)
ICON_FILES		= $(wildcard $(ICON_LOCATION)/*)

#  Define the VPATH
VPATH           = $(BUILD_LOCATION) $(SOURCE_LOCATION) $(DIST_LOCATION)

#	Blender Manifest Definitions
BLENDER_VERSION     = 4.3
BL_MANIFEST_FILE    = blender_manifest.toml
BL_SCHEMA_VERSION   = "1.0.0"
BL_ID				= "$(PROJECT)"
BL_NAME				= "$(strip $(shell echo $(PROJECT) | sed 's/[A-Z]/ &/g'))"
BL_VERSION			= $(shell echo $(VERSION) | tr -d [a-z][A-Z])
BL_TAGLINE			= "Align an object bounding box or orgin to world coordinates"
BL_MAINTAINER		= "$(COMPANY) <acheck@linkage-d.com>"
BL_TYPE				= "add-on"
BL_TAGS				= ["Object"]
BL_VERSION_MIN		= "4.2.0"
BL_LICENSE			= ["SPDX:GPL-3.0-or-later"]
BL_WEBSITE			= "https://blendermarket.com/products/linkage-object-aligner"
BL_COPYRIGHT		= ["2024 $(COMPANY)"]


################################################################################
#
#								N O T I C E
#
################################################################################
#
#		There are no configurable build options below this section.
#		Any customizable variables that define how this project is built
#		packaged, or how the manifest is created are defined above this
#		line. Modifiing any of the information below might break the makefile.
#
################################################################################

################################################################################
#
#	Blender Functions Definitions
#
################################################################################
BLENDER_BUILD	 = $(call INFO,"Building Add-On",$(1)) 							\
				   blender --command extension build --verbose					\
				    --source-dir $(BUILD_LOCATION) 								\
					--output-filepath $(1);
BLENDER_INSTALL  = blender --command extension install-file 					\
					-r user_default $(1);
BLENDER_MANIFEST = $(call INFO,"Creating",$(1))									\
				   printf 'schema_version = $(BL_SCHEMA_VERSION)\n' > $(1);		\
				   printf 'id = $(BL_ID)\n' >> $(1);	                       	\
				   printf 'version = "$(BL_VERSION)"\n' >> $(1);				\
				   printf 'name = $(BL_NAME)\n' >> $(1);						\
				   printf 'maintainer = $(BL_MAINTAINER)\n' >> $(1);			\
				   printf 'tagline = $(BL_TAGLINE)\n' >> $(1);					\
				   printf 'type = $(BL_TYPE)\n' >> $(1);						\
				   printf 'tags = $(BL_TAGS)\n' >> $(1);						\
				   printf 'blender_version_min = $(BL_VERSION_MIN)\n' >> $(1);	\
				   printf 'license = $(BL_LICENSE)\n' >> $(1);					\
				   printf 'website = $(BL_WEBSITE)\n' >> $(1);					\
				   printf 'copyright = $(BL_COPYRIGHT)\n' >> $(1);
BLENDER_REMOVE   = $(call INFO,"Removing Add-on",$(1))							\
                   blender --command extension remove $(1);
BLENDER_VALIDATE = $(call INFO,"Validating Add-On",$(1))						\
				   blender --command extension validate $(1);


################################################################################
#
#	Common Function Definitions
#
################################################################################
BLANK 	= printf '\n'
CHKDIR 	= $(call INFO,"Checking Folder",$(1))			 						\
		  if ! test -d $(1); then 												\
		      mkdir -p $(1); 													\
		  fi
COPY 	= if test -f $(1); then 												\
			  $(call INFO,"Copying",$(1))										\
			  cp -r $(1) $(2);													\
		  fi
DELETE  = if test -e $(1); then                                         		\
			  $(call INFO,"Removing",$(1))   					        		\
			  rm -fr $(1);                                              		\
		  fi
INFO 	= printf '\e[33;1m%20s\e[0m %s\n' $(1) $(2);
LABEL 	= printf "\e[36;1m*\e[33m%19s\e[37;1m %s\e[0m\n" $(1) $(2);
LINE    = printf "\e[36;1m%0.s*\e[0m" {0..80};	printf "\n";
LIST    = printf "\e[33;1m%20s\e[0m" $(1);										\
		  $(foreach ITEM, $(2), 												\
			  printf " %s\n%20s" $(ITEM);										\
		   )																	\
		   printf "\r";


################################################################################
#
#	Build Targets
#
################################################################################
default: BANNER
	@$(call CHKDIR,$(BUILD_LOCATION))
	@$(call COPY,$(LICENSE_FILE),$(BUILD_LOCATION))
	@$(foreach FILE,$(SOURCE_FILES),											\
		$(call COPY,$(FILE),$(BUILD_LOCATION));									)
	@$(call BLENDER_MANIFEST,$(BUILD_LOCATION)/$(BL_MANIFEST_FILE))
	@$(call DONE)

dist: BANNER
	@$(call CHKDIR,$(DIST_LOCATION))
	@$(call BLENDER_BUILD,$(DIST_LOCATION)/$(PACKAGE_FILE))
	@$(call BLENDER_VALIDATE,$(DIST_LOCATION)/$(PACKAGE_FILE))
	@$(call DONE)

check: BANNER
	@$(call INFO,"Validating Blender Add-on: $(PACKAGE_FILE)")
	@$(call BLENDER_VALIDATE,$(DIST_LOCATION)/$(PACKAGE_FILE))
	@$(call DONE)


################################################################################
#
#  	Clean Targets
#
################################################################################
clean: BANNER
	@$(foreach ITEM, $(shell ls -A $(BUILD_LOCATION)),							\
		$(call DELETE,$(BUILD_LOCATION)/$(ITEM));								)
	@$(call DONE)

clobber: BANNER
	@$(call DELETE,$(BUILD_LOCATION))
	@$(call DELETE,$(DIST_LOCATION))
	@$(call DONE)


################################################################################
#
#	Install and Uninstall Targets
#
################################################################################
inst: BANNER
	@$(call BLENDER_INSTALL,$(DIST_LOCATION)/$(PACKAGE_FILE))
	@$(call DONE)

uninst: BANNER
	@$(call BLENDER_REMOVE,$(PROJECT))
	@$(call DONE)


###############################################################################
#
#  	Test Targets
#
################################################################################
test: BANNER default dist inst
	@$(call INFO,"Launching Blender...")
	@blender


################################################################################
#
#	Informational Targets
#
################################################################################
BANNER:
	@$(call LINE)
	@$(call LABEL)
	@$(call LABEL,Project,$(PROJECT))
	@$(call LABEL,Platform,$(PLATFORM))
	@$(call LABEL)
	@$(call LABEL,Version,$(VERSION))
	@$(call LABEL)
	@$(call LABEL,Date,"$(DATE)")
	@$(call LABEL,Time,"$(TIME)")
	@$(call LABEL)
	@$(call LINE)

BLENDER_INFO:
	@$(call BLANK)
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
	@$(call BLANK)
	@$(call LINE)

info: BANNER BLENDER_INFO
	@$(call BLANK)
	@$(call LIST,"SOURCE_FILES",$(SOURCE_FILES))
	@$(call BLANK)
	@$(call INFO,DIST_LOCATION,$(DIST_LOCATION))
	@$(call BLANK)
	@$(call LIST,"BUILD_FILES",$(BUILD_FILES))
	@$(call BLANK)
	@$(call LIST,"VPATH",$(VPATH))
	@$(call BLANK)
