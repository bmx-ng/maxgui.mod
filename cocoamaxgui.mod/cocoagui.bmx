SuperStrict

Import MaxGUI.MaxGUI
Import Pub.MacOs
Import brl.systemdefault

Import "-framework WebKit"
Import "cocoa.macos.m"

Extern
	
	Function bbSystemEmitOSEvent( nsevent:Byte Ptr,nsview:Byte Ptr,source:Object )
	
	Function ScheduleEventDispatch()
	
	Function NSBegin()
	Function NSEnd()
	
	Function NSGetSysColor:Int(colorindex:Int,r:Int Ptr,g:Int Ptr, b:Int Ptr)
	Function NSColorRequester:Int(r:Int,g:Int,b:Int)
	Function NSSetPointer(shape:Int)
	
	Function NSCharWidth:Int(font:Byte Ptr,charcode:Int)
	' create
	Function NSInitGadget(gadget:TNSGadget)
	' generic
	Function NSActiveGadget:Byte Ptr()
	Function NSFreeGadget(gadget:TNSGadget)
	Function NSClientWidth:Int(gadget:TNSGadget)
	Function NSClientHeight:Int(gadget:TNSGadget)
	Function NSRethink(gadget:TNSGadget)
	Function NSRedraw(gadget:TNSGadget)
	Function NSActivate(gadget:TNSGadget,code:Int)
	Function NSState:Int(gadget:TNSGadget)
	Function NSShow(gadget:TNSGadget,state:Int)
	Function NSEnable(gadget:TNSGadget,state:Int)
	Function NSCheck(gadget:TNSGadget,state:Int)
	Function NSSetNextView(gadget:TNSGadget,nextgadget:TNSGadget)
	Function NSSetHotKey(gadget:TNSGadget,hotkey:Int,modifier:Int)
	Function NSSetTooltip:Int(gadget:TNSGadget,tip:String)
	Function NSGetTooltip:String(gadget:TNSGadget)
	Function NSSuperview:Byte Ptr(view:Byte Ptr)
	' window
	Function NSSetStatus(gadget:TNSGadget,Text:String,pos:Int)
	Function NSSetMinimumSize(gadget:TNSGadget,width:Int,height:Int)
	Function NSSetMaximumSize(gadget:TNSGadget,width:Int,height:Int)
	Function NSPopupMenu(gadget:TNSGadget,menu:TNSGadget)
	' font
	Function NSRequestFont:Byte Ptr(font:Byte Ptr)
	Function NSLoadFont:Byte Ptr(name:String,size:Double,flags:Int)
	Function NSGetDefaultFont:Byte Ptr()
	Function NSSetFont(gadget:TNSGadget,font:Byte Ptr)
	Function NSFontName:String(font:Byte Ptr)
	Function NSFontStyle:Int(font:Byte Ptr)
	Function NSFontSize:Double(font:Byte Ptr)
	' items
	Function NSClearItems(gadget:TNSGadget)
	Function NSAddItem(gadget:TNSGadget,index:Int,Text:String,tip:String,image:Byte Ptr,extra:Object)
	Function NSSetItem(gadget:TNSGadget,index:Int,Text:String,tip:String,image:Byte Ptr,extra:Object)
	Function NSRemoveItem(gadget:TNSGadget,index:Int)
	Function NSSelectItem(gadget:TNSGadget,index:Int,state:Int)
	Function NSSelectedItem:Int(gadget:TNSGadget,index:Int)
	Function NSSelectedNode:Byte Ptr(gadget:TNSGadget)
	' text
	Function NSSetText(gadget:TNSGadget,Text:String)
	Function NSGetText:String(gadget:TNSGadget)
	Function NSReplaceText(gadget:TNSGadget,pos:Int,length:Int,Text:String,units:Int)
	Function NSAddText(gadget:TNSGadget,Text:String)
	Function NSAreaText:String(gadget:TNSGadget,pos:Int,length:Int,units:Int)
	Function NSAreaLen:Int(gadget:TNSGadget,units:Int)
	Function NSLockText(gadget:TNSGadget)
	Function NSUnlockText(gadget:TNSGadget)
	Function NSSetTabs(gadget:TNSGadget,tabwidth:Int)
	Function NSSetMargins(gadget:TNSGadget,leftmargin:Int)
	Function NSSetColor(gadget:TNSGadget,r:Int,g:Int,b:Int)
	Function NSRemoveColor(gadget:TNSGadget)
	Function NSSetAlpha(gadget:TNSGadget,alpha:Float)
	Function NSSetTextColor(gadget:TNSGadget,r:Int,g:Int,b:Int)
	Function NSGetCursorPos:Int(gadget:TNSGadget,units:Int)
	Function NSGetSelectionlength:Int(gadget:TNSGadget,units:Int)
	Function NSSetStyle(gadget:TNSGadget,r:Int,g:Int,b:Int,flags:Int,pos:Int,length:Int,units:Int)	
	Function NSSetSelection(gadget:TNSGadget,pos:Int,length:Int,units:Int)
	Function NSCharAt:Int(gadget:TNSGadget,line:Int)
	Function NSLineAt:Int(gadget:TNSGadget,index:Int)
	Function NSCharX:Int(gadget:TGadget,char:Int)
	Function NSCharY:Int(gadget:TGadget,char:Int)
	' prop
	Function NSSetValue(gadget:TNSGadget,value:Float)
	' slider
	Function NSSetSlider(gadget:TNSGadget,value:Double,small:Double,big:Double)
	Function NSGetSlider:Double(gadget:TNSGadget)
	' images for panels and nodes
	Function NSPixmapImage:Byte Ptr(image:TPixmap)
	Function NSSetImage(gadget:TNSGadget,nsimage:Byte Ptr,flags:Int)
	Function NSSetIcon(gadget:TNSGadget,nsimage:Byte Ptr)
	Function NSCountKids:Int(gadget:TNSGadget)
	' html
	Function NSRun:String(gadget:TNSGadget,script:String)
	' misc
	Function NSRelease(nsobject:Byte Ptr)
	' system
	Function NSGetUserName:String()
	Function NSGetComputerName:String()
	
