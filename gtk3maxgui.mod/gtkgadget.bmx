' Copyright (c) 2006-2018 Bruce A Henderson
' 
' Permission is hereby granted, free of charge, to any person obtaining a copy
' of this software and associated documentation files (the "Software"), to deal
' in the Software without restriction, including without limitation the rights
' to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
' copies of the Software, and to permit persons to whom the Software is
' furnished to do so, subject to the following conditions:
' 
' The above copyright notice and this permission notice shall be included in
' all copies or substantial portions of the Software.
' 
' THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
' IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
' FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
' AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
' LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
' OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
' THE SOFTWARE.
' 
SuperStrict

Import "gtkcommon.bmx"

Type TGTKGadget Extends TGadget

	Field iclass:Int
	' usually the pointer to the gtk widget
	Field handle:Byte Ptr

	Field menubar:Byte Ptr
	Field menu:Byte Ptr

	' reference to this gadgets' font (if we've ever set it programmatically)
	Field _font:TGuiFont

	' a map to hold connection handler ids... sometimes we need to disconnect the little buggers.
	Field connectionMap:TMap = New TMap

	' a unique identifier for this gadget
	Field accelMapId:String
	Field accelString:String
	Field hasAccel:Int
	
	Field initialSizing:Int = False

	Field mySetVisible:Int = True
	Field visible:Int = False
	
	' the class id of this gadget in MaxGUI terms.
	Field maxguiClass:Int
	
	Method Init(GadgetClass:Int, _x:Int, _y:Int, _w:Int, _h:Int, _style:Int)
		SetRect(_x,_y,_w,_h)
		iclass = GadgetClass
		kids = New TList
		style = _style
	End Method

	Method addConnection(name:String, id:Int)
		connectionMap.Insert(name, TGTKInteger.Set(id))
	End Method

	Function Destroy(data:Byte Ptr, closure:Byte Ptr)
		'Print "Destroy Handler"
	End Function

	Function Create:TGTKGadget(GadgetClass:Int, x:Int, y:Int, w:Int, h:Int, label:String, group:TGadget, style:Int, mgclass:Int)

		Local gadget:TGTKGadget
		
		Select GadgetClass
			Case GTK_WINDOW
				gadget = TGTKWindow.CreateWindow(x, y ,w , h, label, group, style)
			Case GTK_BUTTON
				gadget = TGTKButtonPush.CreateButton(x, y ,w , h, label, group, style)
			Case GTK_RADIOBUTTON
				gadget = TGTKButtonRadio.CreateButton(x, y ,w , h, label, group, style)
			Case GTK_CHECKBUTTON
				gadget = TGTKButtonCheckbox.CreateButton(x, y ,w , h, label, group, style)
			Case GTK_LABEL
				gadget = TGTKLabel.CreateLabel(x, y ,w , h, label, group, style)
			Case GTK_MENUITEM
				gadget = TGTKMenuItem.CreateMenuItem(label, style, group)
			Case GTK_TEXTFIELD
				gadget = TGTKTextField.CreateTextField(x, y ,w , h, label, group, style)
			Case GTK_HTMLVIEW
				If gtk3maxgui_htmlview Then
					gadget = gtk3maxgui_htmlview.CreateHTMLView(x, y ,w , h, label, group, style)
				Else
					Throw "No HTMLView specified. You need To Import one!    " + ..
						" Import Gtk.gtk3webkitgtk"
				End If
			Case GTK_TABBER
				gadget = TGTKTabber.CreateTabber(x, y ,w , h, label, group, style)
			Case GTK_PANEL
				gadget = TGTKPanel.CreatePanel(x, y ,w , h, label, group, style)
			Case GTK_COMBOBOX
				gadget = TGTKComboBox.CreateComboBox(x, y ,w , h, label, group, style)
			Case GTK_PROGRESSBAR
				gadget = TGTKProgressBar.CreateProgressBar(x, y ,w , h, label, group, style)
			Case GTK_STEPPER
				gadget = TGTKStepper.CreateStepper(x, y ,w , h, label, group, style)
			Case GTK_SCROLLBAR
				gadget = TGTKScrollBar.CreateScrollBar(x, y ,w , h, label, group, style)
			Case GTK_TRACKBAR
				gadget = TGTKTrackBar.CreateTrackBar(x, y ,w , h, label, group, style)
			Case GTK_TEXTAREA
				' no custom text area? use the default
				If Not gtk3maxgui_textarea Then
					gtk3maxgui_textarea = New TGTKDefaultTextAreaDriver
				End If
				gadget = gtk3maxgui_textarea.CreateTextArea(x, y ,w , h, label, group, style)
			Case GTK_TOOLBAR
				gadget = TGTKToolbar.CreateToolBar(x, y ,w , h, label, group, style)
			Case GTK_LISTBOX
				gadget = TGTKListbox.CreateListBox(x, y ,w , h, label, group, style)
			Case GTK_TREEVIEW
				gadget = TGTKTreeView.CreateTreeView(x, y ,w , h, label, group, style)
Rem 
			Case GTK_CANVAS
				gadget = TGTKCanvas.CreateCanvas(x, y ,w , h, label, group, style)
End Rem
		End Select

		' map the new gadget - so we can find it later if required
		If gadget Then
			GadgetMap.Insert(gadget.handle, gadget)
		End If
		
		If group Then
			gadget._SetParent group
		End If
		gadget.SetShape x,y,w,h
		' set the maxgui class type
		gadget.maxguiClass = mgclass

		Return gadget
	End Function

	Method Free:Int()
		Local gadget:TGTKGadget
		Local rkids:TList		
		rkids=kids.Reversed()
		For gadget = EachIn rkids
			gadget.Free()
		Next
		gadget = TGTKGadget(parent)
		If gadget Then
			gadget.kids.remove Self
		End If

		' remove reference from global reference map
		If handle Then
			GadgetMap.Remove(handle)
			handle = Null
		End If
		
		connectionMap.Clear()
		
	End Method

	Rem
	bbdoc: Show or hide the gadget.
	End Rem
	Method SetShow:Int(truefalse:Int)
		visible = truefalse
		mySetVisible = visible
		
		If truefalse Then
			gtk_widget_show(handle)
		Else
			gtk_widget_hide(handle)
		EndIf
		
		UpdateChildVisibility()
	End Method

	Method UpdateChildVisibility()
		For Local gadget:TGTKGadget = EachIn kids
			If Not visible Then
				gadget.visible = False
			Else
				gadget.visible = gadget.mySetVisible
			End If
			
			gadget.UpdateChildVisibility()
		Next
	End Method

	' checks text for mnemonics
	Method processText:String(txt:String)
		' convert underscores to doubles
		txt = txt.Replace("_", "__")

		txt = txt.Replace("&&", "$^^$")
		txt = txt.Replace("&", "_")
		txt = txt.Replace("$^^$", "&")
		
		Return txt
	End Method

	Method setAccelEntry(keycode:Int, modifier:Int)
		Local accelKey:Int
		Local modKey:Int
		
		If accelString And hasAccel Then
			Local accelPtr:Byte Ptr = accelString.ToUTF8String()
			gtk_accelerator_parse(accelPtr, Varptr accelKey, Varptr modKey)
			MemFree(accelPtr)
			If accelKey <> 0 Then
				gtk_widget_remove_accelerator(handle, getWindow().accelGroup, accelKey, modKey)
				hasAccel = False
			End If
		End If

		' enabling accelerator?	
		If keycode Then
			accelString = TGTKKeyMap.accelToString(keycode, modifier)
			Local accelPtr:Byte Ptr = accelString.ToUTF8String()
			gtk_accelerator_parse(accelPtr, Varptr accelKey, Varptr modKey)
			MemFree(accelPtr)
			gtk_widget_add_accelerator(handle, "activate", getWindow().accelGroup, accelKey, modKey, GTK_ACCEL_VISIBLE)
			hasAccel = True
		End If
	End Method
	
	Method setAccelMapId(id:String)
		accelMapId = id.Replace("&", "")
	End Method

	' returns the widgets window
	Method getWindow:TGTKWindow()
		If Not TGTKWindow(Self) Then
			If TGTKGadget(parent) Then
				Return TGTKGadget(parent).getWindow()
			Else
				Return Null
			End If
		End If
		
		Return TGTKWindow(Self)
	End Method

	Rem
	bbdoc: Callback for focus lost.
	End Rem
	Function OnFocusLost:Int(widget:Byte Ptr, event:Byte Ptr, obj:Object)
		PostGuiEvent(EVENT_GADGETLOSTFOCUS, TGadget(obj))
	End Function
	
	Rem
	bbdoc: Set the gadget tooltip.
	End Rem
	Method setToolTip:Int(tip:String)
		If tip And tip.length > 0 Then
			Local tipPtr:Byte Ptr = tip.ToUTF8String()
			gtk_widget_set_tooltip_text(handle, tipPtr)
			MemFree(tipPtr)
		Else
			gtk_widget_set_has_tooltip(handle, False)
		End If
	End Method

	Rem
	bbdoc: Perform an activation command on the gadget.
	End Rem
	Method Activate:Int(cmd:Int)
		Select cmd
			Case ACTIVATE_FOCUS
				gtk_widget_grab_focus(handle)
			Case ACTIVATE_FORWARD
			Case ACTIVATE_BACK
			Case ACTIVATE_REDRAW
				redraw()
				PostGuiEvent(EVENT_GADGETPAINT, Self)
		End Select
	End Method
	
	Method redraw()
		gtk_widget_queue_draw(handle)
	End Method

	Rem
	bbdoc: Return the gadget's client width.
	End Rem
	Method ClientWidth:Int()
		If initialSizing Then
?bmxng
			Local minReq:GtkRequisition 
			Local natReq:GtkRequisition
?Not bmxng
			Local minReq:GtkRequisition = New GtkRequisition
			Local natReq:GtkRequisition = New GtkRequisition
?
			gtk_widget_get_preferred_size(handle, minReq, natReq)

			Return natReq.width
		End If
		Return width
	End Method

	Rem
	bbdoc: Return the gadget's client height.
	End Rem
	Method ClientHeight:Int()
		If initialSizing Then
?bmxng
			Local minReq:GtkRequisition 
			Local natReq:GtkRequisition
?Not bmxng
			Local minReq:GtkRequisition = New GtkRequisition
			Local natReq:GtkRequisition = New GtkRequisition
?
			gtk_widget_get_preferred_size(handle, minReq, natReq)

			Return natReq.height
		End If
		Return height
	End Method

	Method Rethink:Int()
		If handle
			gtk_layout_move(TGTKContainer(parent).container, handle, Max(xpos,0), Max(ypos,0))
			gtk_widget_set_size_request(handle, Max(width,0), Max(height,0))
		End If
	End Method

	Rem
	bbdoc: Return the gadget state.
	End Rem
	Method State:Int()
		Local flags:Int
		Local _state:Int = gtk_widget_get_state_flags(handle)

		Select _state
			Case GTK_STATE_FLAG_INSENSITIVE
				flags:| STATE_DISABLED
			Case GTK_STATE_FLAG_SELECTED
				flags:| STATE_SELECTED
			Case GTK_STATE_FLAG_ACTIVE
				flags:| STATE_ACTIVE
		End Select

		If Not gtk_widget_get_visible(handle) Then
			flags:| STATE_HIDDEN
		End If

		Return flags
	End Method

End Type

Rem
bbdoc: The Desktop.
End Rem
Type TGTKDesktop Extends TGTKGadget

	Function CreateDesktop:TGTKDesktop()
		Local this:TGTKDesktop = New TGTKDesktop

		this.initDesktop()

		Return this
	End Function

	Method initDesktop()

		iclass = GTK_DESKTOP

		handle = gdk_screen_get_default()

		SetArea(0, 0, gdk_screen_get_width(handle), gdk_screen_get_height(handle))

	End Method

	Method Rethink:Int()
	End Method

	Rem
	bbdoc: Returns the desktop width.
	End Rem
	Method ClientWidth:Int()
		Return width
	End Method

	Rem
	bbdoc: Returns the desktop height.
	End Rem
	Method ClientHeight:Int()
		Return height
	End Method
	
	Rem
	bbdoc: Returns the desktop depth.
	End Rem
	Method GetDepth:Int()
		Local visual:Byte Ptr = gdk_screen_get_system_visual(handle)
		Return gdk_visual_get_depth(visual)
	End Method
	
	Rem
	bbdoc: Returns the desktop hertz.
	End Rem
	Method GetHertz:Int()
		Return bmx_gtk3_gtkdesktop_gethertz()
	End Method
	
	Rem
	bbdoc: Returns the desktop scale factor that maps from window coordiantes to the actual device pixels.
	about: On traditional systems this is 1, but on very high density outputs this can be a higher value (often 2).
	End Rem
	Method ScaleFactor:Int()
		Return gdk_screen_get_monitor_scale_factor(handle, 0)
	End Method

End Type

Rem
bbdoc: This type handles "internal" widget containers for "Container" gadgets.
End Rem
Type TGTKContainer Extends TGTKGadget

	' a multi-row container
	Field box:Byte Ptr

	' the "Fixed" container that we place gadgets onto
	Field container:Byte Ptr

	' dont need to free this, as removing radio buttons from it will free itself when empty
	Field radioGroup:Byte Ptr
	
	' initialize the container stuff
	Method Init(GadgetClass:Int, x:Int, y:Int, w:Int, h:Int, style:Int)
		Super.init(GadgetClass, x, y, w, h, style)

	End Method

	Method ClientWidth:Int()
		Return width
	End Method

	Method ClientHeight:Int()
		Return height
	End Method


End Type

Rem
bbdoc: A Window
End Rem
Type TGTKWindow Extends TGTKContainer

	Field statusbar:Byte Ptr
	Field sblabels:Byte Ptr[]
	
	Field toolbar:TGTKToolbar
	Field accelGroup:Byte Ptr

	Field oldCW:Int
	Field oldCH:Int
	
	Field _maximized:Int
	Field _minimized:Int
	
	Field ignoreMoveEvent:Int
	Field ignoreSizeEvent:Int
	
	Function CreateWindow:TGTKWindow(x:Int, y:Int, w:Int, h:Int, label:String, group:TGadget, style:Int)
		Local this:TGTKWindow = New TGTKWindow

		this.initWindow(x, y, w, h, label, group, style)

		gtkWindows.addLast(this)
		
		Return this
	End Function

	Method initWindow(x:Int, y:Int, w:Int, h:Int, label:String, group:TGadget, style:Int)

		If group And TGTKDesktop(group)
			group = Null
		End If
		
		' should only be a window parent!!
		If group Then
			Assert TGTKWindow(group), "group not TGTKWindow!"
		End If

		handle = gtk_window_new(GTK_WINDOW_TOPLEVEL)

		Init(GTK_WINDOW, x, y, w, h, style)

		' container BEGIN
		box = gtk_box_new(GTK_ORIENTATION_VERTICAL, 0)
		gtk_widget_show(box)

		If style & WINDOW_MENU Then
			menubar = gtk_menu_bar_new()
			gtk_box_pack_start(box, menubar, False, True, 0)
			gtk_widget_show(menubar)
		End If

		container = gtk_layout_new(Null, Null)
		
		gtk_widget_show(container)
		gtk_box_pack_start(box, container, True, True, 0)
		' container END

		If style & WINDOW_STATUS Then
			createStatusbar()
			SetStatusText("")
		EndIf

		If (LocalizationMode() & LOCALIZATION_OVERRIDE) Then
			LocalizeGadget(Self, label)
		Else
			SetText(label)
		EndIf

		gtk_window_move(handle, x, y)
		gtk_window_set_default_size(handle, w, calcHeight(h))

		gtk_window_set_decorated(handle, (style & WINDOW_TITLEBAR))
		gtk_window_set_resizable(handle, (style & WINDOW_RESIZABLE))
		
		If style & WINDOW_TOOL Then
			gtk_window_set_type_hint(handle, GDK_WINDOW_TYPE_HINT_UTILITY)
		End If

		gtk_container_add(handle, box)
		' some funky window setting up...
		' It's all rather fiddly, but it appears to work.

?bmxng
		Local geom:GdkGeometry
?Not bmxng
		Local geom:GdkGeometry = New GdkGeometry
?
'DebugStop
		Local hints:Int = 0
		If style & WINDOW_RESIZABLE Then
			hints:| GDK_HINT_USER_SIZE
			geom.minWidth = 16
			geom.minHeight = 16
		
			hints:| GDK_HINT_RESIZE_INC
			geom.widthInc = 1
			geom.heightInc = 1
		Else
			geom.minWidth = w
			geom.minHeight = calcHeight(h)
		End If
		geom.maxWidth = -1
		geom.maxHeight = -1

		If Not (style & WINDOW_CLIENTCOORDS) Then
			geom.baseWidth = w
			geom.baseHeight = calcHeight(h)
		Else
			geom.baseWidth = -1
			geom.baseHeight = -1
		End If
		gtk_window_set_geometry_hints(handle, box, geom, GDK_HINT_POS | GDK_HINT_MIN_SIZE | ..
			GDK_HINT_BASE_SIZE | GDK_HINT_USER_POS | hints)

		If Not(style & WINDOW_RESIZABLE) Then
			gtk_widget_set_size_request(handle, w, calcHeight(h))
		End If

		' connect this window with its parent
		If group And (style & WINDOW_CHILD) Then
			gtk_window_set_transient_for(handle, TGTKWindow(group).handle)
		End If

		Rem
		A Window produces the following events:
		EVENT_WINDOWMOVE	Window has been moved
		EVENT_WINDOWSIZE	Window has been resized
		EVENT_WINDOWCLOSE	Window close icon clicked
		EVENT_WINDOWACTIVATE	Window activated
		EVENT_WINDOWACCEPT	Drag and Drop operation was attempted
		End Rem
		' move
		addConnection("configure-event", g_signal_cb3(handle, "configure-event", OnWindowMoveSize, Self, Destroy, 0))
		' size
		addConnection("check-resize", g_signal_cb2(handle, "check-resize", OnWindowSize, Self, Destroy, 0))
		' close
		addConnection("delete-event", g_signal_cb3_ret(handle, "delete-event", OnWindowClose, Self, Destroy, 0))
		' activate
		addConnection("focus-in-event", g_signal_cb3(handle, "focus-in-event", OnWindowActivate, Self, Destroy, 0))
		addConnection("focus-out-event", g_signal_cb3_ret(handle, "focus-out-event", OnWindowDeactivate, Self, Destroy, 0))
		' accept
		'g_signal_cb3(handle, "XXXXXX", WindowAccept, Self, Destroy, 0)
		' minimize / maximize
		addConnection("window-state-event", g_signal_cb3_ret(handle, "window-state-event", OnWindowStateChange, Self, Destroy, 0))

		If style & WINDOW_ACCEPTFILES Then
			'Local entries:Byte Ptr
			
			gtk_drag_dest_set(handle, GTK_DEST_DEFAULT_ALL, Null, 0, GDK_ACTION_COPY)
			gtk_drag_dest_add_uri_targets(handle)
			
			addConnection("drag-drop", g_signal_cb8(handle, "drag-data-received", OnDragDrop, Self, Destroy, 0))
		End If
		
		' used for tabbers - ensure they are redrawn properly when required
		'g_signal_cb7(container, "draw-background", OnDraw, Self, Destroy, 0)

		accelGroup = gtk_accel_group_new()
		gtk_window_add_accel_group(handle, accelGroup)
		setAccelMapId(label)

		If ~style & WINDOW_HIDDEN
			Setshow(True)
		Else
			SetShow(False)
		End If

	End Method

	Method calcHeight:Int(requestedHeight:Int)
		If Not (style & WINDOW_CLIENTCOORDS) Then
			Return requestedHeight	
		Else
?bmxng
			Local minReq:GtkRequisition 
			Local natReq:GtkRequisition
?Not bmxng
			Local minReq:GtkRequisition = New GtkRequisition
			Local natReq:GtkRequisition = New GtkRequisition
?
			If statusbar Then
				gtk_widget_get_preferred_size(statusbar, minReq, natReq)
				requestedHeight:+ natReq.height
			End If
			If menubar Then
				gtk_widget_get_preferred_size(menubar, minReq, natReq)
				requestedHeight:+ natReq.height
			End If
			
			Return requestedHeight
		End If
	End Method

	Method deCalcHeight:Int(actualHeight:Int)
		If Not (style & WINDOW_CLIENTCOORDS) Then
			Return actualHeight	
		Else
?bmxng
			Local minReq:GtkRequisition 
			Local natReq:GtkRequisition
?Not bmxng
			Local minReq:GtkRequisition = New GtkRequisition
			Local natReq:GtkRequisition = New GtkRequisition
?
			If statusbar Then
				gtk_widget_get_preferred_size(statusbar, minReq, natReq)
				actualHeight:- natReq.height
			End If
			If menubar Then
				gtk_widget_get_preferred_size(statusbar, minReq, natReq)
				actualHeight:- natReq.height
			End If

			Return actualHeight
		End If
	End Method
	
	Rem
	bbdoc: Callback for window size / move
	End Rem
	Function OnWindowMoveSize(widget:Byte Ptr, event:Byte Ptr, obj:Object)
		Local x:Int, y:Int, w:Int, h:Int
		bmx_gtk3maxgui_gdkeventconfigure(event, Varptr x, Varptr y, Varptr w, Varptr h)

		Local win:TGTKWindow = TGTKWindow(obj)
		If win Then
			Local change:Int = False
			
			h = win.deCalcHeight(h)
			
			' Has the window actually changed size/position?
			If win.width <> w Or win.height <> h Then
				change = True

				If Not win.ignoreSizeEvent Then
					PostGuiEvent(EVENT_WINDOWSIZE, TGadget(obj),,,w,h)
				End If
			End If
			
			gtk_window_get_position(win.handle, Varptr x, Varptr y)
			
			If win.xpos <> x Or win.ypos <> y Then
				change = True

				If Not win.ignoreMoveEvent Then
					PostGuiEvent(EVENT_WINDOWMOVE, TGadget(obj),,,x,y)
				End If
			End If

			If win.ClientHeight() <> win.oldCH Or win.ClientWidth() <> win.oldCW Then
				win.oldCH = win.ClientHeight()
				win.oldCW = win.ClientWidth()

				change = True
			End If
			
			' something has changed.. we need to update ourself and tell the children.
			If change Then
				win.setRect(x, y, w, h)
				win.layoutkids()
			End If
			
			win.ignoreMoveEvent = False
			win.ignoreSizeEvent = False
		End If

	End Function
	
	Method Rethink:Int()
		gtk_window_move(handle, xpos, ypos)
		If style & WINDOW_RESIZABLE Then
			gtk_window_resize(handle, width, calcHeight(height))
		Else
			gtk_window_set_default_size(handle, width, calcHeight(height))
		End If
		
		layoutkids() ' we need to do this so the children know we've really changed.
	End Method

	Rem
	bbdoc: Callback for window size.
	about: This event doesn't actually trigger a max size event, but we use it to adjust the client
	size.
	End Rem
	Function OnWindowSize(widget:Byte Ptr, obj:Object)
		Local win:TGTKWindow = TGTKWindow(obj)
		If win Then
			If win.ClientHeight() <> win.oldCH Or win.ClientWidth() <> win.oldCW Then
				win.oldCH = win.ClientHeight()
				win.oldCW = win.ClientWidth()

				TGTKContainer(obj).rethink()
			End If
		End If
	End Function

	Rem
	bbdoc: Callback for window state change.
	End Rem	
	Function OnWindowStateChange:Int(widget:Byte Ptr, event:Byte Ptr, obj:Object)
		Local statemask:Int
		bmx_gtk3maxgui_gdkeventwindowstate(event, Varptr statemask)
		
		Local win:TGTKWindow = TGTKWindow(obj)
		If win Then
			If statemask & GDK_WINDOW_STATE_ICONIFIED Then
				win._minimized = Not win._minimized
			End If
			
			If statemask & GDK_WINDOW_STATE_MAXIMIZED Then
				win._maximized = Not win._maximized
				
				' when maximized, we can't be minimized... so clear it
				If win._maximized Then
					win._minimized = False
				End If
			End If

		End If
	End Function

	Rem
	bbdoc: Callback for window close
	End Rem
	Function OnWindowClose:Int(widget:Byte Ptr, event:Byte Ptr, obj:Object)
		PostGuiEvent(EVENT_WINDOWCLOSE, TGadget(obj))
		Return True ' we don't want it to close - that's a user decision :-p
	End Function
	
	Rem
	bbdoc: Callback for window activate
	End Rem
	Function OnWindowActivate(widget:Byte Ptr, event:Byte Ptr, obj:Object)
		PostGuiEvent(EVENT_WINDOWACTIVATE, TGadget(obj))
	End Function

	Rem
	bbdoc: Callback for window deactivate
	about: Not used, but might come in handy at some point...
	End Rem
	Function OnWindowDeactivate:Int(widget:Byte Ptr, event:Byte Ptr, obj:Object)
		' We catch this but don't act on it...
		Return False
	End Function
	
	Function OnDragDrop(widget:Byte Ptr, context:Byte Ptr, x:Int, y:Int, data:Byte Ptr, info:Int, time:Int, obj:Object)
		Local uris:String[] = bmx_gtk3_selection_data_get_uris(data)
		If uris Then
			For Local uri:String = EachIn uris
				PostGuiEvent EVENT_WINDOWACCEPT,TGadget(obj),0,0,x,y,uri.Replace("file://", "")
			Next
		End If
	End Function

	Method SetShape:Int(x:Int,y:Int,w:Int,h:Int)
		If x <> xpos Or y <> ypos Then
			ignoreMoveEvent = True
		End If
		If w <> width Or h <> height Then
			ignoreSizeEvent = True
		End If
		Super.SetShape(Max(x, 0), Max(y, 0), w, h)
	End Method

	Rem
	bbdoc: Set the window status text
	End Rem
	Method SetStatusText:Int(text:String)
		If statusbar Then

			Local t:Int, m0:String, m1:String, m2:String
			m0 = text
			t = m0.find("~t")
			If t <> -1 Then
				m1 = m0[t+1..]
				m0 = m0[..t]
			End If
			t = m1.find("~t")
			If t <> -1 Then
				m2 = m1[t+1..]
				m1 = m1[..t]
			End If
			
			Local mb0:Byte Ptr = m0.ToUTF8String()
			Local mb1:Byte Ptr = m1.ToUTF8String()
			Local mb2:Byte Ptr = m2.ToUTF8String()
			gtk_label_set_text(sblabels[0], mb0)
			gtk_label_set_text(sblabels[1], mb1)
			gtk_label_set_text(sblabels[2], mb2)
			MemFree(mb2)
			MemFree(mb1)
			MemFree(mb0)

			If m0.length = 0 And m1.length = 0 And m2.length = 0 Then
				gtk_widget_show(sblabels[0])
				gtk_widget_hide(sblabels[1])
				gtk_widget_hide(sblabels[2])
			Else
				If m0.length > 0 Then
					gtk_widget_show(sblabels[0])
				Else
					gtk_widget_hide(sblabels[0])
				End If
				
				If m1.length > 0 Then
					gtk_widget_show(sblabels[1])
				Else
					gtk_widget_hide(sblabels[1])
				End If
				
				If m2.length > 0 Then
					gtk_widget_show(sblabels[2])
				Else
					gtk_widget_hide(sblabels[2])
				End If
			End If
		End If
	End Method

	Method GetMenu:TGadget()
		Return Self
	End Method
	
	Method createStatusbar()
		' our "statusbar" is actually a horizontal box...
		statusbar = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 0)
		gtk_widget_show(statusbar)

		sblabels = New Byte Ptr[3]
		
		For Local i:Int = 0 Until 3
		
			Local sblabel:Byte Ptr = gtk_label_new("")

			sblabels[i] = sblabel
			
			If i = 0 Then
				gtk_misc_set_alignment(sblabel, 0, 0.5)
				'gtk_label_set_yalign(sblabel, 0.5) ' 3.16
			Else If i = 2 Then
				gtk_misc_set_alignment(sblabel, 1, 0.5)
				'gtk_label_set_xalign(sblabel, 1) ' 3.16
				'gtk_label_set_yalign(sblabel, 0.5) ' 3.16
			End If
			
			gtk_box_pack_start(statusbar, sblabel, True, True, 0)
		Next
		
		' add to the window!
		gtk_box_pack_start(box, statusbar, False, True, 0)
	End Method

	Method addToolbar(_toolbar:TGTKToolbar)
		If toolbar <> Null Then
			toolbar.free()
		End If

		toolbar = _toolbar

		' add to the list
		gtk_box_pack_start(box, toolbar.handle, False, False, 0)

		' we need to move this to the correct place (usually under the menu)
		If menubar Then
			gtk_box_reorder_child(box, toolbar.handle, 1)
		Else
			gtk_box_reorder_child(box, toolbar.handle, 0)			
		End If

	End Method

	Method ClientHeight:Int()
