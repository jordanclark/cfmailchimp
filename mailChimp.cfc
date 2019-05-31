<cfcomponent displayname="MailChimp" hint="I use the Mail Chimp API" output="false">


<cffunction name="init" access="public" output="false">
	<cfargument name="apiKey" type="string" required="true">
	<cfargument name="apiUrl" type="string" required="true" default="https://<dc>.api.mailchimp.com/<ver>/">
	
	<cfset this.datacenter = listLast( arguments.apiKey, "-" )>
	<cfset this.apiKey = arguments.apiKey>
	<cfset this.apiUrl = replaceNoCase( arguments.apiUrl, "<dc>", this.datacenter )>
	<cfset this.httpTimeOut = 120>
	
	<cfset variables.exceptions = {
		<!--- GENERAL SYSTEM ERRORS --->
		"-32601" = "ServerError_MethodUnknown"
	,	"-32602" = "ServerError_InvalidParameters"
	,	"-99" = "Unknown_Exception"
	,	"-98" = "Request_TimedOut"
	,	"-92" = "Zend_Uri_Exception"
	,	"-91" = "PDOException"
	,	"-91" = "Avesta_Db_Exception"
	,	"-90" = "XML_RPC2_Exception"
	,	"-90" = "XML_RPC2_FaultException"
	,	"-50" = "Too_Many_Connections"
	,	0 = "Parse_Exception"
		
		<!---100: User Related Errors--->
	,	100 = "User_Unknown"
	,	101 = "User_Disabled"
	,	102 = "User_DoesNotExist"
	,	103 = "User_NotApproved"
	,	104 = "Invalid_ApiKey"
	,	105 = "User_UnderMaintenance"
	,	106 = "Invalid_AppKey"
	,	107 = "Invalid_IP"
	,	108 = "User_DoesExist"

		<!---120: User - Action Related Errors--->
	,	120 = "User_InvalidAction"
	,	121 = "User_MissingEmail"
	,	122 = "User_CannotSendCampaign"
	,	123 = "User_MissingModuleOutbox"
	,	124 = "User_ModuleAlreadyPurchased"
	,	125 = "User_ModuleNotPurchased"
	,	126 = "User_NotEnoughCredit"
	,	127 = "MC_InvalidPayment"
	
		<!---200: List Related Errors--->
	,	200 = "List_DoesNotExist"
	
		<!---210: List - Basic Actions--->
	,	210 = "List_InvalidInterestFieldType"
	,	211 = "List_InvalidOption"
	,	212 = "List_InvalidUnsubMember"
	,	213 = "List_InvalidBounceMember"
	,	214 = "List_AlreadySubscribed"
	,	215 = "List_NotSubscribed"
	
		<!---220: List - Import Related--->
	,	220 = "List_InvalidImport"
	,	221 = "MC_PastedList_Duplicate"
	,	222 = "MC_PastedList_InvalidImport"
	
		<!---230: List - Email Related--->
	,	230 = "Email_AlreadySubscribed"
	,	231 = "Email_AlreadyUnsubscribed"
	,	232 = "Email_NotExists"
	,	233 = "Email_NotSubscribed"
	
		<!---250: List - Merge Related--->
	,	250 = "List_MergeFieldRequired"
	,	251 = "List_CannotRemoveEmailMerge"
	,	252 = "List_Merge_InvalidMergeID"
	,	253 = "List_TooManyMergeFields"
	,	254 = "List_InvalidMergeField"
	
		<!---270: List - Interest Group Related--->
	,	270 = "List_InvalidInterestGroup"
	,	271 = "List_TooManyInterestGroups"
	
		<!---300: Campaign Related Errors--->
	,	300 = "Campaign_DoesNotExist"
	,	301 = "Campaign_StatsNotAvailable"
	
		<!---310: Campaign - Option Related Errors--->
	,	310 = "Campaign_InvalidAbsplit"
	,	311 = "Campaign_InvalidContent"
	,	312 = "Campaign_InvalidOption"
	,	313 = "Campaign_InvalidStatus"
	,	314 = "Campaign_NotSaved"
	,	315 = "Campaign_InvalidSegment"
	,	316 = "Campaign_InvalidRss"
	,	317 = "Campaign_InvalidAuto"
	,	318 = "MC_ContentImport_InvalidArchive"
	,	319 = "Campaign_BounceMissing"
	
		<!---330: Campaign - Ecomm Errors--->
	,	330 = "Invalid_EcommOrder"
	
		<!---350: Campaign - Absplit Related Errors--->
	,	350 = "Absplit_UnknownError"
	,	351 = "Absplit_UnknownSplitTest"
	,	352 = "Absplit_UnknownTestType"
	,	353 = "Absplit_UnknownWaitUnit"
	,	354 = "Absplit_UnknownWinnerType"
	,	355 = "Absplit_WinnerNotSelected"
	
		<!---500: Generic Validation Errors--->
	,	500 = "Invalid_Analytics"
	,	501 = "Invalid_DateTime"
	,	502 = "Invalid_Email"
	,	503 = "Invalid_SendType"
	,	504 = "Invalid_Template"
	,	505 = "Invalid_TrackingOptions"
	,	506 = "Invalid_Options"
	,	507 = "Invalid_Folder"
	,	508 = "Invalid_URL"
	
		<!---550: Generic Unknown Errors--->
	,	550 = "Module_Unknown"
	,	551 = "MonthlyPlan_Unknown"
	,	552 = "Order_TypeUnknown"
	,	553 = "Invalid_PagingLimit"
	,	554 = "Invalid_PagingStart"
	}>
	
		
	<cfset this.listInterestGroupings = this.listGroupSets>
	<cfset this.listInterestGroupingAdd = this.listAddGroupSet>
	<cfset this.listInterestGroupingUpdate = this.listUpdateGroupSet>
	<cfset this.listInterestGroupingDel = this.listDelGroupSet>
	
	<cfset this.listInterestGroupAdd = this.listAddGroup>
	<cfset this.listInterestGroupUpdate = this.listUpdateGroup>
	<cfset this.listInterestGroupDel = this.listDelGroup>

	<cfset this.campaignReplicate = this.campaignCopy>
	
	<cfreturn this>
</cffunction>


<cffunction name="debugLog" output="false">
	<cfargument name="input" type="any" required="true">
	
	<cfif structKeyExists( request, "log" ) AND isCustomFunction( request.log )>
		<cfif isSimpleValue( arguments.input )>
			<cfset request.log( "MailChimp: " & arguments.input )>
		<cfelse>
			<cfset request.log( "MailChimp: (complex type)" )>
			<cfset request.log( arguments.input )>
		</cfif>
	<cfelse>
		<cftrace
			type="information"
			category="MailChimp"
			text="#( isSimpleValue( arguments.input ) ? arguments.input : "" )#"
			var="#arguments.input#"
		>
	</cfif>
	
	<cfreturn>
</cffunction>


<cffunction name="mcDateFormat" output="false">
	<cfargument name="date" type="string" required="true">

	<cfif len( arguments.date ) AND isDate( arguments.date )>
		<cfset arguments.date = dateConvert( "local2utc", arguments.date )>
		<cfset arguments.date = dateFormat( arguments.date, "yyyy-mm-dd" ) & " " & timeFormat( arguments.date, "HH:mm:ss" )>
	<cfelse>
		<cfset arguments.date = "">
	</cfif>
	
	<cfreturn arguments.date>
</cffunction>


<cffunction name="mcDollarFormat" output="false" returnType="numeric">
	<cfargument name="value" type="string" required="true">

	<cfreturn replace( numberFormat( arguments.value, ".00" ), ",", "", "all" ) * 1.00>
</cffunction>



<!--- ---------------------------------------------------------------------------------------------------------- --->
<!--- HELPER METHODS --->
<!--- ---------------------------------------------------------------------------------------------------------- --->


<!--- http://www.mailchimp.com/api/1.2/ping.func.php --->
<cffunction name="ping" access="public" output="false"
	hint="ping"
>
	<cfset var out= this.apiRequest(
		apiMethod= "ping"
	)>
	
	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.2/chimpchatter.func.php --->
<cffunction name="chimpChatter" access="public" output="false"
	hint="Return the current Chimp Chatter messages for an account."
>
	<cfset var out= this.apiRequest(
		apiMethod= "chimpChatter"
	)>
	
	<!--- returns array: message, type, list_id, campaign_id, update_time --->
	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.2/getaccountdetails.func.php --->
<cffunction name="getAccountDetails" access="public" output="false"
	hint="Retrieve lots of account information including payments made, plan info, some account stats, installed modules, contact info, and more. No private information like Credit Card numbers is available."
>
	<cfset var out= this.apiRequest(
		apiMethod= "getAccountDetails"
	)>
	
	<!--- returns array: username, user_id, is_trial, timezone, plan_type, plan_low, plan_high, plan_start_date --->
	<!--- emails_left, pending_monthly, first_payment, last_payment, times_logged_in, last_login, affiliate_link --->
	<!--- contact[], modules[], orders[], rewards[] --->
	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.2/createfolder.func.php --->
<cffunction name="createFolder" access="public" output="false"
	hint="Create a new folder to file campaigns in"
>
	<cfargument name="name" type="string" required="true">
	
	<cfset var out= this.apiRequest(
		apiMethod= "createFolder"
	,	name="#arguments.name#"
	)>
	
	<!--- returns folder_id --->
	<cfreturn out>
