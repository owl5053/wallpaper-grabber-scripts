#!/bin/bash

# a script for Linux/macOS that changes the desktop wallpaper
# by OWL5053

#not work on FreeBsd/Mac
#url=$(curl -s -L "https://35photo.pro/genre_99/new/" | sed -ne '/data-src="/{s/.*data-src="\(.*\).*/\1/p;q;}' | sed -r 's/".+//' | sed 's/c1.//' | sed 's/_temp/_main/' | sed 's/sizes\///' | sed 's/_800n//'
#  genre_98 - Adult only!
url=$(curl --cookie "nude=true" -s -L "https://35photo.pro/genre_99/new" | grep -o 'data-src="[^"]*"' | cut -d '"' -f 2 | shuf -n1 | sed -r 's/".+//' | sed 's/c1.//' | sed 's/_temp/_main/' | sed 's/sizes\///' | sed 's/_800n//'
);
echo "Downloading: "$url;
pathimg=$HOME"/Pictures/35photo.jpg";

echo "Saving in: "$pathimg;
curl -s -o $pathimg $url

#if detected Mac OS
if [[ "$OSTYPE" == "darwin"* ]]; then
	# variant 1 to set wallpaper on MAC
        # osascript -e 'tell application "Finder" to set desktop picture to POSIX file "'$pathimg'"'
	# variant 2 to set wallpaper on MAC
	sqlite3 ~/Library/Application\ Support/Dock/desktoppicture.db "update data set value = '$pathimg'" && killall Dock
 else
#if not Mac OS
if [ "$XDG_CURRENT_DESKTOP" = "XFCE" ]
  then
    xres=$(echo $(xfconf-query --channel xfce4-desktop --list | grep last-image))
    for x in "${xres[@]}"
    do
		    xfconf-query --channel xfce4-desktop --property $x --set "" #refresh desktop if the same name
        xfconf-query --channel xfce4-desktop --property $x --set $pathimg
    done
  # Set the wallpaper for unity, gnome3, cinnamon.
  elif gsettings set org.gnome.desktop.background picture-uri "file://$pathimg"; then
    gsettings set org.gnome.desktop.background picture-options "zoom"
  else
    echo "$XDG_CURRENT_DESKTOP not supported."
    break
 fi
 echo "New wallpaper set for $XDG_CURRENT_DESKTOP."
fi

