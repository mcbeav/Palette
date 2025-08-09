#!/usr/bin/env bash -p
##: @group Information {
# {{{ Summary }}}
#
# Pallete's intent is to backup/restore data in the macOS colorpicker app: ColorSnapper 2. ColorSnapper 2 has no built in method's for manipulating the data stored in the application. This script allows dated backup's of current colors saved in ColorSnapper 2; Restoration of data backups previously created; Combining data files into a single file and loading the combined data files into ColorSnapper 2; Creating color palettes to save & reference or load back into ColorSnapper 2 at any time
# Palette was created because I use ColorSnapper2 almost everyday between multiple computers. If I switch to a different computer I don't have access to the colors in ColorSnapper2 on my other computers for the various projects I am working on. Palette allows me to backup my data so I can clear the data in ColorSnapper2 when starting a new project to keep the colors I am working with separated between projects. It allows me to keep my data synced with iCloud between computers. I can load in the ColorSnapper2 data I am working with from another computer and continue to work on a specific project. I can combine the ColorSnapper2 data from multiple computers so I have all of the colors I have been working with from multiple computers. I can save specific colors for a certain project to a "Palette", so I can keep these colors organized and separated, and I can load in this data anytime I work on the project associated with these colors, easily switching between "Palettes" when I switch between projects.
#
# {{{ Functionality Description }}}
# ColorSnapper Backup - 
# ColorSnapper Restore - 
# ColorSnapper Clear - 
# Create A Palette - 
# Load A Palette - 
# Sync ColorSnapper - 
# ColorSnapper Combine - 
# Preview Color Data - 
# Manage Data - 
# Options - 
# Help - 
# Exit - 
#
# {{{ Author }}} 
#
# mcbeav
# hello@mcbeav.me
# 11/20/2020
#
# {{{ License -- GNU }}}
#
# Copyright 2020 mcbeav
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
##: @End Information }

##: @group Bash Settings {
# Abort Script On Non-Zero Exit Status
set -o errexit
# Abort Script On Usage Of Unbound|Unset Variable
set -o nounset
# Abort Script On Pipe Error
set -o pipefail
##: @End Bash Settings }

##: @group Data {
#   ##: @User {
# If You're Using The Standalone Script, APPLICATION Should Be Set To false. Change The Value Of APPLICATION To false If It Is Not Set
readonly APPLICATION="true"
#   ##: @End User }

#   ##: @Constants {
# IFSC (String) -- Creates A Copy Of IFS To Restore The IFS Variable If It Has Been Changed & Needs To Be Restored
readonly IFSC="$IFS"
# SCRIPT (String) -- Stores The Absolute File Path To The Script Including The Script Name, That Is Running
readonly SCRIPT="$(which $0)"
# LOCATION (String) -- Stores The Absolute File Path To The Script That Is Running; Used For File Creation When Using The Application Version
readonly CONTROLLER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
# DIMENSIONS (Array) -- Stores The Height & Width The Terminal Window Will Be Sized For The Application
readonly DIMENSIONS=( 30 70 )
# ORIGINAL (Array) --Stores The Original Height & Width Of The Terminal So It Can Be Restored When The Script Has Exited
readonly ORIGINAL=( $(stty size | cut -d ' ' -f 1) $(stty size | cut -d ' ' -f 2) )
# LOGO (Array) -- Stores Each Line Of The Logo So The Logo Can Be Constructed & Centered Based On The Terminal Window Width
readonly LOGO=( "888 88e          888           d8     d8" "888 888D  ,\"Y88b 888  ,e e,   d88    d88    ,e e," "888 88\"  \"8\" 888 888 d88 88b d88888 d88888 d88 88b" "888      ,ee 888 888 888   ,  888    888   888   ," "888      \"88 888 888  \"YeeP\"  888    888    \"YeeP\"" )
# LOADING (Array) -- Stores Each Frame For The Loading Animation That Plays When The display_loading Function Is Called To Show A Visual Indication The App Is Working & Is Not Hanging
readonly LOADING=( " |     _ \   \   _ \_ _|  \ |  __|\n |    (   | _ \  |  | |  .  | (_ |\n____|\___/_/  _\___/___|_|\_|\___|" "     ┌┐     \n  ┌┐ ││ ┌┐  \n┌┐││ ││ ││┌┐\n└┘││ ││ ││└┘\n  └┘ ││ └┘  \n     └┘     " "  ┌┐    ┌┐  \n┌┐││ ┌┐ ││┌┐\n││││ ││ ││││\n││││ ││ ││││\n└┘││ └┘ ││└┘\n  └┘    └┘  " "┌┐        ┌┐\n││┌┐    ┌┐││\n││││ ┌┐ ││││\n││││ └┘ ││││\n││└┘    └┘││\n└┘        └┘" " \n┌┐   ┌┐   ┌┐\n││┌┐ ││ ┌┐││\n││└┘ ││ └┘││\n└┘   └┘   └┘" )
# NC (String) -- No Color; Ends Any Color Styling
readonly NC="\033[0m"
# MODE (String) -- Returns "dark" If Finder Is Using Dark Mode; Otherwise Returns An Error
readonly MODE=$(defaults read -g AppleInterfaceStyle 2> /dev/null)
#   ##: @End Constants }

#   ##: @Variables {
# TODAY (String) -- Today's Date Used For Naming & Organizing Backups & Finding & Restoring From A Backup
TODAY=$(date +"%m-%d")
# LOCATION (String) -- Contains The Base Directory Set By The directory_base Function Called When The Application Starts. This Is Where Data Is Stored If Using The Application Version
LOCATION="${CONTROLLER}"
# FRAMES (Array) -- Holds The Animation Frames After The Proper Spacing Has Been Added To Each Frame So The Animation Is Properly Centered On Screen
FRAMES=()
# ESC (String) -- Shortcut For Displaying Special Characters
ESC="\033"
# SETTINGS (Array) -- Stores The Local File Path & OR Cloud File Path OR If iCloud Is Being Used The iCloud File Path. Stores 4 Values, If The User Is Storing Palette Data Locally (This Is Optional, & You Can Choose Cloud Storage Only). The Values Are NO || USER || APPLICATION. NO Indicates The User Is Not Wanting Local Copies Of The Data Stored. USER Indicates Palette Data Is Being Stored At A User Defined File Path. APPLICATION Indicates Palette Will Store The Data Inside The Application. The Second Value Is NO If There Is No Local Storage, The Absolute File Path If The Local Storage Is User Defined Or APPLICATION If Palette Is Storing The Data In The Application. The 3rd Value Determines If A Cloud Backup Is Made. NO If The User Is Not, CLOUD If The User Wants A Copy Of Palette Data To Be Created OR ICLOUD If iCloud Is To Be Used.
SETTINGS=()
# DISPLAY (Array) -- Stores The Logo & Banner Strings Formatted For The Current Window Size So They Can Be Printed Instead Of Constructing Them Each Time They Are Called. The Values Are Updated When The Window Size Changes Or The Banner Is Updated When The Banner Message Has Changed
DISPLAY=( "" "" )
# WINDOW (Array) --Stores The Height & Width Of The Terminal So It Can Be Restored When The Script Has Exited
WINDOW=( $(stty size | cut -d ' ' -f 1) $(stty size | cut -d ' ' -f 2) )
# COLS (String) -- Stores The Width In Columns Of The Terminal Window For Checking If The Terminal Window Has Been Resized & To Calculate The Spacing Needed To Center Various Text In The Terminal Window
COLS=${WINDOW[1]}
# HINTCOLOR (String) -- Stores The Color For The Hint Message Displayed At The Bottom Center Of The Terminal On Specific Screens
HINTCOLOR=""
# LOGOCOLOR (String) -- Stores The Color For The Logo Displayed Top Center Of The Window
LOGOCOLOR=""
# BANNERCOLOR (String) -- Stores The Color For The Banner Displayed Under The Logo
BANNERCOLOR=""
# MESSAGE (String) -- Stores The Banner Message In Case The Banner Needs To Be Reconstructed Due To The Application Window Being Sized Or Other Various Reasons
MESSAGE=""
# PRELOAD (Array) -- Stores A Selected File Before Modifying Any Data In ColorSnapper Or Palette
PRELOAD=()
# COLORSNAPPER (String) -- Stores Whether The ColorSnapper Application Is Known To Be Installed. It's Assumed The Application Is Installed. When The Application First Runs The colorsnapper_exists Function Checks If ColorSnapper2 Is Installed. If It Can Not Be Found A Warning Will Be Displayed At The Startup Of Palette
COLORSNAPPER="true"
#   ##: @End Variables }
##: @End Data }

#*: @function update_date {
#*: Description: Updates The TODAY Variable With The Current Date In MM-DD Format
#*: }
function update_date {
    TODAY=$(date +"%m-%d");
}

##: @group Functions {
#    ##: @Functions Properties {
#*: @function properties_update {
#*: Description: Updates Window Size Data Stored In Variables;
#*: Purpose: When The Terminal Window Is Resized The properties_update Function Is Called To Update The WINDOW Variable Containing The Window's Column & Row Dimensions, COL Is Updated To The Terminal's Column Dimensions, & The Values Stored In Display Are Reset. This Is Done To Accurately Calculate The Spaces Required To Center Text In The Terminal Window. The DISPLAY Array Holds The Logo & Banner As A String Ready To Be Displayed, But If The Terminal Is Resized The Logo & Banner Must Be Reconstructed According To The Terminal's New Window Size.
#*: }
function properties_update {
    # Update The WINDOW Array Holding The Window Height & Width Values
    WINDOW=( $(stty size | cut -d ' ' -f 1) $(stty size | cut -d ' ' -f 2) );
    # Update The COLS Value Holding The Width Width Value
    COLS=${WINDOW[1]};
    # Reset The DISPLAY Values So The Logo & Banner Message Is Regenerated Since The Spaces Required To Center The Text Will Now Be Different
    DISPLAY[0]="";
    # Reset The DISPLAY Values So The Logo & Banner Message Is Regenerated Since The Spaces Required To Center The Text Will Now Be Different
    DISPLAY[1]="";
}
#    ##: @End Properties }
#    ##: @Functions Window {
#*: @function window_resize {
#*: Description: Resizes The Terminal Window To The Values Passed To The Function; If No Values Are Passed The Function Uses The Values Stored In The Array DIMENSIONS
#*: Arguments: _height (INT) -- The Height In Rows To Size The Terminal Window; _width(INT) -- The Width In Columns To Size The Terminal Window;
#*: Purpose: Called Once When The Script / Application Starts To Resize The Terminal Window & Called When The Script Exits / Application Is Quit To Return The Terminal Window Back To It's Original Size.
#*: }
function window_resize() {
    printf "\e[8;${1};${2}t";
}

#*: @function window_clear {
#*: Description: Clears The Terminal
#*: Purpose: For Every New Screen Output To The Terminal Window The Previous Output Is Cleared From The Terminal
#*: }
function window_clear { printf "\33c\e[3J"; }

#*: @function window_focus {
#*: Description: Attempts To Bring The Terminal Window Into Focus
#*: Purpose: Attempts To Focus The Terminal Window As ColorSnapper Attempts To Steal Focus When It First Opens Or Is Relaunched
#*: }
function window_focus { printf "\e[5t"; }

#*: @function window_name {
#*: Description: Changes The Title In The Terminal Bar
#*: Arguments: _title (String) -- A String That Terminal Window Title Will Be Assigned As;
#*: Purpose: Assigns The Terminal Window A Name Depending On The Option The User Has Selected
#*: }
function window_name() {
    # If A Value Is Passed The Window's Title Is Set To The Value That Was Passed, Otherwise The Title Is Set To An Empty String
    local _title="";
    if (( "$#" > 0 )); then _title=${1}; fi
    echo -n -e "\033]0;${_title}\007";
}
#    ##: @End Window }

#    ##: @Functions Cursor {
#*: @function cursor_top {
#*: Description: Prints The Cursor Position Row (Top) # From The Top Of The Terminal Window
#*: Purpose: Determine The Top (Row) Position Of Cursor
#*: }
function cursor_top {
    local _col;
    local _row;
    local IFS=';';
    IFS=';' read -sdR -p $'\E[6n' _row _col;
    IFS=${IFSC};
    echo "${_row#*[}";
}

#*: @function cursor_left {
#*: Description: Prints The Cursor Left (Column) # Position From The Left Of The Terminal Window
#*: Purpose: Determine The Left (Column) Position Of The Cursor
#*: }
function cursor_left {
    local _col;
    local _row;
    local IFS=';';
    IFS=';' read -sdR -p $'\E[6n' _row _col;
    IFS=${IFSC};
    echo "${_col}";
}

#*: @function cursor_indent {
#*: Description: Indents The Cursor The Specified Amount Of Spaces Passed To The Function; If No Value Is Passed The Default Value Of 3 Is Used
#*: Arguments: _left (INT) (optional) -- Optionally, A Value Can Be Passed To The Function To Specify How Many Columns From The Left To Move The Cursor;
#*: Purpose: Indents The Cursor When A User Is Asked To Provide Input So The Input Can Be Clearly Seen
#*: }
function cursor_indent() {
    local _left=3;
    if (( "$#" > 0 )); then _left=${1}; fi
    tput cup $(cursor_top) ${_left};
}

#*: @function cursor_move {
#*: Description: Moves The Cursor To The Spefied Top & Left Positions Passed To The Function
#*: Arguments: _top (INT): The Amount Of Rows From The Top To Place The Cursor; _left (INT) (optional) -- Optionally, A Value Can Be Passed To The Function To Specify How Many Columns From The Left To Move The Cursor; If A Value Is Not Supplied The Left Position Of The Cursor At Time Of Calling The Function Is Used By Calling The cursor_left Function
#*: Purpose: Moves The Cursor On The Screen To Print Messages In Different Areas Of The Window Or When Asking The User For Input
#*: }
function cursor_move() {
    local _top=${1}
    local _left=$(cursor_left);
     if (( "$#" > 1 )); then _left=${2}; fi
    tput cup ${_top} ${_left};
}

#*: @function cursor_show {
#*: Description: Turns The Cursor On Making The Cursor Visible
#*: Purpose: Brings The Cursor Back After It Has Been Turned Off Using The cursor_hide Function
#*: }
function cursor_show { printf "$ESC[?25h"; }

#*: @function cursor_hide {
#*: Description: Turns The Cursor Off Hiding The Cursor
#*: Purpose: Hides The Cursor On Screen When It Is Not Needed
#*: }
function cursor_hide { printf "$ESC[?25l"; }
#    ##: @End Cursor }

