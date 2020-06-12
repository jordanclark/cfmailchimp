<cfcomponent  extends="mailChimp2" displayname="MailChimp" hint="I use the Mail Chimp API" output="false">


<cffunction name="init" access="public" output="false">
	<cfargument name="apiKey" type="string" required="true">
	<cfargument name="apiUrl" type="string" required="true" default="https://<dc>.api.mailchimp.com/<ver>/">
	
	<cfset this.ping = this.ping3>
	<cfset this.campaigns = this.campaigns3>
	<cfset this.campaignCreate = this.campaignCreate3>
	<cfset this.campaignCopy = this.campaignCopy3>
	<cfset this.campaignDelete = this.campaignDelete3>
	<cfset this.campaignSendTest = this.campaignSendTest3>
	<cfset this.campaignSchedule = this.campaignSchedule3>
	<cfset this.campaignUnschedule = this.campaignUnschedule3>
	<cfset this.campaignSend = this.campaignSend3>
	<cfset this.campaignPause = this.campaignPause3>
	<cfset this.campaignResume = this.campaignResume3>
	<cfset this.campaignCancelSend = this.campaignCancelSend3>
	<cfset this.campaignSendChecklist = this.campaignSendChecklist3>
	<!--- <cfset this.listAbuseReports = this.listAbuseReports3> --->
	<cfset this.ecommOrderDel = this.ecommOrderDelete3>
	<cfset this.ecommOrderDelete = this.ecommOrderDelete3>
	<cfset this.ecommOrderCancel = this.ecommOrderCancel3>
	<cfset this.ecommOrderShip = this.ecommOrderShip3>
	<cfset this.ecommOrders = this.ecommOrders3>
	<cfset this.ecommOrder = this.ecommOrder3>
	<cfset this.ecommStoreOrders = this.ecommStoreOrders3>
	<!--- <cfset this.ecommOrderAdd = this.ecommOrderAdd3> --->
	<cfset this.ecommStores = this.ecommStores3>
	<cfset this.ecommStore = this.ecommStore3>
	<cfset this.ecommStoreAdd = this.ecommStoreAdd3>
	<cfset this.ecommStoreEdit = this.ecommStoreEdit3>
	<cfset this.ecommStoreDelete = this.ecommStoreDelete3>
	<cfset this.ecommStoreSyncStart = this.ecommStoreSyncStart3>
	<cfset this.ecommStoreSyncEnd = this.ecommStoreSyncEnd3>

	<cfset this.productAdd = this.productAdd3>
	<cfset this.productEdit = this.productEdit3>
	<cfset this.productDelete = this.productDelete3>
	<cfset this.product = this.product3>
	<cfset this.products = this.products3>
	<cfset this.ecommStoreProducts = this.products3>

	<cfset this.customerAdd = this.customerAdd3>
	<cfset this.customerEdit = this.customerEdit3>
	<cfset this.customerDelete = this.customerDelete3>
	<cfset this.customer = this.customer3>
	<cfset this.customers = this.customers3>
	<cfset this.ecommStoreProducts = this.customers3>

	<cfset this.batch = this.batch3>
	<cfset this.batches = this.batches3>
	<cfset this.batchDelete = this.batchDelete3>
	<cfset this.batchesClear = this.batchesClear3>

	<cfreturn super.init( argumentCollection = arguments )>
</cffunction>


<!--- https://developer.mailchimp.com/documentation/mailchimp/reference/ping/ --->
<cffunction name="ping3" access="public" output="false"
	hint="Ping the MailChimp API - a simple method you can call that will return a constant value as long as everything is good"
>
	<cfset var out = this.apiRequest3(
		api= "GET /ping" )>

	<cfif isStruct( out.response ) AND structKeyExists( out.response, "msg" ) AND out.response.msg IS "Everything's Chimpy!">
		<cfset out.response.success = true>
	<cfelse>
		<cfset out.response.success = false>
	</cfif>
	
	<cfreturn out>
</cffunction>


<!--- ---------------------------------------------------------------------------------------------------------- --->
<!--- MEMBER METHODS --->
<!--- ---------------------------------------------------------------------------------------------------------- --->


<!--- https://developer.mailchimp.com/documentation/mailchimp/reference/lists/members/#read-get_lists_list_id_members_subscriber_hasha671e18a0d --->
<cffunction name="listMember3" access="public" output="false"
	hint="Get all the information for a particular member of a list"
>
	<cfargument name="list_id" type="string" required="true">
	<cfargument name="subscriber_hash" type="string" required="true">
	<cfargument name="fields" type="string" required="false">
	<cfargument name="exclude_fields" type="string" required="false">

	<cfset var out = "">

	<cfif find( "@", arguments.subscriber_hash )>
		<cfset arguments.subscriber_hash = this.mcEmailHash( arguments.subscriber_hash )>
	</cfif>
	
	<cfset out = this.apiRequest3(
		api= "GET /lists/{list_id}/members/{subscriber_hash}"
	,	argumentCollection= arguments
	)>

	<cfreturn out>
</cffunction>


<!--- https://developer.mailchimp.com/documentation/mailchimp/reference/lists/members/#read-get_lists_list_id_members_subscriber_hasha671e18a0d --->
<cffunction name="listMembers3" access="public" output="false"
	hint="Get all the information for a particular member of a list"
>
	<cfargument name="list_id" type="string" required="true">
	<cfargument name="fields" type="string" required="false">
	<cfargument name="exclude_fields" type="string" required="false">
	<cfargument name="count" type="numeric" default="10">
	<cfargument name="offset" type="numeric" default="0">
	<cfargument name="email_type" type="string" required="false" hint="regular, plaintext, absplit, rss, variate">
	<cfargument name="status" type="string" required="false" hint="sent, save, paused, schedule, sending">
	<cfargument name="since_timestamp_opt" type="string" required="false" hint="">
	<cfargument name="before_timestamp_opt" type="string" required="false" hint="">
	<cfargument name="since_last_changed" type="string" required="false" hint="">
	<cfargument name="before_last_changed" type="string" required="false" hint="">
	<cfargument name="unique_email_id" type="string" required="false">
	<cfargument name="vip_only" type="string" required="false">
	<cfargument name="interest_category_id" type="string" required="false">
	<cfargument name="interest_ids" type="string" required="false">
	<cfargument name="interest_match" type="string" required="false" hint="any, all, none">
	
	<cfset var out = "">
	
	<cfif structKeyExists( arguments, "since_timestamp_opt" ) AND isDate( arguments.since_timestamp_opt )>
		<cfset arguments[ "since_timestamp_opt" ] = mcDateFormat( arguments.since_timestamp_opt )>
	</cfif>
	<cfif structKeyExists( arguments, "before_timestamp_opt" ) AND isDate( arguments.before_timestamp_opt )>
		<cfset arguments[ "before_timestamp_opt" ] = mcDateFormat( arguments.before_timestamp_opt )>
	</cfif>
	<cfif structKeyExists( arguments, "since_last_changed" ) AND isDate( arguments.since_last_changed )>
		<cfset arguments[ "since_last_changed" ] = mcDateFormat( arguments.since_last_changed )>
	</cfif>
	<cfif structKeyExists( arguments, "before_last_changed" ) AND isDate( arguments.before_last_changed )>
		<cfset arguments[ "before_last_changed" ] = mcDateFormat( arguments.before_last_changed )>
	</cfif>

	<cfset out = this.apiRequest3(
		api= "GET /lists/{list_id}/members"
	,	argumentCollection= arguments
	)>

	<cfreturn out>
</cffunction>


<!--- https://developer.mailchimp.com/documentation/mailchimp/reference/lists/members/ --->
<cffunction name="listMemberCreate3" access="public" output="false"
	hint="Add a member to the list"
>
	<cfargument name="list_id" type="string" required="true">
	<cfargument name="email_address" type="string" required="false">
	<cfargument name="email_type" type="string" required="false" hint="html or text">
	<cfargument name="status" type="string" required="false" hint="subscribed, unsubscribed, cleaned, pending">
	<cfargument name="merge_fields" type="struct" required="false">
	<cfargument name="interests" type="struct" required="false">
	<cfargument name="language" type="string" required="false">
	<cfargument name="vip" type="string" required="false">
	<cfargument name="location" type="struct" required="false" hint="latitude, longitude">
	<cfargument name="ip_signup" type="string" required="false">
	<cfargument name="timestamp_signup" type="string" required="false">
	<cfargument name="ip_opt" type="string" required="false">
	<cfargument name="timestamp_opt" type="string" required="false">
	
	<cfset var out = "">
	
	<cfif structKeyExists( arguments, "timestamp_signup" ) AND isDate( arguments.timestamp_signup )>
		<cfset arguments[ "timestamp_signup" ] = mcDateFormat( arguments.timestamp_signup )>
	</cfif>
	<cfif structKeyExists( arguments, "timestamp_opt" ) AND isDate( arguments.timestamp_opt )>
		<cfset arguments[ "timestamp_opt" ] = mcDateFormat( arguments.timestamp_opt )>
	</cfif>

	<cfset out = this.apiRequest3(
		api= "POST /lists/{list_id}/members"
	,	argumentCollection= arguments
	)>

	<cfreturn out>