</cffunction>


<!--- http://apidocs.mailchimp.com/1.3/folderadd.func.php --->
<cffunction name="folderAdd" access="public" output="false"
	hint="Add a new folder to file campaigns or autoresponders in"
>
	<cfargument name="name" type="string" required="true">
	<cfargument name="type" type="string" default="campaign"><!--- campaign or autoresponder --->
	
	<cfset var out= this.apiRequest(
		apiMethod= "folderAdd"
	,	apiVersion= "1.3"
	,	name= arguments.name
	,	type= arguments.type
	)>
	
	<!--- returns folder_id --->
	<cfreturn out>
</cffunction>


<!--- http://apidocs.mailchimp.com/1.3/folderdel.func.php --->
<cffunction name="folderDel" access="public" output="false"
	hint="Delete a campaign or autoresponder folder. Note that this will simply make campaigns in the folder appear unfiled, they are not removed."
>
	<cfargument name="folderID" type="string" required="true">
	
	<cfset var out= this.apiRequest(
		apiMethod= "folderDel"
	,	apiVersion= "1.3"
	,	fid= arguments.folderID
	)>
	
	<!--- returns boolean --->
	<cfreturn out>
</cffunction>


<!--- http://apidocs.mailchimp.com/1.3/folderupdate.func.php --->
<cffunction name="folderUpdate" access="public" output="false"
	hint="Update the name of a folder for campaigns or autoresponders."
>
	<cfargument name="folderID" type="string" required="true">
	<cfargument name="name" type="string" required="true">
	<cfargument name="type" type="string" required="true"><!--- campaign or autoresponder --->
	
	<cfset var out= this.apiRequest(
		apiMethod= "folderUpdate"
	,	apiVersion= "1.3"
	,	fid= arguments.folderID
	,	name= arguments.name
	,	type= arguments.type
	)>
	
	<!--- returns folder_id --->
	<cfreturn out>
</cffunction>


<!--- http://apidocs.mailchimp.com/1.3/folders.func.php --->
<cffunction name="folders" access="public" output="false"
	hint="List all the folders for a user account."
>
	<cfargument name="type" type="string" required="true"><!--- campaign or autoresponder --->
	
	<cfset var out= this.apiRequest(
		apiMethod= "folders"
	,	apiVersion= "1.3"
	,	type= arguments.type
	)>
	
	<!--- returns array: folder_id, name, date_created, type --->
	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.2/generatetext.func.php --->
<cffunction name="generateText" access="public" output="false"
	hint="Have HTML content auto-converted to a text-only format."
>
	<cfargument name="html" type="string" required="true">
	
	<cfset var out= this.apiRequest(
		apiMethod= "generateText"
	,	output="html"
	,	type="html"
	,	content= arguments.html
	)>
	
	<!--- returns html --->
	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.2/inlinecss.func.php --->
<cffunction name="inlineCss" access="public" output="false"
	hint="Send your HTML content to have the CSS inlined and optionally remove the original styles."
>
	<cfargument name="html" type="string" required="true">
	<cfargument name="stripStyle" type="boolean" default="true">
	
	<cfset var out= this.apiRequest(
		apiMethod= "inlineCss"
	,	output="html"
	,	html= arguments.html
	,	strip_css= arguments.stripStyle
	)>
	
	<!--- returns html --->
	<cfreturn out>
</cffunction>



<!--- ---------------------------------------------------------------------------------------------------------- --->
<!--- API METHODS --->
<!--- ---------------------------------------------------------------------------------------------------------- --->


<!--- http://www.mailchimp.com/api/1.2/apikeys.func.php --->
<cffunction name="apiKeys" access="public" output="false"
	hint="Retrieve a list of all MailChimp API Keys for this User"
>
	<cfargument name="username" type="string" required="true">
	<cfargument name="password" type="string" required="true">
	
	<cfset var out= this.apiRequest(
		apiMethod= "apikeys"
	,	argumentCollection= arguments
	)>
	
	<!--- returns array: apikey, created_at, expired_at --->
	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.2/apikeyadd.func.php --->
<cffunction name="apiKeyAdd" access="public" output="false"
	hint="Add an API Key to your account. We will generate a new key for you and return it."
>
	<cfargument name="username" type="string" required="true">
	<cfargument name="password" type="string" required="true">
	
	<cfset var out= this.apiRequest(
		apiMethod= "apikeyAdd"
	,	argumentCollection= arguments
	)>
	
	<!--- returns apikey --->
	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.2/apikeyadd.func.php --->
<cffunction name="apiKeyExpire" access="public" output="false"
	hint="Expire a Specific API Key."
>
	<cfargument name="username" type="string" required="true">
	<cfargument name="password" type="string" required="true">
	<cfargument name="apikey" type="string" required="true">
	
	<cfset var out= this.apiRequest(
		apiMethod= "apikeyExpire"
	,	argumentCollection= arguments
	)>
	
	<!--- returns boolean --->
	<cfreturn out>
</cffunction>



<!--- ---------------------------------------------------------------------------------------------------------- --->
<!--- WEBHOOK METHODS --->
<!--- ---------------------------------------------------------------------------------------------------------- --->


<!--- http://www.mailchimp.com/api/1.2/listwebhook.func.php --->
<cffunction name="listWebhooks" access="public" output="false"
	hint="Return the Webhooks configured for the given list"
>
	<cfargument name="list" type="string" required="true">
	
	<cfset var out= this.apiRequest(
		apiMethod= "listWebhooks"
	,	id= arguments.list
	)>
	
	<!--- returns array: url, actions, sources --->
	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.2/listwebhookadd.func.php --->
<cffunction name="listWebhookAdd" access="public" output="false"
	hint="Add a new Webhook URL for the given list"
>
	<cfargument name="list" type="string" required="true">
	<cfargument name="url" type="string" required="true">
	<cfargument name="actions" type="string" required="true" hint="subscribe, unsubscribe, profile, cleaned, upemail">
	<cfargument name="sources" type="string" required="true" hint="user, admin, api">
	
	<cfset var out= this.apiRequest(
		apiMethod= "listWebhookAdd"
	,	id= arguments.list
	,	url= arguments.url
	,	actions= listToArray( arguments.actions )
	,	sources= listToArray( arguments.sources )
	)>
	
	<!--- returns boolean --->
	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.2/listwebhookdel.func.php --->
<cffunction name="listWebhookDel" access="public" output="false"
	hint="Delete an existing Webhook URL from a given list"
>
	<cfargument name="list" type="string" required="true">
	<cfargument name="url" type="string" required="true">
	
	<cfset var out= this.apiRequest(
		apiMethod= "listWebhookDel"
	,	id= arguments.list
	,	url= arguments.url
	)>
	
	<!--- returns boolean --->
	<cfreturn out>
</cffunction>



<!--- ---------------------------------------------------------------------------------------------------------- --->
<!--- LIST METHODS --->
<!--- ---------------------------------------------------------------------------------------------------------- --->


<!--- http://www.mailchimp.com/api/1.2/lists.func.php --->
<cffunction name="lists" access="public" output="false"
	hint="Retrieve all of the lists defined for your user account"
>
	<cfset var out= this.apiRequest(
		apiMethod= "lists"
	)>
	
	<!--- returns array: id, web_id, name, date_created, member_count, unsubscribe_count, cleaned_count --->
	<!--- email_type_option, default_from_name, default_from_email, default_subject, default_language, list_rating --->
	<!--- member_count_since_send, unsubscribe_count_since_send, cleaned_count_since_send --->
	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.2/listsforemail.func.php --->
<cffunction name="listsForEmail" access="public" output="false"
	hint="Retrieve all List Ids a member is subscribed to."
>
	<cfargument name="email" type="string" required="true">
	
	<cfset var out= this.apiRequest(
		apiMethod= "listsForEmail"
	,	email_address= arguments.email
	)>
	
	<!--- returns array: list_id --->
	<cfreturn out>
</cffunction>


<!--- http://apidocs.mailchimp.com/1.3/listclients.func.php --->
<cffunction name="listClients" access="public" output="false"
	hint="Retrieve the clients that the list's subscribers have been tagged as being used based on user agents seen. Made possible by user-agent-string.info"
>
	<cfargument name="list" type="string" required="true">
	
	<cfset var out= this.apiRequest(
		apiMethod= "listClients"
	,	apiVersion= "1.3"
	,	id= arguments.list
	)>
	
	<!--- returns array: desktop --->
	<cfreturn out>
</cffunction>


<!--- http://apidocs.mailchimp.com/1.3/listactivity.func.php --->
<cffunction name="listActivity" access="public" output="false"
	hint=""
>
	<cfargument name="list" type="string" required="true">
	
	<cfset var out= this.apiRequest(
		apiMethod= "listActivity"
	,	apiVersion= "1.3"
	,	id= arguments.list
	)>
	
	<!--- returns array: day, emails_sent, unique_opens, recipient_clicks, hard_bounce, soft_bounce, abuse_reports, subs, unsubs, other_adds, other_removes --->
	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.3/listabusereports.func.php --->
<cffunction name="listAbuseReports" access="public" output="false"
	hint="Get all email addresses that complained about a given list"
