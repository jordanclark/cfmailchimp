<cfcomponent extends="oldies.components.mailChimp" displayname="MailChimp" hint="I use the Mail Chimp API" output="false">


<!--- ---------------------------------------------------------------------------------------------------------- --->
<!--- HELPER METHODS --->
<!--- ---------------------------------------------------------------------------------------------------------- --->


<!--- https://apidocs.mailchimp.com/api/2.0/helper/ping.php --->
<cffunction name="ping" access="public" output="false"
	hint="Ping the MailChimp API - a simple method you can call that will return a constant value as long as everything is good"
>
	<cfset var out= this.apiRequest2(
		apiMethod= "helper/ping"
	)>
	<cfif isStruct( out.response ) AND structKeyExists( out.response, "msg" ) AND out.response.msg IS "Everything's Chimpy!">
		<cfset out.response.success = true>
	<cfelse>
		<cfset out.response.success = false>
	</cfif>
	
	<cfreturn out>
</cffunction>


<!--- https://apidocs.mailchimp.com/api/2.0/helper/chimp-chatter.php --->
<cffunction name="chimpChatter" access="public" output="false"
	hint="Return the current Chimp Chatter messages for an account."
>
	<cfset var out= this.apiRequest2(
		apiMethod= "helper/chimp-chatter"
	)>
	
	<!--- returns array: message, type, list_id, campaign_id, update_time --->
	<cfreturn out>
</cffunction>


<!--- https://apidocs.mailchimp.com/api/2.0/helper/account-details.php --->
<cffunction name="accountDetails" access="public" output="false"
	hint="Retrieve lots of account information including payments made, plan info, some account stats, installed modules, contact info, and more. No private information like Credit Card numbers is available."
>
	<cfargument name="exclude" type="string" default="" hint="Valid keys are 'modules', 'orders', 'rewards-credits', 'rewards-inspections', 'rewards-referrals', 'rewards-applied', 'integrations'.">

	<cfset var out= this.apiRequest2(
		apiMethod= "helper/account-details"
	,	exclude= listToArray( arguments.exclude, ',' )
	)>
	
	<!--- returns array: username, user_id, is_trial, timezone, plan_type, plan_low, plan_high, plan_start_date --->
	<!--- emails_left, pending_monthly, first_payment, last_payment, times_logged_in, last_login, affiliate_link --->
	<!--- contact[], modules[], orders[], rewards[] --->
	<cfreturn out>
</cffunction>
<cfset this.getAccountDetails = this.accountDetails>


<!--- https://apidocs.mailchimp.com/api/2.0/helper/generate-text.php --->
<cffunction name="generateText" access="public" output="false"
	hint="Have HTML content auto-converted to a text-only format."
>
	<cfargument name="html" type="string" required="true">
	
	<cfset var out = "">
	<cfset var content = { html = arguments.html }>

	<cfset out= this.apiRequest2(
		apiMethod= "helper/generate-text"
	,	type="html"
	,	content= content
	)>
	
	<cfreturn out>
</cffunction>


<!--- https://apidocs.mailchimp.com/api/2.0/helper/inline-css.php --->
<cffunction name="inlineCss" access="public" output="false"
	hint="Send your HTML content to have the CSS inlined and optionally remove the original styles."
>
	<cfargument name="html" type="string" required="true">
	<cfargument name="stripStyle" type="boolean" default="true">
	
	<cfset var out= this.apiRequest2(
		apiMethod= "helper/inline-css"
	,	html= arguments.html
	,	strip_css= arguments.stripStyle
	)>
	
	<cfreturn out>
</cffunction>


<!--- https://apidocs.mailchimp.com/api/2.0/helper/campaigns-for-email.php --->
<cffunction name="campaignsForEmail" access="public" output="false"
	hint="Retrieve minimal data for all Campaigns a member was sent"