</cffunction>


<!--- https://developer.mailchimp.com/documentation/mailchimp/reference/lists/members/#%20 --->
<cffunction name="listMemberUpsert3" access="public" output="false"
	hint="Add or update a member to the list"
>
	<cfargument name="list_id" type="string" required="true">
	<cfargument name="email_address" type="string" required="true">
	<cfargument name="email_type" type="string" required="false" hint="html or text">
	<cfargument name="status" type="string" required="false" hint="subscribed, unsubscribed, cleaned, pending">
	<cfargument name="merge_fields" type="struct" required="false">
	<cfargument name="interests" type="struct" required="false">
	<cfargument name="language" type="string" required="false">
	<cfargument name="vip" type="string" required="false">
	<cfargument name="location" type="struct" required="false" hint="latitude, longitude">
	<cfargument name="ip_signup" type="string" required="false">
	<cfargument name="timestamp_signup" type="string" required="false">
	<cfargument name="ip_opt" type="string" required="false">
	<cfargument name="timestamp_opt" type="string" required="false">
	
	<cfset var out = "">
	
	<cfset arguments.subscriber_hash = this.mcEmailHash( arguments.email_address )>
	<cfif structKeyExists( arguments, "timestamp_signup" ) AND isDate( arguments.timestamp_signup )>
		<cfset arguments[ "timestamp_signup" ] = mcDateFormat( arguments.timestamp_signup )>
	</cfif>
	<cfif structKeyExists( arguments, "timestamp_opt" ) AND isDate( arguments.timestamp_opt )>
		<cfset arguments[ "timestamp_opt" ] = mcDateFormat( arguments.timestamp_opt )>
	</cfif>

	<cfset out = this.apiRequest3(
		api= "PUT /lists/{list_id}/members/{subscriber_hash}"
	,	argumentCollection= arguments
	)>

	<cfreturn out>
</cffunction>


<!--- https://developer.mailchimp.com/documentation/mailchimp/reference/lists/members/ --->
<cffunction name="listMemberUpdate3" access="public" output="false"
	hint="Add or update a member to the list"
>
	<cfargument name="list_id" type="string" required="true">
	<cfargument name="email_address" type="string" required="true">
	<cfargument name="email_type" type="string" required="false" hint="html or text">
	<cfargument name="status" type="string" required="false" hint="subscribed, unsubscribed, cleaned, pending">
	<cfargument name="merge_fields" type="struct" required="false">
	<cfargument name="interests" type="struct" required="false">
	<cfargument name="language" type="string" required="false">
	<cfargument name="vip" type="string" required="false">
	<cfargument name="location" type="struct" required="false" hint="latitude, longitude">
	<cfargument name="ip_signup" type="string" required="false">
	<cfargument name="timestamp_signup" type="string" required="false">
	<cfargument name="ip_opt" type="string" required="false">
	<cfargument name="timestamp_opt" type="string" required="false">
	
	<cfset var out = "">
	
	<cfset arguments.subscriber_hash = this.mcEmailHash( arguments.email_address )>
	<cfif structKeyExists( arguments, "timestamp_signup" ) AND isDate( arguments.timestamp_signup )>
		<cfset arguments[ "timestamp_signup" ] = mcDateFormat( arguments.timestamp_signup )>
	</cfif>
	<cfif structKeyExists( arguments, "timestamp_opt" ) AND isDate( arguments.timestamp_opt )>
		<cfset arguments[ "timestamp_opt" ] = mcDateFormat( arguments.timestamp_opt )>
	</cfif>

	<cfset out = this.apiRequest3(
		api= "PATCH /lists/{list_id}/members/{subscriber_hash}"
	,	argumentCollection= arguments
	)>

	<cfreturn out>
</cffunction>


<cffunction name="listSubscribe3" access="public" output="false"
	hint="Subscribe the provided email to a list"
>
	<cfargument name="list_id" type="string" required="true">
	<cfargument name="email_address" type="string" required="false">
	<cfargument name="email_type" type="string" required="false" hint="html or text">
	<cfargument name="merge_fields" type="struct" required="false">
	<cfargument name="interests" type="struct" required="false">
	<cfargument name="language" type="string" required="false">
	<cfargument name="vip" type="string" required="false">
	<cfargument name="location" type="struct" required="false" hint="latitude, longitude">
	<cfargument name="ip_signup" type="string" required="false">
	<cfargument name="timestamp_signup" type="string" required="false">
	<cfargument name="ip_opt" type="string" required="false">
	<cfargument name="timestamp_opt" type="string" required="false">
	
	<cfreturn this.listMemberCreate3( status= "subscribed", argumentCollection= arguments )>
</cffunction>


<cffunction name="listUnsubscribe3" access="public" output="false"
	hint="Subscribe the provided email to a list"
>
	<cfargument name="list_id" type="string" required="true">
	<cfargument name="email_address" type="string" required="false">
	
	<cfset arguments.subscriber_hash = this.mcEmailHash( arguments.email_address )>
	<cfset arguments.status = "unsubscribed">

	<cfset out = this.apiRequest3(
		api= "PATCH /lists/{list_id}/members/{subscriber_hash}"
	,	argumentCollection= arguments
	)>

	<cfreturn out>
</cffunction>


<!--- ---------------------------------------------------------------------------------------------------------- --->
<!--- LIST SEGMENT METHODS --->
<!--- ---------------------------------------------------------------------------------------------------------- --->


<!--- https://developer.mailchimp.com/documentation/mailchimp/reference/lists/segments/ --->
<cffunction name="listSegments3" access="public" output="false"
	hint="Get all the information for a particular member of a list"
>
	<cfargument name="list_id" type="string" required="true">
	<cfargument name="fields" type="string" required="false">
	<cfargument name="exclude_fields" type="string" required="false">
	<cfargument name="count" type="numeric" default="10">
	<cfargument name="offset" type="numeric" default="0">
	<cfargument name="type" type="string" required="false">
	<cfargument name="status" type="string" required="false">
	<cfargument name="since_created_at" type="string" required="false">
	<cfargument name="before_created_at" type="string" required="false">
	<cfargument name="since_updated_at" type="string" required="false">
	<cfargument name="before_updated_at" type="string" required="false">
	
	<cfset var out = "">
	
	<cfif structKeyExists( arguments, "since_created_at" ) AND isDate( arguments.since_created_at )>
		<cfset arguments[ "since_created_at" ] = mcDateFormat( arguments.since_created_at )>
	</cfif>
	<cfif structKeyExists( arguments, "before_created_at" ) AND isDate( arguments.before_created_at )>
		<cfset arguments[ "before_created_at" ] = mcDateFormat( arguments.before_created_at )>
	</cfif>
	<cfif structKeyExists( arguments, "since_updated_at" ) AND isDate( arguments.since_updated_at )>
		<cfset arguments[ "since_updated_at" ] = mcDateFormat( arguments.since_updated_at )>
	</cfif>
	<cfif structKeyExists( arguments, "before_updated_at" ) AND isDate( arguments.before_updated_at )>
		<cfset arguments[ "before_updated_at" ] = mcDateFormat( arguments.before_updated_at )>
	</cfif>

	<cfset out = this.apiRequest3(
		api= "GET /lists/{list_id}/segments"
	,	argumentCollection= arguments
	)>

	<cfreturn out>
</cffunction>


<!--- https://developer.mailchimp.com/documentation/mailchimp/reference/lists/segments/ --->
<cffunction name="listSegmentCreate3" access="public" output="false"
	hint="Create a list segment"
>
	<cfargument name="list_id" type="string" required="true">
	<cfargument name="name" type="string" required="true">
	<cfargument name="static_segment" type="any" required="false">
	<cfargument name="options" type="object" required="false">

	<cfif isSimpleValue( arguments.static_segment )>
		<cfset arguments.static_segment = listToArray( arguments.static_segment, ";" )>
	</cfif>

	<cfset out = this.apiRequest3(
		api= "POST /lists/{list_id}/segments"
	,	argumentCollection= arguments
	)>

	<cfreturn out>
</cffunction>