#   ##: @Functions Strings {
#*: @function str_findcenter {
#*: Description: Prints The Number Of Spaces That Is Required To Center The String Passed To The Function. The String Passed Must Have New Lines Delimeted As An Asterisk(*). The Function Determines The Longest Line In The String & Calculates The Amount Of Spaces Required To Center That String. This Is Used To Print A Block Of Text Centered In The Window.
#*: Arguments: _message (String): Passing In A String With Aterisks(*) Delimiting The Line Breaks, The Function Will Return The Amount Of Spaces Required To Center A Paragraph Of Text Based Off The Longest Line In The String.
#*: Purpose: Used To Determine How Many Spaces Are Required To Center A Multi-Line Block Of Text As A Whole Block Instead Of Centering Each Individual Line.
#*: }
function str_findcenter() {
    # Store The String Passed As _message
    local _message=${1};
    # Duplicate The Message Stored In _str
    local _str="${_message}";
    # Check If The Message Passed In Is A Multi-line String Using An Asterisk(*) As The Delimeter For Line Breaks; If There Are No Asterisks In The String It's Assumed The String Is Short Enough To Fit On A Single Line In The Window
    if [[ ${_message} == *"*"* ]]; then
        # Change The IFS To An Asterisk(*) So We Can Split Each Line Into An Array Element
        local IFS="*";
        # Convert The Lines Into An Array
        _message=($_message);
        # Change The IFS Back To It's Original State Avoid Running Into Any Potential Errors
        IFS=${IFSC};
        # Set The _str To The First String In The _message Array
        _str="${_message[0]}";
        # If There Is More Than 1 Element In The _message Array Loop Over The Array Starting At Element 1, Comparing The Lengths Of _str & The String In The Next Array Element. The Result Is _str Will Have The Longest String Out Of All Of The Strings
        if (( ${#_message[@]} > 1 )); then
            # Loop Over Each Line In The Array Comparing The Length Of Each Line To Find The Longest String In The Array; _str Is Set To The Longest String In The Array
            for _line in "${_message[@]:1}"; do
                # If The String In The Array Element _line Is Longer Than The Stirng Stored In _str Then Set The Value Of _str To _line
                if (( ${#_line} > ${#_str} )); then _str="${_line}"; fi
            done
        fi
    fi
    # Find The Center Of The String Based Off The Longest String From All Of The Lines
    local _center=$(( (( COLS - ${#_str} )) / 2 ));
    # Print Out The Number Representing The Center Which Will Be The Number Of Spaces Required To Center The Message Passed As A Paragraph Or Block Of Text Based On The Current Terminal Window Size
    echo "${_center}";
}

#*: @function str_split {
#*: Description: Splits A String That Is Too Long To Be Displayed On A Single Line. 
#*: Arguments: _message (String) -- The String To Split, Which Is A Message To Be Displayed On Screen; _gutter (INT) (optional): Can Pass An Optional Gutter Value To Split The String Sooner If Some Extra Padding Is Desired For The Message;
#*: Purpose: Used To Control Where A String Line Breaks Depending On The Size Of The Terminal Window. This Splits A String At A Space Dependent Upon The Size Of The Terminal Window & If Any Extra Padding Is Specified. This Ensures A String Can Be Properly Spaced, Padded, & Centered
#*: }
function str_split() {
    # Store The Value Passed As The Message
    local _message=${1};
    # Set The Gutter Value To 0 If No 2nd Value Is Passed To The Function
    local _gutter=0;
    # If A 2nd Value Was Passed To The Function Set The Gutter Equal To The Value
    if (( "$#" > 1 )); then _gutter=${2}; fi
    # Declare The _line Array
    local _lines=();
    # Declare A _str Variable
    local _str="";
    # Check If The Message Passed Has A Colon In The String Indicating A Title Before The Colon
    if [[ ${_message} == *":"* ]]; then
        # Split & Store The Title In The _str Variable
        _str=$(echo "${_message}" | cut -d':' -f 1);
        # Add The Title To The Array
        _lines+=( "${_str}:" );
        # Reset The _str Variable
        _str="";
        # Set The _message Variable To The Message Minus The Title That's Already Been Added To The Array
        _message=$(echo "${_message}" | cut -d':' -f 2);
    fi
    # Grab The Character Length Of The Message
    local _length=${#_message};
    local _measurement=$(( COLS - (( _gutter * 2 )) ));
    if (( _length > 0 )) && (( _length > _measurement )); then
        while (( _length > _measurement )); do
            while [[ "${_message:$_measurement:1}" != [[:space:]] ]]; do
                _measurement=$(( _measurement - 1 ));
            done
            _lines+=( "${_message:0:$_measurement}" );
            _measurement=$(( _measurement + 1 ));
            _message="${_message:$_measurement}";
            _length=${#_message};
            _measurement=$(( COLS - (( _gutter * 2 )) ));
        done
    fi
    if [[ ! -z "${_message// }" ]]; then _lines+=( "${_message}" ); fi
    _str="${_lines[0]}";
    for _line in "${_lines[@]:1}"; do _str="${_str}*${_line}"; done
    # Return / Print The String Using Asterisks (*) As The Delimeter Indicating Where The String Should Have Line Breaks Inserted Based Off The Window Width & If A Gutter Size Was Specified
    echo -e "${_str}";
}

#*: @function str_space {
#*: Description: Adds The Necessary Padding To The String Passed To The Function
#*: Arguments: _option (String) "String To Display"; _option (String) "Left || Right || Center || Indent || Pad || Trailing"
#*: }
function str_space() {
    local _message=${1};
    local _option="center";
    local _gutter=0;
    local _c="";
    local _e="";
    if (( "$#" > 1 )); then
        case "$#" in
            "4") _option=${2};
                     _gutter=${3};
                     _c=${4};
                     _e=${NC};
            ;;
            "3") _option=${2};
                     _gutter=${3};
            ;;
            "2") _option=${2};
            ;;
        esac;
    fi
    local _check="";
    local _length=${#_message};
    local _pad=$(echo "scale=1;(((${COLS} - ((${_gutter} * 2))) - ${_length}) / 2)" | bc);
    local _remainder=$(echo "${_pad}" | cut -d'.' -f 2);
    _pad=$(echo "${_pad}" | cut -d'.' -f 1);
    if (( _remainder > 0 )); then
        _remainder=" ";
    else
        _remainder="";
    fi
    if [[ "${_pad}" = "1" ]]; then
        _pad=" ";
    elif (( _pad > 0 )); then
        _pad=$(printf "%*s" $_pad '');
    else
        _pad="";
    fi
    case "$_option" in
        "left") _pad="${_remainder}${_pad}";
                _str="${_pad}${_message}";
                _check=${#_str};
                if (( _check > $(( COLS - (( _gutter * 2 )) )) )); then _pad=${_pad:0:$(( ${#_pad} - (( _check - (( COLS - (( _gutter * 2 )) )) )) ))}; fi
                _str="${_pad}${_c}${_message}${_e}";
        ;;
        "right") _pad="${_pad}${_remainder}";
                _str="${_message}${_pad}";
                _check=${#_str};
                if (( _check > $(( COLS - (( _gutter * 2 )) )) )); then _pad=${_pad:0:$(( ${#_pad} - (( _check - (( COLS - (( _gutter * 2 )) )) )) ))}; fi
                _str="${_c}${_message}${_e}${_pad}";
        ;;
        "indent") _pad=$(printf "%*s" $_gutter '');
                _str="${_pad}${_c}${_message}${_e}";
        ;;
        "pad") _pad=$(printf "%*s" $_gutter '');
                _str="${_pad}${_c}${_message}${_e}${_pad}";
        ;;
        "trailing") _pad=$(printf "%*s" $_gutter '');
                _str="${_c}${_message}${_e}${_pad}";
        ;;
        "center") _str="${_pad}${_message}${_pad}${_remainder}";
                _check=${#_str};
                if (( _check > $(( COLS - (( _gutter * 2 )) )) )); then
                    _str="${_pad}${_c}${_message}${_e}";
                    _pad="${_pad}${_remainder}";
                    _pad=${_pad:0:$(( ${#_pad} - (( _check - (( COLS - (( _gutter * 2 )) )) )) ))};
                    _str="${_str}${_pad}";
                else
                    _str="${_pad}${_c}${_message}${_e}${_pad}${_remainder}";
                fi
        ;;
        "*") _str="${_pad}${_message}${_pad}${_remainder}";
                _check=${#_str};
                if (( _check > $(( COLS - (( _gutter * 2 )) )) )); then
                    _str="${_pad}${_c}${_message}${_e}";
                    _pad="${_pad}${_remainder}";
                    _pad=${_pad:0:$(( ${#_pad} - (( _check - (( COLS - (( _gutter * 2 )) )) )) ))};
                    _str="${_str}${_pad}";
                else
                    _str="${_pad}${_c}${_message}${_e}${_pad}${_remainder}";
                fi
        ;;
    esac;
    _message="${_str}";
    echo -e "${_message}";
}
#   ##: @End Strings }

#   ##: @Functions Format {
#       ##: @Format Output {
#*: @function display_single {
#*: Description: Prints A Single Line Message On Screen
#*: Arguments: _message(STR) - The Single Line String Message That Will Be Displayed On Screen
#*: }
function display_single() {
    local _message=${1};
    local _c="";
    local _e="";
    if (( "$#" > 1 )); then
        _c=${2};
        _e="${NC}";
    fi
    local _length=${#_message};
    if (( _length <= COLS )); then
        _message=$(str_space "${_message}" "left" "0");
        _message="${_c}${_message}${_e}";
        echo -e "\n${_message}";
    else
        display_paragraph "${_message}";
    fi
}

#*: @function display_paragraph {
#*: Description: Prints A Multi-Line String On Screen
#*: Arguments: _message(STR) - The Message That Will Be Displayed On Screen
#*: }
function display_paragraph() {
    local _message=${1};
    local _trim="10";
    local _gutter="0";
    local str="";
    local _paragraph=();
    if (( "$#" > 1 )); then
        case "$#" in
            "3") _trim=${2};
                     _gutter=${3};
            ;;
            "2") _trim=${2};
            ;;
        esac
    fi
    _message=$(str_split "${_message}" "${_trim}");
    if [[ -z "${3// }" ]]; then _gutter=$(str_findcenter "${_message}"); fi
    local IFS="*";
    _message=($_message);
    IFS=${IFSC};
    for _line in "${_message[@]}"
    do
         _str=$(str_space "${_line}" "indent" "${_gutter}");
         _paragraph+=( "${_str}" );
    done
    echo -e "\n";
    for _line in "${_paragraph[@]}"
    do
        echo -e "${_line}";
    done
}

#*: @function display_hint {
#*: Description: Displays A Message At The Bottom Of The Terminal Window
#*: Arguments: _message(STR) - The String Message To Display At The Bottom Of The Terminal Window
#*: }
function display_hint() {
    local _message=${1};
    local _c="";
    local _e="";
    if (( "$#" > 1 )); then
        _c=${2};
        _e=${NC};
    fi
    local _length=${#_message};
    if (( _length > COLS )); then
        display_paragraph "${_message}";
    else
        _message=$(str_space "${_message}" "center" "0");
    fi
    _message="${_c}${_message}${_e}";
    local _cursor=$(cursor_top);
    cursor_move $(( ${WINDOW[0]} - 3 )) 1;
    echo -e "\n${_message}";
    cursor_move ${_cursor} 1;
}

#*: @function display_keys {
#*: Description: Displays A Message At The Bottom Of The Terminal Window Explaining The Cursor Key Functions To The User
#*: }
function display_keys {
    display_hint "[▲] Up    [▼] Down    [◀] Back||Go    [▶] || [ RTN ] Select" "${KEYSCOLOR}";
}

#*: @function display_yesorno {
#*: Description: Displays A Message At The Bottom Of The Terminal Window Giving A Hint To The User On Which Action To Take
#*: }
function display_yesorno {
    display_hint "[ y ]               or                [ n ]" "${HINTCOLOR}";
}
#       ##: @End Output }

#       ##: @Format Color {
#*: @function display_color {
#*: Description: Displays A Single Line Of Text With A Background Color
#*: Arguments: _text(STR) - The String To Be Displayed; _background(STR) - The Background Color
#*: }
function display_color() {
    local _text=$(echo "${1}" | tr '[:upper:]' '[:lower:]');
    local _background;
    if (( "$#" > 1 )); then
        _background=$(echo "${2}" | tr '[:upper:]' '[:lower:]');
        case "${_background}" in
            "black")          _background=0;;
            "red")             _background=1;;
            "green")         _background=2;;
            "yellow")       _background=3;;
            "blue")          _background=4;;
            "magenta")   _background=5;;
            "cyan")          _background=6;;
            "white")        _background=7;;
            "grey")          _background=8;;
        esac;
        tput setab ${_background}
    fi
    case "${_text}" in
        "black")          _text=0;;
        "red")             _text=1;;
        "green")         _text=2;;
        "yellow")       _text=3;;
        "blue")          _text=4;;
        "magenta")   _text=5;;
        "cyan")          _text=6;;
        "white")        _text=7;;
        "grey")          _text=8;;
    esac;
    tput clear
    tput setaf ${_text}
}

#*: @function define_color {
#*: Description: Assembles The Correct Color Code To Display Color Text In The Terminal Based On The Arguments Passed To The Function
#*: Arguments: _color(STR) - The Color Of The String; _target(STR); _style(STR) - Any Style Modifiers; _modifier(STR) - Any Style Modifiers
#*: Purpose:
#*: }
function define_color() {
    local _color=$(echo "${1}" | tr '[:upper:]' '[:lower:]');
    local _target="text";
    local _style="normal";
    local _modifier="none";
    if (( "$#" > 2 )); then
        _target=$(echo "${2}" | tr '[:upper:]' '[:lower:]');
        _style=$(echo "${3}" | tr '[:upper:]' '[:lower:]');
        _modifier=$(echo "${4}" | tr '[:upper:]' '[:lower:]');
    fi
    local _a;
    local _b;
    case "${_color}" in
        "black")        _b=30;;
        "red")           _b=31;;
        "green")       _b=32;;
        "yellow")     _b=33;;
        "blue")         _b=34;;
        "magenta")  _b=35;;
        "cyan")         _b=36;;
        "white")       _b=37;;
        "*")              _b=30;;
    esac;
    if [[ "${_target}" = "background" ]]; then _b=$(( _b + 10 )); fi
    if [[ "${_style}" = "bright" ]]; then _b=$(( _b + 60 )); fi
    case "${_modifier}" in
        "none")         _a=0;;
        "bold")          _a=1;;
        "bright")      _a=1;;
        "dim")           _a=2;;
        "underline") _a=4;;
        "blink")         _a=5;;
        "reverse")     _a=6;;
        "hidden")      _a=7;;
        "*")               _a=0;;
    esac;
    echo "\033[${_a};${_b}m";
}

#*: @function define_colors {
#*: Description: Define Color Variables For Information That Will be Displayed On Screen
#*: }
function define_colors {
    local _color;
    local _logo=$(random_color);
    # If MacOS Is Running In Dark Mode Set The HINT & KEYS Color To White & If MacOS Is Running In Light Mode Set The HINT & KEYS Color To White
    if [[ "${MODE}" = "Dark" ]]; then
        _color="white";
    else
        _color="black";
    fi
    HINTCOLOR=$(define_color ${_color} "text" "normal" "bright");
    KEYSCOLOR=$(define_color ${_color} "text" "normal" "bright");
    LOGOCOLOR=$(define_color "${_logo}" "text" "normal" "bright");
}

#*: @function color_banner {
#*: Description: Set A Random Color For The Banner
#*: }
function color_banner {
    local _color=$(random_color);
    BANNERCOLOR=$(define_color "${_color}" "text" "normal" "bright");
}

#*: @function random_color {
#*: Description: Chooses A Random Color
#*: Purpose: Used To Generate A Random Color For The Logo & The Banner Whenever Displayed On Screen
#*: }
function random_color {
    local _seed;
    if [[ "${MODE}" = "Dark" ]]; then
        _seed=$(( ( RANDOM % 6 )  + 1 ));
    else
        _seed=$(( ( RANDOM % 5 )  + 1 ));
    fi
    local _color;
    case "${_seed}" in
        1) _color="red";;
        2) _color="green";;
        3) _color="cyan";;
        4) _color="blue";;
        5) _color="magenta";;
        6) _color="yellow";;
    esac;
    echo "${_color}";
}
#       ##: @End Color }
#   ##: @End Format }

#   ##: @Functions Logo {
#*: @function logo {
#*: Description: Prints The Palette Logo Centered To The Terminal Window
#*: Purpose: The Function Takes Each Logo Line Stored In The LOGO Variable & Determines The Spacing Required To Center The Logo In The Terminal & Stores It As A String In The DISPLAY Array. The Logo Is Constructed, Centering The Logo Based Off The Window Dimensions When The Script Starts, & Is Stored In The DISPLAY String. If The Terminal Window Size Has Not Changed, The Logo Is Printed From The String To Avoid Having To Construct The Logo String Everytime The Function Is Called. If The Window Size Has Changed Since The Last Time The Logo Was Displayed, The Logo Will Be Constructed Again & Stored In The DISPLAY Variable.
#*: }
function logo {
    # Check If The DISPLAY Variable Has A Value Set & If The Window Size Has Changed Since The Last Time The Logo Function Was Called. If The Window Size Has Not Changed & The DISPLAY String Has Value Of The Logo Constructed & Centered Then Do NOT Reconstruct The Logo & Print The Already Generated Logo
    if [[ "${WINDOW[1]}" != "${COLS}" || -z "${DISPLAY[0]// }" ]]; then
        local _logo=();
        local _str="${LOGO[0]}";
        for _line in "${LOGO[@]:1}"; do _str="${_str}*${_line}"; done
        local _center=$(str_findcenter "${_str}");
        for _line in "${LOGO[@]}"; do
            _str=$(str_space "${_line}" "indent" "${_center}" "${LOGOCOLOR}");
            _logo+=( "$_str" );
        done
        _str="";
        for _line in "${_logo[@]}"; do _str="${_str}\n${_line}"; done
        DISPLAY[0]="${_str}";
    else
        _str="${DISPLAY[0]}";
    fi
    echo -e "${_str}";
}
#   ##: @End Logo }

