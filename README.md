This is a collection repository of my personal [i3blocks](https://github.com/vivien/i3blocks).

--

### media-info.sh

This block displays information from [D-Bus MPRIS](https://specifications.freedesktop.org/mpris-spec/latest/) compliant media players (such as Spotify or VLC). It **does not** require [playerctl](https://github.com/acrisci/playerctl) to do so; it instead interfaces with MPRIS directly.

This block utilizes [Font Awesome](http://fontawesome.io/) icons (you can swap them for unicode alternatives).

Sample Output: `  In A Sentimental Mood - Duke Ellington`

Sample `~/.i3blocks.conf` Entry:

```
[media-info]
command=bash .../media-info.sh
interval=1
```
