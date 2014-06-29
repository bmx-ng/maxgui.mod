Strict

Rem
bbdoc: MaxGUI/Proxy Gadgets
about: This module contains any official proxy gadgets that wrap around the standard MaxGUI gadgets and provide an additional library
of gadgets that can be used in a whole host of programs. Any gadgets in this library can be used with the standard MaxGUI functions
available in the core #MaxGUI.MaxGUI module.
End Rem
Module MaxGUI.ProxyGadgets

ModuleInfo "Version: 1.12"
ModuleInfo "License: BSD License"

ModuleInfo "History: 1.12 Release"
ModuleInfo "History: Added optional pHandleSize parameter."
ModuleInfo "History: Added ability to set split handle background color."
ModuleInfo "History: Fixed SPLIT_LIMITPANESIZE and SPLIT_CLICKTOTOGGLE bug."
ModuleInfo "History: 1.11 Release"
ModuleInfo "History: Hyperlink gadget now defaults to link colour returned by LookupGuiColor()."
ModuleInfo "History: 1.10 Release"
ModuleInfo "History: Decreased the TSplitter threshold for orientation flip."
ModuleInfo "History: 1.09 Release"
ModuleInfo "History: Added SCROLLPANEL_HNEVER and SCROLLPANEL_VNEVER constants."
ModuleInfo "History: 1.08 Release"
ModuleInfo "History: Added a new TScrollPanel gadget."
ModuleInfo "History: 1.07 Release"
ModuleInfo "History: Tweaked THyperlinkGadget.eventHandler() so that it works consistently on all platforms."
ModuleInfo "History: 1.06 Release"
ModuleInfo "History: Fixed some rogue dragging locks for splitters on Windows."
ModuleInfo "History: 1.05 Release"
ModuleInfo "History: Tidied up TSplitter.eventHook(), fixing several bugs in drag code."
ModuleInfo "History: 1.04 Release"
ModuleInfo "History: Added a new SetSplitterBehavior command."
ModuleInfo "History: 1.03 Release"
ModuleInfo "History: Fixed hyperlink tooltips."
ModuleInfo "History: A hyperlink's URL can now be modified/retrieved using SetGadgetExtra / GadgetExtra."
ModuleInfo "History: 1.02 Release"
ModuleInfo "History: Added a new TSplitter gadget. See CreateSplitter for more info."
ModuleInfo "History: 1.01 Release"
ModuleInfo "History: Filtered EVENT_MOUSEDOWN to avoid infinite loop on Windows."
ModuleInfo "History: Updated THyperlinkGadget to use LookupGuiFont()."
ModuleInfo "History: Inherited MaxGUI.Win32MaxGUI's label SS_NOTIFY fix."
ModuleInfo "History: 1.00 Release"
ModuleInfo "History: Added the first custom gadget: the hyperlink control."

Import "hyperlink.bmx"
Import "splitter.bmx"
Import "scrollpanel.bmx"