#   ##: @Functions Banner {
#*: @function banner {
#*: Description: Takes The Message Passed To The Function & Centers The Message Surrounded By A Border & Is Displayed Below The Logo. The Banner Displays The Menu Titles & Feedback Messages.
#*: Arguments: _message(optional); If No Parameter Is Supplied To The Function Call, The Value Stored In MESSAGE Will Be Used. The Function Constructs A Banner Centering The Message With A Border Surrounding The Message.
#*: Purpose: The Menu Title & Messages Are Displayed Inside Of The Banner. The Banner Is Displayed Below The Logo. The Banner Function Takes The Message That Will Go Inside Of It, Split The Heading If There Is One, & Center The Heading & Message, Surround The Banner With A Border & Store It In The DISPLAY Variable. The Banner Will Be Reconstructed If The Window Size Changes OR The Message Inside The Banner Changes.
#*: }
function banner() {
    # Change The Banner Color Everytime It Is Drawn To The Window
    color_banner;
    local _message="";
    local _banner=();
    local _str="";
    #BORDER -- [0] Top Left -- [1] Top|Bottom -- [2] Top Right -- [3] Side -- [4] Bottom Right -- [5] Top|Bottom -- [6] Bottom Left -- [7] Side
    local _border=( "╔" "═" "╗" "║" "╝" "═" "╚" "║" );
    if [[ "$#" -gt 0 || "${WINDOW[1]}" != "${COLS}" || -z "${DISPLAY[1]// }" ]]; then
        if (( "$#" > 0 )); then
            _message=${1};
            MESSAGE="${_message}";
        elif [[ ! -z "${MESSAGE// }" ]]; then
            _message="${MESSAGE}";
        fi
        local _measurement=$(( COLS - 6 ));
        local _horizontal=$(printf %${_measurement}s |tr " " "${_border[1]}");
        local _pad=$(printf "%*s" $_measurement '');
        local _top="  ${_border[0]}${_horizontal}${_border[2]}";
        local _space="  ${_border[3]}${_pad}${_border[3]}";
        local _bottom="  ${_border[6]}${_horizontal}${_border[4]}";
        _message=$(str_split "${_message}" "3");
        local IFS="*";
        _message=($_message);
        IFS=${IFSC};
        for _line in "${_message[@]}"; do
            _line=$(str_space "${_line}" "center" "3");
            _banner+=( "  ${_border[3]}${_line}${_border[3]}" );
        done
        local _length=${#_banner[@]};
        _str="${_top}\n${_space}\n${_banner[0]}";
        if [[ ${_banner[0]} == *":"* ]]; then _str="${_str}\n${_space}"; fi
        if (( _length > 1 )); then
            for _line in "${_banner[@]:1}"; do
                _str="${_str}\n${_line}";
            done
            _str="${_str}\n${_space}";
        fi
        _str="${BANNERCOLOR}${_str}\n${_bottom}${NC}";
        DISPLAY[1]="${_str}";
    else
        _str="${DISPLAY[1]}";
    fi
    echo -e "${_str}";
}
#   ##: @End Banner }

#   ##: @Functions Heading {
#*: @function heading {
#*: Description: The heading Function Prints The Logo, Banner, & Messages For Each Screen Output To The Terminal
#*: Arguments: 
#*: Purpose: The heading Function Takes The Message For The Banner, Focuses The Window, Clears The Window, Prints The Logo & The Message Inside Of The Banner. It's The Functions That Are Called Everytime The Screen Changes Output
#*: }
function heading() {
    local _message="";
    if (( "$#" > 0 )); then _message=${1}; fi
    window_focus;
    window_clear;
    if (( "$#" > 1 )); then window_name "${2}"; fi
    logo;
    banner "${_message}";
}
#   ##: @End Heading }

#   ##: @Functions Loading {
#*: @function loading {
#*: Description: Displays A Loading Animation To Give Visual Feedback To The User
#*: Arguments: _time (String || Integer) (Optional) "Number Of Seconds For The Loading Animation To Run"
#*: }
function loading() {
    local _time=3;
    if (( "$#" > 0 )); then _time=${1}; fi
              _time=$(echo "scale=0;(( ${_time} / 0.2 ))" | bc);
    local _i=0;
    local _f=1;
    if [[ "${WINDOW[1]}" != "${COLS}" || -z "${FRAMES[0]// }" ]]; then
        # _time=$(echo "scale=1;(( ${_time} / 5 ))" | bc);
        local _text=$(echo -e "${LOADING[0]}");
        local _frame1=$(echo -e "${LOADING[1]}");
        local _frame2=$(echo -e "${LOADING[2]}");
        local _frame3=$(echo -e "${LOADING[3]}");
        local _frame4=$(echo -e "${LOADING[4]}");
        IFS=$'\n';
        _text=(${_text});
        _frame1=(${_frame1});
        _frame2=(${_frame2});
        _frame3=(${_frame3});
        _frame4=(${_frame4});
        IFS=${IFSC};
        local _str="${_text[0]}";
        for _line in "${_text[@]:1}"; do _str="${_str}*${_line}"; done
        local _center=$(str_findcenter "${_str}");
        _str="";
        for _line in "${_text[@]}"; do
            _line=$(str_space "${_line}" "indent" "${_center}");
            _str="${_str}\n${_line}"
        done
        FRAMES[0]=$(echo -e "${_str}");
        _str="${_frame1[0]}";
        for _line in "${_frame1[@]:1}"; do _str="${_str}*${_line}"; done
        _center=$(str_findcenter "${_str}");
        _str="";
        for _line in "${_frame1[@]}"; do
            _line=$(str_space "${_line}" "indent" "${_center}");
            _str="${_str}\n${_line}"
        done
        FRAMES[1]=$(echo -e "${_str}");
        _str="";
        for _line in "${_frame2[@]}"; do
            _line=$(str_space "${_line}" "indent" "${_center}");
            _str="${_str}\n${_line}"
        done
        FRAMES[2]=$(echo -e "${_str}");
        _str="";
        for _line in "${_frame3[@]}"; do
            _line=$(str_space "${_line}" "indent" "${_center}");
            _str="${_str}\n${_line}"
        done
        FRAMES[3]=$(echo -e "${_str}");
        _str="";
        for _line in "${_frame4[@]}"; do
            _line=$(str_space "${_line}" "indent" "${_center}");
            _str="${_str}\n${_line}"
        done
        FRAMES[4]=$(echo -e "${_str}");
    fi
    while (( _i < _time )); do
        window_clear;
        logo
        echo -e "\n";
        echo -e "${FRAMES[0]}";
        echo -e "\n";
        echo -e "${FRAMES[$_f]}";
        cursor_hide;
        sleep 0.2s
        (( _i++ ));
        (( _f++ ));
        if [[ "${_f}" -gt 4 ]]; then _f=1; fi
    done
}
#   ##: @End Loading }

#   ##: @Functions Introduction {
#*: @function introduction {
#*: Description: Displays A Short Introduction To The Application Upon First Launch
#*: Purpose: Introduces The User To A Brief Introduction Of What The Palette Script / Application Is & Some Of The Things You Can Do With It
#*: }
function introduction {
    local _page=1
    local _heading="";
    local _description="";
    # While The Page Number Is Under 5 Set The Values Of The Heading & Description That Will Be Displayed In The Terminal To The Corresponding Page Number 
    while (( _page < 5 )); do
        case "${_page}" in
            1) _heading="What Is Palette?"
                _description="Palette Is A Data Management Tool For ColorSnapper2. It Provides Methods To Backup Data, Restore Data, Sync Data With iCloud, Organize Data, Group Data, Combine Data From Multiple Computers, & Much More.";
            ;;
            2) _heading="Why Do I Need Palette?"
                _description="Palette Was Created Because I Design & Develop On Multiple Computers & I Run ColorSnapper2 On Multiple Computers. I Needed A Way To Keep My ColorSnapper Data Synced Between Computers If I Am Working On A Project & Switch Computers. When I Start Working On A New Project I Clear ColorSnapper's Data, So I Can Keep Colors For Each Project Separated & Grouped Together. I Needed To Be Able To Save Colors For Projects & Load In Those Colors When Changing Projects.";
            ;;
            3) _heading="What Can I Do With Palette?"
                _description="Save Colors For The Project You're Currently Working On & Clear ColorSnapper To Start A New Project. You Could Restore The Colors When You Switch Projects. You Can Backup Your ColorSnapper Data From One Computer & Load It On Another Computer. You Can Keep Your ColorSnapper Data Synced Between Computers. These Are Just A Few Things You Can Do & There Are Plenty More.";
            ;;
            4) _heading="Opening Palette Files"
                _description="When Double Clicking A Palette File Or Dragging A Palette File Over The Palette Application, A Preview Of The Colors In The Palette File Will Be Generated & Opened & Palette Will Ask If You Would Like To Load The Colors From The Palette File Into ColorSnapper. Documentation Can Be Found In The Help Menu";
            ;;
        esac;
        if [[ ! -z "${_description// }" ]]; then
            heading "${_heading}:" "${_heading}";
            display_paragraph "${_description}";
            display_hint "[ Press Space Bar To Continue... ]" "${HINTCOLOR}";
            cursor_hide;
            read -s -e -n 1 key 2>/dev/null >&2;
            (( _page++ ));
        fi
    done;
    cd "${LOCATION}/Data";
    if [[ ! -d ".tmp" ]]; then mkdir ".tmp"; fi
}
#   ##: @End Introduction }

#   ##: @Functions Help {
#*: @function help_menu {
#*: Description: Main Application Function That Catches Any Exit Signals So The Script Can Cleanup Before Exiting; Resizes The Terminal Window To The Sizes Stored In The __dimensions Array; Preps The Logo By Adding Proper Spacing Calling The logo_center Function & Adds Color To The Logo Calling The logo_color Function & Then Prints The Logo To The Top Of The Screen.
#*: }
function help_menu {
    heading "Help:Select An Option To Explain It's Function" "Palette: Help";
    display_keys;
    case `select_opt "  Backup ColorSnapper Data      " "  Restore ColorSnapper Data     " "  Clear ColorSnapper            " "  Save Color Palette            " "  Load Color Palette            " "  Preview Palette Data          " "  Sync ColorSnapper             " "  Combine Palette Data          " "  Import A Palette File         " "  Export A Palette File         " "  Delete A Palette              " "  Set Palette File Action       " "  Change Data Storage Location  " "  Display Documentation         " "  Back                          "` in
        0) help_explain "backup";;
        1) help_explain "restore";;
        2) help_explain "clear";;
        3) help_explain "save";;
        4) help_explain "load";;
        5) help_explain "preview";;
        6) help_explain "sync";;
        7) help_explain "combine";;
        8) help_explain "import";;
        9) help_explain "export";;
        10) help_explain "delete";;
        11) help_explain "file";;
        12) help_explain "data";;
        13) help_explain "documentation";;
        14) main_menu;;
    esac;
}

#*: @function help_explain {
#*: Description: Calculates The Amount Of Spaces Needed To Center The Palette Logo Text & Add's The Proper Padding To Each String
#*: Arguments: _option(STR) - String Value Of The Option To Display
#*: }
function help_explain() {
    local _option="";
    local _heading="";
    local _description="";
    if (( "$#" > 0 )); then _option="${1}"; fi
    case "${_option}" in
        "backup")       _heading="Backup ColorSnapper:";
                                _description="Backup ColorSnapper Data Will Save All Of The Colors You Are Currently Working With In ColorSnapper To A Palette File With The Name Of Today's Date In The Format Of [mm-dd]. The Application Can Only Save 1 Full Backup Per Day, So If You Run The Function Twice In A Day, The First Save's Data Will Be Overwritten. (The Create A Palette Option Is for Saving Different Sets Of Data) You Can Restore The Data Saved from That Date By Using The Restore ColorSnapper Data Option And Selecting The Desired Date To Restore. For More Details Visit The Documentation Page.";
        ;;
        "restore")      _heading="Restore ColorSnapper:";
                                _description="Restore ColorSnapper Data Displays The List Of Dates On Backups Were Created & Allows You To Restore The ColorSnapper Data from A Specific Date. This Will Overwrite Any Color Data That Is Saved In The ColorSnapper Application & Can Not Be Reversed! Consider Making A Backup Or Palette Before Using The Restore Function. For More Details Visit The Documentation Page.";
        ;;
        "clear")          _heading="Clear ColorSnapper:";
                                _description="Clear ColorSnapper Will Clear The History & Favorite Colors In The ColorSnapper Application To Give You A Clean Start When Picking New Colors. It Will Not Touch Any Data Saved By Palette. The Purpose Of Clear Is To Give You A Clean Start In ColorSnapper To Keep Color Sets With The Projects They Belong. For More Details Visit The Documentation Page.";
        ;;
        "save")          _heading="Save Color Palette:";
                               _description="Create A Palette Will Create A Palette File Containing The Favorite Colors In The ColorSnapper Application. You Can Use The Load A Palette To Load These Colors Into ColorSnapper At Any Time. The Purpose Of This Is To Keep Sets Of Colors Organized For Whatever Project They Belong. For More Details Visit The Documentation Page.";
        ;;
        "load")         _heading="Load Color Palette:";
                              _description="Load A Palette Will Display The Name Of Palette Files Saved & Load In The Colors Saved In The Selected Palette. This Will Replace The Color Data In The ColorSnapper Application With The Colors Saved In The Palette File. For More Details Visit The Documentation Page.";
        ;;
        "preview")   _heading="Preview Palette Data:";
                              _description="Preview File Will Display Your Saved Palette Data And Allow You to A Preview of The Colors Saved In The Selected File So You Can View The Colors Before Loading The Data Into ColorSnapper. For More Details Visit The Documentation Page.";
        ;;
        "sync")        _heading="Sync ColorSnapper Data:";
                             _description="Sync ColorSnapper's Purpose Is For People Using ColorSnapper On Multiple Computers & Using The Local & Cloud Backup Options In Palette. The Sync Function Combines A Cloud Backup With The Current Color Data In ColorSnapper On The Computer The Sync Function Is Run, Combining & Displaying The Color Data from Both Computers, & Then Backs up The Combined File to The Cloud. This Allows You to Work On Projects On Multiple Computers & Always Have The Colors You're Working With On All Computers. For More Details Visit The Documentation Page.";
        ;;
        "combine") _heading="Combine Data:";
                             _description="The Combine ColorSnapper Option Allows You To Load A Palette File & Merge The Colors With The Colors Currently Loaded In ColorSnapper. This Is like Loading A Palette Without Overwritting The Colors Currently In ColorSnapper. You Can Also Use This Option To Load A Palette & Combine It With Another Palette If You Need To Combine 2 Color Palettes. For More Details Visit The Documentation Page.";
        ;;
        "import")   _heading="Import Palette:";
                             _description="Allows You To Import A Palette File From Your Computer Into Your Palette Library. For Example, If You Have A Palette From Another Computer Or Download A Palette From The Internet, You Can Use Import To Import It Into Library. For More Details Visit The Documentation Page.";
        ;;
        "export")    _heading="Export A Palette:";
                             _description="Displays The List Of Saved Palettes & Exports The Selected Palette File File To Your Downloads Folder If You're Using The Application To Manage Your Palette Library. For More Details Visit The Documentation Page.";
        ;;
        "delete")    _heading="Delete A Palette:";
                             _description="Displays The List Of Saved Palettes & Deletes The Selected Palette File From Your Library If You Are Using The Application To Manage Your Palette Library. It Will NOT Delete Any Palette Files Backed Up To Cloud Storage. Palette Files Backed Up To Cloud Storage Must Be Managed Manually. For More Details Visit The Documentation Page.";
        ;;
        "file")        _heading="Set Palette File Behavior:";
                             _description="You Can Set The Default Preferred Behavior Of What Will Happen When You Double Click A Palette File OR Drag A Palette File Onto The Palette Application. By Default, If You Double Click A Palette File, A Preview Of The Palette Will Be Generated & Opened For You To View. You Can Change This Default Behavior To Instead Verify That You Would Like To Load The Palette File You Opened & It Will Load The Palette File Data Into ColorSnapper. For More Details Visit The Documentation Page.";
        ;;
        "data")       _heading="Change Data Location:";
                             _description="When You First Open The Palette Application It Sets Up Where Your Palette Data Will Be Stored. It Asks A Series Of Questions To Help Set This Up. You Can Change The Location Where Your Palette Data Is Stored & If You Would Like To Save Your Data Locally, To The Cloud / iCloud Or Save To Both. Selecting This Option Will Asks You These Initial Setup Questions Again. For More Details Visit The Documentation Page.";
        ;;
        "documentation") open https://github.com/mcbeav/palette;
                                        main_menu;
        ;;
        "*") open https://github.com/mcbeav/palette;
                main_menu;
        ;;
    esac;
    if [[ ! -z "${_description// }" ]]; then
        heading "${_heading}";
        display_paragraph "${_description}";
        display_hint "[ Press Space Bar To Continue... ]" "${HINTCOLOR}";
        cursor_hide;
        read -s -e -n 1 key 2>/dev/null >&2;
        help_menu;
    fi
}
#   ##: @End Help }

