# paginate

A pagination element plugin for [Nitrogen Web Framework](http://nitrogenproject.com) ([GitHub](http://github.com/nitrogen/nitrogen))

## Installing into a Nitrogen Application

Add it as a rebar dependency by adding into the deps section of rebar.config:

```erlang
	{paginate, ".*", {git, "git://github.com/choptastic/paginate.git", {branch, master}}}
```

### Using Nitrogen's built-in plugin installer (Requires Nitrogen 2.2.0)

Run `make` in your Application. The rest should be automatic.

### Manual Installation (Nitrogen Pre-2.2.0)

Run the following at the command line:

```shell
	./rebar get-deps
	./rebar compile
```

Then add the following includes into any module requiring the form

```erlang
	-include_lib("paginate/include/records.hrl").
```

## Usage

Add the following to the body of a page

```erlang
	#paginate{
		tag=search,
		perpage=20,
	}
```

Then add a `paginate_event/4` function to your page (be sure it's exported) which returns a `#paginate_event` record:

```erlang
paginate_event(Tag, SearchText, PerPage, Page) ->
	NumberOfResults = my_search_module:count(SearchText),
	FormattedResults = my_search_module:format(SearchText),
	#paginate_event{body=FormattedResults, items=NumberOfResults}.
```

`paginate_event/4` must return a `#paginate_event` record containing a `body` and `items`, which is simply the *total* number of matching elements satisifed by the `SearchText`.

## Element Attributes

+ `tag` = The `Tag` value that will be passed to `Module:paginate_event/4`
+ `delegate` = The module to post the `paginate_event/2` function
+ `class` = The class of the wrapper div
+ `body` = The contents of the page with a blank search results.
+ `num_items` = The *total* number of initial matching items.
+ `textbox_class` = The class of the search textbox
+ `perpage_option` = List of integers representing the options available for the "X per page" drop down, allowing the user to change the number of pages allowed
+ `perpage_format` = The string passed to `io_lib:format` to format the "Per Page" option text (default: `"~B per page"`)
+ `search_button_text` = The text labeling the "Search Button". (Default: `"Search"`)
+ `reset_button_text` = The text labeling the "Reset Button". (Default `"Reset"`)

## Example

You can see it in use at http://slides.sigma-star.com and the associated code at: [code](https://github.com/choptastic/sliderl/blob/master/src/pages/index.erl).

## License

Copyright (c) 2013, [Jesse Gumm](http://sigma-star.com/page/jesse)
([@jessegumm](http://twitter.com/jessegumm))

MIT License
