// BrowserCheck Object
function BrowserCheck() {
	var b = navigator.appName
	if (b=="Netscape") this.b = "ns"
	else if (b.toLowerCase().indexOf("explorer")!=-1) this.b = "ie"
  	else this.b = b
	this.version = navigator.appVersion
	this.v = parseInt(this.version)
	this.ns = (this.b=="ns" && this.v>=4)
	this.ns4 = (this.b=="ns" && this.v==4)
	this.ns5 = (this.b=="ns" && this.v==5)
	this.ns6 = (this.b=="ns" && this.v==6)
	this.ie = (this.b=="ie" && this.v>=4)
	this.ie4 = (this.version.indexOf('MSIE 4')>0)
	this.ie5 = (this.version.indexOf('MSIE 5')>0)
	this.ie6 = (this.version.indexOf('MSIE 6')>0)
	this.min = (this.ns||this.ie)
}
nana_browser_is = new BrowserCheck();
regular_nana_banners_mode = true;

// Display Ads 
// Used to display regular banners
function DisplayAds(sitepage, position, width, height) 
 {	if (regular_nana_banners_mode) {		var oas = 'http://realmedia.nana.co.il/RealMedia/ads/';
		var RN = new String (Math.random());
		var RNS = RN.substring(2,11);
		var oaspage = sitepage + '/1' + RNS + '@' + position;
			document.write('<SCRIPT LANGUAGE="JavaScript1.1" SRC="' + oas + 'adstream_jx.ads/' + oaspage + '">');
		document.write('</SCRIPT>');	} }
 

// checking window location for virtual common reason (https)
var qString
qString = new String(window.location)
if (qString.indexOf("https:") < 0){
	document.write('<SCR'+'IPT language="javaScript" src="http://common.nana.co.il/Header/dotomiManager.js"></SCR'+'IPT>');
}else{
	document.write('<SCR'+'IPT language="javaScript" src="https://secure.netvision.net.il/common/Header/dotomiManager.js"></SCR'+'IPT>');
}
// DISPLAY BANNERS FROM DOTOMI
function DisplayAds_Dotomi(sitepage, position, width, height) 
{

if (regular_nana_banners_mode) {
	var oas = 'http://realmedia.nana.co.il/RealMedia/ads/';
	var RN = new String (Math.random());
	var RNS = RN.substring(2,11);
	var oaspage = sitepage + '/1' + RNS + '@' + position;
	var rurl = oas + 'adstream_jx.ads/' + oaspage;
	
	if (typeof dotomiManager != "undefined" && dotomiManager.isShowMessage()){
		var dotomiSrc = "http://dmm.dotomi.com/dmm/servlet/dmm?dres=jscript&rurl=" + escape(rurl).replace(new RegExp('\\+','g'),'%2B') + "&pid=1100&mtg=0&ms=1&btg=1&mp=1&rwidth="+width+"&rheight="+height;
		document.write("<scr"+"ipt src=\"" + dotomiSrc + "\" language=\"javaScript\"></scr"+"ipt>");
		dotomiManager.setRefreshCookie();
	}else{
		document.write('<SCRIPT LANGUAGE="JavaScript1.1" SRC="' + rurl + '">');
		document.write('</SCRIPT>');
	}
}
}

