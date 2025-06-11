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
PROJECT				= $(notdir $(shell pwd))
COMPANY				= Linkage Design
CONTACT				= acheck@linkage-d.com
LICENSE_FILE		= LICENSE

#	Blender Manifest Definitions
BLENDER_VERSION     = 4.3
BL_MANIFEST_FILE    = blender_manifest.toml
BL_SCHEMA_VERSION   = "1.0.0"
BL_ID				= "$(firstword $(COMPANY))$(PROJECT)"
BL_NAME				= "$(firstword $(COMPANY)) $(strip $(shell echo $(PROJECT)	\
					  | sed 's/[A-Z]/ &/g'))"
BL_VERSION			= $(shell echo $(VERSION) | tr -d [a-z][A-Z])
BL_TAGLINE			= "Align an object bounding box or orgin to world coordinates"
BL_MAINTAINER		= "$(COMPANY) <$(CONTACT)>"
BL_TYPE				= "add-on"
BL_TAGS				= ["Object"]
BL_VERSION_MIN		= "4.2.0"
BL_LICENSE			= ["SPDX:GPL-3.0-or-later"]
BL_WEBSITE			= "https://linkage-d.com"
BL_COPYRIGHT		= ["2024 $(COMPANY)"]


################################################################################
#
#							  W A R N I N G
#
################################################################################
#
#		There are no configurable build options below this section.
#		Any customizable variables that define how this project is
#		built packaged, or how the manifest is created are defined
#		above this section.
#
#		Modifing any of the information below could cause errors
#		in the build process.
#
################################################################################

#  	Get the Target Platform
TARGET			= $(strip $(if $(MAKECMDGOALS), $(MAKECMDGOALS), default))
PLATFORM 		= $(shell uname)

#  	Get the Date and Time
DATE			= $(shell date "+%Y-%m-%d")
TIME			= $(shell date "+%H:%M:%S")

#  Detirmine the Branch and Version of this Project
BRANCH  		= $(if $(filter 0,$(words $(shell ls -A .git))),				\
			 	      "NONE",													\
			   		  $(shell git branch --show-current)						\
                  )
VERSION 		= $(strip 														\
				      $(if $(filter main,$(BRANCH)),							\
 					      $(shell git describe --tags --abbrev=0),				\
			  		      v0.0.0												\
					  )															\
				  )

#	Define the Package Name and File
PACKAGE_NAME	= $(firstword $(COMPANY))$(PROJECT)
PACKAGE_FILE    = $(PACKAGE_NAME)-$(VERSION).zip

#  Define the Locations of the Source, Build, and Distribution Files
SOURCE_LOCATION = source
ICON_LOCATION   = icons
BUILD_LOCATION  = build
DIST_LOCATION   = dist