?bmxng
		Local allocation:GtkAllocation
?Not bmxng
		Local allocation:GtkAllocation = New GtkAllocation
?

		gtk_widget_get_allocation(container, allocation)
		Local h:Int = allocation.height
		If h <= 8 Then
			h = height
?bmxng
			Local minReq:GtkRequisition 
			Local natReq:GtkRequisition
?Not bmxng
			Local minReq:GtkRequisition = New GtkRequisition
			Local natReq:GtkRequisition = New GtkRequisition
?

			If statusbar Then
				gtk_widget_get_preferred_size(statusbar, minReq, natReq)
				h:- natReq.height
			End If
			If menubar Then
				gtk_widget_get_preferred_size(menubar, minReq, natReq)
				h:- natReq.height
			End If

		End If

		If toolbar Then
			h:- toolbar.height
		End If
	
		Return h
	End Method

	Method ClientWidth:Int()

?bmxng
		Local allocation:GtkAllocation
?Not bmxng
		Local allocation:GtkAllocation = New GtkAllocation
?
		gtk_widget_get_allocation(handle, allocation)
		Local w:Int = allocation.width

		If w <= 8 Then
			w = width
		End If

		Return w
	End Method

	Rem
	bbdoc: Pop up a popup menu
	End Rem
	Method PopupMenu:Int(menu:TGadget,extra:Object=Null)
		If TGTKMenuItem(menu) Then
			If TGTKMenuItem(menu).popupMenu Then
				TGTKMenuItem(menu).popupExtra = extra
				gtk_menu_popup(TGTKMenuItem(menu).popupMenu, Null, Null, Null, Null, 0, gtk_get_current_event_time())
			End If
		End If
	End Method

	Method free:Int() Override
		Super.Free()

		If handle 
			gtk_widget_destroy(handle)
		EndIf
		handle = Null

		gtkWindows.remove(Self)
	End Method

	Method Activate:Int(cmd:Int)
		Super.Activate(cmd)
		
		If Not visible Return 0

		Select cmd
			Case ACTIVATE_MAXIMIZE
				gtk_window_maximize(handle)
			Case ACTIVATE_MINIMIZE
				gtk_window_iconify(handle)
			Case ACTIVATE_RESTORE
				' since we need to remember if we are maximized while being minimized
				' we check for minimized first...
				If _minimized Then
					gtk_window_deiconify(handle)
				Else If _maximized Then
					gtk_window_unmaximize(handle)
				End If
			Case ACTIVATE_FOCUS
				gtk_window_present(handle)
		End Select
	End Method
	
	Method SetMinimumSize:Int(w:Int, h:Int)
?bmxng
		Local geom:GdkGeometry
?Not bmxng
		Local geom:GdkGeometry = New GdkGeometry
?
		gtk_window_set_geometry_hints(handle, Null, geom, GDK_HINT_MIN_SIZE)
	End Method

	Rem
	bbdoc: Sets the window icon with the specified pixmap.
	End Rem
	Method setIcon(pix:TPixmap)
		If pix <> Null Then
			Local pixmap:TPixmap = pix.convert( PF_RGBA8888 )
			Local icon:Byte Ptr = gdk_pixbuf_new_from_data(pixmap.pixels, GDK_COLORSPACE_RGB, True, 8, ..
						pixmap.width, pixmap.height, pixmap.Pitch, Null, Null)
			gtk_window_set_icon(handle, icon)
		End If
	End Method
	
	Rem
	bbdoc: Returns the window state.
	End Rem
	Method State:Int()
		Local flags:Int = Super.state()
		
		' Note: you can be maximized and minimized at the same time, so that when
		' we un-maximize (de-conify) it goes back to maximized.
		' not sure if we should set them both in this instance. "Not" at the moment...
		If _minimized Then
			flags:| STATE_MINIMIZED
		Else If _maximized Then
			flags:| STATE_MAXIMIZED
		End If
		
		Return flags
	End Method

	Method SetText:Int(text:String)
		Local textPtr:Byte Ptr = text.ToUTF8String()
		gtk_window_set_title(handle, textPtr)
		MemFree(textPtr)
	End Method
	
	Method GetText:String()
		Return String.FromUTF8String(gtk_window_get_title(handle))
	End Method

	Method toString:String()
		Return "TGTKWindow"
	End Method
End Type

Rem
bbdoc: A menu item.
End Rem
Type TGTKMenuItem Extends TGTKGadget
	
	Field popupMenu:Byte Ptr

	Field tag:Int = 0
	Field ignoreSelection:Int
	Field isCheckable:Int
	Field hasMnemonic:Int
	Field isSeparator:Int
	Field checked:Int
	Field text:String
	Field index:Int
	Field isStockItem:Int
	
	Global popupExtra:Object

	' we use these to remember keycode and modifier just in case we need to make this
	' menu item a check-type - in which case we delete and create a new one.
	Field myKeycode:Int
	Field myModifier:Int
	
	Field windowAccelGroup:Byte Ptr
	
	Field pixmap:TPixmap
	Field imagePixbuf:Byte Ptr
	Field image:Byte Ptr
	
	Function CreateMenuItem:TGTKMenuItem(label:String, tag:Int, parent:TGadget)
		Local this:TGTKMenuItem = New TGTKMenuItem

		this.initMenu(label, tag, parent)

		Return this
	End Function

	Method initMenu(_label:String, _tag:Int, _parent:TGadget)
		iclass = GTK_MENUITEM
		tag = _tag
		
		Local originalLabel:String = _label

		If TGTKWindow(_parent) Then
			windowAccelGroup = TGTKWindow(_parent).accelGroup
		Else If TGTKMenuItem(_parent)
			windowAccelGroup = TGTKMenuItem(_parent).windowAccelGroup
		Else
			'Throw "menu item has no valid parent"
			' A popupmenu... perhaps?
			windowAccelGroup = Null
		End If

		' localisation
		If (LocalizationMode() & LOCALIZATION_OVERRIDE) Then
			MapInsert maxgui_driver._mapLocalized, Self, [_label,""]
			_label = LocalizeString(_label)
		End If

		setAccelMapId(_label)


		' this is our menu item / text
		If _label = Null Or _label.length = 0 Then
			' a separator
			handle = gtk_separator_menu_item_new()
			isSeparator = True
		Else
	
			' convert underscores to doubles
			'_label = _label.replace("_", "__")

			' a normal menu item
			' Does it have a 
			Local p:Int = _label.find("&")

			_label = processText(_label)
			Local _labelPtr:Byte Ptr = _label.ToUTF8String()
			
			' does this label have a mnemonic?
			If p >= 0 Then
				'_label = _label.replace("&", "_")
				hasMnemonic = True

				handle = gtk_menu_item_new_with_mnemonic(_labelPtr)

			Else

				handle = gtk_menu_item_new_with_label(_labelPtr)

			End If
			MemFree(_labelPtr)
		End If

		text = _label

		' let's hope that at least the parent is set!!
		If _parent Then

			parent = _parent

			If TGTKWindow(parent) Then

				Assert TGTKWindow(parent).menubar, "Cannot add menu to window created without WINDOW_MENU"

				' add a new menu for the menubar
				' Note : we never show this!! (on purpose)
				menu = gtk_menu_new()

				' attach the menu text to the menu
				gtk_menu_item_set_submenu(handle, menu)

				' add the menu to the menubar
				' Need to make sure we have a menubar to add it to...
				' In debug mode we'll have failed the above assertion already.
				If TGTKWindow(parent).menubar Then
					gtk_menu_shell_append(TGTKWindow(parent).menubar, handle)
				End If

			Else If TGTKMenuItem(parent) Then

				If TGTKMenuItem(parent).popupMenu Then
					gtk_container_add(TGTKMenuItem(parent).popupMenu, handle)
				Else
					' we may need to create a sub menu to hold this!
					If Not TGTKMenuItem(parent).menu Then
						TGTKMenuItem(parent).menu = gtk_menu_new()
	
						' attach the menu text to the menu
						gtk_menu_item_set_submenu(TGTKMenuItem(parent).handle, TGTKMenuItem(parent).menu)
	
					End If
	
					gtk_menu_shell_append(TGTKMenuItem(parent).menu, handle)
					
				End If
				' we need to know our position in the menu
				index = parent.kids.count()
			End If

			gtk_widget_show(handle)

			' Add an activate signal and store ourself in the menu data
			If Not TGTKWindow(parent) And Not isSeparator Then
				addConnection("activate", g_signal_cb2_ret(handle, "activate", MenuSelected, Self, Destroy, 0))
				g_object_set_data(handle, "_maxmenu", Self)
			End If
		Else ' popupmenu...
			popupMenu = gtk_menu_new()

			' don't add OUR menu item to the list, as it is only a place holder.
			'gtk_container_add(popupMenu, handle)

			gtk_widget_show(handle)
		End If

	End Method

	Method SetHotKey:Int(keycode:Int, modifier:Int)
		myKeycode = keycode
		myModifier = modifier
		
		setAccelEntry(keycode, modifier)
		
		' override F10 menu access?
		If keycode = KEY_F10 And modifier = 0 Then
			Local settings:Byte Ptr = gtk_settings_get_default()
			gtk_settings_set_string_property(settings, "gtk-menu-bar-accel", "<alt>F10", AppFile)
		End If
	End Method

	Rem
	bbdoc: Callback function for selecting a menu option.
	about: Triggers a menu action event.<br>
	NOTE - We have to ignore "obj" because it is not reliable
	End Rem
	Function MenuSelected:Int(widget:Byte Ptr, obj:Object)

		Local _menu:TGTKMenuItem = g_object_get_menudata(widget, "_maxmenu")

		Assert _menu, "Menu data is missing...  !!!!"

		' If this isn't a submenu root (one which has sub menus)
		' then we can post the event
		If Not _menu.menu And Not _menu.ignoreSelection Then
			PostGuiEvent(EVENT_MENUACTION, _menu, _menu.tag,,,,_menu.popupextra)
			If _menu.popupExtra Then
				_menu.popupExtra = Null
			End If
		End If

		' We need to keep the "checked" flag uptodate...
		If _menu.isCheckable Then
			_menu.checked = gtk_check_menu_item_get_active(widget)
		End If
		
		_menu.ignoreSelection = False

		Return True

	End Function

	Method SetSelected:Int(bool:Int)

		' Don't do anything if we are already set...
		If (checked = bool) And isCheckable Then
			Return 0
		End If

		ignoreSelection = True

		' if it's not checkable yet, we need to make it so
		If Not isCheckable And Not isSeparator And menu = Null Then
			' remove the current menu
			If handle Then
				gtk_widget_destroy(handle)
				hasAccel = False
			End If

			Local textPtr:Byte Ptr = text.ToUtf8String()
			If hasMnemonic Then
				handle = gtk_check_menu_item_new_with_mnemonic(textPtr)
			Else
				handle = gtk_check_menu_item_new_with_label(textPtr)
			End If
			MemFree(textPtr)
			gtk_widget_show(handle)

			' if we originally gave this a keycode / modifier, we need to re-establish it.
			If myKeycode <> 0 Then
				SetHotKey(myKeycode, myModifier)
			End If

			If TGTKWindow(parent) Then
				' Only insert if menubar exists tho...
				If TGTKWindow(parent).menubar Then
					gtk_menu_shell_insert(TGTKWindow(parent).menubar, handle, index)
				End If
			Else If TGTKMenuItem(parent) Then
				If TGTKMenuItem(parent).menu Then
					gtk_menu_shell_insert(TGTKMenuItem(parent).menu, handle, index)
				End If
			EndIf

			' we need to catch toggles!
			addConnection("toggled", g_signal_cb2_ret(handle, "toggled", MenuSelected, Self, Destroy, 0))
			g_object_set_data(handle, "_maxmenu", Self)

			isCheckable = True

			' If we are not setting it checked it won't generate a toggle event...
			If Not bool Then
				ignoreSelection = False
			End If
		End If

		checked = bool

		gtk_check_menu_item_set_active(handle, checked)
	End Method

	Rem
	bbdoc: Returns menu state - checked or unchecked
	End Rem
	Method State:Int()
		Local _state:Int = Super.State()
	
		If isCheckable Then
			If gtk_check_menu_item_get_active(handle) Then
				_state :| STATE_SELECTED
			End If
		End If

		Return _state
	End Method

	Rem
	bbdoc: Returns the menu text
	End Rem
	Method GetText:String()
		If Not isSeparator Then
			Return String.FromUTF8String(gtk_label_get_text(gtk_bin_get_child(handle)))
		End If

		Return ""
	End Method

	Rem
	bbdoc: Sets the menu text
	End Rem
	Method SetText:Int(label:String)
		If Not isSeparator Then
			If label = Null Then
				label = ""
			End If
			
			text = processText(label)

			Local labelPtr:Byte Ptr = text.ToUTF8String()
			If label.find("&") >= 0 Then
				gtk_label_set_text_with_mnemonic(gtk_bin_get_child(handle), labelPtr)
			Else
				gtk_label_set_text(gtk_bin_get_child(handle), labelPtr)
			End If
			MemFree(labelPtr)
		End If
	End Method
	
	Method free:Int() Override
		Local _handle:Byte Ptr = handle

		Super.Free()

		If _handle
			gtk_widget_destroy(_handle)
		End If
		menu = Null

		If pixmap Then
			pixmap = Null
		End If
		If image Then
		'	g_object_unref(image) ' oops.. TODO: we might need this still.
			image = Null
		End If
		If imagePixbuf Then
			g_object_unref(imagePixbuf)
			imagePixbuf = Null
		End If

	End Method

	Method rethink:Int()
	End Method

	Method DoLayout:Int()
	End Method

	Method SetPixmap:Int(pix:TPixmap, flags:Int)
		If Not isSeparator Then
			If pix Then
				If PixmapFormat(pix) <> PF_RGBA8888 And PixmapFormat(pix) <> PF_BGRA8888 Then
					pixmap = pix.convert( PF_RGBA8888 )
				Else
					pixmap = pix
				End If
				
				If imagePixbuf Then
					g_object_unref(imagePixbuf)
				End If
	
				imagePixbuf = gdk_pixbuf_new_from_data(pixmap.pixels, GDK_COLORSPACE_RGB, True, 8, ..
								pixmap.width, pixmap.height, pixmap.Pitch, Null, Null)
				
				If Not image Then
					image = gtk_image_new()
				End If

				gtk_image_set_from_pixbuf(image, imagePixbuf)
			Else
				If pixmap Then
					gtk_image_clear(image)
					pixmap = Null
				End If
			End If
			
			If image Then
				' TODO
				'gtk_image_menu_item_set_image(handle, image)
			End If
		End If
	End Method

	Method toString:String()
		Return "TGTKMenuItem : " + text + " : " + Super.ToString()
	End Method

	Method SetEnabled:Int(bool:Int)
		gtk_widget_set_sensitive(handle, bool)
	End Method