>
	<cfargument name="email" type="string" required="true">
	<cfargument name="emailType" type="string" default="email" hint="email, euid or leid">
	<cfargument name="listID" type="string" default="">
	
	<cfset var out = "">
	<cfset var e = {
		"#arguments.emailType#" = arguments.email
	}>
	<cfset var o = {
		"list_id" = arguments.listID
	}>
	
	<cfset out= this.apiRequest2(
		apiMethod= "helper/campaigns-for-email"
	,	email= e
	,	options= o
	)>
	
	<cfreturn out>
</cffunction>


<!--- https://apidocs.mailchimp.com/api/2.0/helper/lists-for-email.php --->
<cffunction name="listsForEmail" access="public" output="false"
	hint="Retrieve minimal data for all Campaigns a member was sent"
>
	<cfargument name="email" type="string" required="true">
	<cfargument name="emailType" type="string" default="email" hint="email, euid or leid">
	
	<cfset var out = "">
	<cfset var e = {
		"#arguments.emailType#" = arguments.email
	}>
	
	<cfset out= this.apiRequest2(
		apiMethod= "helper/lists-for-email"
	,	email= e
	)>
	
	<cfreturn out>
</cffunction>


<!--- https://apidocs.mailchimp.com/api/2.0/helper/search-campaigns.php --->
<cffunction name="campaignSearch" access="public" output="false"
	hint="Search all campaigns for the specified query terms"
>
	<cfargument name="query" type="string" required="true">
	<cfargument name="offset" type="numeric" default="0">
	<cfargument name="highlight" type="string" default="b">
	
	<cfset var out= this.apiRequest2(
		apiMethod= "helper/search-campaigns"
	,	query= arguments.query
	,	offset= arguments.offset
	,	snip_start= "<#arguments.highlight#>"
	,	snip_end= "</#arguments.highlight#>"
	)>
	
	<cfreturn out>
</cffunction>
<cfset this.searchCampaigns = this.campaignSearch>


<!--- https://apidocs.mailchimp.com/api/2.0/helper/search-members.php --->
<cffunction name="memberSearch" access="public" output="false"
	hint="Search account wide or on a specific list using the specified query terms"
>
	<cfargument name="query" type="string" required="true">
	<cfargument name="listID" type="string" default="">
	<cfargument name="offset" type="numeric" default="0">
	
	<cfset var out= this.apiRequest2(
		apiMethod= "helper/search-members"
	,	query= arguments.query
	,	offset= arguments.offset
	,	id= arguments.listID
	)>
	
	<cfreturn out>
</cffunction>
<cfset this.searchMembers = this.memberSearch>


<!--- https://apidocs.mailchimp.com/api/2.0/helper/verified-domains.php --->
<cffunction name="verifiedDomains" access="public" output="false"
	hint="Retrieve all domain verification records for an account"
>
	<cfset var out= this.apiRequest2(
		apiMethod= "helper/verified-domains"
	)>
	
	<cfreturn out>
</cffunction>



<!--- ---------------------------------------------------------------------------------------------------------- --->
<!--- FOLDER METHODS --->
<!--- ---------------------------------------------------------------------------------------------------------- --->


<!--- https://apidocs.mailchimp.com/api/2.0/folders/add.php --->
<cffunction name="folderAdd" access="public" output="false"
	hint="Add a new folder to file campaigns, autoresponders, or templates in"
>
	<cfargument name="name" type="string" required="true">
	<cfargument name="type" type="string" required="true" hint="campaign, autoresponder, or template">
	
	<cfset var out= this.apiRequest2(
		apiMethod= "folders/add"
	,	name= arguments.name
	,	type= arguments.type
	)>
	
	<!--- returns folder_id --->
	<cfreturn out>
</cffunction>
<cfset this.createFolder = this.folderAdd>


<!--- https://apidocs.mailchimp.com/api/2.0/folders/del.php --->
<cffunction name="folderDel" access="public" output="false"
	hint="Delete a campaign, autoresponder, or template folder. Note that this will simply make whatever was in the folder appear unfiled, no other data is removed"
>
	<cfargument name="folderID" type="string" required="true">
	<cfargument name="type" type="string" required="true" hint="campaign, autoresponder, or template">
	
	<cfset var out= this.apiRequest2(
		apiMethod= "folders/del"
	,	fid= arguments.folderID
	,	type= arguments.type
	)>
	
	<!--- returns boolean --->
	<cfreturn out>
