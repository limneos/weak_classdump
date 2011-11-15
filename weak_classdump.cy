#!/usr/bin/cycript 

function commonTypes(type){
	
	isPointer=NO;
	if ([type containsSubstring:@"^"]){
		isPointer=YES;
		type=[type stringByReplacingOccurrencesOfString:@"^" withString:""];
	}
	
	switch (type.toString()){
	
		case "d": type = "double"; break;
		case "i": type = "int"; break;
		case "f": type = "float"; break;
		case "c": type = "BOOL"; break;
		case "s": type = "short"; break;
		case "I": type = "unsigned"; break;
		case "l": type = "long"; break;
		case "q": type = "long long"; break;
		case "L": type = "unsigned long"; break;
		case "C": type = "unsigned char"; break;
		case "S": type = "unsigned short"; break;
		case "Q": type = "unsigned long long"; break;
		case "B": type = "_Bool"; break;
		case "v": type = "void"; break;
		case "*": type = "char*"; break;
		case ":": type = "SEL"; break;
		case "#": type = "Class"; break;
		case "@": type = "id"; break;
		case "@?": type = "id"; break;
		default: type = type;
	
	}
	
	return isPointer ? type.toString()+"*" : type.toString();

}
function constructTypeAndName(aType,IvarName,isIvar){
	//return aType.toString()+" "+IvarName.toString();
	NSNotFound=2147483647;
	
			
	compareString1=[NSString stringWithString:aType];
	compareString2=[[[NSString stringWithString:aType] stringByReplacingOccurrencesOfString:"^" withString:""] stringByAppendingString:@"*"];
	if (![[NSString stringWithString:commonTypes(aType)] isEqual:compareString1] && ![[NSString stringWithString:commonTypes(aType)] isEqual:compareString2]){
		
		return commonTypes(aType).toString()+" "+IvarName.toString();
	}

	charSet=[NSCharacterSet characterSetWithCharactersInString:"@^\"{}="];
	structCharSet=[NSCharacterSet characterSetWithCharactersInString:"?:{}="];
	
	

	
	if ([aType rangeOfString:"]"].location!=NSNotFound && [aType rangeOfString:"^{"].location==NSNotFound){
		
		aType=[aType stringByRemovingCharactersFromSet: [NSCharacterSet punctuationCharacterSet ]];
		arrayCount=[[aType copy] stringByRemovingCharactersFromSet: [NSCharacterSet letterCharacterSet ]];
		arrayType=[aType stringByRemovingCharactersFromSet: [NSCharacterSet decimalDigitCharacterSet ]];
		return commonTypes(arrayType).toString()+"["+arrayCount.toString()+"]"+" "+IvarName.toString();
			
	}

	if ([aType rangeOfString:"{?"].length>0 && isIvar){
	
		aType=[aType stringByRemovingCharactersFromSet:structCharSet];
		structValues=[aType componentsSeparatedByString:@"\""];
		structValues =[NSMutableArray arrayWithArray:structValues ];
		firstEntry=[structValues removeObjectAtIndex:0];
		[structValues removeObject:firstEntry];
		newString=[NSString stringWithString:"struct {\n"];
		namesArray=[NSMutableArray array];
		typesArray=[NSMutableArray array];
		
		for  (d=0; d<[structValues count] ; d++){
			
			if ((d % 2)==0){
				[namesArray addObject:structValues[d]];
			}
			else{
				[typesArray addObject:structValues[d]];
			}
		}

		for (e=0; e<[typesArray count]; e++){
			newString=newString.toString()+"\t\t"+constructTypeAndName(typesArray[e],namesArray[e],0).toString()+";\n";
		}
		return newString.toString()+"\t} "+IvarName.toString();
	
	}
	
	if ([aType rangeOfString:"{"].length>0){
		returnValue="struct ";
		range=[aType rangeOfString:@"="];
		if ([aType containsSubstring:@"{?={"]){
			return @"Unknown_struct "+IvarName.toString();
		}
		aType=[aType stringByReplacingCharactersInRange:[range.location,aType.length-range.location] withString:"" ];
		returnValue=returnValue.toString()+[aType stringByRemovingCharactersFromSet:structCharSet].toString();
		return commonTypes(returnValue).toString()+" "+IvarName.toString();
	}
	
	
	if ([aType rangeOfString:@"^"].length>0){
		
		range=[aType rangeOfString:"^" options: NULL range: [2,aType.length-2]];
		if (range.length>0){
			aType=[aType stringByReplacingCharactersInRange:[range.location-1,aType.length-range.location+1] withString:"" ];
		}
		aType=[aType stringByRemovingCharactersFromSet:charSet];
		//aType=[aType stringByReplacingOccurrencesOfString:@"__" withString:""];
		return aType.toString()+"* "+IvarName.toString();

	}
	

	
	if ([aType rangeOfString:@"@\""].length>0){
		if ([aType rangeOfString:"<"].location==2){
			aType="id"+aType.toString();
			return [aType stringByRemovingCharactersFromSet:charSet].toString()+" "+IvarName.toString();
		}
		
		return [[aType stringByRemovingCharactersFromSet:charSet] stringByAppendingString:@"*"].toString()+" "+IvarName.toString();
	}	
	
	if ([aType rangeOfString:@"b"].length>0 && [aType rangeOfString:":{"].length<1){
		string=[aType stringByReplacingOccurrencesOfString:@"b" withString:""];
		return "unsigned int "+IvarName.toString()+":"+string.toString();
	}
	
	
	//aType=commonTypes(aType);
	
	return aType.toString() + " " + IvarName.toString();
 
}

