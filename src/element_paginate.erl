%% vim: ts=4 sw=4 et
-module (element_paginate).
-include_lib("nitrogen_core/include/wf.hrl").
-include("records.hrl").
-export([
    reflect/0,
    render_element/1,
    refresh/1,
    event/1
]).

-record(paginate_postback, {
        delegate, 
        mode=normal,
        tag,
        page=1,
        search_text_id,
        reset_button_id,
        page_id,
        bottom_page_id,
        perpage_id,
        body_id
    }).

reflect() -> record_info(fields, paginate).

render_element(Rec = #paginate{}) ->
    SearchTextID = wf:temp_id(),
    BodyID = wf:temp_id(),
    PageID = wf:temp_id(),
    BottomPageID = wf:temp_id(),
    PerPageID = wf:temp_id(),
    ResetButtonID = wf:temp_id(),
    
    Tag = Rec#paginate.tag,
    Delegate = Rec#paginate.delegate,
    CurPage = Rec#paginate.page,
    PerPage = Rec#paginate.perpage,
    ID = Rec#paginate.id,

    Postback = #paginate_postback{
        delegate=Delegate,
        mode=normal,
        search_text_id=SearchTextID,
        reset_button_id=ResetButtonID,
        page_id=PageID,
        bottom_page_id=BottomPageID,
        perpage_id=PerPageID,
        body_id=BodyID,
        tag=Tag,
        page=CurPage
    },

    RefreshPostback = Postback#paginate_postback{mode={refresh,""}},
    set_refresh_postback(Tag,RefreshPostback),

    PostbackEvents = #event{type=click, delegate=?MODULE, postback=Postback},

    NumPages = total_pages(Rec#paginate.num_items,Rec#paginate.perpage),
    
    PageSelectorPanel = #panel{
        class=paginate_page_list,
        body=page_selector(CurPage, NumPages, Postback)
    },

    Terms = #panel{
        id=ID,
        class=[paginate, Rec#paginate.class],
        style=Rec#paginate.style,
        body=[
            #panel{class=paginate_header,body=[
                #singlerow{cells=[
                    #tablecell{body=[
                        #panel{class=paginate_header_search,body=[
                            #panel{class='col-lg-4', body=[
                                #panel{class='input-group',body=[
                                    #textbox{class='form-control',id=SearchTextID,postback=Postback,delegate=?MODULE},
                                    #span{class='input-group-btn',body=[
                                        #button{
                                            text=Rec#paginate.search_button_text,
                                            postback=Postback,
                                            delegate=?MODULE,
                                            class=[btn,'btn-default']
                                        },
                                        #button{
                                            id=ResetButtonID,
                                            text=Rec#paginate.reset_button_text,
                                            class=[paginate_reset_button,btn,'btn-warning'],
                                            style="display:none",
                                            click=[
                                                #fade{},
                                                #set{target=SearchTextID,value=""},
                                                #event{delegate=?MODULE,postback=Postback#paginate_postback{mode=reset}}
                                            ]
                                        }
                                    ]}
                                ]}
                            ]}
                        ]}
                    ]},
                    #tablecell{body=[
                        #spinner{class=paginate_spinner}
                    ]},
                    #tablecell{body=[
                        #panel{class=paginate_perpage_wrapper,body=[
                            #dropdown{
                                id=PerPageID,
                                %class='form-control',
                                options=[perpage_option(PerPage,N,Rec#paginate.perpage_format) || N <- Rec#paginate.perpage_options],
                                actions=PostbackEvents
                            }
                        ]}
                    ]}
                ]}
            ]},
            PageSelectorPanel#panel{id=PageID},
            #panel{id=BodyID, body=Rec#paginate.body},
            PageSelectorPanel#panel{id=BottomPageID}
        ]
    },
    element_panel:render_element(Terms).

perpage_option(PerPage,Num,Format) ->
    #option{value=wf:pickle(Num),text=wf:f(Format,[Num]),selected=PerPage==Num}.

page_selector(_, 0, _) ->
    [];
page_selector(_, 1, _) ->
    [];
page_selector(Selected, NumPages, Postback) ->
    ["Pages: ",[[" ",page_link(Current, Selected, Postback)] || Current <- lists:seq(1,NumPages)]].

page_link(Selected, Selected, _Postback) ->
    #span{class=paginate_current, text=wf:to_list(Selected)};
page_link(Current, _Selected, Postback) ->
    #link{
        text=wf:to_list(Current),
        class=paginate_page,
        postback=Postback#paginate_postback{page=Current},
        delegate=?MODULE
    }.
    
total_pages(TotalItems, PerPage) ->
    _TotalPages = (TotalItems div PerPage) + ?WF_IF(TotalItems rem PerPage == 0, 0, 1).

set_refresh_postback(Tag,Postback) ->
    wf:state({paginate_refresh_postback,Tag},Postback).

get_refresh_postback(Tag) ->
    wf:state({paginate_refresh_postback,Tag}).

refresh(Tag) ->
    Postback = get_refresh_postback(Tag),
    event(Postback).

event(Postback = #paginate_postback{
                mode=Mode,
                perpage_id=PerPageID,
                search_text_id=SearchTextID,
                reset_button_id=ResetButtonID,
                body_id=BodyID,
                page_id=PageID,
                bottom_page_id=BottomPageID,
                tag=Tag,
                page=Page,
                delegate=Delegate}) ->
    PerPage = wf:depickle(wf:q(PerPageID)),

    SearchText = case Mode of
        reset -> "";
        normal -> wf:q(SearchTextID);
        {refresh,Text} -> Text
    end,

    RefreshPostback = Postback#paginate_postback{mode={refresh,SearchText}},
    set_refresh_postback(Tag,RefreshPostback),

    Module = wf:coalesce([Delegate,wf:page_module()]),

    case Module:paginate_event(Tag, SearchText, PerPage, Page) of
        #paginate_event{body=NewBody, items=NewItems} ->
            TotalPages = total_pages(NewItems, PerPage),
            PageSelector = page_selector(Page, TotalPages, Postback),

            wf:update(BodyID, NewBody),
            wf:update(PageID, PageSelector),
            wf:update(BottomPageID, PageSelector),
            case SearchText of
                [] -> wf:wire(ResetButtonID,#fade{});
                _ -> wf:wire(ResetButtonID,#appear{})
            end,
            ok;
        _ ->
            throw({invalid_event_response,"Response from ~p:paginate_event/4 must be a #paginate_event record"})
    end.



