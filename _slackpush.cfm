<cfif structKeyExists(form,"txtMsg") >
	<cfinclude template="slackCredentials.cfm">
	<cfoutput>
		<cfscript>
			if( structKeyExists(session,"useraccesstoken")) {
		        local.dataset.accesstoken = session.useraccesstoken;
		        local.username = "";
		    }
		    if( structKeyExists(Cookie, "BOTUSERNAME") ) {
		    	local.username = "username=#urlEncodedFormat(Cookie.BOTUSERNAME)#&";
		    }
		    if( structKeyExists(form,"txtMsg") and len(form.txtMsg) ) {
		        local.txtMsg = urlEncodedFormat(form.txtMsg);
		        cfhttp(method="POST", charset="utf-8", url="#local.dataset.requesturl#chat.postMessage?token=#local.dataset.accesstoken#&channel=#local.dataset.chanelId#&text=#local.txtMsg#&#local.username#pretty=1", result="result") {
		            cfhttpparam(name="q", type="formfield", value="cfml");
		        }
		    }
		    local.data.success = "true";
		</cfscript>
	</cfoutput>
<cfelse>
	<cfscript>
		if(structKeyExists(form,"botName")) {
	        cookie[ "BOTUSERNAME" ] = {
	            value: "#form.botName#",
	            expires: "never"
	        };
	    }
	    local.data.success = "true";
	</cfscript>
</cfif>

<cfoutput>#serializejson(local.data)#</cfoutput>