#   ##: @Functions Menu {
#*: @function select_option {
#*: Description: Creates A Selectable Menu; Lists Menu Items That Can Be Highlighted Using The Arrow Keys To Control The Selection & The Enter Key To Select An Option
#*: }
function select_option {

    ESC=$( printf "\033")
    cursor_blink_on()   { printf "$ESC[?25h"; }
    cursor_blink_off() { printf "$ESC[?25l"; }
    cursor_move()         { printf "$ESC[$1;${2:-1}H"; }
    print_option()        { printf "   $1 "; }
    print_selected()     { printf "  $ESC[7m $1 $ESC[27m"; }
    cursor_top()           { IFS=';' read -sdR -p $'\E[6n' _row _col; echo ${_row#*[}; }
    # key_input()             { read -s -n3 key 2>/dev/null >&2
    #                      if [[ $key = $ESC[A ]]; then echo up;    fi
    #                      if [[ $key = $ESC[B ]]; then echo down;  fi
    #                      if [[ $key = ""     ]]; then echo enter; fi; }

    key_input () {
        local key;
        IFS=; read -r -s -n 1;
        key="$REPLY";
        if [[ "$key" =~ ^[A-Za-z0-9]$ ]]; then echo "${key}";
        elif [[ "$key" == $'\n' ]]; then echo "enter";
        elif [[ "$key" == $'\r' ]]; then echo "enter";
        elif [[ "$key" == $'' ]]; then echo "enter";
        elif [[ "$key" == $'\e' ]]; then
            IFS=; read -r -s -n 2 -t 1
            if [[ "$REPLY" == "[A" ]]; then echo "up";
            elif [[ "$REPLY" == "[B" ]]; then echo "down";
            elif [[ "$REPLY" == "[C" ]]; then echo "enter";
            elif [[ "$REPLY" == "[D" ]]; then echo "back";
            elif [[ "$REPLY" == "" ]]; then echo "enter";
            fi
        fi
        key=;
  }

    for _opt; do printf "\n"; done

    local _lastrow=$(cursor_top)
    local _startrow=$(( $_lastrow - $# ))

    trap "cursor_blink_on; stty echo; printf '\n'; exit" 2
    cursor_blink_off

    local _selected=0
    while true; do
        local _idx=0
        for _opt; do
            cursor_move $(( _startrow + _idx ))
            if [[ "${_idx}" -eq "${_selected} " ]]; then
                print_selected "${_opt}"
            else
                print_option "${_opt}"
            fi
            (( _idx++ ))
        done

        case $(key_input) in
            enter) break;;
            up)    (( _selected-- ));
                   if [[ "${_selected}" -lt 0 ]]; then _selected=$(( $# - 1 )); fi;;
            down)  (( _selected++ ));
                   if [[ "${_selected}" -ge "$#" ]]; then _selected=0; fi;;
            back) _selected=$(( $# - 1 ));
                      break;;
        esac
    done

    cursor_move "${_lastrow}"
    printf "\n"
    cursor_blink_on

    return $_selected
}

#*: @function select_opt {
#*: Description: Takes A Menu Item That Was Selected From The select_option Function & Runs A Function Associated With The Selected Menu Item
#*: }
function select_opt {
    select_option "$@" 1>&2
    local _result=$?
    echo $_result
    return $_result
}
#   ##: @End Menu }

#   ##: @Functions Settings {
#       ###: @Settings File {
#*: @function settings_load {
#*: Description: Loads The Settings File For The Palette Application
#*: SETTINGS[0] - NO || USER || APPLICATION - Stores If The User Is Storing Palette Data Locally. NO - Does Not Store Locally. USER - User Defined Location Locally - APPLICATION - Stores Data Locally In The Palette Application
#*: SETTINGS[1] - Local Storage File Path - NO || FILEPATH || APPLICATION - NO If Not Using Local Storage. FILEPATH - The Filepath If The User Specified The Filepath For Storage. APPLICATION - Stores The Data In A Pre-Defined Path In The Palette Application
#*: SETTINGS[2] - NO || CLOUD || ICLOUD - Stores If User Is Using Cloud Storage. NO - Not Using Cloud Storage. CLOUD - User Defined Cloud Storage Path. ICLOUD - iCloud Backup
#*: SETTINGS[3] - NO || FILEPATH || PALETTE - Stores The Filepath For Cloud Backup If Enabled. NO - Not Using Cloud Storage. FILEPATH - The Absolute Filepath To The Cloud Storage Service. PALETTE - Predefined Filepath In iCloud.
#*: }
function settings_load {
    directory_set;
    if [[ ! -e "${LOCATION}/Resources/.palette/Settings/Settings" ]]; then
        if [[ ! -d "${LOCATION}/Data/.tmp" ]]; then introduction; fi
        setup_menu;
    else
        cd "${LOCATION}/Resources/.palette/Settings";
        SETTINGS=$(<./Settings);
        SETTINGS=(${SETTINGS});
    fi
}

#*: @function settings_load {
#*: Description: Previous Version Of The Settings Function
#*: }
# function settings_load {
#     if [[ "${APPLICATION}" = "true" ]]; then
#         directory_set;
#         if [[ ! -e "${LOCATION}/Resources/.palette/Settings/Settings" ]]; then
#             if [[ ! -d "${LOCATION}/Data/.tmp" ]]; then introduction; fi
#             setup_menu;
#         else
#             cd "${LOCATION}/Resources/.palette/Settings";
#             SETTINGS=$(<./Settings);
#             SETTINGS=(${SETTINGS});
#         fi
#     else
#         if [[ -z "${LOCAL// }" ]]; then
#             SETTINGS[0]="NO";
#             SETTINGS[1]="NO";
#         else
#             SETTINGS[0]="USER";
#             SETTINGS[1]="${LOCAL}";
#         fi
#         if [[ -z "${CLOUD// }" ]]; then
#             SETTINGS[2]="NO";
#             SETTINGS[3]="NO";
#         else
#             SETTINGS[2]="USER";
#             SETTINGS[3]="${CLOUD}";
#         fi
#         if [[ ! -z "${ICLOUD// }" ]]; then
#             SETTINGS[2]="ICLOUD";
#             if [[ "${ICLOUD}" = "APPLICATION" ]]; then
#                 SETTINGS[3]="Palette";
#             else
#                 SETTINGS[3]="${ICLOUD}";
#             fi
#         fi
#     fi
#     settings_check;
# }

#*: @function settings_check {
#*: Description: Previous Version Of The settings_check Function
#*: }
# function settings_check {
#     if [[ "${SETTINGS[0]}" = "NO" && "${SETTINGS[2]}" = "NO" ]]; then
#         if [[ "${APPLICATION}" = "true" ]]; then
#             settings_fix;
#         else
#             heading "Error:Values Are Not Properly Defined! A Local Path OR Cloud Path Must Be Defined!" "Palette: Error";
#             read -s -e -n 1 _key 2>/dev/null >&2;
#             exit;
#         fi
#     fi
# }

#*: @function settings_save {
#*: Description: Saves The Settings File For The Application
#*: Arguments:
#*: Purpose:
#*: }
function settings_save {
    if [[ ! -z "${SETTINGS[@]}" ]]; then
        cd "${LOCATION}/Resources/.palette/Settings";
        echo -e "${SETTINGS[0]}\n${SETTINGS[1]}\n${SETTINGS[2]}\n${SETTINGS[3]}" > "Settings";
    fi
}

#*: @function settings_save {
#*: Description: Previous Version Of The settings_save Function
#*: }
# function settings_save {
#     settings_check;
#     if [[ "${APPLICATION}" = "true" ]]; then
#         if [[ ! -z "${SETTINGS[@]}" ]]; then
#             cd "${LOCATION}/Resources/.palette/Settings";
#             echo -e "${SETTINGS[0]}\n${SETTINGS[1]}\n${SETTINGS[2]}\n${SETTINGS[3]}" > "Settings";
#         fi
#     fi
# }

#*: @function settings_fix {
#*: Description: 
#*: }
function settings_fix() {
    cd "${LOCATION}/Resources/.palette/Settings";
    if [[ -e "Settings" ]]; then mv "Settings" "/Users/$USER/.Trash" 2> /dev/null; fi
    unset SETTINGS;
    SETTINGS=();
    if (( "$#" > 0 )); then
        settings_load;
    else
        heading "Error:There Is An Issue With Your Palette Settings File! Your Data Has Not Been Affected, But You'll Need To Run The Initial Setup Again." "Palette: Error";
        case `select_opt "  Run Initial Setup  " "  Exit               "` in
            0) settings_load;;
            1) main_quit;;
        esac;
    fi
    main_menu;
}
#       ###: @End File }

#       ###: @Settings Setup {
#*: @function setup_menu {
#*: Description: 
#*: Arguments:
#*: Purpose:
#*: }
function setup_menu {
    unset SETTINGS;
    SETTINGS=();
    heading "Initial Setup:How Would You Like To Save Your Palette Data?" "Palette: Setup"
    case `select_opt "  Save Data Locally                        " "  Save Data To A Cloud Service             " "  Save Data Locally & To A Cloud Service   " "  Quit                                     "` in
        0) setup_local "false";;
        1) setup_cloud "false";;
        2) setup_local "true";;
        3) main_quit;;
    esac;
    settings_save;
}

#*: @function setup_local {
#*: Description: 
#*: Arguments:
#*: Purpose:
#*: }
function setup_local() {
    if [[ "${1}" = "false" ]]; then
        SETTINGS[2]="NO";
        SETTINGS[3]="NO";
    fi
    heading "Initial Setup:Palette Can Manage Your Saved Data Or You Can Choose A Folder. Would You Like Palette To Keep Your Saved Data Inside The App? [y,n]";
    display_yesorno;
    cursor_hide;
    read -s -e -n 1 _key 2>/dev/null >&2;
    _key=$(echo "${_key}" | tr '[:upper:]' '[:lower:]');
    if [[ "${_key}" = "y" ]]; then
        SETTINGS[0]="APPLICATION";
        SETTINGS[1]="${LOCATION}/Data";
    elif [[ "${_key}" = "n" ]]; then
        SETTINGS[0]="USER";
        setup_localpath;
    else
        setup_local ${1};
    fi
    if [[ "${1}" = "true" ]]; then
        setup_cloud "true";
    fi
}

#*: @function setup_localpath {
#*: Description: 
#*: Arguments:
#*: Purpose:
#*: }
function setup_localpath() {
    local _message="Saved Data Location:Enter The Absolute Folder Path To Store Saved Data. ( Tip - You Can Drag And Drop The Folder Onto The Terminal & Hit Enter )";
    if (( "$#" > 0 )); then _message=${1}; fi
    heading "${_message}";
    display_hint "[ Formatting: /Users/$USER/Documents/Palette ]" "${HINTCOLOR}";
    cursor_indent;
    cursor_hide;
    read _userpath;
    if [[ -d "${_userpath}" ]]; then
        heading "Saved Data Location:You Would Like To Store Your Palette Data In $(basename "${_userpath}") ? [y,n]";
        display_yesorno;
        cursor_hide;
        read -s -e -n 1 _key 2>/dev/null >&2;
        _key=$(echo "${_key}" | tr '[:upper:]' '[:lower:]');
        if [[ "${_key}" = "y" ]]; then
            cd "${_userpath}";
            if [[ ! -d "Backups" ]]; then mkdir "Backups"; fi
            if [[ ! -d "Palettes" ]]; then mkdir "Palettes"; fi
            SETTINGS[1]="${_userpath}";
        else
            setup_localpath;
        fi
    else
        setup_localpath "Error:The Entered Path Does Not Exist. Enter The File Path Formatted Like /Users/$USER/path/to/folder";
    fi
}

#*: @function setup_cloud {
#*: Description: 
#*: Arguments:
#*: Purpose:
#*: }
function setup_cloud() {
    if [[ "${1}" = "false" ]]; then
        SETTINGS[0]="NO";
        SETTINGS[1]="NO";
    fi
    heading "Initial Setup:Would You Like Your Data Backed Up To iCloud? [y,n] ( Press [ n ] To Use A Different Cloud Service )";
    display_hint "[  y  ]: To Use iCloud, [ n ]: To Use Another Cloud Service" "${HINTCOLOR}";
    cursor_hide;
    read -s -e -n 1 _key 2>/dev/null >&2;
    _key=$(echo "${_key}" | tr '[:upper:]' '[:lower:]');
    if [[ "${_key}" = "y" ]]; then
        _key="";
        SETTINGS[2]="ICLOUD";
        heading "iCloud Data Location:Would You Like Palette To Manage Where Your Data Will Be Saved In iCloud Drive? ( Palette Will Save Your Data In A Folder Named Palette In The iCloud Drive Root Folder. Press [ y ] To Let Palette Manage Storage Location OR Press [ n ] To Specify A Folder Path To Use For Palette's Data In iCloud Drive ) [y,n]";
        display_yesorno;
        cursor_hide;
        read -s -e -n 1 _key 2>/dev/null >&2;
        _key=$(echo "${_key}" | tr '[:upper:]' '[:lower:]');
        if [[ "${_key}" = "y" ]]; then
            cd /Users/$USER/Library/Mobile\ Documents/com\~apple\~CloudDocs;
            if [[ ! -d "Palette" ]]; then mkdir -p Palette/{Backups,Palettes}; fi
            cd "Palette";
            if [[ ! -d "Backups" ]]; then mkdir "Backups"; fi
            if [[ ! -d "Palettes" ]]; then mkdir "Palettes"; fi
            SETTINGS[3]="Palette";
        elif [[ "${_key}" = "n" ]]; then
            setup_icloudpath;
        fi
    elif [[ "${_key}" = "n" ]]; then
        SETTINGS[2]="USER";
        setup_cloudpath;
    else
        setup_cloud "${1}";
    fi
}

#*: @function setup_icloudpath {
#*: Description: 
#*: Arguments:
#*: Purpose:
#*: }
function setup_icloudpath() {
    local _message="iCloud Data Location:Enter The Path Inside Of Your iCloud Drive Where You Would Like Palette To Save It's Data. ( IMPORTANT - Do NOT Type The Absolute Path! Only Enter The Path Starting From The Root Of Your iCloud Drive! eg: path/to/palette || eg: folder-name )";
    if (( "$#" > 0 )); then _message=${1}; fi
    heading "${_message}";
    display_hint "[ Formatting: folder/path/to/storage ]" "${HINTCOLOR}";
    cursor_indent;
    cursor_hide;
    read _icloudpath;
    cd /Users/$USER/Library/Mobile\ Documents/com\~apple\~CloudDocs;
    if [[ -d "${_icloudpath}" ]]; then
        heading "iCloud Data Location:You Would Like To Store Your Palette Data In $(basename "${_icloudpath}") In Your iCloud Drive? [y,n]";
        display_yesorno;
        cursor_hide;
        read -s -e -n 1 _key 2>/dev/null >&2;
        _key=$(echo "${_key}" | tr '[:upper:]' '[:lower:]');
        if [[ "${_key}" = "y" ]]; then
            cd /Users/$USER/Library/Mobile\ Documents/com\~apple\~CloudDocs;
            cd "${_icloudpath}";
            if [[ ! -d "Backups" ]]; then mkdir "Backups"; fi
            if [[ ! -d "Palettes" ]]; then mkdir "Palettes"; fi
            SETTINGS[3]="${_icloudpath}";
        else
            setup_icloudpath;
        fi
    else
        setup_icloudpath "Error:The Entered Path Does Not Exist. Enter The File Path Formatted Like path/to/folder";
    fi
}