function propertyTranslator(attrib){
	
	switch (attrib.toString()){
		case "R" : p = "readonly"; 
		case "C" : p = "copy"; break;
		case "&" : p = "retain"; break;
		case "N" : p = "nonatomic"; break;
		case "D" : p = "@dynamic"; break;
		case "W" : p = "__weak"; break;
		case "P" : p = "t<encoding>"; break;
		default: p = attrib;
	}

	return p;
}

function propertyLineGenerator(attributes,name){
	
	parSet=[NSCharacterSet characterSetWithCharactersInString:@"()"];
	attributes=[attributes stringByRemovingCharactersFromSet:parSet];
	attrArr=[attributes componentsSeparatedByString:@","];
	
		type=attrArr[0];
		type=[type stringByReplacingCharactersInRange:[0,1] withString:""];
		type=constructTypeAndName(type,"",0);
		type=[type stringByRemovingWhitespace];
		//return type.toString()+"\n";
		attrArr=[NSMutableArray arrayWithArray:attrArr];
		[attrArr removeObjectAtIndex:0];
		
		propertyString="@property ";
		
		newPropsArray=[NSMutableArray array];
		synthesize=[NSString stringWithString:""];
		for each (attr in attrArr){
			vToClear=nil;		
			if ([attr rangeOfString:@"V_"].location==0){
				vToClear=attr;
				attr=[attr stringByReplacingCharactersInRange:[0,1] withString:""];
				synthesize="\t//@synthesize "+attr.toString()+"=_"+attr.toString()+" - In the implementation block";
			}
			if ([attr length]==1){
				
				[newPropsArray addObject:propertyTranslator(attr)];
				
			
			}
			if ([attr rangeOfString:@"G"].location==0){
				attr=[attr stringByReplacingCharactersInRange:[0,1] withString:""];
				attr="getter="+attr.toString();
				[newPropsArray addObject:attr];
			}
			if ([attr rangeOfString:@"S"].location==0){
				attr=[attr stringByReplacingCharactersInRange:[0,1] withString:""];
				attr="setter="+attr.toString();
				[newPropsArray addObject:attr];
			}
			
		}
		if ([newPropsArray containsObject:@"nonatomic"] && ![newPropsArray containsObject:@"assign"] && ![newPropsArray containsObject:@"readonly"] && ![newPropsArray containsObject:@"copy"] && ![newPropsArray containsObject:@"retain"]){
			[newPropsArray addObject:@"assign"];
		}
		
		newPropsArray=[newPropsArray reversedArray];
			
		rebuiltString=[newPropsArray componentsJoinedByString:","];
		attrString=newPropsArray.length>0 ? "("+rebuiltString.toString()+")" : "(assign)";
		
		propertyString=propertyString.toString()+attrString.toString()+" "+type.toString()+" "+name.toString()+"; "+synthesize.toString()+"\n";		
		return propertyString;

}

