<cfcomponent hint="my simple session app" output="false">
	<cfscript>				
		this.Name="URLApp";
		this.SessionManagement="Yes";
		this.ClientManagement="Yes";
		this.ClientStorage ="Cookie";
	</cfscript>

	<cffunction name="onRequestStart">
		<!--- decode encrypted URL --->
		<cfset objUrl = new UrlParamEncoder().DecodeUrl()>
		
		
	</cffunction>
</cfcomponent>