# epo-ops
Ruby interface to the EPO Open Patent Services (OPS)

## Status

[![Build Status](https://travis-ci.org/FHG-IMW/epo-ops.svg?branch=master)](https://travis-ci.org/FHG-IMW/epo-ops)
[![Code Climate](https://codeclimate.com/github/FHG-IMW/epo-ops/badges/gpa.svg)](https://codeclimate.com/github/FHG-IMW/epo-ops)

# Authentification
In order to use this gem you need to register at the EPO for OAuth
[here](https://developers.epo.org/user/register).
Use your credentials by configuring
```ruby
Epo:Ops.configure do |conf|
  conf.consumer_key = "YOUR_KEY"
  conf.consumer_secret = "YOUR_SECRET"
end
```

# Developing
For the tests you need to set up your OAuth credentials by renaming
`test/epo_credentials.yml.dist` to `test/epo_credentials.yml` and enter your key
 and secret.
