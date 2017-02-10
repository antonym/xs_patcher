## xs_patcher

Patches XenServer host with all released hotfixes

This script will retrieve and apply all of the latest hotfixes for Citrix XenServer.
A listing of the latest patches can be found here:

http://xenserver.org/overview-xenserver-open-source-virtualization/download.html

links to recomended patches per version:
XS 7.0: https://support.citrix.com/search?searchQuery=%3F&lang=en&sort=cr_date_desc&prod=XenServer&pver=XenServer+7.0&ct=Hotfixes&ctcf=Recommended
XS 6.5: https://support.citrix.com/search?searchQuery=%3F&lang=en&sort=cr_date_desc&prod=XenServer&pver=XenServer+6.5&ct=Hotfixes&ctcf=Recommended
XS 6.2: https://support.citrix.com/search?searchQuery=%3F&lang=en&sort=cr_date_desc&prod=XenServer&pver=XenServer+6.2.0&ct=Hotfixes&ctcf=Recommended
XS 6.1: https://support.citrix.com/search?searchQuery=%3F&lang=en&sort=cr_date_desc&prod=XenServer&pver=XenServer+6.1.0&ct=Hotfixes&ctcf=Recommended **
XS 6.0.2: https://support.citrix.com/search?searchQuery=%3F&lang=en&sort=cr_date_desc&prod=XenServer&pver=XenServer+6.0.2&ct=Hotfixes&ctcf=Recommended

** Xenserver 6.1 is EOL past September 2016. Use at your Own risk.

## Supported Versions / Last update

	XenServer 6.0.0 (Boston)        ??
	XenServer 6.0.2 (Sanibel)       ??
	XenServer 6.1.0 (Tampa)         2017/02
	XenServer 6.2.0 (Clearwater)    ??
	XenServer 6.5.0 (Creedence)     2017/02
	XenServer 7.0.0 (Dundee)        2017/02

At this time (February 2017) the XenServer 7.0 patches for systems entitled to receive automatic Management Agent updates are not included in this guide.

Otherwise at this time (2017/02) scripts are updated up for versions 7.0 + 6.5 + 6.1

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

