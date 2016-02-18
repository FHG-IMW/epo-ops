[![Build Status](https://travis-ci.org/FHG-IMW/epo-ops.svg?branch=master)](https://travis-ci.org/FHG-IMW/epo-ops)
[![Code Climate](https://codeclimate.com/github/FHG-IMW/epo-ops/badges/gpa.svg)](https://codeclimate.com/github/FHG-IMW/epo-ops)

# epo-ops
Ruby interface to the EPO Open Patent Services (OPS)
You can play around with the API [here](https://developers.epo.org/).
Documentation of it can be found [here](https://www.epo.org/searching-for-patents/technical/espacenet/ops.html) under `Downloads`.

# Usage

## Authentification
In order to use this gem you need to register at the EPO for OAuth
[here](https://developers.epo.org/user/register).
Use your credentials by configuring
```ruby
Epo::Ops.configure do |conf|
  conf.consumer_key = "YOUR_KEY"
  conf.consumer_secret = "YOUR_SECRET"
end
```

## What works up to now
* Search the EPO OPS register with `Epo::Ops::Register.search(query)`; use `Epo::Ops::SearchQueryBuilder` to build an appropriate request.
* Get bibliographic info from the register, both for application and publication references (which you may retrieve with the search).
* Bulk searching for all patents on a given date wih `Epo::Ops::Register::Bulk.all_queries(date)`. Note that patents are usually published on Wednesdays, if you find some on another weekday, please let us know.
   This method currently returns all queries necessary to find all patents with `Epo::Ops::Register.search`

### #search
Use the `SearchQueryBuilder` to set up the queries. By default structs are returned that should make it easier to work with the results, but with the `raw`-flag set to true you may also retrieve the resulting hash and parse it yourself.
The results have the method `#epodoc_reference` which perfectly fits into `#biblio`

### #biblio
With `Epo::Ops::Register.biblio(reference\_id)` you can retrieve the bibliographic entry for the given patent (see OPS documentation). By default it searches the `/application/` endpoint, but you may set `publication` as the second parameter. Make sure the `reference\_id` matches the given type. The last optional parameter allows you to set another format the id, but the default `epodoc` is strongly advised. This format is also provided from search results with `#epodoc_reference`.