</cffunction>


<!--- https://apidocs.mailchimp.com/api/2.0/folders/update.php --->
<cffunction name="folderUpdate" access="public" output="false"
	hint="Update the name of a folder for campaigns, autoresponders, or templates"
>
	<cfargument name="folderID" type="string" required="true">
	<cfargument name="name" type="string" required="true">
	<cfargument name="type" type="string" required="true" hint="campaign, autoresponder, or template">
	
	<cfset var out= this.apiRequest2(
		apiMethod= "folders/update"
	,	fid= arguments.folderID
	,	name= arguments.name
	,	type= arguments.type
	)>
	
	<!--- returns folder_id --->
	<cfreturn out>
</cffunction>


<!--- https://apidocs.mailchimp.com/api/2.0/folders/list.php --->
<cffunction name="folderList" access="public" output="false"
	hint="List all the folders for a user account."
>
	<cfargument name="type" type="string" required="true" hint="campaign, autoresponder, or template">
	
	<cfset var out= this.apiRequest2(
		apiMethod= "folders/list"
	,	type= arguments.type
	)>
	
	<!--- returns array: folder_id, name, date_created, type --->
	<cfreturn out>
</cffunction>
<cfset this.folders = this.folderList>


<!--- ---------------------------------------------------------------------------------------------------------- --->
<!--- API METHODS --->
<!--- ---------------------------------------------------------------------------------------------------------- --->



<!--- ---------------------------------------------------------------------------------------------------------- --->
<!--- WEBHOOK METHODS --->
<!--- ---------------------------------------------------------------------------------------------------------- --->



<!--- ---------------------------------------------------------------------------------------------------------- --->
<!--- LIST METHODS --->
<!--- ---------------------------------------------------------------------------------------------------------- --->


<!--- https://apidocs.mailchimp.com/api/2.0/lists/abuse-reports.php --->
<cffunction name="listAbuseReports" access="public" output="false"
	hint="Get all email addresses that complained about a given list"