>
	<cfargument name="list" type="string" required="true">
	<cfargument name="start" type="numeric" default="0">
	<cfargument name="limit" type="numeric" default="100">
	<cfargument name="since" type="string" default="">
	
	<cfset var out = "">
	
	<cfif isDate( arguments.since )>
		<cfset arguments.since = this.mcDateFormat( arguments.since )>
	</cfif>
	
	<cfset out= this.apiRequest(
		apiMethod= "listAbuseReports"
	,	apiVersion= "1.3"
	,	verb="GET"
	,	id= arguments.list
	,	start= arguments.start
	,	limit= arguments.limit
	,	since= arguments.since
	)>
	
	<!--- returns array: date, email, campaign_id, type --->
	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.2/listgrowthhistory.func.php --->
<cffunction name="listGrowthHistory" access="public" output="false"
	hint="Get all email addresses that complained about a given list"
>
	<cfargument name="list" type="string" required="true">
	
	<cfset var out= this.apiRequest(
		apiMethod= "listGrowthHistory"
	,	id= arguments.list
	)>
	
	<!--- returns array: month, existing, imports, optin --->
	<cfreturn out>
</cffunction>



<!--- ---------------------------------------------------------------------------------------------------------- --->
<!--- LIST SUBSCRIPTION METHODS --->
<!--- ---------------------------------------------------------------------------------------------------------- --->


<cffunction name="listSubscribe" access="public" output="false"
	hint="Subscribe the provided email to a list"
>
	<cfargument name="list" type="string" required="true">
	<cfargument name="email" type="string" required="true">
	<cfargument name="emailType" type="string" default="">
	<cfargument name="firstName" type="string" default="">
	<cfargument name="lastName" type="string" default="">
	<cfargument name="groups" type="any" default="">
	<cfargument name="ip" type="string" default="">
	<cfargument name="created" type="string" default="">
	<cfargument name="mergeVars" type="struct" default="#{}#">
	<cfargument name="sendConfirm" type="boolean" default="false">
	<cfargument name="updateExisting" type="boolean" default="false">
	<cfargument name="replaceGroups" type="boolean" default="false">
	<cfargument name="sendWelcome" type="boolean" default="false">
	
	<cfset var out = "">
	<cfset var gid = "">
	<cfset var args = {}>
	
	<cfif len( arguments.firstname )>
		<cfset arguments.mergeVars[ "FNAME" ] = arguments.firstname>
	</cfif>
	<cfif len( arguments.lastname )>
		<cfset arguments.mergeVars[ "LNAME" ] = arguments.lastname>
	</cfif>
	<cfif isSimpleValue( arguments.groups ) AND len( arguments.groups )>
		<cfset arguments.mergeVars[ "GROUPINGS" ] = []>
		<cfloop list="#arguments.groups#" index="gid" delimiters=";">
			<cfif isNumeric( listGetAt( gid, 1, ":" ) )> 
				<cfset arrayAppend( arguments.mergeVars[ "GROUPINGS" ], {
					"id" = listGetAt( gid, 1, ":" ) 
				,	"groups" = replaceNoCase( listGetAt( gid, 2, ":" ), "null", "" )
				} )>
			<cfelse>
				<cfset arrayAppend( arguments.mergeVars[ "GROUPINGS" ], {
					"name" = listGetAt( gid, 1, ":" ) 
				,	"groups" = replaceNoCase( listGetAt( gid, 2, ":" ) , "null", "" )
				} )>
			</cfif>
		</cfloop>
	<cfelseif isArray( arguments.groups )>
		<!--- broken --->
		<!--- <cfset arguments.mergeVars[ "GROUPS" ] = arguumnets.groups> --->
	</cfif>
	<cfif len( arguments.ip )>
		<cfset arguments.mergeVars[ "OPTIN_IP" ] = arguments.ip>
	</cfif>
	<cfif isDate( arguments.created )>
		<cfset arguments.mergeVars[ "OPTIN_TIME" ] = this.mcDateFormat( arguments.created )>
	</cfif>
	
	<cfset this.flattenObject( args, "merge_vars", arguments.mergeVars )> 
	
	<cfset out= this.apiRequest(
		apiMethod= "listSubscribe"
	,	id= arguments.list
	,	email_address= arguments.email	
	,	email_type= arguments.emailType
	,	double_optin= arguments.sendConfirm
	,	update_existing= arguments.updateExisting
	,	replace_interests= arguments.replaceGroups
	,	send_welcome= arguments.sendWelcome
	,	argumentCollection= args 
	)>
	<!--- merge_vars= rguments.mergeVars --->
	
	<!--- returns boolean --->
	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.2/listunsubscribe.func.php --->
<cffunction name="listUnsubscribe" access="public" output="false"
	hint="Unsubscribe the given email address from the list"
>
	<cfargument name="list" type="string" required="true">
	<cfargument name="email" type="string" required="true">
	<cfargument name="deleteMember" type="boolean" default="false">
	<cfargument name="sendGoodbye" type="boolean" default="false">
	<cfargument name="sendNotify" type="boolean" default="false">
	
	<cfset var out= this.apiRequest(
		apiMethod= "listUnsubscribe"
	,	id= arguments.list
	,	email_address= arguments.email
	,	delete_member= arguments.deleteMember
	,	send_goodbye= arguments.sendGoodbye
	,	send_notify= arguments.sendNotify
	)>
	
	<!--- returns boolean --->
	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.2/listbatchunsubscribe.func.php --->
<cffunction name="listBatchUnsubscribe" access="public" output="false"
	hint="Unsubscribe a batch of email addresses to a list"
>
	<cfargument name="list" type="string" required="true">
	<cfargument name="emails" type="any" required="true">
	<cfargument name="deleteMember" type="boolean" default="false">
	<cfargument name="sendGoodbye" type="boolean" default="false">
	<cfargument name="sendNotify" type="boolean" default="false">
	
	<cfset var out = "">
	<cfset var args = {}>
	
	<cfif isSimpleValue( arguments.emails )>
		<cfset arguments.emails = listToArray( arguments.emails, ";" )>
	</cfif>
	
	<cfset this.flattenObject( args, "emails", arguments.emails )> 
	
	<cfset out= this.apiRequest(
		apiMethod= "listBatchUnsubscribe"
	,	id= arguments.list
	,	delete_member= arguments.deleteMember
	,	send_goodbye= arguments.sendGoodbye
	,	send_notify= arguments.sendNotify
	,	argumentCollection= args
	)> <!--- emails --->
	<!--- emails="#arguments.emails#" --->
	
	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.2/listbatchsubscribe.func.php --->
<cffunction name="listBatchSubscribe" access="public" output="false"
	hint="Subscribe a batch of email addresses to a list at once."
>
	<cfargument name="list" type="string" required="true">
	<cfargument name="batch" type="any" required="true">
	<cfargument name="groups" type="any" default="">
	<cfargument name="sendConfirm" type="boolean" default="false">
	<cfargument name="updateExisting" type="boolean" default="false">
	<cfargument name="replaceGroups" type="boolean" default="false">
	
	<cfset var out = "">
	<cfset var email = "">
	<cfset var b = 0>
	<cfset var args = {}>
	
	<cfif isSimpleValue( arguments.batch )>
		<cfset b = []>
		<cfloop index="email" list="#arguments.batch#" delimiters=";">
			<cfset b= this.addToSubscribeBatch(
				batch= b
			,	email= email
			,	groups= arguments.groups
			)>
		</cfloop>
		<cfset arguments.batch = b>
	</cfif>
	
	<cfset this.flattenObject( args, "batch", arguments.batch )> 
	
	<cfset out= this.apiRequest(
		apiMethod= "listBatchSubscribe"
	,	apiVersion= "1.3"
	,	id= arguments.list
	,	double_optin= arguments.sendConfirm
	,	update_existing= arguments.updateExisting
	,	replace_interests= arguments.replaceGroups
	,	argumentCollection= args
	)><!--- batch --->
	
	<cfreturn out>
</cffunction>


<cffunction name="addToSubscribeBatch" access="public" output="false">
	<cfargument name="batch" type="array" default="#[]#">
	<cfargument name="email" type="string" required="true">
	<cfargument name="emailType" type="string" default="">
	<cfargument name="firstName" type="string" default="">
	<cfargument name="lastName" type="string" default="">
	<cfargument name="groups" type="any" default="">
	<cfargument name="ip" type="string" default="">
	<cfargument name="created" type="string" default="">
	<cfargument name="mergeVars" type="struct" default="#{}#">
	
	<cfset var item = "">
	<cfset var gid = "">
	<cfset var member = arguments.mergeVars>
	
	<cfset member[ "EMAIL" ] = arguments.email>
	<cfset member[ "EMAIL_TYPE" ] = arguments.emailType>
	
	<cfif len( arguments.firstname )>
		<cfset member[ "FNAME" ] = arguments.firstname>
	</cfif>
	<cfif len( arguments.lastname )>
		<cfset member[ "LNAME" ] = arguments.lastname>
	</cfif>
	<cfif isSimpleValue( arguments.groups ) AND len( arguments.groups )>
		<cfset member[ "GROUPINGS" ] = []>
		<cfloop list="#arguments.groups#" index="gid" delimiters=";">
			<cfif isNumeric( listGetAt( gid, 1, ":" ) )> 
				<cfset arrayAppend( member[ "GROUPINGS" ], {
					"id" = listGetAt( gid, 1, ":" ) 
				,	"groups" = replaceNoCase( listGetAt( gid, 2, ":" ), "null", "" )
				} )>
			<cfelse>
				<cfset arrayAppend( member[ "GROUPINGS" ], {
					"name" = listGetAt( gid, 1, ":" ) 
				,	"groups" = replaceNoCase( listGetAt( gid, 2, ":" ) , "null", "" )
				} )>
			</cfif>
		</cfloop>
	<cfelseif isArray( arguments.groups )>
		<cfset member[ "GROUPS" ] = arguments.groups>
	</cfif>
	<cfif len( arguments.ip )>
		<cfset member[ "OPTIN_IP" ] = arguments.ip>
	</cfif>
	<cfif isDate( arguments.created )>
		<cfset member[ "OPTIN_TIME" ] = this.mcDateFormat( arguments.created )>
	</cfif>
	
	<cfset arrayAppend( arguments.batch, member )>
	
	<cfreturn arguments.batch>
