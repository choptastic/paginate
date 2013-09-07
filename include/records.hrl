-record(paginate, {?ELEMENT_BASE(element_paginate),
		delegate						:: module(),
		tag								:: term(),
		page=1							:: integer(),
		perpage=20						:: integer(),
		num_items=0						:: integer(),
		search_button_text="Search"		:: text(),
		reset_button_text="Reset"		:: text(),
		perpage_options=[10,20,50,100]	:: [integer()],
		body=[]							:: body(),
		perpage_format="~B per page"	:: text()
	}).

-record(paginate_event, {
		body=[]							:: body(),
		items=0							:: integer()
	}).