>
	<cfargument name="list" type="string" required="true">
	<cfargument name="start" type="numeric" default="0">
	<cfargument name="limit" type="numeric" default="100">
	<cfargument name="since" type="string" default="">
	
	<cfset var out= this.apiRequest2(
		apiMethod= "lists/abuse-reports"
	,	id= arguments.list
	,	start= arguments.start
	,	limit= arguments.limit
	,	since= this.mcDateFormat( arguments.since )
	)>
	
	<!--- returns array: date, email, campaign_id, type --->
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
	
	<cfset out= this.apiRequest2(
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
	<!--- merge_vars= arguments.mergeVars --->
	
	<!--- returns boolean --->
	<cfreturn out>
</cffunction>


<!--- https://apidocs.mailchimp.com/api/2.0/lists/batch-subscribe.php --->
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
	
	<cfif isSimpleValue( arguments.batch )>
		<cfset b = []>
		<cfloop index="email" list="#arguments.batch#" delimiters=";">
			<cfset this.addToSubscribeBatch( batch= b, email= email, groups= arguments.groups, created= now() )>
		</cfloop>
		<cfset arguments.batch = b>
	</cfif>
	
	<cfset out= this.apiRequest2(
		apiMethod= "lists/batch-subscribe"
	,	id= arguments.list
	,	batch= arguments.batch
	,	double_optin= arguments.sendConfirm
	,	update_existing= arguments.updateExisting
	,	replace_interests= arguments.replaceGroups
	)>
	
	<cfreturn out>
</cffunction>


<cffunction name="addToSubscribeBatch" access="public" output="false">
	<cfargument name="batch" type="array" default="#[]#">
	<cfargument name="email" type="string" required="true">
	<cfargument name="emailType" type="string" default="email" hint="email, euid or leid">
	<cfargument name="msgType" type="string" default="" hint="text or html">
	<cfargument name="firstName" type="string" default="">
	<cfargument name="lastName" type="string" default="">
	<cfargument name="groups" type="any" default="">
	<cfargument name="ip" type="string" default="">
	<cfargument name="created" type="string" default="">
	<cfargument name="mergeVars" type="struct" default="#{}#">
	
	<cfset var item = "">
	<cfset var gid = "">
	<cfset var m = arguments.mergeVars>
	
	<cfset m.email = {
		"#arguments.emailType#" = arguments.email
	}>
	<cfif len( arguments.msgType )>
		<cfset m.email_type = arguments.msgType>
	</cfif>
	
	<cfif len( arguments.firstname )>
		<cfset m.fname = arguments.firstname>
	</cfif>
	<cfif len( arguments.lastname )>
		<cfset m.lname = arguments.lastname>
	</cfif>
	<cfif isSimpleValue( arguments.groups ) AND len( arguments.groups )>
		<cfset m.groupings = []>
		<cfloop list="#arguments.groups#" index="gid" delimiters=";">
			<cfif isNumeric( listGetAt( gid, 1, ":" ) )> 
				<cfset arrayAppend( m.groupings, {
					id = listGetAt( gid, 1, ":" ) 
				,	groups = listToArray( replaceNoCase( listGetAt( gid, 2, ":" ), "null", "" ), "," )
				} )>
			<cfelse>
				<cfset arrayAppend( m.groupings, {
					name = listGetAt( gid, 1, ":" ) 
				,	groups = listToArray( replaceNoCase( listGetAt( gid, 2, ":" ) , "null", "" ), "," )
				} )>
			</cfif>
		</cfloop>
	<cfelseif isArray( arguments.groups )>
		<cfset m.groups = arguments.groups>
	</cfif>
	<cfif len( arguments.ip )>
		<cfset m.optin_ip = arguments.ip>
	</cfif>
	<cfif isDate( arguments.created )>
		<cfset m.optin_time = this.mcDateFormat( arguments.created )>
	</cfif>
	
	<cfset arrayAppend( arguments.batch, m )>
	
	<cfreturn arguments.batch>
</cffunction>



<!--- ---------------------------------------------------------------------------------------------------------- --->
<!--- LIST MERGEVAR METHODS --->
<!--- ---------------------------------------------------------------------------------------------------------- --->


<!--- ---------------------------------------------------------------------------------------------------------- --->
<!--- LIST GROUPINGS METHODS --->
<!--- ---------------------------------------------------------------------------------------------------------- --->


<!--- ---------------------------------------------------------------------------------------------------------- --->
<!--- LIST SEGMENT METHODS --->
<!--- ---------------------------------------------------------------------------------------------------------- --->


<!--- https://apidocs.mailchimp.com/api/2.0/lists/segments.php --->
<cffunction name="listSegments" access="public" output="false">
	<cfargument name="list" type="string" required="true">
	<cfargument name="type" type="string" required="true"><!--- static or saved --->
	
	<cfset var out = "">

	<cfset out= this.apiRequest2(
		apiMethod= "lists/segments"
	,	id= arguments.list
	,	type= arguments.type
	)>
	
	<cfreturn out>
</cffunction>


<!--- ---------------------------------------------------------------------------------------------------------- --->
<!--- MEMBER METHODS --->
<!--- ---------------------------------------------------------------------------------------------------------- --->


<!--- https://apidocs.mailchimp.com/api/2.0/lists/update-member.php --->
<cffunction name="listUpdateMember" access="public" output="false"
	hint="Edit the email address, merge fields, and interest groups for a list member."
>
	<cfargument name="list" type="string" required="true">
	<cfargument name="email" type="string" required="true">
	<cfargument name="emailType" type="string" default="email" hint="email, euid or leid">
	<cfargument name="msgType" type="string" default="" hint="text or html">
	<cfargument name="firstName" type="string" default="">
	<cfargument name="lastName" type="string" default="">
	<cfargument name="groups" type="any" default="">
	<cfargument name="ip" type="string" default="">
	<cfargument name="created" type="string" default="">
	<cfargument name="mergeVars" type="struct" default="#{}#">
	<cfargument name="replaceGroups" type="boolean" default="false">
	
	<cfset var out = "">
	<cfset var gid = "">
	<cfset var m = {}>
	<cfset var e = {
		"#arguments.emailType#" = arguments.email
	}>

	<cfif len( arguments.firstname )>
		<cfset m.fname = arguments.firstname>
	</cfif>
	<cfif len( arguments.lastname )>
		<cfset m.lname = arguments.lastname>
	</cfif>
	<cfif isSimpleValue( arguments.groups ) AND len( arguments.groups )>
		<cfset m.groupings = []>
		<cfloop list="#arguments.groups#" index="gid" delimiters=";">
			<cfif isNumeric( listGetAt( gid, 1, ":" ) )> 
				<cfset arrayAppend( m.groupings, {
					id = listGetAt( gid, 1, ":" ) 
				,	groups = listToArray( replaceNoCase( listGetAt( gid, 2, ":" ), "null", "" ), "," )
				} )>
			<cfelse>
				<cfset arrayAppend( m.groupings, {
					name = listGetAt( gid, 1, ":" ) 
				,	groups = listToArray( replaceNoCase( listGetAt( gid, 2, ":" ) , "null", "" ), "," )
				} )>
			</cfif>
		</cfloop>
	<cfelseif isArray( arguments.groups )>
		<!--- broken --->
		<!--- <cfset m.groups = arguments.groups> --->
	</cfif>
	<cfif len( arguments.ip )>
		<cfset m.optin_ip = arguments.ip>
	</cfif>
	<cfif isDate( arguments.created )>
		<cfset m.optin_time = this.mcDateFormat( arguments.created )>
	</cfif>
	
	<cfset out= this.apiRequest2(
		apiMethod= "lists/update-member"
	,	id= arguments.list
	,	email= e
	,	email_type= arguments.msgType
	,	replace_interests= arguments.replaceGroups
	,	merge_vars= m
	)>
	
	<!--- returns boolean --->
	<cfreturn out>
</cffunction>



<!--- ---------------------------------------------------------------------------------------------------------- --->
<!--- CAMPAIGN METHODS --->
<!--- ---------------------------------------------------------------------------------------------------------- --->


<!--- https://apidocs.mailchimp.com/api/2.0/campaigns/list.php --->
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
	<cfargument name="usesSegments" type="boolean" default="false">
	<cfargument name="start" type="numeric" default="0">
	<cfargument name="limit" type="numeric" default="25">
	<cfargument name="sort" type="string" default="create_time DESC" hint="create_time, send_time, title, subject, ASC or DESC">
	
	<cfset var out = "">
	
	<cfset arguments.filters = {
		"exact" = arguments.exact
	,	"uses_segments" = arguments.usesSegments
	}>
	
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
	
	<cfset out= this.apiRequest2(
		apiMethod= "campaigns/list"
	,	start= arguments.start
	,	limit= arguments.limit
	,	filters= arguments.filters
	,	sort_field= listFirst( arguments.sort, ' ' )
	,	sort_dir= listLast( arguments.sort, ' ' )
	)>
	
	<!--- returns array: id, web_id, list_id, folder_id, title, type, create_time, send_time, emails_sent, status, from_name, from_email --->
	<!--- subject, to_email, archive_url, inline_css, analytics, analytics_tag, authenticate, ecomm360, auto_tweet, timewarp, track_clicks_text --->
	<!--- track_clicks_html, track_options, segment_test, segment_opts --->
	<cfreturn out>
</cffunction>


<!--- https://apidocs.mailchimp.com/api/2.0/campaigns/create.php --->
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
	<cfargument name="tracking" type="string" default="opens,html_clicks,text_clicks">
	<cfargument name="title" type="string" default="#arguments.subject#">
	<cfargument name="authenticate" type="boolean" required="false">
	<cfargument name="analytics" type="string" default="">
	<cfargument name="autoFooter" type="boolean" default="false">
	<cfargument name="inlineCSS" type="boolean" default="false">
	<cfargument name="generateText" type="boolean" default="false">
	<cfargument name="timeWarp" type="boolean" default="false">
	<cfargument name="ecomm360" type="boolean" default="false">
	<cfargument name="url" type="string" default="">
	<cfargument name="html" type="string" default="">
	<cfargument name="text" type="string" default="">
	<cfargument name="segments" type="struct" default="#{}#">
	<cfargument name="options" type="struct" default="#{}#">
	
	<cfset var out = "">
	<cfset var args = {
		type = arguments.type
	,	options = {
			"list_id" = arguments.list
		,	"subject" = arguments.subject
		,	"title" = arguments.title
		,	"from_email" = arguments.fromEmail
		,	"from_name" = arguments.fromName
		,	"to_name" = arguments.toName
		,	"tracking" = {
				"opens" = listFindNoCase( arguments.tracking, "opens" ) ? true : false
			,	"html_clicks" = listFindNoCase( arguments.tracking, "html_clicks" ) ? true : false
			,	"text_clicks" = listFindNoCase( arguments.tracking, "text_clicks" ) ? true : false
			}
		,	"authenticate" = arguments.authenticate
		,	"auto_footer" = arguments.autoFooter
		,	"inline_css" = arguments.inlineCSS
		,	"generate_text" = arguments.generateText
		,	"timewarp" = arguments.timeWarp
		,	"ecomm360" = arguments.ecomm360
		}
	,	content = {
			"html" = arguments.html
		,	"text" = arguments.text
		}
	,	segment_opts = arguments.segments
	,	type_opts = arguments.options
	}>
	
	<cfif isSimpleValue( arguments.analytics )>
		<cfset args.options[ "analytics" ] = {
			"google" = arguments.analytics
		,	"gooal" = arguments.analytics
		}>
	</cfif>
	<cfif len( arguments.url )>
		<cfset args.content[ "url" ] = arguments.url>
	</cfif>

	<cfset out= this.apiRequest2(
		apiMethod= "campaigns/create"
	,	argumentCollection= args
	)>
	<!--- returns campaignID --->

	<cfreturn out>
</cffunction>


<!--- https://apidocs.mailchimp.com/api/2.0/campaigns/content.php --->
<cffunction name="campaignContent" access="public" output="false"
	hint="Get the content (both html and text) for a campaign either as it would appear in the campaign archive or as the raw, original content"
>
	<cfargument name="campaign" type="string" required="true">
	<cfargument name="view" type="string" default="archive" hint="archive, preview or raw">
	<cfargument name="email" type="string" required="true">
	<cfargument name="emailType" type="string" default="email" hint="email, euid or leid">
	
	<cfset var out = "">
	<cfset var options = {
		"view" = arguments.view
	}>
	
	<cfif len( arguments.email )>
		<cfset options["email"] = {
			"#arguments.emailType#" = arguments.email
		}>
	</cfif>

	<cfset out= this.apiRequest2(
		apiMethod= "campaigns/content"
	,	cid= arguments.campaign
	,	options= options
	)>
	
	<!--- returns struct: html & text --->
	<cfreturn out>
</cffunction>


<!--- https://apidocs.mailchimp.com/api/2.0/reports/sent-to.php --->
<cffunction name="campaignSentTo" access="public" output="false"
	hint="Get all email addresses the campaign was successfully sent to (ie, no bounces)"
>
	<cfargument name="campaign" type="string" required="true">
	<cfargument name="status" type="string" required="true"><!--- sent, hard, soft --->
	<cfargument name="start" type="numeric" default="0">
	<cfargument name="limit" type="numeric" default="100">
	
	<cfset var out = "">
	<cfset var o = {
		"status"= arguments.status
	,	"start"= arguments.start
	,	"limit"= arguments.limit
	}>

	<cfset out= this.apiRequest2(
		apiMethod= "reports/sent-to"
	,	cid= arguments.campaign
	,	opts= o
	)>
	
	<!--- returns array: total, data: email, status, absplit_group, tz_group --->
	<cfreturn out>
</cffunction>


<!--- https://apidocs.mailchimp.com/api/2.0/reports/abuse.php --->
<cffunction name="reportsAbuse" access="public" output="false"
	hint="Get all email addresses that complained about a given campaign"
>
	<cfargument name="campaign" type="string" required="true">
	<cfargument name="start" type="numeric" default="0">
	<cfargument name="limit" type="numeric" default="100">
	<cfargument name="since" type="string" default="">
	
	<cfset var out = "">
	<cfset var o = {
		"start"= arguments.start
	,	"limit"= arguments.limit
	,	"since"= this.mcDateFormat( arguments.since )
	}>

	<cfset out= this.apiRequest2(
		apiMethod= "reports/abuse"
	,	cid= arguments.campaign
	,	opts= o
	)>
	
	<!--- returns array: date, email, type --->
	<cfreturn out>
</cffunction>
<cfset this.campaignAbuseReports = this.reportsAbuse>


<!--- ---------------------------------------------------------------------------------------------------------- --->
<!--- ECOMMERCE METHODS --->
<!--- ---------------------------------------------------------------------------------------------------------- --->


<!--- https://apidocs.mailchimp.com/api/2.0/ecomm/order-add.php --->
<cffunction name="ecommOrderAdd" access="public" output="false"
	hint="Import Ecommerce Order Information to be used for Segmentation"
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
		"id" = arguments.orderID
	,	"store_id" = arguments.storeID
	,	"shipping" = replace( numberFormat( arguments.shipping, ".00" ), ",", "", "all" )
	,	"tax" = replace( numberFormat( arguments.tax, ".00" ), ",", "", "all" )
	,	"total" = replace( numberFormat( arguments.total, ".00" ), ",", "", "all" )
	,	"order_date" = this.mcDateFormat( arguments.date )
	,	"items" = arguments.items
	}>
	
	<cfif len( arguments.storeName )>
		<cfset order[ "store_name" ] = arguments.storeName>
	</cfif>
	<cfif len( arguments.campaignID )>
		<cfset order[ "campaign_id" ] = arguments.campaignID>
	</cfif>
	<cfif find( "@", arguments.email )>
		<cfset order[ "email" ] = arguments.email>
	<cfelse>
		<cfset order[ "email_id" ] = arguments.email>
	</cfif>

	<!---
	<cfset var item = 0>
	<cfset var i = 0>
	<cfloop array="#arguments.items#" index="i">
		<cfset item = {
			product_id= i.productID
		}>
		<cfif structKeyExists( i, "lineNum" ) AND len( i.lineNum )>
			<cfset item.line_num = i.lineNum>
		</cfif>
		<cfif structKeyExists( i, "sku" ) AND len( i.sku )>
			<cfset item.sku = i.sku>
		</cfif>
		<cfif structKeyExists( i, "productName" ) AND len( i.productName )>
			<cfset item.product_name = i.productName>
		</cfif>
		<cfset item.category_id = ( structKeyExists( i, "categoryID" ) ? i.categoryID : "" )>
		<cfset item.category_name = ( structKeyExists( i, "categoryName" ) ? i.categoryName : "" )>
		<cfif structKeyExists( i, "qty" ) AND len( i.qty )>
			<cfset item.qty = i.qty>
		</cfif>
		<cfif structKeyExists( i, "cost" ) AND len( i.cost )>
			<cfset item.cost = i.cost>
		</cfif>
		<cfset arrayAppend( order.items, item )>
	</cfloop>
	--->
	
	<cfset out= this.apiRequest2(
		apiMethod= "ecomm/order-add"
	,	order= order
	)>
	<!---
	<cfif isStruct( out.response ) AND structKeyExists( out.response, "complete" ) AND out.response.complete IS "true">
		<cfset out.response.success = true>
	<cfelse>
		<cfset out.response.success = false>
	</cfif>
	--->

	<!--- returns true or throws an error --->
	<cfreturn out>
