/*
	script take care of Input fields
	01/04/03 Shay Lapid
*/
function Input(oInput)
{
var iMaxSize;
this.iMaxSize=iMaxSize;
oInput.iMaxSize=iMaxSize;

oInput.AddToPosition=AddToPosition;
this.AddToPosition=AddToPosition;
oInput.BlockHebChar=BlockHebChar;
this.BlockNonHebChar=BlockNonHebChar;
oInput.BlockNonHebChar=BlockNonHebChar;
this.BlockHebChar=BlockHebChar;
oInput.BlockNonEnglishChar=BlockNonEnglishChar;
this.BlockNonEnglishChar=BlockNonEnglishChar;
this.Sort = Sort;
oInput.Sort = Sort;
this.FixUrl=FixUrl;
oInput.FixUrl=FixUrl;	
this.CheckEmail=CheckEmail;
oInput.CheckEmail=CheckEmail;	
this.getContentSize=getContentSize;
oInput.getContentSize=getContentSize;	
this.MaxLength=MaxLength;
oInput.MaxLength=MaxLength;	

this.CheckLength=CheckLength;
oInput.CheckLength=CheckLength;	

	function MaxLength(iMaxLength)
	{
		oInput.iMaxSize=iMaxLength-1;
		oInput.onkeypress=ConCat;
	}
	
	function ConCat()
	{
		if (oInput.iMaxSize<getContentSize())
		{
				oInput.innerText=oInput.innerText.substring(0,oInput.iMaxSize);
				alert('ניתן להכניס עד ' + (oInput.iMaxSize + 1) + ' תוים')
		}
	}
	
	function CheckLength(iSize)
	{
		var arr=oInput.value.split(' ');
		
		for (i=0;i<arr.length;i++)
			if (arr[i].length>iSize)
				return false;
		return true;
	}	
	
	function getContentSize()
	{
	return getContent().length;
	}
	
	function getContent()
	{
	if (!oInput.value)
		return oInput.innerText;
	else
		return oInput.value;
	}
	
	function CheckEmail()
	{
		return (oInput.value.indexOf("@")> 1 && oInput.value.indexOf(".") > oInput.value.indexOf("@") + 2 );
	}

	function FixUrl()
	{
		if (oInput.value.indexOf("mailto:")!=-1 || oInput.value.indexOf("http://")!=-1) return ;
		if (oInput.value.indexOf("@")!=-1)
			oInput.value = "mailto:" + oInput.value
		else
			if (oInput.value.indexOf("www")!=-1)
				if (oInput.value.indexOf("http")==-1)
					oInput.value = "http://" + oInput.value
	}	
	
	function AddToPosition(sText)
	{
		oInput.focus();
		document.selection.createRange().text=sText;
	}

	function BlockNonHebChar() 
	{
		var PressedKey = window.event.keyCode;					
		if (!((PressedKey>=1488) && (PressedKey<=1514)) || !PressedKey==39) 
		{ 
			window.event.returnValue = 0;
		} 			
	}

	function BlockHebChar() 
	{
		var PressedKey = window.event.keyCode;					
		if ((PressedKey>=1488) && (PressedKey<=1514) ) 
		{ 
			window.event.returnValue = 0;
		} 			
	}

	function BlockNonEnglishChar() 
	{
		var PressedKey = window.event.keyCode;					
		if (!(
			(PressedKey>=97 && PressedKey<=122) || 
			(PressedKey>=65 && PressedKey<=90)) 
			)
		{
			window.event.returnValue = 0;
		} 			
	}

	function Sort(ArrInput, IsCaseSensitive)
	{
		var arrSort = new Array(ArrInput.length);
		var sInput
		for (i = 0; i < arrSort.length; ++i)
		{
			sInput = ArrInput[i].value
			if (IsCaseSensitive)
				arrSort[i] = sInput;
			else
				arrSort[i] = sInput.toLowerCase();

		}

		arrSort = arrSort.sort();

		var index = 0;
		for (i = 0; i < arrSort.length; ++i)
			for (j = 0; j < arrSort.length; ++j)
			{
				sInput = ArrInput[j].value;
				if (!IsCaseSensitive)
					sInput = sInput.toLowerCase();
				if (arrSort[i] == sInput)
					oInput[j].value = ++index;
			}
	}	
	
}