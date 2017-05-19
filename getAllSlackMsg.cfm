<cfinclude template="slackUsers.cfm">
<cfoutput>
    <cfscript>
        cfhttp(method="POST", charset="utf-8", url="#local.dataset.requesturl#channels.history?token=#local.dataset.accesstoken#&channel=#local.dataset.chanelId#&count=#local.dataset.count#&pretty=1", result="chatroomjson") {
              cfhttpparam(name="q", type="formfield", value="cfml");
         }
         local.data.chatData = deserializeJSON(chatroomjson.Filecontent); 
    </cfscript>   
    <!--- <div class="chatMsgWrap" id="chatMsgWrap"> --->
    <div class="chatUserNameBlock">
        <cfloop index = "LoopCount" from = "#arrayLen(local.data.chatData.messages)#" to = "1" step = "-1">
            <cfscript>
                local.data.userName = "";
                local.data.text = "";
                local.data.dateTime = "";
                local.data.edited = false;
                local.data.image = "../../img/slackbot.png";
                
                if( structKeyExists(local.data.chatData.messages[LoopCount], "username")) {
                    local.data.userName = local.data.chatData.messages[LoopCount].username;
                } else {
                    local.data.userdetails = StructFindvalue(application.data.processuserlist,local.data.chatData.messages[LoopCount].user,"one");                          
                    local.data.userName = local.data.userdetails[1].owner.name;
                    local.data.image =  local.data.userdetails[1].owner.image;
                } 
                if( structKeyExists(local.data.chatData.messages[LoopCount], "text")) {
                    local.data.text = local.data.chatData.messages[LoopCount].text;
                }
                
                if( structKeyExists(local.data.chatData.messages[LoopCount], "ts")) {
                    local.data.dateTime = dateAdd("s", local.data.chatData.messages[LoopCount].ts, createDateTime(1970, 1, 1, 0, 0, 0));
                    local.data.timestamp = local.data.chatData.messages[LoopCount].ts;
                }
                if( structKeyExists(local.data.chatData.messages[LoopCount], "edited")) {
                    local.data.edited = true;
                    local.data.dateTime = dateAdd("s", local.data.chatData.messages[LoopCount].edited.ts, createDateTime(1970, 1, 1, 0, 0, 0));
                }
            </cfscript>
          <!---   <div class="dayHolder">
                <div class="border"></div><span>Yesterday</span><div class="border"></div>
            </div> --->
            <div class="row chatInputSec" id="#local.data.timestamp#">
                <div class="chatAvtar floatleft">
                    <img src="#local.data.image#" width="36" height="36" alt="Bot">
                </div>
                <div class="chatMsg floatleft">
                    <span class="chatUserName">#local.data.userName# </span>
                    <span class="chatTime"><cfif local.data.edited>
                        (edited)
                    </cfif>#timeFormat(local.data.dateTime,"hh:nn:ss")#</span>
                    <span class="starChat"></span>
                    <div class="chatMsgBlock">
                        #local.data.text#
                    </div>
                </div>
            </div>
        </cfloop>                            
    </div>
    <!--- </div> --->
</cfoutput>