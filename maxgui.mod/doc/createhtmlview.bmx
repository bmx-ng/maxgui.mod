' createhtmlview.bmx
SuperStrict

Import MaxGui.Drivers
?linux
Import MaxGui.gtk3webkit2gtk
?

Local window:TGadget
Local htmlview:TGadget

window=CreateWindow("My Window",30,20,600,440,,15|WINDOW_ACCEPTFILES)

htmlview=CreateHTMLView(0,0,ClientWidth(window),ClientHeight(window),window)
SetGadgetLayout htmlview,1,1,1,1 

HtmlViewGo htmlview,"blitzmax.org"

While WaitEvent()
	Print CurrentEvent.ToString()
	Select EventID()
		Case EVENT_WINDOWCLOSE
			End
	End Select
Wend