<!--- https://developer.mailchimp.com/documentation/mailchimp/reference/lists/segments/members/ --->
<cffunction name="listSegmentMembers3" access="public" output="false"
	hint="Get all the information for a particular member of a list"
>
	<cfargument name="list_id" type="string" required="true">
	<cfargument name="segment_id" type="string" required="true">
	<cfargument name="fields" type="string" required="false">
	<cfargument name="exclude_fields" type="string" required="false">
	<cfargument name="count" type="numeric" default="10">
	<cfargument name="offset" type="numeric" default="0">
	
	<cfset var out = this.apiRequest3(
		api= "GET /lists/{list_id}/segments/{segment_id}/members"
	,	argumentCollection= arguments
	)>

	<cfreturn out>
</cffunction>


<!--- ---------------------------------------------------------------------------------------------------------- --->
<!--- LIST INTEREST METHODS --->
<!--- ---------------------------------------------------------------------------------------------------------- --->


<!--- https://developer.mailchimp.com/documentation/mailchimp/reference/lists/segments/ --->
<cffunction name="listInterestCategories3" access="public" output="false"
	hint="Get all the information for a particular member of a list"
>
	<cfargument name="list_id" type="string" required="true">
	<cfargument name="fields" type="string" required="false">
	<cfargument name="exclude_fields" type="string" required="false">
	<cfargument name="count" type="numeric" default="10">
	<cfargument name="offset" type="numeric" default="0">
	<cfargument name="type" type="string" required="false">
	
	<cfset var out = "">
	
	<cfset out = this.apiRequest3(
		api= "GET /lists/{list_id}/interest-categories"
	,	argumentCollection= arguments
	)>

	<cfreturn out>
</cffunction>


<!--- https://developer.mailchimp.com/documentation/mailchimp/reference/lists/segments/ --->
<cffunction name="listInterestCategoryCreate3" access="public" output="false"
	hint="Create a list segment"
>
	<cfargument name="list_id" type="string" required="true">
	<cfargument name="title" type="string" required="true">
	<cfargument name="display_order" type="numeric" required="true">
	<cfargument name="type" type="string" required="true">

	<cfif isSimpleValue( arguments.static_segment )>
		<cfset arguments.static_segment = listToArray( arguments.static_segment, ";" )>
	</cfif>

	<cfset out = this.apiRequest3(
		api= "POST /lists/{list_id}/interest-categories"
	,	argumentCollection= arguments
	)>

	<cfreturn out>
</cffunction>


<!--- https://developer.mailchimp.com/documentation/mailchimp/reference/lists/interest-categories/interests/ --->
<cffunction name="listInterests3" access="public" output="false"
	hint="Get all the information for a particular member of a list"
>
	<cfargument name="list_id" type="string" required="true">
	<cfargument name="interest_category_id" type="string" required="true">
	<cfargument name="fields" type="string" required="false">
	<cfargument name="exclude_fields" type="string" required="false">
	<cfargument name="count" type="numeric" default="10">
	<cfargument name="offset" type="numeric" default="0">
	
	<cfset var out = "">
	
	<cfset out = this.apiRequest3(
		api= "GET /lists/{list_id}/interest-categories/{interest_category_id}/interests"
	,	argumentCollection= arguments
	)>

	<cfreturn out>
</cffunction>


<!--- https://developer.mailchimp.com/documentation/mailchimp/reference/lists/segments/ --->
<cffunction name="listInterestCreate3" access="public" output="false"
	hint="Create a list segment"
>
	<cfargument name="list_id" type="string" required="true">
	<cfargument name="interest_category_id" type="string" required="true">
	<cfargument name="name" type="string" required="true">
	<cfargument name="display_order" type="string" required="false">

	<cfset out = this.apiRequest3(
		api= "POST /lists/{list_id}/interest-categories/{interest_category_id}/interests"
	,	argumentCollection= arguments
	)>

	<cfreturn out>
</cffunction>


<!--- ---------------------------------------------------------------------------------------------------------- --->
<!--- CAMPAIGN METHODS --->
<!--- ---------------------------------------------------------------------------------------------------------- --->


<!--- https://developer.mailchimp.com/documentation/mailchimp/reference/campaigns/#read-get_campaigns --->
<cffunction name="campaigns3" access="public" output="false"
	hint="Get the list of campaigns and their details matching the specified filters"
>
	<cfargument name="fields" type="string" required="false">
	<cfargument name="exclude_fields" type="string" required="false">
	<cfargument name="count" type="numeric" default="10">
	<cfargument name="offset" type="numeric" default="0">
	<cfargument name="type" type="string" required="false" hint="regular, plaintext, absplit, rss, variate">
	<cfargument name="status" type="string" required="false" hint="sent, save, paused, schedule, sending">
	<cfargument name="before_send_time" type="string" required="false" hint="">
	<cfargument name="since_send_time" type="string" required="false" hint="">
	<cfargument name="before_create_time" type="string" required="false" hint="">
	<cfargument name="since_create_time" type="string" required="false" hint="">
	<cfargument name="list_id" type="string" required="false">
	<cfargument name="folder_id" type="string" required="false">
	<cfargument name="sort_field" type="string" default="send_time" hint="create_time, send_time">
	<cfargument name="sort_dir" type="string" default="DESC" hint="ASC, DESC">

	<cfset var out = "">

	<cfif structKeyExists( arguments, "before_send_time" ) AND isDate( arguments.before_send_time )>
		<cfset arguments[ "before_send_time" ] = mcDateFormat( arguments.before_send_time )>
	</cfif>
	<cfif structKeyExists( arguments, "since_send_time" ) AND isDate( arguments.since_send_time )>
		<cfset arguments[ "since_send_time" ] = mcDateFormat( arguments.since_send_time )>
	</cfif>
	<cfif structKeyExists( arguments, "before_create_time" ) AND isDate( arguments.before_create_time )>
		<cfset arguments[ "before_create_time" ] = mcDateFormat( arguments.before_create_time )>
	</cfif>
	<cfif structKeyExists( arguments, "since_create_time" ) AND isDate( arguments.since_create_time )>
		<cfset arguments[ "since_create_time" ] = mcDateFormat( arguments.since_create_time )>
	</cfif>

	<cfset out = this.apiRequest3(
		api= "GET /campaigns"
	,	argumentCollection= arguments
	)>	

	<cfif NOT structKeyExists( out.response, "campaigns" ) OR NOT isArray( out.response.campaigns )>
		<cfset out.response.campaigns = []>
		<cfset out.success = false>
	</cfif>

	<cfreturn out>
</cffunction>



<cffunction name="campaignCreate3" access="public" output="false"
	hint="Create a new draft campaign to send. You can not have more than 32,000 campaigns in your account."
>
	<cfargument name="type" type="string" required="true" hint="regular, plaintext, absplit, rss, auto">
	<cfargument name="recipients" type="struct" required="true">
	<cfargument name="settings" type="struct" required="true">
	<cfargument name="variate_settings" type="struct" required="false">
	<cfargument name="tracking" type="struct" required="true">
	<cfargument name="rss_opts" type="struct" required="false">
	<cfargument name="social_card" type="struct" required="false">
	<cfargument name="url" type="string" default="">
	<cfargument name="html" type="string" default="">
	<cfargument name="plain_text" type="string" default="">
	
	<cfset var out = "">
	<cfset var out2 = "">

	<cfset var args2 = {
		"url"= arguments.url
	,	"html"= arguments.html
	,	"plain_text"= arguments.plain_text
	}>
	<cfset structDelete( arguments, "url" )>
	<cfset structDelete( arguments, "html" )>
	<cfset structDelete( arguments, "plain_text" )>

	<cfset out = this.apiRequest3(
		api= "POST /campaigns"
	,	argumentCollection= arguments
	)>
	<!--- returns campaignID --->

	<cfif out.success>
		<cfset args2[ "campaign_id" ] = out.response.id>
		<cfset out.content = this.apiRequest3( api= "PUT /campaigns/{campaign_id}/content"
			, argumentCollection= args2 )>
		<cfif NOT out.content.success>
			<cfset out.success = false>
		</cfif>
	</cfif>

	<cfreturn out>
</cffunction>


<!--- http://developer.mailchimp.com/documentation/mailchimp/reference/campaigns/#action-post_campaigns_campaign_id_actions_replicate --->
<cffunction name="campaignCopy3" access="public" output="false"
	hint="Replicate a campaign"
>
	<cfargument name="campaign_id" type="string" required="true">
	
	<cfset var out = "">
	
	<cfset out = this.apiRequest3(
		api= "POST /campaigns/{campaign_id}/actions/replicate"
	,	argumentCollection= arguments
	)>

	<!--- returns out.response.id --->
	<cfreturn out>
