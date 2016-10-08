This is a collection repository of my personal [i3blocks](https://github.com/vivien/i3blocks).

--

### media-info.sh

This block displays information from [D-Bus MPRIS](https://specifications.freedesktop.org/mpris-spec/latest/) compliant media players (such as Spotify or VLC). It **does not** require [playerctl](https://github.com/acrisci/playerctl) to do so; it instead interfaces with D-Bus directly.

This block utilizes [Font Awesome](http://fontawesome.io/) icons (you can swap them for unicode alternatives).

Example Output: `  In A Sentimental Mood - Duke Ellington`

**~/.i3blocks.conf** Entry:

```
[media-info]
command=bash .../media-info.sh
interval=1
...
```

Input | Action
----- | ------
Left Click | *N/A*
Right Click | Pause/Play Track
Middle Click | Stop Track
Scroll Down | Next Track
Scroll Up | Previous Track

--

### weather-underground.sh

This block displays information from [Weather Underground's API](https://www.wunderground.com/weather/api/). It requires that you supply it a valid Wunderground API key and a valid location.

In order to get a free API key you must sign up for an account [here](https://www.wunderground.com/member/registration?mode=api_signup), then select the Stratus Developer plan [here](https://www.wunderground.com/weather/api/d/pricing.html) (I know it says purchase but it's most certainly free). Valid location formats include US zipcodes (10101), US state/city (NY/New_York), or country/city (UK/London). To display in degrees Celsius/Centigrade supply the **-C** option.

Example Output: `Clear, 59 °F`

**~/.i3blocks.conf** Entry:
```
[weather-underground]
command=bash .../weather-underground.sh [-C] API_KEY LOCATION
interval=persist
signal=6
...
```

Input | Action
----- | ------
Left Click | *N/A*
Right Click | Flash High/Low Temp
Middle Click | *N/A*
Scroll Down | *N/A*
Scroll Up | *N/A*