#*: @function setup_cloudpath {
#*: Description: 
#*: Arguments:
#*: Purpose:
#*: }
function setup_cloudpath() {
    local _message="Cloud Data Location:Enter The Absolute Folder Path To Store Saved Data ( Tip - You Can Drag And Drop The Folder Onto The Terminal & Hit Enter ) ( If DropBox Is Installed, Provide The Absolute Folder Path To The Folder In DropBox Where You Want Palette To Store It's Data )";
    if (( "$#" > 0 )); then _message=${1}; fi
    heading "${_message}"
    display_hint "[ Formatting: /Users/$USER/DropBox/Palette ]" "${HINTCOLOR}";
    cursor_indent;
    cursor_hide;
    read _userpath;
    if [[ -d "${_userpath}" ]]; then
        heading "Saved Data Location:You Would Like To Store Your Palette Data In $(basename "${_userpath}") ? [y,n]";
        display_yesorno;
        cursor_hide;
        read -s -e -n 1 _key 2>/dev/null >&2;
        _key=$(echo "${_key}" | tr '[:upper:]' '[:lower:]');
        if [[ "${_key}" = "y" ]]; then
            cd "${_userpath}";
            if [[ ! -d "Backups" ]]; then mkdir "Backups"; fi
            if [[ ! -d "Palettes" ]]; then mkdir "Palettes"; fi
            SETTINGS[3]="${_userpath}";
        else
            setup_cloudpath;
        fi
    else
        setup_cloudpath "Error:The Entered Path Does Not Exist. Enter The File Path Formatted Like /Users/$USER/path/to/folder";
    fi
}
#       ###: @End Setup }
#   ##: @End Settings }

#   ##:  @Functions Directories {
#*: @function directory_up {
#*: Description: Moves Up The Specified Amount Of Directories
#*: Arguments: _amount (INT) -- The Number Of Times To Move Up In The Current Directory
#*: Purpose: Used As A Shortcut To Traverse Up Directories
#*: }
function directory_up() {
    # Set The Default Amount Of Directories To Move Up To 1 If No Value Is Passed To The Function Call
    local _amount=1;
    # If A Value Is Passed To The Function Call Set The _amount Variable Equal To That Value
    if (( "$#" > 0 )); then _amount=${1}; fi
    # While The _amount Variable Does Not Equal 0 Move Up A Directory; Subtract 1 From The _amount Variable Value Each Time The Loop Completes
    while [[ "${_amount}" -ne 0 ]]; do
        cd ..
        _amount=$(( _amount - 1 ));
    done
}

#*: @function directory_change {
#*: Description: Changes The Directory To Where Palette Data Is Stored According To The File Paths Set In The Settings & Depending Upon If The User Has Local, Cloud, Or Both Enabled In The Settings
#*: Arguments: _directory (String) "local" || "cloud"; _subdirectory (String) (Optional) "Backups" || "Palettes";
#*: Purpose: Used To Move To The Appropriate Directory Where Palette Data Is Stored Locally Or For Cloud Saves. Also Moves Into The Backups Or Palettes Data Directory If Specified
#*: }
function directory_change() {
    if (( "$#" > 1 )); then _subdirectory=${2}; fi
    if [[ "${1}" = "local" ]]; then
        if [[ "${SETTINGS[0]}" != "NO" ]]; then
                cd "${SETTINGS[1]}";
        fi
    elif [[ "${1}" = "cloud" ]]; then
        if [[ "${SETTINGS[2]}" != "NO" ]]; then
            if [[ "${SETTINGS[2]}" = "ICLOUD" ]]; then cd /Users/$USER/Library/Mobile\ Documents/com\~apple\~CloudDocs; fi
            cd "${SETTINGS[3]}";
        fi
    fi
    if [[ ! -d "Backups" ]]; then mkdir "Backups"; fi
    if [[ ! -d "Palettes" ]]; then mkdir "Palettes"; fi
    if [[ ! -z ${_subdirectory// } ]]; then cd "${_subdirectory}"; fi
}

#*: @function directory_local {
#*: Description: 
#*: Arguments:
#*: Purpose:
#*: }
function directory_local() {
    # Check If The Local Backup Is Enabled In The Settings
    if [[ "${SETTINGS[0]}" != "NO" ]]; then
        # If The Local Backup Setting Is Enabled Change Into The Directory Path Specified In The SETTINGS Array
        cd "${SETTINGS[1]}";
        # Check If The Backups Folder Exists; If It Does Not Create The Directory
        if [[ ! -d "Backups" ]]; then mkdir "Backups"; fi
        # Check If The Palettes Folder Exists; If It Does Not Create The Directory
        if [[ ! -d "Palettes" ]]; then mkdir "Palettes"; fi
        # If A Value Was Passed To The Function Call, Change Into That Directory. The Functions Assumes Either "Backups" or "Palettes" or No Value Will Ba Passed To The Function
        if (( "$#" > 0 )); then cd "${1}"; fi
    fi
}

#*: @function directory_cloud {
#*: Description: Changes Into The Directory Assigned For Cloud Storage For Saving Palette Data If Cloud Backup Is Enabled
#*: Arguments: _path (String) ( Optional ) -- Optionally, Can Pass In "Backups" || "Palettes" & The Function Will Change Into The Directory After It Has Moved Into The Approriate Directory Assigned For Saving Data In A Cloud Storage
#*: Purpose: Used To Move Into The Appropriate Cloud Storage Folders When Palette Data Needs To Be Read From Or Written
#*: }
function directory_cloud() {
    # Check If Cloud Backup Is Enabled In The Settings
    if [[ "${SETTINGS[2]}" != "NO" ]]; then
        # If A Cloud Backup Setting Is Enabled Check If It Is Backing Up To iCloud; If iCloud Is Being Used First cd Into The Root Of iCloud Drive
        if [[ "${SETTINGS[2]}" = "ICLOUD" ]]; then cd /Users/$USER/Library/Mobile\ Documents/com\~apple\~CloudDocs; fi
        # Change To The Directory Stored In Settings For Cloud Storage Path; If The Backup Is Not iCloud, The Directory Will Be The Path Specified By The User, If The App Is Using iCloud The Directory Is Already In The iCloud Drive Base. It Will Then Change Directory To The Palette Folder In The Root Of iCloud Drive If The Application Is Managing The iCloud Backup Or If The User Specified A Location Then It Will Change Into The User Specified Folder Relative To The Root Of The iCloud Drive Folder
        cd "${SETTINGS[3]}";
        # Check If The Backups Folder Exists; If It Does Not Create The Directory
        if [[ ! -d "Backups" ]]; then mkdir "Backups"; fi
        # Check If The Palettes Folder Exists; If It Does Not Create The Directory
        if [[ ! -d "Palettes" ]]; then mkdir "Palettes"; fi
        # If A Value Was Passed To The Function Call, Change Into That Directory. The Functions Assumes Either "Backups" or "Palettes" or No Value Will Ba Passed To The Function
        if (( "$#" > 0 )); then cd "${1}"; fi
    fi
}

#*: @function directory_set {
#*: Description: Sets The Directory For Where Data Is Stored If Using The Application
#*: Purpose: Sets The LOCATION Variable Equal To The Base Directory Where Different Scripts, Directories, & Files Will Be Accessed & Ensures The Required Folders Exist
#*: }
function directory_set {
    # Move Into The Directory Where The Script Is Running From
    cd "${CONTROLLER}";
    # Move Up 3 Directories Where MacOS, Resources, & The Data Folder Will Reside
    directory_up 3;
    # Set The LOCATION Variable Equal To The Current Working Directory
    LOCATION=$(pwd);
    # Check If The Data Directory Exists; If It Doesn't Create The Directory
    if [[ ! -d "Data" ]]; then mkdir "Data"; fi
    # Change Into The Data Directory
    cd "Data";
    # Check If The Backups Directory Exists; If It Doesn't Create The Directory
    if [[ ! -d "Backups" ]]; then mkdir "Backups"; fi
    # Check If The Palettes Directory Exists; If It Doesn't Create The Directory
    if [[ ! -d "Palettes" ]]; then mkdir "Palettes"; fi
    # Move Up 1 Directory
    directory_up 1;
    # Move Into The Directory Where The Settings File Will Exist
    cd "Resources/.palette";
    # Check If The Settingss Directory Exists; If It Doesn't Create The Directory
    if [[ ! -d "Settings" ]]; then mkdir "Settings"; fi
}
#   ##: @End Directories }

#   ##:  @Functions Icons {
#*: @function icon_random {
#*: Description: Chooses A Color At Random For Applying To A Generated Palette File
#*: Purpose: Used To Vary The Icons Color Of Palette Files Created When Using The Application
#*: }
function icon_random {
    local _seed=$(( ( RANDOM % 10 )  + 1 ));
    local _icon;
    case "${_seed}" in
        1) _icon="Aqua";;
        2) _icon="Blue";;
        3) _icon="Coral";;
        4) _icon="Lime";;
        5) _icon="Magenta";;
        6) _icon="Orange";;
        7) _icon="Pink";;
        8) _icon="Purple";;
        9) _icon="Red";;
        10) _icon="Yellow";;
    esac;
    echo "${_icon}";
}

#*: @function icon_files {
#*: Description: Chooses A Color Based On The Amount Of Files 
#*: Arguments: _option (String) "Backups" || "Palettes"; Accepts The Type Of Palette File Being Saved
#*: Purpose: Chooses A Color Based On The Amount Of Existing Saved Files Of "Backups" || "Palettes" So Each Palette File Icon Is A Different Color
#*: }
function icon_files() {
    local _option=${1};
    local _icon="Aqua";
    if [[ "${SETTINGS[0]}" != "NO" ]]; then
        directory_local "${_option}";
    elif [[ "${SETTINGS[2]}" != "NO" ]]; then
        directory_cloud "${_option}";
    fi
    local _count=$(ls | egrep '\.palette$');
    if [[ ! -z "${_count// }" ]]; then
        IFS=$'\n';
        _count=(${_count});
        IFS=${IFSC};
        _count=${#_count[@]};
        if (( _count > 10 )); then
            _count=$(echo "scale=1;(( ${_count} / 10 ))" | bc);
            _count=$(echo "${_count}" | cut -d'.' -f 2);
        fi
        case "${_count}" in
            0) _icon="Aqua";;
            1) _icon="Blue";;
            2) _icon="Purple";;
            3) _icon="Magenta";;
            4) _icon="Pink";;
            5) _icon="Red";;
            6) _icon="Yellow";;
            7) _icon="Lime";;
            8) _icon="Orange";;
            9) _icon="Coral";;
        esac;
    fi
    echo "${_icon}";
}

#*: @function icon_apply {
#*: Description: Applies The Specified Color Icon To The Specified File That Was Created By Palette
#*: Arguments: _option (String) -- "Backups" || "Palettes"; _file (String) -- "Filename" The Name Of The Palette File Created That Will Have An Icon Applied To It
#*: Purpose: If The Application Version Is Running The Palette Files Created Will Have A Different Color Glass Block As An Icon To Vary The Icon Colors Of The Palette File Document Type
#*: }
function icon_apply() {
    local _option=${1}
    local _file=${2};
    local _icon="Aqua";
    if [[ "${_option}" = "Backups" ]]; then
        _icon=$(icon_files "${_option}");
    elif [[ "${_option}" = "Palettes" ]]; then
        _icon=$(icon_random);
    fi
    cd "${LOCATION}/Resources/.palette/Apps";
    local _apply=$(./SetFileIcon -image "${LOCATION}/Resources/Icons/${_icon}.icns" -file "${LOCATION}/Data/${_option}/${_file}.palette" 2> /dev/null);
}
#   ##: @End Icons }

#   ##: @Functions Preview {
#*: @function preview_menu {
#*: Description: 
#*: Arguments:
#*: Purpose:
#*: }
function preview_menu() {
    if (( "$#" > 0 )); then preview_list "${1}"; fi
    heading "Preview:Would You Like To View A Backup Or A Saved Palette?" "Palette: Preview";
    case `select_opt "  Backup   " "  Palette  " "  Back     "` in
        0) preview_list "Backups";;
        1) preview_list "Palettes";;
        2) main_menu;;
    esac;
}

