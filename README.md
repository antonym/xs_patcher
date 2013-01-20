## xs_patcher - patches XenServer host with all released hotfixes

This script will retrieve and apply all of the latest hotfixes for Citrix XenServer.

## Supported Versions

	XenServer 6.0.0 (Boston)
	XenServer 6.0.2 (Sanibel)
	XenServer 6.1.0 (Tampa)

## Running

Drop the repo onto a XenServer and run:

	cd xs_patcher
	./xs_patcher.sh

## Adding new hotfixes

The hotfixes are stored in individual files per distro in the patches directory. To 
add new hotfixes, just add a line in the following format:

	patch name|uuid of patch|url of download|url of kb article
	
Make sure to keep the patch names sequential so they get applied in the right order.

## Disclaimer

Use at your own risk, make sure to test before rolling out to Production.