function weak_classdump(classname,outputdir){
	if (!classname){
		return "Cannot find class";
	}
	version = [NSProcessInfo processInfo ].operatingSystemVersionString;
	loc=[NSLocale localeWithLocaleIdentifier: "en-us"];
	date=[NSDate.date descriptionWithLocale: loc];
	classString = "/*\n * This header is generated by weak_classdump 0.0.1\n * on "+date.toString()+"\n * Operating System: "+version.toString()+"\n * weak_classdump is Freeware by Elias Limneos.\n *\n */\n\n";
	
	_class_copyIvarList = new Functor(dlsym(RTLD_DEFAULT,"class_copyIvarList"),"^^{objc_ivar=}#^I");
	_class_copyProtocolList=new Functor(dlsym(RTLD_DEFAULT,"class_copyProtocolList"),"^@#^I");
	_class_conformsToProtocol=new Functor(dlsym(RTLD_DEFAULT,"class_conformsToProtocol"),"B#@");
	
	_class_copyPropertyList=new Functor(dlsym(RTLD_DEFAULT,"class_copyPropertyList"),"^^{objc_property=}#^I");
	_method_getName=new Functor(dlsym(RTLD_DEFAULT,"method_getName"),"*^{objc_method=}");
	_method_getNumberOfArguments=new Functor(dlsym(RTLD_DEFAULT,"method_getNumberOfArguments"),"I^{objc_method=}");
	_method_copyReturnType=new Functor(dlsym(RTLD_DEFAULT,"method_copyReturnType"),"*^{objc_method=}");
	_method_copyArgumentType=new Functor(dlsym(RTLD_DEFAULT,"method_copyArgumentType"),"*^{objc_method=}I");
	_property_getAttributes=new Functor(dlsym(RTLD_DEFAULT,"property_getAttributes"),"*^{objc_property=}");  
	_property_getName=new Functor(dlsym(RTLD_DEFAULT,"property_getName"),"*^{objc_property=}"); 
	_ivar_getName = new Functor(dlsym(RTLD_DEFAULT,"ivar_getName"),"*^?");
	_ivar_getTypeEncoding = new Functor(dlsym(RTLD_DEFAULT,"ivar_getTypeEncoding"),"*^{objc_ivar=}");
	_protocol_getName=new Functor(dlsym(RTLD_DEFAULT,"protocol_getName"),"*@");
	
	// Note: Looking for a way to get class methods with or without instantiating a class object.
	_class_copyMethodList=new Functor(dlsym(RTLD_DEFAULT,"class_copyMethodList"),"^^{objc_method=}#^I");
	//_objc_getClassList=new Functor(dlsym(RTLD_DEFAULT,"objc_getClassList"),"i^#i");
	//_class_createInstance=new Functor(dlsym(RTLD_DEFAULT,"class_createInstance"),"@#L");
	
	 
	protocolsCount=new int;
	protocolArray=_class_copyProtocolList(classname,protocolsCount);
	protocolsString="";
	for (i=0; i<*protocolsCount; i++){
		if (_class_conformsToProtocol(classname,protocolArray[i])){
			protocolsString=protocolsString.toString()+" <"+_protocol_getName(protocolArray[i]).toString()+">";
		}
	}
	
	superclass=classname.superclass;
	
	if (superclass!=nil && superclass!="nil"){
		classString = classString.toString()+[NSString stringWithString:@"@interface "+classname.toString()+" : "+superclass.toString()].toString() + protocolsString.toString();
	}
	else{
		classString = classString.toString()+[NSString stringWithString:@"@interface "+classname.toString()].toString() + protocolsString.toString();
	}
  
	classIvarCount=new int;
	superclassIvarCount=new int;
	list=_class_copyIvarList(classname,classIvarCount);
	superlist=_class_copyIvarList(superclass,superclassIvarCount);
	
	superClassIvars=[NSMutableArray array];
	
	classString = classString.toString()+" {";  
	
	for (i=0; i<*superclassIvarCount;i++){
		if (_ivar_getName(superlist[i])){
			[superClassIvars addObject:_ivar_getName(superlist[i])];
		}
	
	}
	free(superlist);
	for (i=0; i<*classIvarCount;i++){
		classIvar=_ivar_getName(list[i]);
		appendString="";
		if (classIvar && ![superClassIvars containsObject:classIvar]){
			ivarType=ivar_getTypeEncoding(list[i]).toString();
			ivar=constructTypeAndName([NSString stringWithString:ivarType],[NSString stringWithString:_ivar_getName(list[i])],1);
			classString=classString.toString()+"\n\t"+ivar.toString()+"; "; 
		}
	
	}
	
	free(list);
	
	classString = classString.toString()+"\n}\n";     
	
 

	propertiesCount=new int;
	propertyList=_class_copyPropertyList(classname,propertiesCount);
	for (i=0; i<*propertiesCount; i++){
		
		propname=_property_getName(propertyList[i]);
		attrs=_property_getAttributes(propertyList[i]);
		
		classString=classString.toString()+propertyLineGenerator(attrs,propname).toString();
	}
	 
	free(propertyList);
	methodsCount=new int;
	methodList=_class_copyMethodList(classname,methodsCount);
	for (i=0; i<*methodsCount;i++){
		method=methodList[i];
		methodName=_method_getName(method);
		returnType=_method_copyReturnType(method);
		returnType=[constructTypeAndName([NSString stringWithString:returnType],[NSString stringWithString:""],0) stringByRemovingWhitespace];
		argNum=_method_getNumberOfArguments(method);
		methodBrokenDown=[methodName componentsSeparatedByString:@":"];
		methodString=[NSString stringWithString:""];
		if ([methodBrokenDown count]>1){
			for (x=0; x<[methodBrokenDown count]-1; x++){
				anIndex=x+2;
				argumentType=_method_copyArgumentType(method,anIndex);
				if (!argumentType){
					argumentType="id";
				}
				typeName=constructTypeAndName([NSString stringWithString:argumentType],[NSString stringWithString:""],0);
				typeName=[typeName stringByTrimmingLastCharacter];
				methodString=methodString.toString()+methodBrokenDown[x].toString()+":("+typeName.toString()+")arg"+(x+1)+" ";
				
			}
			methodString=[methodString stringByTrimmingLastCharacter];
		}
		else{
			methodString=methodName;
		}
		
		classString=classString.toString()+"-("+returnType.toString()+")"+methodString.toString()+";\n";
		
	}
	free(methodList);
	classString = classString.toString()+"@end";
 
	if (typeof(outputdir) == 'undefined'){
		outputdir = "/tmp";
	}
	outputdir=outputdir.toString()+"/";
	classString = [NSString stringWithString:classString ]; 
	if ([classString writeToFile:outputdir.toString()+classname.toString()+".h" atomically:YES]){
		return "Wrote file to "+outputdir.toString()+classname.toString()+".h";
	}
	else {
		NSSearchPathForDirectoriesInDomains=new Functor(dlsym(RTLD_DEFAULT,"NSSearchPathForDirectoriesInDomains"),"@ccc");
		writeableDir=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		writeableDir=writeableDir[0];
		return "Failed to write to "+outputdir.toString()+classname.toString()+".h - Check file path and permissions? Suggested writeable directory: "+writeableDir.toString();
	}
}
// Usage example : weak_classdump(SBAwayController);
// (will write to default path "/tmp/SBAwayController.h"
// example 2: weak_classdump(UIApplication,"/var/mobile/");
// will write to "/var/mobile/UIApplication.h"