// DISPLAY BANNERS IN IFRAME FROM DOTOMI
function DisplayAdsInIFrame_Dotomi(sitepage, position, width, height, bReturnString){
	if (regular_nana_banners_mode) {
		var oas = 'http://realmedia.nana.co.il/RealMedia/ads/';
		var RN = new String (Math.random());
		var RNS = RN.substring(2,11);
		var oaspage = sitepage + '/1' + RNS + '@' + position;
		var rurl = oas + 'adstream_sx.ads/' + oaspage;

		if (typeof dotomiManager != "undefined" && dotomiManager.isShowMessage()){
			var dotomiSrc = "http://dmm.dotomi.com/dmm/servlet/dmm?dres=iframe&rurl=" + escape(rurl).replace(new RegExp('\\+','g'),'%2B') + "&pid=1100&mtg=0&ms=1&btg=1&mp=1&rwidth="+width+"&rheight="+height;
			document.write('<IFRAME NAME="Banner' + position + '" ID="Banner' + position + '" allowTransparency=true WIDTH=' + width + ' HEIGHT=' + height + ' NORESIZE SCROLLING=No FRAMEBORDER=0 MARGINHEIGHT=0 MARGINWIDTH=0 SRC="' + dotomiSrc + '"></IFRAME>');
			dotomiManager.setRefreshCookie();
		}else{
			var sHTML = '<IFRAME NAME=Banners WIDTH=' + width + ' HEIGHT=' + height + ' NORESIZE SCROLLING=No FRAMEBORDER=0 MARGINHEIGHT=0 MARGINWIDTH=0 SRC="' + rurl + '">';
			if (nana_browser_is.ns) {
				sHTML += '<SCRIPT LANGUAGE="JavaScript1.1" SRC="' + oas + 'adstream_jx.ads/' + oaspage + '">';
				sHTML += '</SCRIPT>';
			}
			sHTML +='</IFRAME>';
		
			if (bReturnString){
				return sHTML;
			}else{
				document.write(sHTML);
			}
		}
	}
}

function DisplayFloatingAds(sitepage, position)
{
	if (regular_nana_banners_mode) {		var oas = 'http://realmedia.nana.co.il/RealMedia/ads/';
		var RN = new String (Math.random());
		var RNS = RN.substring(2,11);

		var oaspage = sitepage + '/1' + RNS + '@' + position;		var JSSource = oas + 'adstream_jx.ads/' + oaspage	
		if (nana_browser_is.ie5 || nana_browser_is.ie6) {		
			document.write('<SCRIPT LANGUAGE="JavaScript1.1" SRC="' + JSSource + '">');
			document.write('</SCRIPT>');		}	}
}

function DisplayAdsInIFrame(sitepage, position, width, height,bReturnString) 
 {
	if (regular_nana_banners_mode) {		
		var oas = 'http://realmedia.nana.co.il/RealMedia/ads/';
		var RN = new String (Math.random());
		var RNS = RN.substring(2,11);
		var oaspage = sitepage + '/1' + RNS + '@' + position;
		var sHTML = '<IFRAME NAME="Banner' + position + '" ID="Banner' + position + '" WIDTH=' + width + ' HEIGHT=' + height + ' NORESIZE SCROLLING=No FRAMEBORDER=0 MARGINHEIGHT=0 MARGINWIDTH=0 SRC="' + oas + 'adstream_sx.ads/' + oaspage + '">';
		if (nana_browser_is.ns) {			sHTML += '<SCRIPT LANGUAGE="JavaScript1.1" SRC="' + oas + 'adstream_jx.ads/' + oaspage + '">';
			sHTML += '</SCRIPT>';		}
		sHTML +='</IFRAME>';
		if (bReturnString) {
			return sHTML;
		} else {			document.write(sHTML);		}	
	} 
}
function DisplayAdsBackUp(sitepage, width, height) 
{	document.write('<table border=0 cellpadding=0 cellspacing=0 WIDTH=' + width + ' HEIGHT=' + height + '>');
	document.write('<tr><td align=center valign=middle>');
	document.write('<A href="http://www.nana.co.il">');	if (width=='200' && height=='55') {		document.write('<IMG border="0" height="55" width="200" src="http://common.nana.co.il/Header/nana200.gif"></A>');
	} else if (width=='400' && height=='55') {
		document.write('<IMG border="0" height="55" width="400" src="http://common.nana.co.il/Header/nana400.gif"></A>');	} else {
		document.write('<IMG border="0" height=' + height + ' width=' + width + ' src="http://common.nana.co.il/Header/pixel.gif"></A>');
	}	document.write('</td><tr></table>');
}
