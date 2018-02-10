
Strict

Rem
bbdoc: MaxGUI/Drivers
about:
Your MaxGUI applications should import this module if they want BlitzMax to selectively import the latest official #{MaxGUI drivers} for your application and platform:

[ @Platform | @{Default Driver}
* Windows 2000/XP/Vista | #MaxGUI.Win32MaxGUIEx
* Windows 9X | #MaxGUI.Win32MaxGUIEx (requires unicows.dll or MSLU to run)
* Linux | #Gtk.Gtk3MaxGUI
* Mac OS X | #MaxGUI.CocoaMaxGUI
]
End Rem
Module MaxGUI.Drivers

ModuleInfo "Version: 0.05"
ModuleInfo "Author: Simon Armstrong"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"

ModuleInfo "History: 0.05"
ModuleInfo "History: gtk.GTK3MaxGUI has now become the standard Linux MaxGUI driver."
ModuleInfo "History: 0.04 Release"
ModuleInfo "History: MaxGUI.Win32MaxGUIEx has now become the standard Windows MaxGUI driver."
ModuleInfo "History: 0.03 Release"
ModuleInfo "History: The most appropriate driver is automatically selected at run-time for the OS."
ModuleInfo "History: Both the old ANSI and new UNICODE Windows modules are now imported."
ModuleInfo "History: 0.02 Release"
ModuleInfo "History: Added compiler directives and removed MaxGUI.MaxGUI."
ModuleInfo "History: 0.01 Release"
ModuleInfo "History: Initial release required for BlitzMax 1.28 examples update."

?Win32
' disabled until it is working
Import MaxGUI.Win32MaxGUIEx
'Import "-lunicows"
?MacOs
Import Maxgui.CocoaMaxGui
?LinuxX86
'Import Maxgui.FLTKMaxGui
' default to the GTK3 version of MaxGUI
Import gtk.GTK3MaxGUI
?LinuxX64
Import gtk.GTK3MaxGUI
?raspberrypi
Import gtk.GTK3MaxGUI
?