</cffunction>



<!--- ---------------------------------------------------------------------------------------------------------- --->
<!--- LIST MERGEVAR METHODS --->
<!--- ---------------------------------------------------------------------------------------------------------- --->


<!--- http://www.mailchimp.com/api/1.2/listmergevars.func.php --->
<cffunction name="listMergeVars" access="public" output="false"
	hint="Get the list of merge tags for a given list, including their name, tag, and required setting"
>
	<cfargument name="list" type="string" required="true">
	
	<cfset var out= this.apiRequest(
		apiMethod= "listMergeVars"
	,	id= arguments.list
	)>
	
	<!--- returns array of merge-vars: name, req, field_type, public, show, order, default, size, tag, choices --->
	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.2/listmergevaradd.func.php --->
<cffunction name="listMergeVarAdd" access="public" output="false"
	hint="Add a new merge tag to a given list"
>
	<cfargument name="list" type="string" required="true">
	<cfargument name="tag" type="string" required="true">
	<cfargument name="name" type="string" required="true">
	<cfargument name="fieldType" type="string" required="true">
	<cfargument name="required" type="boolean" required="true">
	<cfargument name="public" type="boolean" required="true">
	<cfargument name="show" type="boolean" required="true">
	<cfargument name="default" type="string" required="true">
	<cfargument name="choices" type="string" required="true">
	
	<cfset var out = "">
	<cfset var req = {
		field_type = arguments.fieldType
	,	req = arguments.required
	,	public = arguments.public
	,	show = arguments.show
	,	default_value = arguments.default
	,	choice = arguments.choice
	}>
	
	<cfset out= this.apiRequest(
		apiMethod= "listMergeVarAdd"
	,	id= arguments.list
	,	tag= arguments.tag
	,	name= arguments.name
	,	req= req
	)>
	
	<!--- returns boolean --->
	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.2/listmergevarupdate.func.php --->
<cffunction name="listMergeVarUpdate" access="public" output="false"
	hint="Update most parameters for a merge tag on a given list. You cannot currently change the merge type"
>
	<cfargument name="list" type="string" required="true">
	<cfargument name="tag" type="string" required="true">
	<cfargument name="name" type="string" required="true">
	<cfargument name="fieldType" type="string" required="true">
	<cfargument name="required" type="boolean" required="true">
	<cfargument name="public" type="boolean" required="true">
	<cfargument name="show" type="boolean" required="true">
	<cfargument name="default" type="string" required="true">
	<cfargument name="choices" type="string" required="true">
	
	<cfset var out = "">
	
	<cfset var req = {
		field_type = arguments.fieldType
	,	req = arguments.required
	,	public = arguments.public
	,	show = arguments.show
	,	default_value = arguments.default
	,	choice = arguments.choice
	}>
	
	<cfset out= this.apiRequest(
		apiMethod= "listMergeVarUpdate"
	,	id= arguments.list
	,	tag= arguments.tag
	,	name= arguments.name
	,	req= req
	)>
	
	<!--- returns boolean --->
	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.2/listmergevardel.func.php --->
<cffunction name="listMergeVarDel" access="public" output="false"
	hint="Delete a merge tag from a given list and all its members. Seriously - the data is removed from all members as well"
>
	<cfargument name="list" type="string" required="true">
	<cfargument name="tag" type="string" required="true">
	
	<cfset var out= this.apiRequest(
		apiMethod= "listMergeVarDel"
	,	id= arguments.list
	,	tag= arguments.tag
	)>
	
	<!--- returns boolean --->
	<cfreturn out>
</cffunction>



<!--- ---------------------------------------------------------------------------------------------------------- --->
<!--- LIST GROUPINGS METHODS --->
<!--- ---------------------------------------------------------------------------------------------------------- --->


<!--- http://www.mailchimp.com/api/1.2/listinterestgroupings.func.php --->
<cffunction name="listGroupSets" access="public" output="false"
	hint="Get the list of interest groupings for a given list, including the label, form information, and included groups for each"
>
	<cfargument name="list" type="string" required="true">
	
	<cfset var out= this.apiRequest(
		apiMethod= "listInterestGroupings"
	,	id= arguments.list
	)>
	
	<!--- returns array of interest groupings: id, name, form_field, groups --->
	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.2/listinterestgroupingadd.func.php --->
<cffunction name="listAddGroupSet" access="public" output="false"
	hint="Add a new Interest Grouping - if interest groups for the List are not yet enabled, adding the first grouping will automatically turn them on."
>
	<cfargument name="list" type="string" required="true">
	<cfargument name="name" type="string" required="true">
	<cfargument name="type" type="string" required="true" hint="checkboxes,hidden,dropdown,radio">
	<cfargument name="groups" type="any" required="true">
	
	<cfset var out = "">
	
	<cfif isSimpleValue( arguments.groups )>
		<cfset arguments.groups = listToArray( arguments.groups, ";" )>
	</cfif>
	
	<cfset out= this.apiRequest(
		apiMethod= "listInterestGroupingAdd"
	,	id= arguments.list
	,	name= arguments.name
	,	type= arguments.type
	,	groups= arguments.groups
	)>
	
	<!--- returns new grouping id --->
	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.2/listinterestgroupingupdate.func.php --->
<cffunction name="listUpdateGroupSet" access="public" output="false"
	hint="Update an existing Interest Grouping"
>
	<cfargument name="grouping" type="string" required="true">
	<cfargument name="field" type="string" required="true" hint="name or type">
	<cfargument name="value" type="string" required="true">
	
	<cfset var out= this.apiRequest(
		apiMethod= "listInterestGroupingUpdate"
	,	grouping_id= arguments.grouping
	,	name= arguments.field
	,	value= arguments.value
	)>
	
	<!--- returns boolean --->
	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.2/listinterestgroupingdel.func.php --->
<cffunction name="listDelGroupSet" access="public" output="false"
	hint="Delete an existing Interest Grouping - this will permanently delete all contained interest groups and will remove those selections from all list members"
>
	<cfargument name="grouping" type="string" required="true">
	
	<cfset var out= this.apiRequest(
		apiMethod= "listInterestGroupingDel"
	,	grouping_id= arguments.grouping
	)>
	
	<!--- returns boolean --->
	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.2/listinterestgroupadd.func.php --->
<cffunction name="listAddGroup" access="public" output="false"
	hint="Add a single Interest Group - if interest groups for the List are not yet enabled, adding the first group will automatically turn them on."
>
	<cfargument name="list" type="string" required="true">
	<cfargument name="grouping" type="string" required="true">
	<cfargument name="name" type="string" required="true">
	
	<cfset var out= this.apiRequest(
		apiMethod= "listInterestGroupAdd"
	,	id= arguments.list
	,	group_name= arguments.name
	,	grouping_id= arguments.grouping
	)>
	
	<!--- returns boolean --->
	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.2/listinterestgroupupdate.func.php --->
<cffunction name="listUpdateGroup" access="public" output="false"
	hint="Change the name of an Interest Group"
>
	<cfargument name="list" type="string" required="true">
	<cfargument name="grouping" type="string" required="true">
	<cfargument name="oldName" type="string" required="true">
	<cfargument name="newName" type="string" required="true">
	
	<cfset var out= this.apiRequest(
		apiMethod= "listInterestGroupUpdate"
	,	id= arguments.list
	,	grouping_id= arguments.grouping
	,	old_name= arguments.oldName
	,	new_name= arguments.newName
	)>
	
	<!--- returns boolean --->
	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.2/listinterestgroupdel.func.php --->
<cffunction name="listDelGroup" access="public" output="false"
	hint="Delete a single Interest Group - if the last group for a list is deleted, this will also turn groups for the list off."
>
	<cfargument name="list" type="string" required="true">
	<cfargument name="grouping" type="string" required="true">
	<cfargument name="name" type="string" required="true">
	
	<cfset var out= this.apiRequest(
		apiMethod= "listInterestGroupDel"
	,	id= arguments.list
	,	group_name= arguments.name
	,	grouping_id= arguments.grouping
	)>
	
	<!--- returns boolean --->
	<cfreturn out>
</cffunction>



<!--- ---------------------------------------------------------------------------------------------------------- --->
<!--- LIST SEGMENT METHODS --->
<!--- ---------------------------------------------------------------------------------------------------------- --->


<!--- http://www.mailchimp.com/api/1.2/liststaticsegments.func.php --->
<cffunction name="listStaticSegments" access="public" output="false"
	hint=""
>
	<cfargument name="list" type="string" required="true">
	
	<cfset var out= this.apiRequest(
		apiMethod= "listStaticSegments"
	,	id= arguments.list
	)>
	
	<!--- returns array: id, name, member_count, created_date, last_update, last_reset --->
	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.2/listaddstaticsegment.func.php --->