End Type

Type TGTKIconStrip Extends TIconStrip

	Field images:Byte Ptr[]
	Field names:String[]

	Function IsNotBlank:Int(pixmap:TPixmap)
		Local w:Int = pixmap.width
		Local h:Int = pixmap.height
		Local c:Int = pixmap.ReadPixel(0,0) 			
		For Local x:Int = 0 Until h
			For Local y:Int = 0 Until h
				If pixmap.ReadPixel(x,y) <> c Then
					Return True
				End If
			Next
		Next
	End Function
	
	Function Create:TGTKIconStrip(source:Object)
	
		Local baseName:String = MilliSecs()
	
		Local pix:TPixmap = TPixmap(source)
		If Not pix Then
			pix = LoadPixmap(source)

			If Not pix Then
				Return Null
			End If
		End If
		Local n:Int = pix.width/pix.height
		If n = 0 Then
			Return Null
		End If

		Local pixmap:TPixmap = pix.convert( PF_RGBA8888 )

		Local icons:TGTKIconStrip = New TGTKIconStrip
		icons.pixmap=pixmap
		icons.count=n
		icons.images=New Byte Ptr[n]
		icons.names = New String[n]

		Local h:Int = pixmap.height
		Local w:Int = h

		For Local x:Int = 0 Until n
			Local winpix:TPixmap = pixmap.Window(x*w,0,w,pixmap.height)
			If IsNotBlank(winpix) Then
				icons.images[x]= gdk_pixbuf_new_from_data(winpix.pixels, GDK_COLORSPACE_RGB, True, 8, ..
						w, h, pixmap.Pitch, Null, Null)
				Local name:String = baseName + "_" + x
				icons.names[x] = name
				gtk_icon_theme_add_builtin_icon(name, h, icons.images[x])
			End If
		Next
		Return icons
	End Function

End Type

Rem
bbdoc: Base type for button gadgets.
End Rem
Type TGTKButton Extends TGTKGadget

	Field hotkey:THotKey

	Field ignoreButtonClick:Int

	Method makeButton(label:String) Abstract

	Method initButton(x:Int, y:Int, w:Int, h:Int, label:String, group:TGadget, style:Int)
		
		Init(iclass, x, y, w, h, style)

		parent = group

		' localisation
		If (LocalizationMode() & LOCALIZATION_OVERRIDE) Then
			MapInsert maxgui_driver._mapLocalized, Self, [label,""]
			label = LocalizeString(label)
		End If

		makeButton(label)

		setAccelMapId(label)

		gtk_layout_put(TGTKContainer(parent).container, handle, x, y)
		gtk_widget_set_size_request(handle, w, Max(h,0))

		sensitivity:| SENSITIZE_MOUSE
		
		' Set as default ?
		If style = BUTTON_OK Then
			gtk_widget_grab_default(handle)
		End If

		setShow(True)

		' button clicked handler
		addConnection("clicked", g_signal_cb2(handle, "clicked", OnButtonClicked, Self, Destroy, 0))
		' catch right-mouse buttons
		addConnection("button-press-event", g_signal_cb3_ret(handle, "button-press-event", OnMouseDown, Self, Destroy, 0))

		addConnection("enter-notify-event", g_signal_cb3_ret(handle, "enter-notify-event", OnMouseEnter, Self, Destroy, 0))
		addConnection("leave-notify-event", g_signal_cb3_ret(handle, "leave-notify-event", OnMouseLeave, Self, Destroy, 0))

	End Method

	Rem
	bbdoc: Callback for button click.
	End Rem
	Function OnButtonClicked(widget:Byte Ptr, obj:Object)
		If Not TGTKButton(obj).ignoreButtonClick Then
			PostGuiEvent(EVENT_GADGETACTION, TGadget(obj), ButtonState(TGadget(obj)))
		End If
		
		TGTKButton(obj).ignoreButtonClick = False
	End Function

	Function OnMouseDown:Int(widget:Byte Ptr, event:Byte Ptr, obj:Object)
		Local x:Double, y:Double, button:Int
		bmx_gtk3maxgui_gdkeventbutton(event, Varptr x, Varptr y, Varptr button)

		If button = 3 Then ' right mouse button

			PostGuiEvent(EVENT_GADGETMENU, TGadget(obj),,,x,y)

			Return True
		End If

		Return False
	End Function

	Function OnMouseEnter:Int(widget:Byte Ptr, event:Byte Ptr, obj:Object)
	
		If TGTKGadget(obj).visible Then
			PostGuiEvent(EVENT_MOUSEENTER, TGadget(obj))
		End If

		Return False
	End Function

	Function OnMouseLeave:Int(widget:Byte Ptr, event:Byte Ptr, obj:Object)

		If TGTKGadget(obj).visible Then
			PostGuiEvent(EVENT_MOUSELEAVE, TGadget(obj))
		End If

		Return False
	End Function

	Rem
	bbdoc: Sets the button text.
	End Rem
	Method SetText:Int(text:String)
		text = processText(text)

		Local textPtr:Byte Ptr = text.ToUTF8String()
		gtk_button_set_label(handle, textPtr)
		MemFree(textPtr)
		gtk_button_set_use_underline(handle, True)
	End Method

	Rem
	bbdoc: Returns the button text.
	End Rem
	Method GetText:String()
		Return String.FromUTF8String(gtk_button_get_label(handle))
	End Method

	Rem
	bbdoc: Sets the button text color.
	End Rem
	Method SetTextColor:Int(r:Int, g:Int, b:Int)
		Local color:GdkRGBA = New GdkRGBA(r / 255.0, g / 255.0, b / 255.0)
		
		Local buttonLabel:Byte Ptr = gtk_bin_get_child(handle)
		gtk_widget_override_color(buttonLabel, GTK_STATE_FLAG_NORMAL, color)
		gtk_widget_override_color(buttonLabel, GTK_STATE_FLAG_ACTIVE, color)
		gtk_widget_override_color(buttonLabel, GTK_STATE_FLAG_PRELIGHT, color)
	End Method

	Method free:Int() Override
		Super.Free()

		If handle 
			gtk_widget_destroy(handle)
		EndIf
		handle = Null

	End Method

	Rem
	bbdoc: Sets a hot key for the button.
	End Rem
	Method SetHotKey:Int(keycode:Int, modifier:Int)
		setAccelEntry(keycode, modifier)
	End Method

	Method toString:String()
		Return "TGTKButton"
	End Method
End Type

Rem
bbdoc: A push button
End Rem
Type TGTKButtonPush Extends TGTKButton

	Function CreateButton:TGTKButtonPush(x:Int, y:Int, w:Int, h:Int, label:String, group:TGadget, style:Int)
		Local this:TGTKButtonPush = New TGTKButtonPush

		this.initButton(x, y, w, h, label, group, style)

		Return this
	End Function

	Method makeButton(label:String)

		label = processText(label)
		
		Local labelPtr:Byte Ptr = label.ToUTF8String()
		handle = gtk_button_new_with_label(labelPtr)
		MemFree(labelPtr)
		gtk_button_set_use_underline(handle, True)

		' enable "default" gadget functionality
		g_object_set_int(handle, "can-default", True)
	End Method

	Method SetText:Int(text:String)
		text = processText(text)

		Local textPtr:Byte Ptr = text.ToUTF8String()
		gtk_button_set_label(handle, textPtr)
		MemFree(textPtr)
		gtk_button_set_use_underline(handle, True)
	End Method

	Method SetPixmap:Int(pix:TPixmap, flags:Int = 0)
		If pix Then
			Local pixmap:TPixmap
			If pix.format <> PF_RGBA8888 Then
				pixmap = pix.convert( PF_RGBA8888 )
			Else
				pixmap = pix
			End If
	
			Local image:Byte Ptr = gtk_image_new_from_pixbuf(gdk_pixbuf_new_from_data(pixmap.pixels, GDK_COLORSPACE_RGB, True, 8, ..
						pixmap.width, pixmap.height, pixmap.Pitch, Null, Null))
			If image Then
				gtk_button_set_image(handle, image)
				gtk_button_set_image_position(handle, GTK_POS_LEFT)
			End If
		End If
	End Method

	Method toString:String()
		Return "TGTKButtonPush"
	End Method

End Type

Rem
bbdoc: A button which has a toggle-type usage (radio / checkbox)
End Rem
Type TGTKToggleButton Extends TGTKButton

	Field isSelected:Int

	Method SetSelected:Int(bool:Int)
		If bool <> gtk_toggle_button_get_active(handle) Then
			ignoreButtonClick = True
		End If
		
		gtk_toggle_button_set_active(handle, bool)
		
		isSelected = bool
	End Method

	Method State:Int()
		Local flags:Int = Super.State()

		If gtk_toggle_button_get_active(handle) Then
			flags:|STATE_SELECTED
		End If

		Return flags
	End Method

	Rem
	bbdoc: Callback for button click.
	End Rem
	Function OnButtonClicked(widget:Byte Ptr, obj:Object)
		If Not TGTKButton(obj).ignoreButtonClick Then
			If TGTKToggleButton(obj).isSelected <> gtk_toggle_button_get_active(widget)
				PostGuiEvent(EVENT_GADGETACTION, TGadget(obj), ButtonState(TGadget(obj)))
			End If
			TGTKToggleButton(obj).isSelected = gtk_toggle_button_get_active(widget)
		End If
		
		TGTKButton(obj).ignoreButtonClick = False
	End Function

	Method disableEvents()
	End Method
	
	Method enableEvents()
	End Method
	
End Type

Rem
bbdoc: A radio button.
End Rem
Type TGTKButtonRadio Extends TGTKToggleButton

	Function CreateButton:TGTKButtonRadio(x:Int, y:Int, w:Int, h:Int, label:String, group:TGadget, style:Int)
		Local this:TGTKButtonRadio = New TGTKButtonRadio

		this.initButton(x, y, w, h, label, group, style)

		Return this
	End Function

	Method makeButton(label:String)
		Local _group:Byte Ptr = TGTKContainer(parent).radioGroup
		label = processText(label)

		Local labelPtr:Byte Ptr = label.ToUTF8String()
		If _group = Null Then
			handle = gtk_radio_button_new_with_label(Null, labelPtr)
			gtk_toggle_button_set_active(handle, True)
			isSelected = True
		Else
			handle = gtk_radio_button_new_with_label(_group, labelPtr)
		End If
		MemFree(labelPtr)
		
		' update the radiogroup, ready for a new radio button...
		TGTKContainer(parent).radioGroup = gtk_radio_button_get_group(handle)
		
		gtk_button_set_use_underline(handle, True)
		
		If style & BUTTON_PUSH Then
			gtk_toggle_button_set_mode(handle, False)
		End If
		
	End Method

	Method SetSelected:Int(bool:Int)
		disableEvents()
		
		gtk_toggle_button_set_active(handle, bool)
		
		enableEvents()
		
		isSelected = bool
	End Method

	Function OnButtonClicked(widget:Byte Ptr, obj:Object)
		TGTKToggleButton(obj).isSelected = gtk_toggle_button_get_active(widget)

		If TGTKToggleButton(obj).isSelected Then
			PostGuiEvent(EVENT_GADGETACTION, TGadget(obj), ButtonState(TGadget(obj)))
		End If
		
		TGTKButton(obj).ignoreButtonClick = False
	End Function

	Method disableEvents()
		For Local gadget:TGTKButtonRadio = EachIn parent.kids
			Local id:TGTKInteger = TGTKInteger(gadget.connectionMap.ValueForKey("clicked"))
			If id Then
				g_signal_handler_disconnect(gadget.handle, id.value)
			End If
		Next
	End Method
	
	Method enableEvents()
		For Local gadget:TGTKButtonRadio = EachIn parent.kids
			gadget.addConnection("clicked", g_signal_cb2(gadget.handle, "clicked", OnButtonClicked, gadget, Destroy, 0))
		Next
	End Method

	Method toString:String()
		Return "TGTKButtonRadio"
	End Method

End Type

Rem
bbdoc: A checkbox button
End Rem
Type TGTKButtonCheckbox Extends TGTKToggleButton

	Function CreateButton:TGTKButtonCheckbox(x:Int, y:Int, w:Int, h:Int, label:String, group:TGadget, style:Int)
		Local this:TGTKButtonCheckbox = New TGTKButtonCheckbox

		this.initButton(x, y, w, h, label, group, style)

		Return this
	End Function

	Method makeButton(label:String)
		label = processText(label)
		
		Local labelPtr:Byte Ptr = label.ToUTF8String()
		handle = gtk_check_button_new_with_label(labelPtr)
		MemFree(labelPtr)
		
		gtk_button_set_use_underline(handle, True)

		If style & BUTTON_PUSH Then
			gtk_toggle_button_set_mode(handle, False)
		End If

	End Method

	Method toString:String()
		Return "TGTKButtonCheckbox"
	End Method

End Type

Rem
bbdoc: A label.
End Rem
Type TGTKLabel Extends TGTKGadget

	' surrounding frame widget, if any
	Field frame:Byte Ptr
	Field hasFrame:Int
	Field isSeparator:Int
	Field ebox:Byte Ptr

	Function CreateLabel:TGTKLabel(x:Int, y:Int, w:Int, h:Int, label:String, group:TGadget, style:Int)
		Local this:TGTKLabel = New TGTKLabel

		this.initLabel(x, y, w, h, label, group, style)

		Return this
	End Function

	Method initLabel(x:Int, y:Int, w:Int, h:Int, label:String, group:TGadget, style:Int)
		Init(GTK_LABEL, x, y, w, h, style)

		If style & LABEL_FRAME And style & LABEL_SUNKENFRAME Then
			isSeparator = True
		End If

		If Not isSeparator Then
			Local labelPtr:Byte Ptr = label.ToUTF8String()
			handle = gtk_label_new(labelPtr)
			MemFree(labelPtr)

			If style & LABEL_RIGHT Then
				gtk_misc_set_alignment(handle, 1, 0.5)
			Else If style & LABEL_CENTER Then
				gtk_misc_set_alignment(handle, 0.5, 0.5)	
			Else
				gtk_misc_set_alignment(handle, 0, 0.5)	
			End If


			sensitivity:| SENSITIZE_MOUSE
			
			' since a Label can't accept events, we wrap it inside an event box which can
			ebox = gtk_event_box_new()
			gtk_event_box_set_visible_window(ebox, False)
			gtk_widget_add_events(ebox, GDK_BUTTON_PRESS_MASK | GDK_ENTER_NOTIFY_MASK | GDK_LEAVE_NOTIFY_MASK)
			
			addConnection("enter-notify-event", g_signal_cb3_ret(ebox, "enter-notify-event", OnMouseEnter, Self, Destroy, 0))
			addConnection("leave-notify-event", g_signal_cb3_ret(ebox, "leave-notify-event", OnMouseLeave, Self, Destroy, 0))
			addConnection("button-press-event", g_signal_cb3_ret(ebox, "button-press-event", OnMouseDown, Self, Destroy, 0))

			' show the box
			gtk_widget_show(ebox)
			' add the label to the eventbox
			gtk_container_add(ebox, handle)
			
			If (LocalizationMode() & LOCALIZATION_OVERRIDE) Then
				LocalizeGadget(Self, label)
			Else
				SetText(label)
			EndIf
		End If

		' Should we add a frame?
		If style & LABEL_FRAME Or style & LABEL_SUNKENFRAME Then

			hasFrame = True

			If isSeparator Then
				If w < h Then
					frame = gtk_separator_new(GTK_ORIENTATION_VERTICAL)
				Else
					frame = gtk_separator_new(GTK_ORIENTATION_HORIZONTAL)
				End If
				handle = frame
			Else
				frame = gtk_frame_new(Null)
				If style & LABEL_FRAME Then
					gtk_frame_set_shadow_type(frame, GTK_SHADOW_ETCHED_IN)
				Else
					gtk_frame_set_shadow_type(frame, GTK_SHADOW_IN)
				End If

				gtk_container_add(frame, ebox)

			End If

			gtk_layout_put(TGTKContainer(group).container, frame, x, y)
			gtk_widget_set_size_request(frame, w, Max(h,0))

		Else
			gtk_layout_put(TGTKContainer(group).container, ebox, x, y)
			gtk_widget_set_size_request(handle, w, Max(h,0))
		End If

		setShow(True)

	End Method

	Rem
	bbdoc: Show or Hide the label
	End Rem
	Method SetShow:Int(truefalse:Int)
		visible = truefalse
		mySetVisible = visible
		
		If hasFrame Then
			If truefalse Then
				gtk_widget_show(frame)
			Else
				gtk_widget_hide(frame)
			EndIf
		End If

		If Not isSeparator Then
			If truefalse Then
				gtk_widget_show(handle)
				gtk_widget_show(ebox)
			Else
				gtk_widget_hide(ebox)
			EndIf
		End If
	End Method

	Method SetText:Int(text:String)
		If Not isSeparator Then
			Local textPtr:Byte Ptr = text.ToUtf8String()
			gtk_label_set_text(handle, textPtr)
			MemFree(textPtr)
		End If
	End Method
	
	Method GetText:String()
		If Not isSeparator Then
			Return String.FromUTF8String(gtk_label_get_text(handle))
		End If
		Return Null
	End Method

	Method free:Int() Override
		Super.Free()

		If frame
			gtk_widget_destroy(frame)
		Else
			If ebox Then
				gtk_widget_destroy(ebox)
			End If
		EndIf
		handle = Null
		frame = Null
		ebox = Null

	End Method

	Method setToolTip:Int(tip:String)
	
		If Not isSeparator Then
			If tip And tip.length > 0 Then
				Local tipPtr:Byte Ptr = tip.ToUTF8String()
				gtk_widget_set_tooltip_text(ebox, tipPtr)
				MemFree(tipPtr)
			Else
				gtk_widget_set_has_tooltip(ebox, False)
			End If
		Else
			If tip And tip.length > 0 Then
				Local tipPtr:Byte Ptr = tip.ToUTF8String()
				gtk_widget_set_tooltip_text(handle, tipPtr)
				MemFree(tipPtr)
			Else
				gtk_widget_set_has_tooltip(handle, False)
			End If
		End If
	End Method

	Method Rethink:Int()
		If frame Then
			gtk_layout_move(TGTKContainer(parent).container, frame, Max(xpos, 0), Max(ypos, 0))
			gtk_widget_set_size_request(frame, Max(width,0), Max(height,0))
		Else If handle Then
			gtk_layout_move(TGTKContainer(parent).container, ebox, Max(xpos, 0), Max(ypos, 0))
			gtk_widget_set_size_request(handle, Max(width,0), Max(height,0))
		End If
	End Method

	Function OnMouseEnter:Int(widget:Byte Ptr, event:Byte Ptr, obj:Object)
	
		If TGTKGadget(obj).visible Then
			PostGuiEvent(EVENT_MOUSEENTER, TGadget(obj))
		End If
		
		Return False
	End Function

	Function OnMouseLeave:Int(widget:Byte Ptr, event:Byte Ptr, obj:Object)

		If TGTKGadget(obj).visible Then
			PostGuiEvent(EVENT_MOUSELEAVE, TGadget(obj))
		End If
		
		Return False
	End Function

	Rem
	bbdoc: Callback For mouse button press.
	End Rem
	Function OnMouseDown:Int(widget:Byte Ptr, event:Byte Ptr, obj:Object)
		Local x:Double, y:Double, button:Int
		bmx_gtk3maxgui_gdkeventbutton(event, Varptr x, Varptr y, Varptr button)
		
		If button = 3 Then ' right mouse button

			PostGuiEvent(EVENT_GADGETMENU, TGadget(obj),,,x,y)

		Else ' other mouse buttons
			If button = 2 Then
				button = 3
			End If

			PostGuiEvent(EVENT_MOUSEDOWN, TGadget(obj),button,,x,y)
		End If
		
		Return True
	End Function

	Rem
	bbdoc: Sets the label text color.
	End Rem
	Method SetTextColor:Int(r:Int, g:Int, b:Int)
		Local color:GdkRGBA = New GdkRGBA(r / 255.0, g / 255.0, b / 255.0)

		gtk_widget_override_color(handle, GTK_STATE_FLAG_NORMAL, color)

	End Method

	Method toString:String()
		Return "TGTKLabel"
	End Method
End Type


