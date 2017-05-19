<cfscript>
    cfhttp(method="POST", charset="utf-8", url="#local.dataset.requesturl#users.list?token=#local.dataset.accesstoken#&channel=#local.dataset.chanelId#&pretty=1",  result="usersList") {
        cfhttpparam(name="q", type="formfield", value="cfml");
    }
    local.data.userlistData = deserializeJSON((usersList.Filecontent)).members;
    local.data.userlist.user = {};
    for(i=1; i LTE arrayLen(local.data.userlistData); i++) {
        local.tempdata = 'id'&i;
        local.data.userlist.user[local.tempdata] = {};
        local.data.userlist.user[local.tempdata].id = local.data.userlistData[i].id;
        local.data.userlist.user[local.tempdata].name = local.data.userlistData[i].name;
        local.data.userlist.user[local.tempdata].image = local.data.userlistData[i].profile.image_32;
    }    
</cfscript>