</cffunction>


<!--- https://apidocs.mailchimp.com/api/2.0/ecomm/order-del.php --->
<cffunction name="ecommOrderDel" access="public" output="false"
	hint="Delete Ecommerce Order Information used for segmentation"
>
	<cfargument name="storeID" type="string" required="true">
	<cfargument name="orderID" type="string" required="true">
	
	<cfset var out = "">

	<cfset out= this.apiRequest2(
		apiMethod= "ecomm/order-del"
	,	store_id= arguments.storeID
	,	order_id= arguments.orderID
	)>
	<cfif isStruct( out.response ) AND structKeyExists( out.response, "complete" ) AND out.response.complete IS "true">
		<cfset out.response.success = true>
		<cfset out.success = true>
	<cfelse>
		<cfset out.response.success = false>
		<cfset out.success = false>
	</cfif>
	
	<!--- returns true or throws an error --->
	<cfreturn out>
</cffunction>


<!--- https://apidocs.mailchimp.com/api/2.0/ecomm/orders.php --->
<cffunction name="ecommOrders" access="public" output="false"
	hint="Delete Ecommerce Order Information used for segmentation"
>
	<cfargument name="campaign" type="string" default="">
	<cfargument name="start" type="numeric" default="0">
	<cfargument name="limit" type="numeric" default="100">
	<cfargument name="since" type="string" default="">
	
	<cfset var out = "">

	<cfset out= this.apiRequest2(
		apiMethod= "ecomm/orders"
	,	cid= arguments.campaign
	,	start= arguments.start
	,	limit= arguments.limit
	,	since= arguments.since
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
				<cfset this.flattenObject( arguments.out, newKey, arguments.data[ x ] )>
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
				<cfset this.flattenObject( arguments.out, newKey, arguments.data[ item ] )>
			</cfif>
		</cfloop>
	</cfif>
	
	<cfreturn arguments.out>
</cffunction>


<cffunction name="apiRequest2" output="false" returnType="struct">
	<cfargument name="apiMethod" type="string" required="true">
	<cfargument name="verb" type="string" default="POST">
	<cfargument name="output" type="string" default="json">
	
	<cfset var http = {}>
	<cfset var dataKeys = 0>
	<cfset var item = "">
	<cfset var out = {
		args = {}
	,	success = false
	,	error = ""
	,	status = ""
	,	statusCode = 0
	,	response = ""
	,	verb = arguments.verb
	,	requestUrl = replace( this.apiUrl, "<ver>", "2.0" )
	,	username = ""
	,	password = ""
	}>

	<cfset out.requestUrl &= arguments.apiMethod & ".json">
	<cfset out.verb = "POST">
	<cfset arguments.verb = "POST">
	<cfset arguments.output = "json">
	<cfset out.args[ "apikey" ] = this.apiKey>

	<!--- copy args over to a new structure with proper names --->
	<cfloop item="item" collection="#arguments#">
		<cfif NOT listFindNoCase( "apiMethod,verb,output,method", item )>
			<cfif findNoCase( "{#item#}", out.requestUrl )>
				<cfset out.requestUrl = replaceNoCase( out.requestUrl, "{#item#}", arguments[ item ], "all" )>
			<cfelseif find( "[", item )>
				<cfset out.args[ item ] = arguments[ item ]>
			<cfelse>
				<cfset out.args[ lCase( item ) ] = arguments[ item ]>
			</cfif>
		</cfif>
	</cfloop>

	<cfif out.verb IS "GET">
		<cfset out.requestUrl &= this.structToQueryString( out.args, true )>
	<cfelseif NOT structIsEmpty( out.args )>
		<cfset out.body = serializeJSON( out.args )>
	</cfif>
	
	<cfset this.debugLog( "APIv2: #uCase( out.verb )#: #out.requestUrl#" )>
	<cfif structKeyExists( out, "body" )>
		<cfset this.debugLog( out.body )>
	</cfif>

	<cfif request.debug AND request.dump>
		<cfset this.debugLog( out )>
	</cfif>
	
	<cftimer type="debug" label="mailchimp v2 request">
		<cfhttp result="http" method="#out.verb#" url="#out.requestUrl#" charset="UTF-8" timeOut="#this.httpTimeOut#" throwOnError="false">
			<cfif out.verb IS "POST" OR out.verb IS "PUT" OR out.verb IS "PATCH">
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
	<cfelseif left( out.statusCode, 1 ) IS 2>
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


</cfcomponent>