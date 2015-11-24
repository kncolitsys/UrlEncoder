<!--- data to transfer --->
<cfset stcUser = StructNew()>
<cfset stcUser.favColor = "orange">
<cfset stcUser.favAnimal= "cat">
<cfset stcUser.userID=99>

<cfoutput>
<!--- sample page has url to second page --->
Old Url:

<a href="url2.cfm?color=#stcUser.favColor#&animal=#stcUser.favAnimal#"> Old Style Url </a>
<hr>


<cfset objUrl = new UrlParamEncoder()>

New Url:
<a href="url2.cfm?#objUrl.EncodeUrl(stcUser)#"> Secure URL </a> <br>

Short Lived:
<a href="url2.cfm?#objUrl.EncodeUrl(inputData=stcUser,ttl=5)#"> Secure URL </a> <br>
</cfoutput>




