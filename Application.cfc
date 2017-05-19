/**
* @output false
*/
component{

    this.name              	= "chat";
    this.sessionmanagement 	= true;
    this.sessiontimeout    	= createTimeSpan(1,0,0,0);
    // websockets
    this.wschannels 		= [{name="sChat"}];
}