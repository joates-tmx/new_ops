<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<!--#include File="./MyLogin/MyLoginSecurePage.inc"--> 
<!--#include file="./0commonz2.asp"-->
<!--#include file="./0COMMON_DATEMATH.asp" -->
<!--#include file="./menu.asp"-->
<!--#include file="./jquery-contextmenu.asp"-->
<style>
	#mtab_content_1 a {
		color: #024963;
	}
	#readable_story_container {
		margin-top: 10px;
		padding-top: 10px;
		background-color: white;
		border: 2px;
	}
		#parsed_text_container {
		display:none;
		position: absolute; 
		background: white;
		border:1px solid gray;
		/* padding: 15px;  */
		top: 3vw; 
		left: 55vw;  
		width: 35vw;
		z-index: 100;
		border-radius: 10px;		
		box-shadow:  0 0 10px  rgba(0,0,0,0.6);
			-moz-box-shadow: 0 0 10px  rgba(0,0,0,0.6);
			-webkit-box-shadow: 0 0 10px  rgba(0,0,0,0.6);
			-o-box-shadow: 0 0 10px  rgba(0,0,0,0.6);
	}
	#parsed_text_container_header {
		/* border: 8px solid lightblue; */
		background: lightblue;
		text-align: center;
		cursor: move;
		height: 14px;
		border-top-left-radius: 10px;
	}
	#parsed_text {
		padding: 15px;
		overflow-y:auto;
		max-height:750px;
	}
	#parsed_text.news-story-text {
		font-size: 16px;
		line-height: 2;
	}
	#news_story_old_format__inner {
		font-size: 16px;
	}
	#pt-close-button {
		position: absolute;
		right: 0;
		top: 0;
		cursor: pointer;
		border: 1px;
	}
	#news_icon_wrapper {
		cursor: pointer;
	}
	#news_icon_wrapper_old_format {
		cursor: pointer;
	}
	.modal {
		max-width: 70%;
	} 
	.draggable-text {
		font-size: 9.5px;
		visibility: hidden;
		opacity: 0;
	}
	#parsed_text_container_header:hover .draggable-text {
		visibility: visible;
		opacity: 1;
	}
	.font-size-button {
		position: absolute;
		top: 0;
		cursor: pointer;
		border: 3px;
		background-color: transparent;
		font-weight: bold;
		font-size: 14px;
	}
	#increase_font_size {
		right: 50px;
	}
	#decrease_font_size {
		right: 40px;
	}
	#pop_story_new_tab {
		left: 15px;
	}
	#pop_story_new_tab img{
		height:12px;
	}
</style>
<script src="./js/event_lock.js?v=7"></script> 
</head>
<body class="coach green " id="standard_format">
<div id=zdiv_content name=zdiv_content>
<div id="parsed_text_container">
	<div id="parsed_text_container_header" class="draggable"> 
		<p class="draggable-text">I'm draggable.</p>
		<button id="pop_story_new_tab" class="font-size-button" onclick="popStoryNewTab()"><img src=".\images\NW.GIF"></button>
		<button id="increase_font_size" class="font-size-button" onclick="increase_parsed_text_size()">+</button>
		<button id="decrease_font_size" class="font-size-button" onclick="decrease_parsed_text_size()">-</button>
		<button id="pt-close-button" onclick="hideNewsStoryInPage()">X</button>
	</div>
	<div id="parsed_text"></div>
</div>
<form method=post id=main_form name=main_form action=# onsubmit="unload_form();" >
<div id="content" class="three-column">
<!-- start of page -->
<% 
'zcp_on = true
dim dow(7)
dow(1) = "Su "
dow(2) = "Mo "
dow(3) = "Tu "
dow(4) = "We "
dow(5) = "Th "
dow(6) = "Fr "
dow(7) = "Sa "	
fiscal_year_list = "/...}"	
for year_ct = -10 to 2
	fiscal_year_list = fiscal_year_list & "" &_
	year(date())+year_ct & "/" & year(date())+year_ct & "&nbsp;&nbsp;}" &_
	""
next
lstatus_list = 	"/...}ACTIVE/ACTIVE}DISABLED/DISABLED}HISTORICAL/HISTORICAL}PENDING_REVIEW/PENDING_REVIEW"
right_now = znow()
cr hiddenf("mactive_tab", zrequest("mactive_tab"))
cr hiddenf("active_tab", zrequest("active_tab"))
zscreen__updates = zrequest("zscreen__updates")
if zrequest("qa_onscreen") <> "Y" then zscreen__updates = ""
cr hiddenf("zscreen__updates", zscreen__updates)
'
'	Globals
'
'-------------------------------------------------------------
worklist_support = TRUE
'
'	Selection/Filter
'
selection_event_id = ""
selection_stock_symbol = ""
selection_quarter = ""
selection_fiscal_year = ""
selection_updated = ""
selection_live_call_datetime = ""
selection_status = ""
selection_company_name = ""
'-------------------------------------------------------------
'	Screen Management
'
screen_warning = 1
screen_error = 2
screen_ok = 0
screen_status = screen_ok
screen_width = 950
sw_buffer = ""
zpage_id = "standard_format"
zfinal_script = ""
tab_err = ""
dim mtab(10)
dim mtab_title(10)
for ct = 1 to 10
	mtab(ct) = ""
	mtab_title(ct) = ""
next
'-------------------------------------------------------------
'	Other
'
Dim edm_processed_directory, edm_readable_directory
edm_processed_directory = "\\codeserver\0wsh\ws_" & lcase(zsystem_top) & "\NewsWare_preannounce\processed_stories\"
edm_readable_directory = "\\codeserver\0wsh\ws_" & lcase(zsystem_top) & "\NewsWare_preannounce\readable_stories\"
not_found_txt = "?NOT_FOUND?"
stickies = "N"
all_errors = ""
set connection = CreateObject("adodb.connection") ' Connection
connection.Open connstr
Set rs = Server.CreateObject("ADODB.RecordSet")
Set rstemp = Server.CreateObject("ADODB.RecordSet")
Set xrs = Server.CreateObject("ADODB.RecordSet")
Set rs_CONF_CALLS = Server.CreateObject("ADODB.RecordSet")
Set old_CONF_CALLS = Server.CreateObject("ADODB.RecordSet")
set rs_list = CreateObject("adodb.recordset")     ' Record set
set rs_companies = CreateObject("adodb.recordset")     ' Record set
the_ribbon = ""
list_prefix = "/Please Select}"
build_lists = true
%><!--#include file="ice_common.asp" --><%
data_entry_list = "/All...}"
set RS = Connection.Execute("Select  " &_
	"usercode,name " &_
		" from WSH_INTERNAL_USERS where acl like '%FUNCTION:EDIT_CO%' and record_status='current' order by name")
while not(RS.EOF)		
	data_entry_list = data_entry_list & rs("usercode") & "/" & rs("name") & "}"
	rs.movenext
wend
data_entry_list = ucase(data_entry_list)
rs.close
'-------------------------------------------------------------
'	Record Globals
'
this_callback_date = ""
this_company_id = ""
this_company_name = ""
this_country = ""
this_country_code = ""
this_create_parser_ticket = ""
this_created = ""
this_created_by = ""
this_date_desc = ""
this_edate = "" 
this_edate_status = ""
this_event_id = ""
this_event_type = ""
this_external_notes = ""
this_fiscal_year = ""
this_id = ""
this_ISIN = ""
this_iso_country_code = ""
this_live_call_datetime = cdate(date() & " 00:00")
this_live_intl_number = ""
this_live_intl_passcode = ""
this_live_number = ""
this_live_passcode = ""
this_live_pwebsite = ""
this_live_url = ""
this_counter_1CL = ""
this_display_on_WL = ""
this_notes = ""
this_one_click_link = ""
this_parser_ticket_description = ""
this_qa_flag = ""
this_qa_flag = ""
this_qa_notes = ""
this_qa_notes = ""
this_qa_onscreen = ""
this_qaed = ""
this_qaed = ""
this_qaed_by = ""
this_qaed_by = ""
this_quarter = ""
this_rebroadcast_enddate=""
this_record_status = "CURRENT"
this_replay_end_date = ""
this_replay_number = ""
this_replay_passcode = ""
this_replay_pwebsite = ""
this_replay_reservation_id = ""
this_replay_start_datetime = ""
this_replay_url = ""

this_live_registration_url = ""
this_source_code = ""
this_source_file = ""
this_source_id = ""
this_status = "ACTIVE"
this_stock_exchange = ""
this_stock_symbol = ""
this_time_zone = ""
this_tod = ""
this_updated = ""
this_updated_by = ""
this_utc_offset = ""
err_company_id= ""
err_company_name= ""
err_country_code= ""
err_create_parser_ticket = ""
err_created_by= ""
err_created= ""
err_event_id= ""
err_event_type= ""
err_external_notes= ""
err_fiscal_year= ""
err_id= ""
err_ISIN= ""
err_live_call_datetime= ""
err_live_intl_number= ""
err_live_intl_passcode= ""
err_live_number= ""
err_parser_ticket_description = ""
err_live_passcode= ""
err_live_pwebsite= ""
err_live_url= ""
err_notes= ""
err_qa_flag= ""
err_qa_flag= ""
err_qa_notes= ""
err_qa_notes= ""
err_qaed_by= ""
err_qaed_by= ""
err_qaed= ""
err_qaed= ""
err_quarter= ""
err_rebroadcast_enddate=""
err_record_status= ""
err_replay_end_date= ""
err_replay_number= ""
err_replay_passcode= ""
err_replay_pwebsite= ""
err_replay_reservation_id= ""
err_replay_start_datetime= ""
err_replay_url= ""

err_live_registration_url= ""
err_source_code= ""
err_source_file= ""
err_source_id= ""
err_status= ""
err_stock_exchange= ""
err_stock_symbol= ""
err_updated_by= ""
err_updated= ""
' 
' 
old_notes = ""
old_cc_date = ""
old_cc_tod = ""
old_live_call_datetime = ""
old_live_number = ""
old_live_passcode = ""
old_live_url = ""
old_live_url = ""
old_live_intl_number = ""
old_live_intl_passcode = ""
old_replay_url = ""
old_replay_url = ""
old_live_registration_url = ""
old_replay_number = ""
old_replay_passcode = ""
old_replay_start_datetime = ""
old_replay_end_date = ""
' 
'-------------------------------------------------------------
'	Selection Globals
'
selection_COT_lists = zrequest_form("selection_COT_lists")
selection_event_id = zrequest_form("selection_event_id")
selection_stock_symbol = zrequest_form("selection_stock_symbol")	
selection_company_name = zrequest_form("selection_company_name")
selection_quarter = zrequest_form("selection_quarter")
selection_fiscal_year = zrequest_form("selection_fiscal_year")
selection_updated = zrequest_form("selection_updated")
selection_live_call_datetime = zrequest_form("selection_live_call_datetime")
selection_search = zrequest_form("selection_search")
selection_status = zrequest_form("selection_status")
this_data_entry = ""
if zthis_security = "manager" then 
	this_data_entry = "ALL"
else
	this_data_entry = zthis_usercode
end if
data_entry_input = "" &_
	drop_listf("data_entry", this_data_entry, data_entry_list, "style='width:155px;'") &_
	""
'-------------------------------------------------------------
'
'	Preprocessing
'
context_set = false
this_id = trim(ucase(zrequest_form("this_id")))
if zrequest_querystring("CompanyId") <> "" or zrequest_querystring("camefrom") = "HOME_LIST" then 
	pam_companyid = ucase(trim(zrequest("PAM_COMPANYID")))
	pam_ref = ucase(trim(zrequest("PAM")))
	GLOBAL_pam_ref = zrequest_form("GLOBAL_pam_ref")
	if GLOBAL_pam_ref = "" then GLOBAL_pam_ref = pam_ref
	if (pam_ref <> "") then 
		GLOBAL_companyid = pam_companyid
		pam_processing = true
	else
		GLOBAL_companyid = zrequest("companyid")
		pam_processing = false
	end if
	zput_session "companyid", request("companyid")
	zput_session "fy", request("fy")
	zput_session "qtr", request("qtr")
	context_set = true
	this_company_id = zget_session("companyid")
	if (request("CAMEFROM") = "EDATES" OR request("CAMEFROM") = "HOME_LIST" OR request("CAMEFROM") = "SYMBOL" OR request("CAMEFROM") = "FOOTER") and zrequest("next_id") <> "NEW" then 				
		this_fiscal_year = zget_session("fy")
		this_quarter = zget_session("qtr")
		this_2x_year = zget_table("COMPANIES", "FLAG_2XYEAR", "RECORD_STATUS='CURRENT' AND COMPANY_ID='" & this_company_id & "'")
		
		find_quarter =" (quarter='" & this_quarter & "')" 
		
		xsql = "select top(1)  " &_
			"id" &_
				" from CONF_CALLS where company_id='" & this_company_id & "' and record_status='CURRENT' and fiscal_year='" & this_fiscal_year & "'  and "  & find_quarter & " order by status" 
		
		rs.open xsql, connection, 3,3
		if not rs.eof then this_id= rs("id")
		rs.close
	end if	