EndExtern

Global GadgetMap:TMap=New TMap

maxgui_driver=New TCocoaMaxGuiDriver

Type TCocoaMaxGUIDriver Extends TMaxGUIDriver
	
	Global CocoaGuiFont:TCocoaGuiFont
	
	Method New()
		NSBegin
		atexit_ NSEnd
		If Not CocoaGuiFont Then CocoaGuiFont = TCocoaGuiFont(LibraryFont(GUIFONT_SYSTEM))
	End Method
	
	Method UserName$()
		Return NSGetUserName$()
	End Method
	
	Method ComputerName$()
		Return NSGetComputerName$()
	End Method
		
	Method CreateGadget:TGadget(internalclass:Int,name:String,x:Int,y:Int,w:Int,h:Int,group:TGadget,style:Int)
		Local p:Int,hotkey:Int
		If internalclass=GADGET_MENUITEM
			name=name.Replace("&","")
		ElseIf internalclass=GADGET_BUTTON
			p=name.Find("&")
			If p>-1
'				hotkey=Asc(name[p..p+1]) 'to do - convert and call SetHotKey before return
				name=name[..p]+name[p+1..]
			EndIf
		ElseIf internalclass=GADGET_TOOLBAR
			Global _toolbarcount:Int
			_toolbarcount:+1
			name="Toolbar"+_toolbarcount
		EndIf
		Local gadget:TNSGadget = TNSGadget.Create(internalclass,name,x,y,w,h,TNSGadget(group),style)
		If internalclass<>GADGET_WINDOW And internalclass<>GADGET_MENUITEM And internalclass<>GADGET_DESKTOP
			gadget.SetLayout EDGE_CENTERED,EDGE_CENTERED,EDGE_CENTERED,EDGE_CENTERED
		EndIf
		If group Then gadget._SetParent group
		' gadget.SetTextColor(0,0,0) ' use default colour
		gadget.LinkView
		Return gadget	
	End Method
		
	Function CreateFont:TGuiFont(handle:Byte Ptr,flags:Int=FONT_NORMAL)
		Local font:TGuiFont = New TCocoaGuiFont
		font.handle = handle
		font.name = NSFontName(handle)
		font.size = NSFontSize(handle)
		font.style = NSFontStyle(handle)|flags
		Return font
	EndFunction

	Method LoadFont:TGuiFont(name:String,size:Int,flags:Int)
		Return CreateFont(NSLoadFont(name,Double(size),flags),flags)
	End Method
	
	Method LoadFontWithDouble:TGuiFont(name:String,size:Double,flags:Int)
		Return CreateFont(NSLoadFont(name,size,flags),flags)
	End Method
	
	Method LibraryFont:TGuiFont( pFontType:Int = GUIFONT_SYSTEM, pFontSize:Double = 0, pFontStyle:Int = FONT_NORMAL )
		If pFontType = GUIFONT_SYSTEM Then
			Local tmpHandle:Byte Ptr = NSGetDefaultFont()
			If pFontSize <= 0 Then pFontSize = NSFontSize(tmpHandle)
			Return LoadFontWithDouble( NSFontName(tmpHandle), pFontSize, NSFontStyle(tmpHandle)|pFontStyle )
		Else
			Return Super.LibraryFont( pFontType, pFontSize, pFontStyle )
		EndIf
	EndMethod
	
	Method LookupColor:Int( colorindex:Int, red:Byte Var, green:Byte Var, blue:Byte Var )
		
		Local r:Int, g:Int, b:Int
		
		If NSGetSysColor( colorindex, Varptr r, Varptr g, Varptr b )
			red = r & $FF
			green = g & $FF
			blue = b & $FF
			Return True
		EndIf
		
		Return Super.LookupColor( colorindex, red, green, blue )
				
	EndMethod
	
	Method RequestColor:Int(r:Int,g:Int,b:Int)
		Return NSColorRequester(r,g,b)
	End Method
	
	Method RequestFont:TGuiFont(font:TGuiFont)
		Local	handle:Byte Ptr
		If font handle=font.handle
		handle=NSRequestFont(handle)
		If handle
			If font And handle=font.handle Return font
			Return CreateFont(handle)
		EndIf
	End Method
	
	Method SetPointer:Int(shape:Int)
		NSSetPointer shape
	End Method		
	
	Method ActiveGadget:TGadget()
		PollSystem()
		Local handle:Byte Ptr = NSActiveGadget()
		If handle Return GadgetFromHandle(handle)
	End Method
	
	Method LoadIconStrip:TIconStrip(source:Object)
		Return TCocoaIconStrip.Create(source)
	End Method
