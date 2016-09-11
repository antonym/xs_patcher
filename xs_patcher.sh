#!/bin/bash
## xs_patcher
## detects xenserver version and applies the appropriate patches

## URL to patches: http://updates.xensource.com/XenServer/updates.xml

source /etc/xensource-inventory
TMP_DIR=$HOME/tmp
CACHE_DIR=$HOME/cache

function clean_tmp_dir {
	rm -rf $TMP_DIR/*
}

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
				rm $TMP_DIR/$PATCH_FILE
			fi	

			echo "Applying $PATCH_NAME... [ Release Notes @ $PATCH_KB ]"
			UP_PATCH_UUID=$(xe patch-upload file-name=$CACHE_DIR/$PATCH_NAME.xsupdate)
			if [[ -z $UP_PATCH_UUID ]]; then
				echo "Patch $PATCH_UUID failed to upload. Check that the patch file exists ($CACHE_DIR/$PATCH_NAME.xsupdate) and try again."
			else
				if [[ $UP_PATCH_UUID == $PATCH_UUID ]]; then
					xe patch-apply uuid=$PATCH_UUID host-uuid=$INSTALLATION_UUID
					if [[ $? -eq 0 ]]; then
						rm $CACHE_DIR/${PATCH_NAME}.xsupdate
						rm $CACHE_DIR/${PATCH_NAME}*.bz2
						if [[ $DISTRO == "creedence" && $PATCH_NAME == "XS65ESP1023" ]]; then
							clean_tmp_dir
							echo "For some reason XS65ESP1024 errors when here. Reboot the server and clean up the old patches. Then rerun me"
							exit 1
						fi
					else
						break
						echo "The patch $PATCH_NAME failed to apply to the host. Check to make sure the disk isn't full and re-run the script."
					fi
				else
					echo "Patch ID \"$PATCH_UUID\" doesn't match the patch ID \"$UP_PATCH_UUID\" returned from the uploaded patch. Try re-running the script if this appears to be an invalid error. Otherwise try applying the patch using the returned ID, again \"$UP_PATCH_UUID\"."
				fi
			fi
		fi
	done

	clean_tmp_dir
	echo "Everything has been patched up!"
}

get_xs_version
apply_patches