Rem
bbdoc: Base type for editable gadgets (textfield / textarea).
End Rem
Type TGTKEditable Extends TGTKGadget

	Field ignoreTextChange:Int

	Method Activate:Int(cmd:Int)
		Super.Activate(cmd)

	End Method

	Function OnTextChanged(widget:Byte Ptr, obj:Object)
		If Not TGTKEditable(obj).ignoreTextChange Then
			PostGuiEvent(EVENT_GADGETACTION, TGadget(obj))
		End If
		
		If TGTKEditable(obj).ignoreTextChange Then
			TGTKEditable(obj).ignoreTextChange:-1
		End If
	End Function

	' key handler stuff - filtering etc
	Function OnKeyDown:Int(widget:Byte Ptr, gdkEvent:Byte Ptr, obj:Object)
		Local source:TGTKEditable = TGTKEditable(obj)

		' only if we are using a filter...
		If source And source.eventfilter <> Null Then
			Local _key:Int, _mods:Int
			bmx_gtk3maxgui_gdkeventkey(gdkEvent, Varptr _key, Varptr _mods)
			Local key:Int = TGTKKeyMap.mapBack(_key)
			Local mods:Int = TGTKKeyMap.mapModifierBack(_mods)
			
			Local event:TEvent=HotKeyEvent( key,mods, Null )
			If event Then
				event.emit()
				Return True
			EndIf

			event = CreateEvent(EVENT_KEYDOWN, source, key, mods)
			
			If Not source.eventfilter(event, source.context) Then
				Return True
			End If

			Local char:Int = gdk_keyval_to_unicode(_key)
			' we sometimes get 0 from this function when key is valid... so set it to key just so that it has a value.
			If char = 0 And key <> 0 Then
				char = key
			End If

			event = CreateEvent(EVENT_KEYCHAR, source, char, mods)
			If Not source.eventfilter(event, source.context) Then
				Return True
			End If
		EndIf

		Return False
	End Function
End Type

Rem
bbdoc: A Text field.
End Rem
Type TGTKTextField Extends TGTKEditable

	Field isPassword:Int
	
	Function CreateTextField:TGTKTextField(x:Int, y:Int, w:Int, h:Int, label:String, group:TGadget, style:Int)
		Local this:TGTKTextField = New TGTKTextField

		this.initTextField(x, y, w, h, label, group, style)

		Return this
	End Function

	Method initTextField(x:Int, y:Int, w:Int, h:Int, label:String, group:TGadget, style:Int)

		handle = gtk_entry_new()

		Init(GTK_TEXTFIELD, x, y, w, h, style)

		If style Then
			isPassword = True

			gtk_entry_set_visibility(handle, False)
		End If

		' causes the default gadget to be activated when Enter is pressed inside this Text Field.
		g_object_set_int(handle, "activates-default", True)

		setShow(True)

		gtk_layout_put(TGTKContainer(group).container, handle, x, y)
		gtk_widget_set_size_request(handle, w, Max(h,0))


		' add callbacks
		addConnection("changed", g_signal_cb2(handle, "changed", OnTextChanged, Self, Destroy, 0))
		addConnection("key-press-event", g_signal_cb3_ret(handle, "key-press-event", OnKeyDown, Self, Destroy, 0))
		addConnection("focus-out-event", g_signal_cb3_ret(handle, "focus-out-event", OnFocusLost, Self, Destroy, 0))
		' catch right-mouse buttons
		addConnection("button-press-event", g_signal_cb3_ret(handle, "button-press-event", OnMouseDown, Self, Destroy, 0))

	End Method

	Rem
	bbdoc: Returns the textfield text.
	End Rem
	Method GetText:String()
		Return String.FromUTF8String(gtk_entry_get_text(handle))
	End Method

	Rem
	bbdoc: Sets the textfield text.
	End Rem
	Method SetText:Int(txt:String)
		If txt = Null
			txt = ""
		End If
		
		' when set to blank, it raises 2 change events?
		If txt = "" And GetText() <> "" Then
			ignoreTextChange:+1
		End If
		
		If txt <> GetText() Then
			ignoreTextChange:+1
		End If
		
		Local txtPtr:Byte Ptr = txt.ToUTF8String()
		gtk_entry_set_text(handle, txtPtr)
		MemFree(txtPtr)
	End Method

	Method free:Int() Override
		Super.Free()

		If handle 
			gtk_widget_destroy(handle)
		EndIf
		handle = Null

	End Method

	Method Activate:Int(cmd:Int)
		Super.Activate(cmd)

		Select cmd
			Case ACTIVATE_CUT
				gtk_editable_cut_clipboard(handle)
			Case ACTIVATE_COPY
				gtk_editable_copy_clipboard(handle)
			Case ACTIVATE_PASTE
				gtk_editable_paste_clipboard(handle)
		End Select
	End Method
	
	Function OnMouseDown:Int(widget:Byte Ptr, event:Byte Ptr, obj:Object)
		Local x:Double, y:Double, button:Int
		bmx_gtk3maxgui_gdkeventbutton(event, Varptr x, Varptr y, Varptr button)

		If button = 3 Then ' right mouse button

			PostGuiEvent(EVENT_GADGETMENU, TGadget(obj),,,x,y)

			Return True
		End If

		Return False
	End Function

	Method toString:String()
		Return "TGTKTextField"
	End Method

End Type

Rem
bbdoc: A base for list gadgets.
End Rem
Type TGTKList Extends TGTKGadget

	Field icons:TGTKIconStrip

	Field _store:Byte Ptr
	Field _selection:Byte Ptr
	' sometimes we need to ignore events because we made them ourselves - rather than the user selecting
	' something.
	Field ignoreListChangeEvent:Int

	Method SetIconStrip:Int(iconstrip:TIconStrip)
		icons = TGTKIconStrip(iconstrip)
	End Method

	Method populateListRow(index:Int, text:String, tip:String, icon:Int, iter:Byte Ptr)

		' need to put the string in a GValue for placing into the list
		Local _value:Byte Ptr = bmx_gtk3_gvalue_new(G_TYPE_STRING)
		'g_value_init(_value, G_TYPE_STRING)
		Local textPtr:Byte Ptr = text.ToUTF8String()
	  	g_value_set_string(_value, textPtr)
		MemFree(textPtr)
	
		' set the row value
		If TGTKListbox(Self) Or TGTKComboBox(Self) Then
			gtk_list_store_set_value(_store, iter, 1, _value)
		Else
			gtk_tree_store_set_value(_store, iter, 1, _value)
		End If
	
		' tidy up !
		g_value_unset(_value)


		Local image:Byte Ptr

		If icons And icon>=0 Then
			image = icons.images[icon]
		End If

		If image Then
			' Insert the appropriate icon

			g_value_init(_value, gdk_pixbuf_get_type())
		  	g_value_set_object(_value, image)
		
			' set the row value
			If TGTKListbox(Self) Or TGTKComboBox(Self) Then
				gtk_list_store_set_value(_store, iter, 0, _value)
			Else
				gtk_tree_store_set_value(_store, iter, 0, _value)
			End If
		
			' tidy up !
			g_value_unset(_value)
		Else
			' clear out an icon if one is present in this entry

			g_value_init(_value, gdk_pixbuf_get_type())
		  	g_value_set_object(_value, Null)
		
			' set the row value
			If TGTKListbox(Self) Or TGTKComboBox(Self) Then
				gtk_list_store_set_value(_store, iter, 0, _value)
			Else
				gtk_tree_store_set_value(_store, iter, 0, _value)
			End If
		
			' tidy up !
			g_value_unset(_value)
		End If

		bmx_gtk3_gvalue_free(_value)
		
	End Method

	Method initColumns()
		' add a column to the list :
		Local col:Byte Ptr = gtk_tree_view_column_new()

		' pack column into list 
		gtk_tree_view_append_column(handle, col)

		Local pixRenderer:Byte Ptr = gtk_cell_renderer_pixbuf_new()
		Local textRenderer:Byte Ptr = gtk_cell_renderer_text_new()

		' pack cell renderers into column
		gtk_tree_view_column_pack_start(col, pixRenderer, False)
		gtk_tree_view_column_pack_end(col, textRenderer, True)

		gtk_tree_view_column_add_attribute(col, pixRenderer, "pixbuf", 0)
		gtk_tree_view_column_add_attribute(col, textRenderer, "text", 1)
	End Method

	Function OnSelectionChanged(_sel:Byte Ptr, obj:Object) Abstract

End Type

Rem
bbdoc: A combo box
End Rem
Type TGTKComboBox Extends TGTKList

	Field isEditable:Int

	Function CreateComboBox:TGTKComboBox(x:Int, y:Int, w:Int, h:Int, label:String, group:TGadget, style:Int)
		Local this:TGTKComboBox = New TGTKComboBox

		this.initComboBox(x, y, w, h, label, group, style)

		Return this
	End Function

	Method initComboBox(x:Int, y:Int, w:Int, h:Int, label:String, group:TGadget, style:Int)

		If style = COMBOBOX_EDITABLE Then
			isEditable = True
			handle = gtk_combo_box_new_with_entry()
		Else
			handle = gtk_combo_box_new()
		End If

		Init(GTK_COMBOBOX, x, y, w, h, style)
		
		' Create a list store of pixbuf and string (the two displayable columns)
		_store = gtk_list_store_new(2, gdk_pixbuf_get_type(), G_TYPE_STRING)

		gtk_combo_box_set_model(handle, _store)
		
		' for editable, we need to tell it which column contains the text part
		If isEditable Then
			gtk_combo_box_set_entry_text_column(handle, 1)
		End If
		initColumns()

		setShow(True)

		gtk_layout_put(TGTKContainer(group).container, handle, x, y)
		gtk_widget_set_size_request(handle, w, Max(h,0))
		
		addConnection("changed", g_signal_cb2(handle, "changed", OnSelectionChanged, Self, Destroy, 0))
		' catch right-mouse buttons
		addConnection("button-press-event", g_signal_cb3_ret(handle, "button-press-event", OnMouseDown, Self, Destroy, 0))

	End Method
	
	Method initColumns()
		gtk_cell_layout_clear(handle)

		Local pixRenderer:Byte Ptr = gtk_cell_renderer_pixbuf_new()
		Local textRenderer:Byte Ptr = gtk_cell_renderer_text_new()

		' pack cell renderers into layout
		gtk_cell_layout_pack_start(handle, pixRenderer, False)
		gtk_cell_layout_pack_end(handle, textRenderer, True)

		gtk_cell_layout_add_attribute(handle, pixRenderer, "pixbuf", 0)
		gtk_cell_layout_add_attribute(handle, textRenderer, "text", 1)

	End Method

	Rem
	bbdoc: Callback for selection change.
	End Rem
	Function OnSelectionChanged(widget:Byte Ptr, obj:Object)
		Local row:Int = TGTKComboBox(obj).SelectedItem()
		PostGuiEvent(EVENT_GADGETACTION, TGadget(obj), row,,,,TGadget(obj).ItemExtra(row))
	End Function

	Function OnMouseDown:Int(widget:Byte Ptr, event:Byte Ptr, obj:Object)
		Local x:Double, y:Double, button:Int
		bmx_gtk3maxgui_gdkeventbutton(event, Varptr x, Varptr y, Varptr button)

		If button = 3 Then ' right mouse button

			Local treePath:Byte Ptr
			Local row:Int = TGTKComboBox(obj).SelectedItem()
			
			If row >= 0 Then
				PostGuiEvent(EVENT_GADGETMENU, TGadget(obj),row,,x,y,TGTKList(obj).items[row].extra)
			Else
				PostGuiEvent(EVENT_GADGETMENU, TGadget(obj),row,,x,y)
			End If
			Return True
		End If

		Return False
	End Function
	
	Method InsertListItem:Int(index:Int, text:String, tip:String, icon:Int, tag:Object)
		Local iter:Byte Ptr = bmx_gtk3_gtktreeiter_new()

		gtk_list_store_insert(_store, iter, index)

		populateListRow(index, text, tip, icon, iter)
		bmx_gtk3_gtktreeiter_free(iter)
	End Method

	Method SetListItem:Int(index:Int, text:String, tip:String, icon:Int, tag:Object)
		Local iter:Byte Ptr = bmx_gtk3_gtktreeiter_new()
		Local found:Int = gtk_tree_model_iter_nth_child(_store, iter, Null, index)

		If found Then
			populateListRow(index, text, tip, icon, iter)
		End If
		bmx_gtk3_gtktreeiter_free(iter)
	End Method

	Method SelectedItem:Int()
		Return gtk_combo_box_get_active(handle)
	End Method

	Method SetListItemState:Int(index:Int ,state:Int)
		If state & STATE_SELECTED Then
			gtk_combo_box_set_active(handle, index)
		End If
	End Method

	Method ClearListItems:Int()
		gtk_list_store_clear(_store)
	End Method

	Method RemoveListItem:Int(index:Int)
		Local iter:Byte Ptr = bmx_gtk3_gtktreeiter_new()
		Local found:Int = gtk_tree_model_iter_nth_child(_store, iter, Null, index)
		
		If found Then
			gtk_list_store_remove(_store, iter)
		End If
		bmx_gtk3_gtktreeiter_free(iter)
	End Method

	Method ItemText:String(index:Int)
		If index < 0 Or index >= items.length Then
			Return GetText()
		End If
		Return items[index].text
	End Method

	Method GetText:String()
			Local st:String
			Local iter:Byte Ptr = bmx_gtk3_gtktreeiter_new()
			Local found:Int = gtk_combo_box_get_active_iter(handle, iter)
			
			If found Then
				Local _value:Byte Ptr = bmx_gtk3_gvalue_new(G_TYPE_STRING)
				
				gtk_tree_model_get_value(_store, iter, 0, _value)
				
				st = String.FromUTF8String(g_value_get_string(_value))
				
				' tidy up !
				g_value_unset(_value)

				bmx_gtk3_gvalue_free(_value)
			End If
			
			Return st
	End Method

	Method free:Int() Override
		Super.Free()

		If handle 
			gtk_widget_destroy(handle)
		EndIf
		handle = Null
	End Method

	Method toString:String()
		Return "TGTKComboBox"
	End Method

End Type

Rem
bbdoc: A scrollable list.
End Rem
Type TGTKListWithScrollWindow Extends TGTKList

	Field scrollWindow:Byte Ptr

	Method Init(GadgetClass:Int, x:Int, y:Int, w:Int, h:Int, style:Int)
		Super.init(iclass, x, y, w, h, style)
	
		handle = gtk_tree_view_new()
		gtk_tree_view_set_headers_visible(handle, False)

		' a reference to the selection object
		_selection = gtk_tree_view_get_selection(handle)

		' currently we only support SINGLE row selection
		gtk_tree_selection_set_mode(_selection, GTK_SELECTION_SINGLE)


		scrollWindow = gtk_scrolled_window_new(Null, Null)
		' set container resize mode
		gtk_container_set_resize_mode(scrollWindow, GTK_RESIZE_QUEUE)
		' set scrollbar policy
		gtk_scrolled_window_set_policy(scrollWindow, GTK_POLICY_AUTOMATIC, GTK_POLICY_AUTOMATIC)
		' show
		gtk_widget_show(scrollWindow)

		' add the html view to the scroll view
		gtk_container_add(scrollWindow, handle)


		' add callback
		addConnection("changed", g_signal_cb2(_selection, "changed", OnSelectionChanged, Self, Destroy, 0))
		
		' catch right-mouse buttons
		addConnection("button-press-event", g_signal_cb3_ret(handle, "button-press-event", OnMouseDown, Self, Destroy, 0))
	End Method

	Method SetShow:Int(truefalse:Int)
		visible = truefalse
		mySetVisible = visible
		
		If truefalse Then
			gtk_widget_show(scrollWindow)
			gtk_widget_show(handle)
		Else
			gtk_widget_hide(scrollWindow)
			gtk_widget_hide(handle)
		EndIf

		UpdateChildVisibility()
	End Method

	Function OnMouseDown:Int(widget:Byte Ptr, event:Byte Ptr, obj:Object)
	End Function

End Type

Rem
bbdoc: List box
End Rem
Type TGTKListbox Extends TGTKListWithScrollWindow


	Field currentSelection:Int = -1

	Function CreateListBox:TGTKListbox(x:Int, y:Int, w:Int, h:Int, label:String, group:TGadget, style:Int)
		Local this:TGTKListbox = New TGTKListbox

		this.initListBox(x, y, w, h, label, group, style)

		Return this
	End Function

	Method initListBox(x:Int, y:Int, w:Int, h:Int, label:String, group:TGadget, style:Int)
		Init(GTK_LISTBOX, x, y, w, h, style)

		' had intended using GTK_TYPE_PIXBUF here but it's a different value every time!?!
		_store = gtk_list_store_new(2, gdk_pixbuf_get_type(), G_TYPE_STRING)

		initColumns()

		gtk_tree_view_set_model(handle, _store)

		' remove *our* reference to the store... when the list is destroyed this will be too
		g_object_unref(_store)

		addConnection("row-activated", g_signal_cb4(handle, "row-activated", OnRowActivated, Self, Destroy, 0))

		SetShow(True)

		gtk_layout_put(TGTKContainer(group).container, scrollwindow, x, y)
		gtk_widget_set_size_request(handle, w, Max(h,0))

	End Method

	Method InsertListItem:Int(index:Int, text:String, tip:String, icon:Int, extra:Object)
		Local iter:Byte Ptr = bmx_gtk3_gtktreeiter_new()

		gtk_list_store_insert(_store, iter, index)

		populateListRow(index, text, tip, icon, iter)
		bmx_gtk3_gtktreeiter_free(iter)
	End Method

	Method SetListItem:Int(index:Int, text:String, tip:String, icon:Int, tag:Object)
		Local iter:Byte Ptr = bmx_gtk3_gtktreeiter_new()
		Local found:Int = gtk_tree_model_iter_nth_child(_store, iter, Null, index)
		If found Then
			populateListRow(index, text, tip, icon, iter)
		End If
		bmx_gtk3_gtktreeiter_free(iter)
	End Method

	Rem
	bbdoc: Removes an item from the list at the given index
	End Rem
	Method RemoveListItem:Int(index:Int)
		Local iter:Byte Ptr = bmx_gtk3_gtktreeiter_new()
		Local found:Int = gtk_tree_model_iter_nth_child(_store, iter, Null, index)
		
		If found Then
			If gtk_tree_selection_iter_is_selected(_selection, iter) Then
				ignoreListChangeEvent = True
			End If
			gtk_list_store_remove(_store, iter)
		End If
		bmx_gtk3_gtktreeiter_free(iter)
	End Method

	Method SetListItemState:Int(index:Int, state:Int)
		Local iter:Byte Ptr = bmx_gtk3_gtktreeiter_new()

		Local found:Int = gtk_tree_model_iter_nth_child(_store, iter, Null, index)

		If found Then
			If state & STATE_SELECTED Then
				ignoreListChangeEvent = True
				gtk_tree_selection_select_iter(_selection, iter)
			Else
				If gtk_tree_selection_iter_is_selected(_selection, iter) Then
					ignoreListChangeEvent = True
				End If
					
				gtk_tree_selection_unselect_iter(_selection, iter)
			End If
		End If
		bmx_gtk3_gtktreeiter_free(iter)
	End Method

	Method ListItemState:Int(index:Int)
		Local state:Int = 0
		Local iter:Byte Ptr = bmx_gtk3_gtktreeiter_new()

		Local found:Int = gtk_tree_model_iter_nth_child(_store, iter, Null, index)

		If found Then
			If gtk_tree_selection_iter_is_selected(_selection, iter) Then
				state:| STATE_SELECTED
			End If
		End If

		bmx_gtk3_gtktreeiter_free(iter)
		Return state
	End Method

	Function OnSelectionChanged(_sel:Byte Ptr, obj:Object)
		Local iter:Byte Ptr = bmx_gtk3_gtktreeiter_new()

		Local row:Int = -1
		Local selected:Int = gtk_tree_selection_get_selected(_sel, Null, iter)
		If selected Then
			Local path:Byte Ptr = gtk_tree_model_get_string_from_iter(TGTKList(obj)._store, iter)
			row = String.fromCString(path).toInt()
			g_free(path)
		End If

		If TGTKListbox(obj).currentSelection <> row Then
		
			TGTKListbox(obj).currentSelection = row
			
			If Not TGTKList(obj).ignoreListChangeEvent Then
				PostGuiEvent(EVENT_GADGETSELECT, TGadget(obj), row,,,,TGadget(obj).ItemExtra(row))
			End If
		End If
		TGTKList(obj).ignoreListChangeEvent = False
		
		bmx_gtk3_gtktreeiter_free(iter)
	End Function

	Rem
	bbdoc: Callback for listbox activation (double-click).
	End Rem
	Function OnRowActivated(widget:Byte Ptr, treePath:Byte Ptr, treeviewColumn:Byte Ptr, obj:Object)
		Local p:Byte Ptr = gtk_tree_path_to_string(treePath)
		Local row:Int
		
		If p <> Null Then
			row = String.fromCString(p).toInt()
		End If

		' clean up mem
		g_free(p)

		If row >= 0 Then
			PostGuiEvent(EVENT_GADGETACTION, TGadget(obj),row ,,,,TGTKList(obj).items[row].extra)
		Else
			PostGuiEvent(EVENT_GADGETACTION, TGadget(obj), row)
		End If
	End Function

	Function OnMouseDown:Int(widget:Byte Ptr, event:Byte Ptr, obj:Object)
		Local x:Double, y:Double, button:Int
		bmx_gtk3maxgui_gdkeventbutton(event, Varptr x, Varptr y, Varptr button)

		If button = 3 Then ' right mouse button

			Local treePath:Byte Ptr
			Local row:Int = -1
			
		     ' Get tree path For row that was clicked
			If gtk_tree_view_get_path_at_pos(widget, Int(x), Int(y), Varptr treePath, Null, Null, Null) Then
				Local p:Byte Ptr = gtk_tree_path_to_string(treePath)

				
				If p <> Null Then
					row = String.fromCString(p).toInt()
				End If

				' clean up mem
				g_free(p)
				gtk_tree_path_free(treePath)
			End If
		
			If row >= 0 Then
				PostGuiEvent(EVENT_GADGETMENU, TGadget(obj),row,,x,y,TGTKList(obj).items[row].extra)
			Else
				PostGuiEvent(EVENT_GADGETMENU, TGadget(obj),row,,x,y)
			End If
			Return True
		End If

		Return False
	End Function
	
	Method ClearListItems:Int()
		If gtk_tree_selection_get_selected(_selection, Null, Null) Then
			ignoreListChangeEvent = True
		End If
		gtk_list_store_clear(_store)
	End Method

	Method rethink:Int()
		If handle Then
			gtk_layout_move(TGTKContainer(parent).container, scrollwindow, Max(xpos, 0), Max(ypos, 0))
			gtk_widget_set_size_request(scrollwindow, Max(width,0), Max(height,0))
		End If
	End Method

	Method free:Int() Override
		Super.free()

		' destroying the widget should destroy the handle (list) too.
		If scrollWindow Then
			gtk_widget_destroy(scrollWindow)
		End If
		
		scrollWindow = Null
		handle = Null

	End Method

	Method toString:String()
		Return "TGTKListbox"
	End Method