End Type

Function GadgetFromHandle:TNSGadget( handle:Byte Ptr )
	Return TNSGadget( GadgetMap.ValueForKey( TPtrWrapper.Create(handle) ) )
End Function

Function EmitCocoaOSEvent( event:Byte Ptr,handle:Byte Ptr,gadget:Object = Null )
	Local owner:TGadget = TGadget(gadget)
	If Not owner Then owner = GadgetFromHandle( handle )
	If owner Then
		While owner.source
			owner = owner.source
		Wend
	EndIf
	bbSystemEmitOSEvent event,handle,owner
End Function

Function EmitCocoaMouseEvent:Int( event:Byte Ptr, handle:Byte Ptr )
	Local gadget:TNSGadget
'	While handle
		gadget = GadgetFromHandle( handle )
		If gadget Then
			If (gadget.sensitivity & SENSITIZE_MOUSE) Then
				EmitCocoaOSEvent( event, handle, gadget )
				Return 1
			EndIf
			Return 0
		EndIf
'		handle = NSSuperview(handle)
'	Wend
End Function

Function EmitCocoaKeyEvent:Int( event:Byte Ptr, handle:Byte Ptr )
	Local gadget:TNSGadget
	While handle
		gadget = GadgetFromHandle( handle )
		If gadget Then
			If (gadget.sensitivity & SENSITIZE_KEYS) Then
				EmitCocoaOSEvent( event, handle, gadget )
				Return 1
			EndIf
			Return 0
		EndIf
		handle = NSSuperview(handle)
	Wend
End Function