BUILD_FILES		= $(shell ls -Ar $(BUILD_LOCATION))
SOURCE_FILES    = $(wildcard $(SOURCE_LOCATION)/*)
ICON_FILES	    = $(wildcard $(ICON_LOCATION)/*)

#  Define the VPATH
VPATH           = $(BUILD_LOCATION) $(SOURCE_LOCATION) $(DIST_LOCATION)


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
			  $(call INFO,"Copying File",$(1))									\
			  cp -r $(1) $(2);													\
		  fi
DELETE  = if test -e $(1); then                                         		\
			  $(call INFO,"Deleting File",$(1))   					        	\
			  rm -fr $(1);                                              		\
		  fi
EDGE    = $(if $(filter 0,$(words $(1))),										\
			   printf "\e[36;1m%0.s*\e[0m" {0..80};	printf "\n";,				\
			   printf "\e[36;1m*\e[33m%19s\e[37m %s\e[0m\n" $(1) $(2);			\
		   )
ERROR	= printf "\e[31m%20s\e[0m %s\n" $(1) $(2);
INFO 	= printf "\e[33m%20s\e[0m %s\n" $(1) $(2);
LABEL   = printf "\e[35m%s\e[0m\n" $(1);
LIST    = printf "\e[33m%20s\e[0m" $(1);										\
		  $(foreach ITEM, $(2), 												\
			  printf " %s\n%20s" $(ITEM);										\
		   )																	\
		   printf "\r";


################################################################################
#
#	Blender Functions Definitions
#
################################################################################
BLENDER_BUILD	 = blender --command extension build							\
				       --verbose  												\
				       --source-dir $(BUILD_LOCATION) 							\
				       --output-filepath $(1);
BLENDER_INSTALL  = if test -e $(1); then 										\
					   $(call INFO,"Installing Add-On",$(1))					\
					   blender --command extension install-file -e -r 			\
					   user_default $(1);										\
				   else 														\
					   $(call ERROR,"Could Not Find",$(1))						\
				   fi
BLENDER_MANIFEST = $(call INFO,"Creating Manifest",$(1))						\
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
BLENDER_REMOVE   = $(if $(filter 1,$(shell 										\
						blender --command extension list | grep -c $(1))),		\
						$(call INFO,"Removing Add-On",$(1))						\
						blender --command extension remove $(1),				\
						$(call ERROR,$(1),"Is Not Installed")					\
					)
BLENDER_VALIDATE = blender --command extension validate $(1);


################################################################################
#
#	Build Targets
#
################################################################################
default: BANNER
	@$(call LABEL,"Building $(PACKAGE_NAME)")
	@$(call CHKDIR,$(BUILD_LOCATION))
	@$(call COPY,$(LICENSE_FILE),$(BUILD_LOCATION))
	@$(foreach FILE,$(SOURCE_FILES),											\
		$(call COPY,$(FILE),$(BUILD_LOCATION));									\
	)
	@$(call CHKDIR,$(BUILD_LOCATION)/$(ICON_LOCATION))
	@$(foreach ICON,$(ICON_FILES),												\
		$(call COPY,$(ICON),$(BUILD_LOCATION)/$(ICON_LOCATION));				\
	)
	@$(call BLENDER_MANIFEST,$(BUILD_LOCATION)/$(BL_MANIFEST_FILE))
	@$(call BLANK)

dist: BANNER
	@$(call LABEL,"Creating $(PACKAGE_NAME)")
	@$(call CHKDIR,$(DIST_LOCATION))
	@$(call BLANK)
	@$(call LABEL,"Building $(PACKAGE_FILE)")
	@$(call BLENDER_BUILD,$(DIST_LOCATION)/$(PACKAGE_FILE))
	@$(call BLANK)

check: BANNER
	@$(call LABEL,"Validating $(PACKAGE_FILE)")
	@$(call BLENDER_VALIDATE,$(DIST_LOCATION)/$(PACKAGE_FILE))
	@$(call BLANK)


################################################################################
#
#  	Clean Targets
#
################################################################################
clean: BANNER
	@$(call LABEL,"Cleaning $(PROJECT)")
	@$(foreach ITEM, $(shell ls -A $(BUILD_LOCATION)),							\
		$(call DELETE,$(BUILD_LOCATION)/$(ITEM));								)
	@$(call BLANK)

clobber: BANNER
	@$(call LABEL,"Clobber $(PROJECT)")
	@$(foreach ITEM, $(shell ls -A $(BUILD_LOCATION)),							\
		$(call DELETE,$(BUILD_LOCATION)/$(ITEM));				 				\
	)
	@$(call DELETE,$(BUILD_LOCATION)/$(ICON_LOCATION))
	@$(call DELETE,$(DIST_LOCATION)/$(PACKAGE_FILE))
	@$(call BLENDER_REMOVE,$(PACKAGE_NAME))
	@$(call BLANK)


################################################################################
#
#	Install and Uninstall Targets
#
################################################################################
inst: BANNER
	@$(call LABEL,"Installing $(PACKAGE_FILE)")
	@$(call BLENDER_INSTALL,$(DIST_LOCATION)/$(PACKAGE_FILE))
	@$(call BLANK)

uninst: BANNER
	@$(call LABEL,"Un-Installing $(PACKAGE_NAME)")
	@$(call BLENDER_REMOVE,$(PACKAGE_NAME))
	@$(call BLANK)


###############################################################################
#
#  	Test Targets
#
################################################################################
test: BANNER clean default dist check inst
	@$(call LABEL,"Launching Blender...")
	@blender
	@$(call BLANK)


################################################################################
#
#	Informational Targets
#
################################################################################
BANNER:
	@$(call EDGE)
	@$(call EDGE,"")
	@$(call EDGE,Project,$(PROJECT))
	@$(call EDGE,Platform,$(PLATFORM))
	@$(call EDGE,"")
	@$(call EDGE,Target,$(TARGET))
	@$(call EDGE,"")
	@$(call EDGE,Branch,$(BRANCH))
	@$(call EDGE,Version,$(VERSION))
	@$(call EDGE,"Package File",$(PACKAGE_FILE))
	@$(call EDGE,"")
	@$(call EDGE,Date,"$(DATE)")
	@$(call EDGE,Time,"$(TIME)")
	@$(call EDGE,"")
	@$(call EDGE)

BLENDER_INFO:
	@$(call LABEL,"Blender Manifest Data")
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
	@$(call LABEL,"Blender Repo List")
	@$(call BLANK)
	@blender --command extension repo-list
	@$(call BLANK)

info: BANNER
	@$(call LIST,SOURCE_LOCATION,$(SOURCE_LOCATION))
	@$(call LIST,BUILD_LOCATION,$(BUILD_LOCATION))
	@$(call LIST,DIST_LOCATION,$(DIST_LOCATION))
	@$(call BLANK)
	@$(call LIST,"SOURCE_FILES",$(SOURCE_FILES))
	@$(call BLANK)
	@$(call LIST,"ICON_FILES",$(ICON_FILES))
	@$(call BLANK)
	@$(call LIST,"BUILD_FILES",$(BUILD_FILES))
	@$(call BLANK)
	@$(call LIST,"VPATH",$(VPATH))
	@$(call BLANK)
	@MAKE BLENDER_INFO
