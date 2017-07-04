[![Build Status](https://travis-ci.org/FHG-IMW/epo-ops.svg?branch=master)](https://travis-ci.org/FHG-IMW/epo-ops)
[![Code Climate](https://codeclimate.com/github/FHG-IMW/epo-ops/badges/gpa.svg)](https://codeclimate.com/github/FHG-IMW/epo-ops)

# epo-ops
Ruby interface to the EPO Open Patent Services (OPS).

[Documentation can be found here](http://www.rubydoc.info/gems/epo-ops/)

The EPO provides [playground](https://developers.epo.org/), where you can try
out the methods. As well as [Documentation](https://www.epo.org/searching-for-patents/technical/espacenet/ops.html)
of the different endpoints and detailed usage (see the 'Downloads' section).

# Usage

## Authentication
In order to use this gem you need to register at the [EPO for
OAuth](https://developers.epo.org/user/register).
Use your credentials by configuring

```ruby
Epo::Ops.configure do |conf|
  conf.consumer_key = "YOUR_KEY"
  conf.consumer_secret = "YOUR_SECRET"
end
```

## Quickstart
### Search for Patents

Get references to all Patents on a given date and IPC-class:

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
