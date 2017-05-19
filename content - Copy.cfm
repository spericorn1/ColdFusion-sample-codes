<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js"></script>
<cfinclude template="slackCredentials.cfm">
<cfinclude template="slackUsers.cfm">
<!--- <cfdump var="#local.data.userlist#" /><cfabort /> --->
<script type="text/javascript">
    var userlist = <cfoutput>#serializeJSON(local.data.userlist)#</cfoutput>;   
    var channelId = "<cfoutput>#local.dataset.chanelId#</cfoutput>";
    function sendmsg(event,obj) {
      var txtMsg = $('#msgText').val();
      var keycode = event.keyCode || event.which;
        if(keycode == '13') {
          if($.trim(txtMsg).length) { sendToSlack();
            } else { alert("Enter a message.."); 
          }
        }
    }
    function parsePinned(data){
        var data =  JSON.parse(data);        
         $.each(data, function(key, value) {
            pinned(value.TS.toString(),value.USER.toString());
        });     
    }
    function sendToSlack() {
      var txtMsg = $('#msgText').val();     
      if(txtMsg.length) {
        $.ajax({type: "POST", url: "/chat/_slackpush.cfm",
          dataType: 'json', data: { "txtMsg":txtMsg },
          error: function(data) { alert("Message sending failed");}
        });        
        $('#msgText').val("");
      }
    }
    function pinned(ts,user){
        nodeId = ts.replace(".", "");
        $("#"+nodeId).addClass('pin');
        obj = parseUser(user);
        if(!$("#"+nodeId).find('.pinnedBy').length){
            var pinned = "<span class='pinnedBy'> pinned by "+obj.username+" </span>";
            $('#'+nodeId).find('.chatTime').append(pinned);
        }
       
    }
    function parseMessage(msgData){ 
        var ts = new Date(msgData.timestamp * 1000);
       
        var data ='<div class="row chatInputSec" id="'+msgData.timestamp.replace(".", "")+'"><div class="chatAvtar floatleft"><img src="'+msgData.image+'" width="36" height="36" alt="Bot"></div><div class="chatMsg floatleft"><span class="chatUserName">'+msgData.username+'</span><span class="chatTime">'+ts.toTimeString().toString().split(' ')[0]+'</span><span class="starChat"></span><div class="chatMsgBlock">'+msgData.text+'</div></div></div>';
        $('.chatUserNameBlock').append(data); 
        $("#"+msgData.timestamp).on("click", function(){
       
        });
    }
    function chooseBotName(sts) {
        if(sts) {
            $('#botUserNameSelect').remove();
            $('.chatView').css("display","block");
        }
    }
    function parseUser(userid){
        
        var obj = {};       
        $.each(userlist.USER, function(key, value) {
            if(value.ID==userid){
                obj.username = value.NAME;
                obj.image = value.IMAGE;

            }
        });         
       return obj;
    }
    function WebSocketTest(url) {
        if ("WebSocket" in window) {
            var ws = new WebSocket(url);            
            ws.onopen = function(){             
            };
            ws.onmessage = function (evt) { 
                var data = JSON.parse(evt.data);    
                if((typeof(data.channel) !== "undefined" && data.channel == channelId) || (typeof(data.channel_id) !== "undefined" && data.channel_id == channelId)){    
                    if(data.type == 'message') {  
                        if(typeof(data.subtype) !== "undefined" && data.subtype=="pinned_item"){
                           return ;
                        } 
                        if(typeof(data.deleted_ts) !== "undefined") {
                            nodeId = data.deleted_ts.replace(".", "");
                            $("#"+nodeId).remove();
                        }
                        if(typeof(data.text) !== "undefined"){
                            var userdata = {
                                text : data.text,
                                timestamp :data.ts,
                                userid : data.user,
                                image : "",
                                username: ""
                            };                                
                            nodeId = userdata.timestamp.replace('.','');                               
                            if($('#'+nodeId).length==0){
                                console.log(userdata.userid);
                                console.log(typeof(userdata.userid));
                                 console.log(typeof(data.username));
                                if(typeof(userdata.userid)!=="undefined"){
                                    obj = parseUser(userdata.userid);
                                    console.log(obj);
                                }                                
                                if(typeof(data.username) !=="undefined"){
                                    userdata.username = data.username;
                                     userdata.image = "../../img/slackbot.png";
                                }else {
                                    userdata.username = obj.username;
                                    userdata.image = obj.image;  
                                }
                                console.log(userdata);
                                parseMessage(userdata);         
                            }
                            
                        } else if(typeof(data.message) !== "undefined"){
                            if( data.message.edited !== "undefined" ) { 
                                 var userdata = {
                                    text : data.message.text,
                                    timestamp : new Date(data.message.ts * 1000)                                
                                };                         
                                text = data.message.text;
                                data.previous_message.ts = data.previous_message.ts.replace(".", "");
                                $node = document.getElementById("'"+data.previous_message.ts+"'");                             
                                $('#'+data.previous_message.ts).find('.chatTime').html(userdata.timestamp.toTimeString().toString().split(' ')[0]+" (edited)");
                                $('#'+data.previous_message.ts).find('.chatMsgBlock').html(userdata.text);
                            }
                        }  
                    } else if(data.type=='user_typing'){
                        obj = parseUser(data.user);
                        $('#user_typing').html(obj.username+" is typing ...");
                        setTimeout(function(){
                            $('#user_typing').html("");
                        }, 5000);
                    } else if( data.type == 'pin_added') {
                        nodeId = data.item.message.ts.replace(".", "");
                        $("#"+nodeId).addClass('pin');
                        obj = parseUser(data.user);
                        var pinned = "<span class='pinnedBy'> pinned by "+obj.username+" </span>";
                        $('#'+nodeId).find('.chatTime').append(pinned);
                    } else if(data.type == 'pin_removed') {
                        nodeId = data.item.message.ts.replace(".", "");
                        $("#"+nodeId).removeClass('pin');
                        $('#'+nodeId).find('.pinnedBy').remove();
                    }
                }          
            };
            ws.onclose = function() {             
            };
        } else {
            // The browser doesn't support WebSocket
            alert("WebSocket NOT supported by your Browser!");
        }
    }
    $(function() {     
        $('#chooseBotNameBtn').click(function(){
            var bot_name = $('#bot_name').val();
            $.ajax({ type: "POST", url: "/admin/npnr/_slackpush.cfm",
                dataType: 'json', data: { "botName":bot_name },
                success: function(data) {                    
                    $('#botUserNameSelect').remove();
                    $('.chatView').css("display","block");    
                }                
            });
        });
    });