<cffunction name="listAddStaticSegment" access="public" output="false"
	hint=""
>
	<cfargument name="list" type="string" required="true">
	<cfargument name="name" type="string" required="true">
	
	<cfset var out= this.apiRequest(
		apiMethod= "listAddStaticSegment"
	,	id= arguments.list
	,	name= arguments.name
	)>
	
	<!--- returns segment ID --->
	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.2/listdelstaticsegment.func.php --->
<cffunction name="listDelStaticSegment" access="public" output="false"
	hint=""
>
	<cfargument name="list" type="string" required="true">
	<cfargument name="segment" type="string" required="true">
	
	<cfset var out= this.apiRequest(
		apiMethod= "listDelStaticSegment"
	,	id= arguments.list
	,	seg_id= arguments.segment
	)>
	
	<!--- returns: boolean --->
	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.2/liststaticsegmentaddmembers.func.php --->
<cffunction name="listStaticSegmentAddMembers" access="public" output="false"
	hint=""
>
	<cfargument name="list" type="string" required="true">
	<cfargument name="segment" type="string" required="true">
	<cfargument name="batch" type="any" required="true">
	<cfargument name="delim" type="string" default=";">
	
	<cfset var out = "">
	
	<cfif isSimpleValue( arguments.batch )>
		<cfset arguments.batch = listToArray( arguments.batch, arguments.delim )>
	</cfif>
	
	<cfset out= this.apiRequest(
		apiMethod= "listStaticSegmentAddMembers"
	,	id= arguments.list
	,	seg_id= arguments.segment
	,	batch= arguments.batch
	)>
	
	<!--- returns array: success, error --->
	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.2/liststaticsegmentdelmembers.func.php --->
<cffunction name="listStaticSegmentDelMembers" access="public" output="false"
	hint="Get all email addresses that complained about a given list"
>
	<cfargument name="list" type="string" required="true">
	<cfargument name="segment" type="string" required="true">
	<cfargument name="batch" type="any" required="true">
	<cfargument name="delim" type="string" default=";">
	
	<cfset var out = "">
	
	<cfif isSimpleValue( arguments.batch )>
		<cfset arguments.batch = listToArray( arguments.batch, arguments.delim )>
	</cfif>
	
	<cfset out= this.apiRequest(
		apiMethod= "listStaticSegmentDelMembers"
	,	id= arguments.list
	,	seg_id= arguments.segment
	,	batch= arguments.batch
	)>
	
	<!--- returns array: success, error --->
	<cfreturn out>
</cffunction>



<!--- ---------------------------------------------------------------------------------------------------------- --->
<!--- MEMBER METHODS --->
<!--- ---------------------------------------------------------------------------------------------------------- --->


<!--- http://www.mailchimp.com/api/1.2/listmembers.func.php --->
<cffunction name="listMembers" access="public" output="false"
	hint="Get all of the list members for a list that are of a particular status"
>
	<cfargument name="list" type="string" required="true">
	<cfargument name="status" type="string" default="subscribed" hint="subscribed, unsubscribed, cleaned, updated">
	<cfargument name="since" type="string" default="">
	<cfargument name="start" type="numeric" default="0">
	<cfargument name="limit" type="numeric" default="100">
	
	<cfset var out = "">
	
	<cfif isDate( arguments.since )>
		<cfset arguments.since = this.mcDateFormat( arguments.since )>
	</cfif>
	
	<cfset out= this.apiRequest(
		apiMethod= "listMembers"
	,	id= arguments.list
	,	status= arguments.status
	,	since= arguments.since
	,	start= arguments.start
	,	limit= arguments.limit
	)>
	
	<!--- returns array of members: email, timestamp --->
	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.2/listmemberinfo.func.php --->
<cffunction name="listMemberInfo" access="public" output="false"
	hint="Get all the information for a particular member of a list"
>
	<cfargument name="list" type="string" required="true">
	<cfargument name="email" type="string" required="true">
	
	<cfset var out= this.apiRequest(
		apiMethod= "listMemberInfo"
	,	id= arguments.list
	,	email_address= arguments.email
	)>
	
	<!--- returns array of members: id, email, email_type, merges, status, ip_opt, ip_signup, member_rating, campaign_id, lists, timestamp, info_changed, web_id --->
	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.2/listmemberinfo.func.php --->
<cffunction name="listMemberActivity" access="public" output="false"
	hint="Get the most recent 100 activities for particular list members (open, click, bounce, unsub, abuse, sent to)"
>
	<cfargument name="list" type="string" required="true">
	<cfargument name="email" type="string" required="true">
	
	<cfset var out= this.apiRequest(
		apiMethod= "listMemberActivity"
	,	id= arguments.list
	,	email_address= arguments.email
	)>
	
	<!--- returns array: success, errors, data: action, timestamp, url, bounce_type, campaign_id --->
	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.2/listupdatemember.func.php --->
<cffunction name="listUpdateMember" access="public" output="false"
	hint="Edit the email address, merge fields, and interest groups for a list member."
>
	<cfargument name="list" type="string" required="true">
	<cfargument name="email" type="string" required="true">
	<cfargument name="emailType" type="string" default="">
	<cfargument name="firstName" type="string" default="">
	<cfargument name="lastName" type="string" default="">
	<cfargument name="groups" type="any" default="">
	<cfargument name="ip" type="string" default="">
	<cfargument name="created" type="string" default="">
	<cfargument name="mergeVars" type="struct" default="#{}#">
	<cfargument name="replaceGroups" type="boolean" default="false">
	
	<cfset var out = "">
	<cfset var gid = "">
	<cfset var args = {}>
	
	<cfif len( arguments.firstname )>
		<cfset arguments.mergeVars[ "FNAME" ] = arguments.firstname>
	</cfif>
	<cfif len( arguments.lastname )>
		<cfset arguments.mergeVars[ "LNAME" ] = arguments.lastname>
	</cfif>
	<cfif isSimpleValue( arguments.groups ) AND len( arguments.groups )>
		<cfset arguments.mergeVars[ "GROUPINGS" ] = []>
		<cfloop list="#arguments.groups#" index="gid" delimiters=";">
			<cfif isNumeric( listGetAt( gid, 1, ":" ) )> 
				<cfset arrayAppend( arguments.mergeVars[ "GROUPINGS" ], {
					"id" = listGetAt( gid, 1, ":" ) 
				,	"groups" = replaceNoCase( listGetAt( gid, 2, ":" ), "null", "" )
				} )>
			<cfelse>
				<cfset arrayAppend( arguments.mergeVars[ "GROUPINGS" ], {
					"name" = listGetAt( gid, 1, ":" ) 
				,	"groups" = replaceNoCase( listGetAt( gid, 2, ":" ) , "null", "" )
				} )>
			</cfif>
		</cfloop>
	<cfelseif isArray( arguments.groups )>
		<!--- broken --->
		<!--- <cfset arguments.mergeVars[ "GROUPS" ] = arguumnets.groups> --->
	</cfif>
	<cfif len( arguments.ip )>
		<cfset arguments.mergeVars[ "OPTIN_IP" ] = arguments.ip>
	</cfif>
	<cfif isDate( arguments.created )>
		<cfset arguments.mergeVars[ "OPTIN_TIME" ] = this.mcDateFormat( arguments.created )>
	</cfif>
	
	<cfset this.flattenObject( args, "merge_vars", arguments.mergeVars )> 
	
	<cfset out= this.apiRequest(
		apiMethod= "listUpdateMember"
	,	apiVersion= "1.3"
	,	id= arguments.list
	,	email_address= arguments.email
	,	email_type= arguments.emailType
	,	replace_interests= arguments.replaceGroups
	,	argumentCollection= args
	)><!--- merge_vars --->
	
	<!--- returns boolean --->
	<cfreturn out>
</cffunction>



<!--- ---------------------------------------------------------------------------------------------------------- --->
<!--- CAMPAIGN METHODS --->
<!--- ---------------------------------------------------------------------------------------------------------- --->


<!--- http://www.mailchimp.com/api/1.3/campaigns.func.php --->
<cffunction name="campaigns" access="public" output="false"
	hint="Get the list of campaigns and their details matching the specified filters"
