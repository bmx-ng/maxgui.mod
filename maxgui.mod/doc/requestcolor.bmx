' requestcolor.bmx
SuperStrict

Import MaxGui.Drivers


Local window:TGadget
Local panel:TGadget
Local red:Int,green:Int,blue:Int

window=CreateWindow("RequestColor",40,40,320,240)
panel=CreatePanel(20,20,32,32,window,PANEL_ACTIVE|PANEL_SUNKEN)

While True
	WaitEvent 
	Select EventID()
		Case EVENT_WINDOWCLOSE
			End
		Case EVENT_MOUSEDOWN
			If RequestColor(red,green,blue)
				red=RequestedRed()
				green=RequestedGreen()
				blue=RequestedBlue()
				SetPanelColor panel,red,green,blue
			EndIf				
	End Select
Wend

