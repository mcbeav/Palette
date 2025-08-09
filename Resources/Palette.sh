#!/usr/bin/env bash -p
# LOCATION (STR) -- Grab The Location Of Where The Script Is Being Run So We Can Load The Controller Script Into The Terminal Window
LOCATION="$(cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd)";
# PID (STR) -- If The Terminal Application Is Already Open, Grab The Process ID
PID=$(pgrep "Terminal");
# MODE (STR) -- Returns "dark" If Finder Is Using Dark Mode; Otherwise Returns An Error
MODE=$(defaults read -g AppleInterfaceStyle 2> /dev/null);
# Change To The Directory Where The Script Was Run To Start Settings Up The Application
cd "${LOCATION}";
# Read & Store The Correct Theme Files Contents In A Variable Based On If MacOS Is Running In Light Or Dark Mode
if [[ "${MODE}" = "Dark" ]]; then
    _theme=$(<${LOCATION}/Themes/dark);
else
    _theme=$(<${LOCATION}/Themes/light);
fi
# Write The Contents To A Termainl Theme File With The Name Of Palette
echo -e "${_theme}" > "${LOCATION}/Themes/Palette.terminal";
# Open The Recently Written Terminal Theme So A New Terminal Window Is Opened Using The Newly Written Theme
open -a "Terminal" ./Themes/Palette.terminal;
# Close All Background Terminal Windows & Start The Controller Script In The New Terminal Window With The Correct Palette Theme
# ! This Is Not A Good Idea & This Could Cause Many Issues With User Running Terminal Processes, But This Will Stay Purely For The Proof Of Concept & To Make This Script Act More Like An Actual Application
osascript -e '
    tell application "System Events"
        if (count (processes whose name is "Terminal")) is 1 then
            tell application "Terminal"
                set Palette to id of front window
                delay 1
                set custom to (do script "'${LOCATION}'/.palette/Controller/Controller.sh" in window 1)
                close (every window whose id ≠ Palette)
            end tell
        end if
    end tell'