>
	<cfargument name="campaign" type="string" required="false">
	<cfargument name="list" type="string" required="false">
	<cfargument name="folder" type="string" required="false">
	<cfargument name="template" type="string" required="false">
	<cfargument name="status" type="string" required="false" hint="sent, save, paused, schedule, sending">
	<cfargument name="type" type="string" required="false" hint="regular, plaintext, absplit, rss, trans, auto">
	<cfargument name="fromName" type="string" required="false">
	<cfargument name="fromEmail" type="string" required="false">
	<cfargument name="title" type="string" required="false">
	<cfargument name="subject" type="string" required="false">
	<cfargument name="sendStart" type="string" required="false">
	<cfargument name="sendEnd" type="string" required="false">
	<cfargument name="exact" type="boolean" default="false">
	<cfargument name="start" type="numeric" default="0">
	<cfargument name="limit" type="numeric" default="25">
	
	<cfset var out = "">
	<cfset var args = {}>
	
	<cfset arguments.filters = { "exact" = arguments.exact }>
	
	<cfif structKeyExists( arguments, "campaign" )>
		<cfset arguments.filters[ "campaign_id" ] = arguments.campaign>
	</cfif>
	<cfif structKeyExists( arguments, "list" )>
		<cfset arguments.filters[ "list_id" ] = arguments.list>
	</cfif>
	<cfif structKeyExists( arguments, "folder" )>
		<cfset arguments.filters[ "folder_id" ] = arguments.folder>
	</cfif>
	<cfif structKeyExists( arguments, "template" )>
		<cfset arguments.filters[ "template_id" ] = arguments.template>
	</cfif>
	<cfif structKeyExists( arguments, "status" )>
		<cfset arguments.filters[ "status" ] = arguments.status>
	</cfif>
	<cfif structKeyExists( arguments, "type" )>
		<cfset arguments.filters[ "type" ] = arguments.type>
	</cfif>
	<cfif structKeyExists( arguments, "fromName" )>
		<cfset arguments.filters[ "from_name" ] = arguments.fromName>
	</cfif>
	<cfif structKeyExists( arguments, "fromEmail" )>
		<cfset arguments.filters[ "from_email" ] = arguments.fromEmail>
	</cfif>
	<cfif structKeyExists( arguments, "title" )>
		<cfset arguments.filters[ "title" ] = arguments.title>
	</cfif>
	<cfif structKeyExists( arguments, "subject" )>
		<cfset arguments.filters[ "subject" ] = arguments.subject>
	</cfif>
	<cfif structKeyExists( arguments, "sendStart" ) AND isDate( arguments.sendStart )>
		<cfset arguments.filters[ "sendtime_start" ] = this.mcDateFormat( arguments.sendStart )>
	</cfif>
	<cfif structKeyExists( arguments, "sendEnd" ) AND isDate( arguments.sendEnd )>
		<cfset arguments.filters[ "sendtime_end" ] = this.mcDateFormat( arguments.sendEnd )>
	</cfif>
	
	<cfset this.flattenObject( args, "filters", arguments.filters )> 
	
	<cfset out= this.apiRequest(
		apiMethod= "campaigns"
	,	apiVersion= "1.3"
	,	verb="GET"
	,	start= arguments.start
	,	limit= arguments.limit
	,	argumentCollection= args
	)><!--- filters --->
	
	<!--- returns array: id, web_id, list_id, folder_id, title, type, create_time, send_time, emails_sent, status, from_name, from_email --->
	<!--- subject, to_email, archive_url, inline_css, analytics, analytics_tag, authenticate, ecomm360, auto_tweet, timewarp, track_clicks_text --->
	<!--- track_clicks_html, track_options, segment_test, segment_opts --->
	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.3/campaigncreate.func.php --->
<cffunction name="campaignCreate" access="public" output="false"
	hint="Create a new draft campaign to send. You can not have more than 32,000 campaigns in your account."
>
	<cfargument name="type" type="string" required="true" hint="regular, plaintext, absplit, rss, auto">
	<cfargument name="list" type="string" required="true">
	<cfargument name="subject" type="string" required="true">
	<cfargument name="fromEmail" type="string" required="true">
	<cfargument name="fromName" type="string" required="true">
	<cfargument name="toName" type="string" required="true">
	<cfargument name="template" type="string" default="">
	<cfargument name="folder" type="string" default="">
	<cfargument name="tracking" type="struct" default="#{ opens = true, html_clicks = true, text_clicks = true }#">
	<cfargument name="title" type="string" default="#arguments.subject#">
	<cfargument name="authenticate" type="boolean" required="false">
	<cfargument name="analytics" type="string" default="">
	<cfargument name="autoFooter" type="boolean" default="false">
	<cfargument name="inlineCSS" type="boolean" default="false">
	<cfargument name="generateText" type="boolean" default="false">
	<cfargument name="autoTweet" type="boolean" default="false">
	<cfargument name="autoFB" type="boolean" default="false">
	<cfargument name="timeWarp" type="boolean" default="false">
	<cfargument name="ecomm360" type="boolean" default="false">
	<cfargument name="url" type="string" default="">
	<cfargument name="html" type="string" default="">
	<cfargument name="text" type="string" default="">
	<cfargument name="segments" type="struct" default="#{}#">
	
	<cfset var out = "">
	<cfset var args = {}>
	<cfset var opts = {
		"list_id" = arguments.list
	,	"subject" = arguments.subject
	,	"title" = arguments.title
	,	"from_email" = arguments.fromEmail
	,	"from_name" = arguments.fromName
	,	"to_name" = arguments.toName
	,	"tracking" = arguments.tracking
	,	"authenticate" = arguments.authenticate
	,	"auto_footer" = arguments.autoFooter
	,	"inline_css" = arguments.inlineCSS
	,	"generate_text" = arguments.generateText
	,	"auto_tweet" = arguments.autoTweet
	,	"auto_fb_post" = arguments.autoFB
	,	"timewarp" = arguments.timeWarp
	,	"ecomm360" = arguments.ecomm360
	}>
	<cfset var content = {
		"html" = arguments.html
	,	"text" = arguments.text
	,	"url" = arguments.url
	}>
	
	<cfif len( arguments.template )>
		<cfset opts[ "template_id" ] = arguments.template>
	</cfif>
	<cfif len( arguments.folder )>
		<cfset opts[ "folder_id" ] = arguments.folder>
	</cfif>
	<cfif isSimpleValue( arguments.analytics )>
		<cfset opts[ "analytics" ] = { "google" = arguments.analytics }>
	</cfif>
	
	<cfset this.flattenObject( args, "options", opts )>
	<cfset this.flattenObject( args, "content", content )>
	<cfset this.flattenObject( args, "segment_opts", arguments.segments )>

	<cfset out= this.apiRequest(
		apiMethod= "campaignCreate"
	,	apiVersion= "1.3"
	,	verb="POST"
	,	type= arguments.type
	,	argumentCollection= args
	)>
	<!--- returns campaignID --->

	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.2/campaignreplicate.func.php --->
<cffunction name="campaignCopy" access="public" output="false"
	hint="Replicate a campaign"
>
	<cfargument name="campaign" type="string" required="true">
	
	<cfset var out= this.apiRequest(
		apiMethod= "campaignReplicate"
	,	cid= arguments.campaign
	)>
	
	<!--- returns campaignID --->
	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.3/campaigndelete.func.php --->
<cffunction name="campaignDelete" access="public" output="false"
	hint="Delete a campaign. Be careful!"
>
	<cfargument name="campaign" type="string" required="true">
	
	<cfset var out= this.apiRequest(
		apiMethod= "campaignDelete"
	,	apiVersion= "1.3"
	,	cid= arguments.campaign
	)>
	
	<!--- returns boolean --->
	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.2/campaigncontent.func.php --->
<cffunction name="campaignContent" access="public" output="false"
	hint="Get the content (both html and text) for a campaign either as it would appear in the campaign archive or as the raw, original content"
>
	<cfargument name="campaign" type="string" required="true">
	<cfargument name="archive" type="boolean" default="true">
	
	<cfset var out= this.apiRequest(
		apiMethod= "campaignContent"
	,	cid= arguments.campaign
	,	for_archive= arguments.archive
	)>
	
	<!--- returns struct: html & text --->
	<cfreturn out>
</cffunction>


<!--- http://apidocs.mailchimp.com/1.3/campaignmembers.func.php --->
<cffunction name="campaignMembers" access="public" output="false"
	hint="Get all email addresses the campaign was successfully sent to (ie, no bounces)"
>
	<cfargument name="campaign" type="string" required="true">
	<cfargument name="status" type="string" required="true"><!--- sent, hard, soft --->
	<cfargument name="start" type="numeric" default="0">
	<cfargument name="limit" type="numeric" default="1000">
	
	<cfset var out= this.apiRequest(
		apiMethod= "campaignMembers"
	,	apiVersion= "1.3"
	,	verb="GET"
	,	cid= arguments.campaign
	,	status= arguments.status
	,	start= arguments.start
	,	limit= arguments.limit
	)>
	
	<!--- returns array: total, data: email, status, absplit_group, tz_group --->
	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.2/campaigntemplates.func.php --->
<cffunction name="campaignTemplates" access="public" output="false"
	hint="Retrieve all templates defined for your user account"
>	
	<cfset var out= this.apiRequest(
		apiMethod= "campaignTemplates"
	,	cid= arguments.campaign
	)>
	
	<!--- returns array: id, name, layout, preview_image, sections[] --->
	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.2/campaignsharereport.func.php --->
<cffunction name="campaignShareReport" access="public" output="false"
	hint="Get the URL to a customized VIP Report for the specified campaign and optionally send an email to someone with links to it"
>
	<cfargument name="campaign" type="string" required="true">
	<!--- options are not implemented --->
	
	<cfset var out= this.apiRequest(
		apiMethod= "campaignShareReport"
	,	cid= arguments.campaign
	)>
	
	<!--- returns boolean --->
	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.3/campaignabusereports.func.php --->
<cffunction name="campaignAbuseReports" access="public" output="false"
	hint="Get all email addresses that complained about a given campaign"
>
	<cfargument name="campaign" type="string" required="true">
	<cfargument name="start" type="numeric" default="0">
	<cfargument name="limit" type="numeric" default="100">
	<cfargument name="since" type="string" default="">
	
	<cfset var out = "">
	
	<cfif isDate( arguments.since )>
		<cfset arguments.since = this.mcDateFormat( arguments.since )>
	</cfif>
	
	<cfset out= this.apiRequest(
		apiMethod= "campaignAbuseReports"
	,	apiVersion= "1.3"
	,	cid= arguments.campaign
	,	start= arguments.start
	,	limit= arguments.limit
	,	since= arguments.since
	)>
	
	<!--- returns array: date, email, type --->
	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.2/campaignadvice.func.php --->