End Type

Rem
bbdoc: A node in the tree view.
End Rem
Type TGTKTreeViewNode Extends TGTKListWithScrollWindow

	' is this node the root node?
	Field isRoot:Int
	' internal representation of node position in the tree
	Field _path:String
	' direct access to the node in the tree
	Field myIter:Byte Ptr
	' icon to display for this node
	Field _icon:Int
	' flag to prevent non-user events from firing
	Field ignoreExpand:Int
	Field ignoreCollapse:Int
	' text of this node
	Field _text:String

	Function _createNode:TGTKTreeViewNode(parent:TGTKTreeViewNode, index:Int)
		Local this:TGTKTreeViewNode = New TGTKTreeViewNode

		this.kids = New TEList

		this.handle = parent.handle
		this._store = parent._store
		this._selection = parent._selection
		this.parent = parent
		this.icons = parent.icons

		this.myIter = bmx_gtk3_gtktreeiter_new()

		this.refreshPath(index)
		
		Return this
	End Function

	Method refreshPath(index:Int)
		Assert myIter, "Null Iterator!"
	
		If parent Then
			_path = TGTKTreeViewNode(parent)._path
			If TGTKTreeViewNode(parent)._path.length > 0 Then
				_path:+ ":"
			End If
		Else
			_path = ""
		End If
		_path:+ index

		gtk_tree_model_get_iter_from_string(_store, myIter, _path)
	End Method

	Method refreshChildPaths()
		Local i:Int = 0
		For Local child:TGTKTreeViewNode = EachIn kids
			child.refreshPath(i)
			child.refreshChildPaths()
			i:+ 1
		Next
	End Method

	Function OnSelectionChanged(_sel:Byte Ptr, obj:Object)
		Local iter:Byte Ptr = bmx_gtk3_gtktreeiter_new()
		Local node:TGTKTreeViewNode = Null
		Local selected:Int = gtk_tree_selection_get_selected(_sel, Null, iter)
		If selected Then
			Local p:Byte Ptr = gtk_tree_model_get_string_from_iter(TGTKList(obj)._store, iter)
			node = TGTKTreeViewNode(obj).findNodeFromPath(String.FromCString(p))
			g_free(p)
		End If

		If Not TGTKList(obj).ignoreListChangeEvent Then
			PostGuiEvent(EVENT_GADGETSELECT, TGadget(obj),,,,,node)
		End If
		TGTKList(obj).ignoreListChangeEvent = False
		bmx_gtk3_gtktreeiter_free(iter)
	End Function

	Rem
	bbdoc: Returns the root node for this tree
	End Rem
	Method RootNode:TGadget()
		If Not isRoot Then
			Return parent.RootNode()
		End If
		Return Self
	End Method

	Rem
	bbdoc: Inserts a new node as a child at the specified index.
	End Rem
	Method InsertNode:TGadget(index:Int, text:String, icon:Int)
		Local iter:Byte Ptr = bmx_gtk3_gtktreeiter_new()
		Local childNode:TGTKTreeViewNode

		' create a new row in the tree
		If isRoot Then
			If index < 0 Then
				gtk_tree_store_append(_store, iter, Null)
			Else
				gtk_tree_store_insert(_store, iter, Null, index)
			End If

		Else
			If index < 0 Then
				gtk_tree_store_append(_store, iter, myIter)
			Else
				gtk_tree_store_insert(_store, iter, myIter, index)
			End If
		End If

		' add the text / icon to the tree
		populateListRow(index, text, Null, icon, iter)

		' add the child to the parent kids
		If index < 0 Or index = CountKids() Then
			childNode = TGTKTreeViewNode._createNode(Self, CountKids())
			childNode._text = text
			kids.addLast(childNode)
		Else
			childNode = TGTKTreeViewNode._createNode(Self, index)
			childNode._text = text
			TEList(kids).insertElementAt(childNode, index)
			refreshChildPaths()
		End If

		childNode._icon = icon
		
		If (LocalizationMode() & LOCALIZATION_OVERRIDE) Then
			LocalizeGadget(childNode, text)
		Else
			childNode.SetText(text)
		EndIf

		bmx_gtk3_gtktreeiter_free(iter)
		Return childNode
	End Method

	Rem
	bbdoc: Changes the tree node text and icon
	End Rem
	Method ModifyNode:Int(text:String, icon:Int)
		' not allowed to modify the root node... quietly ignore the request.
		If isRoot Then
			Return 0
		End If

		_text = text
		populateListRow(-1, text, Null, icon, myIter)
	End Method

	Rem
	bbdoc: Returns the currently selected tree node or null if none selected
	End Rem
	Method SelectedNode:TGadget()

		Local iter:Byte Ptr = bmx_gtk3_gtktreeiter_new()
		If gtk_tree_selection_get_selected(_selection, Null, iter) Then
			Local path:Byte Ptr = gtk_tree_model_get_path(_store, iter)

			Local p:Byte Ptr = gtk_tree_path_to_string(path)
			Local node:TGTKTreeViewNode = findNodeFromPath(String.FromCString(p))

			g_free(p)
			gtk_tree_path_free(path)
			
			bmx_gtk3_gtktreeiter_free(iter)
			Return node
		End If

		bmx_gtk3_gtktreeiter_free(iter)
		Return Null
	End Method

	Rem
	bbdoc: Returns the number of child nodes
	End Rem
	Method CountKids:Int()
		Return kids.count()
	End Method

	Method free:Int() Override
		Super.free()

		If isRoot Then
			If scrollWindow Then
				gtk_widget_destroy(scrollWindow)
			End If

			scrollWindow = Null
			handle = Null
		Else
			' this should always be true... if not, we really want to throw an assertion.
			' Assert myIter, "Trying to Free() a node twice?"
			If myIter Then
				gtk_tree_store_remove(_store, myIter)
				bmx_gtk3_gtktreeiter_free(myIter)
				myIter = Null
				If parent Then
					TGTKTreeViewNode(parent).refreshChildPaths()
				End If
			End If
		End If
		
	End Method

	' search always begins from the tree root, so we only need to look through the 
	' children.. ie. downwards
	' TODO : make this more efficient...  we should be able to use the path to skip
	' searching of child nodes of nodes not in our path
	Method findNodeFromPath:TGTKTreeViewNode(lookup:String)
		If lookup = _path Then
			Return Self
		End If

		Local i:Int = 0
		For Local child:TGTKTreeViewNode = EachIn kids
			Local node:TGTKTreeViewNode = child.findNodeFromPath(lookup)
			If node Then
				Return node
			End If
		Next

		Return Null
	End Method

	Method Activate:Int(command:Int)
		Super.Activate(command)

		Select command
			Case ACTIVATE_EXPAND
				If _path <> Null And _path.length > 0 Then
					ignoreExpand = True
					' get the tree view
					Local _root:TGTKTreeViewNode = TGTKTreeViewNode(RootNode())
					' get this node path
					Local path:Byte Ptr = gtk_tree_path_new_from_string(_path)
	
					' expand the node
					gtk_tree_view_expand_row(_root.handle, path, False)
	
					' free stuff
					gtk_tree_path_free(path)
				End If
			Case ACTIVATE_COLLAPSE
				If _path <> Null And _path.length > 0 Then
					ignoreCollapse = True

					' get the tree view
					Local _root:TGTKTreeViewNode = TGTKTreeViewNode(RootNode())
					' get this node path
					Local path:Byte Ptr = gtk_tree_path_new_from_string(_path)
	
					' expand the node
					gtk_tree_view_collapse_row(_root.handle, path)
	
					' free stuff
					gtk_tree_path_free(path)
				End If
			Case ACTIVATE_SELECT
				If _path <> Null And _path.length > 0 Then
					' the tree view should ignore this selection...
					TGTKTreeViewNode(RootNode()).ignoreListChangeEvent = True
				
					' get this node path
					Local path:Byte Ptr = gtk_tree_path_new_from_string(_path)
					
					' set the new selection
					gtk_tree_selection_select_path(_selection, path)
					
					' free stuff
					gtk_tree_path_free(path)					
				End If
		End Select
	End Method
	
	Rem
	bbdoc: Returns the text for this node.
	End Rem
	Method GetText:String()
		Return _text
	End Method
	
	Rem
	bbdoc: Sets the text for this node.
	End Rem
	Method SetText:Int(text:String)
		ModifyNode(text, _icon)
	End Method

	Method toString:String()
		Return "TGTKTreeViewNode : " + _text + " : " + Super.ToString()
	End Method
	
End Type

Rem
bbdoc: A tree view.
End Rem
Type TGTKTreeView Extends TGTKTreeViewNode

	Function CreateTreeView:TGTKTreeView(x:Int, y:Int, w:Int, h:Int, label:String, group:TGadget, style:Int)
		Local this:TGTKTreeView = New TGTKTreeView

		this.initTreeView(x, y, w, h, label, group, style)

		Return this
	End Function

	Method initTreeView(x:Int, y:Int, w:Int, h:Int, label:String, group:TGadget, style:Int)
		Init(GTK_TREEVIEW, x, y, w, h, style)

		ignoreListChangeEvent = True
		
		kids = New TEList

		' create the tree store
		_store = gtk_tree_store_new(2, gdk_pixbuf_get_type(), G_TYPE_STRING)

		' set up the column contents
		initColumns()

		' attach store to the view
		gtk_tree_view_set_model(handle, _store)

		' remove *our* reference to the store... when the tree is destroyed this will be too
		g_object_unref(_store)

		SetShow(True)

		gtk_layout_put(TGTKContainer(group).container, scrollwindow, x, y)
		gtk_widget_set_size_request(handle, w, Max(h,0))


		addConnection("row-activated", g_signal_cb4(handle, "row-activated", OnRowActivated, Self, Destroy, 0))
		addConnection("row-expanded", g_signal_cb4(handle, "row-expanded", OnRowExpanded, Self, Destroy, 0))
		addConnection("row-collapsed", g_signal_cb4(handle, "row-collapsed", OnRowCollapsed, Self, Destroy, 0))

		isRoot = True
	End Method

	Rem
	bbdoc: Callback For tree-view node activation (Double-click).
	End Rem
	Function OnRowActivated(widget:Byte Ptr, treePath:Byte Ptr, treeviewColumn:Byte Ptr, obj:Object)
		Local p:Byte Ptr = gtk_tree_path_to_string(treePath)
		Local node:TGTKTreeViewNode = TGTKTreeViewNode(obj).findNodeFromPath(String.FromCString(p))

		' clean up mem
		g_free(p)

		PostGuiEvent(EVENT_GADGETACTION, TGadget(obj),,,,,node)
	End Function

	Rem
	bbdoc: Callback for tree-view node expand.
	End Rem
	Function OnRowExpanded(widget:Byte Ptr, treeIter:Byte Ptr, treePath:Byte Ptr, obj:Object)
		Local p:Byte Ptr = gtk_tree_path_to_string(treePath)
		Local node:TGTKTreeViewNode = TGTKTreeViewNode(obj).findNodeFromPath(String.FromCString(p))

		' clean up mem
		g_free(p)

		If Not node.ignoreExpand Then
			PostGuiEvent(EVENT_GADGETOPEN, TGadget(obj),,,,,node)
		End If

		node.ignoreExpand = False
	End Function

	Rem
	bbdoc: Callback for tree-view node collapse.
	End Rem
	Function OnRowCollapsed(widget:Byte Ptr, treeIter:Byte Ptr, treePath:Byte Ptr, obj:Object)
		Local p:Byte Ptr = gtk_tree_path_to_string(treePath)
		Local node:TGTKTreeViewNode = TGTKTreeViewNode(obj).findNodeFromPath(String.FromCString(p))

		' clean up mem
		g_free(p)

		If Not node.ignoreCollapse Then
			PostGuiEvent(EVENT_GADGETCLOSE, TGadget(obj),,,,,node)
		End If

		node.ignoreCollapse = False
	End Function

	Rem
	bbdoc: Callback for mouse right-click
	End Rem
	Function OnMouseDown:Int(widget:Byte Ptr, event:Byte Ptr, obj:Object)
		Local x:Double, y:Double, button:Int
		bmx_gtk3maxgui_gdkeventbutton(event, Varptr x, Varptr y, Varptr button)

		If button = 3 Then ' right mouse button
			
			Local node:TGTKTreeViewNode
			Local treePath:Byte Ptr
			
		     ' Get tree path For row that was clicked
			If gtk_tree_view_get_path_at_pos(widget, Int(x), Int(y), Varptr treePath, Null, Null, Null) Then
				Local p:Byte Ptr = gtk_tree_path_to_string(treePath)
				node = TGTKTreeViewNode(obj).findNodeFromPath(String.FromCString(p))
				
				' clean up mem
				g_free(p)
				gtk_tree_path_free(treePath)
			End If
		
			PostGuiEvent(EVENT_GADGETMENU, TGadget(obj),,,x,y,node)

			Return True
		End If

		Return False
	End Function
	
	' overriden - does nothing!!
	Method LayoutKids:Int()
	End Method

	Method rethink:Int()
		If handle Then
			gtk_layout_move(TGTKContainer(parent).container, scrollwindow, Max(xpos, 0), Max(ypos, 0))
			gtk_widget_set_size_request(scrollwindow, Max(width,0), Max(height,0))
		End If
	End Method

	Method toString:String()
		Return "TGTKTreeView"
	End Method

End Type

Rem
bbdoc: A base-type for handling slider / range gadgets - ScrollBar and TrackBar
End Rem
Type TGTKRange Extends TGTKGadget

	Field currentValue:Int
	Field rangeMin:Int
	Field rangeMax:Int

	Rem
	bbdoc: Sets the slider range.
	End Rem
	Method SetRange:Int(visible:Int, total:Int)
		rangeMin = Min(visible, total)
		rangeMax = Max(visible, total)
		gtk_range_set_range(handle, rangeMin, rangeMax)
	End Method

	Rem
	bbdoc: Sets the value on the slider.
	End Rem
	Method SetProp:Int(value:Int)
		currentValue = value
		gtk_range_set_value(handle, value)
	End Method

	Rem
	bbdoc: Returns the current slider value.
	End Rem
	Method GetProp:Int()
		Return gtk_range_get_value(handle)
	End Method

	Rem
	bbdoc: Callback for user changing of a slider.
	about: Tries to keep the value within the desired range.
	End Rem
	Function OnChangeValue:Int(widget:Byte Ptr, scrolltype:Int, value:Double, obj:Object)
		Local v:Int = Max(Min(value, TGTKRange(obj).rangeMax), TGTKRange(obj).rangeMin)
		If v <> TGTKRange(obj).currentValue Then
			TGTKRange(obj).currentValue = v
			PostGuiEvent(EVENT_GADGETACTION, TGadget(obj), v)
		End If

		Return False
	End Function
	
	Method free:Int() Override
		Super.Free()

		If handle 
			gtk_widget_destroy(handle)
		EndIf
		handle = Null
	End Method

	Method toString:String()
		Return "TGTKRange"
	End Method

End Type

Rem
bbdoc: A scrollbar
End Rem
Type TGTKScrollBar Extends TGTKRange

	Field thumbSize:Int
	Field Range:Int
	Field pageSize:Int

	Function CreateScrollBar:TGTKScrollBar(x:Int, y:Int, w:Int, h:Int, label:String, group:TGadget, style:Int)
		Local this:TGTKScrollBar = New TGTKScrollBar

		this.initScrollBar(x, y, w, h, label, group, style)

		Return this
	End Function

	Method initScrollBar(x:Int, y:Int, w:Int, h:Int, label:String, group:TGadget, style:Int)

		If style & SLIDER_VERTICAL Then
			handle = gtk_scrollbar_new(GTK_ORIENTATION_VERTICAL, Null)
		Else
			handle = gtk_scrollbar_new(GTK_ORIENTATION_HORIZONTAL, Null)
		End If

		Init(GTK_SCROLLBAR, x, y, w, h, style)

		' set the default range
		SetRange(1, 10)

		setShow(True)

		addConnection("change-value", g_signal_cb4a(handle, "change-value", OnChangeValue, Self, Destroy, 0))
		
		gtk_layout_put(TGTKContainer(group).container, handle, x, y)
		gtk_widget_set_size_request(handle, w, Max(h,0))
		gtk_range_set_round_digits(handle, 0)

	End Method

	Rem
	bbdoc: Overrides the default...
	End Rem
	Method SetRange:Int(small:Int, big:Int)

		Range = big - small
		pageSize = small
		
		If small <> 0 Then
			thumbSize = big/small
			thumbSize = range / thumbSize
		Else
			thumbSize = 1
		End If

		If Range = 0 Then
			Range = 1
			thumbSize = 1
		End If

	    gtk_adjustment_set_page_size(gtk_range_get_adjustment(handle), thumbSize)
	    gtk_range_set_increments(handle, 1, pageSize)
	    gtk_range_set_range(handle, 0, Range)
	    gtk_range_set_value(handle, GetProp())
	End Method

	Function OnChangeValue:Int(widget:Byte Ptr, scrolltype:Int, value:Double, obj:Object)
		Local v:Int = Min(TGTKScrollBar(obj).range, Max(value, 0))

		If v <> TGTKRange(obj).currentValue Then
			TGTKRange(obj).currentValue = v
			PostGuiEvent(EVENT_GADGETACTION, TGadget(obj), v)
		End If

		Return False
	End Function

	Method toString:String()
		Return "TGTKScrollBar"
	End Method

End Type

Rem
bbdoc: A trackbar
End Rem
Type TGTKTrackBar Extends TGTKRange

	Function CreateTrackBar:TGTKTrackBar(x:Int, y:Int, w:Int, h:Int, label:String, group:TGadget, style:Int)
		Local this:TGTKTrackBar = New TGTKTrackBar

		this.initTrackBar(x, y, w, h, label, group, style)

		Return this
	End Function

	Method initTrackBar(x:Int, y:Int, w:Int, h:Int, label:String, group:TGadget, style:Int)

		If style & SLIDER_VERTICAL Then
			handle = gtk_scale_new_with_range(GTK_ORIENTATION_VERTICAL, 1, 10, 1)
		Else
			handle = gtk_scale_new_with_range(GTK_ORIENTATION_HORIZONTAL, 1, 10, 1)
		End If

		Init(GTK_TRACKBAR, x, y, w, h, style)

		' set the default range
		SetRange(1,10)

		gtk_scale_set_draw_value(handle, False)

		setShow(True)
		
		addConnection("change-value", g_signal_cb4a(handle, "change-value", OnChangeValue, Self, Destroy, 0))

		gtk_layout_put(TGTKContainer(group).container, handle, x, y)
		gtk_widget_set_size_request(handle, w, Max(h,0))

	End Method

	Method toString:String()
		Return "TGTKTrackBar"
	End Method

End Type

Type TGTKStepper Extends TGTKGadget

	Function CreateStepper:TGTKStepper(x:Int, y:Int, w:Int, h:Int, label:String, group:TGadget, style:Int)
		Local this:TGTKStepper = New TGTKStepper

		this.initStepper(x, y, w, h, label, group, style)

		Return this
	End Function

	Method initStepper(x:Int, y:Int, w:Int, h:Int, label:String, group:TGadget, style:Int)
	
		handle = gtk_spin_button_new_with_range(1, 100, 1)
	
		Init(GTK_STEPPER, x, y, w, h, style)
		
		' init range..
		SetRange(1,100)
		gtk_spin_button_set_increments(handle, 1, 10)
		
		setShow(True)
		
		addConnection("change-value", g_signal_cb3a_ret(handle, "change-value", OnChangeValue, Self, Destroy, 0))

		gtk_layout_put(TGTKContainer(group).container, handle, x, y)
		gtk_widget_set_size_request(handle, w, Max(h,0))
	End Method

	Rem
	bbdoc: Sets the value on the slider.
	End Rem
	Method SetProp:Int(value:Int)
		'currentValue = value
		gtk_spin_button_set_value(handle, value)
	End Method

	Rem
	bbdoc: Returns the current slider value.
	End Rem
	Method GetProp:Int()
		Return gtk_spin_button_get_value(handle)
	End Method

	Rem
	bbdoc: Sets the slider range.
	End Rem
	Method SetRange:Int(visible:Int, total:Int)
		Local rangeMin:Int = Min(visible, total)
		Local rangeMax:Int = Max(visible, total)
		gtk_spin_button_set_range(handle, rangeMin, rangeMax)
	End Method

	Function OnChangeValue:Int(widget:Byte Ptr, scrolltype:Int, obj:Object)
		Local v:Int = gtk_spin_button_get_value(widget)

		PostGuiEvent(EVENT_GADGETACTION, TGadget(obj), v)

		Return False
	End Function

	Method toString:String()
		Return "TGTKStepper"
	End Method