end if
if isblank(this_id) then this_id = trim(ucase(zrequest_form("next_id")))
if zrequest_form("first_time") = "" and this_id = "" and zrequest("xevent_id") <> "" then this_id = zget_table("CONF_CALLS", "id", "event_id='" & zrequest("xevent_id") & "' and record_status='CURRENT'")
if zrequest("new_filter") = "Y" then this_id = ""
cancel_button0 = "" &_
	"<a href=#   " &_
		" onclick=""" &_
		"var_set('active_tab','');"&_
		"var_set('mactive_tab','1');" &_
		"var_set('next_id','');" &_
		"var_set('first_time', '');" &_
		"var_set('worklist', '');" &_
		"sub();" &_
		"return false;" &_
		""" " &_
		" title='Click to cancel (changes will be lost)' " &_
		">" &_
		"<img src='" & zicon_cancel_on & "' border=""0""></a>" &_
	""
cancel_button1 = "" &_
	"<a href=#   " &_
		" onclick=""" &_
		"var_set('active_tab','1');"&_
		"var_set('mactive_tab','1');" &_
		"var_set('next_id','');" &_
		"var_set('first_time', '');" &_
		"var_set('filters_set', '');" &_
		"var_set('worklist', '');" &_
		"sub();" &_
		"return false;" &_
		""" " &_
		" title='Click to cancel' " &_
		">" &_
		"<img src='" & zicon_cancel_on & "' border=""0""></a>" &_
	""
newrec_button0 = "" &_
	"<a href=#  " &_
		" onclick=""" &_
		"var_set('active_tab','');"&_
		"var_set('mactive_tab','1');" &_
		"var_set('next_id','NEW');" &_		
		"var_set('CAMEFROM','');" &_
		"var_set('first_time', '');" &_
		"sub();" &_
		"return false;" &_
		""" " &_
		" title='Click to add' " &_
		">" &_
		"<img src='" & zicon_add_record & "' border=""0"">Click to Add A New Conference Call</a>" &_
	""
newrec_button_with_context = "" &_
	"<a href=#  " &_
		" onclick=""" &_
		"var_set('active_tab','');"&_
		"var_set('mactive_tab','1');" &_
		"var_set('next_id','NEW');" &_
		"var_set('CAMEFROM','');" &_
		"var_set('first_time', '');" &_
		"sub();" &_
		"return false;" &_
		""" " &_
		" title='Click to add' " &_
		">" &_
		"<img src='" & zicon_add_record & "' border=""0"">Click to Add A New Conference Call for " & zget_table("COMPANIES", "COMPANY_NAME", "RECORD_STATUS='CURRENT' AND COMPANY_ID='" & zget_session("CompanyID") & "'") & "</a>" &_
	""
	'Commented out since not in use; uncomment and add to worklist button if the worklist should be by analyst
	'data_entry_input &_
	'"<br><br>" &_
worklist_callback_button = "" &_
	"<br><br>" &_
	"<a href=#  " &_
		" onclick=""" &_
		"var_set('active_tab','');"&_
		"var_set('mactive_tab','1');" &_
		"var_set('next_id','');" &_
		"var_set('worklist','1');" &_
		"var_set('first_time', '');" &_
		"var_set('new_filter', 'Y');" &_
		"var_set('filters_set', '');" &_
		"sub();" &_
		"return false;" &_
		""" " &_
		" title='Worklist for callbacks' " &_
		">" &_
		"<img src='" & zicon_worklist & "' border=""0"">WORKLIST FOR CALLBACKS</a>" &_
	""
worklist_one_click_link_button = "" &_
	"<br><br>" &_
	"<a href=#  " &_
		" onclick=""" &_
		"var_set('active_tab','');"&_
		"var_set('mactive_tab','1');" &_
		"var_set('next_id','');" &_
		"var_set('worklist','2');" &_
		"var_set('first_time', '');" &_
		"var_set('new_filter', 'Y');" &_
		"var_set('filters_set', '');" &_
		"sub();" &_
		"return false;" &_
		""" " &_
		" title='Worklist for one click links' " &_
		">" &_
		"<img src='" & zicon_worklist & "' border=""0"">WORKLIST FOR ONE CLICK LINKS</a>" &_
	""
submit_button0 = submit_button_hide(zicon_done_on,"var_set('done','Y');var_set('no_edit_country','');")
show_parsed_text_btn = "<span id=""news_icon_wrapper"" style=""filter: grayscale(100%);"" onclick=""displayNewsStoryInPage('" & parsed_text_url & "')"">" & zimg_news & "</span>"
show_parsed_text_btn_old_format = "<span id=""news_icon_wrapper_old_format"" onclick=""displayNewsStoryOldFormat()"">" & zimg_news & "</span>"
'-------------------------------------------------------------
'
'	Main Program
'
first_time = zrequest_form("first_time")
screen_status = screen_ok 
no_edit = false
if zrequest("no_edit") = "Y" then no_edit = true
if zrequest("no_edit_country") = "Y" then no_edit = true
clear_cat
this_worklist = zrequest("worklist")
this_camefrom = zrequest("camefrom")
if this_camefrom = "HOME_LIST" and pam_ref <> "" then 
	news_story_text = display_story(edm_readable_directory & pam_ref & ".html")
	news_story_text = replace(news_story_text, "<link rel=""stylesheet"" href=""\\codeserver\0WSH\ws_test\css\parser_keywords.css"">", "")
	news_story_text = 	"<div id=""news_story_text__inner"">" &_
							news_story_text &_
						"</div>"
	response.write "<div id=""news_story_text"" style=""display:none;"">" & news_story_text & "</div>"
	news_story_old_format = "<div id=""news_story_old_format__inner"">" &_ 
								display_original_source_format(edm_processed_directory & pam_ref & ".xml") &_
							"</div>"
	' news_story_old_format = display_original_source_format(edm_processed_directory & pam_ref & ".xml")
	response.write "<div id=""news_story_old_format"" style=""display:none;"">" & news_story_old_format & "</div>"
end if
if this_worklist <> "" and isblank(this_id) then 
	mactive_tab = 0
	first_id = ""
	xnumber_listed = 0
	generate_worklist this_worklist
	mtab(1) = get_cat
	select case(this_worklist)
		case "1"
			mtab_title(1) = "Callback Worklist"
		case "2"
			mtab_title(1) = "One Click Worklist"
		case else
			mtab_title(1) = "Worklist"
	end select		
elseif isblank(this_id) then 
	first_id = ""
	xnumber_listed = 0
	list_selected
	mtab(1) = get_cat
	mtab_title(1) = "Record List"
elseif isblank(zrequest_form("first_time")) then 
	get_record
	show_screen img(zicon_edit) 
	zfinal_script = "activate_tab('');"
else
	get_record
	get_screen
	if no_edit then
		' No Editing requested - redisplay the screen
		show_screen img(zicon_edit)
		zfinal_script = "activate_tab('');"	
	else
		' Normal processing
		check_screen
		'br screen_status
		if screen_status = screen_ok and no_edit = false then
			put_record
			screen_message = "<span style=''><b>CONF_CALLS Updated at " & znow() & "</span>" 
			zfinal_script = "activate_tab('1');"
			'::go back to homelist if that's your work flow
			if ucase(zrequest("camefrom")) = "HOME_LIST" then 
				' Set ConnS3 = Server.CreateObject("ADODB.Connection")
				' Set xrs = Server.CreateObject("ADODB.RecordSet")
				' connS3.Open connStrS3
				sql = "select priority, priority_reason from earnings_dates where pam_ref = '" & pam_ref & "'"
				xrs.open sql, connection,3,3
				if instr(1, xrs("priority_reason") , " NEWS") <> 0 and xrs("priority") >= 900 then 
					if xrs("priority") >= 1800 then
						xrs("priority") = xrs("priority") - 900
					else
						xrs("priority_reason") = replace(xrs("priority_reason"), " NEWS", "")
						xrs("priority") = xrs("priority") - 900 
					end if
					xrs.update
				end if
				xrs.close
				' conns3.close
				connection.close
				response.redirect "info1.asp?companyid=" & this_company_id
				' response.redirect "home_list.asp"
			end if
			'::Uncomment the next two lines to leave the record displayed on the page
			'show_screen img(zicon_edit) & screen_message
			'zfinal_script = "activate_tab('');"
			'::The following lines return to the listing
			if zrequest("next_id") = "NEW" then 
				cat_BR newrec_button0 				
				if worklist_support then cat_BR worklist_callback_button
				cat_BR ""
				'cat_BR "", tdf(xbold,mo("Data Entry",""))& tdf("",drop_listf("data_entry", this_data_entry,data_entry_list, "style='width:280px;'")) 
				zfinal_script = "activate_tab('1');"
				mtab(1) = get_cat
				mtab_title(1) = "Record List"
			else
				first_id = ""
				xnumber_listed = 0
				'
				'	decide if we did a list-select or a worklist
				if zrequest("filters_set") = "Y" and this_worklist = "" then
					list_selected
					mtab(1) = get_cat
					mtab_title(1) = "Record List"
					mactive_tab = "1"
				elseif NOT(isblank(this_worklist)) then
						mactive_tab = 0
						first_id = ""
						xnumber_listed = 0
						generate_worklist this_worklist
						mtab(1) = get_cat
						select case(this_worklist)
							case "1"
								mtab_title(1) = "Callback Worklist"
							case "2"
								mtab_title(1) = "One Click Worklist"
							case else
								mtab_title(1) = "Worklist"
						end select		
				else
					first_id = ""
					xnumber_listed = 0
					generate_worklist 1
					mtab(1) = get_cat
					mtab_title(1) = "Past end/tender expiration dates"
					zfinal_script = "activate_tab('');" &_
						""
					this_id = ""
				end if
			end if
		else
			' Problem with screen
			screen_message = "<span style='color:red'><b>Please correct the errors/<span style='color:#808000;'>warnings</span:</span>" 
			show_screen img(zicon_error) & screen_message
			zfinal_script = "activate_tab('');"
		end if
	end if
end if
cr		hiddenf("no_edit", "") &_
		hiddenf("no_edit_country", zrequest("no_edit_country")) &_
		hiddenf("next_id", this_id)  &_
		hiddenf("new_filter", "") &_
		hiddenf("history", zrequest("history")) &_
		hiddenf("worklist", zrequest("worklist")) &_
		""
%>
<!-- M I D D L E  C O N T E N T -->	
<div id="col-mid" class="green"><!-- start of middle -->
<%
if the_ribbon <> "" then 
	cr "<div id='ribbon' style='width:450px; height:40px;z-index:1000;'>"
	cr the_ribbon
	cr "</div>"
	cr "<div id='mtabs' style='width:805px;background-color:#EFEFF7;" &_
			"border-top:1px solid #EFEFF7;" &_
			"border-top-right-radius:5px;" &_
			"border-top-left-radius:0px;" &_
			"border-left:1px solid #CCCCCC;" &_
			"border-right:1px solid #EFEFF7;" &_
			"'>"
else
	cr "<div id='mtabs' " &_
			"'>"
end if
found_mactive_tab = false
if mactive_tab = "" then mactive_tab = FCINT(zrequest("mactive_tab"))
dim mtab_active(10)
for ct = 1 to 10
	mtab_active(ct) = ""
	if ct = mactive_tab  then 
		mtab_active(ct) = " active"
		found_mactive_tab = true
		exit for
	end if
next
if not(found_mactive_tab) then mtab_active(1) = " active"
cr "	<div class='tab_row' style='width:700px;'>"
for ct = 1 to 10
	if mtab(ct) <> ""  or ct = 1 then 
		if mtab_title(ct) = "HISTORY" then 
			cr "	<a href='#' " &_
				" onclick=""history_helper('conf_calls');activate_mtab(" & ct & ");return false;"" " &_
				" name='mtab_" & ct & "' id='mtab_" & ct & "'  class='mtab" & mtab_active(ct) & "'><span class='left'></span><span " & mtab_err(ct) & ">" & mtab_title(ct) & "</span><span class='right'></span></a>"
	
		elseif mtab_title(ct) = "ALL&nbsp;CONF&nbsp;CALLS" then 
			cr "	<a href='#' " &_
				" onclick=""all_conf_calls_helper();activate_mtab(" & ct & ");return false;"" " &_
				" name='mtab_" & ct & "' id='mtab_" & ct & "'  class='mtab" & mtab_active(ct) & "'><span class='left'></span><span " & mtab_err(ct) & ">" & mtab_title(ct) & "</span><span class='right'></span></a>"
		else
			cr "	<a href='#' name='mtab_" & ct & "' id='mtab_" & ct & "'  class='mtab" & mtab_active(ct) & "'><span class='left'></span><span " & mtab_err(ct) & ">" & mtab_title(ct) & "</span><span class='right'></span></a>"
		end if
	end if
next
cr "	</div> <!-- end of tab_row -->"
cr "	<!-- m T A B    C O N T E N T -->"
for ct = 1 to 10
	if mtab(ct) <> "" or ct = 1 then cr show_mtab(ct, mtab(ct), mtab_active(ct))
next
cr	"</div> <!-- E N D   m  T A B   C O N T E N T -->" 
connection.close
'------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
'
'	G E T _ R E C O R D
'
sub get_record()
	zcp "get_record START"
	if this_id = "NEW" or this_id = "" then
		this_id = "NEW"
		this_created_by = zthis_login
		this_created = ""
		this_updated_by = this_created_by
		this_updated = this_created
		this_event_id = znew_id("CONF_CALLS", 1, 0)
		if this_company_id <> "" then
			this_stock_symbol = zget_table("COMPANIES", "STOCK_SYMBOL", "RECORD_STATUS='CURRENT' AND COMPANY_ID='" & this_company_id & "'")
			this_company_name = zget_table("COMPANIES", "COMPANY_NAME", "RECORD_STATUS='CURRENT' AND COMPANY_ID='" & this_company_id & "'")
			this_ISIN = zget_table("COMPANIES", "ISIN", "RECORD_STATUS='CURRENT' AND COMPANY_ID='" & this_company_id & "'")
				
		end if	
	else
		xsql_rec = "SELECT top(1) * from CONF_CALLS WHERE id = '" & this_id & "'"
		rs_CONF_CALLS.open xsql_rec, connection, 3, 3
		if (rs_CONF_CALLS.eof) then 
			br "Error: CONF_CALLS ID not found - " & this_id
			rs_CONF_CALLS.close
			response.end
		else
			this_updated_by = zthis_login
			this_updated = znow()
			this_id = rs_CONF_CALLS("id")
			this_record_status = rs_CONF_CALLS("record_status")
			this_event_id = rs_CONF_CALLS("event_id")
			this_status = rs_CONF_CALLS("status")
			this_company_id = rs_CONF_CALLS("company_id")
			this_stock_symbol = rs_CONF_CALLS("stock_symbol")
			this_company_name = rs_CONF_CALLS("company_name")
			this_stock_exchange = rs_CONF_CALLS("stock_exchange")
			this_quarter = rs_CONF_CALLS("quarter")
			this_fiscal_year = rs_CONF_CALLS("fiscal_year")
			this_live_call_datetime = rs_CONF_CALLS("live_call_datetime")
			if this_status = "PENDING_REVIEW" then this_live_call_datetime = ""
			this_live_number = rs_CONF_CALLS("live_number")
			this_live_passcode = rs_CONF_CALLS("live_passcode")
			this_live_intl_number = rs_CONF_CALLS("live_intl_number")
			this_live_intl_passcode = rs_CONF_CALLS("live_intl_passcode")
			this_live_url = rs_CONF_CALLS("live_url")
			this_one_click_link = rs_CONF_CALLS("one_click_link")
			this_live_pwebsite = rs_CONF_CALLS("live_pwebsite")
			this_replay_start_datetime = rs_CONF_CALLS("replay_start_datetime")
			this_replay_end_date = rs_CONF_CALLS("replay_end_date")
			this_replay_number = rs_CONF_CALLS("replay_number")
			this_replay_reservation_id = rs_CONF_CALLS("replay_reservation_id")
			this_replay_passcode = rs_CONF_CALLS("replay_passcode")
			this_replay_url = rs_CONF_CALLS("replay_url")

			this_display_on_WL = rs_CONF_CALLS("Display_on_WL")
			this_live_registration_url = rs_CONF_CALLS("live_registration_url")
			this_replay_pwebsite = rs_CONF_CALLS("replay_pwebsite")
			this_callback_date = rs_CONF_CALLS("callback_date")
			this_notes = rs_CONF_CALLS("notes")
			this_external_notes = rs_CONF_CALLS("external_notes")
			this_ISIN = rs_CONF_CALLS("ISIN")
			this_qaed = rs_CONF_CALLS("qaed")
			this_qaed_by = rs_CONF_CALLS("qaed_by")
			this_qa_flag = rs_CONF_CALLS("qa_flag")
			this_qa_notes = rs_CONF_CALLS("qa_notes")
			this_event_type = rs_CONF_CALLS("event_type")
			this_source_id = rs_CONF_CALLS("source_id")
			this_source_code = rs_CONF_CALLS("source_code")
			this_source_file = rs_CONF_CALLS("source_file")
			this_created = rs_CONF_CALLS("created")
			this_created_by = rs_CONF_CALLS("created_by")
			this_updated = rs_CONF_CALLS("updated")
			this_updated_by = rs_CONF_CALLS("updated_by")
			this_rebroadcast_enddate= rs_CONF_CALLS("rebroadcast_enddate")
			this_country = rs_CONF_CALLS("country")
			if rs_CONF_CALLS("counter_1CL") <> null then
				this_counter_1CL = rs_CONF_CALLS("counter_1CL")
			else
				this_counter_1CL = determine_counter_1CL_value(this_company_id,this_created,true)
			end if
			if zget_table("COMPANIES", "WW_STATUS", "RECORD_STATUS='CURRENT' AND COMPANY_ID='" & this_company_id & "'") = "WW" then
				this_country_code = rs_CONF_CALLS("country_code")
				this_time_zone = rs_CONF_CALLS("time_zone")
			else
				this_country_code = "UNITED_STATES_EAST"
				this_time_zone = rs_CONF_CALLS("time_zone")
			end if
			this_utc_offset = rs_CONF_CALLS("utc_offset")
			this_iso_country_code = rs_CONF_CALLS("iso_country_code")
		end if
		rs_CONF_CALLS.close
		if this_status="HISTORICAL" then
			this_edate = zget_table("results", "announce_datetime", "company_id='" & this_company_id & "' and quarter='" & this_quarter & "'  and fiscal_year='" & this_fiscal_year & "' and record_status='CURRENT'")
			if this_edate = "?UNKNOWN?" then this_edate = null
			this_tod = ""
			this_edate_status = ""
			this_date_desc = "RESULTS ANNOUNCE DATETIME: " 
		else
			this_edate = zget_table("earnings_dates", "earnings_date", "company_id='" & this_company_id & "' and record_status = 'CURRENT' and status = 'ACTIVE'")
			this_tod = zget_table("earnings_dates", "time_of_day", "company_id='" & this_company_id & "' and record_status = 'CURRENT' and status = 'ACTIVE'")
			this_edate_status = zget_table("earnings_dates", "earnings_date_status", "company_id='" & this_company_id & "' and record_status = 'CURRENT' and status = 'ACTIVE'")
			this_date_desc = "CURRENT ED: " 
		end if
		if pam_processing then 
			'br "Retriving from PAM"
			Set ConnS3 = Server.CreateObject("ADODB.Connection")
			Set pam_RS = Server.CreateObject("ADODB.RecordSet")
			connS3.Open connStrS3
			SQL = "Select top(1)  " &_
				"fixed_notes," &_
				"fixed_conf_notes," &_
				"fixed_cc_date," &_
				"fixed_cc_tod," &_
				"fixed_cc_phone1," &_
				"fixed_cc_passcode1," &_
				"fixed_cc_url," &_
				"fixed_cc_phone2," &_
				"fixed_cc_passcode2," &_
				"fixed_cc_url2," &_
				"fixed_goto_broadcast_ends," &_
				"fixed_cc_phone3," &_
				"fixed_cc_passcode3," &_
				"fixed_cc_replay_starts," &_
				"fixed_goto_reserv_num," &_
				"fixed_cc_replay_ends," &_
				"g_notes," &_
				"cc_date," &_
				"cc_tod," &_
				"cc_phone1," &_
				"cc_passcode1," &_
				"cc_url," &_
				"cc_phone2," &_
				"cc_passcode2," &_
				"cc_url2," &_
				"cc_phone3," &_
				"cc_passcode3," &_
				"cc_replay_starts," &_
				"cc_replay_ends " &_
					" from PAM where g_story_ref='" & pam_ref & "'"
			'br "::PAM:" & sql
			pam_RS.open sql, connS3,3,3
			ccupdate = znow()
			if ucase(this_camefrom) = "HOME_LIST" then
				old_notes = this_notes
				old_cc_date = this_cc_date
				old_cc_tod = this_cc_tod
				old_live_call_datetime = old_cc_date & " " & old_cc_tod
				old_live_number = this_live_number
				old_live_passcode = this_live_passcode
				old_live_url = this_live_url
				old_live_url = this_live_url
				old_live_intl_number = this_live_intl_number
				old_live_intl_passcode = this_live_intl_passcode
				old_replay_url = this_replay_url


				old_live_registration_url = this_live_registration_url

				old_replay_number = this_replay_number
				old_replay_passcode = this_replay_passcode
				old_replay_start_datetime = this_replay_start_datetime
				old_replay_end_date = this_replay_end_date
				' 
				if this_notes = "" then this_notes = pam_rs("g_notes")
				if this_cc_date = "" then this_cc_date = pam_rs("cc_date")
				if this_cc_tod = "" then this_cc_tod = pam_rs("cc_tod")
				this_live_call_datetime = this_cc_date & " " & this_cc_tod
				' br "this_cc_date: " & this_cc_date
				' br "this_live_call_datetime: " & this_live_call_datetime
				' if this_live_call_datetime = "" then this_live_call_datetime = pam_rs("cc_date")
				if this_live_number = "" then this_live_number = pam_rs("cc_phone1")
				if this_live_passcode = "" then this_live_passcode = pam_rs("cc_passcode1")
				' if this_live_url = "" then this_live_url = trim(pam_rs("cc_url")) & ""
				if this_live_url = "" then live_broadcast = "http://"	
				' International
				if this_live_intl_number = "" then this_live_intl_number = trim(pam_rs("cc_phone2"))
				if this_live_intl_passcode = "" then this_live_intl_passcode = pam_rs("cc_passcode2")
				' Replay
				' if this_replay_url = "" then this_replay_url = trim(pam_rs("cc_url2")) & ""
				if this_replay_url = "" then goto_broadcast = "http://"

				if this_replay_number = "" then this_replay_number = trim(pam_rs("cc_phone3"))
				if this_replay_passcode = "" then this_replay_passcode = pam_rs("cc_passcode3")
				if this_replay_start_datetime = "" then this_replay_start_datetime =pam_rs("cc_replay_starts")
				if this_replay_end_date = "" then this_replay_end_date = pam_rs("cc_replay_ends")	
			else
				this_notes = pam_rs("fixed_notes")
				this_external_notes = pam_rs("fixed_conf_notes")
				this_cc_date = pam_rs("fixed_cc_date")
				this_cc_tod = pam_rs("fixed_cc_tod")
				this_live_call_datetime = this_cc_date & " " & this_cc_tod
				' this_live_call_datetime = pam_rs("fixed_cc_date")
				conferencecalltime = pam_rs("fixed_cc_tod")
				this_live_number = pam_rs("fixed_cc_phone1")
				this_live_passcode = pam_rs("fixed_cc_passcode1")
				this_live_url = trim(pam_rs("fixed_cc_url")) & ""
				if this_live_url = "" then live_broadcast = "http://"	
				' International
				this_live_intl_number = trim(pam_rs("fixed_cc_phone2"))
				this_live_intl_passcode = pam_rs("fixed_cc_passcode2")
				' Replay
				this_replay_url = trim(pam_rs("fixed_cc_url2")) & ""
				if this_replay_url = "" then goto_broadcast = "http://"
				this_rebroadcast_enddate =pam_rs("fixed_goto_broadcast_ends")
				this_replay_number = trim(pam_rs("fixed_cc_phone3"))
				this_replay_passcode = pam_rs("fixed_cc_passcode3")
				this_replay_start_datetime =pam_rs("fixed_cc_replay_starts")
				this_replay_reservation_id = pam_rs("fixed_goto_reserv_num")
				this_replay_end_date = pam_rs("fixed_cc_replay_ends")	
			end if
			pam_rs.close
			conns3.close
		end if
	end if
	cr hiddenf("this_edate", this_edate)
	cr hiddenf("pam_ref", pam_ref)
	zcp "get_record END"
	zlock_company this_company_id, zthis_login
end sub
'
'	P U T _ R E C O R D
'
sub put_record()
	xold_id = this_id
	if this_id = "NEW" or  this_id = "" then
		xaction = "NEW"
		
		
		xsql_rec = "select * from CONF_CALLS WHERE event_id='" & this_event_id & "'"
		rs_CONF_CALLS.open xsql_rec, connection, 3, 3
		if rs_CONF_CALLS.eof then 
			rs_CONF_CALLS.addnew
		else
			cr "<span style='color:red;'><b>This would have resulted in a duplicate record; no work was done for event_id='" & this_event_id & "'; Please contact Gerry</b></span>" 
			rs_CONF_CALLS.close
			connection.close
			response.end
		end if
		' These will populate into the new record
		this_created = znow()
		this_created_by = zthis_login
		this_updated = this_created
		this_updated_by = this_created_by
	else
		xaction = "UPDATE"
		'	Retrieve the old record
		xsql_rec = "select top(1) * " &_
				" from CONF_CALLS WHERE id='" & this_id & "'"
		old_CONF_CALLS.open xsql_rec, connection, 3, 3
		if this_QA_flag <> "" then
			if isnotblank(zscreen__updates) and this_QA_flag = "P" then this_QA_flag = "PC"
			old_CONF_CALLS("QA_flag") = this_QA_flag
			old_CONF_CALLS("QAed") = znow()
			old_CONF_CALLS("QAed_by") = zthis_login
			old_CONF_CALLS("QA_notes") = mid(this_QA_notes,1,old_CONF_CALLS("QA_notes").DefinedSize )
			old_CONF_CALLS.update
			if this_QA_flag = "P" then 
				zunlock_event_id old_CONF_CALLS("event_id")
				old_CONF_CALLS.close
				exit sub
			end if
		end if
		'
		'	Add the new record
		xsql_rec = "select top(1) * from CONF_CALLS WHERE 1=2"
		rs_CONF_CALLS.open xsql_rec, connection, 3, 3
		rs_CONF_CALLS.addnew
		'
		'	Preserve the old values
		For xct = 0 To rs_CONF_CALLS.fields.count -1
			if rs_CONF_CALLS.fields(xct).Properties("ISAUTOINCREMENT") and rs_CONF_CALLS.fields(xct).Properties("KEYCOLUMN") Then
				' skip it because it's an identity field
			else
				rs_CONF_CALLS.Fields(xct).value = old_CONF_CALLS.fields(xct).value
			end if
		Next
		this_created = old_CONF_CALLS("created")
		this_created_by = old_CONF_CALLS("created_by")
		this_updated = znow()
		this_updated_by = zthis_login
	end if
	'
	'	Update the record with the screen info
	this_record_status = "CURRENT"
	this_event_type = "CONF_CALLS"
	this_source_code = "WSHI"	' Overwrite if this is not appropriate
	this_source_id = zget_table("source_table", "source_id", "[source_code]='" & this_source_code & "'") 
	this_source_file = "WSH"
	this_stock_exchange = zget_table("COMPANIES", "stock_exchANGE", "RECORD_STATUS='CURRENT' AND COMPANY_ID='" & this_company_id & "'")	
	'
	rs_CONF_CALLS("record_status") = mid(this_record_status,1,rs_CONF_CALLS("record_status").definedsize)
	rs_CONF_CALLS("event_id") = mid(this_event_id,1,rs_CONF_CALLS("event_id").definedsize)
	rs_CONF_CALLS("status") = mid(this_status,1,rs_CONF_CALLS("status").definedsize)
	rs_CONF_CALLS("company_id") = this_company_id
	rs_CONF_CALLS("stock_symbol") = mid(this_stock_symbol,1,rs_CONF_CALLS("stock_symbol").definedsize)
	rs_CONF_CALLS("company_name") = mid(this_company_name,1,rs_CONF_CALLS("company_name").definedsize)
	rs_CONF_CALLS("stock_exchange") = mid(this_stock_exchange,1,rs_CONF_CALLS("stock_exchange").definedsize)
	rs_CONF_CALLS("quarter") = mid(this_quarter,1,rs_CONF_CALLS("quarter").definedsize)
	rs_CONF_CALLS("fiscal_year") = mid(this_fiscal_year,1,rs_CONF_CALLS("fiscal_year").definedsize)
	if isblank(	this_live_call_datetime ) then this_live_call_datetime = null ' fix datetime
	rs_CONF_CALLS("live_call_datetime") = this_live_call_datetime
	rs_CONF_CALLS("live_number") = mid(this_live_number,1,rs_CONF_CALLS("live_number").definedsize)
	rs_CONF_CALLS("live_passcode") = mid(this_live_passcode,1,rs_CONF_CALLS("live_passcode").definedsize)
	rs_CONF_CALLS("live_intl_number") = mid(this_live_intl_number,1,rs_CONF_CALLS("live_intl_number").definedsize)
	rs_CONF_CALLS("live_intl_passcode") = mid(this_live_intl_passcode,1,rs_CONF_CALLS("live_intl_passcode").definedsize)
	rs_CONF_CALLS("live_url") = mid(this_live_url,1,rs_CONF_CALLS("live_url").definedsize)
	rs_CONF_CALLS("one_click_link") = this_one_click_link
	rs_CONF_CALLS("Display_on_WL") = this_Display_on_WL
	rs_CONF_CALLS("live_pwebsite") = mid(zPurl(this_live_url),1,rs_CONF_CALLS("live_pwebsite").definedsize)
	if isblank(	this_replay_start_datetime ) then this_replay_start_datetime = null ' fix datetime
	rs_CONF_CALLS("replay_start_datetime") = this_replay_start_datetime
	if isblank(	this_replay_end_date ) then this_replay_end_date = null ' fix datetime
	rs_CONF_CALLS("replay_end_date") = this_replay_end_date
	rs_CONF_CALLS("replay_number") = mid(this_replay_number,1,rs_CONF_CALLS("replay_number").definedsize)
	rs_CONF_CALLS("replay_reservation_id") = mid(this_replay_reservation_id,1,rs_CONF_CALLS("replay_reservation_id").definedsize)
	rs_CONF_CALLS("replay_passcode") = mid(this_replay_passcode,1,rs_CONF_CALLS("replay_passcode").definedsize)
	rs_CONF_CALLS("replay_url") = mid(this_live_url,1,rs_CONF_CALLS("replay_url").definedsize) 
	rs_CONF_CALLS("Counter_1CL") = this_counter_1CL
	rs_CONF_CALLS("live_registration_url") = mid(this_live_registration_url,1,rs_CONF_CALLS("live_registration_url").definedsize) 
	rs_CONF_CALLS("replay_pwebsite") = mid(zPurl(this_live_url),1,rs_CONF_CALLS("replay_pwebsite").definedsize) 'now set to be = live_url
	if isblank(this_callback_date) then this_callback_date = null ' fix datetime
	rs_CONF_CALLS("callback_date") = this_callback_date
	rs_CONF_CALLS("notes") = mid(this_notes,1,rs_CONF_CALLS("notes").definedsize)
	rs_CONF_CALLS("external_notes") = mid(this_external_notes,1,rs_CONF_CALLS("external_notes").definedsize)
	rs_CONF_CALLS("ISIN") = mid(this_ISIN,1,rs_CONF_CALLS("ISIN").definedsize)
	if this_qaed = "" then this_qaed = null
	rs_CONF_CALLS("event_type") = mid(this_event_type,1,rs_CONF_CALLS("event_type").definedsize)
	rs_CONF_CALLS("source_id") = mid(this_source_id,1,rs_CONF_CALLS("source_id").definedsize)
	rs_CONF_CALLS("source_code") = mid(this_source_code,1,rs_CONF_CALLS("source_code").definedsize)
	rs_CONF_CALLS("source_file") = mid(this_source_file,1,rs_CONF_CALLS("source_file").definedsize)
	if isblank(	this_created ) then this_created = null ' fix datetime
	rs_CONF_CALLS("created") = this_created
	rs_CONF_CALLS("created_by") = mid(this_created_by,1,rs_CONF_CALLS("created_by").definedsize)
	if isblank(	this_updated ) then this_updated = null ' fix datetime
	rs_CONF_CALLS("updated") = znow()
	rs_CONF_CALLS("updated_by") = zthis_login
	rs_CONF_CALLS("qa_flag") = ""
	rs_CONF_CALLS("qaed") = null
	rs_CONF_CALLS("qaed_by") = ""
	rs_CONF_CALLS("qa_notes") = ""
	xv_ldesc = zget_table("validation","v_ldesc"," v_code='" & THIS_country_code & "'")
	this_iso_country_code = get_tag("iso_country_code", xv_ldesc)
	this_utc_offset =  get_tag("gmt_offset", xv_ldesc)
	this_country = zget_table("validation","v_desc"," v_code='" & this_country_code & "'")
	rs_CONF_CALLS("country") = this_country 
	rs_CONF_CALLS("country_code") = this_country_code 
	rs_CONF_CALLS("utc_offset") = this_utc_offset 
	rs_CONF_CALLS("time_zone") = this_time_zone
	rs_CONF_CALLS("iso_country_code") = this_iso_country_code 
	if isblank(	this_rebroadcast_enddate ) then this_rebroadcast_enddate = null ' fix datetime
	rs_CONF_CALLS("rebroadcast_enddate") = this_rebroadcast_enddate
	rs_CONF_CALLS.update
	rs_CONF_CALLS.close
	'
	'	Get the new key
	set xrs_id = connection.Execute( "SELECT @@IDENTITY" ) 
	this_id = xrs_id(0)
	xrs_id.Close
	if xaction = "UPDATE" then
		'
		'	Mark the old record as PREV
		old_CONF_CALLS("record_status") = "PREV"
		old_CONF_CALLS.update
		old_CONF_CALLS.close	
		'
		'	Retire any other records with the same event_id	
		if trim(this_id & "") <> "" and trim(this_id & "") <> trim(xold_id & "") then 
			xsql_rec = "select  " &_
				"record_status" &_
					" from CONF_CALLS WHERE event_id='" & this_event_id  & "' and  id<>'" & this_id & "' and record_status <> 'PREV' "
			old_CONF_CALLS.open xsql_rec, connection, 3, 3
			while not(old_CONF_CALLS.eof)
				old_CONF_CALLS("record_status") = "PREV"
				old_CONF_CALLS.update
				old_CONF_CALLS.movenext
			wend
			old_CONF_CALLS.close
		end if
	end if
	' update likely_one_click_link in companies table
	Dim likely_one_click_link, xsql_one_click, xsql_companies
	likely_one_click_link = "N"
	if this_one_click_link = "Y" then
		likely_one_click_link = "Y"
	else
		xsql_one_click = "SELECT one_click_link FROM CONF_CALLS " &_
						"WHERE company_id = '" & this_company_id & "' " &_
						"AND live_call_datetime > '" & fcdate(today) - 365  & "' " &_
						"AND status <> 'DISABLED' " &_
						"AND status <> 'PENDING_REVIEW' " &_
						"AND record_status = 'CURRENT' " &_
						""
		rs_CONF_CALLS.open xsql_one_click, connection, 3, 3
		while not rs_CONF_CALLS.EOF
			if rs_CONF_CALLS("one_click_link") = "Y" then likely_one_click_link = "Y"
			rs_CONF_CALLS.movenext
		wend
		rs_CONF_CALLS.close
	end if
	xsql_companies = "SELECT likely_one_click_link FROM companies WHERE company_id = '" & this_company_id & "'  and record_status = 'CURRENT'"
	rs_companies.open xsql_companies, connection, 3, 3
	rs_companies("likely_one_click_link") = likely_one_click_link
	rs_companies.update
	rs_companies.close
	right_now = znow()
	'promote_CONF_CALLS	
	if this_create_parser_ticket = "Y" and isnotblank(this_parser_ticket_description) then
		create_bad_parser_ticket pam_ref, this_parser_ticket_description, this_event_id
	end if
	update_fields_inline "EURLS", "Company_Id='" & this_company_id  & "' and record_status='current'", "EURL_PENDING/N}", false
	zunlock_company this_company_id
	zunlock_event_id this_event_id
	if zrequest("worklist") = "2" then this_id=""    'this is required to prevent the QA screen from appearing during work with the one-click worklist - ticket 27276
end sub
'
'	G E T _ S C R E E N
'
sub get_screen()
	this_qa_onscreen = zrequest("qa_onscreen")
	this_id = zrequest("id")
	this_record_status = zrequest("record_status")
	this_event_id = zrequest("event_id")
	this_status = zrequest("status")
	this_company_id = zrequest("company_id")
	this_stock_symbol = zrequest("stock_symbol")
	this_company_name = zrequest("company_name")
	this_stock_exchange = zrequest("stock_exchange")
	this_quarter = zrequest("quarter")
	this_fiscal_year = zrequest("fiscal_year")
	this_live_call_datetime = zrequest("live_call_datetime")
	this_live_number = zclean(zrequest("live_number"))
	this_live_passcode = zclean(zrequest("live_passcode"))
	this_live_intl_number = zclean(zrequest("live_intl_number"))
	this_live_intl_passcode = zclean(zrequest("live_intl_passcode"))
	this_live_url = zclean(zrequest("live_url"))
	this_one_click_link = zclean(zrequest("one_click_link"))
	' this_live_pwebsite = zrequest("live_pwebsite")
	this_replay_start_datetime = zrequest("replay_start_datetime")
	this_replay_end_date = zrequest("replay_end_date")
	this_replay_number = zclean(zrequest("replay_number"))
	this_replay_reservation_id = zclean(zrequest("replay_reservation_id"))
	this_replay_passcode = zclean(zrequest("replay_passcode"))
	this_replay_url = zclean(zrequest("replay_url"))
	' this_replay_pwebsite = zrequest("replay_pwebsite")

	this_live_registration_url = zclean(zrequest("live_registration_url"))

	if this_live_registration_url = "" or this_live_registration_url = null then
		this_Display_on_WL = zrequest("display_on_WL")
	else
		this_Display_on_WL = "N"
	end if

	this_callback_date = zrequest("callback_date")
	this_notes = zclean(zrequest("notes"))
	this_external_notes = zclean(zrequest("external_notes"))
	this_ISIN = zrequest("ISIN")
	this_qaed = zrequest("qaed")
	this_qaed_by = zrequest("qaed_by")
	this_qa_flag = zrequest("qa_flag")
	this_qa_notes = zclean(zrequest("qa_notes"))
	this_event_type = zrequest("event_type")
	this_source_id = zrequest("source_id")
	this_source_code = zrequest("source_code")
	this_source_file = zrequest("source_file")
	this_created = zrequest("created")
	this_created_by = zrequest("created_by")
	this_updated = zrequest("updated")
	this_updated_by = zrequest("updated_by")
	this_rebroadcast_enddate = zrequest("rebroadcast_enddate")
	this_country = zrequest("country")
	this_country_code = zrequest("country_code")
	this_utc_offset = zrequest("utc_offset")
	this_time_zone = zrequest("time_zone")
	this_iso_country_code = zrequest("iso_country_code")
	this_create_parser_ticket = zrequest("create_parser_ticket")
	this_parser_ticket_description = zrequest("parser_ticket_description")
end sub
'
'	C H E C K _ S C R E E N
'
function check_screen()
	zcheck_event_id_lock this_event_id, 1, err_event_id
	if this_qa_onscreen = "Y" then 
		if this_qa_flag = "F" and isblank(ztrim(this_qa_notes)) then l_errf 2,"qa_notes", err_qa_notes, "Cannot be blank if QA Failed"
		if isblank(this_qa_flag) and isnotblank(ztrim(this_qa_notes)) then l_errf 2,"qa_notes", err_qa_notes, "Must be blank if flag is blank"
	end if
	if isblank(this_event_id) then l_errf 1,"event_id", err_event_id, "Cannot be blank"
	if isblank(this_status) then l_errf 1,"status", err_status, "Cannot be blank"
	' if this_status = "PENDING_REVIEW" then  l_errf 1,"status", err_status, "Cannot be PENDING_REVIEW"
	if this_status = "HISTORICAL" and fcdate(this_live_call_datetime) > fcdate(today) then  l_errf 1,"status", err_status, "Cannot be HISTORICAL if in the future"
	if isblank(this_company_id) then l_errf 1,"company_id", err_company_id, "Cannot be blank"
	if isblank(this_country_code) then l_errf 1,"country_code", err_country_code, "Country must be selected"	
	if isblank(this_stock_symbol) then l_errf 1,"stock_symbol", err_stock_symbol, "Cannot be blank"
	if isblank(this_company_name) then l_errf 1,"company_name", err_company_name, "Cannot be blank"
	'if isblank(this_stock_exchange) then l_errf 1,"stock_exchange", err_stock_exchange, "Cannot be blank"
	if isblank(this_quarter) then l_errf 1,"quarter", err_quarter, "Cannot be blank"
	if isblank(this_fiscal_year) then l_errf 1,"fiscal_year", err_fiscal_year, "Cannot be blank"
	if not(isdate(this_live_call_datetime)) and isnotblank(this_live_call_datetime) then l_errf 1,"live_call_datetime", err_live_call_datetime, "Invalid Date"
	if this_status = "PENDING_REVIEW" and isnotblank(this_live_call_datetime) then l_errf 1,"live_call_datetime", err_live_call_datetime, "Must be blank if status is PENDING_REVIEW"
	if this_status <> "DISABLED" and this_status <> "PENDING_REVIEW" and isblank(this_live_call_datetime) then l_errf 1,"live_call_datetime", err_live_call_datetime, "Cannot be blank if status not PENDING_REVIEW"
	check_edate = zget_table("results", "announce_datetime", "company_id='" & this_company_id & "' and record_status = 'Current' and fiscal_year = '" & this_fiscal_year & "' and quarter = '" & this_quarter & "'")
	if check_edate = "?UNKNOWN?" then
		check_edate = null
	else
		if this_status <> "PENDING_REVIEW" and datediff("d",fcdate(this_live_call_datetime),check_edate) > 15 then l_warnf 1, "live_call_datetime", err_live_call_datetime, "WARNING: " & this_live_call_datetime & " is more than 15 days difference from EDate (" & check_edate & ")"
	end if
	if hour(check_edate) = 23 then check_edate = month(check_edate) & "/" & day(check_edate) & "/" & year(check_edate)
	
	if this_status = "PENDING_REVIEW" then
		if isnotblank(this_live_url) then l_errf 1,"live_url", err_live_url, "Must be blank if status is pending_review"
		if isnotblank(this_live_number) then l_errf 1,"live_number", err_live_number, "Must be blank if status is pending_review"
	elseif this_status <> "DISABLED" then
		if isblank(this_live_url) and isblank(this_live_number) then 
			l_errf 1,"live_url", err_live_url, "Must enter either a live url or live number if status is not PENDING_REVIEW"
			l_errf 1,"live_number", err_live_number, "Must enter either a live url or live number if status is not PENDING_REVIEW"
		end if	
	end if
	if isnotblank(this_live_registration_url) then 
		if not(valid_url(this_live_registration_url)) then 
			l_errf 1,"live_registration_url",err_live_registration_url,validate_url(this_live_registration_url)
		else
			if instr(1, this_external_notes, this_live_registration_url,1) = 0 then 
				this_external_notes = this_external_notes & ", Register:" & this_live_registration_url 
				if mid(this_external_notes,1,1) = "," then this_external_notes = trim(mid(this_external_notes,2))
			end if
		end if
	end if
	'if isblank(this_live_pwebsite) then l_errf 1,"live_pwebsite", err_live_pwebsite, "Cannot be blank"
	if this_live_url="" then 
		' l_warnf 1,"live",err_live_url,"live is Blank" 
	else
		if not(valid_url(this_live_url)) then l_errf 1,"live_url",err_live_url,validate_url(this_live_url)
	end if
	if not(isdate(this_replay_start_datetime)) and isnotblank(this_replay_start_datetime) then l_errf 1,"replay_start_datetime", err_replay_start_datetime, "Invalid Date"
	'if isblank(this_replay_start_datetime) then l_errf 1,"replay_start_datetime", err_replay_start_datetime, "Cannot be blank"
	if not(isdate(this_replay_end_date)) and isnotblank(this_replay_end_date) then l_errf 1,"replay_end_date", err_replay_end_date, "Invalid Date"
	validate_start_end_dates dateonly(this_live_call_datetime), dateonly(this_replay_start_datetime),"replay_start_datetime",err_replay_start_datetime,1,"Replay may not be prior to live call."
	validate_start_end_dates this_replay_start_datetime, this_replay_end_date,"replay_start_datetime",err_replay_start_datetime,1,"Replay End may not be prior to Replay Start."
	validate_start_end_dates check_edate,this_live_call_datetime, "live_call_datetime", err_live_call_datetime, 1,"Cannot be prior to the next earnings date (" & check_edate & ")"
	validate_start_end_dates dateonly(this_replay_start_datetime),this_rebroadcast_enddate, "rebroadcast_enddate", err_rebroadcast_enddate, 1,"Rebroadcast End may not be prior to Replay Start ."
	
	if isnotblank(this_live_call_datetime) and not valid_weekday24(this_live_call_datetime) then  l_warnf 1,"live_call_datetime", err_live_call_datetime, this_live_call_datetime & " is a weekend date. Are you sure?"
	
	if this_live_number="" then 
		 if this_live_intl_number <> "" then l_errf 1, "live_number", err_live_number,"Cannot be blank while there is an INTL Number"
	else
		if not valid_phone(this_live_number)then l_errf 1,"live_number", err_live_number,"Invalid phone number"
	end if
	if this_live_intl_number="" then 
		' l_warnf 1, "intl_phone", err_intl_phone,"intl phone number is Blank"
	else
		if not valid_phone(this_live_intl_number)then l_errf 1,"live_intl_number", err_live_intl_number,"Invalid phone number"
	end if
	if this_replay_number="" then 
		' l_warnf 1, "intl_phone", err_intl_phone,"intl phone number is Blank"
	else
		if not valid_phone(this_replay_number)then l_errf 1,"replay_number", err_replay_number,"Invalid phone number"
	end if
	lsql= "select id from CONF_CALLS where company_id='" & this_company_id & "' and quarter='" & this_quarter & "' and fiscal_year='" & this_fiscal_year & "' and event_id <> '" & this_event_id & "' and status<>'DISABLED' and record_status='CURRENT'"
	' br "::Lsql:" & lsql
	rs_CONF_CALLS.open lsql, connection, 3,3
	if not rs_CONF_CALLS.eof then
		l_errf 1,"fiscal_year", err_fiscal_year,"This fiscal year already exists"
		l_errf 1,"quarter", err_quarter,"This fiscal quarter already exists"
	end if 
	'manager check
	rs_CONF_CALLS.close
	'
	'
	'	Validate the freshness of the current record
	'
	'
	xsql = "select top(1) id from CONF_CALLS where event_id='" & this_event_id & "' order by updated desc, id desc"
	xrs.open xsql, connection,3,3
	if not(xrs.eof) then 
		if trim(xrs("id") & "") <> trim(this_id & "") then l_errf 1,"event_id", err_event_id, "A more recent record has been detected.<br> Please reload your record and do your update again <a href='./CONF_CALLS.asp?xevent_id=" & this_event_id & "'>Click here to reload record</a>"
	end if
	xrs.close
end function
'
'	Record an error
'
sub L_errf(xtab, xfld, xerr, xtxt)
	'br "L_errf:" &  xfld & ":" & xtxt 
	brz 2,"L_errf:" &  xfld & ":" & xtxt 
	if zsystem_top <> "CALLERS" then	br "L_errf:" &  xfld & ":" & xtxt 
	xtxt = "<span style='color:red;'><b>" & xtxt & "</b></span>"
	xerr = xerr & "<br>" &_
			xtxt
	screen_status = screen_error
	tab_err = tab_err & "," & xtab
	all_errors = all_errors &_
		"<br><span style='color:red;'>Error - " & xfld & " - " & xtxt  & "</span>"
	sw_buffer = ""
end sub
'
'	Record a warning
'
sub L_warnf(xtab, xfld, xwarn_buffer, xtxt)
	'br "L_warnf:" &  xfld & ":" & xtxt 
	if zsystem_top <> "CALLERS" then	br "L_warnf:" &  xfld & ":" & xtxt 
	sw_buffer = sw_buffer & hiddenf("sw_" & xfld, xtxt)
	if zrequest("sw_" & xfld) <> xtxt  then 
		screen_status = screen_warning
		xtxt = "<span style='color:#808000;'><b>" & xtxt & "</b></span>"
		xwarn_buffer = xwarn_buffer & "<br>" &_
			xtxt
		tab_err = tab_err & "," & xtab
		all_errors = all_errors &_
			"<br><span style='font-color:#808000'>Warning - " & xfld & " - " & xtxt  & "</span>"
	end if
end sub
'
'	S H O W _ S C R E E N
'
sub show_screen(xmessage)
	zcheck_event_id_lock this_event_id, 1, err_event_id
	if instr(1, err_event_id, "Sorry, this event is now locked by ",1) <> 0 then zscreen_mode = "READONLY"
	stickies = "Y"
	if zrequest("worklist") <> "" then 
		xcancel_button = "" &_
			"<a href=#   " &_
				" onclick=""" &_
				"var_set('active_tab','');"&_
				"var_set('mactive_tab','" & zrequest("worklist") & "');" &_
				"var_set('next_id','');" &_
				"var_set('first_time', '');" &_
				"var_set('filters_set', '');" &_
				"var_set('worklist', '" & zrequest("worklist") & "');" &_
				"sub();" &_
				"return false;" &_
				""" " &_
				" title='Click to cancel (changes will be lost)' " &_
				">" &_
				"<img src='" & zicon_cancel_on & "' border=""0""></a>" &_
			""
	else
		xcancel_button = cancel_button0
	end if
	if zrequest("history") = "Y" then submit_button0 = ""
	zcp "make_screen START"
	cr "<script type=""text/javascript"" src=""./js/saver.js?v=6""></script>"
	xbold = "style='font-weight:bold;width:210px;'"
	xblue = "#5178BB"
	for xct = 1 to 10
		mtab_title(xct) = ""
		mtab(xct) = ""
	next
	if screen_status = screen_error then sw_buffer = ""
	cat hiddenf("first_time", "N") &_
		hiddenf("orderby__event_id", zrequest("orderby__event_id")) &_
		hiddenf("orderby__status", zrequest("orderby__status")) &_
		hiddenf("orderby__stock_symbol", zrequest("orderby__stock_symbol")) &_
		hiddenf("orderby__company_name", zrequest("orderby__company_name")) &_
		hiddenf("orderby__quarter", zrequest("orderby__quarter")) &_
		hiddenf("orderby__fiscal_year", zrequest("orderby__fiscal_year")) &_
		hiddenf("orderby__updated", zrequest("orderby__updated")) &_
		hiddenf("orderby__live_call_datetime", zrequest("orderby__live_call_datetime")) &_
		hiddenf("id", this_id) &_
		sw_buffer &_
		""
	'
	'
	'	Make the ribbon
	zcp "make_screen ribbon"
	cat "<table cellspacing=0 " &_
		"style='background-color:#EFEFF7;" &_
		"border-top:1px solid #CCCCCC;" &_
		"border-left:1px solid #CCCCCC;border-top-left-radius:5px;" &_
		"border-right:1px solid #CCCCCC;border-top-right-radius:5px;" &_
		"border-bottom:1px solid #EFEFF7;" &_
		"width:" & screen_width - 500 & "px;'>"
	ribbon_color = "#EFEFF7"
	cat_trf " style='height:40px;background-color:" & ribbon_color & ";'", "" &_
			tdf("", "") &_
			tdf("", xmessage) &_
			""
	cat "</table>"
	the_ribbon = get_cat
	':: note - if you don't want the ribbon:
	' the_ribbon = ""
	xmtab_ct = 0
	'
	'	MTAB 1 - Generic Info
	'
	if this_status = "HISTORICAL" then 
		status_entry = inputRo("status", this_status, "style='width:100px;background-color:#EFEFF7;border=0px;'") & err_status
	else
		status_entry = drop_listf("status", this_status, lstatus_list, "style='width:150px;'") & err_status
	end if	
	'process symbol for correct yahoo link:
	yahoo_symbol = convert_symbol_yahoo(this_stock_symbol)
	'
	'	IR Website
	xpop_company_website = "onclick= "" pop_url('company_website');return false;"" "	
	this_company_website =  get_company_website(this_company_website, this_stock_symbol,zrequest("company_website"))
	if this_company_website = "" then xcompany_website_style = "style='display:none;'"
	'process records differently for US and CAD
	'This will affect the links
	if this_stock_symbol <> "" then	
		'	tmx Website
		'
		xpop_tmx_website = "onclick= "" pop_url('tmx_website');return false;"" "	
		xww_website_style = "style='display:none;'"
		if zget_table("companies","ww_status","RECORD_STATUS='CURRENT' AND [STOCK_SYMBOL]='" & this_stock_symbol & "'") = "WW" then
			xpop_ww_website = "onclick= "" pop_url('ww_website');return false;"" "	
			if this_ww_website = "" and this_stock_symbol <> "" then _
			this_ww_website = zget_table("COMPANIES", "WW_EXCHANGE_LINK", "RECORD_STATUS='CURRENT' AND [STOCK_SYMBOL]='" & this_stock_symbol & "'")
			if this_ww_website = "" or this_ww_website= "?UNKNOWN?" then this_ww_website = zrequest("ww_website")	
			if this_ww_website <> "" then xww_website_style = ""
		else
			if this_country_code = "" then this_country_code = "UNITED_STATES_EAST"
		end if	
		
		'	sedar Website
		xpop_sedar_issuer_number = "onclick= "" pop_url('sedar_issuer_number');return false;"" "	
		if (this_sedar_issuer_number = "" or isnull(this_sedar_issuer_number)) and mid(this_stock_symbol,1,3) =  "CA:" then this_sedar_issuer_number = zget_table("COMPANIES", "SEDAR_ISSUER_NUMBER", "RECORD_STATUS='CURRENT' AND [STOCK_SYMBOL]='" & this_stock_symbol & "'")
		if this_sedar_issuer_number = "" or this_sedar_issuer_number= "?UNKNOWN?" then this_sedar_issuer_number = zrequest("sedar_issuer_number")
		xsedar_issuer_number_style = ""
		if this_sedar_issuer_number = "" or isnull(this_sedar_issuer_number) then 
			xsedar_issuer_number_style = "style='display:none;'"
		else
		end if
	
		'
		'	Yahoo Website
		xpop_yahoo_website = "onclick= "" pop_url('yahoo_website');return false;"" "	
		if instr(this_stock_symbol,"CA:")=0 then 
			xtmx_website_style = "style='display:none;'"		
			xsedar_website_style = "style='display:none;'"
				'	SEC 
			xpop_company_cik = "onclick= "" pop_url('company_cik');return false;"" "	
			if this_company_cik = "" and this_stock_symbol <> "" then _
			this_company_cik = zget_table("COMPANIES", "REG_CIK", "RECORD_STATUS='CURRENT' AND [STOCK_SYMBOL]='" & this_stock_symbol & "'")
			if this_company_cik = "" or this_company_cik= "?UNKNOWN?" then this_company_cik = zrequest("company_cik")	
			if this_company_cik = "" then 	xcompany_cik_style = "style='display:none;'"			
		else					
			xyahoo_website_style = "style='display:none;'"	
			xcompany_cik_style = "style='display:none;'"			
		end if
		'		
		'
	else
		'	Hide CAD links
		xtmx_website_style = "style='display:none;'"
		xsedar_website_style = "style='display:none;'"	
		'
		'	Hide US links
		xyahoo_website_style = "style='display:none;'"
		xcompany_cik_style = "style='display:none;'"	
	end if
	xthis_linkto = "<span name=this_linkto id=this_linkto></span>"
	if this_company_id <> "" then 	
		xlinkto = trim(zget_table("COMPANIES", "LINKTO", "RECORD_STATUS='CURRENT' AND [COMPANY_ID]='" & this_company_id & "'") & "")
		if xlinkto <> "" and xlinkto <> "?UNKNOWN?" then 
			xthis_linkto = "<span name=this_linkto id=this_linkto>" &_
				"<br><img src='./images/warning_animated.gif'>&nbsp;&nbsp;" &_
				"<b>" & zshow_link("",zget_table("COMPANIES", "STOCK_SYMBOL", "RECORD_STATUS='CURRENT' AND [COMPANY_ID]='" & this_company_id & "'") & "," & xlinkto) & "</b>" &_
				"</span>"
		end if
	end if
	x2x_indicator = ""
	if this_company_id <> "" then
		xcompany_country = zget_table("COMPANIES", "WSH_COUNTRY", "RECORD_STATUS='CURRENT' AND COMPANY_ID='" & this_company_id & "'")
		if  zget_table("COMPANIES", "FLAG_2XYEAR", "RECORD_STATUS='CURRENT' AND COMPANY_ID='" & this_company_id & "'") = "Y"     then x2x_indicator = "&nbsp;<img src=./images/2x21.png>&nbsp;per year"
	end if
	if this_live_url <> "" then
		live_url_pop = addy_popf2(this_live_url, zicon_web,"","")
	else
		live_url_pop = ""
	end if

	if this_live_registration_url <> "" then
		live_registration_url_pop = addy_popf2(this_live_registration_url, zicon_web,"","")
	else
		live_registration_url_pop = ""
	end if

	if this_replay_url <> "" then
		replay_url_pop = addy_popf2(this_replay_url, zicon_web,"","")
	else
		replay_url_pop = ""
	end if
	xsymbol_lookup = "<a " &_
		"id=company_lookup " &_
		"href='ZCOMPANY_LOOKUPX.ASP?zlookup_field=stock_symbol" &_
			"&zfields=stock_symbol/Stock Symbol}" &_
				"company_name/Company Names}" &_
				"company_id/CompanyId}" &_
				"company_cik/cik}" &_
				"isin/isin}" &_
				"company_website/website}" &_
				"company_country/country}" &_
				"this_linkto/@linkto}" &_
			"&zform=main_form" &_
			"&zall=Y" &_
			"&zshow_icons=Y" &_
			"&zno_edit=Y" &_
			"&zevent=ICE" &_
			"&keepThis=true" &_
			"&TB_iframe=true" &_
			"&toolbar=yes" &_
			"&height=400" &_
			"&width=410' " &_
			" class='thickbox' ><img src='../images/FINDER.GIF' border='0'></a>" &_
		""
	if zthickbox = false then 
		xsymbol_lookup = xsymbol_lookup &  "<script type='text/javascript' src='./js/thickbox.js'></script>" & crlf
		xsymbol_lookup = xsymbol_lookup &  "<link rel='stylesheet' href='./css/thickbox.css' type='text/css' media='screen' />" & crlf
		zthickbox = true
	end if	
	xtmx_money_popup = ""
	xstrip_canada_stock_symbol = ""
	if instr(this_stock_symbol, "CA:") > 0 then
		xstrip_canada_stock_symbol = split(this_stock_symbol, ":")(1)
	end if
	if xstrip_canada_stock_symbol <> "" then 
		xtmx_money_popup = "<a id='tmx_money_link' " & "" & " href='https://money.tmx.com/en/quote/" & trim(xstrip_canada_stock_symbol) & "' target='_blank'>" & imgf("tmxmoney.png", " style='width:60px;' ") & "</a>" &_
			"&nbsp;&nbsp;&nbsp;"
	end if
	xpopups = 	"&nbsp;&nbsp;&nbsp;" &_
			"<a id='company_pop_website' " & xcompany_website_style & " href=#  " & xpop_company_website & ">" & zimg_web & "</a>" &_
			"&nbsp;&nbsp;&nbsp;" &_
			"<a id='company_pop_cik' " & xcompany_cik_style & "href=#  " & xpop_company_cik & ">" & zimg_sec & "</a>" &_
			"<a id='ww_pop_website' " & xww_website_style & " href=#  " & xpop_ww_website & ">" & zimg_ww & "</a>" &_
			"&nbsp;&nbsp;&nbsp;" &_
			"<a id='tmx_pop_website' " & xtmx_website_style & " href=#  " & xpop_tmx_website & ">" & zimg_tmx & "</a>" &_
			"&nbsp;&nbsp;&nbsp;" &_			
			"<a id='sedar_pop_website' " & xsedar_issuer_number_style & " href=#  " & xpop_sedar_issuer_number & ">" & zimg_sedar & "</a>" &_
			"&nbsp;&nbsp;&nbsp;" &_
			xtmx_money_popup &_
			"" &_
				"" &_
			hiddenf("company_website", this_company_website) &_
			hiddenf("tmx_website", this_tmx_website) &_
			hiddenf("sedar_issuer_number", this_sedar_issuer_number) &_
			hiddenf("company_cik", this_company_cik) &_		
			hiddenf("yahoo_symbol", yahoo_symbol) &_		
			hiddenf("ww_website", this_ww_website) &_
			""
			
	if instr(this_quarter,"T") > 0 then quarter_list = "" &_
		"Q1T/Q1T}" &_
		"Q2T/Q2T}" &_
		"Q3T/Q3T}" &_
		"Q4T/Q4T}" &_
		"H1T/H1T}" &_
		"H2T/H2T}" &_
		""	
	if this_company_id <> "" then 
		this_stock_symbol = zget_table("COMPANIES", "STOCK_SYMBOL", "RECORD_STATUS='CURRENT' AND [COMPANY_ID]='" & this_company_id & "'")
		if  ucase(zget_table("COMPANIES", "REIT", "RECORD_STATUS='CURRENT' AND COMPANY_ID='" & this_company_id & "'")) = "Y"  then xreit_indicator = "&nbsp;<img src=./images/reit.png>&nbspREIT"
		if  zget_table("COMPANIES", "FLAG_2XYEAR", "RECORD_STATUS='CURRENT' AND COMPANY_ID='" & this_company_id & "'") = "Y" then
			x2x_indicator = "&nbsp;<img src=./images/2x21.png>&nbsp;per year"			
			quarter_list = quarter_list &_
				"H1/H1}" &_
				"H2/H2}" &_
				""		
		else
			quarter_list = quarter_list &_
				"Q1/Q1}" &_
				"Q2/Q2}" &_
				"Q3/Q3}" &_
				"Q4/Q4}" &_
				""
		end if
		if mid(this_quarter,1,1) = "H" and instr(1, quarter_list, "H1/H1") = 0 then 			quarter_list = quarter_list &_
				"H1/H1}" &_
				"H2/H2}" &_
				""		
		if mid(this_quarter,1,1) = "Q" and instr(1, quarter_list, "Q1/Q1") = 0 then 			quarter_list = quarter_list &_
				"Q1/Q1}" &_
				"Q2/Q2}" &_
				"Q3/Q3}" &_
				"Q4/Q4}" &_
				""		
	end if
	' add highlighting, etc for things replaced by pam
	bg_highlight = "background-color:yellow;"
	live_call_datetime_style = ""
	live_number_style = ""
	live_passcode_style = ""
	live_url_style = ""
	live_url_style = ""
	live_intl_number_style = ""
	live_intl_passcode_style = ""
	replay_url_style = ""

	live_registration_url_style = ""
	replay_number_style = ""
	replay_passcode_style = ""
	replay_start_datetime_style = ""
	replay_end_date_style = ""
	live_call_datetime_diff = ""
	live_number_diff = ""
	live_passcode_diff = ""
	live_url_diff = ""
	live_url_diff = ""
	live_intl_number_diff = ""
	live_intl_passcode_diff = ""
	replay_url_diff = ""
	live_registration_url_diff = ""
	replay_number_diff = ""
	replay_passcode_diff = ""
	replay_start_datetime_diff = ""
	replay_end_date_diff = ""
	if this_camefrom = "HOME_LIST" then
		if this_live_call_datetime <> old_live_call_datetime then
			live_call_datetime_style = bg_highlight
			live_call_datetime_diff = old_live_call_datetime
			if this_live_call_datetime = not_found_txt then this_live_call_datetime = ""
		end if
		if this_live_number <> old_live_number then
			live_number_style = bg_highlight
			live_number_diff = old_live_number
			if this_live_number = not_found_txt then this_live_number = ""
		end if
		if this_live_passcode <> old_live_passcode then
			live_passcode_style = bg_highlight
			live_passcode_diff = old_live_passcode
			if this_live_passcode = not_found_txt then this_live_passcode = ""
			br this_live_passcode
		end if
		if this_live_url <> old_live_url then
			live_url_style = bg_highlight
			live_url_diff = old_live_url
			if this_live_url = not_found_txt then this_live_url = ""
		end if
		
		if this_live_intl_number <> old_live_intl_number then
			live_intl_number_style = bg_highlight
			live_intl_number_diff = old_live_intl_number
			if this_live_intl_number = not_found_txt then this_live_intl_number = ""
		end if
		if this_live_intl_passcode <> old_live_intl_passcode then
			live_intl_passcode_style = bg_highlight
			live_intl_passcode_diff = old_live_intl_passcode
			if this_live_intl_passcode = not_found_txt then this_live_intl_passcode = ""
		end if
		if this_replay_url <> old_replay_url then
			replay_url_style = bg_highlight
			replay_url_diff = old_replay_url
			if this_replay_url = not_found_txt then this_replay_url = ""
		end if
		if this_live_registration_url <> old_live_registration_url then
			live_registration_url_style = bg_highlight
			live_registration_url_diff = old_live_registration_url
			if this_live_registration_url = not_found_txt then this_live_registration_url = ""
		end if
		if this_replay_number <> old_replay_number then
			replay_number_style = bg_highlight
			replay_number_diff = old_replay_number
			if this_replay_number = not_found_txt then this_replay_number = ""
		end if
		if this_replay_passcode <> old_replay_passcode then
			replay_passcode_style = bg_highlight
			replay_passcode_diff = old_replay_passcode
			if this_replay_passcode = not_found_txt then this_replay_passcode = ""
		end if
		if this_replay_start_datetime <> old_replay_start_datetime then
			replay_start_datetime_style = bg_highlight
			replay_start_datetime_diff = old_replay_start_datetime
			if this_replay_start_datetime = not_found_txt then this_replay_start_datetime = ""
		end if
		if trim(this_replay_start_datetime & "") = "" then
			replay_start_datetime_style = bg_highlight
			this_replay_start_datetime = this_live_call_datetime
		end if
		if this_replay_end_date <> old_replay_end_date then
			replay_end_date_style = bg_highlight
			replay_end_date_diff = old_replay_end_date
			if this_replay_end_date = not_found_txt then this_replay_end_date = ""
		end if
	end if
	xparsed_text_button = ""
	xparsed_text_button_old_format = ""
	if this_camefrom = "HOME_LIST" then 
		xparsed_text_button = "      " & show_parsed_text_btn
		xparsed_text_button_old_format = "      " & show_parsed_text_btn_old_format
	end if
	email_button = modal_mouseoverF(img("./images/write_email18.png"), "Click to Email",400,1000, "IFRAME:" & "compmsg.asp?companyid=" & this_company_id, "", "")
	xmtab_ct = xmtab_ct + 1
	zcp "make_screen MTAB_" & xmtab_ct
	mtab_title(xmtab_ct) = "CONF_CALLS" ' "MTAB" & xmtab_ct ' :: set the actual title here
	cat "<table cellspacing=3 border=0 style='width:" & screen_width & "px;'>"	
	cat_trf "", tdf(xbold,mo("Event Id",""))& tdf("",inputRo("event_id", this_event_id, "style='width:100px;background-color:#EFEFF7;border=0px;'") & xparsed_text_button_old_format & "   " & xparsed_text_button & err_event_id)
	cat_trf "", tdf(xbold,mo("Status",""))& tdf("",status_entry) 
	cat_trf "", tdf(xbold,mo("Record Status",""))& tdf("",inputRo("record_status", this_record_status, "style='width:100px;background-color:#EFEFF7;border=0px;'") & err_record_status)
	if isnotblank(this_company_id) then xinfo_icon = "" &_
		modal_mouseoverF(img("infosmall.gif"), "Click for CO Info",1000,1500, "IFRAME:" & "info1.asp?companyid=" & this_company_id , "", "")	
	cat_trf "", tdf("", "") & tdf("align=right", "")	
	cat_trf "", tdf(xbold,mo("Stock Symbol","")) &_
		tdf("",inputf("stock_symbol", this_stock_symbol, "style='width:50px;'") &_
		xsymbol_lookup & lclear_button("stock_symbol","company_name","companyid") & xpopups & x2x_indicator & xthis_linkto & xinfo_icon & err_stock_symbol ) 		
	cat_trf "", tdf(xbold,mo("Company Name",""))& tdf("",inputRO("company_name", this_company_name, "style='width:350px;background-color:#EFEFF7;border=0px;'") & err_company_names)
	cat_trf "", tdf(xbold,mo("ISIN",""))& tdf("",inputro("isin", this_ISIN, "style='width:120px;background-color:#EFEFF7;border=0px;'") & err_ISIN) 		
	cat_trf "", tdf(xbold,mo("Company ID",""))& tdf("",inputRO("company_id", this_company_id, "style='width:150px;background-color:#EFEFF7;border=0px;'") & err_companyid)		
	cat_trf "", tdf(xbold,mo("Company Country",""))& tdf("",inputRO("company_country", xcompany_country, "style='width:150px;background-color:#EFEFF7;border=0px;'") & err_companyid)		
	cat_trf "", tdf("", "") & tdf("", "")
	cat_trf "", tdf(xbold,mo("Quarter",""))& tdf("",drop_listf("quarter", this_quarter, quarter_list,"") & err_quarter) 		
	cat_trf "", tdf(xbold,mo("Fiscal Year",""))& tdf("",drop_listf("fiscal_year", this_fiscal_year, fiscal_year_list, "") & err_fiscal_year)	
	cat_trf "", tdf("", "") & tdf("", "")
	cat_trf "", tdf("", "") & tdf(xbold, this_date_desc & this_edate & "|" & this_tod  & "|" & this_edate_status)
	cat_trf "", tdf(xbold,mo("Live Call Date & time",""))& tdf("",input_datetimeX("main_form", "live_call_datetime", this_live_call_datetime, true, true, "style='" & live_call_datetime_style & "' onmouseout='dupe_date()'",0,".INPUT.DATEMATH") & err_live_call_datetime & live_call_datetime_diff & "&nbsp;" & email_button) 		
	if zget_table("COMPANIES", "WW_STATUS", "RECORD_STATUS='CURRENT' AND COMPANY_ID='" & this_company_id & "'") = "WW" then
		cat_trf "", tdf(xbold,mo("Country Code",""))& tdf("",drop_listf("country_code", this_country_code, venue_country_list,"style='width:200px;' onchange=""var_set('no_edit_country','Y');sub();return false;"" " ) & err_country_code) 
	else
		cat_trf "", tdf(xbold,mo("Country Code",""))& tdf("",inputRO("country_code", this_country_code, "style='width:200px;background-color:#EFEFF7;border=0px;'") & err_country_code) 		
	end if	
	
	this_time_zone = get_tag("iso_timezone_code", zget_table("validation","v_ldesc"," v_code='" & THIS_country_code & "'"))
	'
	cat_trf "", tdf(xbold,mo("Time Zone","")) &_
		tdf("",inputRO("time_zone", this_time_zone,"style='width:150px;background-color:#EFEFF7;border=0px;'"))
	cat_trf "", tdf("", "") & tdf("", "")
	cat_trf "", tdf(xbold,mo("Live Number",""))& tdf("",inputf("live_number", this_live_number, "style='width:100px;" & live_number_style & "' onmouseout='dupe_int()'" ) & clear_button("live_number") & err_live_number & live_number_diff) 		
	cat_trf "", tdf(xbold,mo("Live Passcode",""))& tdf("",inputf("live_passcode", this_live_passcode, "style='width:184px;" & live_passcode_style & "'  onmouseout='dupe_int()'") & clear_button("live_passcode") & err_live_passcode & live_passcode_diff) 		
	cat_trf "", tdf(xbold,mo("Live Intl Number",""))& tdf("",inputf("live_intl_number", this_live_intl_number, "style='width:184px;" & live_intl_number_style & "'") & clear_button("live_intl_number") & err_live_intl_number & live_intl_number_diff) 		
	cat_trf "", tdf(xbold,mo("Live Intl Passcode",""))& tdf("",inputf("live_intl_passcode", this_live_intl_passcode, "style='width:184px;" & live_intl_passcode_style & "'") & clear_button("live_intl_passcode") & err_live_intl_passcode & live_intl_passcode_diff) 
	xpaste_from_clipboard = "&nbsp;&nbsp;<a href=# onclick=""paste_from_clipboard('live_url');return false""><img src=./images/paste.png style='width:15px;height:15px;'></a>"

	cat_trf "", tdf(xbold,mo("Live URL",""))& tdf("",live_url_pop & inputf("live_url", this_live_url, "style='width:500px;" & live_url & "'onclick='setOneClickLink()' onblur='setOneClickLink()' onmouseout='dupe_url()'") & clear_button("live_url") & xpaste_from_clipboard & err_live_url & live_url_diff) 	
	cat_trf "", tdf(xbold,mo("One Click Link",""))&  tdf("", radio_listf("one_click_link",this_one_click_link,"N/No}Y/Yes}","style='width:20px;'onclick='changeOneClickAlert()'") & "&nbsp&nbsp&nbsp&nbsp1CL Confidence: " & this_counter_1CL & "%")
	cat_trf "", tdf(xbold,mo("Display on Worklist",""))&  tdf("", radio_listf("display_on_WL",this_display_on_WL,"N/No}Y/Yes}","style='width:20px;'onclick='changeOneClickAlert()'"))
	cat_trf "", tdf(xbold,mo("Live Registration URL",""))& tdf("",live_registration_url_pop & inputf("live_registration_url", this_live_registration_url, "style='width:500px;" & live_registration_url & "'onclick='setOneClickLink()' onblur='setOneClickLink()' onmouseout='dupe_url()'") & clear_button("live_registration_url") & xpaste_from_clipboard & err_live_registration_url & live_registration_url_diff) 	
	cat_trf "", tdf("", submit_button0) & tdf("style='text-align:right;'", xcancel_button)
	cat_trf "", tdf("", "") & tdf("", "")
	cat_trf "", tdf(xbold,mo("Replay Start Date & time",""))& tdf("",input_datetimeX("main_form", "replay_start_datetime", this_replay_start_datetime, true, true, "style='" & replay_start_datetime_style & "'",0,".INPUT") & datemath_button("replay_start_datetime", "", "datemath_from_timezone=UNITED_STATES_EAST") & err_replay_start_datetime & replay_start_datetime_diff) 		
	cat_trf "", tdf(xbold,mo("Replay End Date",""))& tdf("",input_datetimeX("main_form", "replay_end_date", this_replay_end_date, false, true, "style='" & replay_end_date_style & "'",0,".INPUT.") & datemath_button("replay_end_date", "date", "datemath_from_timezone=UNITED_STATES_EAST") & err_replay_end_date & replay_end_date_diff) 		
	cat_trf "", tdf(xbold,mo("Replay Number",""))& tdf("",inputf("replay_number", this_replay_number, "style='width:100px;" & replay_number_style & "'") & clear_button("replay_number") & err_replay_number & replay_number_diff) 		
	cat_trf "", tdf(xbold,mo("Replay Passcode",""))& tdf("",inputf("replay_passcode", this_replay_passcode, "style='width:184px;" & replay_passcode_style & "'") & clear_button("replay_passcode") & err_replay_passcode & replay_passcode_diff) 		
	cat_trf "", tdf(xbold,mo("Replay Reservation Id",""))& tdf("",inputf("replay_reservation_id", this_replay_reservation_id, "style='width:184px;'") & clear_button("replay_reservation_id") & err_replay_reservation_id) 
	
	cat_trf "", tdf(xbold,mo("Rebroadcast End",""))& tdf("",input_datetimeX("main_form", "rebroadcast_enddate", this_rebroadcast_enddate, false, true, "",0,".INPUT.") & err_rebroadcast_enddate) 				
	
	cat_trf "", tdf("", "") & tdf("", "")
	cat_trf "", tdf("", "") & tdf("", "")
	cat_trf "", tdf(xbold,mo("External Notes",""))& tdf("",input_textbox("external_notes", this_external_notes, 3,40, "") & err_external_notes) 		
	cat_trf "", tdf("", "") & tdf("", "(External and visible to clients)")
	cat_trf "", tdf("", "") & tdf("", "")
	cat_trf "", tdf(xbold,mo("Callback Date",""))& tdf("",input_datetimeX("main_form", "callback_date", this_callback_date, false, true, "",0,".INPUT.") & "<a href=#  onclick=""setCallbackDate()"">ED-2 </a>")
	cat_trf "", tdf(xbold,mo("Internal Notes",""))& tdf("",inputf("notes", this_notes, "style='width:400px;'") & err_notes) 
	
	if pam_ref <> "" then 
		cat_trf "",  tdf("create_parser_ticket",check_listnF("create_parser_ticket", this_create_parser_ticket, "Y/Create Ticket}", 5, ""))
		cat_trf "id='parser_ticket_description_trf'", tdf(xbold,mo("Ticket Description",""))& tdf("", inputboxF("parser_ticket_description", this_parser_ticket_description, 3, 30,"placeholder='What went wrong? Explain here. Please be specific.'") & err_parser_ticket_description) 		
	end if
	cat_trf "", tdf(xbold,mo("Created",""))& tdf("",hiddenff("created", this_created, "") & this_created & err_created) 		
	cat_trf "", tdf(xbold,mo("Created By",""))& tdf("",hiddenff("created_by", this_created_by, "") & this_created_by & err_created_by) 		
	cat_trf "", tdf(xbold,mo("Updated",""))& tdf("",hiddenff("updated", this_updated, "") & this_updated & err_updated) 		
	cat_trf "", tdf(xbold,mo("Updated By",""))& tdf("",hiddenff("updated_by", this_updated_by, "") & this_updated_by & err_updated_by) 		
	cat_trf "", tdf("",hiddenff("replay_url", this_replay_url, "")) 		

	cat_trf "", tdf("", "") & tdf("", "")
	cat_trf "", tdf("", submit_button0) & tdf("style='text-align:right;'", xcancel_button)
	cat "</table>"
	mtab(xmtab_ct) = get_cat
	'	MTAB QA
	'
	if this_id <> "NEW" and this_id <> "" then 
		xmtab_ct = xmtab_ct + 1	' should be 2
		zcp "make_screen MTAB_" & xmtab_ct
		mtab_title(xmtab_ct) = "QA" ' "MTAB" & xmtab_ct ' :: set the actual title here
		cat hiddenf("qa_onscreen", "Y")
		cat "<table cellspacing=3 border=0 style='width:" & screen_width & "px;'>"
		cat_trf "", tdf(xbold,mo("QA Flag",""))& tdf("",radio_list("qa_flag", trim(ucase(this_qa_flag & "")), "/N/A}P/Pass}F/Fail}") & err_qa_flag)
		cat_trf "", tdf(xbold,mo("QA Notes",""))& tdf("",input_textbox("qa_notes", this_qa_notes, 3,40, "") & err_qa_notes)
		cat_trf "", tdf("", "") & tdf("", "")
		cat_trf "", tdf("", submit_button0) & tdf("style='text-align:right;'", xcancel_button)
		cat "</table>"
		mtab(xmtab_ct) = get_cat
	end if
	'
	'	To enable other tabs:
	'
	'xmtab_ct = xmtab_ct + 1
	'zcp "make_screen MTAB_" & xmtab_ct
	'mtab_title(xmtab_ct) = "MTAB" & xmtab_ct ' :: set the actual title here
	'cat "<table cellspacing=3 border=0 style='width:" & screen_width & "px;'>"	
	'cat_trf "", tdf("", "") & tdf("", "")
	'cat_trf "", tdf("", submit_button0) & tdf("style='text-align:right;'", cancel_button0)
	'cat "</table>"
	'mtab(xmtab_ct) = get_cat
	'
	'
	'
	'	Notes: see .\conf_calls_all_conf_calls_tab.asp for source
	'
	if this_company_id <> "" then
		xmtab_ct = xmtab_ct + 1
		mtab_title(xmtab_ct) = "ALL&nbsp;CONF&nbsp;CALLS" 
		cat_cr "<div id=all_conf_calls_div name=all_conf_calls_div style='overflow:auto;width:970px;'>"
		cat_cr "</div>"
		mtab(xmtab_ct) = get_cat
	end if
	'	
	'	History: see ./history_tab.asp for source
	'
	%><!--#include file="./history_helper.asp"--><%
end sub
function show_mtab(xtab, xcontent, xactive)
	if xactive <> "" then xactive = " active"
	xtxt = "" &_	
		"	<div name='mtab_content_" & xtab & "' id='mtab_content_" & xtab & "'  class='mtabcontent" & xactive & "'>" & crlf &_
		"		<div class='module first noborder'>" & crlf &_
					xcontent &_
		"		</div><!-- end of module first noborder -->" & crlf &_
		"		<div class='btm_wide_auto'></div><!-- Rounded bottom -->" & crlf &_
		"	</div> <!-- End of mcontent " & xtab & " -->" & crlf 
	show_mtab = xtxt
end function	
function mtab_err(xtab)
	if instr(1, "," & tab_err & ",", "," & xtab & ",",1) then
		mtab_err = "style='color:red'"
	else
		mtab_err = ""
	end if
end function
sub list_selected()
	zcp "list_selected()"
	filters_val = ""
	selection_updated_by = zrequest_form("selection_updated_by")
	'	Handle a delete/confirm
	if isnotblank(zrequest_form("confirm_id")) then
		'
		'	Do the delete
		xconfirm_id = zrequest_form("confirm_id")
		xconfirm_id = update_fields("CONF_CALLS", "id='" & xconfirm_id & "'" , "" &_
			"status/DISABLED}" &_
			"")		
		':: if you have some more meaningful data item, substitute it here:
		xthis_key = zget_table("CONF_CALLS", "event_id", "id='" & xconfirm_id & "'")		
		if this_company_id="" then this_company_id =zget_table("CONF_CALLS", "company_id", "id='" & xconfirm_id & "'")
		'promote_CONF_CALLS
		xthis_delete_message = img(zicon_delete_item) & " Item " & xthis_key & " has been deleted"
		cat_br xthis_delete_message
		xconfirm_id = ""
	end if
	if isblank(xconfirm_id) then
		
		orderby__event_id = zrequest("orderby__event_id")
		orderby__status = zrequest("orderby__status")
		orderby__stock_symbol = zrequest("orderby__stock_symbol")
		orderby__company_name = zrequest("orderby__company_name")
		orderby__quarter = zrequest("orderby__quarter")
		orderby__fiscal_year = zrequest("orderby__fiscal_year")
		orderby__updated = zrequest("orderby__updated")
		orderby__live_call_datetime = zrequest("orderby__live_call_datetime")
		orderby = ""
		if mid(orderby__event_id,1,1) = "^" then orderby = orderby & ", CONF_CALLS.event_id"
		if mid(orderby__status,1,1) = "^" then orderby = orderby & ", CONF_CALLS.status"
		if mid(orderby__stock_symbol,1,1) = "^" then orderby = orderby & ", CONF_CALLS.stock_symbol"
		if mid(orderby__company_name,1,1) = "^" then orderby = orderby & ", CONF_CALLS.company_name"
		if mid(orderby__quarter,1,1) = "^" then orderby = orderby & ", CONF_CALLS.quarter"
		if mid(orderby__fiscal_year,1,1) = "^" then orderby = orderby & ", CONF_CALLS.fiscal_year"
		if mid(orderby__updated,1,1) = "^" then orderby = orderby & ", CONF_CALLS.updated"
		if mid(orderby__live_call_datetime,1,1) = "^" then orderby = orderby & ", CONF_CALLS.live_call_datetime"
		if mid(orderby__event_id,1,1) = "v" then orderby = orderby & ", CONF_CALLS.event_id desc"
		if mid(orderby__status,1,1) = "v" then orderby = orderby & ", CONF_CALLS.status desc"
		if mid(orderby__stock_symbol,1,1) = "v" then orderby = orderby & ", CONF_CALLS.stock_symbol desc"
		if mid(orderby__company_name,1,1) = "v" then orderby = orderby & ", CONF_CALLS.company_name desc"
		if mid(orderby__quarter,1,1) = "v" then orderby = orderby & ", CONF_CALLS.quarter desc"
		if mid(orderby__fiscal_year,1,1) = "v" then orderby = orderby & ", CONF_CALLS.fiscal_year desc"
		if mid(orderby__updated,1,1) = "v" then orderby = orderby & ", CONF_CALLS.updated desc"
		if mid(orderby__live_call_datetime,1,1) = "v" then orderby = orderby & ", CONF_CALLS.live_call_datetime desc"	
		
		xsql = ""
		xwhere_sql = ""
		'br "::New filter:" & zrequest("new_filter")
		if this_company_id <> "" and zrequest("new_filter") <> "Y" then xwhere_sql = " AND CONF_CALLS.company_id='" & this_company_id & "'"
		xsearch_sql = ""
		If selection_COT_lists <> "" Then 
			xwhere_sql = xwhere_sql & " AND  (DATALENGTH(COMPANIES.lists) <> 0) "
			xCOT_join = " INNER JOIN COMPANIES ON CONF_CALLS.company_ID = COMPANIES.company_id and COMPANIES.RECORD_STATUS = 'CURRENT'"
		end if
		
		If selection_updated_by <> "" then 
			if selection_updated_by = "@NOT_ME" then 
				xwhere_sql = xwhere_sql & " AND not(CONF_CALLS.[updated_by] LIKE = '%" & zthis_login & "%') "
			else
				xwhere_sql = xwhere_sql & " AND (CONF_CALLS.[updated_by] LIKE '%" & selection_updated_by & "%') "
			end if
		end if
		If selection_event_id <> "" Then xwhere_sql = xwhere_sql & " AND (CONF_CALLS.[event_id] = '" & selection_event_id & "') "
		If selection_status <> "" Then xwhere_sql = xwhere_sql & " AND (CONF_CALLS.[status] = '" & selection_status & "') "
		If selection_stock_symbol <> "" Then xwhere_sql = xwhere_sql & " AND (CONF_CALLS.[stock_symbol] = '" & selection_stock_symbol & "') "
		If selection_company_name <> "" Then xwhere_sql = xwhere_sql & " AND (CONF_CALLS.[company_name] like '%" & selection_company_name & "%') "
		If selection_quarter <> "" Then xwhere_sql = xwhere_sql & " AND (CONF_CALLS.[quarter] = '" & selection_quarter & "') "
		If selection_fiscal_year <> "" Then xwhere_sql = xwhere_sql & " AND (CONF_CALLS.[fiscal_year] = '" & selection_fiscal_year & "') "
		If selection_updated <> "" Then xwhere_sql = xwhere_sql & " AND (CONF_CALLS.[updated] >= '" & selection_updated & "') "
		If selection_live_call_datetime <> "" Then xwhere_sql = xwhere_sql & " AND (CONF_CALLS.[live_call_datetime] >= '" & selection_live_call_datetime & "') "
		if selection_search <> "" then 
			xsearch_sql = xsearch_sql & "or CONF_CALLS.[event_id] like '%" & selection_search & "%' " 
			xsearch_sql = xsearch_sql & "or CONF_CALLS.[status] like '%" & selection_search & "%' " 
			xsearch_sql = xsearch_sql & "or CONF_CALLS.[stock_symbol] like '%" & selection_search & "%' " 
			xsearch_sql = xsearch_sql & "or CONF_CALLS.[company_name] like '%" & selection_search & "%' " 
			xsearch_sql = xsearch_sql & "or CONF_CALLS.[quarter] like '%" & selection_search & "%' " 
			xsearch_sql = xsearch_sql & "or CONF_CALLS.[fiscal_year] like '%" & selection_search & "%' " 
			xsearch_sql = xsearch_sql & "or CONF_CALLS.[updated] like '%" & selection_search & "%' " 
			xsearch_sql = xsearch_sql & "or CONF_CALLS.[live_call_datetime] like '%" & selection_search & "%' " 
			xwhere_sql = xwhere_sql & " AND (" &_
				mid(xsearch_sql, 3) &_
				")"
		end if
		xwhere_sql = xwhere_sql & " AND CONF_CALLS.record_status='CURRENT'"
		xsql = "select top(101) CONF_CALLS.* from CONF_CALLS " & xCOT_join & " where " & mid(xwhere_sql, 5) & " "
		
		if orderby = "" then 
			orderby = ", CONF_CALLS.fiscal_year desc, CONF_CALLS.quarter desc"
			orderby__balance_sheet_at ="vid"
		end if
		orderby = mid(orderby, 2)
		' end if
		if orderby = "" and selection_updated <> ""  then 
			orderby = ", CONF_CALLS.updated"
			orderby__updated = "^"
		end if
		
		if orderby = "" then 
			orderby = ", CONF_CALLS.id desc"
			orderby__balance_sheet_at ="vid"
		end if
		orderby = mid(orderby, 2)
		if instr(xsql," order by") = 0 then xsql = xsql & " order by " & orderby
		if zrequest_form("filters_set") = "Y" or this_company_id <> "" then
			zfinal_script = "activate_mtab('1');activate_tab('');"
			show_list (xsql)
		else
			cat_BR newrec_button0 
			if worklist_support then 
				cat_BR worklist_callback_button	
				cat_BR worklist_one_click_link_button
			end if
			cat_BR ""
			zfinal_script = "activate_tab('1');" &_
				"activate_mtab('1');"
		end if
	else
		cat_br ""
		cat_br ""
		cat_br ""
		cat cancel_button0
	end if
end sub
'
'
'	Show the list
sub show_list(xsql)
	xsql = replace(xsql, "CONF_CALLS.* ", "" &_
		" CONF_CALLS.company_id" &_
		",CONF_CALLS.id" &_
		",CONF_CALLS.event_id" &_
		",CONF_CALLS.status" &_
		",CONF_CALLS.stock_symbol" &_
		",CONF_CALLS.company_name" &_
		",CONF_CALLS.quarter" &_
		",CONF_CALLS.fiscal_year" &_
		",CONF_CALLS.updated" &_
		",CONF_CALLS.live_call_datetime" &_
		",CONF_CALLS.qa_flag" &_
		" ")
	zcp "show_list(" & xsql & ")"
	'br "::" & xsql
	div_width = 1000
	cat  "<div style='padding-left:4px; padding-right:10px; width:" & (div_width) & "px;height:700px;overflow:hidden;overflow-x:hidden;'> "
	rs_list.open xsql, connection,3,1
	xthis_row_color = ""
	xdelete_id = trim(zrequest("delete_id") & "")
	xl_event_id = 100
	xl_status = 100
	xl_stock_symbol = 100
	xl_company_name = 200
	xl_quarter = 50
	xl_fiscal_year = 50
	xl_updated = 100
	xl_live_call_datetime = 184
	xl_qa_flag = 16
	If rs_list.EOF Then
		if context_set then			
			cat_BR newrec_button_with_context 
			cat_BR ""
			cat_br znow() & " No Conference Calls for " & zget_table("COMPANIES", "COMPANY_NAME", "RECORD_STATUS='CURRENT' AND COMPANY_ID='" & this_company_id & "'")
		else
			if worklist_support then cat_BR worklist_callback_button		
			cat_BR ""
			cat_BR newrec_button0 
			cat_br znow() & " No results for search"
		end if
		zfinal_script = "activate_tab('1');"
	Else
		' if this_company_id <> "" then cat_BR newrec_button_with_context 
		If rs_list.RecordCount > 100 Then
			cat_br "Top 100 results shown"
		end if
		if isblank(xdelete_id) then 
			cat_BR newrec_button0 
			cat  "<div style='padding-left:4px; padding-right:10px; width:" & div_width-40 & "px;height:25px;overflow:hidden;overflow-x:hidden;'> "
			cat "<table style='width:" & div_width-60 & "px;'>"
			cat_trf "", "" &_
				tdf("style='width:24px;text-align:center;'", "") &_
				tdf("style='width:24px;text-align:center;'", "") &_		
				tdf("style='width:" & xl_event_id & "px;'", sortby("Event Id", "event_id")) &_
				tdf("style='width:" & xl_status & "px;'", sortby("Status", "status")) &_
				tdf("style='width:" & xl_stock_symbol & "px;'", sortby("Symbol", "stock_symbol")) &_
				tdf("style='width:" & xl_company_name & "px;'", sortby("Company Name", "company_name")) &_
				tdf("style='width:" & xl_quarter & "px;'", sortby("Quarter", "quarter")) &_
				tdf("style='width:" & xl_fiscal_year & "px;'", sortby("Fiscal Year", "fiscal_year")) &_
				tdf("style='width:" & xl_updated & "px;'", sortby("Updated", "updated")) &_
				tdf("style='width:" & xl_live_call_datetime & "px;'", sortby("Live Call", "live_call_datetime")) &_
				tdf("style='width:" & xl_qa_flag & "px;'", sortby("QA", "qa_flag")) &_
				""
			cat "</table>"
			cat "</div>"
		end if
		cat  "<div style='padding-left:4px; padding-right:10px; width:" & div_width-40 & "px;height:590px;overflow:auto;overflow-x:hidden;'> "
		cat "<table style='width:" & div_width-60 & "px;'>"
		xnumber_listed = 0
		xfirst_company_id = ""
		while not(rs_list.eof) and xnumber_listed <= 100
			if xfirst_company_id = "" then
				' determine if we can do stickies -- grab the first record's ID and and assume the best
				xfirst_company_id = rs_list("company_id")
				this_company_id = rs_list("company_id")
				stickies = "Y"
			end if
			if rs_list("company_id") <> xfirst_company_id and isnotblank(xfirst_company_id) then stickies = "N"
			if first_id = "" then first_id = rs_list("id")
			xnumber_listed = xnumber_listed + 1
			xc = ""
			xr = "valign=top bgcolor=#FFC0C0"
			xthis_row_color= rcblue
			if xdelete_id = trim(rs_list("id") & "") then 
				xaction_delete =  action_button("Click to Confirm Deletion" _
					, "confirm_id" _
					, rs_list("id") _
					, zicon_delete _
					, "" _
					, "var_set('active_tab','2');var_set('mactive_tab','1');")
				xthis_row_color = xr
				xc = "Click the icon to confirm delete"
			else
				xaction_delete = action_button("Click to Delete" _
					, "delete_id", rs_list("id") _
					, zicon_delete _
					, "" _
					, "document.getElementById('wait_" & rs_list("id") & "').style.display='block';var_set('active_tab','');var_set('mactive_tab','1');")
			end if
			'if zthis_usertype <>  "ADMIN"  then xaction_delete = ""
			xselect_me = "document.getElementById('wait_" & rs_list("id") & "').style.display='block';"
			this_item =  "" &_
					"<tr " & xthis_row_color & ">" &_
					tdf("style='width:24px;text-align:center;'", "<img src='" & zicon_loading & "' id='wait_" & rs_list("id") & "' name='wait_" & rs_list("id") & "' style='display:none;'>" &_
						"") &_
					tdf("style='width:24px;text-align:center;'", xaction_delete &_
						"") &_
					tdf("style='width:" & xl_event_id & "px;'", action_textMO("Click to edit","next_id", rs_list("id"), rs_list("event_id") , xselect_me) ) &_
					tdf("style='width:" & xl_status & "px;'", action_textMO("Click to edit","next_id", rs_list("id"), rs_list("status") , xselect_me) ) &_
					tdf("style='width:" & xl_stock_symbol & "px;'", action_textMO("Click to edit","next_id", rs_list("id"), rs_list("stock_symbol") , xselect_me) ) &_
					tdf("style='width:" & xl_company_name & "px;'", action_textMO("Click to edit","next_id", rs_list("id"), rs_list("company_name") , xselect_me) ) &_
					tdf("style='width:" & xl_quarter & "px;'", action_textMO("Click to edit","next_id", rs_list("id"), rs_list("quarter") , xselect_me) ) &_
					tdf("style='width:" & xl_fiscal_year & "px;'", action_textMO("Click to edit","next_id", rs_list("id"), rs_list("fiscal_year") , xselect_me) ) &_
					tdf("style='width:" & xl_updated & "px;'", action_textMO("Click to edit","next_id", rs_list("id"), rs_list("updated") , xselect_me) ) &_
					tdf("style='width:" & xl_live_call_datetime & "px;'", action_textMO("Click to edit","next_id", rs_list("id"), rs_list("live_call_datetime") , xselect_me) ) &_
					tdf("style='width:" & xl_qa_flag & "px;'", action_textMO("Click to edit","next_id", rs_list("id"), rs_list("qa_flag") , xselect_me) ) &_
					"</tr>"
			if (xdelete_id <> "" and xdelete_id <> trim(rs_list("id"))) then
				'do nothing
			Else
				cat this_item
				if xdelete_id <> "" then cat_br "<br><center>" & xc & "</center>"
			End If
			rs_list.movenext
		wend
		cat "</table>"
		cat hiddenf("delete_id", "")	' Handled in this code
		cat hiddenf("confirm_id", "")	' Handled in this code
		cat "</div>"
		cat_br ""
		cat cancel_button1
	End If
	rs_list.close
	cat "</div>"
	zcp "show_list_end"
end sub
function show_filter_screen()
	if quarter_list = "/...}" or quarter_list = "" then 
		quarter_list = "/...}" &_
				"Q1/Q1}" &_
				"Q2/Q2}" &_
				"Q3/Q3}" &_
				"Q4/Q4}" &_
				"H1/H1}" &_
				"H2/H2}" &_
				""		
	end if
	
	cat "<div style=""padding-left:4px; padding-right:10px; height:450px;"">"
	selection_updated_by = zrequest_form("selection_updated_by")
	selection_announce_date = zrequest_form("selection_announce_date")
	selection_search = zrequest_form("selection_search")
	selection_COT_lists = zrequest_form("selection_COT_lists")
	selection_event_id = zrequest_form("selection_event_id")
	selection_stock_symbol = zrequest_form("selection_stock_symbol")
	selection_quarter = zrequest_form("selection_quarter")
	selection_fiscal_year = zrequest_form("selection_fiscal_year")
	selection_updated = zrequest_form("selection_updated")
	selection_live_call_datetime = zrequest_form("selection_live_call_datetime")
	selection_status = zrequest_form("selection_status")
	selection_company_name = zrequest_form("selection_company_name")
	cat "<table width=260px>"
	cat_tr tdf("colspan=2", "Enter search criteria, <br>or leave blank for max 200 returned")
	cat_tr tdb("Upd on/After") & tdf("", input_datetimeX("main_form", "selection_updated", selection_updated, false, true, "",0,".INPUT.")) 
	cat_tr tdb("Updated By") & tdf("", drop_listf("selection_updated_by", selection_updated_by,"/...}" & zselected_user_list("NOC"),"style='width:150px;'")  & clear_button("selection_updated_by")) 
	cat_tr tdb("Event Id") & tdf("", inputf("selection_event_id", selection_event_id, "style='width:100px;'") & clear_button("selection_event_id")) 
	 cat_tr tdb("Status") & tdf("", drop_listF("selection_status", selection_status, lstatus_list,  "style='width:110px;'") & clear_button("selection_status")) 
	cat_tr tdb("Stock Symbol") & tdf("", inputf("selection_stock_symbol", selection_stock_symbol, "style='width:150px;'") & clear_button("selection_stock_symbol")) 
	cat_tr tdb("Company Name") & tdf("", inputf("selection_company_name", selection_company_name, "style='width:100px;'") & clear_button("selection_company_name")) 
	cat_tr tdb("Quarter") & tdf("", drop_listf("selection_quarter", selection_quarter,"/...}" & quarter_list, "style='width:100px;'") & clear_button("selection_quarter")) 
	cat_tr tdb("Fiscal Year") & tdf("", drop_listf("selection_fiscal_year", selection_fiscal_year, fiscal_year_list, "") & clear_button("selection_fiscal_year")) 
	cat_tr tdb("Live Call Datetime") & tdf("", input_datetimeX("main_form", "selection_live_call_datetime", selection_live_call_datetime, false, true, "",0,".INPUT.")) 
	' cat_tr tdb("Announced") & tdf("", input_datetimeX("main_form", "selection_announce_datetime", selection_announce_datetime, false, true, "",0,".INPUT."))
	cat_tr tdf("colspan=2", "<b>Search:</b>")
	cat_tr tdf("colspan=2", inputf("selection_search", selection_search, "style='width:250px;'") & clear_button("selection_search"))
	cat_tr tdb("Lists") & tdf("", check_listf("selection_COT_lists", selection_COT_lists, "Y/Present}","")  ) 
	cat_tr td("&nbsp;") & td("&nbsp;")
	if isblank(this_id ) then
		xshow_loading = "document.getElementById('wait_filter').style.display='block';"
		xsubmit = "xsubmit='Y';"
	end if	
	cat_tr tdf("colspan=2 align=center", "" &_
		"<a href=# " &_
			" onclick=""" &_
			"var_set('filters_set','Y');" &_
			"var_set('worklists','');" &_
			"var_set('new_filter','Y');" &_
			"var_set('active_tab','');" &_
			"var_set('mactive_tab','1');" &_
			xsubmit &_
			xshow_loading &_
			"unsafe_sub();" &_
			""" " &_
			">" &_
			img(zicon_search) & "</a>")
	cat_tr tdf("colspan=2 align=center","<img src='" & zicon_loading & "' id='wait_filter' name='wait_filter' style='display:none;'>")
	cat "</table>"
	cat hiddenf("filters_set", "Y")
	cat "</div>"
	show_filter_screen = get_cat
end function		
sub generate_worklist(xtype)
	'	Handle a delete/confirm
	if isnotblank(zrequest_form("confirm_id")) _
	and trim(zrequest("worklist")) = trim(xtype)  _
	then
		' 	Generate callback_date
		'	xcallback_date
		
		'
		'	Do the confirm
		xconfirm_id = zrequest_form("confirm_id")
		'
		'
		
		xthis_company_id = zget_table("CONF_CALLS", "company_id", "id='" & xconfirm_id & "'")
		xthis_edate = zget_table("CONF_CALLS", "live_call_datetime", "company_id='" & xthis_company_id & "' and record_status = 'CURRENT' and status = 'ACTIVE'")
		xcallback_date = fcdate(xthis_edate - 2)
		xworklist_notes = replace(zrequest("worklist_notes_" & xconfirm_id), "}", "")
		xconfirm_id = update_fields("CONF_CALLS", "id='" & xconfirm_id & "'" , "" &_
			"worklist_notes/" & xworklist_notes & "}" &_
			"callback_date/" & xcallback_date & "}" &_
			"")		
		':: if you have some more meaningful data item, substitute it here:
		xthis_key = zget_table("CONF_CALLS", "stock_symbol", "id='" & xconfirm_id & "'")
		xthis_confirm_message = img(confirm_item_icon) & " Company " & xthis_key & " has been deferred"
		cat_br xthis_confirm_message
		xconfirm_id = ""
	end if
	zrequest_form("confirm_id")
	if isblank(xconfirm_id) then
		Dim default_order
		if cint(xtype) = 2 then
			' worklist of all oneclick links = "N"
			'xsql =  "SELECT TOP(50) CONF_CALLS.*, companies.likely_one_click_link FROM CONF_CALLS " &_
			'		"INNER JOIN companies " &_
			'		"ON companies.company_id = CONF_CALLS.company_id " &_ 
			'		"WHERE CONF_CALLS.status='active' " &_
			'		"AND CONF_CALLS.record_status = 'CURRENT' " &_
			'		"AND CONF_CALLS.one_click_link = 'N' " &_
			'		"AND companies.record_status = 'CURRENT' " &_ 
			'		"AND companies.coverage = 'Y' " &_
			'		""
					
			xsql = "SELECT TOP(50) CONF_CALLS.*, companies.likely_one_click_link FROM CONF_CALLS  " &_
				"INNER JOIN companies  " &_
				"ON companies.company_id = CONF_CALLS.company_id  " &_
				"WHERE CONF_CALLS.status='active'  " &_
				"AND CONF_CALLS.record_status = 'CURRENT'  " &_
				"AND CONF_CALLS.one_click_link = 'N'  " &_
				"AND companies.record_status = 'CURRENT'  " &_
				"AND companies.coverage = 'Y'  " &_
				"and conf_calls.updated < '" & date() & "'" &_
				"and conf_calls.display_on_WL <> 'N'" &_
				""
					
			default_order = "CONF_CALLS.callback_date"
		else
			' default to xtype = 1
			' callback dates that are non empty worklist
			' 
			xtype = 1
			xsql =  "SELECT TOP(100) CONF_CALLS.*, earnings_dates.earnings_date		FROM CONF_CALLS " &_
					"INNER JOIN earnings_dates " &_
					"ON earnings_dates.Company_Id = CONF_CALLS.company_id " &_
					"INNER JOIN companies " &_
					"ON companies.company_id = CONF_CALLS.company_id " &_ 
					"WHERE earnings_dates.status='active' " &_
					"AND earnings_dates.record_status = 'current' " &_
					"AND earnings_date_status = 'confirmed' " &_
					"AND companies.record_status = 'CURRENT' " &_ 
					"AND companies.coverage = 'Y' " &_ 
					"AND CONF_CALLS.status='pending_review' " &_
					"AND CONF_CALLS.record_status = 'current' " &_
					"AND CONF_CALLS.callback_date <> '' " &_
					"AND CONF_CALLS.updated < '" & date() & "'" &_
					""	
			default_order = "CONF_CALLS.callback_date"
		end if
		Dim orderby : orderby                                   = "ORDER BY "
		Dim null_callback_dates_last : null_callback_dates_last = "CASE WHEN CONF_CALLS.callback_date IS NULL THEN 1 ELSE 0 END"
		Dim order_by_fields: order_by_fields                    = ""
		orderby__callback_date      = zrequest("orderby__callback_date")
		orderby__live_call_datetime = zrequest("orderby__live_call_datetime")
		if mid(orderby__callback_date,1,1)      = "^" then orderby__fields = orderby__fields & ", CONF_CALLS.callback_date"
		if mid(orderby__live_call_datetime,1,1) = "^" then orderby__fields = orderby__fields & ", CONF_CALLS.live_call_datetime"
		if mid(orderby__callback_date,1,1)      = "v" then orderby__fields = orderby__fields & ", CONF_CALLS.callback_date desc"
		if mid(orderby__live_call_datetime,1,1) = "v" then orderby__fields = orderby__fields & ", CONF_CALLS.live_call_datetime desc"
		if orderby__fields <> "" then
			orderby__fields = mid(orderby__fields, 2)
		else
			orderby__fields = default_order
		end if 
		if xtype = 2 then
			xsql = xsql & " ORDER BY " & orderby__fields
		else
			xsql = xsql & " ORDER BY " & null_callback_dates_last & ", " & orderby__fields
		end if
		zfinal_script = "activate_tab('');" 
		show_worklist  cstr(xtype),xsql
	else
		cat_br ""
		cat_br ""
		cat_br ""
		cat cancel_button0
	end if
end sub
'
'
'	Show the list
sub show_worklist(xtype,xsql)
	dim current_counter_1CL
	xsql = replace(xsql, "CONF_CALLS.* ", "" &_
		" CONF_CALLS.company_id" &_
		",CONF_CALLS.id" &_
		",CONF_CALLS.live_url" &_
		",CONF_CALLS.worklist_notes" &_
		",CONF_CALLS.event_id" &_
		",CONF_CALLS.stock_symbol" &_
		",CONF_CALLS.notes" &_
		",CONF_CALLS.live_call_datetime" &_
		",CONF_CALLS.likely_one_click_link" &_
		",CONF_CALLS.callback_date" &_
		",CONF_CALLS.earnings_date" &_
		",CONF_CALLS.created" &_
		" ")
	div_width = 1000
	cat  "<div style='padding-left:4px; padding-right:10px; width:" & (div_width) & "px;height:700px;overflow:hidden;overflow-x:hidden;'> "
	cat hiddenf("defer_id", "")	' Handled in this code
	cat hiddenf("confirm_id", "")	' Handled in this code
	rs_list.open xsql, connection, 3,3
	xthis_row_color = ""
	xdefer_id = zrequest("defer_id")
	xl_stock_symbol = 80
	xl_live_call_datetime = 70
	xl_action_buttons = 40
	xl_company_name = 300
	xl_email = 40
	xl_email_date = 70
	xl_event_id = 80
	Dim xl_notes, xl_callback_date, xl_earnings_date, xl_1CL_percentage
	xl_notes = 150
	xl_callback_date = 70
	xl_earnings_date = 70
	xl_1CL_percentage = 35
	If rs_list.EOF Then
		cat_BR newrec_button0 
		if worklist_support then 
			if (xtype = 1) then
				cat_BR worklist_callback_button
				cat_BR ""
				cat_br znow() & " No results for search"
				cat_br worklist_one_click_link_button
			else
				cat_BR worklist_callback_button
				cat_br worklist_one_click_link_button
				cat_BR ""
				cat_br znow() & " No results for search"
			end if
		end if
		zfinal_script = "activate_tab('');"
	Else
		Dim column_headers
		if xtype = 2 then
			column_headers = 	tdf("style='width:24px;text-align:center;'", "") &_
								tdf("style='width:" & xl_event_id & "px;'", "Event ID") &_
								tdf("style='width:" & xl_action_buttons & "px;'", "") &_
								tdf("style='width:" & xl_stock_symbol & "px;'", "Symbol") &_
								tdf("style='width:" & xl_notes & "px;'", "Notes") &_
								tdf("style='width:" & xl_callback_date & "px;'", sortby("Callback", "callback_date")) &_
								tdf("style='width:" & xl_live_call_datetime & "px;'", sortby("Live Call", "live_call_datetime")) &_
								tdf("style='width:" & xl_1CL_percentage & "px;'", "1CL %") &_
								tdf("style='width:24px;text-align:center;'", "DFR") &_
								""
								' tdf("style='width:" & xl_callback_date & "px;'", sortby("Callback Date", "callback_date")) &_
								' tdf("style='width:" & xl_email & "px;'", "Email") &_
								' tdf("style='width:" & xl_email_date & "px;'", "Last Email") &_
		else
			column_headers = 	tdf("style='width:24px;text-align:center;'", "") &_
								tdf("style='width:" & xl_event_id & "px;'", "Event ID") &_
								tdf("style='width:" & xl_action_buttons & "px;'", "") &_
								tdf("style='width:" & xl_stock_symbol & "px;'", "Symbol") &_
								tdf("style='width:" & xl_notes & "px;'", "Notes") &_
								tdf("style='width:" & xl_callback_date & "px;'", "Callback Date") &_
								tdf("style='width:" & xl_earnings_date & "px;'", "ED") &_
								tdf("style='width:" & xl_email & "px;'", "Email") &_
								tdf("style='width:" & xl_email_date & "px;'", "Last Email") &_
								tdf("style='width:24px;text-align:center;'", "DFR") &_
								""
		end if
		cat  "<div style='padding-left:4px; padding-right:10px; width:" & div_width-40 & "px;height:25px;overflow:hidden;overflow-x:hidden;'> "
		cat "<table style='width:" & div_width-60 & "px;'>"
			cat_trf "", "" & column_headers
		cat "</table>"
		cat "</div>"
		cat  "<div style='padding-left:4px; padding-right:10px; width:" & div_width-40 & "px;height:600px;overflow:auto;overflow-x:hidden;'> "
		cat "<table style='width:" & div_width-60 & "px;'>"
		Dim xcc_link
		xnumber_listed = 0
		xct = 0
		while not(rs_list.eof)
			xct = xct + 1
			' if zget_table("COMPANIES", "COVERAGE", "RECORD_STATUS='CURRENT' AND [COMPANY_ID]='" & rs_list("company_id") & "'") = "N" then 
				' rs_list.movenext
				' done = true
			' else
				done = false
			' end if
			if not(done) then
				if first_id = "" then first_id = rs_list("id")
				xnumber_listed = xnumber_listed + 1
				xc = ""
				xr = "valign=top bgcolor=#FFC0C0"
				xthis_row_color= rcblue
					xaction_defer =  action_button("Click to Confirm Defer" _
						, "confirm_id" _
						, rs_list("id") _
						, zicon_defer _
						, "" _
						, "var_set('mactive_tab','" & xtype & "');var_set('active_tab','');")
					xthis_row_color = xr
					xc = "Please Confirm the Deferral"
				xselect_me = "document.getElementById('wait_" & rs_list("id") & "').style.display='block';var_set('mactive_tab','1');var_set('active_tab','');var_set('worklist','" & xtype & "');"
				if isnotblank(rs_list("live_url")) then
					xcc_link = "<a href='" & rs_list("live_url") & "' target='_blank'><img src='./images/website22.png'" &_
					" border=0></a>"
				else
					xcc_link = "<a href='" & zget_table("COMPANIES", "IRWEBSITE", "RECORD_STATUS='CURRENT' AND [COMPANY_ID]='" & rs_list("company_id") & "'") & "' target='_blank'><img src='./images/website22.png'" &_
					" border=0></a>"
				end if
				ww_popup = ""
				if zget_table("companies","ww_status","RECORD_STATUS='CURRENT'AND [COMPANY_ID]='" & rs_list("company_id") & "'") = "WW" then
					xpop_ww_website = "onclick= "" pop_url('ww_website');return false;"" "
					this_ww_website = zget_table("COMPANIES", "WW_EXCHANGE_LINK", "RECORD_STATUS='CURRENT' AND [COMPANY_ID]='" & rs_list("company_id") & "'")
					if this_ww_website <> "" then ww_popup = "<a href='" & this_ww_website & "' target='_blank'><img src='./images/ww.png'" &_
					" border=0></a>"
				end if				
				if	xdefer_id = trim(rs_list("id")) then
					xbutton = "<input type='image' onclick='" &_
						"window.history.back();" &_
						"return false;" &_
						"' src='./images/redx.gif' title='Cancel Defer'>"
					this_update = "" &_
						crlf &_
						"<tr " & xthis_row_color & ">" &_
							tdf("colspan=2", "" ) &_
							tdf("colspan=2 style='text-align:right;'", inputf("worklist_notes_" & rs_list("id"), trim(rs_list("worklist_notes")& ""), "style='width:500px;'") ) &_
							tdf("style='width:24px;text-align:center;'", xaction_defer ) &_
						"</tr>" &_
						""
					zfinal_script = "activate_tab('');" &_
						"activate_mtab('" & xtype & "');" &_
						""
				else
					xbutton = xaction_defer
					this_update = ""
					' UNCOMMENT to include worklist_notes on screen
					' 
					' if trim(rs_list("worklist_notes") & "") <> "" then 
					' 	'br "::'" & trim(rs_list("worklist_notes") & "") & "'"
					' 	' this_update = "" &_
					' 	' 	crlf &_
					' 	' 	"<tr " & xthis_row_color & ">" &_
					' 	' 		tdf("colspan=3", "" ) &_
					' 	' 		tdf("colspan=5 style='text-align:right;'", trim(rs_list("worklist_notes")& "") ) &_
					' 	' 		tdf("colspan=1 style='width:24px;text-align:center;'", "" ) &_
					' 	' 	"</tr>" &_
					' 	' 	""
					' else	
					' 	this_update = ""
					' end if
				end if
				if this_xtype <> 2 then
					this_email = zget_table("COMPANIES","send_request_email","company_id = '" & rs_list("company_id") & "'")
					this_email_date = zget_table("COMPANIES","recent_request_emails","company_id = '" & rs_list("company_id") & "'")
					this_email_date = trim(this_email_date & "")
					if isblank(this_email_date) then
						this_email = "No"
						this_email_date = ""
					else
						' find the latest email
						xemail_date = split(this_email_date, "}")
						this_email_date = fcdate("1/1/1970")
						for xdate_ct = 0 to ubound(xemail_date)
							if xemail_date(xdate_ct) <> "" then 
								xslash_pos = instr(1, xemail_date(xdate_ct), "/")
								xthis_email_date = fcdate(mid(xemail_date(xdate_ct), xslash_pos + 1))
								if xthis_email_date > this_email_date then this_email_date = xthis_email_date
							end if
						next
						this_email = "Yes"
					end if
	
					Dim xprevious_cc, had_cc_within_the_year
					xprevious_cc = zget_table("CONF_CALLS", "live_call_datetime", "company_id = '" & rs_list("company_id") & "' AND record_status = 'CURRENT' " &_
											"AND status ='HISTORICAL' ORDER BY live_call_datetime DESC" )
					if isnotblank(xprevious_cc) and xprevious_cc <> "?UNKNOWN?" and xprevious_cc > fcdate(today) - 365 then 
						had_cc_within_the_year = true 
					else
						had_cc_within_the_year = false
					end if 
				end if
				if xtype = 2 then
					if rs_list("Counter_1CL") <> "" or rs_list("Counter_1CL") <> null then
						current_counter_1CL = rs_list("Counter_1CL")
					else
						current_counter_1CL = determine_counter_1CL_value(rs_list("company_id"),rs_list("created"),false)
					end if

					this_item =  "" &_
							"<tr " & xthis_row_color & ">" &_
								tdf("style='width:24px;text-align:center;'", "<img src='" & zicon_loading & "' id='wait_" & rs_list("id") & "' name='wait_" & rs_list("id") & "' style='display:none;'>") &_
								tdf("style='width:" & xl_event_id & "px;'", action_textMO("Click to edit","next_id", rs_list("id"), rs_list("event_id") , xselect_me) ) &_
								tdf("style='width:" & xl_action_buttons & "px;' valign=top", xcc_link ) &_
								tdf("style='width:" & xl_stock_symbol & "px;'", action_textMO("Click to edit","next_id", rs_list("id"), rs_list("stock_symbol") , xselect_me) ) &_
								tdf("style='width:" & xl_notes & "px;'", action_textMO("Click to edit","next_id", rs_list("id"), mid(rs_list("notes"), 1, 23) , xselect_me) ) &_
								tdf("style='width:" & xl_callback_date & "px;'", action_textMO("Click to edit","next_id", rs_list("id"), zformatshortdate(rs_list("callback_date")) , xselect_me) ) &_								
								tdf("style='width:" & xl_live_call_datetime & "px;'", action_textMO("Click to edit","next_id", rs_list("id"), zformatshortdate(rs_list("live_call_datetime")) , xselect_me) ) &_
								tdf("style='width:" & xl_1CL_percentage & "px;'", action_textMO("Click to edit","next_id", rs_list("id"), zformatshortdate(current_counter_1CL & " %") , xselect_me) ) &_
								tdf("style='width:24px;text-align:center;'", xbutton ) &_
							"</tr>" &_
							""
				else
					if had_cc_within_the_year then 
						this_item =  "" &_
								"<tr " & xthis_row_color & ">" &_
									tdf("style='width:24px;text-align:center;'", "<img src='" & zicon_loading & "' id='wait_" & rs_list("id") & "' name='wait_" & rs_list("id") & "' style='display:none;'>") &_
									tdf("style='width:" & xl_event_id & "px;'", action_textMO("Click to edit","next_id", rs_list("id"), rs_list("event_id") , xselect_me) ) &_
									tdf("style='width:" & xl_action_buttons & "px;' valign=top", xcc_link & " " & ww_popup ) &_
									tdf("style='width:" & xl_stock_symbol & "px;'", action_textMO("Click to edit","next_id", rs_list("id"), rs_list("stock_symbol") , xselect_me) ) &_
									tdf("style='width:" & xl_notes & "px;'", action_textMO("Click to edit","next_id", rs_list("id"), mid(rs_list("notes"), 1, 23) , xselect_me) ) &_
									tdf("style='width:" & xl_callback_date & "px;'", action_textMO("Click to edit","next_id", rs_list("id"), zformatshortdate(rs_list("callback_date")) , xselect_me) ) &_
									tdf("style='width:" & xl_earnings_date & "px;'", action_textMO("Click to edit","next_id", rs_list("id"), zformatshortdate(rs_list("earnings_date")) , xselect_me) ) &_
									tdf("style='width:" & xl_email & "px;'", action_textMO("Click to edit","next_id", rs_list("id"), this_email , xselect_me) ) &_
									tdf("style='width:" & xl_email_date & "px;'", action_textMO("Click to edit","next_id", rs_list("id"), zformatshortdate(this_email_date) , xselect_me) ) &_
									tdf("style='width:24px;text-align:center;'", xbutton ) &_
								"</tr>" &_
								""
					else 
						this_item = ""
						this_update = ""
					end if
				end if
				if (xdefer_id <> "" and xdefer_id <> trim(rs_list("id"))) then
					'do nothing
				Else
					cat this_item & this_update
					if xdefer_id <> "" then cat_br "<br><center>" & xc & "</center>"
				End If
				rs_list.movenext
			end if
		wend
		cat "</table>"
		cat "</div>"
		cat_br ""
		cat_br xnumber_listed & " results shown"
		cat_br ""
		cat cancel_button1
	End If
	rs_list.close
	cat "</div>"
end sub
function daydateonly(xtxt)
	if isdate(xtxt) then 
		xday = dow(weekday(xtxt))
		xi = instr(1, xtxt, " " )
		if xi <> 0 then 
			xdt = mid(xtxt, 1, xi -1)
			xtm = mid(xtxt, xi + 1)
			if instr(1, xtm, "AM") <> 0 then
				xm = "AM"
			else
				xm = "PM"
			end if
			xi = instr(1, xtm, ":")
			xi = instr(xi + 1, xtm, ":")
			xtm = mid(xtm, 1, xi -1) & xm
			xtxt = xdt & " " & xtm
		end if
		xtxt = xday & xtxt
	else
		' do nothing
		if isnull(xtxt) then xtxt = "&lt;NULL&gt;"
	end if
	daydateonly = xtxt 
end function
function lclear_button(xname1,xname2,xname3)
	lclear_button = "&nbsp;<a href=# onclick=""var_set('" & xname1 & "', '');var_set('" & xname2 & "', '');var_set('" & xname3 & "', '');return false""><img src='./images/calendar_clear.gif'></a>"
end function
function convert_symbol_yahoo(xticker)
	if isblank(xticker) then
		convert_symbol_yahoo = ""
	else
		yticker = xticker
		yticker = trim(ucase(replace(yticker,".OB", "", 1,-1,1))) 
		yticker = replace(yticker, ".PK", "", 1,-1,1)
		if instr(1, yticker,".") <> 0 then
			if mid(yticker, len(yticker) -1, 1) = "." then yticker = mid(yticker, 1, len(yticker)-2) & "-" & mid(yticker, len(yticker),1)
		end if		
		convert_symbol_yahoo = yticker
	end if	
end function
function get_company_website(xcompany_website, xstock_symbol,xrequest_website)
	if xcompany_website = "" and not isblank(xstock_symbol) then xcompany_website = zget_table("COMPANIES", "IRWEBSITE", "RECORD_STATUS='CURRENT' AND [STOCK_SYMBOL]='" & xstock_symbol & "'")
	if xcompany_website = "" or xcompany_website= "?UNKNOWN?" then xcompany_website = xrequest_website	
	get_company_website = xcompany_website
end function
sub validate_start_end_dates(input_start_date,input_end_date,err_field, err_var,err_tab,err_msg)
	if isdate(input_start_date) and isdate(input_end_date) then
		'br cdate(input_start_date) & ">?" & cdate(input_end_date)
		if cdate(input_start_date) > cdate(input_end_date) then l_errf err_tab,err_var, err_var, err_msg
	end if
end sub	
function show_link(xlist)
	if isnull(xlist) or xlist = "" then 
		xlist2 = ""
	else
		xlista = split(xlist, ",")
		xlist2 = ""
		for xk = lbound(xlista) to ubound(xlista)
			xlist2 = xlist2 & "<a href=company_search.asp?Symbol=" & xlista(xk) & ">" & xlista(xk) & "</a>, "
		next
		xlist2 = mid(xlist2, 1, len(xlist2) - 2)
	end if
	show_link = xlist2
end function
function display_original_source_format(xfilename)
	Dim xml_file, xml, fso
	Set fso = Server.CreateObject("Scripting.FileSystemObject")
	if fso.FileExists(xfilename) then
        Set xml_file = fso.OpenTextFile(xfilename, 1)
        on error resume next
        xml = xml_file.readall
        on error goto 0
    else
        ' br "Does not exist in this directory"
		display_original_source_format = ""
		exit function
    end if
	if instr(1, xml, "</nitf>",1) <> 0 then
		'  acquire media
		i = instr(1, xml, "<hedline>",1)
		if i = 0 then i = 1
		html = mid(xml, i)
		i = instr(1, html, "</nitf>",1)
		xml = mid(html, i)
		html = mid(html, 1, i-1)
	else
		i = instr(1, xml, "<html",1)
		if i <= 0 then i = 1
		html = mid(xml, i)
		'	br showhtml(html)
		if i > 0 then xml = mid(xml, 1,i-1)
	end if
	' display_original_source_format = fix_foreign_characters(html, true)
	html = fix_foreign_characters(html, true)
	end_html_tag_index = instr(1, html, "</html>", 1)
	if end_html_tag_index > 0 then html = mid(html, 1, end_html_tag_index + 6)
	display_original_source_format = html
end function
function display_story(xfilename)
	Set fso = Server.CreateObject("Scripting.FileSystemObject")
	' br "xml_filename: " & xfilename
    if fso.FileExists(xfilename) then
        Set xml_file = fso.OpenTextFile(xfilename, 1)
        on error resume next
        xml = xml_file.readall
        on error goto 0
    else
        ' br "Does not exist in this directory"
		display_story = ""
		exit function
    end if
	if instr(1, xml, "</nitf>",1) <> 0 then
		'  acquire media
		i = instr(1, xml, "<hedline>",1)
		if i = 0 then i = 1
		html = mid(xml, i)
		i = instr(1, html, "</nitf>",1)
		xml = mid(html, i)
		html = mid(html, 1, i-1)
	else
		i = instr(1, xml, "<html",1)
		if i <= 0 then i = 1
		html = mid(xml, i)
		'	br showhtml(html)
		if i > 0 then xml = mid(xml, 1,i-1)
	end if
	' if  this_g_textfile <> "NONE" then html = pop_url(html)
	xml = replace(xml, ">", "&gt;")
	xml = replace(xml, "<", "&lt;")
	xml = replace(xml, chr(10), "<br>")
	xml = replace(xml, "&lt;CategoryCode", "<br>&lt;CategoryCode")
	xml = replace(xml, "&lt;CompanyData", "<br>&lt;CompanyData")
	xml = replace(xml, "&lt;ALERT", "<br>&lt;ALERT")
	display_story = html
end function
function create_bad_parser_ticket(xstory_ref, xdescription, xevent_id)
	dim xticket_id, xticket_status, xticket_assigned_to, xticket_title, xticket_abstract, xticket_updates, xticket_error_message, xticket_attachments, xticket_options, xnotable_differences, xed_sql, xparser_sql, xticket_sql, xhtml_path, xml_path, xticket_path, xdirectory_root, xurl_directory_root, xearnings_dates_url, xweb_url

	set conns3 = Server.CreateObject("ADODB.Connection")
	set xrs_ed = Server.CreateObject("ADODB.RecordSet")
	set xrs_parser = Server.CreateObject("ADODB.RecordSet")
	set xrs_ticket = Server.CreateObject("ADODB.RecordSet")
	connS3.open connStrS3

	if zsystem_top = "CALLERS" then
		xdirectory_root = "\\codeserver\0WSH\ws_callers"
		xurl_directory_root = "https://callers.wallstreethorizon.com"
	else 
		xdirectory_root = "\\codeserver\0WSH\ws_test"
		xurl_directory_root = "https://test.wallstreethorizon.com"
	end if

	xhtml_path = ""
	xml_path = ""
    
    xticket_id = ""
    xticket_status = "1NEW"
    xticket_assigned_to = "JOATES@WALLSTREETHORIZON.COM"
    ' xticket_assigned_to = "ENGINEERING@WALLSTREETHORIZON.COM"
    xticket_title = "BAD PARSE -- EDM" & ":  " & xstory_ref


	xed_sql = "select top(1) time_of_day, earnings_date, quarter, fiscal_year, announcement_url from earnings_dates " &_
			"where pam_ref = '" & xstory_ref & "' and record_status = 'CURRENT'"
	xrs_ed.open xed_sql, connection, 3,3

	xparser_sql = "select top(1) g_stock_symbol, ea_quarter, ea_fiscal_year, ea_date, ea_tod, " &_ 
					"cc_quarter, cc_date, cc_phone1, cc_passcode1, cc_phone2, cc_passcode2, cc_phone3, cc_passcode3, cc_replay_starts, cc_replay_ends, " &_ 
					"g_story_ref, cc_url from pam " &_
			"where g_story_ref = '" & xstory_ref & "'"
	xrs_parser.open xparser_sql, connS3, 3,3

	xhtml_path = xdirectory_root & "\newsware_preannounce\readable_stories\" & xstory_ref & ".html"
	xml_path = xdirectory_root & "\newsware_preannounce\processed_stories\" & xstory_ref & ".xml"
	' xml_path = replace(lcase(xhtml_path), ".html", ".xml")
	' br xml_path
	' response.end

	xnotable_differences = "Notable differences: EARNINGS | PARSER_EARNINGS "

	if not(xrs_parser.eof) then
		if this_stock_symbol <> trim(xrs_parser("g_stock_symbol") & "") then 
			xnotable_differences = xnotable_differences & vbcrlf & "stock_symbol = " & this_stock_symbol & " | stock_symbol = " & xrs_parser("g_stock_symbol")
		end if

		if not(xrs_ed.eof) then
			xweb_url = xrs_ed("announcement_url")
			if isblank(trim(xweb_url)) then xweb_url = xrs_parser("cc_url")

			if xrs_ed("quarter") <> trim(xrs_parser("ea_quarter") & "") then 
				xnotable_differences = xnotable_differences & vbcrlf & "earnings date time_period = " & xrs_ed("quarter") & " | ea_quarter = " & xrs_parser("ea_quarter")
			end if
			
			if xrs_ed("fiscal_year") <> trim(xrs_parser("ea_fiscal_year") & "") then 
				xnotable_differences = xnotable_differences & vbcrlf & "earnings date fiscal_year = " & xrs_ed("fiscal_year") & " | ea_fiscal_year = " & xrs_parser("ea_fiscal_year")
			end if
			
			if fcdate(xrs_ed("earnings_date")) <> fcdate(xrs_parser("ea_date") & "") then 
				xnotable_differences = xnotable_differences & vbcrlf & "earnings_date = " & fcdate(xrs_ed("earnings_date")) & " | ea_date = " & fcdate(xrs_parser("ea_date"))
			end if

			if xrs_ed("time_of_day") <> trim(xrs_parser("ea_tod") & "") then 
				xnotable_differences = xnotable_differences & vbcrlf & "earnings date time_of_day = " & xrs_ed("time_of_day") & " | ea_tod = " & xrs_parser("ea_tod")
			end if
		end if

		if this_quarter <> trim(xrs_parser("cc_quarter") & "") then 
			xnotable_differences = xnotable_differences & vbcrlf & "conf call time_period = " & this_quarter & " | cc_quarter = " & xrs_parser("cc_quarter")
		end if
		
		if fcdate(this_live_call_datetime) <> fcdate(xrs_parser("cc_date") & "") then 
			xnotable_differences = xnotable_differences & vbcrlf & "cc_date = " & fcdate(this_live_call_datetime) & " | cc_date = " & fcdate(xrs_parser("cc_date"))
		end if
		
		if this_live_number <> trim(xrs_parser("cc_phone1") & "") then 
			xnotable_differences = xnotable_differences & vbcrlf & "live_number = " & this_live_number & " | cc_phone1 = " & xrs_parser("cc_phone1")
		end if
		
		if this_live_passcode <> trim(xrs_parser("cc_passcode1") & "") then 
			xnotable_differences = xnotable_differences & vbcrlf & "live_passcode = " & this_live_passcode & " | cc_passcode1 = " & xrs_parser("cc_passcode1")
		end if
		
		if this_live_intl_number <> trim(xrs_parser("cc_phone2") & "") then 
			xnotable_differences = xnotable_differences & vbcrlf & "live_intl_number = " & this_live_intl_number & " | cc_phone2 = " & xrs_parser("cc_phone2")
		end if
		
		if this_live_intl_passcode <> trim(xrs_parser("cc_passcode2") & "") then 
			xnotable_differences = xnotable_differences & vbcrlf & "live_intl_passcode = " & this_live_intl_passcode & " | cc_passcode2 = " & xrs_parser("cc_passcode2")
		end if
		
		if this_replay_number <> trim(xrs_parser("cc_phone3") & "") then 
			xnotable_differences = xnotable_differences & vbcrlf & "replay_number = " & this_replay_number & " | cc_phone3 = " & xrs_parser("cc_phone3")
		end if
		
		if this_replay_passcode <> trim(xrs_parser("cc_passcode3") & "") then 
			xnotable_differences = xnotable_differences & vbcrlf & "replay_passcode = " & this_replay_passcode & " | cc_passcode3 = " & xrs_parser("cc_passcode3")
		end if

		if fcdate(this_replay_start_datetime) <> fcdate(xrs_parser("cc_replay_starts") & "") then 
			xnotable_differences = xnotable_differences & vbcrlf & "replay_start_datetime = " & fcdate(this_replay_start_datetime) & " | cc_replay_starts = " & fcdate(xrs_parser("cc_replay_starts"))
		end if

		if fcdate(this_replay_end_date) <> fcdate(xrs_parser("cc_replay_ends") & "") then 
			xnotable_differences = xnotable_differences & vbcrlf & "replay_end_date = " & fcdate(this_replay_end_date) & " | cc_replay_ends = " & fcdate(xrs_parser("cc_replay_ends"))
		end if
		
		xnotable_differences = replace(xnotable_differences, fcdate("not a date"), "")
		' br xnotable_differences
		' response.end
	else
		' br "something very weird is happening"
		' response.end
	end if

	xrs_ed.close
	xrs_parser.close
			
	xearnings_dates_url = xurl_directory_root & "/earnings_dates.asp?" &_
			"CompanyID=" & this_company_id &_ 
			"&event_id=" & this_event_id &_ 
			"&PAMREF=" & xstory_ref

	if xfield_diffs <> "" then xfield_diffs = vbcrlf & "Diffs: " & vbcrlf

    xticket_abstract = "" &_
		xdescription & vbcrlf & vbcrlf &_ 
		"------------------------------------------------------------------" & vbcrlf & vbcrlf &_ 
		"Parser = EDM" & vbcrlf &_ 
		"Story ref = " & xstory_ref & vbcrlf &_ 
		"Event Id = " & xevent_id & vbcrlf & vbcrlf &_ 
		"Earnings_dates Record Url = " & xearnings_dates_url & vbcrlf & vbcrlf &_ 
		"Readable Story Url = " & xhtml_path & vbcrlf & vbcrlf &_ 
		"Web story Url = " & xweb_url & vbcrlf & vbcrlf &_ 
		xnotable_differences & vbcrlf &_
		""

    xticket_updates = "Created by BAD_PARSER_TICKET.ASP." & vbcrlf & " Story ref = " & xstory_ref & " | " & vbcrlf & " event_id = " & xevent_id & vbcrlf & vbcrlf
    xticket_error_message = ""
    xticket_attachments = ""
    xticket_options = ""

	xticket_id = xupdate_ticket(xticket_id, xticket_status, xticket_assigned_to, xticket_title, xticket_abstract, xticket_updates,  xticket_error_message, xticket_attachments, xticket_options)
	xticket_sql = "select top(1) requestor_login, created_by, updated_by, interested_parties from tickets where ticket_id ='" & xticket_id & "'"
	xrs_ticket.open xticket_sql, connection, 3,3
	if not(xrs_ticket.eof) then
		xrs_ticket("requestor_login") = zthis_login
		xrs_ticket("created_by") = zthis_login
		xrs_ticket("updated_by") = zthis_login
		xrs_ticket("interested_parties") = "eng@wallstreethorizon.com,qa@wallstreethorizon.com"
		xrs_ticket.update
	end if
	xrs_ticket.close

	set xfso = Server.CreateObject("Scripting.FileSystemObject")

	xticket_path = xdirectory_root & "\tickets\ticket_" & xticket_id & "\"

	if not xfso.folderExists(xticket_path) then xfso.CreateFolder(xticket_path)
	
	if file_exists(xhtml_path) and xfso.folderExists(xticket_path) then 
		xfso.copyFile xhtml_path, xticket_path
	end if
	br xml_path
	if file_exists(xml_path) then 
		' br "it exists"
		xfso.copyFile xml_path, xticket_path
	end if

	connS3.close
	set xfso = nothing
	set connS3 = nothing
	' response.end

	create_bad_parser_ticket = xticket_id
end function



' This function will update the Counter_1CL value if it is blank or null in the table
' The identified value will be added to the record itself when the item is saved ("done" button is clicked)
function determine_counter_1CL_value(xcompany_ID, xcreated,xoverwrite)
	Dim rs_previous_conf_calls, sql_previous_conf_calls, current_company_id, current_event_id, comparsion_1CL_count, comparsion_entries_count, current_confidence
	set rs_previous_conf_calls = createObject("adodb.recordset")

	comparsion_1CL_count = 0
	comparsion_entries_count = 0
	current_confidence = 0
	sql_previous_conf_calls = "select top(4) live_url " &_
								"from conf_calls " &_
								"where " &_
								"	record_status = 'current' " &_
								"	and status = 'historical' " &_
								"	and created < '" & xcreated & "'" &_
								"	and company_id = " & xcompany_ID & " " &_
								" order by live_call_datetime desc" &_
								""
	rs_previous_conf_calls.open sql_previous_conf_calls,connection,0,1

	'Note that the created date filter in the previous query prevents records from being counter in their own confidence calculation
	do while rs_previous_conf_calls.eof = false
		comparsion_entries_count = comparsion_entries_count + 1
		xincoming_live_url = rs_previous_conf_calls("live_url")
		
		'check the live url against the list of know 1 click links
		if 	instr(1,xincoming_live_url,"app.webinar.net",1) or _
			instr(1,xincoming_live_url,"channel.royalcast.com",1) or _	
			instr(1,xincoming_live_url,"choruscall",1) or _
			instr(1,xincoming_live_url,"youtube",1) or _
			instr(1,xincoming_live_url,"financialhearings",1) or _
			instr(1,xincoming_live_url,"diamondpassregistration",1) or _
			instr(1,xincoming_live_url,"register",1) or _
			instr(1,xincoming_live_url,"edge.media",1) or _
			instr(1,xincoming_live_url,"engage.vevent",1) or _
			instr(1,xincoming_live_url,"event.onlineseminarsolutions",1) or _
			instr(1,xincoming_live_url,"events.q4inc.com/attendee",1) or _
			instr(1,xincoming_live_url,"event.webcasts",1) or _
			instr(1,xincoming_live_url,"gowebcasting",1) or _
			instr(1,xincoming_live_url,"www.incommglobalevents.com",1) or _
			instr(1,xincoming_live_url,"investcalendar",1) or _
			instr(1,xincoming_live_url,"investis-live",1) or _
			instr(1,xincoming_live_url,"investorcalendar",1) or _
			instr(1,xincoming_live_url,"www.investornetwork/",1) or _
			instr(1,xincoming_live_url,"irbroadstreaming.",1) or _
			instr(1,xincoming_live_url,"merchantcantoscdn",1) or _
			instr(1,xincoming_live_url,"on24",1) or _
			instr(1,xincoming_live_url,"onlinexperiences.com",1) or _
			instr(1,xincoming_live_url,"produceredition.webcasts.com",1) or _
			instr(1,xincoming_live_url,"public.viavid",1) or _
			instr(1,xincoming_live_url,"teams.microsoft",1) or _
			instr(1,xincoming_live_url,"themediaframe",1) or _
			instr(1,xincoming_live_url,"streamfabriken.",1) or _		
			instr(1,xincoming_live_url,"streaming.webcasts",1) or _
			instr(1,xincoming_live_url,"streams.eventcdn.net",1) or _
			instr(1,xincoming_live_url,"streamstudio.",1) or _
			instr(1,xincoming_live_url,"viavid.webcasts",1) or _
			instr(1,xincoming_live_url,"webcaster4",1) or _
			instr(1,xincoming_live_url,"webcastlite.mziq",1) or _
			instr(1,xincoming_live_url,"webcasts.eqs",1) or _
			instr(1,xincoming_live_url,"www.webcast-eqs.com",1) or _
			instr(1,xincoming_live_url,"zoom.us",1) then
				comparsion_1CL_count = comparsion_1CL_count + 1
		end if
		rs_previous_conf_calls.movenext
	loop
	rs_previous_conf_calls.close
	
	'confidence logic calculations
	if comparsion_entries_count = 0 then
		current_confidence = 0
	else
		current_confidence = Fix((comparsion_1CL_count/comparsion_entries_count)*100)
	end if
	if xoverwrite = true then this_counter_1CL = current_confidence
	determine_counter_1CL_value = current_confidence

	set rs_previous_conf_calls = nothing
end function





%>
</div><!-- end of middle -->
<!-- R I G H T  C O N T E N T -->
<!-- start of right -->
		<div id='col-right' class='blue' style='z-index:-1000;'>
		<% if the_ribbon <> "" then %>
		<div id='ribbon_space' style='width:1px;height:40px;z-index:-1000;'>
		</div>
		<%end if%>
		<div id='tabs'>
			<div class='tab_row' >
			<a href='#' name='tab_1' id='tab_1'  class='tab<%=xactive_tab("", "", "1")%>' ><span class='left'></span><span>SEARCH</span><span class='right'></span></a>
	</div> <!-- end of tab_row -->
	<!-- T A B    C O N T E N T -->
			<div name='tab_content_1' id='tab_content_1'  class='tabcontent<%=xactive_tab("", "", "1")%>' style='display:none;'>
				<%this_tab="1"%>
				<h2 class='auto'>Search for Conf Calls</h2>
				<div class='module first noborder'>
				<%
				cr show_filter_screen
				%>
				 </div><!-- end of module first noborder -->
				<div class='btm_narrow_auto'></div><!-- Rounded bottom -->
			</div> <!-- End of content 1 -->
		</div> <!-- conditional end for tabs -->
	</div> <!-- E N D    T A B   C O N T E N T -->
<!-- end of right -->
</div><!-- end of page -->  
</form> 
<div style='display:block;float:right;    position: absolute;
    right: 100px;
    top: 50px;'>
<!--#include file="stickynotes_sidebar_modern.asp" -->
</div>
<!--#include File='./footerV2.asp'-->
<%
if zfinal_script <> "" then cr javascript(zfinal_script)
%>
</div><!-- end of page -->
</body>
<script>
var orig_form = "";
$( document ).ready(function() {
	orig_form = zgetFormVals(main_form, "|qa_flag|qa_notes|mactive_tab|active_tab|zscreen__updates|");
	var newsStoryText = document.getElementById('news_story_text');
	var newsStoryOldFormat = document.getElementById('news_story_old_format');
	toggleTicketDescription()
	applyOverlay('news_story_text', 'news_story_old_format');
	
	if (!!newsStoryOldFormat) {
		displayNewsStoryOldFormat()
	} else if (!!newsStoryText) {
		displayNewsStoryInPage(newsStoryText)
	} else {
	}
});
function unload_form()
	{
	var revised_form = zgetFormVals(main_form, "|qa_flag|qa_notes|mactive_tab|active_tab|zscreen__updates|worklist");
	if (revised_form != orig_form ) document.getElementById("zscreen__updates").value = "CHANGED";
	}
function pop_url(x)
	{
	var website = document.getElementById(x).value;
	var zwebsite = document.getElementById(x).name;
	var zticker = document.getElementById("stock_symbol").value;
	var zyahoo_symbol = document.getElementById("yahoo_symbol").value;
	zticker_prefix = zticker.slice(0,3);
	zticker_cad = zticker.slice(3);
	//window.alert(zticker_prefix);
	// get ticker element create switch for US/CAD
	if (zwebsite == "company_cik") 
		{
		website = "http://www.sec.gov/cgi-bin/browse-edgar?company=&match=&filenum=&State=&Country=&SIC=&owner=exclude&Find=Find+Companies&action=getcompany&CIK=" + website;
		}
	if (zwebsite == "yahoo_website") 
		{
		website = "http://finance.yahoo.com/quote/" + zyahoo_symbol +  "/profile?ltr=1";	
		}
	if (zwebsite == "tmx_website") 
		{
		website = "https://money.tmx.com/en/quote/" + zticker_cad;	
		}
	if (zwebsite == "sedar_issuer_number") 
		{
		//website = "https://www.sedarplus.ca/csa-party/service/create.html?targetAppCode=csa-party&service=searchFilings&_locale=en";
		website = "https://www.sedarplus.ca/csa-party/service/create.html?targetAppCode=csa-party&service=searchFilings&_locale=en";
		}
	popupf(website,1000, 800);
	}
function manage_url()
	{
	website = document.getElementById("url").value;
	if (website != "")
		{
		document.getElementById("pop_url").innerHTML = "<a href='#' onclick=\"popupf('" + website + "',800, 600);return false;\">" +
				"<img src='./images/homepage.png' border=0>&nbsp;</a>";
		document.getElementById("pop_url").style.display="inline-block";	
		}
	else
		document.getElementById("pop_url").style.display="none";	
	}
function showIcons()
	{
	var xwebsite = document.getElementById("company_website").value;
	var xcik = document.getElementById("company_cik").value;
	var xsymbol = document.getElementById("stock_symbol").value;
	var xww_website = document.getElementById("ww_website").value;
	xsymbol_prefix = xsymbol.slice(0,3);
	// window.alert(xsymbol_prefix);
	if (xwebsite != "" )
		{
		if (!!document.getElementById("company_pop_website")) document.getElementById("company_pop_website").style.display="inline-block";
		}
	if (xww_website != "" )
		{
		if (!!document.getElementById("ww_pop_website")) document.getElementById("ww_pop_website").style.display="inline-block";
		}
	if ((xsymbol != "" ) && (xsymbol_prefix != "CA:"))
		{		
		if (!!document.getElementById("yahoo_pop_website")) document.getElementById("yahoo_pop_website").style.display="inline-block";
		if (!!document.getElementById("tmx_pop_website")) document.getElementById("tmx_pop_website").style.display="none";
		}
	if (xsymbol_prefix == "CA:")
		{
		if (!!document.getElementById("tmx_pop_website")) document.getElementById("tmx_pop_website").style.display="inline-block";
		if (!!document.getElementById("yahoo_pop_website")) document.getElementById("yahoo_pop_website").style.display="none";
		}
	if ((xcik != "" )  && (xsymbol_prefix != "CA:"))
		{
		if (!!document.getElementById("company_pop_cik")) document.getElementById("company_pop_cik").style.display="inline-block";
		if (!!document.getElementById("sedar_pop_website")) document.getElementById("sedar_pop_website").style.display="none";
		}
	if (xsymbol_prefix == "CA:" )
		{
		if (!!document.getElementById("sedar_pop_website")) document.getElementById("sedar_pop_website").style.display="inline-block";
		if (!!document.getElementById("company_pop_cik")) document.getElementById("company_pop_cik").style.display="none";
		}
	}
function setCallbackDate() {
	var earningsDateElement = document.getElementById("this_edate");
	if (!!earningsDateElement && !!earningsDateElement.value ) {
		var callbackDate = new Date(earningsDateElement.value);
		callbackDate.setDate(callbackDate.getDate() - 2)
		document.getElementById("callback_date").value = mmddyyyy(callbackDate)
	}
}
function setOneClickLink() {
	var liveURLElement = document.getElementById("live_url");
	var oneClickLinkNo = $("#one_click_link")[0];
	var oneClickLinkYes = $("#one_click_link").siblings()[0];
	if (!!liveURLElement && !!liveURLElement.value) {
		if (!!liveURLElement.value.match(/choruscall|register|app.webinar.net|edge.media|engage.vevent|event.onlineseminarsolutions|event.webcasts|gowebcasting|youtube|financialhearings|investcalendar|investis-live|on24|public.viavid|themediaframe|webcaster4|investorcalendar|streamstudio.|irbroadstreaming.|streamfabriken.|webcastlite.mziq|diamondpassregistration|streaming.webcasts|viavid.webcasts|merchantcantoscdn|webcasts.eqs|www.investornetwork\/|channel.royalcast.com|events.q4inc.com\/attendee|onlinexperiences.com|produceredition.webcasts.com|us02web.zoom.us|zoom.us|www.webcast-eqs.com|www.incommglobalevents.com|streams.eventcdn.net|teams.microsoft|teams.microsoft.com/)) {
			oneClickLinkYes.checked = true;
		} else {
			oneClickLinkNo.checked = true;
		}
	} else {
		oneClickLinkNo.checked = false;
		oneClickLinkYes.checked = false;
	}
}
(function () { 
	if (!!document.getElementById("pam_ref") && !!document.getElementById('pam_ref').value) setOneClickLink();
})()
function changeOneClickAlert() {
	//alert("One click buttons are pre-populated based on the url. Please alert a manager if the the one click buttons are are not automatically correct so we can build it into the system. If you clicked this by mistake then please click on the Live URL field to make the system reset the buttons. Thank you!")
}
function all_conf_calls_helper() {
	let this_company_id = document.getElementById('company_id').value;
	let this_event_id = document.getElementById('event_id').value;
	let url = './conf_calls_all_conf_calls_tab.asp?company_id=' + this_company_id + '&event_id=' + this_event_id;
	return ajaxTabHelper(url, 'all_conf_calls_div')
}
function displayNewsStoryInPage(url) {
	$('#parsed_text').addClass('news-story-text')
	$('#parsed_text').removeClass('news-story-old-format')
	$('#news_icon_wrapper').css('filter', '');
	$('#news_icon_wrapper_old_format').css('filter', 'grayscale(100%)');
	let containsNews = $('#parsed_text_container').data('containsNews');
	if (containsNews === 'news_story_text') {
		// $('#stick_form').hide()
		$('#parsed_text_container').show()
		return;
	}
			console.log('running')
	let newsStoryText = $('#news_story_text').html()
	if (!!newsStoryText) {
		$('#parsed_text_container').data('containsNews', 'news_story_text');
		// $('#stick_form').hide()
		$('#parsed_text').html(newsStoryText)
		$('#parsed_text_container').show()
	}
}
function displayNewsStoryOldFormat() {
	$('#parsed_text').addClass('news-story-old-format')
	$('#parsed_text').removeClass('news-story-text')
	$('#news_icon_wrapper_old_format').css('filter', '');
	$('#news_icon_wrapper').css('filter', 'grayscale(100%)');
	let containsNews = $('#parsed_text_container').data('containsNews');
	if (containsNews === 'news_story_old_format') {
		// $('#stick_form').hide()
		$('#parsed_text_container').show()
		return;
	}
	let newsStoryOldFormat = $('#news_story_old_format').html()
	if (!!newsStoryOldFormat) {
		$('#parsed_text_container').data('containsNews', 'news_story_old_format');
		// $('#stick_form').hide()
		$('#parsed_text').html(newsStoryOldFormat)
		$('#parsed_text_container').show()
	}
}
function hideNewsStoryInPage() {
	$('#parsed_text_container').hide()
	$('#stick_form').show()
}
$('#parsed_text_container').mousedown(function(e){
	$('#parsed_text_container').css('background-color', 'white');
});
$(function(){
	// documentation can be found here: https://swisnl.github.io/jQuery-contextMenu//
	const dateIcon = 'fa-calendar-day'
	const timeIcon = 'fa-clock'
	const strIcon  = 'fa-pencil-alt'
	const addIcon  = 'fa-pencil-alt'
	// field lists (if not supplied by parser)
	const dateFields = 'live_call_date,replay_start_date,replay_end_date,rebroadcast_enddate';
	const timeFields = 'announce_time'
	const strFields  = 'quarter,fiscal_year,live_number,live_passcode,live_intl_number,live_intl_passcode,live_url,replay_number,replay_passcode,replay_reservation_id,notes,external_notes'
	const allOrderedFields = 'quarter,fiscal_year,live_call_date,live_number,live_passcode,live_intl_number,live_intl_passcode,live_url,replay_start_date,replay_end_date,replay_number,replay_passcode,replay_reservation_id,rebroadcast_enddate,external_notes,notes'
	
	const allFieldsList = [...dateFields.split(','), ...timeFields.split(','), ...strFields.split(',')]
	const dateItems = buildItems(dateFields, dateIcon)
	const timeItems = buildItems(timeFields, timeIcon)
	const strItems = buildItems(strFields, strIcon)
	const combinedItems = {
		...dateItems,
		...timeItems,
		...strItems
	}
	const allItems = allOrderedFields.split(',').reduce(function(acc, field) {
		var id = '#' + field;
		acc[id] = combinedItems[id]
		return acc
	}, {})
	
	allItems['#copy_to_clipboard'] = {name: 'Copy to Clipboard', icon: ''}
	allItems['sep1'] = '---------'
	allItems['quit'] = {name: 'Quit', icon: function($element, key, item){ return 'context-menu-icon context-menu-icon-quit'; }}
	// const allItems = {
	// 	...dateItems,
	// 	...timeItems,
	// 	...strItems,
	// 	'sep1': '---------',
	// 	'quit': {name: 'Quit', icon: function($element, key, item){ return 'context-menu-icon context-menu-icon-quit'; }}
	// }
	const noSelectedItems = {
		'noSelected': {
			name: 'Highlight text or hover over a keyword to use the menu.', 
			icon: function($element, key, item){ return 'context-menu-icon context-menu-icon-quit'; }, 
			callback: function(){ return true }
		}
	}
    $.contextMenu({
        selector: '#parsed_text_container',
		build: function($trigger, e) {
			e.stopPropagation();
			let highlightedText = window.getSelection().toString().trim();
			if (highlightedText == '') return {items: noSelectedItems};
			return {
				callback: clickMenuItem,
				items: allItems
			}
		} 
    });
	$.contextMenu({
        selector: '.parser-keyword', 
		trigger: 'hover',
		autoHide: true,
        build: function($trigger, e) {
			e.stopPropagation();
			let el = $(e.target);
			let fieldList = el.data('field-list');
			let fieldType = getFieldType(el);
			let defaultIcon = getIcon(fieldType);
			let items = buildItems(fieldList, defaultIcon)
			let highlightedText = window.getSelection().toString().trim();
			let events = {};
			let hideMenu = () => false;
			if ($.isEmptyObject(items) || highlightedText != '') {
				items = allItems;
				events.show = hideMenu;
			}  else {
				items.fieldValue = el.data('field-value')
				if (!items.fieldValue) items.fieldValue = el.html()
			}
            return {
                callback: clickMenuItem,
                items,
				events
            };
        }
    });
	function buildItems(fieldList, defaultIcon) {
		if (!fieldList) return {};
		let fields = fieldList.split(',');
		let filteredFields = fields.filter(field => allFieldsList.includes(field))
		let items =  filteredFields.reduce( (itemObj, field) => ({
			...itemObj,
			[`#${field}`]: {name: itemName(field), icon: defaultIcon}
		}), {});
		items['#copy_to_clipboard'] = {name: 'Copy to Clipboard', icon: ''}
		if (fieldList.includes('url')) items['#goto_url'] = {name: 'Go To URL', icon: ''} 
		return items;
	}
	function getFieldType(e) {
		let el = $(e)
		if ( el.hasClass('field-type-str') ) return 'str';
		if ( el.hasClass('field-type-date') ) return 'date';
		if ( el.hasClass('field-type-time') ) return 'time';
		if ( el.hasClass('field-type-money') ) return 'money';
		if ( el.hasClass('field-type-url') ) return 'url';
		if ( el.hasClass('field-type-phone-number') ) return 'phone-number';
		if ( el.hasClass('field-type-address ') ) return 'address ';
		if ( el.hasClass('field-type-weekday') ) return 'weekday';
	}
	function getIcon(fieldType) {
		var icon;
		switch(fieldType) {
			case 'date':
				icon = dateIcon
				break;
			case 'time':
				icon = timeIcon
				break;
			case 'str':
			case 'money':
			case 'url':
			case 'phone-number':
			case 'address':
				icon = strIcon
				break;
			case 'weekday':
				icon = strIcon
				break;
		}
		return icon
	}
	function itemName(fieldId) {
		if (fieldId === 'quarter_end_date') return 'Time Period End Date'
		if (fieldId === 'quarter') return 'Time Period'
		return titleCase(fieldId);
	}
	function titleCase(str) {
		return str.toLowerCase().split('_').map(function(word) {
			if (word.length > 0) return word.replace(word[0], word[0].toUpperCase());
			return ''
		}).join(' ');
	}
});
function clickMenuItem(key, options) {
	let fieldValue = options.items.fieldValue;
	if (!!fieldValue && key === '#goto_url') {
		if (fieldValue.toLowerCase().includes('http')){
			window.open(fieldValue,"", "width=700,height=700");
		} else {
			window.open('https://' + fieldValue,"", "width=700,height=700");
		}
		return 'goto_url'
	}


	var txt = fieldValue || window.getSelection().toString().trim()
	var copySuccess = true;

	if (key === '#copy_to_clipboard') return (async () => {await navigator.clipboard.writeText(txt);})();
	if (!!fieldValue && key !== '#announce_datetime') return copyExact(key, fieldValue);

	switch(key) {
		case '#time_of_day':
			var permittedValues = ['Before Market', 'During Market', 'After Market', 'Unspecified'];
			copySuccess = copyToSelectMenu(key, txt, permittedValues);
			break;
		case '#quarter':
			var permittedValues = ['Q1', 'Q2', 'Q3', 'Q4', 'H1', 'H2'];
			copySuccess = copyToSelectMenu(key, txt, permittedValues);
			break;
		case '#fiscal_year':
			var permittedValues = ['2009', '2010', '2011', '2012', '2013', '2014', '2015', '2016', '2017', '2018', '2019', '2020', '2021', '2022', '2023'];
			copySuccess = copyToSelectMenu(key, txt, permittedValues);
			break;
		case '#live_call_datetime':
		case '#replay_start_datetime':
			copySuccess = copyDatetime(key, txt)
			break;
		case '#replay_end_date':
		case '#rebroadcast_enddate':
			copySuccess = copyDate(key, txt)
			break;
		case '#live_number':
		case '#replay_number':
		case '#live_url':
		case '#replay_reservation_id':
			copyExact(key, txt);
			break;
		case '#live_passcode':
		case '#live_intl_passcode':
		case '#replay_passcode':
			copyExact(key, txt.trim());
			break;
		case '#notes':
		case '#external_notes':
			appendExact(key, txt);
	}
	if (copySuccess === false) $('#parsed_text_container').css('background-color', 'yellow')
	return copySuccess;
}
function copyExact(selector, text){
	return $(selector).val(text);
}
function appendExact(selector, text) {
	let appendText;
	let currentVal = $(selector).val();
	if (currentVal.slice(-1) === ' '  || text[0] === ' ') {
		appendText = text
	} else {
		appendText = ' ' + text
	}
	return $(selector).val(currentVal + appendText)
}
function copyDate(selector, text) {
	let words = text.split(' ');
	let filteredWords = words.filter(allowedDateWord)
	let filteredText = filteredWords.join(' ')
	let date = new Date(filteredText);
	let shortDate = date.formatShortDate();
	if (shortDate.includes('NaN')) return false;
	if (!selector) return shortDate;
	return $(selector).val(shortDate);
}
function copyTime(selector, text) {
	let words = text.split(' ');
	let filteredWords = words.filter(allowedTimeWord);
	let timeString = filteredWords.join(' ');
	if (filteredWords.length > 2) return false;
	if (timeString.length < 1) return false;
	if (timeString.includes(':') === false) return false;
	if (!selector) return shortDate;
	return $(selector).val(timeString);
}
function copyDatetime(selector, text) {
	var currentDatetime = $(selector).val();
	var [selectedDate, selectedTime] = parseDatetime(text)
	var [currentDate, currentTime] = parseDatetime(currentDatetime)
	var dateString = (!!selectedDate) ? copyDate(null, selectedDate) : currentDate
	var timeString = (!!selectedTime) ? copyTime(null, selectedTime) : currentTime
	if (!dateString) dateString = ''
	if (!timeString) timeString = ''
	return $(selector).val(dateString + ' ' + timeString)
}
function parseDatetime(text) {
	var dateString, timeString
	let array = text.trim().split(' ')
	if (array[0].includes(':')) {
		timeString = text
	} else if (array[0].includes('/')) {
		dateString = array.shift()
		timeString = array.join(' ')
	}
	return [dateString, timeString]
}
function copyToSelectMenu(selector, text, permittedValues){
	let lcaseText = text.toLowerCase();
	for (var permittedValue of permittedValues) {
		if (lcaseText.includes(permittedValue)) return $(selector + ' option[value="' + permittedValue + '"').prop('selected', true);
	}
	return false;
}
function allowedDateWord(word){
	word = word.replace(',', '')
	word = word.replace('.', '')
	if (word.match(/january|february|march|april|may|june|july|august|september|october|november|december/gi)) return true;
	if (word.match(/^\d+$/)) return true; //numbers only
	if (word.match(/\d+\/\d+\/\d{4}/)) return true; //numbers only
	return false;
}
function allowedTimeWord(word){
	if (word.match(/\d\:\d\d/)) return true;
	if (word.match(/\d\d\:\d\d/)) return true;
	if (word.match(/\d\:\d\d\:\d\d/)) return true;
	if (word.match(/\d\d\:\d\d\:\d\d/)) return true;
	if (word.match(/AM|PM/i)) return true;
	return false;
}
Date.prototype.formatShortDate = function(){
    return (twoDigits(this.getMonth() + 1)) + 
    "/" +  twoDigits(this.getDate()) +
    "/" +  this.getFullYear();
}
function twoDigits(int) {
	return int <= 9 ? `0${int}` : `${int}`;
}
$(function() {
	$("#parsed_text_container").draggable({handle: "#parsed_text_container_header"});
});
function increase_parsed_text_size() {
	let selector;
	if ($('#parsed_text').hasClass('news-story-text')) {
		selector = '#news_story_text__inner'
	} else if ($('#parsed_text').hasClass('news-story-old-format')) {
		selector = '#news_story_old_format__inner'
	} else {
		selector = '#parsed_text'
	}
	// debugger
	let oldFontSize = $(selector).css('font-size');
	let oldNumber = Number(oldFontSize.toLowerCase().replace('px', ''));
	let newFontSize = (oldNumber + 2) +'px'
	return $(selector).css('font-size', newFontSize);
}
function decrease_parsed_text_size() {
	let selector;
	if ($('#parsed_text').hasClass('news-story-text')) {
		selector = '#news_story_text__inner'
	} else if ($('#parsed_text').hasClass('news-story-old-format')) {
		selector = '#news_story_old_format__inner'
	} else {
		selector = '#parsed_text'
	}
	let oldFontSize = $(selector).css('font-size');
	let oldNumber = Number(oldFontSize.toLowerCase().replace('px', ''));
	let newFontSize = (oldNumber - 2) +'px'
	return $(selector).css('font-size', newFontSize);
}
function popStoryNewTab() {
	let html = $('#parsed_text').html()
	let stylesheet = '<link rel="stylesheet" type="text/css" href=".\\css\\parser_keywords.css?v=1" media="screen"/>'
	var wnd = window.open();
	wnd.document.write(stylesheet);
	wnd.document.write(html);
	// wnd.focus()
}
function toggleTicketDescription() {
	if (!document.getElementById('create_parser_ticket')) return;
	if (document.getElementById('create_parser_ticket').checked) {
		$('#create_parser_ticket').val('Y');
		$('#parser_ticket_description_trf').show();
	} else {
		$('#create_parser_ticket').val('N');
		$('#parser_ticket_description_trf').hide();
	}
}
$('#create_parser_ticket').click(toggleTicketDescription)
</script>
<SCRIPT LANGUAGE="JavaScript">
<!-- Begin
function dupe_url() 
	{
	live_url = document.getElementById("live_url").value;
	goto_url = document.getElementById("replay_url").value;
	if (goto_url == "") 
		{
		document.getElementById("replay_url").value = live_url;
		}	
	if (live_url == "") 
		{
		document.getElementById("live_url").value = goto_url;
		}
	}
//  End -->
</script>
<SCRIPT LANGUAGE="JavaScript">
<!-- Begin
function dupe_int() 
	{
	usphn = document.getElementById("live_number").value;
	intphn = document.getElementById("live_intl_number").value;
	if (intphn == "") 
		{
		document.getElementById("live_intl_number").value = usphn;
		document.getElementById("live_intl_passcode").value = document.getElementById("live_passcode").value;
		}
	}
//  End -->
</script>
<script LANGUAGE="JavaScript">
<!-- Begin
function dupe_date() 
	{
	calldate = document.getElementById("live_call_datetime").value;
	replaydate = document.getElementById("replay_start_datetime").value;
	if (replaydate.trim() == "") 
		{
		document.getElementById("replay_start_datetime").value = calldate;
		//document.main_form.goto_broadcast_starttime.value = document.main_form.conferencecalltime.value
		}
	}
//  End -->

async function paste_from_clipboard(xname)
	{
	var snipette = await navigator.clipboard.readText();
	//console.log('pasting text: ' + snipette);
	document.getElementById(xname).value = snipette;
	
	
	//navigator.clipboard.readText().then(
	//	(clipText) => document.getElementById(xname).value = clipText);
	
	
	return false;
	}
</script>
</html>
