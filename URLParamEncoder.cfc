<!--- 
(c) 2011 Bilal Soylu
Distributed under the Creative Commons version 3 license.
http://creativecommons.org/licenses/by/3.0/

Use either the EncodeUrl or DecodeUrl public methods
It is recommended that you use the DecodeUrl method in the your application's onRequestStart method.
If you want the data to be returned in regular URL scope don't forget to specify the storeIn argument:
For example:
new UrlParamEncoder().DecodeUrl(storeIn="URL")

EcodeUrl
--------
To encode URL call the EncodeURL function.
This function will create secure (encrypt) input object. The input can be any kind of CF object, though size is important
as many Firewalls will not let long URL parameters pass.
During encoding you can specify how long a generated Url is valid and whether you only want the client you have issued to (by IP)
use it.

Decode
------
reverses the URL encoding and encryption process. 
Can place the resulting data into either Request.URL scope or regular URL scope.

 --->

<cfcomponent displayname="URLParamEncoderDecoder" hint="Encodes and Decodes URL Parameters">
	<cfscript>
		//constructor will create encryption key in application scope
		init();		
	</cfscript>
	
	<cffunction name="EncodeUrl" returntype="string" hint="this is the main function that runs the URL encryption and encoding of data" output="false">
		<cfargument name="inputData" type="any" required="true" hint="input object to be encoded. This can be any type of data. Though if it is a large data block it may be rejected by firewalls. Firewall commonly do not allow more than 1024 or 2048 bytes in URL strings.">
		<cfargument name="ttl" type="numeric" default="0" hint="time to live in seconds for this URL package. if zero, no time out.">
		<cfargument name="requireOrigin" type="boolean" default="Yes" hint="Whether we require that the URL is used from the same origin as when URL was generated, i.e. cannot be shared? If YES URL has to be used from the IP it was issued to, if NO it can be shared.">
		
		<!--- init data --->
		<cfset var strEncoded = "">
		<cfset var strEncrypted ="">
		<cfset var dteExpires = DateAdd("s",int(arguments.ttl),now())>
		<cfset var stcData = {d=arguments.inputData}>
		
		<!--- if ttl is provided and not zero add it to data  --->
		<cfif arguments.ttl GT 0>
			<cfset stcData.e = dteExpires>
		</cfif>
		<!--- if same origin policy add data --->
		<cfif arguments.requireOrigin>
			<cfset stcData.s=CGI.REMOTE_ADDR>			
		</cfif>
		<!--- serialize into compact package --->
		<cfset strEncoded=SerializeJSON(stcData)>
	
		
		<!--- encrypt and finalize package --->
		<cfset strEncrypted = "P=" & URLEncodedFormat(encrypt(strEncoded,variables.encKey,"AES","Base64"))>
	
		
		<cfreturn strEncrypted>		
		
	</cffunction>
	
	<!--- decoding function can take the explicit argument for URL parameters --->
	<cffunction name="DecodeUrl" hint="this is the main function that runs the URL decryption and decoding of data">
		<cfargument name="inputData" type="string" required="false" hint="this should be then encoded and encrypted data from the URL.P parameter.">
		<cfargument name="storeIn" type="string" default="REQUEST" required="false" hint="In which scope scope should the processed data be stored. REQUEST or URL. If REQUEST, we will store the data in REQUEST.URL. If URL, we will add the data to the URL scope.">
		<cfargument name="throwOnError" type="boolean" default="true" required="false" hint="if error is encountered during decrypting we will throw error. Otherwise we will silently return process.">
		
		<!--- init data --->
		<cfset var strEncoded = "">
		<cfset var strEncrypted ="">		
		<cfset var stcData = {}>		
		<cfset var strErr = "">
		
		<cftry>
			
			<cfif isDefined("arguments.inputData")>
				<cfset strEncrypted = URLDecode(arguments.inputData)>
			<cfelseif isDefined("URL.P")>
				<cfset strEncrypted = URL.P>
			</cfif>
		
			<!--- if we have found something to decrypt we will run the process --->			
			<cfif strEncrypted NEQ "">
				
				<cfset strEncoded = decrypt(strEncrypted,variables.encKey,"AES","Base64")>
				<cfset stcData = DeserializeJSON(strEncoded)>
				<!--- check whether the data is coming from correct IP  --->
				<cfif isDefined("stcData.s") AND stcData.s NEQ CGI.REMOTE_ADDR>
					<cfset strErr = "wrong origin for URL [#CGI.REMOTE_ADDR#]">
				</cfif>
				<!--- check whether time to live has expired --->
				<cfif isDefined("stcData.e") AND Now() GT stcData.e >
					<cfset strErr = strErr &  " URL has expired">
				</cfif>
				<!--- if error has occured throw error --->
				<cfif strErr NEQ "">
					<cfthrow detail="#strErr#" type="URL" message="URL Param Encoder Verification Failed">
				</cfif>
				<!--- determine which scope we will place data --->
				<cfif arguments.storeIn EQ "URL">
					<cfset StructAppend(URL, stcData.d)>
				<cfelse>
					<!--- we will place in request scope in all other cases --->					
					<cfset Request.URL = stcData.d>
				</cfif>
			</cfif>

		
		
			<cfcatch type="any">
				<cfif arguments.throwOnError>
					<cfrethrow>
				</cfif>
			
			</cfcatch>
		</cftry>
		
	</cffunction>
	
	
	
	<cffunction name="init" hint="startup function">
		<cfscript>
			if (isDefined("Application.UrlDecoder.key")) {
				//read key
				variables.encKey = Application.UrlDecoder.key;
			} else {
				//generate and store key
				variables.encKey = generateSecretKey("AES",128);
				Application.UrlDecoder.key = variables.encKey;
			}	
		</cfscript>
	</cffunction>
</cfcomponent>