End Type

Rem
bbdoc: A progress bar
about: Interestingly, although we can find out the current value, MaxGUI doesn't support it...
End Rem
Type TGTKProgressBar Extends TGTKGadget

	Field ebox:Byte Ptr

	Function CreateProgressBar:TGTKProgressBar(x:Int, y:Int, w:Int, h:Int, label:String, group:TGadget, style:Int)
		Local this:TGTKProgressBar = New TGTKProgressBar

		this.initProgressBar(x, y, w, h, label, group, style)

		Return this
	End Function

	Method initProgressBar(x:Int, y:Int, w:Int, h:Int, label:String, group:TGadget, style:Int)

		handle = gtk_progress_bar_new()
		
		Init(GTK_PROGRESSBAR, x, y, w, h, style)

		' required for tooltips functionality
		gtk_widget_add_events(handle, GDK_ENTER_NOTIFY_MASK | GDK_LEAVE_NOTIFY_MASK)

		setShow(True)

		gtk_layout_put(TGTKContainer(group).container, handle, x, y)
		gtk_widget_set_size_request(handle, w, Max(h,0))

	End Method

	Rem
	bbdoc: Set the value of the progress bar.
	End Rem
	Method SetValue:Int(value:Float)
		value = Min(Max(0, value), 1.0)
		gtk_progress_bar_set_fraction(handle, value)
	End Method
	
	Rem
	bbdoc: Get the current value of the progress bar
	End Rem
	Method GetValue:Float()
		Return gtk_progress_bar_get_fraction(handle)
	End Method
	
	Method free:Int() Override
		Super.Free()

		If handle
			gtk_widget_destroy(handle)
		EndIf
		handle = Null
	End Method

	Method toString:String()
		Return "TGTKProgressBar"
	End Method

End Type

Rem
bbdoc: A Toolbar
End Rem
Type TGTKToolbar Extends TGTKGadget

	Field icons:TGTKIconStrip
	Field toolitems:Byte Ptr[]

	Function CreateToolBar:TGTKToolbar(x:Int, y:Int, w:Int, h:Int, label:String, group:TGadget, style:Int)
		Local this:TGTKToolbar = New TGTKToolbar

		this.initToolbar(x, y, w, h, label, group, style)

		Return this
	End Function

	Method initToolbar(x:Int, y:Int, w:Int, h:Int, label:String, group:TGadget, style:Int)

		handle = gtk_toolbar_new()

		Init(GTK_TOOLBAR, x, y, w, h, style)

		If TGTKWindow(group) Then
			TGTKWindow(group).addToolbar(Self)
		End If

		' show icons only
		gtk_toolbar_set_style(handle, GTK_TOOLBAR_ICONS)

		gtk_widget_show(handle)
	End Method

	Method SetIconStrip:Int(iconstrip:TIconStrip)
		icons = TGTKIconStrip(iconstrip)
	End Method

	Rem
	bbdoc: Inserts an item at the specified index.
	End Rem
	Method InsertListItem:Int(index:Int, text:String, tip:String, icon:Int, extra:Object)
		Local image:Byte Ptr		

		If icons And icon>=0 Then
			image = icons.images[icon]
		End If

		toolitems = toolitems[..toolitems.length+1]
		For Local i:Int = toolitems.length - 2 To index Step -1
			toolitems[i + 1] = toolitems[i]
		Next

		If image Then
			Local imageWidget:Byte Ptr = gtk_image_new_from_pixbuf(image)
			gtk_widget_show(imageWidget)
	
			Local textPtr:Byte Ptr = text.ToUTF8String()
			If items[index].flags = GADGETITEM_TOGGLE Then
				toolitems[index] = gtk_toggle_tool_button_new()
				gtk_tool_button_set_label(toolitems[index], textPtr)
				gtk_tool_button_set_icon_name(toolitems[index], icons.names[icon])

				addConnection("toggled", g_signal_cb2(toolitems[index], "toggled", OnToolItemToggled, Self, Destroy, 0))
			Else
				toolitems[index] = gtk_tool_button_new(Null, textPtr)
				gtk_tool_button_set_label(toolitems[index], textPtr)
				gtk_tool_button_set_icon_name(toolitems[index], icons.names[icon])
				

				addConnection("clicked", g_signal_cb2(toolitems[index], "clicked", OnToolItemClicked, Self, Destroy, 0))
			End If
			MemFree(textPtr)

			' Add a tooltip
			SetToolTipIndex(index, tip)
		Else
			' no image? Then this is a separator!
			toolitems[index] = gtk_separator_tool_item_new()
		End If
		gtk_widget_show(toolitems[index])

		gtk_toolbar_insert(handle, toolitems[index], index)
	End Method

	Function OnToolItemToggled(widget:Byte Ptr, obj:Object)
		Local index:Int = gtk_toolbar_get_item_index(TGTKToolbar(obj).handle, widget)
		PostGuiEvent(EVENT_GADGETACTION, TGadget(obj), index, gtk_toggle_tool_button_get_active(widget))
	End Function

	Function OnToolItemClicked(widget:Byte Ptr, obj:Object)
		Local index:Int = gtk_toolbar_get_item_index(TGTKToolbar(obj).handle, widget)
		PostGuiEvent(EVENT_GADGETACTION, TGadget(obj), index)
	End Function

	Method SetListItem:Int(index:Int, text:String, tip:String, icon:Int, extra:Object)

		If toolitems[index] Then
			gtk_container_remove(handle, toolitems[index])

			For Local i:Int = index Until toolitems.length - 1
				toolitems[i] = toolitems[i + 1]
			Next
			toolitems = toolitems[..toolitems.length - 1]
		End If

		InsertListItem(index, text, tip, icon, extra)
	End Method

	Method SetToolTipIndex:Int(index:Int, tip:String)
		' Add a tooltip
		If tip And tip.length > 0 Then
			Local tipPtr:Byte Ptr = tip.ToUTF8String()
			gtk_tool_item_set_tooltip_text(toolitems[index], tipPtr)
			MemFree(tipPtr)
		Else
			gtk_tool_item_set_tooltip_text(toolitems[index], Null)
		End If		
	End Method

	Method SetListItemState:Int(item:Int, state:Int)
		If state & STATE_DISABLED Then
			gtk_widget_set_sensitive(toolitems[item], False)
		Else
			gtk_widget_set_sensitive(toolitems[item], True)
		End If

		If items[item].flags = GADGETITEM_TOGGLE Then
			If state & STATE_SELECTED Then
				gtk_toggle_tool_button_set_active(toolitems[item], True)
			Else
				gtk_toggle_tool_button_set_active(toolitems[item], False)
			End If
		End If
		
		gtk_widget_queue_draw(handle)
	End Method

	Method ListItemState:Int(index:Int)
		Local state:Int = 0

		If Not gtk_widget_is_sensitive(toolitems[index]) Then
			state:| STATE_DISABLED
		End If

		If items[index].flags = GADGETITEM_TOGGLE Then
			If gtk_toggle_tool_button_get_active(toolitems[index]) Then
				state:| STATE_SELECTED
			End If
		End If

		Return state
	End Method

	Method RemoveListItem:Int(index:Int)
		If toolitems[index] Then
			gtk_container_remove(handle, toolitems[index])

			For Local i:Int = index Until toolitems.length - 1
				toolitems[i] = toolitems[i + 1]
			Next
			toolitems = toolitems[..toolitems.length - 1]
		End If
	End Method

	Method rethink:Int()
	End Method

	Method free:Int() Override
		Super.Free()

		If handle
			gtk_widget_destroy(handle)
			
			' assuming that destroying the toolbar will destroy 
			For Local i:Int = 0 Until toolitems.length
				toolitems[i] = Null
			Next
		EndIf
		handle = Null
	End Method

	Method toString:String()
		Return "TGTKToolbar"
	End Method

End Type

Rem
bbdoc: A tabber.
End Rem
Type TGTKTabber Extends TGTKContainer

	Field icons:TGTKIconStrip
	Field images:Byte Ptr[]
	Field labels:Byte Ptr[]
	Field pages:Byte Ptr[]
	Field ignoreChange:Int
	Field currentIndex:Int = -1

	Function CreateTabber:TGTKTabber(x:Int, y:Int, w:Int, h:Int, label:String, group:TGadget, style:Int)
		Local this:TGTKTabber = New TGTKTabber

		this.initTabber(x, y, w, h, label, group, style)

		Return this
	End Function

	Method initTabber(x:Int, y:Int, w:Int, h:Int, label:String, group:TGadget, style:Int)

		handle = gtk_notebook_new()

		Init(GTK_TABBER, x, y, w, h, style)

		container = gtk_layout_new(Null, Null)
		gtk_widget_show(container)
		g_object_ref(container) ' hold an extra ref for our container

		' Scrollable tabs if there are too many to fit on the display
		gtk_notebook_set_scrollable(handle, True)

		gtk_widget_show(handle)

		g_signal_tabchange(handle, "switch-page", OnTabChanged, Self, Destroy, 0)

		gtk_layout_put(TGTKContainer(group).container, handle, x, y)
		gtk_widget_set_size_request(handle, w, Max(h,0))

	End Method

	Function OnTabChanged(widget:Byte Ptr, page:Byte Ptr, index:Int, obj:Object)
		If TGTKTabber(obj).currentIndex >= 0 Then
			Local child:Byte Ptr = gtk_notebook_get_nth_page(TGTKTabber(obj).handle, TGTKTabber(obj).currentIndex)
			TGTKTabber(obj).RemoveFromTab(child)
		End If
		
		If index >= 0 Then
			TGTKTabber(obj).AddToTab(page)
		End If
		TGTKTabber(obj).currentIndex = index

		If Not TGTKTabber(obj).ignoreChange Then
			PostGuiEvent(EVENT_GADGETACTION, TGadget(obj), index,,,,TGadget(obj).ItemExtra(index))
		End If
		TGTKTabber(obj).ignoreChange = False
	End Function

	Rem
	bbdoc: Inserts a new tab
	End Rem
	Method InsertListItem:Int(index:Int, text:String, tip:String, icon:Int, tag:Object)

		' don't create gui events when inserting new pages.
		ignoreChange = True
		
		Local image:Byte Ptr

		If icons And icon>=0 Then
			image = icons.images[icon]
		End If

		images = images[..images.length+1]
		For Local i:Int = images.length - 2 To index Step -1
			images[i + 1] = images[i]
		Next

		labels = labels[..labels.length+1]
		For Local i:Int = labels.length - 2 To index Step -1
			labels[i + 1] = labels[i]
		Next
		
		pages = pages[..pages.length+1]
		For Local i:Int = pages.length - 2 To index Step -1
			pages[i + 1] = pages[i]
		Next

		If image Then
			images[index] = gtk_image_new_from_pixbuf(image)
			gtk_widget_show(images[index])
		Else
			images[index] = gtk_image_new()
		End If

		' since a Label can't accept events, we wrap it inside an event box which can
		Local box:Byte Ptr = gtk_event_box_new()
		gtk_event_box_set_visible_window(box, False)
		gtk_widget_add_events(box, GDK_ENTER_NOTIFY_MASK | GDK_LEAVE_NOTIFY_MASK)
		' show the box
		gtk_widget_show(box)
	
		' create a display label for the tab
		Local textPtr:Byte Ptr = text.ToUTF8String()
		labels[index] = gtk_label_new(textPtr)
		MemFree(textPtr)
		gtk_widget_show(labels[index])
		
		' create a horizontal box to place the image/label combo
		Local hbox:Byte Ptr = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 4)
		gtk_widget_show(hbox)
		
		' add widgets to the hbox
		gtk_box_pack_start(hbox, images[index], False, False, 0)
		gtk_box_pack_start(hbox, labels[index], False, False, 0)
		
		' add the hbox to the eventbox
		gtk_container_add(box, hbox)

		' create a child to hold our container.
		Local child:Byte Ptr = gtk_box_new(GTK_ORIENTATION_VERTICAL, 0)
		pages[index] = child
		gtk_widget_show(child)

		gtk_notebook_insert_page(handle, child, box, index)

		' Add a tooltip to the event box
		SetToolTipIndex(index, tip, box)
	End Method

	Method SetListItem:Int(index:Int, text:String, tip:String, icon:Int, tag:Object)
		Local child:Byte Ptr = gtk_notebook_get_nth_page(handle, index)
		
		' get the event box to which we set tooltips
		Local box:Byte Ptr = gtk_notebook_get_tab_label(handle, child)

		' is there an image to show?
		Local image:Byte Ptr
		If icons And icon>=0 Then
			image = icons.images[icon]
		End If

		If Not image Then
			' hide image if none
			gtk_widget_hide(images[index])
		Else
			' set and display image
			gtk_image_set_from_pixbuf(images[index], image)
			gtk_widget_show(images[index])
		End If

		' set new text
		Local textPtr:Byte Ptr = text.ToUTF8String()
		gtk_label_set_text(labels[index], textPtr)
		MemFree(textPtr)
		
		' Add a tooltip to the event box
		SetToolTipIndex(index, tip, box)
	End Method

	Method RemoveListItem:Int(index:Int)
		Local arr:Byte Ptr[] = images
		images = images[..images.length-1]
		For Local i:Int = index To arr.length-2
			images[i] = arr[i+1]
		Next

		arr = labels
		labels = labels[..labels.length-1]
		For Local i:Int = index To arr.length-2
			labels[i] = arr[i+1]
		Next

		arr = pages
		pages = pages[..pages.length-1]
		For Local i:Int = index To arr.length-2
			pages[i] = arr[i+1]
		Next

		' remove from current tab if required
		If gtk_notebook_get_current_page(handle) = index Then
			Local child:Byte Ptr = gtk_notebook_get_nth_page(handle, index)
			RemoveFromTab(child)
			currentIndex = -1
		Else If index < currentIndex Then
			currentIndex :- 1
		End If
		
		gtk_notebook_remove_page(handle, index)
		
	End Method

	Method ListItemState:Int(index:Int)
		Local state:Int = 0

		If gtk_notebook_get_current_page(handle) = index Then
			state:| STATE_SELECTED
		End If

		Return state
	End Method

	Method SetListItemState:Int(index:Int, state:Int)
		If state & STATE_SELECTED Then
			If gtk_notebook_get_current_page(handle) <> index Then
				ignoreChange = True
?bmxng
				IWrappedSystemDriver(SystemDriver()).GetDriver().Poll()
?Not bmxng
				brl.System.Driver.Poll() ' update events
?
				gtk_notebook_set_current_page(handle, index)
			End If
		End If
	End Method

	Method ClientHeight:Int()
		Local h:Int = height

		If handle Then
?bmxng
			Local minReq:GtkRequisition 
			Local natReq:GtkRequisition
?Not bmxng
			Local minReq:GtkRequisition = New GtkRequisition
			Local natReq:GtkRequisition = New GtkRequisition
?
			gtk_widget_get_preferred_size(handle, minReq, natReq)

			h :- 34 ' FIXME : current hard-coded. Should be height of notebook less tab height and border.

		End If

		Return Max(0, h)
	End Method

	Method ClientWidth:Int()
		Local w:Int = width

		If handle Then
?bmxng
			Local minReq:GtkRequisition 
			Local natReq:GtkRequisition
?Not bmxng
			Local minReq:GtkRequisition = New GtkRequisition
			Local natReq:GtkRequisition = New GtkRequisition
?
			gtk_widget_get_preferred_size(handle, minReq, natReq)
			w:- 4 ' FIXME : current hard-coded. Should be width of notebook less borders.
		End If

		Return Max(0, w)
	End Method

	Method SetToolTipIndex:Int(index:Int, tip:String, label:Byte Ptr)
		' Add a tooltip
		If tip And tip.length > 0 Then
			Local tipPtr:Byte Ptr = tip.ToUTF8String()
			gtk_widget_set_tooltip_text(label, tipPtr)
			MemFree(tipPtr)
		Else
			gtk_widget_set_tooltip_text(label, Null)
		End If		
	End Method

	Method SetIconStrip:Int(iconstrip:TIconStrip)
		icons = TGTKIconStrip(iconstrip)
	End Method

	Method free:Int() Override
		Super.Free()
		
		If container Then
			gtk_widget_destroy(container)
			container = Null
		End If

		handle = Null
		images = Null
		labels = Null
	End Method

	Method Rethink:Int()
		If handle Then
			gtk_layout_move(TGTKContainer(parent).container, handle, xpos, ypos)
			gtk_widget_set_size_request(handle, Max(width,0), Max(height,0))
		End If
	End Method

	Method toString:String()
		Return "TGTKTabber"
	End Method
	
	Method RemoveFromTab(page:Byte Ptr)
		If currentIndex >= 0 Then
			g_object_ref(container)
			gtk_container_remove(page, container)
		End If
	End Method

	Method AddToTab(page:Byte Ptr)
		gtk_box_pack_start(page, container, True, True, 0)
		g_object_unref(container)
	End Method

End Type

Rem
bbdoc: A Panel
End Rem
Type TGTKPanel Extends TGTKContainer

	Field frame:Byte Ptr
	Field hasFrame:Int
	Field panelPixmap:TPixmap
	Field panelPixbuf:Byte Ptr
	Field pixmapMode:Int
	
	Field drawPixbuf:Int
	Field visualpixbuf:Byte Ptr
	Field pbx:Int
	Field pby:Int
	
	Field pane:Int

	Function CreatePanel:TGTKPanel(x:Int, y:Int, w:Int, h:Int, label:String, group:TGadget, style:Int, intoPane:Int = 0)
		Local this:TGTKPanel = New TGTKPanel

		this.initPanel(x, y, w, h, label, group, style, intoPane)

		Return this
	End Function

	Method initPanel(x:Int, y:Int, w:Int, h:Int, label:String, group:TGadget, style:Int, intoPane:Int)

		handle = gtk_layout_new(Null, Null)

		Init(GTK_PANEL, x, y, w, h, style)

		container = handle
		
		If style & PANEL_ACTIVE
			sensitivity:| SENSITIZE_MOUSE | SENSITIZE_KEYS
		End If

		gtk_widget_add_events(handle, GDK_BUTTON_PRESS_MASK | ..
			GDK_BUTTON_RELEASE_MASK | GDK_ENTER_NOTIFY_MASK | GDK_LEAVE_NOTIFY_MASK | ..
			GDK_KEY_PRESS_MASK | GDK_KEY_RELEASE_MASK | GDK_POINTER_MOTION_MASK | GDK_SCROLL_MASK)' | ..
