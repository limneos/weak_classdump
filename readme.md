weak_classdump
==============
A Cycript script that generates a header file for the class passed to the function.

Most useful when you cannot classdump , when binaries are encrypted etc.

-------------------------------
Usage examples : 

	root# cycript -p Skype weak_classdump.cy; cycript -p Skype
	'Added weak_classdump to "Skype" (1685)'

	cy# UIApp
	"<HellcatApplication: 0x1734e0>"

	cy# weak_classdump(HellcatApplication);
	"Wrote file to /tmp/HellcatApplication.h"
	
	cy# UIApp.delegate
	"<SkypeAppDelegate: 0x194db0>"
	
	cy# weak_classdump(SkypeAppDelegate,"/someDirWithWriteAccess/");
	"Wrote file to /someDirWithWriteAccess/SkypeAppDelegate.h"
          
	root# cycript -p iapd weak_classdump.cy; cycript -p iapd
	'Added weak_classdump to "iapd" (1127)'
	
	cy# weak_classdump(IAPPortManager)
	"Wrote file to /tmp/IAPPortManager.h"


Thanks to Ryan Petrich , you can now use weak_classdump_bundle to dump all headers within a bundle.

	root# cycript -p MobilePhone weak_classdump.cy; cycript -p MobilePhone
	'Added weak_classdump to "MobilePhone" (385)'
	
	#cy weak_classdump_bundle([NSBundle mainBundle],"/tmp/MobilePhone")
	

by Elias Limneos
----------------
web: limneos.net

email: iphone (at) limneos (dot) net

twitter: @limneos

Issues
-----------
Thanks to Ryan Petrich, currently no issues. 

Licence
-----------

weak_classdump is open source. Feel free to help improving it if you like.

Environment
-----------
weak_classdump works under Cycript. Visit cycript.org for more info.




