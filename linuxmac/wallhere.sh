#!/bin/bash 

query="" # you can set any query, for example: nature,girl. Default: empty
random_link=$(curl -s -L "https://wallhere.com/en/random?q=${query}&direction=horizontal" | grep -o '<a href="/en/wallpaper/[^"]*' | cut -d'"' -f2 | shuf -n1)
url=$(curl -s -L "https://wallhere.com/${random_link}" | grep 'current-page-photo' | grep -o 'href="[^"]*"' | cut -d'"' -f2)


echo "Downloading: "$url;
pathimg=$HOME"/Pictures/wallhere_com.jpg";

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
      xfconf-query --channel xfce4-desktop --property $x --set ""
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