'				GDK_POINTER_MOTION_HINT_MASK)

		addConnection("button-press-event", g_signal_cb3_ret(handle, "button-press-event", OnMouseDown, Self, Destroy, 0))
		addConnection("button-release-event", g_signal_cb3_ret(handle, "button-release-event", OnMouseUp, Self, Destroy, 0))
		addConnection("enter-notify-event", g_signal_cb3_ret(handle, "enter-notify-event", OnMouseEnter, Self, Destroy, 0))
		addConnection("leave-notify-event", g_signal_cb3_ret(handle, "leave-notify-event", OnMouseLeave, Self, Destroy, 0))
		addConnection("motion-notify-event", g_signal_cb3_ret(handle, "motion-notify-event", OnMouseMove, Self, Destroy, 0))
		addConnection("draw", g_signal_cb3_ret(handle, "draw", OnDraw, Self, Destroy, 0))
		addConnection("scroll-event", g_signal_cb3(handle, "scroll-event", OnScroll, Self, Destroy, 0))

		addConnection("key-press-event", g_signal_cb3_ret(handle, "key-press-event", OnKeyDown, Self, Destroy, 0))
		addConnection("key-release-event", g_signal_cb3_ret(handle, "key-release-event", OnKeyUp, Self, Destroy, 0))

		gtk_widget_show(handle)

		' Should we add a frame?
		If style & PANEL_BORDER Or style & PANEL_GROUP Then

			hasFrame = True

			frame = gtk_frame_new(Null)
			gtk_widget_show(frame)

			' set frame text
			If (LocalizationMode() & LOCALIZATION_OVERRIDE) Then
				LocalizeGadget(Self, label)
			Else
				SetText(label)
			EndIf
			
			gtk_container_add(frame, handle)

			gtk_layout_put(TGTKContainer(group).container, frame, x, y)
			gtk_widget_set_size_request(frame, w, Max(h,0))

		Else

			gtk_layout_put(TGTKContainer(group).container, handle, x, y)
			gtk_widget_set_size_request(handle, w, Max(h,0))

		End If

	End Method

	Rem
	bbdoc: Callback for mouse button press.
	End Rem
	Function OnMouseDown:Int(widget:Byte Ptr, event:Byte Ptr, obj:Object)
		If TGTKPanel(obj).style & PANEL_ACTIVE Then
			Local x:Double, y:Double, button:Int
			bmx_gtk3maxgui_gdkeventbutton(event, Varptr x, Varptr y, Varptr button)

			If button = 3 Then
				button = 2
			Else If button = 2 Then
				button = 3
			End If

			PostGuiEvent(EVENT_MOUSEDOWN, TGadget(obj),button,,x,y)
		End If
		Return True
	End Function

	Rem
	bbdoc: Callback for mouse button release.
	End Rem
	Function OnMouseUp:Int(widget:Byte Ptr, event:Byte Ptr, obj:Object)
		If TGTKPanel(obj).style & PANEL_ACTIVE Then
			Local x:Double, y:Double, button:Int
			bmx_gtk3maxgui_gdkeventbutton(event, Varptr x, Varptr y, Varptr button)

			If button = 3 Then
				button = 2
			Else If button = 2 Then
				button = 3
			End If
			
			PostGuiEvent(EVENT_MOUSEUP, TGadget(obj),button,,x,y)
		End If
		Return True
	End Function

	Rem
	bbdoc: Callback for mouse enter.
	End Rem
	Function OnMouseEnter:Int(widget:Byte Ptr, event:Byte Ptr, obj:Object)
		If TGTKPanel(obj).style & PANEL_ACTIVE Then
			If TGTKGadget(obj).visible Then
				PostGuiEvent(EVENT_MOUSEENTER, TGadget(obj))
			End If
		End If
		Return False
	End Function

	Rem
	bbdoc: Callback for mouse leave.
	End Rem
	Function OnMouseLeave:Int(widget:Byte Ptr, event:Byte Ptr, obj:Object)
		If TGTKPanel(obj).style & PANEL_ACTIVE Then
			If TGTKGadget(obj).visible Then
				PostGuiEvent(EVENT_MOUSELEAVE, TGadget(obj))
			End If
		End If
		Return False
	End Function

	Rem
	bbdoc: Callback for mouse movement
	End Rem
	Function OnMouseMove:Int(widget:Byte Ptr, event:Byte Ptr, obj:Object)
		If TGTKPanel(obj).style & PANEL_ACTIVE Then
			Local _x:Double, _y:Double, button:Int
			bmx_gtk3maxgui_gdkeventmotion(event, Varptr _x, Varptr _y, Varptr button)
			Local x:Int, y:Int
			
			' we actually ignore the coords returned by the event and get the
			' mouse coords relative to this widget's parent
			gdk_window_get_device_position(gtk_widget_get_parent_window(widget), bmx_gtk3maxgui_gdkeventmotiondevice(event), x, y, button)

			' then we remove the stored coords from that value to get the TRUE coords.
			x:- TGTKPanel(obj).xpos
			y:- TGTKPanel(obj).ypos
			
			If button & GDK_BUTTON1_MASK Then
				button = 1
			Else If button & GDK_BUTTON3_MASK Then
				button = 2
			Else If button & GDK_BUTTON2_MASK Then
				button = 3
			Else
				button = 0
			End If
			PostGuiEvent(EVENT_MOUSEMOVE, TGadget(obj),button,,x,y)
		End If
		Return True
	End Function

	Function OnDraw:Int(widget:Byte Ptr, cairo:Byte Ptr, obj:Object)
		Local panel:TGTKPanel = TGTKPanel(obj)
		If panel Then
			If panel.drawPixbuf And panel.visualpixbuf Then
				gdk_cairo_set_source_pixbuf(cairo, panel.visualpixbuf, panel.pbx, panel.pby)
				cairo_paint(cairo)
				cairo_fill(cairo)
			End If
		End If
		PostGuiEvent(EVENT_GADGETPAINT, TGadget(obj))
	End Function
	
	Rem
	bbdoc: Callback for mouse scroll wheel
	End Rem
	Function OnScroll(widget:Byte Ptr, event:Byte Ptr, obj:Object)
		If TGTKPanel(obj).style & PANEL_ACTIVE Then
			Local x:Double, y:Double, direction:Int
			bmx_gtk3maxgui_gdkeventscroll(event, Varptr x, Varptr y, Varptr direction)

			If direction = GDK_SCROLL_UP Or direction = GDK_SCROLL_LEFT Then
				PostGuiEvent(EVENT_MOUSEWHEEL, TGadget(obj),-1,,x,y)
			Else
				PostGuiEvent(EVENT_MOUSEWHEEL, TGadget(obj),1,,x,y)
			End If
		End If
	End Function

	Rem
	bbdoc: Callback for key down
	End Rem
	Function OnKeyDown:Int(widget:Byte Ptr, event:Byte Ptr, obj:Object)
		If TGTKPanel(obj).style & PANEL_ACTIVE Then
			Local _key:Int, _mods:Int
			bmx_gtk3maxgui_gdkeventkey(event, Varptr _key, Varptr _mods)
			Local key:Int = TGTKKeyMap.mapBack(_key)
			Local mods:Int = TGTKKeyMap.mapModifierBack(_mods)
	
			If Not gtk3SetKeyDown(key) Then
				PostGuiEvent(EVENT_KEYDOWN, TGadget(obj), key, mods)
			Else
				PostGuiEvent(EVENT_KEYREPEAT, TGadget(obj), key, mods)
			End If

			Local char:Int = gdk_keyval_to_unicode(_key)
			' we sometimes get 0 from this function when key is valid... so set it to key just so that it has a value.
			If char = 0 And key <> 0 Then
				char = key
			End If
			PostGuiEvent(EVENT_KEYCHAR, TGadget(obj), char, mods)
	
			Return True
		End If
	End Function

	Rem
	bbdoc: Callback for key up
	End Rem
	Function OnKeyUp:Int(widget:Byte Ptr, event:Byte Ptr, obj:Object)
		If TGTKPanel(obj).style & PANEL_ACTIVE Then
			Local _key:Int, _mods:Int
			bmx_gtk3maxgui_gdkeventkey(event, Varptr _key, Varptr _mods)
			Local key:Int = TGTKKeyMap.mapBack(_key)
			Local mods:Int = TGTKKeyMap.mapModifierBack(_mods)
			
			gtk3SetKeyUp(key)
			PostGuiEvent(EVENT_KEYUP, TGadget(obj), key, mods)
	
			Return True
		End If
	End Function

	Rem
	bbdoc: Sets the text of a group panel.
	End Rem
	Method SetText:Int(text:String)
		If style & PANEL_GROUP Then
			If text = Null Or text.length = 0 Then
				gtk_frame_set_label(frame, Null)
			Else
				Local textPtr:Byte Ptr = text.ToUTF8String()
				gtk_frame_set_label(frame, textPtr)
				MemFree(textPtr)
			End If
		End If
	End Method

	Rem
	bbdoc: Shows or hides a panel
	End Rem
	Method SetShow:Int(truefalse:Int)
		visible = truefalse
		mySetVisible = visible
		
		If truefalse Then
			If frame Then
				gtk_widget_show(frame)
			Else
				gtk_widget_show(handle)
			End If
		Else
			If frame Then
				gtk_widget_hide(frame)
			Else
				gtk_widget_hide(handle)
			End If
		EndIf

		UpdateChildVisibility()
	End Method

	Method free:Int() Override
		Super.Free()

		If frame Then
			gtk_widget_destroy(frame)
		Else
			If handle Then
				gtk_widget_destroy(handle)
			End If
		End If
		
		container = Null
		handle = Null
		frame = Null
		
		If panelpixmap Then
			panelpixmap = Null
		End If
		If panelPixbuf Then
			g_object_unref(panelPixbuf)
			panelPixbuf = Null
		End If
	End Method

	Rem
	bbdoc: Set the panel color.
	End Rem
	Method SetColor:Int(r:Int, g:Int, b:Int)
		Local color:GdkRGBA = New GdkRGBA(r / 255.0, g / 255.0, b / 255.0)
		gtk_widget_override_background_color(handle, GTK_STATE_FLAG_NORMAL, color)
	End Method

	Rem
	bbdoc: Set the panel pixmap.
	End Rem
	Method SetPixmap:Int(pixmap:TPixmap, flags:Int)
		pixmapMode = flags
		
		If pixmap Then
			If PixmapFormat(pixmap) <> PF_RGBA8888 And PixmapFormat(pixmap) <> PF_BGRA8888 Then
				panelPixmap = pixmap.convert( PF_RGBA8888 )
			Else
				panelPixmap = pixmap
			End If
			
			If panelPixbuf Then
				g_object_unref(panelPixbuf)
			End If

			panelPixbuf = gdk_pixbuf_new_from_data(panelPixmap.pixels, GDK_COLORSPACE_RGB, True, 8, ..
							panelPixmap.width, panelPixmap.height, panelPixmap.Pitch, Null, Null)
		Else
			If panelPixmap Then
				panelPixmap = Null
			End If
		End If
		redraw()
	End Method
	
	Method rethink:Int()
		If frame Then
			gtk_layout_move(TGTKContainer(parent).container, frame, xpos, ypos)
			gtk_widget_set_size_request(frame, Max(width,0), Max(height,0))
		Else If handle Then
			gtk_layout_move(TGTKContainer(parent).container, handle, xpos, ypos)
			gtk_widget_set_size_request(handle, Max(width,0), Max(height,0))
		End If
		redraw()
	End Method

	Method redraw()

		If Not panelPixmap Then
			If panelPixbuf Then
				g_object_unref(panelPixbuf)
				panelPixbuf = Null
			End If
			If visualpixbuf Then
				g_object_unref(visualpixbuf)
				visualpixbuf = Null
				' make the panel redraw itself
				gtk_widget_queue_draw(handle)
			End If
		End If
		
		If panelPixbuf Then
			
			If visualpixbuf Then
				g_object_unref(visualpixbuf)
			End If
			Select pixmapMode & (PANELPIXMAP_TILE | PANELPIXMAP_CENTER | PANELPIXMAP_FIT | PANELPIXMAP_FIT2 | PANELPIXMAP_STRETCH)
				Case PANELPIXMAP_TILE

					pbx = 0
					pby = 0

					Local w:Float = width
					Local h:Float = height

					Local wfull:Int = w / panelPixmap.width
					Local hfull:Int = h / panelPixmap.height
					
					Local wpart:Int = w Mod panelPixmap.width
					Local hpart:Int = h Mod panelPixmap.height
					
					visualpixbuf = gdk_pixbuf_new(GDK_COLORSPACE_RGB, True, 8, Int(w), Int(h))
					
					For Local x:Int = 0 Until wfull
					
						For Local y:Int = 0 Until hfull
							gdk_pixbuf_copy_area(panelPixbuf, 0, 0, panelPixmap.width, panelPixmap.height, visualpixbuf, x * panelPixmap.width, y * panelPixmap.height)
						Next
						
						If hpart > 0 Then
							gdk_pixbuf_copy_area(panelPixbuf, 0, 0, panelPixmap.width, hpart, visualpixbuf, x * panelPixmap.width, hfull * panelPixmap.height)
						End If
					
					Next
					
					If wpart > 0 Then
					
						For Local y:Int = 0 Until hfull
							gdk_pixbuf_copy_area(panelPixbuf, 0, 0, wpart, panelPixmap.height, visualpixbuf, wfull * panelPixmap.width, y * panelPixmap.height)
						Next
					
						If hpart > 0 Then
							gdk_pixbuf_copy_area(panelPixbuf, 0, 0, wpart, hpart, visualpixbuf, wfull * panelPixmap.width, hfull * panelPixmap.height)
						End If
					
					End If
				
				Case PANELPIXMAP_CENTER
					visualpixbuf = gdk_pixbuf_copy(panelPixBuf)
					pbx = width / 2 - panelPixmap.width / 2
					pby = height / 2 - panelPixmap.height / 2
					
				Case PANELPIXMAP_FIT
					Local _w:Float = width / (panelPixmap.width * 1.0)
					Local _h:Float = height / (panelPixmap.height * 1.0)

					Local newWidth:Int = Min(_w, _h) * panelPixmap.width
					Local newHeight:Int = Min(_w, _h) * panelPixmap.height

					pbx = width / 2 - newWidth / 2
					pby = height / 2 - newHeight / 2

					visualpixbuf = gdk_pixbuf_scale_simple(panelPixbuf, newWidth, newHeight, GDK_INTERP_BILINEAR)

				Case PANELPIXMAP_FIT2
					Local _w:Float = width / (panelPixmap.width * 1.0)
					Local _h:Float = height / (panelPixmap.height * 1.0)

					Local newWidth:Int = Max(_w, _h) * panelPixmap.width
					Local newHeight:Int = Max(_w, _h) * panelPixmap.height

					pbx = width / 2 - newWidth / 2
					pby = height / 2 - newHeight / 2

					visualpixbuf = gdk_pixbuf_scale_simple(panelPixbuf, newWidth, newHeight, GDK_INTERP_BILINEAR)
					
				Case PANELPIXMAP_STRETCH
					pbx = 0
					pby = 0
					visualpixbuf = gdk_pixbuf_scale_simple(panelPixbuf, width, height, GDK_INTERP_BILINEAR)
			End Select
			
			If Not drawPixbuf Then
				drawPixbuf = True
			End If
		
		End If
		
		' make sure the panel refreshes visually
		Super.redraw()
	End Method

	Method Activate:Int(cmd:Int)
		Select cmd
			Case ACTIVATE_REDRAW
				redraw()
		Default
			Super.Activate(cmd)
		End Select
	End Method

	Method toString:String()
		Return "TGTKPanel"
	End Method
End Type

Rem
bbdoc: A canvas.
End Rem
Rem 
Type TGTKCanvas Extends TGTKGadget

	Field canvas:TGraphics
	Field Mode:Int
	

	Function CreateCanvas:TGTKCanvas(x:Int, y:Int, w:Int, h:Int, label:String, group:TGadget, style:Int)
		Local this:TGTKCanvas = New TGTKCanvas

		this.initCanvas(x, y, w, h, label, group, style)

		Return this
	End Function

	Method initCanvas(x:Int, y:Int, w:Int, h:Int, label:String, group:TGadget, style:Int)

		handle = gtk_drawing_area_new()

		Init(GTK_CANVAS, x, y, w, h, style)

		gtk_layout_put(TGTKContainer(group).container, handle, x, y)
		gtk_widget_set_size_request(handle, w, Max(h,0))

		sensitivity:| SENSITIZE_MOUSE | SENSITIZE_KEYS

		' we need to allow the drawing area to accept focus !
		g_object_set_int(handle, "can-focus", True)

		' we need to handle our own redrawing...
		'gtk_widget_set_double_buffered(handle, False)

		addConnection("expose_event", g_signal_cb3(handle, "expose_event", CanvasRedraw, Self, Destroy, 0))

		gtk_widget_add_events(handle, GDK_BUTTON_PRESS_MASK | ..
			GDK_BUTTON_RELEASE_MASK | GDK_ENTER_NOTIFY_MASK | GDK_LEAVE_NOTIFY_MASK | ..
			GDK_KEY_PRESS_MASK | GDK_KEY_RELEASE_MASK | GDK_POINTER_MOTION_MASK | GDK_SCROLL_MASK)' | ..
'				GDK_POINTER_MOTION_HINT_MASK)

		addConnection("button-press-event", g_signal_cb3(handle, "button-press-event", OnMouseDown, Self, Destroy, 0))
		addConnection("button-release-event", g_signal_cb3(handle, "button-release-event", OnMouseUp, Self, Destroy, 0))
		addConnection("enter-notify-event", g_signal_cb3(handle, "enter-notify-event", OnMouseEnter, Self, Destroy, 0))
		addConnection("leave-notify-event", g_signal_cb3(handle, "leave-notify-event", OnMouseLeave, Self, Destroy, 0))
		addConnection("motion-notify-event", g_signal_cb3(handle, "motion-notify-event", OnMouseMove, Self, Destroy, 0))
		addConnection("scroll-event", g_signal_cb3(handle, "scroll-event", OnScroll, Self, Destroy, 0))

		addConnection("key-press-event", g_signal_cb3(handle, "key-press-event", OnKeyDown, Self, Destroy, 0))
		addConnection("key-release-event", g_signal_cb3(handle, "key-release-event", OnKeyUp, Self, Destroy, 0))

		SetShow(True)
	End Method

	Function CanvasRedraw(widget:Byte Ptr, event:Byte Ptr, obj:Object)
		PostGuiEvent(EVENT_GADGETPAINT, TGadget(obj))
	End Function
	
	Method AttachGraphics:TGraphics( flags:Int )
		Mode = flags
	End Method

	Method CanvasGraphics:TGraphics()
		If Not canvas Then
			canvas = BRL.Graphics.AttachGraphics(gdk_x11_drawable_get_xid(gtk_widget_get_window(handle)), Mode)
		End If

		Return canvas
	End Method

	Method Activate:Int(cmd:Int)
		If cmd <> ACTIVATE_REDRAW Then
			Super.Activate(cmd)
		End If

		Select cmd
			Case ACTIVATE_REDRAW
				gtk_widget_queue_draw(handle)
		End Select
	End Method

	Function OnMouseDown:Int(widget:Byte Ptr, event:Byte Ptr, obj:Object)
		Local x:Double, y:Double, button:Int
		bmx_gtk3maxgui_gdkeventbutton(event, Varptr x, Varptr y, Varptr button)

		If button = 3 Then
			button = 2
		Else If button = 2 Then
			button = 3
		End If

		PostGuiEvent(EVENT_MOUSEDOWN, TGadget(obj),button,,x,y)

		Return True
	End Function
	
	Function OnScroll(widget:Byte Ptr, event:Byte Ptr, obj:Object)
		Local x:Double, y:Double, direction:Int
		bmx_gtk3maxgui_gdkeventscroll(event, Varptr x, Varptr y, Varptr direction)

		If direction = GDK_SCROLL_UP Or direction = GDK_SCROLL_LEFT Then
			PostGuiEvent(EVENT_MOUSEWHEEL, TGadget(obj),-1,,x,y)
		Else
			PostGuiEvent(EVENT_MOUSEWHEEL, TGadget(obj),1,,x,y)
		End If
	End Function

	Function OnMouseUp:Int(widget:Byte Ptr, event:Byte Ptr, obj:Object)
		Local x:Double, y:Double, button:Int
		bmx_gtk3maxgui_gdkeventbutton(event, Varptr x, Varptr y, Varptr button)

		If button = 3 Then
			button = 2
		Else If button = 2 Then
			button = 3
		End If

		PostGuiEvent(EVENT_MOUSEUP, TGadget(obj),button,,x,y)

		Return True
	End Function

	Function OnMouseEnter:Int(widget:Byte Ptr, event:Byte Ptr, obj:Object)
		PostGuiEvent(EVENT_MOUSEENTER, TGadget(obj))

		Return True
	End Function

	Function OnMouseLeave:Int(widget:Byte Ptr, event:Byte Ptr, obj:Object)

		PostGuiEvent(EVENT_MOUSELEAVE, TGadget(obj))

		Return True
	End Function

	'Rem
	'bbdoc: Callback for mouse movement
	'End Rem
	Function OnMouseMove:Int(widget:Byte Ptr, event:Byte Ptr, obj:Object)
		Local x:Double, y:Double, button:Int
		bmx_gtk3maxgui_gdkeventmotion(event, Varptr x, Varptr y, Varptr button)

		If button & GDK_BUTTON1_MASK Then
			button = 1
		Else If button & GDK_BUTTON3_MASK Then
			button = 2
		Else If button & GDK_BUTTON2_MASK Then
			button = 3
		Else
			button = 0
		End If
		PostGuiEvent(EVENT_MOUSEMOVE, TGadget(obj),button,,x,y)

		Return True
	End Function

	Function OnKeyDown:Int(widget:Byte Ptr, event:Byte Ptr, obj:Object)
		Local _key:Int, _mods:Int
		bmx_gtk3maxgui_gdkeventkey(event, Varptr _key, Varptr _mods)
		Local key:Int = TGTKKeyMap.mapBack(_key)
		Local mods:Int = TGTKKeyMap.mapModifierBack(_mods)

		If Not gtk3SetKeyDown(key) Then
			PostGuiEvent(EVENT_KEYDOWN, TGadget(obj), key, mods)
		Else
			PostGuiEvent(EVENT_KEYREPEAT, TGadget(obj), key, mods)
		End If

		Local char:Int = gdk_keyval_to_unicode(_key)
		' we sometimes get 0 from this function when key is valid... so set it to key just so that it has a value.
		If char = 0 And key <> 0 Then
			char = key
		End If
		PostGuiEvent(EVENT_KEYCHAR, TGadget(obj), char, mods)

		Return True
	End Function

	Function OnKeyUp:Int(widget:Byte Ptr, event:Byte Ptr, obj:Object)
		Local _key:Int, _mods:Int
		bmx_gtk3maxgui_gdkeventkey(event, Varptr _key, Varptr _mods)
		Local key:Int = TGTKKeyMap.mapBack(_key)
		Local mods:Int = TGTKKeyMap.mapModifierBack(_mods)
		
		gtk3SetKeyUp(key)
		PostGuiEvent(EVENT_KEYUP, TGadget(obj), key, mods)

		Return True
	End Function

	Method free:Int()
		Super.free()
		
		If canvas
			canvas.Close()
			canvas = Null
		End If
		
		If handle 
			gtk_widget_destroy(handle)
		EndIf
		handle = Null
	End Method
End Type
End Rem