?Not Ptr64
Function PostCocoaGuiEvent( id:Int,handle:Byte Ptr,data:Int,mods:Int,x:Int,y:Int,extra:Object )
?Ptr64
Function PostCocoaGuiEvent( id:Int,handle:Byte Ptr,data:Long,mods:Int,x:Int,y:Int,extra:Object )
?
	'DebugLog "PostCocoaGuiEvent"
	Local gadget:TNSGadget
	
	DispatchGuiEvents()
	
	If handle Then
		
		gadget = GadgetFromHandle(handle)
		
		If gadget Then
			
			Select gadget.internalclass
				Case GADGET_TREEVIEW
					extra=GadgetFromHandle(Byte Ptr(data))
					data = 0
			EndSelect
			
			Select id
				Case EVENT_WINDOWSIZE
					If gadget.width <> x Or gadget.height <> y Then
						gadget.SetRect gadget.xpos,gadget.ypos,x,y
						gadget.LayoutKids
					Else
						Return
					EndIf
					
				Case EVENT_WINDOWMOVE
					If gadget.xpos <> x Or gadget.ypos <> y Then
						gadget.SetRect x,y,gadget.width,gadget.height
					Else
						Return
					EndIf
					
				Case EVENT_MENUACTION
					extra=TNSGadget.popupextra
					TNSGadget.popupextra=Null
					
				Case EVENT_GADGETACTION
					
					Select gadget.internalclass
						Case GADGET_SLIDER
							Local oldValue:Int = gadget.GetProp()
							If data Then
								Select (gadget.style&(SLIDER_SCROLLBAR|SLIDER_TRACKBAR|SLIDER_STEPPER))
									Case SLIDER_SCROLLBAR
										If data > 1 Then
											data = gadget.small
										ElseIf data < -1 Then
											data = -gadget.small
										EndIf
								EndSelect
								gadget.SetProp(Int(oldValue+data))
								data=gadget.GetProp()
								If (data = oldValue) Then Return
							Else
								data=gadget.GetProp()
							EndIf
						Case GADGET_LISTBOX, GADGET_COMBOBOX, GADGET_TABBER
							If (data > -1 And data < gadget.items.length) extra=gadget.ItemExtra(Int(data))
						Case GADGET_BUTTON
							Select (gadget.style&7)
								Case BUTTON_CHECKBOX
									If ButtonState(gadget) = CHECK_INDETERMINATE Then SetButtonState(gadget, CHECK_SELECTED )
								Case BUTTON_RADIO
									If (gadget.style&BUTTON_PUSH) Then SetButtonState(gadget,CHECK_SELECTED)
									gadget.ExcludeOthers()
							EndSelect
							data=ButtonState(gadget)
						Case GADGET_TOOLBAR
							If data>-1 Then
								extra=gadget.ItemExtra(Int(data))
								If (gadget.ItemFlags(Int(data))&GADGETITEM_TOGGLE) Then gadget.SelectItem(Int(data),2)
							EndIf
					EndSelect
					
				Case EVENT_GADGETSELECT, EVENT_GADGETMENU
					Select gadget.internalclass
						Case GADGET_LISTBOX, GADGET_COMBOBOX, GADGET_TABBER
							If data>-1 Then extra=gadget.ItemExtra(Int(data))
					EndSelect
					
				Case EVENT_GADGETLOSTFOCUS
				
					QueueGuiEvent id,gadget,Int(data),mods,x,y,extra
					ScheduleEventDispatch()
					Return
					
			EndSelect
		EndIf
	
	EndIf
	
	PostGuiEvent id,gadget,Int(data),mods,x,y,extra
	
EndFunction

Function FilterKeyDown:Int( handle:Byte Ptr,key:Int,mods:Int )
	Local source:TNSGadget
	If handle
		source=GadgetFromHandle(handle)
	EndIf
	If source And source.eventfilter<>Null
		Local event:TEvent=CreateEvent(EVENT_KEYDOWN,source,key,mods)
		Return source.eventfilter(event,source.context)
	EndIf
	Return 1
End Function

Function FilterChar:Int( handle:Byte Ptr,key:Int,mods:Int )
	Local source:TNSGadget
	Select key
		' Return true if they are arrow key characters
		Case 63232, 63233, 63234, 63235
			Return 1
	EndSelect
	If handle
		source=GadgetFromHandle(handle)
	EndIf
	If source And source.eventfilter<>Null 'Return source.charfilter(char,mods,source.context)
		Local event:TEvent=CreateEvent(EVENT_KEYCHAR,source,key,mods)
		Return source.eventfilter(event,source.context)
	EndIf
	Return 1
End Function

Type TNSGadget Extends TGadget
	
	Field internalclass:Int, origclass:Int	'internalclass: Class the Cocoa driver uses to draw the gadget, origclass: Expected class to be returned by Class() method
	Field handle:Byte Ptr
	Field view:Byte Ptr, textcolor:Byte Ptr	'view: NSView handle, textcolor: NSColor handle for Objective-C code
	Field intFontStyle:Int	'Copy of font.style used by cocoa.macos.m to handle underlining/strikethrough etc. that isn't included in NSFont
	Field pixmap:TPixmap
	Field icons:TCocoaIconStrip
	Field small:Int, big:Int
	Field canvas:TGraphics
	Field font:TCocoaGuiFont
	Field enabled:Int = True, forceDisable:Int = False

