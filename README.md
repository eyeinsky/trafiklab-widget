trafiklab-widget
================

A simple GTK app for displaying time until next bus in
Stockholm's public transportation system, making use of the
[TrafikLab](https://www.trafiklab.se/)'s API.


Usage
=====

Acquire an API key from [TrafikLab](https://www.trafiklab.se/)

Find out your stop (an int)
   
```bash
APIKEY=..
SEARCH=..
browser
"https://api.trafiklab.se/samtrafiken/resrobot/FindLocation.json?apiVersion=2.1&from=$SEARCH&coordSys=RT90&key=$APIKEY"
```

Look for the `locationid` where it matches your `displayname`.


Install gem:
   
```bash
git clone https://github.com/eyeinsky/trafiklab-widget.git
cd trafiklab-widget
gem build trafiklab-widget.gemspec
gem install trafiklab-widget-[VERSION].gem
```

Create script:

```ruby
require 'trafiklab-widget'

apikey    =         # :: String
location  = 7400001 # :: Int    # currently centralstation)
direction = nil     # :: String
howMany   = 1       # :: Int    # how many departures you want to see

getPossibleDirections(apikey, from)
# runWidget(key, from, direction, howMany)
```

Running this gets you a print-out of possible directions. From these choose one
to fill `direction`, then comment `getPossibleDirections` and uncomment `runWidget`.

Add script to path, create keyboard shortcut, etc.

Notes
=====

Runs a borderless window -- ALT+click to move it around.

Tested on Debian/Xfce4.

Updates happen every minute.

Departure times are a maximum of 120 minutes in the future (restricted by
TrafikLab's API).