Rem
bbdoc: A text area.
End Rem
Type TGTKDefaultTextArea Extends TGTKTextArea

	Field _tabsize:Int = 4

	Field scrollWindow:Byte Ptr
	Field _textBuffer:Byte Ptr
	Field _textTagTable:Byte Ptr
	Field _tabArray:Byte Ptr
	Field ignoreChange:Int
	Field fastUpdate:Int = False
	
	'Field _selStart:Int
	'Field _selEnd:Int

	Function CreateTextArea:TGTKTextArea(x:Int, y:Int, w:Int, h:Int, label:String, group:TGadget, style:Int)
		Local this:TGTKDefaultTextArea = New TGTKDefaultTextArea

		this.initTextArea(x, y, w, h, label, group, style)

		Return this
	End Function

	Method initTextArea(x:Int, y:Int, w:Int, h:Int, label:String, group:TGadget, style:Int)
		_textBuffer = gtk_text_buffer_new(Null)
		_textTagTable = gtk_text_buffer_get_tag_table(_textBuffer)

		handle = gtk_text_view_new_with_buffer(_textBuffer)
		gtk_widget_show(handle)
		
		' we need these events to allow tooltips to work
		gtk_widget_add_events(handle, GDK_ENTER_NOTIFY_MASK | GDK_LEAVE_NOTIFY_MASK)

		' use word-wrapping ?
		If style & TEXTAREA_WORDWRAP Then
			gtk_text_view_set_wrap_mode(handle, GTK_WRAP_WORD_CHAR)
		End If

		' a read-only textarea ?
		If style & TEXTAREA_READONLY Then
			gtk_text_view_set_editable(handle, False)
		End If

		Init(GTK_TEXTFIELD, x, y, w, h, style)

		' scrollbars for the textarea...
		scrollWindow = gtk_scrolled_window_new(Null, Null)
		' set container resize mode
		gtk_container_set_resize_mode(scrollWindow, GTK_RESIZE_QUEUE)
		' set scrollbar policy
		gtk_scrolled_window_set_policy(scrollWindow, GTK_POLICY_AUTOMATIC, GTK_POLICY_AUTOMATIC)
		' show
		gtk_widget_show(scrollWindow)

		' add the text area to the scroll window
		gtk_container_add(scrollWindow, handle)


		addConnection("changed", g_signal_cb2(_textBuffer, "changed", OnTextChanged, Self, Destroy, 0))
		addConnection("move-cursor", g_signal_cb5(handle, "move-cursor", OnCursorMoved, Self, Destroy, 0))
		addConnection("button-press-event", g_signal_cb3_ret(handle, "button-press-event", OnMouseDown, Self, Destroy, 0))
		addConnection("button-release-event", g_signal_cb3_ret(handle, "button-release-event", OnMouseUp, Self, Destroy, 0))
		addConnection("key-press-event", g_signal_cb3_ret(handle, "key-press-event", OnKeyDown, Self, Destroy, 0))
		addConnection("focus-out-event", g_signal_cb3_ret(handle, "focus-out-event", OnFocusLost, Self, Destroy, 0))

		'g_signal_cb3(handle, "visibility-notify-event", OnVisibilityChange, Self, Destroy, 0)

		gtk_layout_put(TGTKContainer(group).container, scrollwindow, x, y)
		gtk_widget_set_size_request(handle, w, Max(h,0))
	End Method

	Rem
	bbdoc: Callback for text change
	End Rem
	Function OnTextChanged(widget:Byte Ptr, obj:Object)
		If Not TGTKDefaultTextArea(obj).ignoreChange Then
			PostGuiEvent(EVENT_GADGETSELECT, TGadget(obj))
			PostGuiEvent(EVENT_GADGETACTION, TGadget(obj))
		End If
		TGTKDefaultTextArea(obj).ignoreChange = False
	End Function

	Rem
	bbdoc: Callback for text-cursor movement
	End Rem
	Function OnCursorMoved(widget:Byte Ptr, _Step:Int, count:Int, extend_selection:Int, obj:Object)
		PostGuiEvent(EVENT_GADGETSELECT, TGadget(obj))
	End Function

	Rem
	bbdoc: Callback for mouse button press
	End Rem
	Function OnMouseDown:Int(widget:Byte Ptr, event:Byte Ptr, obj:Object)
		Local x:Double, y:Double, button:Int
		bmx_gtk3maxgui_gdkeventbutton(event, Varptr x, Varptr y, Varptr button)

		If button = 3 Then ' right mouse button
			' ignore this...  see MouseUp for menu event!
			Return True
		End If

		PostGuiEvent(EVENT_GADGETSELECT, TGadget(obj))
	End Function

	Rem
	bbdoc: Callback for mouse button release
	End Rem
	Function OnMouseUp:Int(widget:Byte Ptr, event:Byte Ptr, obj:Object)
		Local x:Double, y:Double, button:Int
		bmx_gtk3maxgui_gdkeventbutton(event, Varptr x, Varptr y, Varptr button)

		If button = 3 Then ' right mouse button
			PostGuiEvent(EVENT_GADGETMENU, TGadget(obj),,,x,y)
			Return True
		End If

		PostGuiEvent(EVENT_GADGETSELECT, TGadget(obj))
	End Function
	
	Rem
	bbdoc: Adds text to the end of the text.
	End Rem
	Method AddText:Int(text:String)
		Local _end:Byte Ptr = bmx_gtk3_gtktextiter_new()
		' get the end of the text
		gtk_text_buffer_get_end_iter(_textBuffer, _end)

		ignoreChange = True
		Local textPtr:Byte Ptr = text.ToUTF8String()
		gtk_text_buffer_insert(_textBuffer, _end, textPtr, -1)
		MemFree(textPtr)

		gtk_text_buffer_get_end_iter(_textBuffer, _end)
?bmxng
		IWrappedSystemDriver(SystemDriver()).GetDriver().Poll()
?Not bmxng
		brl.System.Driver.Poll() ' update events, before scrolling to the end...
?
		gtk_text_view_scroll_to_iter(handle, _end, 0, False, 0, 0)
		
		bmx_gtk3_gtktextiter_free(_end)
	End Method

	Rem
	bbdoc: Returns the text For the specified location
	End Rem
	Method AreaText:String(pos:Int, length:Int, units:Int)
		Local _start:Byte Ptr = bmx_gtk3_gtktextiter_new()
		Local _end:Byte Ptr = bmx_gtk3_gtktextiter_new()

		If units = TEXTAREA_LINES Then
			gtk_text_buffer_get_iter_at_line(_textBuffer, _start, pos)
			gtk_text_buffer_get_iter_at_line(_textBuffer, _end, pos + length)

		Else ' must be TEXTAREA_CHARS
			gtk_text_buffer_get_iter_at_offset(_textBuffer, _start, pos)
			gtk_text_buffer_get_iter_at_offset(_textBuffer, _end, pos + length)

		End If

		Local s:Byte Ptr = gtk_text_buffer_get_text(_textBuffer, _start, _end, False)
		Local st:String = String.FromUTF8String(s)
		g_free(s)
		
		bmx_gtk3_gtktextiter_free(_start)
		bmx_gtk3_gtktextiter_free(_end)
		
		Return st
	End Method

	Rem
	bbdoc: Returns either the number of characters or number of rows.
	End Rem
	Method AreaLen:Int(units:Int)
		If units = TEXTAREA_LINES Then
			Return gtk_text_buffer_get_line_count(_textBuffer)
		Else
			Return gtk_text_buffer_get_char_count(_textBuffer)
		End If
	End Method

	Rem
	bbdoc: Returns the current cursor position value, in characters or lines
	End Rem
	Method GetCursorPos:Int(units:Int)
		Local pos:Int = 0
		Local _start:Byte Ptr = bmx_gtk3_gtktextiter_new()
		Local _end:Byte Ptr = bmx_gtk3_gtktextiter_new()

		' Since the cursor position might be at the end of selected text, we get the selection
		' bounds and get the *start* location. If there is no selection, start and end will be the same

		gtk_text_buffer_get_selection_bounds(_textBuffer, _start, _end)
		
		If units = TEXTAREA_LINES Then
			pos = gtk_text_iter_get_line(_start)
		Else ' must be TEXTAREA_CHARS
			pos = gtk_text_iter_get_offset(_start)
		End If

		bmx_gtk3_gtktextiter_free(_start)
		bmx_gtk3_gtktextiter_free(_end)

		Return pos
	End Method

	Rem
	bbdoc: Set the text area visibility.
	End Rem
	Method SetShow:Int(truefalse:Int)
		visible = truefalse
		mySetVisible = visible
		
		If truefalse Then
			gtk_widget_show(handle)
			gtk_widget_show(scrollWindow)
		Else
			gtk_widget_hide(scrollWindow)
		EndIf
	End Method

	Rem
	bbdoc: Set the text area font.
	End Rem
	Method SetFont:Int(font:TGuiFont)
		Super.SetFont(font)

		' we need to reset the tabs, as it is lost when font is changed.
		SetTabs(_tabsize)
	End Method

	Rem
	bbdoc: Sets the text buffer text
	End Rem
	Method SetText:Int(text:String)
		ignoreChange = True
		Local textPtr:Byte Ptr = text.ToUTF8String()
		gtk_text_buffer_set_text(_textBuffer, textPtr, -1)
		MemFree(textPtr)

		' move the cursor to the start
		Local _start:Byte Ptr = bmx_gtk3_gtktextiter_new()
		gtk_text_buffer_get_iter_at_line(_textBuffer, _start, 0)
		gtk_text_buffer_place_cursor(_textBuffer, _start)
		gtk_text_view_scroll_mark_onscreen(handle, gtk_text_buffer_get_insert(_textBuffer))', 0, False, 0, 0.1)
		
		bmx_gtk3_gtktextiter_free(_start)
	End Method

	Rem
	bbdoc: Set the text area selection
	End Rem
	Method SetSelection:Int(pos:Int, length:Int, units:Int)

		Local _start:Byte Ptr = bmx_gtk3_gtktextiter_new()
		Local _end:Byte Ptr = bmx_gtk3_gtktextiter_new()

		If units = TEXTAREA_LINES Then
			gtk_text_buffer_get_iter_at_line(_textBuffer, _start, pos)
			gtk_text_buffer_get_iter_at_line(_textBuffer, _end, pos + length)

		Else ' must be TEXTAREA_CHARS
			gtk_text_buffer_get_iter_at_offset(_textBuffer, _start, pos)
			gtk_text_buffer_get_iter_at_offset(_textBuffer, _end, pos + length)

		End If

		gtk_text_buffer_place_cursor(_textBuffer, _start)
		gtk_text_view_scroll_mark_onscreen(handle, gtk_text_buffer_get_insert(_textBuffer))
		
		gtk_text_buffer_select_range(_textBuffer, _start, _end)

		PostGuiEvent(EVENT_GADGETSELECT, Self)

		' scroll to the start of the selection
		' NOTE: setting param4 to False causes it to scroll only as much as required to show the start
		' Set to True to cause it to always display at the same point on the visible area.
		gtk_text_view_scroll_to_iter(handle, _start, 0, False, 0, 0.1)

		bmx_gtk3_gtktextiter_free(_start)
		bmx_gtk3_gtktextiter_free(_end)
	End Method

	Rem
	bbdoc: Returns the size of the current selection, in characters or lines.
	End Rem
	Method GetSelectionLength:Int(units:Int)
		Local length:Int = 0

		Local _start:Byte Ptr = bmx_gtk3_gtktextiter_new()
		Local _end:Byte Ptr = bmx_gtk3_gtktextiter_new()

		Local hasSelection:Int = gtk_text_buffer_get_selection_bounds(_textBuffer, _start, _end)

		If hasSelection Then

			If units = TEXTAREA_LINES Then

				length = gtk_text_iter_get_line(_end) - gtk_text_iter_get_line(_start)

			Else ' must be TEXTAREA_CHARS

				length = gtk_text_iter_get_offset(_end) - gtk_text_iter_get_offset(_start)

			End If

		End If

		bmx_gtk3_gtktextiter_free(_start)
		bmx_gtk3_gtktextiter_free(_end)

		Return length
	End Method

	Rem
	bbdoc: Sets the style of part of the text area
	about: @flags are any mix of TEXTFORMAT_BOLD, TEXTFORMAT_ITALIC, TEXTFORMAT_UNDERLINE and TEXTFORMAT_STRIKETHROUGH.<br>
	We utilise the buffers' tag table to cache tags that we reuse - based on the attributes.
	This way we only create one for each different style we actually use in the buffer.<br>
	Note: "fastUpdate" flag enables or disables the use of gtk_text_buffer_remove_all_tags which strips
	old tags from the area before applying the new one.<br>
	Ideally, you would first remove tags before applying new ones, but since removal is slow, the following
	method can work well :
	<pre>
	setFastUpdate(false)
	SetStyle on whole intended area to "normal" style
	setFastUpdate(true)
	iterate thru tokens applying styles..
	</pre>
	End Rem
	Method SetStyle:Int(r:Int, g:Int, b:Int, flags:Int, pos:Int, length:Int, units:Int)

		' Build a style string
		Local s:Int = r Shl 24 | g Shl 16 | b Shl 8 | (flags & $ff)
		Local styleText:String = String(s)

		' Does this one already exist?
		Local _textTag:Byte Ptr = gtk_text_tag_table_lookup(_textTagTable, styleText)

		' nope... so we need to create it
		If _textTag = Null Then

			Local color:GdkRGBA = New GdkRGBA(r / 255.0, g / 255.0, b / 255.0)
'
			Local _style:Int = PANGO_STYLE_NORMAL
			If flags & TEXTFORMAT_ITALIC Then
				_style = PANGO_STYLE_ITALIC
			End If
			Local _weight:Int = PANGO_WEIGHT_NORMAL
			If flags & TEXTFORMAT_BOLD Then
				_weight = PANGO_WEIGHT_BOLD
			End If
			Local _under:Int = PANGO_UNDERLINE_NONE
			If flags & TEXTFORMAT_UNDERLINE Then
				_under = PANGO_UNDERLINE_SINGLE
			End If
			Local _strike:Int = False
			If flags & TEXTFORMAT_STRIKETHROUGH Then
				_strike = True
			End If

			' create and setup the tag
			_textTag = bmx_gtk3_set_text_tag_style(_textBuffer, styleText, color, _style, _weight, _under, _strike)
			
		End If

		applyStyle(pos, length, units, _textTag)
		
	End Method
	
	Method applyStyle(pos:Int, length:Int, units:Int, _textTag:Byte Ptr)
		' set up start and end points
		Local _start:Byte Ptr = bmx_gtk3_gtktextiter_new()
		Local _end:Byte Ptr = bmx_gtk3_gtktextiter_new()

		If units = TEXTAREA_LINES Then
			gtk_text_buffer_get_iter_at_line(_textBuffer, _start, pos)
			gtk_text_buffer_get_iter_at_line(_textBuffer, _end, pos + length)
		Else ' must be TEXTAREA_CHARS
			gtk_text_buffer_get_iter_at_offset(_textBuffer, _start, pos)
			gtk_text_buffer_get_iter_at_offset(_textBuffer, _end, pos + length)
		End If

		' remove any existing tags in the range first - otherwise they'll just pile up
		' NOTE : except that this is REALLY slow....
		If Not fastUpdate Then
			gtk_text_buffer_remove_all_tags(_textBuffer, _start, _end)
		End If

		' apply the tag to the range
		gtk_text_buffer_apply_tag(_textBuffer, _textTag, _start, _end)
		
		bmx_gtk3_gtktextiter_free(_start)
		bmx_gtk3_gtktextiter_free(_end)
	End Method

	Method SetBGStyle(r:Int, g:Int, b:Int, pos:Int, length:Int, units:Int)

		' Build a style string
		Local styleText:String = r + "_" + g + "_" + b + "_bg"

		' Does this one already exist?
		Local _textTag:Byte Ptr = gtk_text_tag_table_lookup(_textTagTable, styleText)

		' nope... so we need to create it
		If _textTag = Null Then

			Local color:GdkRGBA = New GdkRGBA(r / 255.0, g / 255.0, b / 255.0)
		
			' create and setup the tag
			_textTag = bmx_gtk3_set_text_bg_tag(_textBuffer, styleText, color)

		End If

		applyStyle(pos, length, units, _textTag)

	End Method	

	Method ReplaceText:Int(pos:Int, length:Int, text:String, units:Int)

		If length = TEXTAREA_ALL Then
			SetText(text)
		Else
			' set up start and end points
			Local _start:Byte Ptr = bmx_gtk3_gtktextiter_new()
			Local _end:Byte Ptr = bmx_gtk3_gtktextiter_new()
	
			If units = TEXTAREA_LINES Then
				gtk_text_buffer_get_iter_at_line(_textBuffer, _start, pos)
				gtk_text_buffer_get_iter_at_line(_textBuffer, _end, pos + length)
			Else ' must be TEXTAREA_CHARS
				gtk_text_buffer_get_iter_at_offset(_textBuffer, _start, pos)
				gtk_text_buffer_get_iter_at_offset(_textBuffer, _end, pos + length)
			End If
	
			' remove the specified range
			gtk_text_buffer_delete(_textBuffer, _start, _end)
	
			' insert new text
			Local textPtr:Byte Ptr = text.ToUTF8String()
			gtk_text_buffer_insert(_textBuffer, _start, textPtr, -1)
			MemFree(textPtr)
			
			bmx_gtk3_gtktextiter_free(_start)
			bmx_gtk3_gtktextiter_free(_end)
		End If
	End Method

	Rem
	bbdoc: Locks the text area.
	End Rem
	Method LockText:Int()
		gtk_text_view_set_editable(handle, False)
	End Method

	Rem
	bbdoc: Unlocks the text area
	End Rem
	Method UnlockText:Int()
		gtk_text_view_set_editable(handle, True)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method SetTabs:Int(tabs:Int)

		' cache the current size
		_tabsize = tabs

		' get the current tab array - returns Null if default 8-space setting
		_tabArray = gtk_text_view_get_tabs(handle)
		
		If _tabArray <> Null Then
			pango_tab_array_free(_tabArray)
		End If

		Local tabmul:Int = 8 * 1024
		If _font <> Null Then
			tabmul = _font.size * 1024
		End If

		_tabArray = pango_tab_array_new_with_positions(1, False, PANGO_TAB_LEFT, tabs * tabmul)
		gtk_text_view_set_tabs(handle, _tabArray)

	End Method

	Method CharAt:Int(line:Int)
		Local _iter:Byte Ptr = bmx_gtk3_gtktextiter_new()
		gtk_text_buffer_get_iter_at_line(_textBuffer, _iter, line)
		Local ret:Int = gtk_text_iter_get_offset(_iter)
		bmx_gtk3_gtktextiter_free(_iter)
		Return ret
	End Method

	Method LineAt:Int(index:Int)
		Local _iter:Byte Ptr = bmx_gtk3_gtktextiter_new()
		gtk_text_buffer_get_iter_at_offset(_textBuffer, _iter, index)
		Local ret:Int = gtk_text_iter_get_line(_iter)
		bmx_gtk3_gtktextiter_free(_iter)
		Return ret
	End Method

	Method free:Int() Override
		Super.Free()

		If scrollWindow Then
			gtk_widget_destroy(scrollWindow)
		EndIf
		handle = Null
		scrollWindow = Null

	End Method

	Method Activate:Int(cmd:Int)
		Super.Activate(cmd)

		Select cmd
			Case ACTIVATE_CUT
				Local clipboard:Byte Ptr = gtk_clipboard_get(gdk_atom_intern("CLIPBOARD", True))
				gtk_text_buffer_cut_clipboard(_textBuffer, clipboard, True)

			Case ACTIVATE_COPY
				Local clipboard:Byte Ptr = gtk_clipboard_get(gdk_atom_intern("CLIPBOARD", True))
				gtk_text_buffer_copy_clipboard(_textBuffer, clipboard)

			Case ACTIVATE_PASTE
				Local clipboard:Byte Ptr = gtk_clipboard_get(gdk_atom_intern("CLIPBOARD", True))
				gtk_text_buffer_paste_clipboard(_textBuffer, clipboard, Null, True)

		End Select
	End Method
	
	Rem
	bbdoc: Enable to allow *fast* formatting.
	about: When enabled, highlighting will not be removed before being applied, and since
	tags are ordered, some highlight may not appear on top of others.
	End Rem
	Method setFastUpdate(bool:Int)
		fastUpdate = bool
	End Method
	
	Method Rethink:Int()
		If handle Then
			gtk_layout_move(TGTKContainer(parent).container, scrollWindow, Max(xpos, 0), Max(ypos, 0))
			gtk_widget_set_size_request(scrollWindow, Max(width,0), Max(height,0))
		End If
	End Method

End Type



Rem
bbdoc: A base type for html view gadgets.
about: Implementations are in seperate modules.<br>
See bah.gtkwebmozilla and bah.gtkwebgtkhtml mods.
End Rem
Type TGTKHTMLView Extends TGTKGadget
	Function CreateHTMLView:TGTKHTMLView(x:Int, y:Int, w:Int, h:Int, label:String, group:TGadget, style:Int) Abstract
	
	Method Stop() Abstract
	Method SetText:Int(url:String) Abstract
	Method GetText:String() Abstract

End Type

Type TGTKWebDriver
	Function CreateHTMLView:TGTKHTMLView(x:Int, y:Int, w:Int, h:Int, label:String, group:TGadget, style:Int) Abstract
End Type

Global gtk3maxgui_htmlview:TGTKWebDriver

Rem
bbdoc: A base type for text area gadgets.
about: Implementations are in seperate modules, except for the default TGTKDefaultTextArea
End Rem
Type TGTKTextArea Extends TGTKEditable
	Function CreateTextArea:TGTKTextArea(x:Int, y:Int, w:Int, h:Int, label:String, group:TGadget, style:Int) Abstract

End Type


Type TGTKTextAreaDriver
	Function CreateTextArea:TGTKTextArea(x:Int, y:Int, w:Int, h:Int, label:String, group:TGadget, style:Int) Abstract
End Type

' default text area driver
Type TGTKDefaultTextAreaDriver Extends TGTKTextAreaDriver
	Function CreateTextArea:TGTKTextArea(x:Int, y:Int, w:Int, h:Int, label:String, group:TGadget, style:Int)
		Return TGTKDefaultTextArea.CreateTextArea(x, y, w, h, label, group, style)
	End Function
End Type

Global gtk3maxgui_textarea:TGTKTextAreaDriver


Extern
	Function g_object_get_menudata:TGTKMenuItem(handle:Byte Ptr, name:Byte Ptr) = "g_object_get_data"
End Extern