</script>

<style type="text/css">    
    .border {
        height: 5px;
        width: 45%;
        border-top: 1px solid #ccc;
        display: inline-block;
    }      
    .chatMsgWrap {
        width: 100%;
        float: left;
    }
    .chatTime{
        padding-left: 10px;
    }
    .chatTime, .starChat {
        color: #999;
        font-size: 12px;
    }
    .chatUserName {
        font-weight: bold;
        color: #606873;
        font-size: 16px;
    }
    .clearfix {
        clear: both;
    }   
    .slackChatTitle p {
        padding: 0px;
        margin: 0;
    }
    .slackChatTitle {
        font-size: 16px;
        padding-bottom: 10px;
    }
    .slackChatMessenger {
        padding-top: 30px;
        padding-bottom: 0px;
    }
    .chatHeadName {
        margin-top: 0px;
        font-weight: 700;
    }
    .chatAvtar {
        position: relative;
        top: 5px;
        width: 36px;
    }
    .chatAvtar img{
        border-radius: 3px;
    }
    .chatMsg {
        width: 90%;
        padding-left: 5px;
    }
    .floatleft {
        float:  left;
    }
    .chatInputSec {
        margin-right: 15px;
        margin-left: 0;
        margin-top:9px;
    }
    .txtCenter {
        text-align: center;
    }
    #botUserNameSelect {
        position: relative;
        top: 5px !important;
    }
    .chatView {
        display: none;
    }
    .sendBtn {
        cursor: pointer;
    }
    
    #msgText{
        border:1px solid ##ccc;
    }
    #user_typing{
        color:#ccc;
        font-size: 11px;
        height: 15px;
    }
    .pin{
        background-color: rgba(255,243,184,.3);
    }
