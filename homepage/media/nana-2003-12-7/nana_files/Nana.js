function suycDateDiff(start) {
	// This function need to recive date in format -> 20:06 25/12/2001
	// and return  how much days in number  from today
	// writen by ron belson on 07/2002
	var strMonthArray = new Array(12);
	strMonthArray[0]  = "Jan";
	strMonthArray[1]  = "Feb";
	strMonthArray[2]  = "Mar";
	strMonthArray[3]  = "Apr";
	strMonthArray[4]  = "May";
	strMonthArray[5]  = "Jun";
	strMonthArray[6]  = "Jul";
	strMonthArray[7]  = "Aug";
	strMonthArray[8]  = "Sep";
	strMonthArray[9]  = "Oct";
	strMonthArray[10] = "Nov";
	strMonthArray[11] = "Dec";
	
	var text = start.substring(5);	
	
	// the mounth
	var sMounth = text
		sMounth = text.substring(3);
		sMounth = sMounth.substring(1,3) ;
	    if(sMounth.indexOf(0)==0) sMounth = sMounth.substring(1,2);
	     sMounth = strMonthArray[sMounth-1];
	     
	// the day
	
	var sDay = text;
		sDay = sDay.substring(1,3) ;	
	
	// the year
			
	var sYear = text ;
	    sYear = sYear.substring(7,11) ;
	
	// all start string again
	   
	   start = sDay + " " + sMounth + " " + sYear ;	    	

	var now;
	now  = new Date() ;		
    var iOut = 0;
    var bufferA = Date.parse( start ) ;
    var bufferB = Date.parse( now ) ;    	
    if ( isNaN (bufferA) || isNaN (bufferB) )   return 0 ;            	                        
    var number = bufferB-bufferA ;       
    iOut = parseInt(number / 86400000) ;                  
    return iOut ;
}
//This function  return nothing
function NanaPopUp (sPopupWinArgs) 
{
	NanaPopUpReturn (sPopupWinArgs)
}
//This function return the refrence of the popup
//Usage:
//	NanaPopUpReturn ('TargetURL, width, height, scrollbars')
//Usage examples:
//	NanaPopUpReturn ('http://www.nana.co.il, 400, 300, yes')
//	NanaPopUpReturn ('http://www.nana.co.il, width=400, height=300, scrollbars=yes')
function NanaPopUpReturn (sPopupWinArgs) {					 
	if(sPopupWinArgs != '') {
		var sURL		= '';
		var sWidth		= '';
		var sHeight		= '';
		var sFeatures	= '';
		var sScrollBars	= '';
		
		var oNewWindow;					
		var sName = 'PopupWin';
		var sFeatures	= '';
		var arrArgs		= sPopupWinArgs.split(",");

		typeof(arrArgs[0]) == 'string' ? sURL = arrArgs[0] : {};
		if (typeof(arrArgs[1]) == 'string')
			sWidth = arrArgs[1].toLowerCase() 
		else {
			parent.location.href=sURL; 
			self.focus();
			return(null);
		}
		typeof(arrArgs[2]) == 'string' ? sHeight = arrArgs[2].toLowerCase() : {};
		typeof(arrArgs[3]) == 'string' ? sScrollBars = arrArgs[3].toLowerCase() : {};
		
		sFeatures = 'top=10, left=10';
		
		if (sWidth == "width=0") {
			sWidth = '';
		} else if (sWidth.indexOf('width')==-1) {
			sWidth = ', width=' + sWidth;
		} 
		
		if (sHeight == "height=0") {
			sHeight = '';
		} else if (sHeight.indexOf('height')==-1) {
			sHeight = ', height=' + sHeight;
		} 
		
		if (sScrollBars != '' && sScrollBars.indexOf('scrollbars')==-1) {
			sScrollBars = ', scrollbars=' + sScrollBars;
		} 

		sFeatures = sFeatures + sWidth + sHeight + sScrollBars
		
		oNewWindow = window.open (sURL,sName,sFeatures);
		return oNewWindow;
	}
}

// get query string paramter and return the value
function RequestQueryString(sParamName){
	var sHref="";
	var arrHref=null;
	var nParamStartPos=0, nParamEndPos=0;
	var sParamValue='';
	
	sHref=document.location.href;
	arrHref=sHref.split("?");
	// return empty string if the query string not exsits
	if(arrHref.length==0) return("");
	
	sParamName+='=';
	nParamStartPos=arrHref[1].indexOf(sParamName);
	// return empty string if the requested parameter is not exsits
	if(nParamStartPos==-1) return("");
	nParamStartPos+=sParamName.toString().length;
	
	nParamEndPos=arrHref[1].indexOf("&", nParamStartPos);
	
	if(nParamEndPos>-1&&nParamEndPos>nParamStartPos)
		sParamValue=arrHref[1].slice(nParamStartPos,nParamEndPos);
	else
		sParamValue=arrHref[1].slice(nParamStartPos);

	return(sParamValue);
}

function SearchRedirect(){

	var sKeywordParam='', sAction='';
	var sParamName='', sParamValue='';
	var nNumOfParam=0, nCounter=0;
	var arrURL=null;
	var sHTML='';
	//alert(document.SearchBar.serviceAction.value);
	arrURL=document.SearchBar.serviceAction.value.split("|");
	nNumOfParam=arrURL.length;	
	
	// get extra parameters
	if(nNumOfParam>2)
		for(nCounter=1;nCounter<nNumOfParam-1;nCounter++){
			sParamName=arrURL[nCounter].split("=")[0];
			sParamValue=arrURL[nCounter].split("=")[1];
			sHTML+='<input type="hidden" name="'+sParamName+'" value="'+sParamValue+'">'
		}

	// get the action
	sAction=arrURL[0];
	// get the keywords parameter name
	sKeywordParam=arrURL[nNumOfParam-1];
	
	SetGirafaCheckbox(document.SearchBar.g.checked, document.SearchBar)
		
	// set the keyword parameter name
	document.SearchBar.q.name=sKeywordParam;
	// set the action parameter value
	document.SearchBar.action=sAction;
	ExtraParam.innerHTML='';
	ExtraParam.innerHTML=sHTML;
	//SearchBar.submit() ;
}

function SetGirafaCheckbox(flag, Formobject){
	if(flag)
		Formobject.gr.value=1;
	else
		Formobject.gr.value=0;
}

// This function save cookie
function saveCookie(name,value,days) {
	if (days) {
		var date = new Date();
		date.setTime(date.getTime()+(days*24*60*60*1000))
		var expires = "; expires="+date.toGMTString()
	}
	else expires = ""
		document.cookie = name+"="+value+expires+"; path=/"
}
// This function read the cookie that was saved by saveCookie function
function readCookie(name) {
	var nameEQ = name + "="
	var ca = document.cookie.split(';')
	for(var i=0;i<ca.length;i++) {
	var c = ca[i];
		while (c.charAt(0)==' ') c = c.substring(1,c.length)
			if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length)
}
return 1;
}
						