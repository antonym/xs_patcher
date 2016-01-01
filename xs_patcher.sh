#!/bin/bash
## xs_patcher
## detects xenserver version and applies the appropriate patches

## URL to patches: http://updates.xensource.com/XenServer/updates.xml

source /etc/xensource-inventory
TMP_DIR=$HOME/tmp
CACHE_DIR=$HOME/cache

function get_xs_version {
	get_version=`cat /etc/redhat-release | awk -F'-' {'print $1'}`
	case "${get_version}" in
		"XenServer release 6.0.0" )
		DISTRO="boston"
		;;

		"XenServer release 6.0.2" )
		DISTRO="sanibel"
		;;

		"XenServer release 6.1.0" )
		DISTRO="tampa"
		;;

		"XenServer release 6.2.0" )
		DISTRO="clearwater"
		;;

		"XenServer release 6.5.0" )
		DISTRO="creedence"
		;;

		* )
		echo "Unable to detect version of XenServer, terminating"
		exit 0
	;;

	esac
}

function apply_patches {
	[ -d $TMP_DIR ] || mkdir $TMP_DIR
	[ -d $CACHE_DIR ] || mkdir $CACHE_DIR

	echo "Looking for missing patches for $DISTRO..."

	grep -v '^#' patches/$DISTRO | while IFS='|'; read PATCH_NAME PATCH_UUID PATCH_URL PATCH_KB; do
		PATCH_FILE=$(echo $PATCH_URL | awk -F/ '{print $NF}')

		if [ -f /var/patch/applied/$PATCH_UUID ]; then
			echo "$PATCH_NAME has been applied, moving on..."
		else
			echo "Found missing patch $PATCH_NAME, checking to see if it exists in cache..."

			if [ ! -f $CACHE_DIR/$PATCH_NAME.xsupdate ]; then
				echo "Downloading from $PATCH_URL..."
				wget -q $PATCH_URL -O $TMP_DIR/$PATCH_FILE
				echo "...unpaching"
				unzip -qq $TMP_DIR/$PATCH_FILE -d $CACHE_DIR
			fi	

			echo "Applying $PATCH_NAME... [ Release Notes @ $PATCH_KB ]"
			xe patch-upload file-name=$CACHE_DIR/$PATCH_NAME.xsupdate
			xe patch-apply uuid=$PATCH_UUID host-uuid=$INSTALLATION_UUID
		fi
	done

	#rm -rf tmp/*
	echo "Everything has been patched up!"
}

get_xs_version
apply_patches
