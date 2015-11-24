<!--- 

		<!--- put data into regular URL scope --->
		<cfset objUrl = new UrlParamEncoder().DecodeUrl(storeIn="URL")>
 --->


<h2>Application Scope</h2>
<cfdump var="#Application#">
<hr>

<h2>URL Scope</h2>
<cfdump var="#URL#">

<hr>

<h2>Request Scope</h2>
<cfdump var="#Request#">