' main factory command

	Function Create:TNSGadget(internalclass:Int,Text:String,x:Int,y:Int,w:Int,h:Int,group:TGadget,style:Int)
		
		Local gadget:TNSGadget = New TNSGadget
		gadget.origclass = internalclass
		gadget.internalclass = internalclass
		
		If Not group And internalclass<>GADGET_DESKTOP Then group = Desktop()
		gadget.parent = group
		
		gadget.name = Text
		gadget.SetRect x,y,w,h	'setarea
		gadget.style = style
		gadget.font = TCocoaMaxGUIDriver.CocoaGUIFont
		
		If TNSGadget(group) Then
			gadget.forceDisable = Not (TNSGadget(group).enabled And Not TNSGadget(group).forceDisable)
		EndIf
		
		NSInitGadget gadget

		If internalclass<>GADGET_TOOLBAR 'toolbars retain name to key insertgadgetitem
			gadget.name = Null
		EndIf
		
		GadgetMap.Insert TPtrWrapper.Create(gadget.handle),gadget
		If gadget.view And gadget.handle <> gadget.view Then
			GadgetMap.Insert TPtrWrapper.Create(gadget.view),gadget
		EndIf
		
		If internalclass=GADGET_SLIDER Then gadget.SetRange(1,10)
		gadget.LockLayout()
		
		If (internalclass=GADGET_WINDOW) And (style&WINDOW_STATUS) Then
			If (style&WINDOW_CLIENTCOORDS) Then
				gadget.SetMinimumSize(25,0)
			Else
				gadget.SetMinimumSize(25,70)
			EndIf
		EndIf
		
		If LocalizationMode() & LOCALIZATION_OVERRIDE Then LocalizeGadget(gadget,Text,"")
		
		gadget.SetEnabled(gadget.enabled)
		
		Return gadget
		
	End Function
	
	Method Class:Int()
		Return origclass
	EndMethod
	
	Function ToView:TNSGadget(value:Object)
		Local	view:TNSGadget = TNSGadget(value)
		If Not view Return Null
		Select view.internalclass
			Case GADGET_DESKTOP,GADGET_WINDOW,GADGET_TOOLBAR,GADGET_LABEL,GADGET_PROGBAR,GADGET_MENUITEM,GADGET_NODE
				Return Null
		End Select
		Return view
	End Function
	
	Method LinkView()
		Local	First:TNSGadget
		Local	prev:TNSGadget
		Local	i:Int,n:Int

		If Not parent Return
		If Not ToView(Self) Return
		n=parent.kids.count()-1
		If n<0 Return
' find first view in family
		For i=0 Until  n
			First=ToView(parent.kids.ValueAtIndex(i))
			If First Exit
		Next
		If Not First Return
' find last view in family
		For i=n-1 To 0 Step -1
			prev=ToView(parent.kids.ValueAtIndex(i))
			If prev Exit
		Next
		If Not prev Return
		NSSetNextView(prev,Self)
		NSSetNextView(Self,First)
	End Method
	
	Method Delete()
		Free()
	End Method
	
