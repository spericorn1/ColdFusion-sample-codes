<cfoutput>
<!--- what page are we dealing with :: this will help set the active menu item --->
<cfset activeNav = ''>

<!--- *********************** _header ***********************--->
<cfinclude template="/includes/_header.cfm">


<!--- *********************** navigation ***********************--->
<cfinclude template="/includes/_siteNav.cfm" />

 <!-- set the activeNav variable here before the include so the menu will have the proper thing selected -->
<!--- <cfinclude template="/includes/chunks/_mainMenu.cfm">
 --->

<!--- *********************** THIS PAGE'S INCLUDE FILE --- this is where your main logic goes for this page ***********************--->
<cfinclude template="content.cfm">



<!--- *********************** THIS PAGE's specific javascript such as (datatables, flot, etc..) ***********************--->


<cfinclude template="/includes/slackFooter.cfm">

<!--- *********************** _footer ***********************--->
<cfparam name="extraJS" default="">

<!--- *********************** _coreJavaScript ***********************--->
    <script src="/js/app.min.js"></script>
    <script src="/js/thenico.js"></script>
    <script src="/js/custom.js"></script>

    <!--- Page Specific Javascript  Test and Include --->
 <cfif FileExists(ExpandPath("_customFootJS.cfm"))> 
    <cfinclude template="_customFootJS.cfm" />


  </cfif>
<script type="text/javascript">
	$(function(){
		msgCount = 0;
	});
</script>
<cfoutput>
<!-- IMPORTANT common script init for all pages-->
<!--- unsure what this file does need to lookin before deleting <script src="/js/scripts.js"></script> <script src="/js/core.js"></script>--->

<!--- PUT Javascript that applies to ALL pages here don't put it in the one above so you don't mingle it with the template scripts above --->

#trim(extraJS)#
</body>
</html>
</cfoutput>
<!--- <cfinclude template="/includes/_debug.cfm"> --->
</cfoutput>
