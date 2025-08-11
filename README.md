<div id="top"></div>

<br>

<center><div width="400px" align="center"><img align="center" width="400px" src="https://raw.githubusercontent.com/mcbeav/readme.photos/refs/heads/main/palette/logo.png"></div></center>

<br>

<h1 align="center">Palette</h1>

<br>

<center>

<div width="506px" align="center">

<img align="center" src="https://raw.githubusercontent.com/mcbeav/readme.photos/refs/heads/main/palette/main-menu.gif">

</div>

</center>

<br>

<p>Palette is an application that enables backing up and restoring your color data for the ColorSnapper application for Mac OS. The application is written entirely in bash and has a few extra features.<p>

<br><br><br>

<h2>Preface</h2>

<p><small>I use the macOS application ColorSnapper2 excessively when I am developing. The application is great, but I wish it had some features to manage the data stored in ColorSnapper2, so I wrote this script and turned it into sort of a pseudo-application. I don't think it likely serves much of a purpose in the present day, and it may not even properly work with new version of macOS. I wrote this around 2020 on macOS 11, and I am publishing the work for anyone that might find this useful. I am very tempted to rewrite this application, but it serves no real purpose any longer.</small></p>

<br><br>

<h2>Features</h2>

<br>

<h3 align="right">Backup & Restore ColorSnapper Data</h3>

<p>Backup the colors & favorites saved in ColorSnapper2.</p>

<p>Data can be backed up locally & to cloud services.</p>

<p>Useful for backing up ColorSnapper2 data from multiple computers</p>

<br><br>

<h3 align="right">Save & Load Color Palettes</h3>

<br><br>

<h2>Launching Palette</h2>

<br>

<h3 align="right">First Launch</h3>

<br>

<p>Upon first launch, you'll be shown a short introduction on the purpose of the Palette application.</p>

<center>

<div width="506px" align="center">