</cffunction>


<!--- http://developer.mailchimp.com/documentation/mailchimp/reference/campaigns/# --->
<cffunction name="campaignDelete3" access="public" output="false"
	hint="Delete a campaign. Be careful!"
>
	<cfargument name="campaign_id" type="string" required="true">
	
	<cfset var out = "">
	
	<cfset out = this.apiRequest3(
		api= "DELETE /campaigns/{campaign_id}"
	,	argumentCollection= arguments
	)>

	<!--- returns boolean --->
	<cfreturn out>
</cffunction>


<!--- http://developer.mailchimp.com/documentation/mailchimp/reference/campaigns/# --->
<cffunction name="campaignSendTest3" access="public" output="false"
	hint="Send a test of this campaign to the provided email address"
>
	<cfargument name="campaign_id" type="string" required="true">
	<cfargument name="test_emails" type="any" required="true">
	<cfargument name="send_type" type="string" default="html" hint="html or plain_text">
	
	<cfset var out = "">
	
	<cfif isSimpleValue( arguments.test_emails )>
		<cfset arguments[ "test_emails" ] = listToArray( arguments.test_emails, ",; " )>
	</cfif>

	<cfset out = this.apiRequest3(
		api= "POST /campaigns/{campaign_id}/actions/test"
	,	argumentCollection= arguments
	)>
	
	<!--- returns boolean --->
	<cfreturn out>
</cffunction>


<!--- http://developer.mailchimp.com/documentation/mailchimp/reference/campaigns/# --->
<cffunction name="campaignSchedule3" access="public" output="false"
	hint="Schedule a campaign to be sent in the future"
>
	<cfargument name="campaign_id" type="string" required="true">
	<cfargument name="schedule_time" type="string" required="true">
	<cfargument name="timeWarp" type="boolean" default="false">
	<cfargument name="batch" type="string" default="" hint="{mins}|{count}">
	
	<cfset var out = "">

	<cfset arguments[ "schedule_time" ] = mcDateFormat( arguments.schedule_time )>
	<cfif listLen( arguments.batch, "|" ) IS 2>
		<cfset arguments[ "batch_delivery" ] = {
			"batch_delay" = listGetAt( arguments.batch, "|", 1 )
		,	"batch_count" = listGetAt( arguments.batch, "|", 2 )
		}>
	</cfif>
	
	<cfset out = this.apiRequest3(
		api= "POST /campaigns/{campaign_id}/actions/schedule"
	,	argumentCollection= arguments
	)>
	
	<!--- returns boolean --->
	<cfreturn out>
</cffunction>


<!--- http://developer.mailchimp.com/documentation/mailchimp/reference/campaigns/# --->
<cffunction name="campaignUnschedule3" access="public" output="false"
	hint="Schedule a campaign to be sent in the future"
>
	<cfargument name="campaign_id" type="string" required="true">
	
	<cfset var out = "">
	
	<cfset out = this.apiRequest3(
		api= "POST /campaigns/{campaign_id}/actions/unschedule"
	,	argumentCollection= arguments
	)>
	
	<!--- returns boolean --->
	<cfreturn out>
</cffunction>


<!--- http://developer.mailchimp.com/documentation/mailchimp/reference/campaigns/# --->
<cffunction name="campaignSend3" access="public" output="false"
	hint="Send a given campaign immediately. For RSS campaigns, this will 'start' them."
>
	<cfargument name="campaign_id" type="string" required="true">
	
	<cfset var out = "">
	
	<cfset out = this.apiRequest3(
		api= "POST /campaigns/{campaign_id}/actions/send"
	,	argumentCollection= arguments
	)>

	<!--- returns boolean --->
	<cfreturn out>
</cffunction>


<!--- http://developer.mailchimp.com/documentation/mailchimp/reference/campaigns/# --->
<cffunction name="campaignPause3" access="public" output="false"
	hint="Pause an AutoResponder orRSS campaign from sending"
>
	<cfargument name="campaign_id" type="string" required="true">
	
	<cfset var out = "">
	
	<cfset out = this.apiRequest3(
		api= "POST /campaigns/{campaign_id}/actions/pause"
	,	argumentCollection= arguments
	)>
	
	<!--- returns boolean --->
	<cfreturn out>
</cffunction>


<!--- http://developer.mailchimp.com/documentation/mailchimp/reference/campaigns/# --->
<cffunction name="campaignResume3" access="public" output="false"
	hint="Resume sending an AutoResponder or RSS campaign"
>
	<cfargument name="campaign_id" type="string" required="true">
	
	<cfset var out = "">
	
	<cfset out = this.apiRequest3(
		api= "POST /campaigns/{campaign_id}/actions/resume"
	,	argumentCollection= arguments
	)>
	
	<!--- returns boolean --->
	<cfreturn out>
</cffunction>


<!--- http://developer.mailchimp.com/documentation/mailchimp/reference/campaigns/# --->
<cffunction name="campaignCancelSend3" access="public" output="false"
	hint="Cancel a Regular or Plain-Text Campaign after you send, before all of your recipients receive it. This feature is included with MailChimp Pro."
>
	<cfargument name="campaign_id" type="string" required="true">
	
	<cfset var out = "">
	
	<cfset out = this.apiRequest3(
		api= "POST /campaigns/{campaign_id}/actions/cancel-send"
	,	argumentCollection= arguments
	)>
	
	<!--- returns boolean --->
	<cfreturn out>
</cffunction>


<!--- http://developer.mailchimp.com/documentation/mailchimp/reference/campaigns/send-checklist/ --->
<cffunction name="campaignSendChecklist3" access="public" output="false"
	hint="Review the send checklist for a campaign, and resolve any issues before sending."
>
	<cfargument name="campaign_id" type="string" required="true">
	
	<cfset var out = "">
	
	<cfset out = this.apiRequest3(
		api= "POST /campaigns/{campaign_id}/send-checklist"
	,	argumentCollection= arguments
	)>

	<!--- returns boolean --->
	<cfreturn out>
</cffunction>



<!--- ---------------------------------------------------------------------------------------------------------- --->
<!--- LIST METHODS --->
<!--- ---------------------------------------------------------------------------------------------------------- --->


<!--- http://developer.mailchimp.com/documentation/mailchimp/reference/lists/abuse-reports/#read-get_lists_list_id_abuse_reports --->
<cffunction name="listAbuseReports3" access="public" output="false"
	hint="Get all email addresses that complained about a given list"
>
	<cfargument name="list_id" type="string" required="true">
	<cfargument name="fields" type="string" required="false">
	<cfargument name="exclude_fields" type="string" required="false">
	<cfargument name="count" type="numeric" default="10">
	<cfargument name="offset" type="numeric" default="0">

	<cfset var out = this.apiRequest3(
		api= "GET /lists/{list_id}/abuse-reports"
	,	argumentCollection= arguments
	)>

	<cfreturn out>
</cffunction>


<!--- ---------------------------------------------------------------------------------------------------------- --->
<!--- ECOMMERCE METHODS --->
<!--- ---------------------------------------------------------------------------------------------------------- --->


<!--- http://developer.mailchimp.com/documentation/mailchimp/reference/ecommerce/orders/#create-post_ecommerce_stores_store_id_orders --->
<cffunction name="ecommOrderAdd3" access="public" output="false"
	hint="Import Ecommerce Order Information to be used for Segmentation"