<cffunction name="campaignAdvice" access="public" output="false"
	hint="Retrieve the text presented in our app for how a campaign performed and any advice we may have for you - best suited for display in customized reports pages. Note: some messages will contain HTML - clean tags as necessary"
>
	<cfargument name="campaign" type="string" required="true">
	
	<cfset var out= this.apiRequest(
		apiMethod= "campaignAdvice"
	,	cid= arguments.campaign
	)>
	
	<!--- returns array: msg, type (negative/positive/neutral) --->
	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.3/campaignbouncemessages.func.php --->
<cffunction name="campaignBounceMessages" access="public" output="false"
	hint="Retrieve the full bounce messages for the given campaign."
>
	<cfargument name="campaign" type="string" required="true">
	<cfargument name="start" type="numeric" default="0">
	<cfargument name="limit" type="numeric" default="25">
	<cfargument name="since" type="string" default="">
	
	<cfset var out = "">
	
	<cfif isDate( arguments.since )>
		<cfset arguments.since = this.mcDateFormat( arguments.since )>
	</cfif>
	
	<cfset var out= this.apiRequest(
		apiMethod= "campaignBounceMessages"
	,	apiVersion= "1.3"
	,	cid= arguments.campaign
	,	start= arguments.start
	,	limit= arguments.limit
	,	since= arguments.since
	)>
	
	<!--- returns array: date, email, message --->
	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.3/campaignhardbounces.func.php --->
<cffunction name="campaignHardBounces" access="public" output="false"
	hint="Get all email addresses with Hard Bounces for a given campaign"
>
	<cfargument name="campaign" type="string" required="true">
	<cfargument name="start" type="numeric" default="0">
	<cfargument name="limit" type="numeric" default="100">
	
	<cfset var out= this.apiRequest(
		apiMethod= "campaignMembers"
	,	apiVersion= "1.3"
	,	cid= arguments.campaign
	,	status= "hard"
	,	start= arguments.start
	,	limit= arguments.limit
	)>
	
	<!--- returns: array of emails --->
	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.3/campaignsoftbounces.func.php --->
<cffunction name="campaignSoftBounces" access="public" output="false"
	hint="Get all email addresses with Soft Bounces for a given campaign"
>
	<cfargument name="campaign" type="string" required="true">
	<cfargument name="start" type="numeric" default="0">
	<cfargument name="limit" type="numeric" default="100">
	
	<cfset var out= this.apiRequest(
		apiMethod= "campaignMembers"
	,	apiVersion= "1.3"
	,	cid= arguments.campaign
	,	status="soft"
	,	start= arguments.start
	,	limit= arguments.limit
	)>
	
	<!--- returns: array of emails --->
	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.2/campaignunsubscribes.func.php --->
<cffunction name="campaignUnsubscribes" access="public" output="false"
	hint="Get all unsubscribed email addresses for a given campaign"
>
	<cfargument name="campaign" type="string" required="true">
	<cfargument name="start" type="numeric" default="0">
	<cfargument name="limit" type="numeric" default="100">
	
	<cfset var out= this.apiRequest(
		apiMethod= "campaignUnsubscribes"
	,	cid= arguments.campaign
	,	start= arguments.start
	,	limit= arguments.limit
	)>
	
	<!--- returns: array of emails --->
	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.2/campaignemaildomainperformance.func.php --->
<cffunction name="campaignEmailDomainPerformance" access="public" output="false"
	hint="Get the top 5 performing email domains for this campaign"
>
	<cfargument name="campaign" type="string" required="true">
	
	<cfset var out= this.apiRequest(
		apiMethod= "campaignEmailDomainPerformance"
	,	cid= arguments.campaign
	)>
	
	<!--- returns array: domain, total_sent, eamils, bounces, opens, clicks, unsubs, delivered, emails_pct, bounces_pct, opens_pct, clicks_pct, unsubs_pct --->
	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.3/campaignsendtest.func.php --->
<cffunction name="campaignSendTest" access="public" output="false"
	hint="Send a test of this campaign to the provided email address"
>
	<cfargument name="campaign" type="string" required="true">
	<cfargument name="emails" type="any" required="true">
	<cfargument name="emailType" type="string" default="both">
	
	<cfset var out = "">
	<cfset var args = {}>
	
	<cfif isSimpleValue( arguments.emails )>
		<cfset arguments.emails = listToArray( arguments.emails, ",; " )>
	</cfif>

	<cfset args[ "cid" ] = arguments.campaign>
	<cfset args[ "send_type" ] = arguments.emailType>
	<cfset this.flattenObject( args, "test_emails", arguments.emails )> 
	
	<cfset out= this.apiRequest(
		apiMethod= "campaignSendTest"
	,	apiVersion= "1.3"
	,	argumentCollection= args
	)>
	
	<!--- returns boolean --->
	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.3/campaignschedule.func.php --->
<cffunction name="campaignSchedule" access="public" output="false"
	hint="Schedule a campaign to be sent in the future"
>
	<cfargument name="campaign" type="string" required="true">
	<cfargument name="date" type="string" required="true">
	<cfargument name="dateB" type="string" default="">
	
	<cfset var out = "">
	
	<cfif isDate( arguments.date )>
		<!---<cfset arguments.date = dateConvert( "Local2UTC", arguments.date )>--->
		<cfset arguments.date = this.mcDateFormat( arguments.date )>
	</cfif>
	<cfif isDate( arguments.dateB )>
		<!---<cfset arguments.dateB = dateConvert( "Local2UTC", arguments.dateB )>--->
		<cfset arguments.dateB = this.mcDateFormat( arguments.dateB )>
	</cfif>
	
	<cfset out= this.apiRequest(
		apiMethod= "campaignSchedule"
	,	apiVersion= "1.3"
	,	cid= arguments.campaign
	,	schedule_time= arguments.date
	,	schedule_time_b= arguments.dateB
	)>
	
	<!--- returns boolean --->
	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.2/campaignunschedule.func.php --->
<cffunction name="campaignUnschedule" access="public" output="false"
	hint="Schedule a campaign to be sent in the future"
>
	<cfargument name="campaign" type="string" required="true">
	
	<cfset var out= this.apiRequest(
		apiMethod= "campaignUnschedule"
	,	cid= arguments.campaign
	)>
	
	<!--- returns boolean --->
	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.2/campaignsendnow.func.php --->
<cffunction name="campaignSendNow" access="public" output="false"
	hint="Send a given campaign immediately. For RSS campaigns, this will 'start' them."
>
	<cfargument name="campaign" type="string" required="true">
	
	<cfset var out= this.apiRequest(
		apiMethod= "campaignSendNow"
	,	cid= arguments.campaign
	)>
	
	<!--- returns boolean --->
	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.2/campaignpause.func.php --->
<cffunction name="campaignPause" access="public" output="false"
	hint="Pause an AutoResponder orRSS campaign from sending"
>
	<cfargument name="campaign" type="string" required="true">
	
	<cfset var out= this.apiRequest(
		apiMethod= "campaignPause"
	,	cid= arguments.campaign
	)>
	
	<!--- returns boolean --->
	<cfreturn out>
</cffunction>


<!--- http://www.mailchimp.com/api/1.2/campaignresume.func.php --->
<cffunction name="campaignResume" access="public" output="false"
	hint="Resume sending an AutoResponder or RSS campaign"
>
	<cfargument name="campaign" type="string" required="true">
	
	<cfset var out= this.apiRequest(
		apiMethod= "campaignResume"
	,	cid= arguments.campaign
	)>
	
	<!--- returns boolean --->
	<cfreturn out>
</cffunction>



<!--- ---------------------------------------------------------------------------------------------------------- --->
<!--- ECOMMERCE METHODS --->
<!--- ---------------------------------------------------------------------------------------------------------- --->



<!--- http://www.mailchimp.com/api/1.3/ecommaddorder.func.php --->
<cffunction name="ecommOrderAdd" access="public" output="false"
	hint="Import Ecommerce Order Information to be used for Segmentatio. This will generall be used by ecommerce package plugins that we provide or by 3rd part system developers."
