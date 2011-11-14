weak_classdump
==============
A Cycript script that generates a header file for the class passed to the function.

Most useful when you cannot classdump , when binaries are encrypted etc.

-------------------------------
Usage examples : 

	root# cycript -p SpringBoard weak_classdump.cy ; cycript -p SpringBoard
	
	cy# weak_classdump(SBIcon);
	"Wrote file to /tmp/SBIcon.h"
	
	cy# weak_classdump(UIApplication,"/var/mobile/classdumps/");
	"Wrote file to /var/mobile/classdumps/UIApplication.h"
	


	
by Elias Limneos
----------------
web: limneos.net

email: iphone (at) limneos (dot) net

twitter: @limneos

Issues
-----------
It currently assumes every variable as (id), since I cannot get types from cycript class.messages approach.

Licence
-----------

weak_classdump is open source. Feel free to help improving it if you like.

Licence
-----------
weak_classdump works under Cycript. Visit cycript.org for more info.




