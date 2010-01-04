// RedSheriff Customer Intelligence - V5    
// COPYRIGHT 2003 RedSheriff Limited

function random() {
   random.seed = (random.seed*random.a + random.c) % random.m;
   return random.seed / random.m;
}
window.onerror=_rsEH;
random.m=714025;
random.a=4096;
random.c=150889;
random.seed = (new Date()).getTime()%random.m;
function _rsEH(_rsE,_rsU,_rsL){}
function rsCi(){
var _rsUA=navigator.appName+" "+navigator.appVersion;
var _rsRUA=navigator.userAgent;
var _rsWS=window.screen;
var _rsBV=navigator.appVersion.substring(0, 1);
var _rsNN=(_rsUA.indexOf('Netscape'));
var _rsMC=(_rsUA.indexOf('Mac'));
var _rsIE=(_rsUA.indexOf('MSIE'));
var _rsLX=(_rsUA.indexOf('Linux'));
var _rsOP=(_rsRUA.indexOf('Opera'));
var _rsKQ=(_rsUA.indexOf('Konqueror'));
var _rsIEV=(parseInt(_rsUA.substr(_rsIE+5)));
var _rsSR='';
var _rsCD='';
var _rsLG='';
var _rsCT='';
var _rsHP='';
var _rsCK='';
var _rsJE='';
var _rsTL='';
if(_rsDT){
        _rsTL=(escape(document.title));
        }
_rsJE=(navigator.javaEnabled()==true)?"y":"n";
if((_rsIE>0)||((_rsNN!=-1)&&(_rsBV >=5))){
	_rsCK=(navigator.cookieEnabled==true)?"y":"n";
}
if((_rsIE>=0)&&(_rsIEV>=5)&&(_rsMC==-1)&&(_rsOP==-1)){
		if(document.body){
			document.body.addBehavior("#default#clientCaps");
			_rsCT=document.body.connectionType;
			document.body.addBehavior("#default#homePage");
			_rsHP=(document.body.isHomePage(location.href))?"y":"n";
			}
}
_rsD= new Date();
_rsTZ=_rsD.getTimezoneOffset()/-60;
if(_rsWS){
	_rsSR=_rsWS.width+'x'+_rsWS.height; 
	_rsCD=_rsWS.colorDepth;
	if(_rsNN!=-1){
		_rsCD=_rsWS.pixelDepth;
		}
	}
if((_rsNN!=-1)||(_rsOP!=-1)){
	_rsLG=navigator.language;
	}
if((_rsIE!=-1)&&(_rsOP==-1)){
	_rsLG=navigator.userLanguage;
	}
document.write('<img src="'+_rsND+'cgi-bin/m?ci='+_rsCI+'&cg='+_rsCG+'&rd='+_rsRD+'&si='+_rsSI+'&rp='+_rsRP+'&sr='+_rsSR+'&cd='+_rsCD+'&lg='+_rsLG+'&je='+_rsJE+'&ck='+_rsCK+'&tz='+_rsTZ+'&ct='+_rsCT+'&hp='+_rsHP+'&tl='+_rsTL+'" border=0 height=1 width=1>');
}
if((_rsSE)&&(random() <= _rsSM)){
        _rsIM='<scr'+'ipt language="JavaScript" type="text/javascript" src="'+_rsND+'cgi-bin/j?ci='+_rsCI+'&rd='+_rsRD+'&se='+_rsSE+'&sv='+_rsSV+'"><\/scr'+'ipt>';
document.write(_rsIM);
	} else {
        	rsCi();
	}
