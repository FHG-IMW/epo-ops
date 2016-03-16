[![Build Status](https://travis-ci.org/FHG-IMW/epo-ops.svg?branch=master)](https://travis-ci.org/FHG-IMW/epo-ops)
[![Code Climate](https://codeclimate.com/github/FHG-IMW/epo-ops/badges/gpa.svg)](https://codeclimate.com/github/FHG-IMW/epo-ops)

# epo-ops
Ruby interface to the EPO Open Patent Services (OPS).

[Full documentation can be found here](http://www.rubydoc.info/gems/epo-ops/)



# Usage

## Quickstart
In order to use this gem you need to register at the [EPO for
OAuth](https://developers.epo.org/user/register).

Then simply install this gem and start a ruby console.
```
$ gem install epo-ops
$ irb
```

require the gem and use your OPS credentials to retrieve for example a single patent.

```ruby
require 'epo/ops'

Epo::Ops.configure do |conf|
  conf.consumer_key = "YOUR_KEY"
  conf.consumer_secret = "YOUR_SECRET"
end

patent = Epo::Ops::Register.raw_biblio('EP1000000', 'publication')
```
The temporary access token is kept in memory for subsequent retrievals. To share this between several processes the
token storage strategy may be changed as shown in `epo/ops/token_store` for redis.

## Advanced Usage
### Search for all Patents on a given Date

Get references to all Patents on a given date and IPC-class is not as easy as it seems. The OPS-API will not return
more than 2000 patents for a given search and suprisingly it does not support the usual offset+limit approach. Therefor
if on a given date more than 2000 patents are available the search has to be partitioned to retrieve them all. This
gem does this automatically by using the different IPC-classes (and subclasses if necessary).

```ruby
Epo::Ops::Register.search("A", Date.new(2016,2 ,3))
# or for all ipc classes
Epo::Ops::Register.search(nil, Date.new(2016,2 ,3))
```

You can now retrieve the bibliographic entries of all these:

```ruby
references = Epo::Ops::Register.search(nil, Date.new(2016,2 ,3))
references.map { |ref| Epo::Ops::Register.biblio(ref) }
```
This will return an object that helps parsing the result. See the documentation
for more information

Note that both operations take a considerable amount of time. Also you may not
want to develop and test with many of these requests, as they can quite quickly
excess the API limits. Also note that this methods use the `application`
endpoint.

## Custom Retrieval

### #raw_search
This allows you to build your own CQL query, as
described in the official documentation. With the second parameter set
to true you can get the raw result as a nested Hash, if you want to
parse it yourself.

```ruby
Epo::Ops::Register.raw_search("q=pd=20160203 and ic=D&Range=1-100", true)
```

### #raw_biblio
If you do not want to retrieve via the `application` endpoint (say you want
`publication`) this method gives you more fine-grained control. Make sure the
`reference_id` you use matches the type.

```ruby
Epo::Ops::Register.raw_biblio('EP1000000', 'publication')
```

# Further Reading

The EPO provides [a developer playground](https://developers.epo.org/), where you can test-drive the OPS-API.
They also provide extensive [documentation](https://www.epo.org/searching-for-patents/technical/espacenet/ops.html)
of the different endpoints and how to use them (see the 'Downloads' section).