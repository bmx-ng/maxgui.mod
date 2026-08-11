' Copyright (c) 2014-2026 Bruce A Henderson
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

Rem
bbdoc: GTKMaxGUI Linux WebKit2Gtk Widget
End Rem
Module MaxGUI.GTK3WebKit2Gtk

ModuleInfo "Version: 1.00"
ModuleInfo "License: MIT"
ModuleInfo "Copyright: 2014-2026 Bruce A Henderson"

ModuleInfo "History: 1.00"
ModuleInfo "History: Initial Release."

Import MaxGUI.GTK3MaxGUI

?linux

Import "-ldl"
Import "glue.c"

Extern
	Function bmx_gtk3_webkit_available:Int()
	Function webkit_web_view_new:Byte Ptr() = "bmx_gtk3_webkit_web_view_new"
	Function webkit_web_view_load_uri(handle:Byte Ptr, url:Byte Ptr) = "bmx_gtk3_webkit_web_view_load_uri"
	Function webkit_web_view_stop_loading(handle:Byte Ptr) = "bmx_gtk3_webkit_web_view_stop_loading"
	Function webkit_web_view_can_go_forward:Int(handle:Byte Ptr) = "bmx_gtk3_webkit_web_view_can_go_forward"
	Function webkit_web_view_can_go_back:Int(handle:Byte Ptr) = "bmx_gtk3_webkit_web_view_can_go_back"
	Function webkit_web_view_go_forward(handle:Byte Ptr) = "bmx_gtk3_webkit_web_view_go_forward"
	Function webkit_web_view_go_back(handle:Byte Ptr) = "bmx_gtk3_webkit_web_view_go_back"
	Function webkit_web_view_get_uri:Byte Ptr(handle:Byte Ptr) = "bmx_gtk3_webkit_web_view_get_uri"
End Extern

Global GtkWebKitGtkWeb:TGTKWebKitGtkDriver = New TGTKWebKitGtkDriver

Type TGTKWebKitGtkDriver Extends TGTKWebDriver
	Method New()
		If bmx_gtk3_webkit_available() Then
			gtk3maxgui_htmlview = Self
		End If
	End Method
	
	Function CreateHTMLView:TGTKWebKitGtk(x:Int, y:Int, w:Int, h:Int, label:String, group:TGadget, style:Int)
		Return TGTKWebKitGtk.CreateHTMLView(x, y, w, h, label, group, style)
	End Function
End Type


Type TGTKWebKitGtk Extends TGTKHTMLView

	Field noNavigate:Int
	Field scrollWindow:Byte Ptr
	Field box:Byte Ptr

	Function CreateHTMLView:TGTKWebKitGtk(x:Int, y:Int, w:Int, h:Int, label:String, group:TGadget, style:Int)
		Local this:TGTKWebKitGtk = New TGTKWebKitGtk

		this.initHTMLView(x, y, w, h, label, group, style)

		Return this
	End Function

	Method initHTMLView(x:Int, y:Int, w:Int, h:Int, label:String, group:TGadget, style:Int)

		handle = webkit_web_view_new()

		init(GTK_HTMLVIEW, x, y, w, h, style)

		noNavigate = (style & HTMLVIEW_NONAVIGATE)


		' create a scroll window for the html view
		scrollWindow = gtk_scrolled_window_new(Null, Null)
		' set container resize mode
		gtk_container_set_resize_mode(scrollWindow, GTK_RESIZE_QUEUE)
		' set scrollbar policy
		gtk_scrolled_window_set_policy(scrollWindow, GTK_POLICY_AUTOMATIC, GTK_POLICY_AUTOMATIC)
		' show
		gtk_widget_show(scrollWindow)

		' add the html view to the scroll view
		gtk_container_add(scrollWindow, handle)


		' We need to put this inside a box...  Why?  because we can't resize the webkit gadget 
		' in code - but we *can* resize a box that holds the scrollwindow + webkit gadget...
		box = gtk_box_new(GTK_ORIENTATION_VERTICAL, 0)
		gtk_widget_show(box)
		gtk_box_pack_start(box, scrollWindow, True, True, 0)

		bmx_gtk3_maxgui_fixed_put(TGTKContainer(group).container, box, x, y, w, Max(h, 0))

		SetShow(True)

		addConnection("load-changed", g_signal_cb3a(handle, "load-changed", OnLoadChanged, Self))

	End Method
	
	Rem
	bbdoc: Stops loading of the current document.
	End Rem
	Method Stop()
		webkit_web_view_stop_loading(handle)
	End Method

	Method SetText:Int(url:String)
		Local urlPtr:Byte Ptr = checkURL(url).ToUTF8String()
		webkit_web_view_load_uri(handle, urlPtr)
		MemFree(urlPtr)
	End Method
	
	Method GetText:String()
		If handle Then
			Return String.FromUTF8String(webkit_web_view_get_uri(handle))
		End If
	End Method

	Method Activate:Int(cmd:Int)
		Super.Activate(cmd)

		Select cmd
			Case ACTIVATE_FORWARD
				If webkit_web_view_can_go_forward(handle) Then
					webkit_web_view_go_forward(handle)
				End If
			Case ACTIVATE_BACK
				If webkit_web_view_can_go_back(handle) Then
					webkit_web_view_go_back(handle)
				End If
		End Select
	End Method

	Function checkURL:String(url:String, forMax:Int=False)
		Local	anchor$,a:Int,lowerUrl:String
		a=url.Find("#")
		If a<>-1 Then
			anchor=url[a..]
			url=url[..a]
		End If
		lowerUrl=url.ToLower()
		If Not lowerUrl.StartsWith("http://") And Not lowerUrl.StartsWith("https://") And Not lowerUrl.StartsWith("file://") Then
			If url.StartsWith("/") Or FileType(url) Then
				url = "file://" + url
			Else
				If forMax Then
					If Not lowerUrl.StartsWith("http::") Then
						url="http::" + url
					End If
				Else
					url = "http://" + url
				End If
			EndIf
		EndIf
		If forMax Then
			If url.ToLower().StartsWith("http://") Then
				url = "http::" + url[7..]
			End If
		End If
		url:+anchor
		url = url.Replace(" ","%20")
		Return url
	End Function

	Function OnLoadChanged(widget:Byte Ptr, loadEvent:Int, obj:Object)
		Select loadEvent
			Case WEBKIT_LOAD_FINISHED
				PostGuiEvent(EVENT_GADGETDONE, TGadget(obj))
		End Select
	End Function

	Method ClientWidth:Int()
		Return width
	End Method

	Method ClientHeight:Int()
		Return height
	End Method

	Method Rethink:Int()
		If handle Then
			bmx_gtk3_maxgui_fixed_set_child_rect(TGTKContainer(parent).container, box, ..
				Max(xpos, 0), Max(ypos, 0), Max(width, 0), Max(height, 0))
		End If
	End Method

	Method free:Int()
		Super.free()
		
		If handle Then
			gtk_widget_destroy(handle)
		EndIf
		handle = Null

	End Method

End Type

Const WEBKIT_LOAD_STARTED:Int = 0
Const WEBKIT_LOAD_REDIRECTED:Int = 1
Const WEBKIT_LOAD_COMMITTED:Int = 2
Const WEBKIT_LOAD_FINISHED:Int = 3
?
