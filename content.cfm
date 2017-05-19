
<link href="slackChatCss.css" rel="stylesheet">
<!-- Main container -->
<main>     
    <cfoutput>
        <cfscript>
            if(structKeyExists(url,"code") and len(url.code)) {
                local.dataset.code = url.code;
                cfhttp(method="POST", charset="utf-8", url="https://slack.com/api/oauth.access?client_id=#local.dataset.clientId#&client_secret=#local.dataset.clientSecret#&code=#local.dataset.code#", result="accessRes") {
                    cfhttpparam(name="q", type="formfield", value="cfml");
                }
                if(deserializeJSON(accessRes.Filecontent).ok) {
                    local.slackusername = StructFindvalue(local.data.userlist,deserializeJSON(accessRes.Filecontent).user_id,"one");
                    // writeDump(local.slackusername);abort;
                    cookie[ "BOTUSERNAME" ] = {
                        value: "#local.slackusername[1].owner.name#",
                        expires: "never"
                    };
                    session.useraccesstoken = deserializeJSON(accessRes.Filecontent).access_token;
                }
            }     
            session.latest.timestamp = "";      
        </cfscript>
            <div class="maincontainer">                
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
                                <div class="chatHeadName">#local.dataset.channelname#</div>                       
                                <p>Purpose: Discussion</p>
                            </div>
                            <div class="userChatBlock clearfix">                               
                                <div class="chatMsgWrap" >
                                    <div class="chatUserNameBlock">
                                       <cfinclude template="slacktemplate.cfm">                                         
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
                                        <input id="msgText" type="text" class="form-control" name="msgText" onkeyup="sendmsg(event,this,1)" placeholder="Type your message" autocomplete="off">
                                        <span class="input-group-addon sendBtn" onclick="sendToSlack()">SEND</span>
                                    </div>
                                <!--- </form> --->
                            </div>

                        </div>
                    </div>
                </div>
            </div>
       
        
        <cfif  not (structKeyExists(session,"useraccesstoken") or (structKeyExists(Cookie, "BOTUSERNAME") and len(Cookie.BOTUSERNAME))) >
            <script type="text/javascript">
                chooseBotName(0);
            </script>
        <cfelse>
            <script type="text/javascript">
                chooseBotName(1);
            </script>
        </cfif>

    </cfoutput>
</main>