>
	<cfargument name="store_id" type="string" required="true">
	<cfargument name="id" type="string" required="true">
	<cfargument name="customer_id" type="string" required="false">
	<cfargument name="customer" type="struct" required="false">
	<cfargument name="currency_code" type="string" default="USD">
	<cfargument name="order_total" type="numeric" required="true">
	<cfargument name="lines" type="array" required="true">
	<cfargument name="campaign_id" type="string" required="false">
	<cfargument name="landing_site" type="string" required="false">
	<cfargument name="financial_status" type="string" required="false" hint="paid, pending, refunded, cancelled">
	<cfargument name="fulfillment_status" type="string" required="false" hint="shipped">
	<cfargument name="order_url" type="string" required="false">
	<cfargument name="discount_total" type="numeric" required="true">
	<cfargument name="tax_total" type="numeric" required="true">
	<cfargument name="shipping_total" type="numeric" required="true">
	<cfargument name="tracking_code" type="string" required="false">
	<cfargument name="processed_at_foreign" type="string" required="false">
	<cfargument name="cancelled_at_foreign" type="string" required="false">
	<cfargument name="updated_at_foreign" type="string" required="false">
	<cfargument name="shipping_address" type="struct" required="false" hint="name, address1, address2, city, province, province_code, postal_code, country, country_code, longitude, latitude, phone, company">
	<cfargument name="billing_address" type="struct" required="false" hint="name, address1, address2, city, province, province_code, postal_code, country, country_code, longitude, latitude, phone, company">
	<cfargument name="promos" type="array" required="false">
	
	<cfset var out = "">
	
	<cfset arguments[ "order_total" ] = mcDollarFormat( arguments.order_total )>
	
	<cfif structKeyExists( arguments, "customer_id" )>
		<cfset arguments[ "customer" ] = {
			"id" = arguments.customer_id
		}>
		<cfset structDelete( arguments, "customer_id" )>
	</cfif>
	<cfif structKeyExists( arguments, "discount_total" ) AND len( arguments.discount_total )>
		<cfset arguments[ "discount_total" ] = mcDollarFormat( arguments.discount_total )>
	</cfif>
	<cfif structKeyExists( arguments, "tax_total" ) AND len( arguments.tax_total )>
		<cfset arguments[ "tax_total" ] = mcDollarFormat( arguments.tax_total )>
	</cfif>
	<cfif structKeyExists( arguments, "shipping_total" ) AND len( arguments.shipping_total )>
		<cfset arguments[ "shipping_total" ] = mcDollarFormat( arguments.shipping_total )>
	</cfif>
	<cfif structKeyExists( arguments, "processed_at_foreign" ) AND len( arguments.processed_at_foreign )>
		<cfset arguments[ "processed_at_foreign" ] = mcDateFormat( arguments.processed_at_foreign )>
	</cfif>
	<cfif structKeyExists( arguments, "cancelled_at_foreign" ) AND len( arguments.cancelled_at_foreign )>
		<cfset arguments[ "cancelled_at_foreign" ] = mcDateFormat( arguments.cancelled_at_foreign )>
	</cfif>
	<cfif structKeyExists( arguments, "updated_at_foreign" ) AND len( arguments.updated_at_foreign )>
		<cfset arguments[ "updated_at_foreign" ] = mcDateFormat( arguments.updated_at_foreign )>
	</cfif>
	<cfif structKeyExists( arguments, "outreach" )>
		<cfset arguments[ "outreach" ] = { "id" = arguments.outreach }>
	</cfif>

	<cfset out = this.apiRequest3(
		api= "POST /ecommerce/stores/{store_id}/orders"
	,	argumentCollection= arguments
	)>

	<cfreturn out>
</cffunction>


<!--- http://developer.mailchimp.com/documentation/mailchimp/reference/ecommerce/orders/#edit-patch_ecommerce_stores_store_id_orders_order_id --->
<cffunction name="ecommOrderCancel3" access="public" output="false"
	hint=""
>
	<cfargument name="store_id" type="string" required="true">
	<cfargument name="order_id" type="string" required="true">
	
	<cfset var out = "">

	<cfset arguments[ "financial_status" ] = "cancelled">

	<cfset out = this.apiRequest3(
		api= "PATCH /ecommerce/stores/{store_id}/orders/{order_id}"
	,	argumentCollection= arguments
	)>
	
	<cfreturn out>
</cffunction>


<!--- http://developer.mailchimp.com/documentation/mailchimp/reference/ecommerce/orders/#edit-patch_ecommerce_stores_store_id_orders_order_id --->
<cffunction name="ecommOrderShip3" access="public" output="false"
	hint=""
>
	<cfargument name="store_id" type="string" required="true">
	<cfargument name="order_id" type="string" required="true">
	
	<cfset var out = "">

	<cfset arguments[ "fulfillment_status" ] = "shipped">

	<cfset out = this.apiRequest3(
		api= "PATCH /ecommerce/stores/{store_id}/orders/{order_id}"
	,	argumentCollection= arguments
	)>
	
	<cfreturn out>
</cffunction>


<!--- http://developer.mailchimp.com/documentation/mailchimp/reference/ecommerce/orders/#delete-delete_ecommerce_stores_store_id_orders_order_id --->
<cffunction name="ecommOrderDelete3" access="public" output="false"
	hint=""
>
	<cfargument name="store_id" type="string" required="true">
	<cfargument name="order_id" type="string" required="true">
	
	<cfset var out = this.apiRequest3(
		api= "DELETE /ecommerce/stores/{store_id}/orders/{order_id}"
	,	argumentCollection= arguments
	)>
	
	<cfreturn out>
</cffunction>


<!--- http://developer.mailchimp.com/documentation/mailchimp/reference/ecommerce/orders/#read-get_ecommerce_orders --->
<cffunction name="ecommOrders3" access="public" output="false"
	hint=""
>
	<cfargument name="fields" type="string" required="false">
	<cfargument name="exclude_fields" type="string" required="false">
	<cfargument name="count" type="numeric" default="10">
	<cfargument name="offset" type="numeric" default="0">
	<cfargument name="campaign_id" type="string" required="false">
	<cfargument name="outreach_id" type="string" required="false">
	<cfargument name="customer_id" type="string" required="false">
	<cfargument name="has_outreach" type="string" required="false">
	
	<cfset var out = this.apiRequest3(
		api= "GET /ecommerce/orders"
	,	argumentCollection= arguments
	)>
	
	<cfreturn out>
</cffunction>


<!--- http://developer.mailchimp.com/documentation/mailchimp/reference/ecommerce/orders/#read-get_ecommerce_stores_store_id_orders --->
<cffunction name="ecommStoreOrders3" access="public" output="false"
	hint=""
>
	<cfargument name="store_id" type="string" required="true">
	<cfargument name="fields" type="string" required="false">
	<cfargument name="exclude_fields" type="string" required="false">
	<cfargument name="count" type="numeric" default="10">
	<cfargument name="offset" type="numeric" default="0">
	<cfargument name="customer_id" type="string" required="false">
	<cfargument name="has_outreach" type="string" required="false">
	<cfargument name="campaign_id" type="string" required="false">
	<cfargument name="outreach_id" type="string" required="false">
	
	<cfset var out = this.apiRequest3(
		api= "GET /ecommerce/stores/{store_id}/orders"
	,	argumentCollection= arguments
	)>
	
	<cfreturn out>
</cffunction>


<!--- http://developer.mailchimp.com/documentation/mailchimp/reference/ecommerce/orders/#read-get_ecommerce_stores_store_id_orders --->
<cffunction name="ecommOrder3" access="public" output="false"
	hint=""
>
	<cfargument name="store_id" type="string" required="true">
	<cfargument name="order_id" type="string" required="true">
	<cfargument name="fields" type="string" required="false">
	<cfargument name="exclude_fields" type="string" required="false">
	
	<cfset var out = this.apiRequest3(
		api= "GET /ecommerce/stores/{store_id}/orders/{order_id}"
	,	argumentCollection= arguments
	)>
	
	<cfreturn out>
</cffunction>


<!--- ---------------------------------------------------------------------------------------------------------- --->
<!--- ECOMMERCE CUSTOMER METHODS --->
<!--- ---------------------------------------------------------------------------------------------------------- --->


<!--- http://developer.mailchimp.com/documentation/mailchimp/reference/ecommerce/stores/customers/#create-post_ecommerce_stores_store_id_customers --->
<cffunction name="customerAdd3" access="public" output="false"
	hint=""
>
	<cfargument name="store_id" type="string" required="true">
	<cfargument name="customer_id" type="string" required="true">
	<cfargument name="email_address" type="string" required="true">
	<cfargument name="opt_in_status" type="boolean" required="true">
	<cfargument name="company" type="string" required="false">
	<cfargument name="first_name" type="string" required="false">
	<cfargument name="last_name" type="string" required="false">
	<cfargument name="orders_count" type="string" required="false">
	<cfargument name="total_spent" type="string" required="false">
	<cfargument name="address" type="struct" required="false">

	<cfset arguments[ "id" ] = arguments.customer_id>

	<cfset var out = this.apiRequest3(
		api= "POST /ecommerce/stores/{store_id}/customers"
	,	argumentCollection= arguments
	)>
	
	<cfreturn out>
</cffunction>


<!--- http://developer.mailchimp.com/documentation/mailchimp/reference/ecommerce/stores/customers/#edit-put_ecommerce_stores_store_id_customers_customer_id --->
<cffunction name="customerUpsert3" access="public" output="false"
	hint=""
