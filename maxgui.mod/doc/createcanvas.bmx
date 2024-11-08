' createcanvas.bmx
SuperStrict

Import MaxGui.Drivers


Global GAME_WIDTH:Int=320
Global GAME_HEIGHT:Int=240

' create a centered window with client size GAME_WIDTH,GAME_HEIGHT

Local wx:Int=(ClientWidth(Desktop())-GAME_WIDTH)/2
Local wy:Int=(ClientHeight(Desktop())-GAME_HEIGHT)/2

Local window:TGadget=CreateWindow("My Canvas",wx,wy,GAME_WIDTH,GAME_HEIGHT,Null,WINDOW_TITLEBAR)'|WINDOW_CLIENTCOORDS)

' create a canvas for our game
Local canvas:TGadget=CreateCanvas(0,0,320,240,window)

' create an update timer

CreateTimer 60

While WaitEvent()
	Select EventID()
		Case EVENT_TIMERTICK
			RedrawGadget canvas

		Case EVENT_GADGETPAINT
			SetGraphics CanvasGraphics(canvas)
			SetOrigin 160,120
			SetLineWidth 5
			Cls
			Local t:Int=MilliSecs()
			DrawLine 0,0,120*Cos(t),120*Sin(t)
			DrawLine 0,0,80*Cos(t/60),80*Sin(t/60)
			Flip

		Case EVENT_MOUSEMOVE
			Print "MOVE!"

		Case EVENT_WINDOWCLOSE
			FreeGadget canvas
			End

		Case EVENT_APPTERMINATE
			End
	End Select
Wend
