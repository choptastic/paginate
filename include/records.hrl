-record(paginate, {?ELEMENT_BASE(element_paginate),
		delegate						:: module(),
		tag								:: term(),
		page=1							:: integer(),
		perpage=20						:: integer(),
		num_items=0						:: integer(),
		search_button_text="Search"		:: text(),
		reset_button_text="Reset"		:: text(),
		perpage_options=[10,20,50,100]	:: [integer()],
        middle_filters=[]               :: body(),
		body=[]							:: body(),
		perpage_format="~B per page"	:: text(),
        show_search=true                :: boolean(),
        show_perpage=true               :: boolean(),
        search_button_id                :: id()
	}).

-record(paginate_event, {
		body=[]							:: body(),
		items=0							:: integer()
	}).