' generic gadget commands

	Method Query:Byte Ptr(queryid:Int)
		Select queryid
			Case QUERY_NSVIEW
				Return handle
			Case QUERY_NSVIEW_CLIENT
				Return view
		End Select				
	End Method

	Method Free:Int()
		If handle Then
			
			If canvas Then canvas.close
			
			GadgetMap.Remove TPtrWrapper.Create(handle)
			If view And handle <> view Then
				GadgetMap.Remove TPtrWrapper.Create(view)
				view = Null
			EndIf
				
			If parent Then
				parent.kids.Remove Self
			End If
			
			NSFreeGadget Self
			font = Null
			
			handle = Null
			
		EndIf
	End Method

	Method Rethink:Int()			'resize	- was recursive
		NSRethink( Self )
	End Method
		
	Method ClientWidth:Int()
		Return Max(NSClientWidth(Self),0)
	End Method
	
	Method ClientHeight:Int()
		Return Max(NSClientHeight(Self),0)
	End Method
	
	Method Activate:Int(cmd:Int)
		NSActivate( Self, cmd )
	End Method
	
	Method State:Int()
		Local tmpState:Int = NSState(Self)&~STATE_DISABLED
		If Not enabled Then tmpState:|STATE_DISABLED
		Return tmpState
	End Method
	
	Method SetShow:Int(bool:Int)
		NSShow( Self, bool )
	End Method

	Method SetText:Int(msg:String)
		If internalclass=GADGET_HTMLVIEW
			Local	anchor:String,a:Int
			a=msg.Find("#")
			If a<>-1 anchor=msg[a..];msg=msg[..a]
			If msg[0..7].ToLower()<>"http://" And msg[0..7].ToLower()<>"file://"
				If FileType(msg)
					msg="file://"+msg
				Else
					msg="http://"+msg
				EndIf
			EndIf
			msg:+anchor
			msg=msg.Replace(" ","%20")
		ElseIf internalclass=GADGET_MENUITEM
			msg=msg.Replace("&", "")
		EndIf
		NSSetText Self,msg
	End Method
	
	Method RunString:String(msg:String)
		If internalclass=GADGET_HTMLVIEW Return NSRun(Self,msg)
	End Method

	Method GetText:String()
		Return NSGetText(Self)
	End Method

	Method SetFont:Int(pFont:TGuiFont)
		If Not TCocoaGuiFont(pFont) Then pFont = TCocoaMaxGUIDriver.CocoaGuiFont
		font = TCocoaGuiFont(pFont)
		intFontStyle = font.style
		NSSetFont( Self, font.handle )
	End Method

	Method SetColor:Int(r:Int,g:Int,b:Int)
		NSSetColor Self,r,g,b
	End Method

	Method RemoveColor:Int()
		NSRemoveColor Self
	End Method

	Method SetAlpha:Int(alpha:Float)
		NSSetAlpha Self,alpha
	End Method
	
	Method SetTextColor:Int(r:Int,g:Int,b:Int)
		NSSetTextColor Self,r,g,b
	End Method
	
	Method SetPixmap:Int(pixmap:TPixmap,flags:Int)
		Local	nsimage:Byte Ptr, x:Int
		If pixmap
			Select pixmap.format
				Case PF_I8,PF_BGR888
					pixmap=pixmap.Convert( PF_RGB888 )
				Case PF_A8,PF_BGRA8888
					pixmap=pixmap.Convert( PF_RGBA8888 )
			End Select
			
			If AlphaBitsPerPixel[ pixmap.format ]
				For Local y:Int=0 Until pixmap.height
					For x=0 Until pixmap.width
						Local argb:Int=pixmap.ReadPixel( x,y )
						pixmap.WritePixel x,y,premult(argb)
					Next
				Next
			EndIf
			nsimage=NSPixmapImage(pixmap)
		EndIf
		NSSetImage(Self,nsimage,flags)
	End Method
	
	Method SetTooltip:Int(pTip:String)
		Select internalclass
			Case GADGET_WINDOW, GADGET_DESKTOP, GADGET_LISTBOX, GADGET_MENUITEM, GADGET_TOOLBAR, GADGET_TABBER, GADGET_NODE
			Default;Return NSSetTooltip( Self, pTip )
		EndSelect
	EndMethod
	
	Method GetTooltip:String()
		Select internalclass
			Case GADGET_WINDOW, GADGET_DESKTOP, GADGET_LISTBOX, GADGET_MENUITEM, GADGET_TOOLBAR, GADGET_TABBER, GADGET_NODE
			Default;Return NSGetTooltip( Self )
		EndSelect
	EndMethod
	
	Method ExcludeOthers()
		For Local g:TNSGadget = EachIn parent.kids
			If g<>Self And g.internalclass=GADGET_BUTTON And (g.style&7)=BUTTON_RADIO
				NSCheck g,False
			EndIf
		Next
	End Method

	Method SetSelected:Int(bool:Int)
		NSCheck Self,bool
		If internalclass=GADGET_BUTTON And (style&7)=BUTTON_RADIO And bool
			ExcludeOthers
		EndIf
	End Method
	
	Method SetEnabled:Int(enable:Int)
		Local old:Int = enabled And Not forceDisable
		enabled = enable
		If Class() = GADGET_WINDOW Then
			NSEnable Self, enable
		Else
			enable = enable And Not forceDisable
			NSEnable Self, enable
			If (enable <> old) Then
				For Local tmpGadget:TNSGadget = EachIn kids
					tmpGadget.forceDisable = Not enable
					If tmpGadget.Class() <> GADGET_WINDOW Then tmpGadget.SetEnabled(tmpGadget.enabled)
				Next
			EndIf
		EndIf
	End Method
	
	Method SetHotKey:Int(hotkey:Int,modifier:Int)
		NSSetHotKey Self,hotkey,modifier
	End Method
	
' window commands
	
	Field _statustext:String
	
	Method GetStatusText:String()
		Return _statustext
	EndMethod
	
	Method SetStatusText:Int(msg:String)
		Local	t:Int,m0:String,m1:String,m2:String
		_statustext = msg
		m0=msg
		t=m0.find("~t");If t<>-1 m1=m0[t+1..];m0=m0[..t];
		t=m1.find("~t");If t<>-1 m2=m1[t+1..];m1=m1[..t];		
		NSSetStatus Self,m0,0
		NSSetStatus Self,m1,1
		NSSetStatus Self,m2,2
	End Method
	
	Method GetMenu:TGadget()
		Return Self
	End Method

	Global popupextra:Object
	
	Method PopupMenu:Int(menu:TGadget,extra:Object)
		popupextra=extra
		NSPopupMenu Self,TNSGadget(menu)
	End Method
	
	Method UpdateMenu:Int()
	End Method
	
	Method SetMinimumSize:Int(w:Int,h:Int)
		NSSetMinimumSize Self,w,h
	End Method
	
	Method SetMaximumSizeL:Int(w:Int,h:Int)
		NSSetMaximumSize Self,w,h
	End Method

	Method SetIconStrip:Int(iconstrip:TIconStrip)
		icons=TCocoaIconStrip(iconstrip)
	End Method

