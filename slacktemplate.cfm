<cfinclude template="slackCredentials.cfm">
<cfinclude template="slackUsers.cfm">
<cfoutput>
    <cfscript>
        local.data.moremessage = "" ;
       
        if(len(session.latest.timestamp)) {
            local.data.moremessage = "&latest="& session.latest.timestamp;
        }
        cfhttp(method="POST", charset="utf-8", url="#local.dataset.requesturl#channels.history?token=#local.dataset.accesstoken#&channel=#local.dataset.chanelId#&count=#local.dataset.count#&pretty=1#local.data.moremessage#", result="chatroomjson") {
            cfhttpparam(name="q", type="formfield", value="cfml");
        }
        
        local.data.chatData = deserializeJSON(chatroomjson.Filecontent); 
        if(structKeyExists(local.data.chatData,"messages") and arrayLen(local.data.chatData.messages)) {
            session.latest.timestamp =  local.data.chatData.messages[arrayLen(local.data.chatData.messages)].ts;
        }       
    </cfscript>
    <cfset local.isNext = false>
    <cfset local.pinnedUserName = "">
    <cfset local.pinnedItems = arraynew(1)>  
    <cfset local.data.pinnedlist = "" >
   
    <cfloop index = "LoopCount" from = "#arrayLen(local.data.chatData.messages)#" to = "1" step = "-1">
        <cfif ( Not structKeyExists(local.data.chatData.messages[LoopCount], "attachments")) and structKeyExists(local.data.chatData.messages[LoopCount], "text") >
            <cfscript>
                local.data.userName = "";
                local.data.text = "";
                local.data.dateTime = "";
                local.data.image = "../../img/slackbot.png";
                local.data.edited = false;
                local.data.pinnedClass = "";                
                local.data.imagepath = "";

                if( structKeyExists(local.data.chatData.messages[LoopCount], "username")) {
                    local.data.userName = local.data.chatData.messages[LoopCount].username;
                } else {
                    local.data.userdetails = StructFindvalue(local.data.userlist,local.data.chatData.messages[LoopCount].user,"one");                          
                    local.data.userName = local.data.userdetails[1].owner.name;
                    local.data.image =  local.data.userdetails[1].owner.image;
                } 
                if( structKeyExists(local.data.chatData.messages[LoopCount], "user")) {
                    local.data.userdetails = StructFindvalue(local.data.userlist,local.data.chatData.messages[LoopCount].user,"one");                          
                    local.data.userName = local.data.userdetails[1].owner.name;
                    local.data.image =  local.data.userdetails[1].owner.image;
                }
                if( structKeyExists(local.data.chatData.messages[LoopCount], "text")) {
                    local.data.text = local.data.chatData.messages[LoopCount].text;
                }
                if( structKeyExists(local.data.chatData.messages[LoopCount], "file")) {
                    local.data.text = "uploaded a file";
                   if( structKeyExists(local.data.chatData.messages[LoopCount].file, "thumb_480")) {
                        local.data.imagepath = '<img src="#local.data.chatData.messages[LoopCount].file.thumb_480#">';
                   } else {

                        local.data.imagepath = '<div class="fileouter"><img src="https://web1.capetown.gov.za/web1/OpenDataPortal/Images/generic.png" class="image_file"> #local.data.chatData.messages[LoopCount].file.title#</div>';
                   }
                   local.data.url_private = local.data.chatData.messages[LoopCount].file.url_private;
                }
                if( structKeyExists(local.data.chatData.messages[LoopCount], "ts")) {
                    local.data.dateTime = dateAdd("s", local.data.chatData.messages[LoopCount].ts, createDateTime(1970, 1, 1, 0, 0, 0));
                    local.data.timestamp = local.data.chatData.messages[LoopCount].ts;
                }
                if( structKeyExists(local.data.chatData.messages[LoopCount], "edited")) {
                    local.data.edited = true;
                    local.data.dateTime = dateAdd("s", local.data.chatData.messages[LoopCount].ts, createDateTime(1970, 1, 1, 0, 0, 0));
                }
                 if( structKeyExists(local.data.chatData.messages[LoopCount], "pinned_to")) {                                                        
                   local.data.pinnedlist = listAppend(local.data.pinnedlist, local.data.chatData.messages[LoopCount].ts,","); 
                }
            </cfscript>

            <div class="row chatInputSec #local.data.pinnedClass#" id="#replace(local.data.timestamp,'.','')#">
                <div class="chatAvtar floatleft">
                    <img src="#local.data.image#" width="36" height="36" alt="Bot">
                </div>
                <div class="chatMsg floatleft">
                    <span class="chatUserName">#local.data.userName#</span>
                    <span class="chatTime">#timeFormat(local.data.dateTime,"hh:nn:ss")#
                        <cfif local.data.edited>
                            (edited)
                        </cfif>
                    </span>
                    <span class="starChat"></span>
                    <div class="chatMsgBlock">
                        #local.data.text# 
                        <cfif len(local.data.imagepath)>                            
                           <br><a href="#local.data.url_private#" target='_blank'>#local.data.imagepath#</a>
                        </cfif>
                    </div>
                </div>
            </div>
        </cfif>        
    </cfloop>  
                            
    <cfloop array="#structfindvalue(local.data.chatData,"pinned_item","all")#" index="index">
        <cfscript>
            if(structKeyExists(index.owner, "attachments") and structKeyExists(index.owner.attachments[1], "ts") and listFindNoCase(local.data.pinnedlist, index.owner.attachments[1].ts)) {
                local.data.count = arrayLen(local.pinnedItems)+1; 
                local.pinnedItems[local.data.count] = {};
                local.pinnedItems[local.data.count].user = index.owner.user;
                local.pinnedItems[local.data.count].ts = index.owner.attachments[1].ts;
            }                                                    
        </cfscript>  
    </cfloop>     
    <script type="text/javascript">        
        parsePinned('#serializejson(local.pinnedItems)#');
    </script>
</cfoutput>

