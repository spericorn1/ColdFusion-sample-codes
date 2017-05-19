<cfoutput>
<!--- what page are we dealing with :: this will help set the active menu item --->
<cfset activeNav = 'Services'>

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




<!--- *********************** _footer ***********************--->
<cfinclude template="/includes/_footer.cfm">
<!--- <cfinclude template="/includes/_debug.cfm"> --->
</cfoutput>
	