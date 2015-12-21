#!/bin/bash
## xs_patcher
## detects xenserver version and applies the appropriate patches

## URL to patches: http://updates.xensource.com/XenServer/updates.xml

HOSTID=`xe host-list --minimal`
HOSTNAME=`hostname`

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
	if [ ! -d tmp ] 
	then
    		mkdir -p tmp
	fi

        echo "Looking for missing patches on $HOSTNAME for $DISTRO..."

        for PATCH in `cat patches/$DISTRO`      
        do
	        PATCH_NAME=`echo $PATCH | awk -F'|' {'print $1'}`
        	PATCH_UUID=`echo $PATCH | awk -F'|' {'print $2'}`
                PATCH_URL=`echo $PATCH | awk -F'|' {'print $3'}`
		PATCH_KB=`echo $PATCH | awk -F'|' {'print $4'}`

                if [ -f /var/patch/applied/$PATCH_UUID ]
		then
			echo "$PATCH_NAME has been applied, moving on..."
		fi
	       
		if [ ! -f /var/patch/applied/$PATCH_UUID ]
        	then
			echo "Found missing patch $PATCH_NAME, checking to see if it exists in cache..."

			if [ ! -f cache/$PATCH_NAME.xsupdate ] 
			then
				echo "Downloading from $PATCH_URL..."
				cd tmp
				wget -q $PATCH_URL
				unzip -qq $PATCH_NAME.zip				
				mv $PATCH_NAME.xsupdate ../cache
				cd ..
			fi	

			echo "Applying $PATCH_NAME... [ Release Notes @ $PATCH_KB ]"
             		xe patch-upload file-name=cache/$PATCH_NAME.xsupdate
		        xe patch-apply uuid=$PATCH_UUID host-uuid=$HOSTID
	        fi

        done

	rm -rf tmp
        echo "Everything has been patched up!"
}

get_xs_version
apply_patches