>
	<cfargument name="store_id" type="string" required="true">
	<cfargument name="customer_id" type="string" required="true">
	<cfargument name="email_address" type="string" required="true">
	<cfargument name="opt_in_status" type="boolean" required="true">
	<cfargument name="company" type="string" required="false">
	<cfargument name="first_name" type="string" required="false">
	<cfargument name="last_name" type="string" required="false">
	<cfargument name="orders_count" type="string" required="false">
	<cfargument name="total_spent" type="string" required="false">
	<cfargument name="address" type="struct" required="false">

	<cfset arguments[ "id" ] = arguments.customer_id>

	<cfset var out = this.apiRequest3(
		api= "PUT /ecommerce/stores/{store_id}/customers/{customer_id}"
	,	argumentCollection= arguments
	)>
	
	<cfreturn out>
</cffunction>


<!--- http://developer.mailchimp.com/documentation/mailchimp/reference/ecommerce/stores/customers/#edit-put_ecommerce_stores_store_id_customers_customer_id --->
<cffunction name="customerEdit3" access="public" output="false"
	hint=""
>
	<cfargument name="store_id" type="string" required="true">
	<cfargument name="customer_id" type="string" required="true">
	<cfargument name="opt_in_status" type="boolean" required="true">
	<!--- email_address cant be changed --->
	<cfargument name="company" type="string" required="false">
	<cfargument name="first_name" type="string" required="false">
	<cfargument name="last_name" type="string" required="false">
	<cfargument name="orders_count" type="string" required="false">
	<cfargument name="total_spent" type="string" required="false">
	<cfargument name="address" type="struct" required="false">

	<cfset arguments[ "id" ] = arguments.customer_id>

	<cfset var out = this.apiRequest3(
		api= "PATCH /ecommerce/stores/{store_id}/customers/{customer_id}"
	,	argumentCollection= arguments
	)>
	
	<cfreturn out>
</cffunction>


<!--- http://developer.mailchimp.com/documentation/mailchimp/reference/ecommerce/stores/customers/#delete-delete_ecommerce_stores_store_id_customers_customer_id --->
<cffunction name="customerDelete3" access="public" output="false"
	hint=""
>
	<cfargument name="store_id" type="string" required="true">
	<cfargument name="customer_id" type="string" required="true">
	
	<cfset var out = this.apiRequest3(
		api= "DELETE /ecommerce/stores/{store_id}/customers/{customer_id}"
	,	argumentCollection= arguments
	)>
	
	<cfreturn out>
</cffunction>


<!--- http://developer.mailchimp.com/documentation/mailchimp/reference/ecommerce/stores/customers/#read-get_ecommerce_stores_store_id_customers_customer_id --->
<cffunction name="customer3" access="public" output="false"
	hint=""
>
	<cfargument name="store_id" type="string" required="true">
	<cfargument name="customer_id" type="string" required="true">
	<cfargument name="fields" type="string" required="false">
	<cfargument name="exclude_fields" type="string" required="false">
	
	<cfset var out = this.apiRequest3(
		api= "GET /ecommerce/stores/{store_id}/customers/{customer_id}"
	,	argumentCollection= arguments
	)>
	
	<cfreturn out>
</cffunction>


<!--- http://developer.mailchimp.com/documentation/mailchimp/reference/ecommerce/stores/customers/#read-get_ecommerce_stores_store_id_customers --->
<cffunction name="customers3" access="public" output="false"
	hint=""
>
	<cfargument name="store_id" type="string" required="true">
	<cfargument name="email_address" type="string" required="false">
	<cfargument name="fields" type="string" required="false">
	<cfargument name="exclude_fields" type="string" required="false">
	<cfargument name="count" type="numeric" default="10">
	<cfargument name="offset" type="numeric" default="0">
	
	<cfset var out = this.apiRequest3(
		api= "GET /ecommerce/stores/{store_id}/customers"
	,	argumentCollection= arguments
	)>
	
	<cfreturn out>
</cffunction>


<!--- ---------------------------------------------------------------------------------------------------------- --->
<!--- ECOMMERCE PRODUCT METHODS --->
<!--- ---------------------------------------------------------------------------------------------------------- --->


<!--- http://developer.mailchimp.com/documentation/mailchimp/reference/ecommerce/stores/products/#create-post_ecommerce_stores_store_id_products --->
<cffunction name="productAdd3" access="public" output="false"
	hint=""
>
	<cfargument name="store_id" type="string" required="true">
	<cfargument name="id" type="string" required="true">
	<cfargument name="title" type="string" required="true">
	<cfargument name="variants" type="array" required="true">
	<cfargument name="handle" type="string" required="false">
	<cfargument name="url" type="string" required="false">
	<cfargument name="description" type="string" required="false">
	<cfargument name="type" type="string" required="false">
	<cfargument name="vendor" type="string" required="false">
	<cfargument name="image_url" type="string" required="false">
	<cfargument name="images" type="array" required="false">
	<cfargument name="published_at_foreign" type="string" required="false">

	<cfset var out = this.apiRequest3(
		api= "POST /ecommerce/stores/{store_id}/products"
	,	argumentCollection= arguments
	)>
	
	<cfreturn out>
</cffunction>


<!--- http://developer.mailchimp.com/documentation/mailchimp/reference/ecommerce/stores/products/#edit-patch_ecommerce_stores_store_id_products_product_id --->
<cffunction name="productEdit3" access="public" output="false"
	hint=""
>
	<cfargument name="store_id" type="string" required="true">
	<cfargument name="product_id" type="string" required="true">
	<cfargument name="title" type="string" required="true">
	<cfargument name="handle" type="string" required="false">
	<cfargument name="url" type="string" required="false">
	<cfargument name="description" type="string" required="false">
	<cfargument name="type" type="string" required="false">
	<cfargument name="vendor" type="string" required="false">
	<cfargument name="image_url" type="string" required="false">
	<cfargument name="variants" type="array" required="true">
	<cfargument name="images" type="array" required="false">
	<cfargument name="published_at_foreign" type="string" required="false">

	<cfset var out = this.apiRequest3(
		api= "PATCH /ecommerce/stores/{store_id}/products/{product_id}"
	,	argumentCollection= arguments
	)>
	
	<cfreturn out>
</cffunction>


<!--- http://developer.mailchimp.com/documentation/mailchimp/reference/ecommerce/stores/products/#delete-delete_ecommerce_stores_store_id_products_product_id --->
<cffunction name="productDelete3" access="public" output="false"
	hint=""
>
	<cfargument name="store_id" type="string" required="true">
	<cfargument name="product_id" type="string" required="true">
	
	<cfset var out = this.apiRequest3(
		api= "DELETE /ecommerce/stores/{store_id}/products/{product_id}"
	,	argumentCollection= arguments
	)>
	
	<cfreturn out>
</cffunction>


<!--- http://developer.mailchimp.com/documentation/mailchimp/reference/ecommerce/stores/products/#read-get_ecommerce_stores_store_id_products --->
<cffunction name="product3" access="public" output="false"
	hint=""
>
	<cfargument name="store_id" type="string" required="true">
	<cfargument name="product_id" type="string" required="true">
	<cfargument name="fields" type="string" required="false">
	<cfargument name="exclude_fields" type="string" required="false">
	
	<cfset var out = this.apiRequest3(
		api= "GET /ecommerce/stores/{store_id}/products/{product_id}"
	,	argumentCollection= arguments
	)>
	
	<cfreturn out>
</cffunction>


<!--- http://developer.mailchimp.com/documentation/mailchimp/reference/ecommerce/stores/products/#read-get_ecommerce_stores_store_id_products --->
<cffunction name="products3" access="public" output="false"
	hint=""
>
	<cfargument name="store_id" type="string" required="true">
	<cfargument name="fields" type="string" required="false">
	<cfargument name="exclude_fields" type="string" required="false">
	<cfargument name="count" type="numeric" default="10">
	<cfargument name="offset" type="numeric" default="0">
	
	<cfset var out = this.apiRequest3(
		api= "GET /ecommerce/stores/{store_id}/products"
	,	argumentCollection= arguments
	)>
	
	<cfreturn out>
</cffunction>


<!--- ---------------------------------------------------------------------------------------------------------- --->
<!--- ECOMMERCE STORE METHODS --->
<!--- ---------------------------------------------------------------------------------------------------------- --->


<!--- http://developer.mailchimp.com/documentation/mailchimp/reference/ecommerce/stores/#read-get_ecommerce_stores --->
<cffunction name="ecommStores3" access="public" output="false"
	hint=""
>
	<cfargument name="fields" type="string" required="false">
	<cfargument name="exclude_fields" type="string" required="false">
	<cfargument name="count" type="numeric" default="10">
	<cfargument name="offset" type="numeric" default="0">
	
	<cfset var out = this.apiRequest3(
		api= "GET /ecommerce/stores"
	,	argumentCollection= arguments
	)>
	
	<cfreturn out>
</cffunction>


