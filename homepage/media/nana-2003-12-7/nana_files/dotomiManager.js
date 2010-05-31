//Version:	1.1

function DotomiManager(){
	
	this.DAY					= 1000 * 60 * 60 * 24;
	this.HOUR					= 1000 * 60 * 60;
	this.MINUTE					= 1000 * 60;
	this.COOKIE_DOTOMI_USER		= "DotomiUser";
	this.COOKIE_AUTO_REFRESH	= "AutoRefresh";
	this.COOKIE_UNIQUE_HIT		= "UniqueHit";
	
	this.getDateMilliseconds = function (){
		var date = new Date();
		return (date.valueOf() - (date.getTimezoneOffset() * 60 * 1000));
	};
	this.getCookieValue = function (name){
		var cookies=document.cookie.split("; ");
		var key,value;
	
		for (var i=0;i<cookies.length;i++){
			key=cookies[i].split(new RegExp('\\=','g'))[0];
			value=unescape(cookies[i].split(new RegExp('\\=','g'))[1]);
			if (name==key)
				return value;
		}
		return "";
	};
	this.isActiveUser = function(){
		if (document.cookie.indexOf(this.COOKIE_DOTOMI_USER)==-1){
			var value = this.getCookieValue(this.COOKIE_UNIQUE_HIT);
			if (!(value == "true" || value == true)){
				document.write('<SCR'+'IPT language="javaScript" src="http://nana.dtmpub.com/getDotomiCookie.asp"></SCR'+'IPT>');
				//document.write('<SCR'+'IPT language="javaScript" src="http://general.dtmpub.com/getDotomiCookie.php"></SCR'+'IPT>');
			}
			return false;
		}else{
			return true;
		}
	};
	this.isSamePage = function(){
		if (this.getCookieValue(this.COOKIE_AUTO_REFRESH) == document.location.href)
			return true;
		else
			return false;
	};
	this.isShowMessage = function (){
		if (this.isActiveUser() && !this.isSamePage())
			return true;
		else
			return false;
	};
	this.setCookie = function (name, value, expires, path, domain){
		var sCookie = new String();
		sCookie += name + "=" + escape(value);
		if (expires)
			sCookie += ";expires=" + expires;
		if (path)
			sCookie += ";path=" + path;
		if (domain)
			sCookie += ";domain=" + domain;
		document.cookie = sCookie;
	};
	this.tagUser = function (value, hour){
		var h = 12;
		if (value == "true" || value == true){
			if (typeof hour == "undefined"){
				hour = h;
			}else{
				if (isNaN(hour)){
					hour = h;
				}
			}
			this.setCookie(this.COOKIE_DOTOMI_USER, "true", new Date(this.getDateMilliseconds() + (365 * this.DAY)).toGMTString(), "/", document.location.host);
			this.setCookie(this.COOKIE_DOTOMI_USER, "true", new Date(this.getDateMilliseconds() + (365 * this.DAY)).toGMTString(), "/", document.location.host.substring(document.location.host.indexOf(".")));
		}else{
			this.setCookie(this.COOKIE_UNIQUE_HIT, "true", new Date(this.getDateMilliseconds() + (hour * this.HOUR)).toGMTString(), "/", document.location.host);
			this.setCookie(this.COOKIE_UNIQUE_HIT, "true", new Date(this.getDateMilliseconds() + (hour * this.HOUR)).toGMTString(), "/", document.location.host.substring(document.location.host.indexOf(".")));
		}
	};
	this.setRefreshCookie = function (){
		this.setCookie(this.COOKIE_AUTO_REFRESH, document.location.href, null, "/", document.location.host);
	};
	
};

var dotomiManager = new DotomiManager();