</style>
<!-- Main container -->
<main>     
    <cfoutput>
        <cfscript>
            if(structKeyExists(url,"code") and len(url.code)) {
                local.dataset.code = url.code;
                cfhttp(method="POST", charset="utf-8", url="https://slack.com/api/oauth.access?client_id=#local.dataset.clientId#&client_secret=#local.dataset.clientSecret#&code=#local.dataset.code#", result="accessRes") {
                    cfhttpparam(name="q", type="formfield", value="cfml");
                }
                // writeDump(deserializeJSON(accessRes.Filecontent));abort;
                if(deserializeJSON(accessRes.Filecontent).ok) {
                    session.useraccesstoken = deserializeJSON(accessRes.Filecontent).access_token;
                }
            }
            cfhttp(method="POST", charset="utf-8", url="#local.dataset.requesturl#channels.history?token=#local.dataset.accesstoken#&channel=#local.dataset.chanelId#&count=#local.dataset.count#&pretty=1", result="chatroomjson") {
                cfhttpparam(name="q", type="formfield", value="cfml");
            }
            local.data.chatData = deserializeJSON(chatroomjson.Filecontent);
             //writeDump(local.data.chatData); abort;
        </cfscript>
        <section>
            <div class="container">
                <div class="slackChatHeader">
                    </div>
                    <div class="slackChatBody">
                        <div class="modal-dialog" id="botUserNameSelect">
                            <!-- Modal content-->
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                                    <h4 class="modal-title">Chat Name</h4>
                                </div>
                                <div class="col-md-12">
                                    <div class="modal-body">
                                        <div class="row txtCenter">
                                            <a href="https://slack.com/oauth/authorize?scope=chat:write:user&client_id=#local.dataset.clientId#"><img src="https://api.slack.com/img/sign_in_with_slack.png" /></a>
                                        </div>
                                        <div class="row txtCenter chatInputSec">
                                            <label>OR</label>
                                        </div>
                                        <!--- <form action="" method="POST" name="chooseName"> --->
                                            <div class="chatInputSec">
                                                <input class="form-control" type="text" name="bot_name" id="bot_name" placeholder="Type a user name"> 
                                            </div>
                                            <div class="chatInputSec">
                                                <input class="form-control btn btn-primary" type="button" name="chooseBotNameBtn" id="chooseBotNameBtn" Value="Submit"> 
                                            </div>
                                        <!--- </form> --->
                                    </div>
                                </div>
                                <div class="modal-footer">
                                </div>
                            </div>
                        </div>
                        <div class="chatView">
                            <div class="slackChatTitle">
                                <h3 class="chatHeadName">#local.dataset.channelname#</h3>                       
                                <p>Purpose: Discussion</p>
                            </div>
                            <div class="userChatBlock clearfix">                               
                                <div class="chatMsgWrap" >
                                    <div class="chatUserNameBlock">
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
                                                    
                                                    
                                                    if( structKeyExists(local.data.chatData.messages[LoopCount], "username")) {
                                                        local.data.userName = local.data.chatData.messages[LoopCount].username;
                                                    } else {
                                                        local.data.userdetails = StructFindvalue(local.data.userlist,local.data.chatData.messages[LoopCount].user,"one");                          
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
                                                                                     
                                    </div>
                                </div>
                            </div>
                        </div>                    
                    <div class="chatView">
                        <div class="slackChatMessenger">
                            <div id="user_typing"></div>
                            <div class="row chatInputSec">
                                <!--- <form class="form-horizontal" id="sendMessageSec" action="" method="POST"> --->
                                    <div class="input-group">
                                        <input id="msgText" type="text" class="form-control" name="msgText" onkeyup="sendmsg(event,this,1)" placeholder="Type your message">
                                        <span class="input-group-addon sendBtn" onclick="sendToSlack()">SEND</span>
                                    </div>
                                <!--- </form> --->
                            </div>

                        </div>
                    </div>
                </div>
            </div>
        </section>
        
        <cfif  not (structKeyExists(session,"useraccesstoken") or (structKeyExists(Cookie, "BOTUSERNAME") and len(Cookie.BOTUSERNAME))) >
            <script type="text/javascript">
                chooseBotName(0);
            </script>
        <cfelse>
            <script type="text/javascript">
                chooseBotName(1);
            </script>
        </cfif>
        <cfscript>
            cfhttp(method="POST", charset="utf-8", url="#local.dataset.requesturl#rtm.start?token=#local.dataset.accesstoken#&simple_latest=true&pretty=1", result="realtimeapi") {
                cfhttpparam(name="q", type="formfield", value="cfml");
            }
            local.data.websocketurl = deserializejson(trim(realtimeapi.filecontent)).url;
        </cfscript>
        <script type="text/javascript">
            WebSocketTest('#local.data.websocketurl#');
            parsePinned('#serializejson(local.pinnedItems)#');
        </script>

    </cfoutput>
</main>