<!--- http://developer.mailchimp.com/documentation/mailchimp/reference/ecommerce/stores/#read-get_ecommerce_stores --->
<cffunction name="ecommStore3" access="public" output="false"
	hint=""
>
	<cfargument name="store_id" type="string" required="true">
	<cfargument name="fields" type="string" required="false">
	<cfargument name="exclude_fields" type="string" required="false">
	<cfargument name="count" type="numeric" default="10">
	<cfargument name="offset" type="numeric" default="0">
	
	<cfset var out = this.apiRequest3(
		api= "GET /ecommerce/stores/{store_id}"
	,	argumentCollection= arguments
	)>
	
	<cfreturn out>
</cffunction>


<!--- http://developer.mailchimp.com/documentation/mailchimp/reference/ecommerce/stores/#read-get_ecommerce_stores --->
<cffunction name="ecommStoreAdd3" access="public" output="false"
	hint=""
>
	<cfargument name="id" type="string" required="true">
	<cfargument name="list_id" type="string" required="true">
	<cfargument name="name" type="string" required="true">
	<cfargument name="platform" type="string" required="false">
	<cfargument name="domain" type="string" required="false">
	<cfargument name="is_syncing" type="boolean" default="false">
	<cfargument name="email_address" type="string" required="false">
	<cfargument name="currency_code" type="string" default="USD" required="true">
	<cfargument name="money_format" type="string" default="$">
	<cfargument name="primary_locale" type="string" default="en">
	<cfargument name="timezone" type="string" required="false">
	<cfargument name="phone" type="string" required="false">
	<cfargument name="address" type="struct" required="false" hint="address1, address2, city, province, province_code, postal_code, country, country_code, longitude, latitude">
	
	<cfset var out = this.apiRequest3(
		api= "POST /ecommerce/stores"
	,	argumentCollection= arguments
	)>
	
	<cfreturn out>
</cffunction>


<!--- http://developer.mailchimp.com/documentation/mailchimp/reference/ecommerce/stores/#read-get_ecommerce_stores --->
<cffunction name="ecommStoreEdit3" access="public" output="false"
	hint=""
>
	<cfargument name="store_id" type="string" required="true">
	<cfargument name="name" type="string" required="true">
	<cfargument name="platform" type="string" required="false">
	<cfargument name="domain" type="string" required="false">
	<cfargument name="is_syncing" type="boolean" required="false">
	<cfargument name="email_address" type="string" required="false">
	<cfargument name="currency_code" type="string" default="USD" required="true">
	<cfargument name="money_format" type="string" default="$">
	<cfargument name="primary_locale" type="string" default="en">
	<cfargument name="timezone" type="string" required="false">
	<cfargument name="phone" type="string" required="false">
	<cfargument name="address" type="struct" required="false" hint="address1, address2, city, province, province_code, postal_code, country, country_code, longitude, latitude">
	
	<cfset var out = this.apiRequest3(
		api= "PATCH /ecommerce/stores/{store_id}"
	,	argumentCollection= arguments
	)>
	
	<cfreturn out>
</cffunction>


<!--- http://developer.mailchimp.com/documentation/mailchimp/reference/ecommerce/stores/#delete-delete_ecommerce_stores_store_id --->
<cffunction name="ecommStoreDelete3" access="public" output="false"
	hint=""
>
	<cfargument name="store_id" type="string" required="true">
	
	<cfset var out = this.apiRequest3(
		api= "DELETE /ecommerce/stores/{store_id}"
	,	argumentCollection= arguments
	)>
	
	<cfreturn out>
</cffunction>


<!--- http://developer.mailchimp.com/documentation/mailchimp/reference/ecommerce/stores/#edit-patch_ecommerce_stores_store_id --->
<cffunction name="ecommStoreSyncStart3" access="public" output="false"
	hint=""
>
	<cfargument name="store_id" type="string" required="true">
	
	<cfset var out = "">

	<cfset arguments.is_syncing = true>

	<cfset out = this.apiRequest3(
		api= "PATCH /ecommerce/stores/{store_id}"
	,	argumentCollection= arguments
	)>
	
	<cfreturn out>
</cffunction>


<!--- http://developer.mailchimp.com/documentation/mailchimp/reference/ecommerce/stores/#edit-patch_ecommerce_stores_store_id --->
<cffunction name="ecommStoreSyncEnd3" access="public" output="false"
	hint=""
>
	<cfargument name="store_id" type="string" required="true">
	
	<cfset var out = "">

	<cfset arguments.is_syncing = false>

	<cfset out = this.apiRequest3(
		api= "PATCH /ecommerce/stores/{store_id}"
	,	argumentCollection= arguments
	)>
	
	<cfreturn out>
</cffunction>


<!--- http://developer.mailchimp.com/documentation/mailchimp/reference/batches/#read-get_batches --->
<cffunction name="batches3" access="public" output="false">
	<cfargument name="fields" type="string" required="false">
	<cfargument name="exclude_fields" type="string" required="false">
	<cfargument name="count" type="numeric" default="10">
	<cfargument name="offset" type="numeric" default="0">
	
	<cfset var out = this.apiRequest3(
		api= "GET /batches"
	,	argumentCollection= arguments
	)>
	
	<cfreturn out>
</cffunction>


<!--- http://developer.mailchimp.com/documentation/mailchimp/reference/batches/#read-get_batches --->
<cffunction name="batchesClear3" access="public" output="false">
	<cfargument name="count" type="numeric" default="10">
	<cfargument name="error_limit" type="numeric" default="0">
	
	<cfset var out = this.batches3( count= arguments.count )>
	<cfset out.deletes = []>
	<cfset out.total_operations = 0>
	<cfset out.finished_operations = 0>
	<cfset out.errored_operations = 0>
	<cfset out.pending_batches = 0>

	<cfif out.success AND arrayLen( out.response.batches )>
		<cfset var b = 0>
		<cfset var d = 0>
		<cfloop array="#out.response.batches#" index="b">
			<cfif b.status IS NOT "finished">
				<cfset out.pending_batches += 1>
			</cfif>
			<cfset out.total_operations += val( b.total_operations )>
			<cfset out.finished_operations += val( b.finished_operations )>
			<cfset out.errored_operations += val( b.errored_operations )>
			<cfif b.status IS "finished" AND b.errored_operations LTE arguments.error_limit>
				<cfset d = this.batchDelete3( b.id )>
				<cfset arrayAppend( out.deletes, d )>
			</cfif>
		</cfloop>
	</cfif>
	
	<cfreturn out>
</cffunction>


<!--- http://developer.mailchimp.com/documentation/mailchimp/reference/batches/#read-get_batches_batch_id --->
<cffunction name="batch3" access="public" output="false">
	<cfargument name="batch_id" type="string" required="true">
	<cfargument name="download" type="boolean" default="false">
	
	<cfset var out = this.apiRequest3(
		api= "GET /batches/{batch_id}"
	,	batch_id= arguments.batch_id
	)>

	<cfif arguments.download AND out.success AND structKeyExists( out.response, "response_body_url" ) AND len( out.response.response_body_url )>
		<cfhttp result="out.download" method="GET" url="out.response.response_body_url" charset="UTF-8" getAsBinary="true" timeOut="#this.httpTimeOut#" throwOnError="false"></cfhttp>
	</cfif>
	
	<cfreturn out>
</cffunction>



<!--- http://developer.mailchimp.com/documentation/mailchimp/reference/batches/#delete-delete_batches_batch_id --->
<cffunction name="batchDelete3" access="public" output="false">
	<cfargument name="batch_id" type="string" required="true">
	
	<cfset var out = this.apiRequest3(
		api= "DELETE /batches/{batch_id}"
	,	argumentCollection= arguments
	)>
	
	<cfreturn out>
</cffunction>