' item handling commands

	Method ClearListItems:Int()
		NSClearItems Self
	End Method

	Method InsertListItem:Int(index:Int,item:String,tip:String,icon:Int,extra:Object)
		Local	image:Byte Ptr
		If internalclass=GADGET_TOOLBAR
			item=name+":"+index
		EndIf
		If icons And icon>=0 image=icons.images[icon]
		NSAddItem Self,index,item,tip,image,extra
	End Method
	
	Method SetListItem:Int(index:Int,item:String,tip:String,icon:Int,extra:Object)
		Local	image:Byte Ptr
		If internalclass=GADGET_TOOLBAR
			item=name+":"+index
		EndIf
		If icons And icon>=0 image=icons.images[icon]
		NSSetItem Self,index,item,tip,image,extra
	End Method
	
	Method RemoveListItem:Int(index:Int)
		NSRemoveItem Self,index
	End Method
	
	Method SetListItemState:Int(index:Int,state:Int)
		NSSelectItem Self,index,state
	End Method
	
	Method ListItemState:Int(index:Int)
 		Return NSSelectedItem(Self,index)
	End Method
	
' treeview commands	

	Method RootNode:TGadget()
		Return Self
	End Method
	
	Method SetIcon(icon:Int)
		Local	p:TNSGadget
		p=Self
		While p
			If p.icons Exit
			p=TNSGadget(p.parent)
		Wend
		If p
			If icon>-1
				NSSetIcon Self,p.icons.images[icon]		
			Else
				NSSetIcon Self,Null		
			EndIf
		EndIf				
	End Method
	
	Method InsertNode:TGadget(index:Int,Text:String,icon:Int)
		Local	node:TNSGadget = Create(GADGET_NODE,Text,0,0,0,0,Self,index)
		node.SetIcon icon
		node._SetParent Self
		Return node
	End Method
	
	Method ModifyNode:Int(Text:String,icon:Int)
		NSSetText Self,Text
		SetIcon icon
	End Method

	Method SelectedNode:TGadget()
		Local	index:Byte Ptr = NSSelectedNode(Self)
		If (index) Return GadgetFromHandle(index)
	End Method

	Method CountKids:Int()
		Return NSCountKids(Self)
	End Method

' textarea commands

	Method ReplaceText:Int(pos:Int,length:Int,Text:String,units:Int)
?debug
		If pos<0 Or pos+length>AreaLen(units) Throw "Illegal Range"
?	
		NSReplaceText Self,pos,length,Text$,units
	End Method

	Method AddText:Int(Text:String)
		NSAddText Self,Text
	End Method

	Method AreaText:String(pos:Int,length:Int,units:Int)
?debug
		If pos<0 Or pos+length>AreaLen(units) Throw "Illegal Range"
?	
		Return NSAreaText(Self,pos,length,units)
	End Method

	Method AreaLen:Int(units:Int)
		Return NSAreaLen(Self,units)
	End Method

	Method LockText:Int()
		NSLockText Self
	End Method

	Method UnlockText:Int()
		NSUnlockText Self
	End Method

	Method SetTabs:Int(tabwidth:Int)
		NSSetTabs Self,tabwidth
	End Method

	Method SetMargins:Int(leftmargin:Int)
		NSSetMargins Self,leftmargin
	End Method

	Method GetCursorPos:Int(units:Int)
		Return NSGetCursorPos(Self,units)
	End Method

	Method GetSelectionLength:Int(units:Int)
		Return NSGetSelectionLength(Self,units)
	End Method

	Method SetStyle:Int(r:Int,g:Int,b:Int,flags:Int,pos:Int,length:Int,units:Int) 	
?debug
		If pos<0 Or pos+length>AreaLen(units) Throw "Illegal Range"
?	
		If length NSSetStyle Self,r,g,b,flags,pos,length,units
	End Method

	Method SetSelection:Int(pos:Int,length:Int,units:Int)
?debug
		If pos<0 Or pos+length>AreaLen(units) Throw "Illegal Range"
?	
		NSSetSelection Self,pos,length,units
	End Method

	Method CharAt:Int(line:Int)