| ![Introduction](https://raw.githubusercontent.com/mcbeav/readme.photos/refs/heads/main/palette/introduction.gif) | 
|:--:| 
| <i>Palette Introduction</i> |

</div>

</center>

<br><br>

<h3 align="right">Setup</h3>

<br>

<p>After the introduction, you'll be taken to the initial setup menu. This is where you'll tell Palette where to store your <i>.palette</i> files. You can choose to store the files locally, using a cloud service such as iCloud, or both locally and using a cloud service.</p>

<br>

<p>The application will ask if you want Palette to handle where the files will be stored or if you want to choose the location where your palette data is stored.</p>

<br>

<center>

<div width="506px" align="center">

| ![Setup](https://raw.githubusercontent.com/mcbeav/readme.photos/refs/heads/main/palette/setup.gif) | 
|:--:| 
| <i>Palette Setup</i> |

</div>

</center>

<br><br>

<h2>Main Menu</h2>

<br>

<h3 align="right">Backup ColorSnapper Data</h3>

<br>

<p>Creates a dated backup of all the colors & favorites marked in ColorSnapper2. This also allows you to add a note to the backup if you would like to remember specific information about the backup you are creating.</p>

<br>

<center>

<div width="506px" align="center">

| ![Backup](https://raw.githubusercontent.com/mcbeav/readme.photos/refs/heads/main/palette/backup.gif) | 
|:--:| 
| <i>Backup ColorSnapper Data</i> |

</div>

</center>

<br><br>

<center>

<div width="506px" align="center">

| <img src="https://raw.githubusercontent.com/mcbeav/readme.photos/refs/heads/main/palette/icons.png" width="506px" alt="Palette Files"> | 
|:--:| 
| <i>Saved Palette Files</i> |

</div>

</center>

<br><br>

<hr>

<br><br>

<h3 align="right">Restore ColorSnapper Data</h3>

<br>

<p>Displays a dated list of backups that have been created using the Backup ColorSnapper Data option and allows you to restore data from a chosen specific date.</p>

<br>

<p>Once a date is selected, any notes stored in the file will be displayed, and you will confirm if this is the backup you would like to restore. When the action is confirmed the data in ColorSnapper is cleared and then the data from the backup is written to ColorSnapper.</p>

<center>

<div width="506px" align="center">

| ![Restore List](https://raw.githubusercontent.com/mcbeav/readme.photos/refs/heads/main/palette/restore.gif) | 
|:--:| 
| <i>Displays A List Of Available Backups</i> |

</div>

</center>

<br><br>

<hr>

<br><br>

<h3 align="right">Clear ColorSnapper</h3>

<br>

<p>Wipes all the stored colors from Colorsnapper to start with a clean palette.</p>

<br>

<center>

<div width="506px" align="center">

| ![Clear](https://raw.githubusercontent.com/mcbeav/readme.photos/refs/heads/main/palette/clear.gif) | 
|:--:| 
| <i>Clear ColorSnapper Data</i> |

</div>

</center>

<br><br>

<p><b><i>ColorSnapper will have no colors saved after you use the Clear ColorSnapper option</i><b></p>

<br>

<hr>

<br><br>

<h3 align="right">Save Color Palette</h3>

<br>

<p>Saves the colors marked as <i>favorites</i> as a palette file that can be loaded and restored at any time. The application will prompt you to name your color palette file.</p>

<br>

<center>

<div width="506px" align="center">

| ![Save Color Palette](https://raw.githubusercontent.com/mcbeav/readme.photos/refs/heads/main/palette/save-palette.gif) | 
|:--:| 
| <i>Save Color Palette</i> |

</div>

</center>

<br><br>

<p>You might find this useful for loading colors for a specific project you are working on or when switching projects.</p>

<br>

<hr>

<br><br>

<h3 align="right">Load Color Palette</h3>

<br>

<p>Loads the color data from a specified palette file that was created using the Create Color Palette option. </p>

<p>The option will display a list of your saved palette files to choose from.</p>

<p>The color data currently in ColorSnapper will be wiped and the color data from the palette file will be loaded. The colors will replace the loaded data.<p>

<br>

<center>

<div width="506px" align="center">

| ![Load Color Palette](https://raw.githubusercontent.com/mcbeav/readme.photos/refs/heads/main/palette/load-palette.gif) | 
|:--:| 
| <i>Load Color Palette</i> |

</div>

</center>

<br><br>

<h4 align="center">Example</h4>

<br>

<p>This example shows 10 colors in ColorSnapper</p>

<br><br>

<center>

<div width="506px" align="center">

| <img src="https://raw.githubusercontent.com/mcbeav/readme.photos/refs/heads/main/palette/example-before.png" width="506px" alt="Example"> | 
|:--:| 
| <i>ColorSnapper Save Palette</i> |

</div>

</center>

<br><br>

<p>5 of those colors are marked as <i>favorites</i> indicated by the yellow star in the corner of the color</p>

<p>Saving a palette using the <i>Save Color Palette</i> option will create a palette file consisting of the 5 colors that are marked as <i>favorites</i></p>

<p>Loading the palette using the <i>Load Color Palette</i> the color data in ColorSnapper is replaced with the 5 colors marked as <i>favorites</i> in the previous photo</p>

<center>

<div width="506px" align="center">

| <img src="https://raw.githubusercontent.com/mcbeav/readme.photos/refs/heads/main/palette/example-after.png" width="506px" alt="Example"> | 
|:--:| 
| <i>ColorSnapper After The Palette File Has Been Loaded</i> |

</div>

</center>

<br><br>


<hr>

<br><br>

<h3 align="right">Preview Palette Data</h3>

<br>

<p>Displays a list of your saved palette files.</p>

<center>

<div width="506px" align="center">

| ![Preview](https://raw.githubusercontent.com/mcbeav/readme.photos/refs/heads/main/palette/preview.gif) | 
|:--:| 
| <i>Preview A Palette File</i> |

</div>

</center>

<br><br>

<p>Palette will generate an SVG file containing a preview of the selecting palette file, so you can view the colors that are saved in the selected palette before loading the data into ColorSnapper</p>

<p>The option will list your saved palette files to choose from</p>

<br>

<center>

<div width="506px" align="center">

| ![Preview](https://raw.githubusercontent.com/mcbeav/readme.photos/refs/heads/main/palette/svg.gif) | 
|:--:| 
| <i>SVG Generated Preview</i> |

</div>

</center>

<br><br>

<hr>

<br><br>

<h3 align="right">Manage Palette Data</h3>

<br>

<p>The Manage menu option gives access to manage your palette files.</p>

<br><br>

<center>

<div width="506px" align="center">

| ![Manage Palettes](https://raw.githubusercontent.com/mcbeav/readme.photos/refs/heads/main/palette/manage.gif) | 
|:--:| 
| <i>Manage Palette Data</i> |

</div>

</center>

<br><br>

<h4 align="center">Sync ColorSnapper</h4>

<p>Sync ColorSnapper combines the data that is currently in ColorSnapper2 with your most current backup created. This option only works if you setup to store your palette data using cloud storage, or a combination of both local and cloud storage.</p>

<p>This option is meant to sync ColorSnapper data across computers if you use ColorSnapper & develop across computers.</p>

<p>All duplicate colors will be removed.</p>

<br>

<h4 align="center">Combine Files</h4>

<p>Combine Files combines the colors loaded into ColorSnapper with the palette file you select removing any duplicate colors in the process.</p>

<p>When loading a palette file using the normal Load Palette, the color data will first be cleared from ColorSnapper. Using the Combine Files menu option will keep the color data in ColorSnapper & load the colors saved in a palette file.</p>

<br>

<h4 align="center">Import A Palette</h4>

<p>Imports a palette file into your palette storage.</p>

<br>

<h4 align="center">Export A Palette</h4>

<p>Exports a palette file from your default storage to a location of your choosing.</p>

<br>

<h4 align="center">Delete Files</h4>

<p>Allows management of your palette data.</p>

<br>

<h4 align="center">Help</h4>

<p>Displays a help menu explaining each menu option.</p>

<br><br>

<hr>

<br><br>

<h3 align="right">Options</h3>

<br>

<p>Allows the change of where your Palette data is being saved.</p>

<br><br>

<hr>

<br>

<h3 align="right">Help</h3>

<br>

<p>A help menu that displays the documentation for the application</p>

<br><br>

<hr>

<br><br>

<h3 align="right">Exit</h3>

<br>

<p>Exits the application & quits the Terminal</p>

<br><br>

<hr>

<br><br><br><br>


<center><sub><a href="#top">back to top</a></sub></center>