<cffunction name="apiRequest3" output="false" returnType="struct">
	<cfargument name="api" type="string" required="true">
	
	<cfset var http = {}>
	<cfset var item = "">
	<cfset var out = {
		args = arguments
	,	success = false
	,	error = ""
	,	status = ""
	,	statusCode = 0
	,	response = ""
	,	verb = listFirst( arguments.api, " " )
	,	requestUrl = replace( this.apiUrl, "<ver>", "3.0" )
	,	username = ""
	,	password = ""
	}>
	
	<cfset out.requestUrl &= replace( listRest( out.args.api, " " ), "/", "", "one" )>
	<cfset structDelete( out.args, "api" )>

	<!--- replace {var} in url --->
	<cfloop item="item" collection="#out.args#">
		<!--- strip NULL values --->
		<cfif isNull( out.args[ item ] )>
			<cfset structDelete( out.args, item )>
		<cfelseif findNoCase( "{#item#}", out.requestUrl )>
			<cfset out.requestUrl = replaceNoCase( out.requestUrl, "{#item#}", out.args[ item ], "all" )>
			<cfset structDelete( out.args, item )>
		</cfif>
	</cfloop>

	<cfif out.verb IS "GET">
		<cfset out.requestUrl &= this.structToQueryString( out.args, true )>
	<cfelseif NOT structIsEmpty( out.args )>
		<cfset out.body = serializeJSON( out.args, false, false )>
	</cfif>
	
	<cfset this.debugLog( "APIv3: #uCase( out.verb )#: #out.requestUrl#" )>
	<cfif structKeyExists( out, "body" )>
		<cfset this.debugLog( out.body )>
	</cfif>

	<cfif request.debug AND request.dump>
		<cfset this.debugLog( out )>
	</cfif>

	<cftimer type="debug" label="mailchimp v3 request">
		<cfhttp result="http" method="#out.verb#" url="#out.requestUrl#" charset="UTF-8" timeOut="#this.httpTimeOut#" throwOnError="false">
			<cfhttpparam type="header" name="Authorization" value="Basic #ToBase64('freddie:#this.apiKey#')#">
			<cfif out.verb IS "POST" OR out.verb IS "PUT" OR out.verb IS "PATCH">
				<cfhttpparam type="header" name="content-type" value="application/json">
			</cfif>
			<cfif structKeyExists( out, "body" )>
				<cfhttpparam type="body" value="#out.body#">
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
	
	<!--- parse response --->
	<cftry>
		<cfset out.response = deserializeJSON( out.response )>
		<cfif isStruct( out.response ) AND structKeyExists( out.response, "error" )>
			<cfset out.success = false>
			<cfset out.error = out.response.error>
		<cfelseif isStruct( out.response ) AND structKeyExists( out.response, "status" ) AND out.response.status IS 400>
			<cfset out.success = false>
			<cfset out.error = out.response.detail>
		</cfif>
		<cfcatch>
			<cfset out.error= "JSON Error: " & (cfcatch.message?:"No catch message") & " " & (cfcatch.detail?:"No catch detail")>
		</cfcatch>
	</cftry>
	
	<cfif len( out.error )>
		<cfset out.success = false>
	</cfif>
	
	<cfreturn out>
</cffunction>


<cffunction name="apiAddBatchRequest3" output="false" returnType="array">
	<cfargument name="batch" type="array" required="true">
	<cfargument name="api" type="string" required="true">
	<cfargument name="operation_id" type="string" required="false">

	<cfset var item = "">
	<cfset var b = arguments.batch>
	<cfset var out = {
		"method" = listFirst( arguments.api, " " )
	,	"path" = listRest( arguments.api, " " )
	,	"params" = {}
	}>

	<cfif structKeyExists( arguments, "operation_id" ) AND NOT isNull( arguments.operation_id )>
		<cfset out[ "operation_id" ] = arguments.operation_id>
	</cfif>

	<cfset structDelete( arguments, "batch" )>
	<cfset structDelete( arguments, "api" )>
	<cfset structDelete( arguments, "operation_id" )>

	<!--- replace {var} in url, strip nulls and build params object --->
	<cfloop item="item" collection="#arguments#">
		<cfif isNull( arguments[ item ] )>
			<cfset structDelete( arguments, item )>
		<cfelseif findNoCase( "{#item#}", out.path )>
			<cfset out.path = replaceNoCase( out.path, "{#item#}", arguments[ item ], "all" )>
			<cfset structDelete( arguments, item )>
		<cfelseif out.method IS "GET">
			<cfset out.params[ lCase( item ) ] = arguments[ item ]>
		</cfif>
	</cfloop>

	<cfset this.debugLog( "APIv3 Add Batch: #uCase( out.method )#: #out.path#" )>
	
	<cfif out.method IS NOT "GET">
		<cfset out[ "body" ] = serializeJSON( arguments, false, false )>
		<cfset this.debugLog( out.body )>
	</cfif>
	
	<cfif request.debug AND request.dump>
		<cfset this.debugLog( out )>
	</cfif>

	<cfset arrayAppend( b, out )>

	<cfreturn b>
</cffunction>

	
<cffunction name="apiBatchRequest3" output="false" returnType="struct">
	<cfargument name="batch" type="array" required="true">
	
	<cfset var http = {}>
	<cfset var item = "">
	<cfset var out = {
		batch = arguments.batch
	,	success = false
	,	error = ""
	,	status = ""
	,	statusCode = 0
	,	response = ""
	,	verb = "POST"
	,	requestUrl = replace( this.apiUrl, "<ver>", "3.0" )
	,	username = ""
	,	password = ""
	}>
	
	<cfset out.requestUrl &= "batches">

	<cfset out.body = serializeJSON( { "operations"= out.batch }, false, false )>
	
	<cfset this.debugLog( "APIv3: BATCH POST: #out.requestUrl#" )>
	<cfif request.debug AND request.dump>
		<cfset this.debugLog( out )>
	</cfif>

	<cftimer type="debug" label="mailchimp v3 batch request">
		<cfhttp result="http" method="POST" url="#out.requestUrl#" charset="UTF-8" timeOut="#this.httpTimeOut#" throwOnError="false">
			<cfhttpparam type="header" name="Authorization" value="Basic #ToBase64('freddie:#this.apiKey#')#">
			<cfhttpparam type="header" name="content-type" value="application/json">
			<cfhttpparam type="body" value="#out.body#">
		</cfhttp>
	</cftimer>
	
	<!--- <cfset this.debugLog( http )> --->
	
	<cfset out.response = toString( http.fileContent )>
	
	<cfif request.debug>
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
	
	<!--- parse response --->
	<cftry>
		<cfset out.response = deserializeJSON( out.response )>
		<cfif isStruct( out.response ) AND structKeyExists( out.response, "error" )>
			<cfset out.success = false>
			<cfset out.error = out.response.error>
		<cfelseif isStruct( out.response ) AND structKeyExists( out.response, "status" ) AND out.response.status IS 400>
			<cfset out.success = false>
			<cfset out.error = out.response.detail>
		</cfif>
		<cfcatch>
			<cfset out.error= "JSON Error: " & (cfcatch.message?:"No catch message") & " " & (cfcatch.detail?:"No catch detail")>
		</cfcatch>
	</cftry>
	
	<cfif len( out.error )>
		<cfset out.success = false>
	</cfif>
	
	<cfreturn out>
</cffunction>


<cffunction name="mcEmailHash" access="public" output="false" returnType="string">
	<cfargument name="email" type="string" required="true">

	<cfreturn lCase( hash( lCase( trim( arguments.email ) ), "md5", "utf-8" ) )>
</cffunction>


<cffunction name="mcInterests" access="public" output="false" returnType="struct">
	<cfargument name="allInterests" type="array" required="true">
	<cfargument name="memberInterests" type="array" required="true">
	
	<cfset var i = 0>
	<cfset var out = {}>
	<cfloop array="#arguments.allInterests#" index="i">
		<cfset out[ i ] = ( arrayContains( arguments.memberInterests, i ) ? true : false )>
	</cfloop>

	<cfreturn out>
</cffunction>


<!--- <cffunction name="ungzip"
	hint="decompresses a binary|(base64|hex|uu) using the gzip algorithm; returns string"
	output="no">
	<!---
		Acknowledgements:
		Christian Cantrell, byte array for CF
			- http://weblogs.macromedia.com/cantrell/archives/2004/01/byte_arrays_and_1.cfm
	--->
	<cfscript>
		var bufferSize=8192;
		var byteArray = createObject("java","java.lang.reflect.Array").newInstance(createObject("java","java.lang.Byte").TYPE,bufferSize);
		var decompressOutputStream=createObject("java","java.io.ByteArrayOutputStream").init();
		var input=0;
		var decompressInputStream=0;
		var l=0;
		if(not isBinary(arguments[1]) and arrayLen(arguments) is 1) return;
		if(arrayLen(arguments) gt 1){
			input=binaryDecode(arguments[1],arguments[2]);
		}else{
			input=arguments[1];
		}
		decompressInputStream=createObject("java","java.util.zip.GZIPInputStream").init(createObject("java","java.io.ByteArrayInputStream").init(input));
		l=decompressInputStream.read(byteArray,0,bufferSize);

		while (l gt -1){
			decompressOutputStream.write(byteArray,0,l);
			l=decompressInputStream.read(byteArray,0,bufferSize);
		}
		decompressInputStream.close();
		decompressOutputStream.close();

		return decompressOutputStream.toString();
	</cfscript>
</cffunction> --->


</cfcomponent>