#*: @function preview_backup {
#*: Description: 
#*: Arguments:
#*: Purpose:
#*: }
function preview_list() {
    local _view=${1};
    local _files=$(data_list "${_view}");
              _files="${_files// }";
    if [[ -z "${_files//$'\n'}" ]]; then
        main_menu "There Is Are No ${_view} To Preview";
    else
        _files=(${_files});
        if [[ "${_view}" = "Palettes" ]]; then
            local _str="${_files[0]}";
            local _tmp=();
            if (( "${#_files[@]}" > 1 )); then for _line in "${_files[@]:1}"; do if (( "${#_line}" > "${#_str}" )); then _str="${_line}"; fi; done; fi;
            for _line in "${_files[@]}"; do
                _line=$(str_space "${_line}" "trailing" $(( ${#_str} - ${#_line} )));
                _tmp+=( "${_line}" );
            done
            _files=( "${_tmp[@]}" );
        fi
        _files+=( "Back " );
        heading "Preview:Select A File To Preview" "Palette: Preview";
        case `select_opt "${_files[@]}"` in
            *) _selection=${_files[$?]};;
        esac;
        if [[ "${_selection// }" = "Back" ]]; then
            preview_menu;
        else
            preview_file "${_selection// }" "${_view}";
        fi
    fi
}

#*: @function preview_open {
#*: Description: 
#*: Arguments:
#*: Purpose:
#*: }
function preview_file() {
    local _id=${1};
    if (( "$#" > 1 )); then
        local _option=${2};
        if [[ "${SETTINGS[0]}" != "NO" ]]; then
            directory_local "${_option}";
            if [[ -e "${_id}.palette" ]]; then _file=$(<./"${_id}".palette); fi
        fi
        if [[ -z "${_file// }" ]]; then
            if [[ "${SETTINGS[2]}" != "NO" ]]; then
                directory_cloud "${_option}";
                if [[ -e "${_id}.palette" ]]; then _file=$(<./"${_id}".palette); fi
            fi
        fi
    else
        if [[ -e "${_id}" ]]; then _file=$(<"${_id}"); fi
        _id=$(basename -s .palette "${_id}");
    fi
   if [[ ! -z "${_file// }" ]]; then
        local _type=$(echo -e "${_file//=}" | head -n 1 | cut -d':' -f 2);
        if [[ "${_type}" = "B" ]]; then
            local _count=$(echo -e "${_file//=}" | head -n 2 | tail -n -1 | cut -d':' -f 2);
            if (( _count > 0 )); then local _colors=$(echo -e "${_file}" | head -n 3 | tail -n -1); fi
        elif [[ "${_type}" = "P" ]]; then
            local _count=$(echo -e "${_file//=}" | head -n 2 | tail -n -1 | cut -d':' -f 2);
            if (( _count > 0 )); then
                local _colors=$(echo -e "${_file}" | tail -n +3);
                _colors="${_colors//$'\n'/,}";
            fi
        fi
        preview_construct "${_id}" "${_colors}";
        preview_open;
        loading 2;
        if [[ ! -z "${_option}" ]]; then
            preview_menu "${_option}";
        else
            main_menu;
        fi
    else
        main_menu "Error: There Was An Issue Attempting To Load The Palette. Please Report This Issue.";
    fi
}

#*: @function preview_construct {
#*: Description: Constructs An SVG File With The Colors In The Selected Palette For Preview
#*: Arguments: _id(STR) - Filename. _colors(STR) - List Of Colors To Build The Preview From.
#*: }
function preview_construct() {
    local _id=${1};
    local _colors=${2};
    if [[ ! -z ${_colors// } ]]; then
        _colors="${_colors//,/$'\n'}";
        IFS=$'\n';
        _colors=(${_colors});
        IFS=${IFSC};
        local _rect=60;
        local _text=90;
        local _height=$(( (( ${#_colors[@]} * 60 )) + 200 ));
        _file="<svg version=\"1.1\" id=\"Layer_1\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" x=\"0px\" y=\"0px\"
            width=\"512px\" height=\"${_height}px\" viewBox=\"0 0 512 ${_height}\" xml:space=\"preserve\">
            <text transform=\"matrix(1 0 0 1 110 100)\" style=\"font-family:'HelveticaNeue-Thin'; font-size:42px;\">${_id}</text>";
        for _color in "${_colors[@]}"; do
            _rect=$(( _rect + 60 ));
            _text=$(( _text + 60 ));
            _color="<rect x=\"110\" y=\"${_rect}\" style=\"fill:#${_color};\" width=\"50\" height=\"50\"/>
                        <text transform=\"matrix(1 0 0 1 170 ${_text})\" style=\"font-family:'HelveticaNeue-Thin'; font-size:12px;\">${_color}</text>";
            _file="${_file}
                        ${_color}";
        done
        _file="${_file} </svg>";
        cd "${LOCATION}/Data/.tmp";
        echo -e "${_file}" > "Preview.svg";
    fi
}

#*: @function preview_open {
#*: Description: Opens The Preview File In Safari
#*: }
function preview_open {
    cd "${LOCATION}/Data/.tmp";
    if [[ -e "Preview.svg" ]]; then
        open -a Safari "Preview.svg";
    fi
}
#   ##: @End Preview }

#   ##:  @Functions Data {
#*: @function data_backup {
#*: Description: Creates A Dated Backup Of The Color Data In ColorSnapper At The Time Of Running The Function. Upon Saving The User Has The Option Of Adding A Note To Help Identify The Significance Of The Backup. The Backup Palette Is Saved To The Local & || Cloud File Paths Specified In The Settings
#*: Purpose: Allows The User To Create A Dated Backup Of Color Files For Situations Such As But Not Limited To, Clearing ColorSnapper Data When Starting A New Project To Keep Color Data Organized & Grouped With The Corresponding Project They Belong To, Saving A Backup Of Important Colors Needed In Case Of Data Loss, Transfering Color Data From One Computer To Another If Working With Multiple Computers, Sharing Color Data With Others, etc
#*: }
function data_backup() {
    local _message;
    local _note;
    # The TODAY Value With The Current Date In Case The Date Has Changed Since The Application Has Been Running
    update_date;
    # Check If Color Data Exists Before Allowing A Backup To Be Made
    local _check=$(data_check "Backups");
    # If The Check Is Not False Then Continue
    if [[ "${_check}" != "false" ]]; then
        # If No Values Are Passed To The Function, Display The Logo & Ask If The User Would Like To Add A Note To The Backup
        if (( "$#" < 1 )); then
            heading "Backup:Press Enter To Backup ( Optional - You Can Type A Short Note To Help You Identify The Significance Of This Backup )" "Palette: Backup";
            display_hint "[ Maximum Of 255 Characters ]" "${HINTCOLOR}";
            cursor_indent
            cursor_hide
            read -r _note
            if [[ ! -z "${_note// }" ]]; then
                _note=${_note//[^a-zA-Z0-9_ -]/};
                if [[ "${#_note}" -gt 255 ]]; then _note="${_note:0:255}"; fi
            fi
            _message=$(data_message "Backups" "${TODAY}");
        else
            _message=${1};
        fi
        if [[ "${SETTINGS[0]}" != "NO" ]]; then
            directory_local "Backups";
            data_save "Backups" "${TODAY}" "${_note}";
        fi
        if [[ "${SETTINGS[2]}" != "NO" ]]; then
            directory_cloud "Backups";
            data_save "Backups" "${TODAY}" "${_note}";
        fi
        main_menu "${_message}";
    # If The Data Check Returns False Then There Are No Colors To Save; Return To The Main Menu Displaying An Error To The User
    else
        main_menu "Error:There Are No Colors In ColorSnapper To Save";
    fi
}

#*: @function data_restore {
#*: Description: 
#*: Arguments:
#*: Purpose:
#*: }
function data_restore {
    local _note=0;
    # Grab The List Of Backup Files & Store It In The _list Variable
    local _list=$(data_list "Backups");
    # Convert The List Of Files Into An Array
              _list=(${_list});
    # If No Files Exist In The Backups Directory Then Return The User To The Main Menu Showing An Error
    if (( ${#_list[@]} < 1 )); then
        main_menu "Error:There Are No Backups Available To Restore From";
    else
        _list+=( "Back " );
        heading "Restore:Choose A Date To Restore A ColorSnapper Backup Data From" "Palette: Restore";
        case `select_opt "${_list[@]}"` in
            *) _selection=${_list[$?]};;
        esac;
        if [[ "${_selection// }" != "Back" ]]; then
            data_preload "${_selection// }" "Backups"
            heading "Restore ColorSnapper From A Backup:Restore The Data From ${_selection// }? [y,n] ( This Will Overwrite The Colors Currently In ColorSnapper! )";
            _note=$(data_note);
            if [[ "${_note}" != "0" ]]; then display_single "${_selection// } Note:  ${_note}"; fi
            display_yesorno;
            cursor_hide;
            read -s -e -n 1 _key 2>/dev/null >&2;
            _key=$(echo "${_key}" | tr '[:upper:]' '[:lower:]');
            if [[ "${_key}" = "y" ]]; then
                data_write "${_selection// }" "Backups";
                main_menu "ColorSnapper Data Restored From ${_selection// }";
            else
                data_restore;
            fi
        else
            main_menu;
        fi
    fi
}

#*: @function data_clear {
#*: Description: Kills The ColorSnapper Process, Clears Any Data In ColorSnapper & Relaunches The Application
#*: }
function data_clear {
    heading "Clear ColorSnapper:This Clears All Colors Currently In Your ColorSnapper Application. This Will Not Touch The Data Palette Has Created. This Is Not Reversable. Are You Sure You Want To Clear ColorSnapper? [y,n]" "Palette: Clear ColorSnapper";
    display_yesorno;
    cursor_hide;
    read -s -e -n 1 _key 2>/dev/null >&2;
    _key=$(echo "${_key}" | tr '[:upper:]' '[:lower:]');
    if [[ "${_key}" = "y" ]]; then
        loading 1;
        colorsnapper_kill;
        sleep 0.3s
        colorsnapper_clear;
        sleep 0.3s;
        colorsnapper_launch;
        main_menu "ColorSnapper Data Has Been Cleared";
    elif [[ "${_key}" = "n" ]]; then
        main_menu;
    else
        data_clear;
    fi
}

#*: @function data_create {
#*: Description: 
#*: Arguments:
#*: Purpose:
#*: }
function data_create {
    local _palette;
    local _data=$(data_check "Palettes");
    if [[ "${_data}" != "false" ]]; then
        heading "Save Palette As:Type A Name To Identify The Color Palette ( Letters, Numbers, Spaces, Underscores & Dashes Allowed )" "Palette: Save Palette As";
        cursor_indent;
        cursor_hide
        read -r _palette;
        _palette=${_palette//[^a-zA-Z0-9_ - ]/};
        _palette=$(echo "${_palette}"|tr " " "-");
        if [[ "${#_palette}" -gt 40 ]]; then _palette=${_palette:0:40}; fi
        heading "Save Palette As: ${_palette} - Is This Correct? [y,n]";
        display_yesorno;
        cursor_hide;
        read -s -e -n 1 _key 2>/dev/null >&2;
        _key=$(echo "${_key}" | tr '[:upper:]' '[:lower:]');
        if [[ "${_key}" = "y" ]]; then
            if [[ "${SETTINGS[0]}" != "NO" ]]; then
                directory_local "Palettes";
                data_save "Palettes" "${_palette}";
            fi
            if [[ "${SETTINGS[2]}" != "NO" ]]; then
                directory_cloud "Palettes";
                data_save "Palettes" "${_palette}";
            fi
            _message=$(data_message "Palettes" "${_palette}");
            main_menu "${_message}";
        else
            main_menu;
        fi
    else
        main_menu "Error:A Palette Is Generated From Colors Marked As Favorite. You Don't Have Any Colors Marked As A Favorite."
    fi
}

#*: @function data_load {
#*: Description: 
#*: Arguments:
#*: }
function data_load {
    local _list;
    local _file;
    local _str;
    local _tmp=();
    _list=$(data_list "Palettes");
    _list=(${_list});
    if (( ${#_list[@]} < 1 )); then
        main_menu "You Haven't Created Any Color Palettes";
    else
        _list+=( "Back " );
        _str="${_list[0]}";
        if (( "${#_list[@]}" > 1 )); then for _line in "${_list[@]:1}"; do if (( "${#_line}" > "${#_str}" )); then _str="${_line}"; fi; done; fi;
        for _line in "${_list[@]}"; do
            _line=$(str_space "${_line}" "trailing" $(( ${#_str} - ${#_line} )));
            _tmp+=( "${_line}" );
        done
        _list=( "${_tmp[@]}" );
        heading "Load A Palette:Select A Color Palette To Load" "Palette: Load A Color Palette";
        case `select_opt "${_list[@]}"` in
            *) _file=${_list[$?]};;
        esac;
        if [[ "${_file// }" = "Back" ]]; then
            main_menu;
        else
            heading "Load Palette:You Want To Load ${_file// }? [y,n] (This Will Overwrite The Colors In ColorSnapper! Consider Backing Up First!)";
            display_yesorno;
            cursor_hide;
            read -s -e -n 1 _key 2>/dev/null >&2;
            _key=$(echo "${_key}" | tr '[:upper:]' '[:lower:]');
            if [[ "${_key}" = "y" ]]; then
                data_write "Palettes" "${_file// }";
                main_menu "The Palette ${_file// } Has Been Loaded Into ColorSnapper";
            elif [[ "${_key}" = "n" ]]; then
                main_menu;
            else
                data_load;
            fi
        fi
    fi
}

#*: @function data_sync {
#*: Description: 
#*: Arguments:
#*: Purpose:
#*: }
function data_sync {
    if [[ "${SETTINGS[2]}" != "NO" ]]; then
        heading "ColorSnapper Sync:Are You Sure You Want To Sync Your Current ColorSnapper Colors With Your Most Recent Cloud Backup? [y,n]" "Palette: Sync";
        display_yesorno;
        cursor_hide;
        read -s -e -n 1 _key 2>/dev/null >&2;
        _key=$(echo "${_key}" | tr '[:upper:]' '[:lower:]');
        if [[ "${_key}" = "y" ]]; then
            local _data="";
            local _current=$(defaults read com.koolesache.ColorSnapper2 HistoryColors);
            directory_cloud;
            cd "Backup";
            local _cloud=$(ls -t | head -1);
            cd "${_cloud}";
            local _colors=$(<./History.palette);
            _colors="${_colors} ${_current}";
            _colors="${_colors//(}";
            _colors="${_colors//)}";
            _colors=$(echo "${_colors}"|tr "," "\n"|sort|uniq);
            _colors=( ${_colors} );
            _data=$(echo -e "\t${_colors[0]},");
            for _line in "${_colors[@]:1}"; do
                _data=$(echo -e "${_data}\n\t${_line},");
            done
            _data=$(echo -e "(\n${_data}\n)");
            colorsnapper_kill;
            defaults write com.koolesache.ColorSnapper2 HistoryColors "${_data}";
            sleep 1s;
            colorsnapper_launch
            sleep 1s;
            data_backup "ColorSnapper Successfully Synced";
        else
            main_menu;
        fi
    else
        main_menu "You Do Not Have Cloud Backup Setup. You'll Likely Want To Use The Combine Option";
    fi
}

#*: @function data_combine {
#*: Description: 
#*: Arguments:
#*: Purpose:
#*: }
function data_combine {
    heading "Combine:This Will Merge The Colors Currently Loaded In ColorSnapper With The Palette File You Provide. Would You Like To Proceed? [y,n]" "Palette: Combine";
    display_yesorno;
    cursor_hide;
    read -s -e -n 1 _key 2>/dev/null >&2;
    _key=$(echo "${_key}" | tr '[:upper:]' '[:lower:]');
    if [[ "${_key}" = "y" ]]; then
        _key="";
        local _userpath;
        heading "Palette File:Provide The Absolute File Path To The File You Would Like To Merge Into ColorSnapper. (Tip - You Can Drag & Drop The File Onto The Terminal Window & Hit Enter)";
        read _userpath;
        local _folder=$(basename "${_userpath}");
        heading "Palette File:${_folder} Is The Correct File? [y,n]";
        cursor_hide;
        read -s -e -n 1 _key 2>/dev/null >&2;
        _key=$(echo "${_key}" | tr '[:upper:]' '[:lower:]');
        if [[ "${_key}" = "y" ]]; then
            _userpath=${_userpath// };
            local _user=$(<"${_userpath}");
            local _current=$(defaults read com.koolesache.ColorSnapper2 HistoryColors);
            _colors="${_user} ${_current}";
            _colors="${_colors//(}";
            _colors="${_colors//)}";
            _colors=$(echo "${_colors}"|tr "," "\n"|sort|uniq);
            _colors=( ${_colors} );
            _data=$(echo -e "\t${_colors[0]},")
            for _line in "${_colors[@]:1}"; do
                _data=$(echo -e "${_data}\n\t${_line},");
            done
            _data=$(echo -e "(\n${_data}\n)");
            colorsnapper_kill;
            defaults write com.koolesache.ColorSnapper2 HistoryColors "${_data}";
            sleep 1s;
            colorsnapper_launch
            sleep 1s;
            main_menu "Palette Data Merged & Loaded Into ColorSnapper";
        else
            main_menu;
        fi
    else
        main_menu;
    fi
}

#       ##:  @Data Management {
#*: @function data_export {
#*: Description: 
#*: Arguments:
#*: Purpose:
#*: }
function data_export {
    if [[ "${APPLICATION}" = "true" && "${SETTINGS[0]}" = "APPLICATION" ]]; then
        local _backups=$(data_list "backup");
        _backups=${_backups//"Back"}
        local _palettes=$(data_list "palette");
        local _list="${_backups}\n${_palettes}"
        _list=(${_list});
        if (( ${#_list[@]} < 2 )); then main_menu "There Is No Saved Data Available To Export"; fi
        heading "Export:Choose A File To Export To Your Downloads Folder. Backup Dates Are Listed & Color Palettes Are Listed Below.";
        case `select_opt "${_list[@]}"` in
            *) _selection=${_list[$?]};;
        esac;
        if [[ "${_selection}" = "Back" ]]; then main_menu; fi
        if [[ "${_selection// }" = "" ]]; then data_export; fi 
        data_exporter "${_selection}";
        main_menu "${_selection} Has Been Exported To Your Downloads Folder";
    else
        main_menu "Data Management Is Only Available For The Application Version Of Palette";
    fi
}

#*: @function manage_backups {
#*: Description: 
#*: Arguments:
#*: Purpose:
#*: }
function export_backups {
    if [[ "${APPLICATION}" = "true" && "${SETTINGS[0]}" = "APPLICATION" ]]; then
        local _list=$(data_list "backup");
        _list=${_list//"Back"}
        local _tmp=$(data_list "palette");
        _list="${_list}\n${_tmp}"
        _list=(${_list});
        if (( ${#_list[@]} < 2 )); then main_menu "There Are No Backups Saved To Palette"; fi
        heading "Export:Choose A File To Export To Your Downloads Folder. Backup Dates Are Listed & Color Palettes Are Listed Below.";
        case `select_opt "${_list[@]}"` in
            *) _selection=${_list[$?]};;
        esac;
        if [[ "${_selection}" = "Back" ]]; then main_menu; fi
        if [[ "${_selection// }" = "" ]]; then data_export; fi 
        data_exporter "backup" "${_selection}";
        main_menu "${_selection} Has Been Exported To Your Downloads Folder";
    else
        main_menu "Data Management Is Only Available For The Application Version Of Palette";
    fi
}

#*: @function manage_palettes {
#*: Description: 
#*: Arguments:
#*: Purpose:
#*: }
function export_palettes {
    if [[ "${APPLICATION}" = "true" && "${SETTINGS[0]}" = "APPLICATION" ]]; then
        local _local;
        local _cloud;
        local _list;
        local _selected;
        _list=$(data_list "palette");
        _list=(${_list});
        if (( ${#_list[@]} < 2 )); then main_menu "You Don't Have Any Color Palettes Saved In The Application"; fi
        heading "Export A Palette:Select A Color Palette To Export To Your Downloads Folder";
        case `select_opt "${_list[@]}"` in
            *) _selection=${_list[$?]};;
        esac;
        if [[ "${_selection}" = "Back" ]]; then main_menu; fi
        data_exporter "palette" "${_selection}";
        main_menu "The Palette ${_selection} Has Been Exported To Your Downloads Folder";
    else
        main_menu "Data Management Is Only Available For The Application Version Of Palette";
    fi
}

#*: @function manage_backups {
#*: Description: 
#*: Arguments:
#*: Purpose:
#*: }
function data_exporter() {
    if [[ "${APPLICATION}" = "true" && "${SETTINGS[0]}" = "APPLICATION" ]]; then
        cd "${LOCATION}/.palette";
        local _option=${1};
        if [[ "${_option}" = "backup" ]]; then
            local _option="Backup";
        elif [[ "${_option}" = "palette" ]]; then
            local _option="Palettes";
        fi
        local _id=${2};
        cd "${_option}";
        if [[ "${_option}" = "Backup" ]]; then
            if [[ -d ${_id} ]]; then
                cd "${_id}";
                cp "History.palette" "/Users/$USER/Downloads/${_id}.palette";
            fi
        elif [[ "${_option}" = "Palettes" ]]; then
            if [[ -e "${_id}.palette" ]]; then cp "${_id}.palette" "/Users/$USER/Downloads/${_id}.palette"; fi
        fi
    else
        main_menu "Data Management Is Only Available For The Application Version Of Palette";
    fi
}

#*: @function data_manage {
#*: Description: 
#*: Arguments:
#*: Purpose:
#*: }
function data_manage {
    if [[ "${APPLICATION}" = "true" && "${SETTINGS[0]}" = "APPLICATION" ]]; then
        heading "Manage Saved Data:Here You Can Delete Old Or Unwanted Backups Or Palettes. Would You Like To Manage Your Backups Or Color Palettes?" "Palette: Delete";
        case `select_opt "  Backups   " "  Palettes  " "  Back      "` in
            0) manage_backups;;
            1) manage_palettes;;
            2) main_menu;;
        esac;
    else
        main_menu "Data Management Is Only Available For The Application Version Of Palette";
    fi
}

#*: @function manage_backups {
#*: Description: 
#*: Arguments:
#*: Purpose:
#*: }
function manage_backups {
    if [[ "${APPLICATION}" = "true" && "${SETTINGS[0]}" = "APPLICATION" ]]; then
        local _history="";
        local _favorites="";
        local _list="";
        local _date;
        _list=$(data_list "backup");
        _list=(${_list});
        if (( ${#_list[@]} < 2 )); then main_menu "There Are No Backups Saved To Palette"; fi
        heading "Manage Backups:Choose A Date To Delete";
        case `select_opt "${_list[@]}"` in
            *) _selection=${_list[$?]};;
        esac;
        if [[ "${_selection}" = "Back" ]]; then main_menu; fi
        heading "Delete Backup:You Would Like To Delete The Backup Made On ${_selection}? [y,n] (This Will Delete This Backup Forever! This Is Not Reversible!)";
        display_yesorno;
        cursor_hide;
        read -s -e -n 1 _key 2>/dev/null >&2;
        _key=$(echo "${_key}" | tr '[:upper:]' '[:lower:]');
        if [[ "${_key}" = "y" ]]; then
            data_delete "backup" "${_selection}";
            main_menu "ColorSnapper Backup From ${_selection} Has Been Deleted!";
        elif [[ "${_key}" = "n" ]]; then
            main_menu;
        else
            manage_backups;
        fi
    else
        main_menu "Data Management Is Only Available For The Application Version Of Palette";
    fi
}

#*: @function manage_palettes {
#*: Description: 
#*: Arguments:
#*: Purpose:
#*: }
function manage_palettes {
    if [[ "${APPLICATION}" = "true" && "${SETTINGS[0]}" = "APPLICATION" ]]; then
        local _local;
        local _cloud;
        local _list;
        local _selected;
        _list=$(data_list "palette");
        _list=(${_list});
        if (( ${#_list[@]} < 2 )); then main_menu "You Don't Have Any Color Palettes Saved In The Application"; fi
        heading "Manage:Select A Color Palette To Delete";
        case `select_opt "${_list[@]}"` in
            *) _selection=${_list[$?]};;
        esac;
        if [[ "${_selection}" = "Back" ]]; then main_menu; fi
        heading "Delete Palette:You Would Like To Delete The Palette ${_selection}? [y,n] (This Will Delete This Backup Forever! This Is Not Reversible!)";
        display_yesorno;
        cursor_hide;
        read -s -e -n 1 _key 2>/dev/null >&2;
        _key=$(echo "${_key}" | tr '[:upper:]' '[:lower:]');
        if [[ "${_key}" = "y" ]]; then
            data_delete "palette" "${_selection}";
            main_menu "The Palette ${_selection} Has Been Deleted";
        elif [[ "${_key}" = "n" ]]; then
            main_menu;
        else
            data_load;
        fi
    else
        main_menu "Data Management Is Only Available For The Application Version Of Palette";
    fi
}

#*: @function manage_backups {
#*: Description: 
#*: Arguments:
#*: Purpose:
#*: }
function data_delete() {
    if [[ "${APPLICATION}" = "true" && "${SETTINGS[0]}" = "APPLICATION" ]]; then
        cd "${LOCATION}/.palette";
        local _option=${1};
        if [[ "${_option}" = "backup" ]]; then
            local _option="Backup";
        elif [[ "${_option}" = "palette" ]]; then
            local _option="Palettes";
        fi
        local _id=${2};
        cd "${_option}";
        if [[ "${_option}" = "Backup" ]]; then
            if [[ -d ${_id} ]]; then
                mv "${_id}" "/Users/$USER/.Trash";
            fi
        elif [[ "${_option}" = "Palettes" ]]; then
            if [[ -e "${_id}.palette" ]]; then mv "${_id}.palette" "/Users/$USER/.Trash"; fi
        fi
    else
        main_menu "Data Management Is Only Available For The Application Version Of Palette";
    fi
}
#       ##: @End Data Management }

#*: @function data_check {
#*: Description: Checks If There Are Any Colors In ColorSnapper To Prevent An Empty Data Set From Being Saved
#*: Arguments: _type (String) "Backups" || "Palettes"; The Type Of Data That Will Be Worked With, Backups Or Palettes, & The Function Will Check For The Appropriate Data
#*: Purpose: Checks If Any Colors Are Saved In ColorSnapper Before Saving A Backup & Provides A Warning To The User Instead Of Saving An Empty Data Set. Also Checks If Any Colors Are Favorited In ColorSnapper Before Saving A Palette & Warns The User If No Colors Are Set As A Favorite
#*: }
function data_check() {
    preload_clear;
    # _data Will Hold The Data Currently Stored In ColorSnapper At The Time The Function Is Called
    local _data;
    # Check The Value Of The Argument Passed To The Function
    if [[ "${1}" = "Backups" ]]; then
        # If "Backups" Was Passed Then Store The History Data From ColorSnapper In The _data Variable
        _data=$(defaults read com.koolesache.ColorSnapper2 HistoryColors);
        # Check The Value Of The Argument Passed To The Function
    elif [[ "${1}" = "Palettes" ]]; then
        # If "Palettes" Was Passed Then Store The Favorites Data From ColorSnapper In The _data Variable
        _data=$(defaults read com.koolesache.ColorSnapper2 FavoriteColors);
    fi
        # Remove The Open Parenthesis From The Data
        _data="${_data//(}";
        # Remove The Close Parenthesis From The Data
        _data="${_data//)}";
        # Remove The Tabs Parenthesis From The Data
        _data="${_data//$'\t'}";
        # Remove The Spaces Parenthesis From The Data
        _data="${_data// }";
    # Check If The Value Stored In The _data Variable With Newlines Removes Exists & Is Not An Empty String
    if [[ -z "${_data//$'\n'}" ]]; then
        # If The _data Variable Does Not Exist Or Is Equal To An Empty String Return / Print "false" Indicating The Data Requested Can Be Accessed
        echo "false";
    else
        # If The _data Variable Exists & Contains Characters Then Return / Print "true" Indicating The Data Requested Can Be Accessed
        echo "true";
    fi
}

#*: @function preload_clear {
#*: Description: Clears Any Preloaded Data
#*: }
function preload_clear {
    unset PRELOAD
    PRELOAD=();
    PRELOAD[0]=0;
    PRELOAD[1]=0;
    PRELOAD[2]=0;
    PRELOAD[3]=0;
    PRELOAD[4]=0;
    PRELOAD[5]=0;
    PRELOAD[6]=0;
    PRELOAD[7]=0;
    PRELOAD[8]=0;
}

#*: @function data_preload {
#*: Description: Preloads Data From A Palette Saved File To Be Formatted For Display, For ColorSnapper, Or To Be Saved To File
#*: Arguments:
#*: PRELOAD[0] - OPTION - BACKUP || PALETTE
#*: PRELOAD[1] - FILENAME
#*: PRELOAD[2] - LOCAL || CLOUD
#*: PRELOAD[3] - HEADER HISTORY COLOR COUNT
#*: PRELOAD[4] - HISTORY COLOR LIST
#*: PRELOAD[5] - HEADER FAVORITE COLOR COUNT
#*: PRELOAD[6] - FAVORITE COLOR LIST
#*: PRELOAD[7] - NOTE CHARACTER COUNT
#*: PRELOAD[8] - NOTE
#*: }
function data_preload() {
    preload_clear;
    local _id=${1};
    local _option=${2}
    local _file;
    if [[ "${SETTINGS[2]}" != "NO" ]]; then
        directory_cloud "${_option}";
        if [[ -e "${_id}.palette" ]]; then
            _file=$(<"${_id}.palette");
            PRELOAD[0]="${_option}";
            PRELOAD[1]="${_id}";
            PRELOAD[2]="Cloud";
        fi
    fi
    if [[ -z "${_file// }" ]]; then
        if [[ "${SETTINGS[0]}" != "NO" ]]; then
            directory_local "${_option}";
            if [[ -e "${_id}.palette" ]]; then 
                _file=$(<"${_id}.palette");
                PRELOAD[0]="${_option}";
                PRELOAD[1]="${_id}";
                PRELOAD[2]="Local";
            fi
        fi
    fi
    if [[ ! -z "${_file// }" ]]; then
        local _type=$(echo -e "${_file}" | head -n 1);
                  _type=$(echo "${_type//=}" | cut -d':' -f 2);
        if [[ "${_type}" = "B" ]]; then
            IFS=$'\n';
            _file=(${_file});
            IFS=${IFSC};
            local _h=$(echo "${_file[1]//=}" | cut -d':' -f 2);
            if (( _h > 0 )); then
                PRELOAD[3]="${_h}";
                PRELOAD[4]="${_file[2]}";
            fi
            local _f=$(echo "${_file[3]//=}" | cut -d':' -f 2);
            if (( _f > 0 )); then
                PRELOAD[5]="${_f}";
                PRELOAD[6]="${_file[4]}";
            fi
            local _n=$(echo "${_file[5]//=}" | cut -d':' -f 2);
            if (( _n > 0 )); then
                PRELOAD[7]="${_n}";
                PRELOAD[8]="${_file[6]}";
            fi
        elif [[ "${_type}" = "P" ]]; then
            local _h=$(echo -e "${_file//=}" | head -n 2 | tail -n -1 | cut -d':' -f 2);
            if (( _h > 0 )); then
                PRELOAD[3]="${_h}";
                PRELOAD[4]=$(echo -e "${_file}" | tail -n +3);
            fi
        fi
    fi
}

#*: @function data_format {
#*: Description: Formats The Color Data Preparing It To Either Be Loaded Into ColorSnapper Or Saved To A File
#*: Arguments: _data (String) "Color Data"; _direction (String) "Application" || "File"; _data Is The Color Data That Needs To Be Formatted; _direction Can Be "Application" || "File" & Tells The data_format Function How To Format The Color Data, Format It To Load Into ColorSnapper Or Format It To Save It To A Palette File
#*: Purpose: Used To Format Color Data For Saving To A Palette File & For Loading Into ColorSnapper
#*: }
function data_format() {
    # The First Argument Passed Should Be The Color Data
    local _data=${1};
    # The Second Argument Passed Should Be What The Color Data Is Being Formatted For, "Application" Or "File"
    local _direction=${2};
    # Remove Any Open Parenthesis From The Data If Any Exists
    _data="${_data//(}";
    # Remove Any Close Parenthesis From The Data If Any Exists
    _data="${_data//)}";
    # Remove Any Tabs From The Data If Any Exists
    _data="${_data//$'\t'}";
    # Remove Any Spaces From The Data If Any Exists
    _data="${_data// }";
    # Check If The Data Should Be Formatted To Be Loaded Into ColorSnapper
    if [[ "${_direction}" = "Application" ]]; then
        # Check If There Is Any Data
        if [[ "${#_data}" -gt 2 ]]; then
            # Handle If There Is Only A Single Color Saved
            if [[ "${#_data}" -lt 9 ]]; then
                _data=$(echo -e "\t${_data}");
            else
                cd ~/Downloads/debug;
                IFS=${IFSC};
                # Replace Any Commas With Newlines In The Data
                # _data="${_data//,/\n}";
                _data="${_data//,/ }";
                # Each Color Should Now Be On It's Own New Line, So Putting The Color Data Into the _colors Array Will Result In The _colors Array Being Populated With Each Color As An Array Element
                local _colors=(${_data});
                echo "${_colors[1]}" > "debug.txt";
                # Set The _data String To The First Array Element (Color) In The _colors Array
                _data=$(echo -e "\t${_colors[0]}");
                # Loop Through The _color Array Starting From The 2nd Element Since The First Element Was Already Added To The Data String
                for _color in "${_colors[@]:1}"; do
                    # Add The _data String To Itself Adding A Comma After The Last Color Added, A New Line & A Tab, Then The Next Color In The Array
                    _data=$(echo -e "${_data},\n\t${_color}");
                done
            fi
        else
            # There Is No Data
            _data="";
        fi
        # Return / Print The Colors Formatted To Be Written In The ColorSnapper Application
        echo -e "(\n${_data}\n)";
    # If The Data Should Be Formatted To Put Into A File
    elif [[ "${_direction}" = "File" ]]; then
        _data="${_data//,}";
        if [[ "${#_data}" -lt 2 ]]; then
            # There Is No Data So Return Data Declaring That
            echo -e "======C:0======\n0";
        else
            # Check If There Is Only A Single Color 
            if [[ "${#_data}" -lt 9 ]]; then
                echo -e "======C:1======\n${_data}";
            else
                # Take The Data With The Appropriate Characters Stripped From The String & Put It Into An Array Resulting In Each Array Element Consisting Of A Value Representing A Color
                local _colors=(${_data});
                # Grab The Total Number Of Colors & Store It In _count
                local _count="${#_colors[@]}";
                # Set The _data String To The First Array Element (Color) In The _colors Array
                _data=$(echo -e "${_colors[0]}");
                # Loop Through The _color Array Starting From The 2nd Element Since The First Element Was Already Added To The Data String
                for _color in "${_colors[@]:1}"; do
                    # Add The _data String To Itself Adding A Comma After The Last Color Added & Then The Next Color In The Array
                    _data=$(echo -e "${_data},${_color}");
                done
                # Return / Print The Colors Formatted To Be Written In A Palette File
                echo -e "======C:${_count}======\n${_data}";
            fi
        fi
    fi
}

#*: @function data_save {
#*: Description: Handles Saving Data To File & Applying A Custom Icon To The Saved File
#*: Arguments: _option(STR) - Backup || Palettes - The Type Of Backup File Being Created. _filename(STR) - The Filename Of The File Being Saved
#*: }
function data_save() {
    local _option=${1};
    local _filename=${2};
    if [[ ! -z "${3// }" ]]; then local _note=${3}; fi
    local _history;
    local _file;
    local _favorites=$(defaults read com.koolesache.ColorSnapper2 FavoriteColors);
              _favorites=$(data_format "${_favorites}" "File");
    if [[ "${_option}" = "Palettes" ]]; then
        _file="${_favorites//,/$'\n'}"
        _file="======T:P======\n${_file}";
    elif [[ "${_option}" = "Backups" ]]; then
        _history=$(defaults read com.koolesache.ColorSnapper2 HistoryColors);
        _history=$(data_format "${_history}" "File");
        _file="======T:B======\n${_history}"
        # if [[ ! -z "${_favorites// }" ]]; then 
        _file="${_file}\n${_favorites}";
        # else
            # _file="${_file}\n======C:0======\n0";
        # fi
        if [[ ! -z "${_note// }" ]]; then 
            _file="${_file}\n======N:${#_note}======\n${_note}";
        else
            _file="${_file}\n======N:0======\n0";
        fi
    fi
    echo -e "${_file}" > "${_filename}.palette";
    sleep 0.5s;
    icon_apply "${_option}" "${_filename}";
    loading 2;
}

#*: @function data_list {
#*: Description: Returns The List Of Saved Palette Files Used To Display To The User In Various Menus
#*: Arguments: _option (String) -- Backups || Palettes -- The Type Of Data That Should Be Listed, Backups, Or Palettes
#*: Purpose: Used To Grab Saved Palette Files From The User's Local & Cloud Save Location & Seemlessly Combine The Available Files
#*: }
function data_list() {
    # The Option ( "Backups" || "Palettes" ) Is Stored In The _option Variable
    local _option=${1};
    # The Variable That Will Hold The List Of Files Stored Locally If Local Storage Is Enabled In The Settings
    local _local="";
    # The Variable That Will Hold The List Of Cloud Saves If Cloud Storage Is Enabled In The Settings
    local _cloud="";
    # The Variable That Will Hold All Of The Files If Both Local & Cloud Saves Are Enabled
    local _list;
    # Check The Settings If Local Backup Is Enabled
    if [[ "${SETTINGS[0]}" != "NO" ]]; then
        # Change The Directory To The Appropriate Directory For Where Palette Files Are Saved Locally Passing The Option To The directory_local Function Which Will Move Into Either The Palettes Or Backups Folder
        directory_local "${_option}";
        # List The Files In The Directory Grepping The List To Return Only The Files With A Palette Extension
        _local=$(ls | egrep '\.palette$');
    fi
    # Check The Settings If Cloud Backup Is Enabled
    if [[ "${SETTINGS[2]}" != "NO" ]]; then
        # Change The Directory To The Appropriate Directory For Where Palette Files Are Saved In The Cloud Passing The Option To The directory_local Function Which Will Move Into Either The Palettes Or Backups Folder
        directory_cloud "${_option}";
        # List The Files In The Directory Grepping The List To Return Only The Files With A Palette Extension
        _cloud=$(ls | egrep '\.palette$');
    fi
    # Combine The List Of Files From Local & Cloud Save Directories
    _list="${_local} ${_cloud}";
    # Remove The .palette Extension From All Of The Listed Files
    _list=$(echo "${_list//.palette}");
    # Remove Any Backslashed From The Listed Files
    _list=${_list//\/};
    # Sort The List Of Files Alphabetically & Remove Any Duplicate Listings
    _list=$(echo "${_list}"|tr " " "\n"|sort|uniq);
    # Return / Print The List
    echo -e "${_list}";
}

#*: @function data_note {
#*: Description: Passes The Note Saved To A Backup Palette If One Exists To Be Dislpayed Before Restoring The Palette.
#*: Purpose: When Restoring Color Data From A Backup Palette The User Is Able To Attach A Note To Help Identify The Significance Of The Backup, But Is Not Required. If A Note Was Saved With A Backup, Before Restoring The Color Data The Note Is Displayed On Screen To The User & The User Is Asked To Verify This Is The File They Would Like To Load.
#*: }
function data_note {
    # Check If The Note Character Count Is Preloaded In The PRELOAD Variable
    if [[ ! -z "${PRELOAD[7]// }" ]]; then
        # Check If The Note Character Count Is Larger Than 0
        if [[ "${PRELOAD[7]}" -gt 0 ]]; then
            # Return / Print A Sanitized Version Of The Note From The Preloaded Palette File
            echo -e "${PRELOAD[8]//[^a-zA-Z0-9_ -]/}";
        else
            # If The Character Count Is 0 Then Return / Print 0
            echo "0";
        fi
    else
        # If No Character Count Is Preloaded Then Return 0
        echo "0";
    fi
}

#*: @function data_message {
#*: Description: Builds A Message Based On Parameters To Give User Feedback About An Event That Occured
#*: Arguments: _option (String) Backups || Palette; _filename (String);
#*: }
function data_message() {
    local _location="";
    local _message="";
    if [[ "${1}" = "Backups" ]]; then
        _message="ColorSnapper Data From ${2} Successfully Saved";
    elif [[ "${1}" = "Palettes" ]]; then
        _message="Color Palette ${2} Saved";
    fi
    if [[ "${SETTINGS[0]}" != "NO" ]]; then _location="Locally";fi
    if [[ ${SETTINGS[2]} != "NO" ]]; then
        if [[ ${SETTINGS[2]} = "ICLOUD" ]]; then
            _location="To iCloud";
        elif [[ ${SETTINGS[2]} = "CLOUD" ]]; then
            _location="To Your Cloud Service";
        fi
        if [[ "${SETTINGS[0]}" != "NO" ]]; then _location="Locally & ${_location}"; fi
    fi
    _message="${_message} ${_location}";
    echo "${_message}";
}
#   ##: @End Data }

#   ##:  @Functions Main {
#*: @function main_menu {
#*: Description: Displays The Selections Available To Work With ColorSnapper2 Data & Palette Files
#*: Arguments: _message (String) (Optional) --
#*: Purpose: Displays The Selections Available To Work With ColorSnapper2 Data & Palette Files
#*: }
function main_menu() {
    local _message="Main Menu:";
    if (( "$#" > 0 )); then 
        local _header=$(echo "${1}" | cut -d':' -f 1);
        if [[ "${_header}" != "Error" ]]; then
            _message="${_message}${1}";
        else
            _message="${1}"
        fi
    fi
    heading "${_message}" "Palette";
    display_keys;
    case `select_opt "  Backup ColorSnapper Data    " "  Restore ColorSnapper Data   " "  Clear ColorSnapper          " "  Save Color Palette          " "  Load Color Palette          " "  Preview Palette Data        " "  Manage Palette Data         " "  Options                     " "  Help                        " "  Exit                        "` in
        0) data_backup;;
        1) data_restore;;
        2) data_clear;;
        3) data_create;;
        4) data_load;;
        5) preview_menu;;
        6) data_menu;;
        7) options_menu;;
        8) help_menu;;
        9) main_quit;;
    esac;
}

#*: @function data_menu {
#*: Description: Displays a menu of options to work with ColorSnapper2's data. The menu can be navigated by using the arrow keys on the keyboard & the enter key to select the highlighted option. The Palette Logo is displayed at the top, the banner is displayed next with a message centered inside the banner. If a value is passed to the main_menu function the banner is constructed & displayed with this message inside, otherwise the message stored in the global MESSAGE is used. The main menu is displayed under the banner
#*: Purpose: Breaks Up The Menu Organizing Data Management Options In A Different Menu System
#*: }
function data_menu() {
    local _message="Manage Data:";
    if (( "$#" > 0 )); then 
        local _header=$(echo "${1}" | cut -d':' -f 1);
        if [[ "${_header}" != "Error" ]]; then
            _message="${_message}${1}";
        else
            _message="${1}"
        fi
    fi
    heading "${_message}" "Palette: Manage Data";
    case `select_opt "  Sync ColorSnapper           " "  Combine Files               " "  Import A Palette            " "  Export A Palette            " "  Delete Files                " "  Help                        " "  Back                        "` in
        0) data_sync;;
        1) data_combine;;
        2) data_import;;
        3) data_export;;
        4) data_delete;;
        5) help_menu;;
        6) main_menu;;
    esac;
}

#*: @function options_menu {
#*: Description: Constructs The Options Menu Which Allows The User To Change Their Palette Data Storage Location
#*: }
function options_menu {
    heading "Options:" "Palette: Options";
    case `select_opt "  Change Data Storage Locations            " "  Back                                     "` in
        0) settings_fix "true";;
        1) main_menu;;
    esac;
}

#*: @function tmp_cleanup {
#*: Description: Cleanup Any Temporary Files Created While The Script|Application Was Running. Typically This Will Only Consist Of An SVG Preview File If The User Did Preview Any Saved Data
#*: Purpose: Cleans Up Any Temporary Files Generated While The Application Was Running
#*: }
function tmp_cleanup {
    # Move To The Directory Stored In LOCATION
    cd "${LOCATION}";
    # If The Data Directory Doesn't Exist Create The Directory With The Appropriate Subdirectories
    if [[ ! -d "Data" ]]; then mkdir -p "Data/{Backup,Palettes}"; fi
    # Move Into The Data Directory
    cd "Data";
    # Check If The .tmp Directory Exists, If It Does Not Create It
    if [[ ! -d ".tmp" ]]; then mkdir ".tmp"; fi
    # Move Into The .tmp Directory
    cd ".tmp";
    # Check if The SVG File The Preview Function Generates Exists; If It Does, Move It To The Trash
    if [[ -e "Preview.svg" ]]; then mv "Preview.svg" "/Users/$USER/.Trash" 2> /dev/null; fi
}

#*: @function main_quit {
#*: Description: Called when the Exit option is selected from the main menu or when the terminal is closed. The function clears the terminal, sizes the terminal back to it's original size before the application was opened, cleans up any temporary files created by calling tmp_cleanup, quits the Palette application if it is running, and quits the Terminal application.
#*: Purpose: Sets The Terminal Window Back To It's Original Size When The Application Was Launched, Removes The Title From The Terminal, Cleans Up Any Temporary Files Or Preview Files That Have Been Generated, Kills The Palette Application & Closes The Terminal If Nothing Else Is Running In The Terminal
#*: }
function main_quit {
    window_resize ${ORIGINAL[0]} ${ORIGINAL[1]};
    window_name;
    window_clear;
    tmp_cleanup;
    # kill $(pgrep "Palette") 2> /dev/null;
    clear >$(tty);
    cd "${LOCATION}/Resources/.palette/Apps"
    open -a "Close.app";
}

#*: @function colorsnapper_launch {
#*: Description: Calls To Open The ColorSnappe2 Function Silencing Any Errors If The Application Does Not Exist
#*: Purpose: ColorSnapper Can't Be Running When Data Is Written To It; colorsnapper_launch Opens ColorSnapper2 After Data Has Been Written To It
#*: }
function colorsnapper_launch { open -a ColorSnapper2 2>/dev/null >&2; }

#*: @function colorsnapper_kill {
#*: Description: Kills ColorSnapper2 If It Is Running Silencing Any Errors That May Occur
#*: Purpose: ColorSnapper2 Must Be Closed Before Writing Data To It
#*: }
function colorsnapper_kill {
    # Check To Be Sure ColorSnapper2 Is Actually Running Otherwise The Script Will Terminate
    local _check=$(ps aux | grep -v grep | grep -ci ColorSnapper2);
    if [ $_check -gt 0 ]; then
        kill $(pgrep "ColorSnapper2") 2> /dev/null;
    fi
}

#*: @function colorsnapper_exist {
#*: Description: Checks If The ColorSnapper Application Is Installed Using The application_installed Function Call
#*: Purpose: Used To Check If The User Has ColorSnapper2 Installed When Starting The Application Showing A Warning If The Application Can Not Be Found
#*: }
function colorsnapper_exist { if ! application_installed 'ColorSnapper2' &>/dev/null; then COLORSNAPPER="false"; fi }

#*: @function colorsnapper_clear {
#*: Description: Clears The Data Stored In ColorSnapper
#*: }
function colorsnapper_clear {
    defaults write com.koolesache.ColorSnapper2 HistoryColors "()" && defaults write com.koolesache.ColorSnapper2 FavoriteColors "()";
}

#*: @function data_write {
#*: Description: Checks If The Correct Color Data Is Preloaded & Sends The Data To Be Written To ColorSnapper Using The colorsnapper_write Function; Also Used To Clear ColorSnapper's Data
#*: Arguments: _id (String) (Optional) "Filename"; _option (String) (Optional) "Backups" || "Palette"; -- Passing Values To The Function Call Is Optional. If No Values Are Passed ColorSnappers Data Will Be Cleared. If Values Are Passed ColorSnapper Will Be Loaded With The Data Stored In The Corresponding Saved Palette File 
#*: Purpose: Used To Setup A Palette To Load Data Into ColorSnapper Or Clear ColorSnapper's Data
#*: }
function data_write() {
    # Check If Any Values Were Passed To The Function Call; The Arguments Are Optional
    if (( "$#" > 0 )); then 
        # Save The First Value Passed To The Function Call As The _id Which Is The Filename Containing The Palette Data Being Used
        local _id=${1};
        # Save The Second Value Passed To The Function Call As The _option Which Will Be Either "Backups" || "Palettes"; This Specifies If A Backup Or A Palette Is Being Loaded
        local _option=${2};
        # If The Palette Preloaded Into The PRELOAD Array Doesn't Match The Selected Filename Stored In _id Then The data_preload Function Is Called First To Load In The Information
        if [[ "${PRELOAD[0]// }" != "${_id// }" ]]; then data_preload "${_id// }" "${_option}"; fi
    else
        # If No Data Was Passed To The Write Function Be Sure To Unset The PRELOAD Variable So No Data Is Accidentally Loaded Into ColorSnapper
        preload_clear;
    fi
    # Check To Be Sure There Is Data Loaded Into The PRELOAD Variable, If There Is Color Data Will Be Sent To The Write Function Call, If There Is Not Nothing WIll Be Sent To The Function & ColorSnappers Data Will Be Cleared
    if [[ ! -z "${PRELOAD// }" ]]; then
    # Check If The Amount Of History Colors Data Is Preloaded & Is Greated Than 0
        if [[ ! -z "${PRELOAD[3]// }" && "${PRELOAD[3]}" -gt 0 ]]; then
            # Check If The Amount Of Favorites Colors Data Is Preloaded & Is Greater Than 0; If So Pass Both The History Color Data & Favorites Color Data To The colorsnapper_write Function
            if [[ ! -z "${PRELOAD[5]// }" && "${PRELOAD[5]}" -gt 0 ]]; then
                # If Both History & Color Data Exists Then Pass The Data To The colorsnapper_write Function
                colorsnapper_write "${PRELOAD[4]}" "${PRELOAD[6]}";
            else
                # If Only The History Color Data Exists Then Only Pass The History Color Data To The colorsnapper_write Function
                colorsnapper_write "${PRELOAD[4]}";
            fi
        else
            # If Data Is Preloaded But It Contains No History Data There Is An Error With The File & It Contains No Information Or The Wrong Information & Error Back To The Main Menu
            main_menu "Error: There Is An Issue Attempting To Load The Requested File. Please Report The Issue.";
        fi
    else
        # If No Data Is Preloaded & No File Was Requested To Be Preloaded, No Data Was Passed To The Function Call & colorsnapper_write Is Called Without Passing Data To The Function Call Which Will Clear ColorSnapper's Data
        colorsnapper_write;
    fi
}

#*: @function colorsnapper_write {
#*: Description: Handles Writing Data To ColorSnapper & Relaunching The Application
#*: Arguments: _history(STR) - The History File Data. _favorites(STR) - The Favorites File Data
#*: }
function colorsnapper_write() {
    local _history="()";
    local _favorites="()";
    colorsnapper_kill;
    if (( "$#" > 0 )); then 
        case "$#" in
            "2") _history=${1};
                    _favorites=${2};
                    _favorites=$(data_format "${_favorites}" "Application");
            ;;
            "1") _history=${1};
            ;;
        esac
        _history=$(data_format "${_history}" "Application");
    fi
    defaults write com.koolesache.ColorSnapper2 HistoryColors "${_history}";
    defaults write com.koolesache.ColorSnapper2 FavoriteColors "${_favorites}";
    loading 2;
    colorsnapper_launch;
}

#*: @function application_installed {
#*: Description: Checks If An Application Is Installed
#*: Arguments: _application(STR) - Name Of The Application To Check If It's Installed
#*: }
function application_installed() {
    local _application=${1}
    local _id;
    _id=$(osascript -e "id of application \"$_application\"" 2>/dev/null) ||
    { echo "false" 1>&2; return 1; }
    _path=$(osascript -e "tell application \"Finder\" to POSIX path of (get application file id \"$_id\" as alias)" 2>/dev/null ||
    { echo "false" 1>&2; return 1; })
    echo "${_path}"
}

#*: @function file_open {
#*: Description: Handles Opening A File With A .palette Extension
#*: Arguments: _file (optional) -- If A Palette File Is Double Clicked OR Dragged Into Palette
#*: }
function file_open() {
    if (( "$#" > 0 )); then 
        if [[ -e "${1}" ]]; then
            preview_file "${1}";
            # file_load "${1}";
        fi
    else
        main_menu
    fi
}

#*: @function main {
#*: Description: Main application loop. The initial function that is called that directs the application. The main function catches any errors, when the terminal window is resized, & when the application is exited.
#*: Arguments: _file (optional) -- If A Palette File Is Double Clicked OR Dragged Into Palette
#*: }
function main() {
    # trap main_quit ABRT;
    # trap main_quit EXIT;
    # trap main_quit INT;
    # trap main_quit SIGINT;
    # trap main_quit SIGQUIT;
    # trap main_quit TERM;
    # trap properties_update SIGWINCH;
    colorsnapper_exist;
    define_colors;
    window_resize ${DIMENSIONS[0]} ${DIMENSIONS[1]};
    window_clear;
    properties_update;
    sleep 1s;
    settings_load;
    if (( "$#" > 0 )); then
        file_open ${1};
    else
        main_menu;
    fi
}
#   ##: @End Main }
##: @End Functions }

if (( "$#" > 0 )); then 
    main ${1};
else
    main;
fi