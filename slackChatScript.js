var msgCount = 0;
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
    $.ajax({type: "POST", url: "/chat2/_slackpush.cfm",
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
function showUnreadMsgCount(msgData) {
    var ts = new Date(msgData.timestamp * 1000);
    var img = "";
    if(msgData.file!=""){
        img = "<br><a href='"+msgData.url_private+"' target='_blank'>"+msgData.file+"</a>";
    }
    $('.chatCount').show();
    $('.chatIcon').show();
    $('.chatCount').html(msgData.msCount);
    $('.chatName').html(msgData.username);
    $('.chatTime').html(ts.toTimeString().toString().split(' ')[0]);
    $('.slackMessage').html(msgData.text+img);
    $('.chatProfilePic').html('<img src="'+msgData.image+'" width="40px" height="40px" alt="profile pic">');
}
function parseMessage(msgData){ 
    msgCount = 0;
    $('.chatIcon').hide();
    var ts = new Date(msgData.timestamp * 1000);
    var img = "";
    if(msgData.file!=""){
        img = "<br><a href='"+msgData.url_private+"' target='_blank'>"+msgData.file+"</a>";
    }
    var data ='<div class="row chatInputSec" id="'+msgData.timestamp.replace(".", "")+'"><div class="chatAvtar floatleft"><img src="'+msgData.image+'" width="36" height="36" alt="Bot"></div><div class="chatMsg floatleft"><span class="chatUserName">'+msgData.username+'</span><span class="chatTime">'+ts.toTimeString().toString().split(' ')[0]+'</span><span class="starChat"></span><div class="chatMsgBlock">'+msgData.text+img+'</div></div></div>';
    $('.chatUserNameBlock').append(data); 
    if($('.chatUserNameBlock').length) {
        $('.userChatBlock').scrollTop($('.userChatBlock')[0].scrollHeight);
    }
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
            // console.log(data);
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
                            username: "",
                            file : "",
                            url_private : "",
                            msCount : 0
                        };                                
                        nodeId = userdata.timestamp.replace('.','');                               
                        if($('#'+nodeId).length==0){                                                               
                            if(typeof(userdata.userid)!=="undefined"){
                                obj = parseUser(userdata.userid);
                                
                            }   
                            if(typeof(data.file)!=="undefined"){
                                userdata.text = "uploaded a file";
                                if(typeof(data.file.thumb_480)!="undefined") {
                                    userdata.file = '<img src="'+data.file.thumb_480+'">';
                                } else{
                                    userdata.file = '<div class="fileouter"><img src="https://web1.capetown.gov.za/web1/OpenDataPortal/Images/generic.png" class="image_file"> '+data.file.title+'</div>';
               
                                }
                                
                                userdata.url_private = data.file.url_private
                            }                              
                            if(typeof(data.username) !=="undefined"){
                                userdata.username = data.username;
                                 userdata.image = "../../img/slackbot.png";
                            }else {
                                userdata.username = obj.username;
                                userdata.image = obj.image;  
                            }
                            if(typeof(data.user) !=="undefined"){
                                 userdata.username = obj.username;
                                userdata.image = obj.image;  
                            }
                            
                            if(!$('.chatUserNameBlock').length && typeof(data.reply_to) ==="undefined"){ 
                                msgCount = msgCount+1;
                                userdata.msCount = msgCount; 
                                if( getCookie("BOTUSERNAME").length ) {
                                    showUnreadMsgCount(userdata);
                                }       
                            } else {
                                parseMessage(userdata);
                            }
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

function getCookie(cname) {
    var name = cname + "=";
    var decodedCookie = decodeURIComponent(document.cookie);
    var ca = decodedCookie.split(';');
    for(var i = 0; i <ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0) == ' ') {
            c = c.substring(1);
        }
        if (c.indexOf(name) == 0) {
            return c.substring(name.length, c.length);
        }
    }
    return "";
}


$(function() {     
    if($('.chatUserNameBlock').length) {
        $('.userChatBlock').scrollTop($('.userChatBlock')[0].scrollHeight);
    }
    $('#chooseBotNameBtn').click(function(){
        var bot_name = $('#bot_name').val();
        $.ajax({ type: "POST", url: "/chat2/_slackpush.cfm",
            dataType: 'json', data: { "botName":bot_name },
            success: function(data) {                    
                $('#botUserNameSelect').remove();
                $('.chatView').css("display","block");    
            }                
        });
    });
    $('.userChatBlock').scroll(function() {
        var pos = $('.userChatBlock').scrollTop();
        var scrollHeight = $('.userChatBlock')[0].scrollHeight;
        if (pos == 0) {
           var data = "<div class='loading'>Loading more messages ...</div>";
           $('.userChatBlock').prepend(data);
           $.ajax({
              type: "POST",
              url: "slacktemplate.cfm",                  
              success: function(data){
                $('.loading').remove();
                $('.userChatBlock').prepend(data);
                var scrollHeightnew = $('.userChatBlock')[0].scrollHeight;
                scrollHeight = scrollHeightnew - scrollHeight;
                $('.userChatBlock').scrollTop(scrollHeight);
              }
            });
        }
    });
});