>
	<cfargument name="email" type="string" required="true">
	<cfargument name="orderID" type="string" required="true">
	<cfargument name="total" type="numeric" required="true">
	<cfargument name="storeID" type="string" required="true">
	<cfargument name="storeName" type="string" default="">
	<cfargument name="campaignID" type="string" default="">
	<cfargument name="shipping" type="numeric" default="0">
	<cfargument name="tax" type="numeric" default="0">
	<cfargument name="date" type="date" default="#now()#">
	<cfargument name="items" type="array" default="#[]#">
	
	<cfset var out = "">
	<cfset var order = {
		id = arguments.orderID
	,	store_id = arguments.storeID
	,	shipping = replace( numberFormat( arguments.shipping, ".00" ), ",", "", "all" )
	,	tax = replace( numberFormat( arguments.tax, ".00" ), ",", "", "all" )
	,	total = replace( numberFormat( arguments.total, ".00" ), ",", "", "all" )
	,	order_date = this.mcDateFormat( arguments.since )
	,	items = []
	}>
	
	<cfif len( arguments.storeName )>
		<cfset order.store_name = arguments.storeName>
	</cfif>
	<cfif len( arguments.campaignID )>
		<cfset order.campaign_id = arguments.campaignID>
	</cfif>
	<cfif find( "@", arguments.email )>
		<cfset order.email = arguments.email>
	<cfelse>
		<cfset order.email_id = arguments.email>
	</cfif>
	
	<cfset var item = 0>
	<cfset var i = 0>
	<cfloop array="#arguments.items#" index="i">
		<cfset item = {
			product_id= i.id
		,	qty= i.qty
		,	cost= i.cost
		}>
		<cfif structKeyExists( i, "sku" ) AND len( i.sku )>
			<cfset item.sku = i.sku>
		</cfif>
		<cfif structKeyExists( i, "lineNum" ) AND len( i.lineNum )>
			<cfset item.line_num = i.lineNum>
		</cfif>
		<cfif structKeyExists( i, "productName" ) AND len( i.productName )>
			<cfset item.product_name = i.productName>
		</cfif>
		<cfif structKeyExists( i, "categoryID" ) AND len( i.categoryID )>
			<cfset item.category_id = i.categoryID>
		</cfif>
		<cfif structKeyExists( i, "categoryName" ) AND len( i.categoryName )>
			<cfset item.category_name = i.categoryName>
		</cfif>
		<cfset arrayAppend( order.items, item )>
	</cfloop>
	
	<cfset out= this.apiRequest(
		apiMethod= "ecommOrderAdd"
	,	apiVersion= "1.3"
	,	order= order
	)>
	
	<!--- returns true or throws an error --->
	<cfreturn out>
</cffunction>



<!--- ---------------------------------------------------------------------------------------------------------- --->
<!--- PRIVATE METHODS --->
<!--- ---------------------------------------------------------------------------------------------------------- --->


<cffunction name="flattenObject" output="false" returnType="struct" access="private">
	<cfargument name="out" type="struct" required="true">
	<cfargument name="prefix" type="string" default="">
	<cfargument name="data" type="any">
	
	<cfset var item = "">
	<cfset var x = 0>
	<cfset var dataKeys = 0>
	<cfset var newKey = "">
	
	<cfif isSimpleValue( arguments.data ) AND len( arguments.data )>
		<cfset arguments.out[ arguments.prefix ] = arguments.data>
	<cfelseif isArray( arguments.data )>
		<cfloop index="x" from="1" to="#arrayLen( arguments.data )#">
			<cfif len( arguments.prefix )>
				<cfset newKey = "#arguments.prefix#[#(x-1)#]">
			<cfelse>
				<cfset newKey = x - 1>
			</cfif>
			<cfif isSimpleValue( arguments.data[ x ] )>
				<cfif len( arguments.data[ x ] )>
					<cfset arguments.out[ newKey ] = arguments.data[ x ]>
				</cfif>
			<cfelse>
				<cfset flattenObject( arguments.out, newKey, arguments.data[ x ] )>
			</cfif>
		</cfloop>
	<cfelseif isStruct( arguments.data )>
		<cfset dataKeys = structKeyArray( arguments.data )>
		<cfset arraySort( dataKeys, "textnocase" )>
		<cfloop index="item" array="#dataKeys#">
			<cfif len( arguments.prefix )>
				<cfset newKey = "#arguments.prefix#[#item#]">
			<cfelse>
				<cfset newKey = item>
			</cfif>
			<cfif isSimpleValue( arguments.data[ item ] )>
				<cfif len( arguments.data[ item ] )>
					<cfset arguments.out[ newKey ] = arguments.data[ item ]>
				</cfif>
			<cfelse>
				<cfset flattenObject( arguments.out, newKey, arguments.data[ item ] )>
			</cfif>
		</cfloop>
	</cfif>
	
	<cfreturn arguments.out>
</cffunction>


<cffunction name="apiRequest" output="false" returnType="struct">
	<cfargument name="apiMethod" type="string" required="true">
	<cfargument name="apiVersion" type="string" default="1.2">
	<cfargument name="verb" type="string" default="POST">
	<cfargument name="output" type="string" default="json">
	
	<cfset var http = {}>
	<cfset var dataKeys = 0>
	<cfset var item = "">
	<cfset var out = {
		args = {
			"method" = arguments.apiMethod
		,	"apikey" = this.apiKey
		}
	,	success = false
	,	error = ""
	,	status = ""
	,	statusCode = 0
	,	response = ""
	,	verb = arguments.verb
	,	requestUrl = replace( this.apiUrl, "<ver>", arguments.apiVersion )
	}>
	
	<!--- copy args over to a new structure with proper names --->
	<cfloop item="item" collection="#arguments#">
		<cfif NOT listFindNoCase( "apiMethod,apiVersion,verb", item )>
			<cfif find( "[", item )>
				<cfset out.args[ item ] = arguments[ item ]>
			<cfelse>
				<cfset out.args[ lCase( item ) ] = arguments[ item ]>
			</cfif>
		</cfif>
	</cfloop>

	<cfif out.verb IS "GET">
		<cfset out.requestUrl &= this.structToQueryString( out.args, true )>
	</cfif>
	
	<cfset this.debugLog( "APIv1: " & arguments.apiMethod )>
	<cfset this.debugLog( out.requestUrl )>

	<cfif request.debug AND request.dump>
		<cfset this.debugLog( out )>
	</cfif>
	
	<cftimer type="debug" label="mailchimp v1 request">
		<cfhttp result="http" method="#out.verb#" url="#out.requestUrl#" charset="UTF-8" timeOut="#this.httpTimeOut#" throwOnError="false">
			<cfif out.verb IS "POST">
				<cfif structKeyExists( out, "body" )>
					<cfhttpparam type="body" value="#out.body#">
				<cfelse>
					<cfloop item="item" collection="#out.args#">
						<cfif listFindNoCase( "method,apikey,output", item )>
							<cfhttpparam name="#item#" type="url" value="#out.args[ item ]#" encoded="false">
						<cfelse>
							<cfhttpparam name="#item#" type="formfield" value="#out.args[ item ]#" encoded="true">
						</cfif>
					</cfloop>
				</cfif>
			</cfif>
		</cfhttp>
	</cftimer>
	
	<!--- <cfset this.debugLog( http )> --->
	
	<cfset out.response = toString( http.fileContent )>
	
	<cfif request.debug AND request.dump>
		<cfset this.debugLog( out.response )>
	</cfif>
	
	<!--- RESPONSE CODE ERRORS --->
	<cfif NOT structKeyExists( http, "responseHeader" ) OR NOT structKeyExists( http.responseHeader, "Status_Code" ) OR http.responseHeader.Status_Code IS "">
		<cfset out.statusCode = 500>
	<cfelse>
		<cfset out.statusCode = http.responseHeader.Status_Code>
	</cfif>
	<cfset this.debugLog( out.statusCode )>
	
	<cfif left( out.statusCode, 1 ) IS 4 OR left( out.statusCode, 1 ) IS 5>
		<cfset out.success = false>
		<cfset out.error = "status code error: #out.statusCode#">
	<cfelseif out.response IS "Connection Timeout" OR out.response IS "Connection Failure">
		<cfset out.error = out.response>
	<cfelseif left( out.statusCode, 1 ) == 2>
		<cfset out.success = true>
	</cfif>
	
	<!--- is response an exception code? --->
	<cfif len( out.response ) LTE 6 AND structKeyExists( variables.exceptions, out.response )>
		<cfset out.success = false>
		<cfset out.error = variables.exceptions[ out.response ]>
	</cfif>
	
	<!--- parse response --->
	<cfif out.success AND arguments.output IS "json">
		<cftry>
			<cfset out.response = deserializeJSON( out.response )>
			<cfif isStruct( out.response ) AND structKeyExists( out.response, "error" )>
				<cfset out.success = false>
				<cfset out.error = out.response.error>
			</cfif> 
			
			<cfcatch>
				<cfset out.error = "JSON Error: " & cfcatch.message>
			</cfcatch>
		</cftry>
	</cfif>
	
	<cfif len( out.error )>
		<cfset out.success = false>
	</cfif>
	
	<cfreturn out>
</cffunction>


<cffunction name="structToQueryString" output="false" returnType="string">
	<cfargument name="stInput" type="struct" required="true">
	<cfargument name="bEncode" type="boolean" default="true">
	<cfargument name="lExclude" type="string" default="">
	<cfargument name="sDelims" type="string" default=",">
	
	<cfset var sOutput = "">
	<cfset var sItem = "">
	<cfset var sValue = "">
	<cfset var amp = "?">
	
	<cfloop item="sItem" collection="#stInput#">
		<cfif ( NOT len( lExclude ) OR NOT listFindNoCase( lExclude, sItem, sDelims ) ) AND NOT isNull( stInput[ sItem ] )>
			<!--- <cftry> --->
				<cfset sValue = stInput[ sItem ]>
				<cfif bEncode>
					<cfset sOutput &= amp & lCase( sItem ) & "=" & urlEncodedFormat( sValue )>
				<cfelse>
					<cfset sOutput &= amp & lCase( sItem ) & "=" & sValue>
				</cfif>
				<cfset amp = "&">
				<!--- <cfcatch></cfcatch>
			</cftry> --->
		</cfif>
	</cfloop>
	
	<cfreturn sOutput>
</cffunction>


</cfcomponent>