?debug
		If line<0 Or line>AreaLen(TEXTAREA_LINES) Throw "Parameter Out Of Range"
?	
		Return NSCharAt(Self,line)
	End Method

	Method LineAt:Int(index:Int)
?debug
		If index<0 Or index>AreaLen(TEXTAREA_CHARS) Throw "Parameter Out Of Range"
?	
		Return NSLineAt(Self,index)
	End Method
	
	Method CharX:Int(char:Int)
		Return NSCharX(Self,char)
	EndMethod
	
	Method CharY:Int(char:Int)
		Return NSCharY(Self,char)
	EndMethod
	
' progbar
	
	Method SetValue:Int(value:Float)
		NSSetValue Self,value
	End Method

' slider / scrollbar

	Method SetRange:Int(_small:Int,_big:Int)
		small=_small
		big=_big
		NSSetSlider Self,GetProp(),small,big
	End Method
	
	Method SetProp:Int(pos:Int)
		NSSetSlider Self,pos,small,big
	End Method

	Method GetProp:Int()
		Local value:Double = NSGetSlider(Self)
		If Not (style&(SLIDER_TRACKBAR|SLIDER_STEPPER))
			value:*(big-small)
			If value>big-small value=big-small
		EndIf
		Return Int(value+0.5:Double)
	End Method
	
' canvas

	Method AttachGraphics:TGraphics( flags:Long )
		canvas=brl.Graphics.AttachGraphics( Query(QUERY_NSVIEW_CLIENT),flags )
	End Method
	
	Method CanvasGraphics:TGraphics()
		Return canvas
	End Method

End Type


Type TCocoaIconStrip Extends TIconStrip
	
	Field images:Byte Ptr[]
	
	Function IsNotBlank:Int(pixmap:TPixmap)
		Local y:Int, h:Int = pixmap.height
		Local c:Int = pixmap.ReadPixel(0,0) 			
		For Local x:Int = 0 Until h
			For y = 0 Until h
				If pixmap.ReadPixel(x,y)<>c Return True
			Next
		Next
	End Function
		
	Function Create:TCocoaIconStrip(source:Object)
		Local	icons:TCocoaIconStrip
		Local	pixmap:TPixmap,pix:TPixmap
		Local	n:Int,x:Int,w:Int
		pixmap=TPixmap(source)
		If Not pixmap pixmap=LoadPixmap(source)
		If Not pixmap Return Null
		Select pixmap.format
		Case PF_I8,PF_BGR888
			pixmap=pixmap.Convert( PF_RGB888 )
		Case PF_A8,PF_BGRA8888
			pixmap=pixmap.Convert( PF_RGBA8888 )
		End Select
		
		If AlphaBitsPerPixel[ pixmap.format ]
			For Local y:Int=0 Until pixmap.height
				For x:Int=0 Until pixmap.width
					Local argb:Int=pixmap.ReadPixel( x,y )
					pixmap.WritePixel x,y,premult(argb)
				Next
			Next
		EndIf

		n=pixmap.width/pixmap.height;
		If n=0 Return Null
		icons=New TCocoaIconStrip
		icons.pixmap=pixmap
		icons.count=n
		icons.images=New Byte Ptr[n]
		w=pixmap.width/n			
		For x=0 Until n
			pix=pixmap.Window(x*w,0,w,pixmap.height)
			If IsNotBlank(pix) icons.images[x]=NSPixmapImage(pix)
		Next
		Return icons
	EndFunction	
	
EndType

Type TCocoaGuiFont Extends TGuiFont
	
	Method Delete()
		If handle Then
			NSRelease(handle)
			handle = 0
		EndIf
	EndMethod
	
	Method CharWidth:Int(char:Int)
		If handle
			Return NSCharWidth(handle,char)
		EndIf
		Return 0
	EndMethod 
		
EndType

Type TPtrWrapper Final
	Field value:Byte Ptr
	Function Create:TPtrWrapper(value:Byte Ptr)
		Local tmpWrapper:TPtrWrapper = New TPtrWrapper
		tmpWrapper.value = value
		Return tmpWrapper
	EndFunction
	Method Compare:Int( o:Object )
		Local c:TPtrWrapper = TPtrWrapper(o)
		If c Then Return (value - c.value)
		Return Super.Compare(o)
	EndMethod
	Method ToString$()
		'Return value
	EndMethod
EndType

Private

Function premult:Int(argb:Int)
	Local a:Int = ((argb Shr 24) & $FF)
	Return ((((argb&$ff00ff)*a)Shr 8)&$ff00ff)|((((argb&$ff00)*a)Shr 8)&$ff00)|(a Shl 24)
End Function
