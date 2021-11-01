' Copyright (c) 2006-2020 Bruce A Henderson
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


?bmxng
Import BRL.SystemDefault
?Not bmxng
Import BRL.System
?
Import MaxGUI.MaxGUI
Import BRL.LinkedList
Import BRL.Map

?linux
'Import "-L/usr/lib/x86_64-linux-gnu/"
Import "-lgtk-3"
Import "-lgdk-3"
Import "-latk-1.0"
Import "-lgio-2.0"
Import "-lpangocairo-1.0"
Import "-lgdk_pixbuf-2.0"
Import "-lcairo-gobject"
Import "-lpango-1.0"
Import "-lcairo"
Import "-lgobject-2.0"
Import "-lglib-2.0"
?

Import "gtkkeymap.bmx"
Import "elist.bmx"

Extern

	' main loop and events
	Function gtk_init(argc:Int Ptr, argv:Byte Ptr Ptr Ptr)
	Function gtk_main_iteration_do:Int(blocking:Int)
	Function gtk_events_pending:Int()
	Function gtk_get_current_event_time:Int()

	' gdkscreen
	Function gdk_screen_get_default:Byte Ptr()
	Function gdk_screen_get_width:Int(handle:Byte Ptr)
	Function gdk_screen_get_height:Int(handle:Byte Ptr)
	Function gdk_screen_get_system_visual:Byte Ptr(handle:Byte Ptr)
	Function gdk_screen_get_display:Byte Ptr(screen:Byte Ptr)
	Function gdk_screen_get_n_monitors:Int(screen:Byte Ptr)
	Function gdk_screen_get_monitor_scale_factor:Int(screen:Byte Ptr, monitor:Int)
	
	' visuals
	Function gdk_visual_get_depth:Int(handle:Byte Ptr)
	
	' gdkdisplay
	Function gdk_display_get_default:Byte Ptr()

	' gdkcursor
	Function gdk_cursor_new_for_display:Byte Ptr(display:Byte Ptr, cursorType:Int)

	' gtkmessagedialog
	Function gtk_message_dialog_new:Byte Ptr(parent:Byte Ptr, flags:Int, _type:Int, buttons:Int, message:Byte Ptr)

	' gtkdialog
	Function gtk_dialog_run:Int(handle:Byte Ptr)
	Function gtk_dialog_add_button:Byte Ptr(handle:Byte Ptr, buttonText$z, responseId:Int)
	
	' gtkwidget
	Function gtk_widget_destroy(handle:Byte Ptr)
	Function gtk_widget_show(handle:Byte Ptr)
	Function gtk_widget_hide(handle:Byte Ptr)
?bmxng
	Function gtk_widget_get_preferred_size(handle:Byte Ptr, minSize:GtkRequisition Var, natSize:GtkRequisition Var)
	Function gtk_widget_get_allocation(handle:Byte Ptr, allocation:GtkAllocation Var)
	Function gtk_widget_override_color(handle:Byte Ptr, state:Int, color:GdkRGBA Var)
	Function gtk_widget_size_allocate(handle:Byte Ptr, allocation:GtkAllocation Var)
	Function gtk_widget_override_background_color(handle:Byte Ptr, state:Int, color:GdkRGBA Var)
?Not bmxng
	Function gtk_widget_get_preferred_size(handle:Byte Ptr, minSize:Byte Ptr, natSize:Byte Ptr)
	Function gtk_widget_get_allocation(handle:Byte Ptr, allocation:Byte Ptr)
	Function gtk_widget_override_color(handle:Byte Ptr, state:Int, color:Byte Ptr)
	Function gtk_widget_size_allocate(handle:Byte Ptr, allocation:Byte Ptr)
	Function gtk_widget_override_background_color(handle:Byte Ptr, state:Int, color:Byte Ptr)
?
	Function gtk_widget_grab_default(handle:Byte Ptr)
	Function gtk_widget_set_size_request(handle:Byte Ptr, width:Int, height:Int)
	Function gtk_widget_remove_accelerator:Int(handle:Byte Ptr, group:Byte Ptr, key:Int, mods:Int)
	Function gtk_widget_add_accelerator(handle:Byte Ptr, signal:Byte Ptr, group:Byte Ptr, key:Int, mods:Int, flags:Int)
	Function gtk_widget_add_events(handle:Byte Ptr, events:Int)
	Function gtk_widget_set_tooltip_text(handle:Byte Ptr, tooltip:Byte Ptr)
	Function gtk_widget_set_has_tooltip(handle:Byte Ptr, value:Int)
	Function gtk_widget_grab_focus(handle:Byte Ptr)
	Function gtk_widget_queue_draw(handle:Byte Ptr)
	Function gtk_widget_get_state_flags:Int(handle:Byte Ptr)
	Function gtk_widget_get_visible:Int(handle:Byte Ptr)
	Function gtk_widget_set_sensitive(handle:Byte Ptr, sensitive:Int)
	Function gtk_widget_is_sensitive:Int(handle:Byte Ptr)
	Function gtk_widget_get_parent_window:Byte Ptr(handle:Byte Ptr)
	Function gtk_widget_get_pango_context:Byte Ptr(handle:Byte Ptr)
	Function gtk_widget_get_style_context:Byte Ptr(handle:Byte Ptr)
	Function gtk_widget_get_window:Byte Ptr(handle:Byte Ptr)
	Function gtk_widget_has_focus:Int(handle:Byte Ptr)
	
	' gtkfilechooserdialog
	Function gtk_file_chooser_dialog_new:Byte Ptr(title:Byte Ptr, parent:Byte Ptr, action:Int, but1$z, opt1:Int, but2$z, opt2:Int, opt3:Byte Ptr)
	
	' gtkfilechooser
	Function gtk_file_chooser_set_current_folder:Int(handle:Byte Ptr, filename:Byte Ptr)
	Function gtk_file_chooser_set_filename:Int(handle:Byte Ptr, filename:Byte Ptr)
	Function gtk_file_chooser_get_filename:Byte Ptr(handle:Byte Ptr)
	Function gtk_file_chooser_add_filter(handle:Byte Ptr, filter:Byte Ptr)

	' glib
	Function g_free(mem:Byte Ptr)
	
	' gobject
	Function g_object_unref(handle:Byte Ptr)
	Function g_object_set_int(handle:Byte Ptr, property:Byte Ptr, value:Int, _null:Byte Ptr=Null) = "void g_object_set(BBBYTE*, BBBYTE*, BBBYTE*, BBBYTE*, BBBYTE*, BBBYTE*) !"
	Function g_object_set_double(handle:Byte Ptr, property:Byte Ptr, value:Double, _null:Byte Ptr=Null) = "void g_object_set(BBBYTE*, BBBYTE*, BBBYTE*, BBBYTE*, BBBYTE*, BBBYTE*) !"
	Function g_value_set_string(handle:Byte Ptr, str:Byte Ptr)
	Function g_value_unset(handle:Byte Ptr)
	Function g_value_init:Byte Ptr(handle:Byte Ptr, _type:Size_T)
	Function g_value_set_object(handle:Byte Ptr, obj:Byte Ptr)
	Function g_value_get_string:Byte Ptr(handle:Byte Ptr)
	Function g_object_ref:Byte Ptr(handle:Byte Ptr)
	Function g_object_connect:Byte Ptr(gtkWidget:Byte Ptr, signalSpec:Byte Ptr, callback(widget:Byte Ptr, pspec:Byte Ptr, gadget:Object), gadget:Object, flag:Int)="g_object_connect"
	Function g_object_set_data(handle:Byte Ptr, key:Byte Ptr, data:Object)
		
	' gtkfilefilter
	Function gtk_file_filter_new:Byte Ptr()
	Function gtk_file_filter_set_name(handle:Byte Ptr, name:Byte Ptr)
	Function gtk_file_filter_add_pattern(handle:Byte Ptr, pattern:Byte Ptr)
	
	' pango
	Function pango_font_description_free(handle:Byte Ptr)
	Function pango_font_description_new:Byte Ptr()
	Function pango_font_description_set_family(handle:Byte Ptr, family:Byte Ptr)
	Function pango_font_description_set_weight(handle:Byte Ptr, weight:Int)
	Function pango_font_description_set_style(handle:Byte Ptr, style:Int)
	Function pango_font_description_set_absolute_size(handle:Byte Ptr, size:Double)
	Function pango_font_description_get_family:Byte Ptr(handle:Byte Ptr)
	Function pango_font_description_get_style:Int(handle:Byte Ptr)
	Function pango_font_description_get_weight:Int(handle:Byte Ptr)
	Function pango_font_description_get_size:Int(handle:Byte Ptr)
	Function pango_context_set_font_description(handle:Byte Ptr, desc:Byte Ptr)
	Function pango_context_load_fontset:Byte Ptr(handle:Byte Ptr, desc:Byte Ptr, language:Byte Ptr)
	Function pango_fontset_foreach(fontset:Byte Ptr, func:Int(_set:Byte Ptr, _font:Byte Ptr ,data:Object), data:Object)
	Function pango_font_describe:Byte Ptr(font:Byte Ptr)
	
	' pango layout
	Function pango_layout_new:Byte Ptr(context:Byte Ptr)
	Function pango_layout_set_text(handle:Byte Ptr, Text:Byte Ptr, length:Int)
	Function pango_layout_get_pixel_size(handle:Byte Ptr, width:Int Ptr, height:Int Ptr)
	
	' gdk pango
	Function gdk_pango_context_get:Byte Ptr()
	
	' gtkwindow
	Function gtk_window_new:Byte Ptr(_type:Int)
	Function gtk_window_move(handle:Byte Ptr, x:Int, y:Int)
	Function gtk_window_set_default_size(handle:Byte Ptr, width:Int, height:Int)
	Function gtk_window_set_decorated(handle:Byte Ptr, setting:Int)
	Function gtk_window_set_resizable(handle:Byte Ptr, resizable:Int)
	Function gtk_window_set_type_hint(handle:Byte Ptr, hint:Int)
?bmxng
	Function gtk_window_set_geometry_hints(handle:Byte Ptr, widget:Byte Ptr, geometry:GdkGeometry Var, mask:Int)
?Not bmxng
	Function gtk_window_set_geometry_hints(handle:Byte Ptr, widget:Byte Ptr, geometry:Byte Ptr, mask:Int)
?	
	Function gtk_window_set_transient_for(handle:Byte Ptr, parent:Byte Ptr)
	Function gtk_window_add_accel_group(handle:Byte Ptr, accelGroup:Byte Ptr)
	Function gtk_window_get_position(handle:Byte Ptr, x:Int Ptr, y:Int Ptr)
	Function gtk_window_resize(handle:Byte Ptr, width:Int, height:Int)
	Function gtk_window_deiconify(handle:Byte Ptr)
	Function gtk_window_unmaximize(handle:Byte Ptr)
	Function gtk_window_present(handle:Byte Ptr)
	Function gtk_window_set_icon(handle:Byte Ptr, icon:Byte Ptr)
	Function gtk_window_set_title(handle:Byte Ptr, title:Byte Ptr)
	Function gtk_window_get_title:Byte Ptr(handle:Byte Ptr)
	Function gtk_window_maximize(handle:Byte Ptr)
	Function gtk_window_iconify(handle:Byte Ptr)
	Function gtk_window_get_focus:Byte Ptr(handle:Byte Ptr)
	
	' GtkBox
	Function gtk_box_new:Byte Ptr(orientation:Int, spacing:Int)
	Function gtk_box_pack_start(handle:Byte Ptr, child:Byte Ptr, expand:Int, fill:Int, padding:Int)
	Function gtk_box_reorder_child(handle:Byte Ptr, child:Byte Ptr, position:Int)

	' GtkMenuBar
	Function gtk_menu_bar_new:Byte Ptr()
	
	' GtkLayout
	Function gtk_layout_new:Byte Ptr(hadjustment:Byte Ptr, vadjustment:Byte Ptr)
	Function gtk_layout_put(handle:Byte Ptr, child:Byte Ptr, x:Int, y:Int)
	Function gtk_layout_move(handle:Byte Ptr, child:Byte Ptr, x:Int, y:Int)
	Function gtk_layout_get_bin_window:Byte Ptr(handle:Byte Ptr)
	
	' GtkLabel
	Function gtk_label_new:Byte Ptr(str:Byte Ptr)
	Function gtk_label_set_xalign(handle:Byte Ptr, xalign:Float)
	Function gtk_label_set_yalign(handle:Byte Ptr, yalign:Float)
	Function gtk_label_set_text(handle:Byte Ptr, str:Byte Ptr)
	Function gtk_label_get_text:Byte Ptr(handle:Byte Ptr)
	Function gtk_label_set_text_with_mnemonic(handle:Byte Ptr, txt:Byte Ptr)
	
	' GtkContainer
	Function gtk_container_add(handle:Byte Ptr, widget:Byte Ptr)
	Function gtk_container_set_resize_mode(handle:Byte Ptr, _mode:Int)
	Function gtk_container_remove(handle:Byte Ptr, widget:Byte Ptr)
	
	' signals
	Function g_signal_cb2:Int(gtkwidget:Byte Ptr, name:Byte Ptr, callback(widget:Byte Ptr, gadget:Object), gadget:Object, destroyhandler(data:Byte Ptr, user: Byte Ptr), flag:Int) = "int g_signal_connect_data(BBBYTE*, BBBYTE*, BBBYTE*, BBBYTE*, BBBYTE*, int) !"
	Function g_signal_cb2_ret:Int(gtkwidget:Byte Ptr, name:Byte Ptr, callback:Int(widget:Byte Ptr, gadget:Object), gadget:Object, destroyhandler(data:Byte Ptr, user: Byte Ptr), flag:Int) = "int g_signal_connect_data(BBBYTE*, BBBYTE*, BBBYTE*, BBBYTE*, BBBYTE*, int) !"
	Function g_signal_cb3:Int(gtkwidget:Byte Ptr, name:Byte Ptr, callback(widget:Byte Ptr, event:Byte Ptr, gadget:Object), gadget:Object, destroyhandler(data:Byte Ptr, user: Byte Ptr), flag:Int) = "int g_signal_connect_data(BBBYTE*, BBBYTE*, BBBYTE*, BBBYTE*, BBBYTE*, int) !"
	Function g_signal_cb3_ret:Int(gtkwidget:Byte Ptr, name:Byte Ptr, callback:Int(widget:Byte Ptr, event:Byte Ptr, gadget:Object), gadget:Object, destroyhandler(data:Byte Ptr, user: Byte Ptr), flag:Int) = "int g_signal_connect_data(BBBYTE*, BBBYTE*, BBBYTE*, BBBYTE*, BBBYTE*, int) !"
	Function g_signal_cb3a_ret:Int(gtkwidget:Byte Ptr, name:Byte Ptr, callback:Int(widget:Byte Ptr, value:Int, gadget:Object), gadget:Object, destroyhandler(data:Byte Ptr, user: Byte Ptr), flag:Int) = "int g_signal_connect_data(BBBYTE*, BBBYTE*, BBBYTE*, BBBYTE*, BBBYTE*, int) !"
	Function g_signal_cb4:Int(gtkwidget:Byte Ptr, name:Byte Ptr, callback(widget:Byte Ptr,url:Byte Ptr,stream:Byte Ptr,gadget:Object),gadget:Object,destroyhandler(data:Byte Ptr,user: Byte Ptr),flag:Int) = "int g_signal_connect_data(BBBYTE*, BBBYTE*, BBBYTE*, BBBYTE*, BBBYTE*, int) !"
	Function g_signal_cb4a:Int(gtkwidget:Byte Ptr, name:Byte Ptr, callback:Int(widget:Byte Ptr,val1:Int,val2:Double,gadget:Object),gadget:Object,destroyhandler(data:Byte Ptr,user: Byte Ptr),flag:Int) = "int g_signal_connect_data(BBBYTE*, BBBYTE*, BBBYTE*, BBBYTE*, BBBYTE*, int) !"
	Function g_signal_cb5:Int(gtkwidget:Byte Ptr, name:Byte Ptr, callback(widget:Byte Ptr,val1:Int,val2:Int,val3:Int,gadget:Object),gadget:Object,destroyhandler(data:Byte Ptr,user: Byte Ptr),flag:Int) = "int g_signal_connect_data(BBBYTE*, BBBYTE*, BBBYTE*, BBBYTE*, BBBYTE*, int) !"
	Function g_signal_cb8:Int(gtkwidget:Byte Ptr, name:Byte Ptr, callback(widget:Byte Ptr,context:Byte Ptr, val1:Int,val2:Int,data:Byte Ptr,val3:Int,val4:Int,gadget:Object),gadget:Object,destroyhandler(data:Byte Ptr,user: Byte Ptr),flag:Int) = "int g_signal_connect_data(BBBYTE*, BBBYTE*, BBBYTE*, BBBYTE*, BBBYTE*, int) !"
	Function g_signal_handler_disconnect(gtkwidget:Byte Ptr, handlerid:Long)
	Function g_signal_tabchange:Int(gtkwidget:Byte Ptr, name:Byte Ptr, callback(widget:Byte Ptr,a:Byte Ptr, index:Int,gadget:Object),gadget:Object,destroyhandler(data:Byte Ptr,user: Byte Ptr),flag:Int) = "int g_signal_connect_data(BBBYTE*, BBBYTE*, BBBYTE*, BBBYTE*, BBBYTE*, int) !"
	
	' accelerator groups
	Function gtk_accel_group_new:Byte Ptr()
	Function gtk_accelerator_parse(accel:Byte Ptr, key:Int Ptr, mods:Int Ptr)
	
	' GtkMenu
	Function gtk_menu_popup(handle:Byte Ptr, parentMenuShell:Byte Ptr, parentMenuItem:Byte Ptr, func:Byte Ptr, data:Byte Ptr, button:Int, activateTime:Int)
	
	' GtkMisc
	Function gtk_misc_set_alignment(handle:Byte Ptr, xalign:Float, yalign:Float)
	
	' image data
	Function gdk_pixbuf_new_from_data:Byte Ptr(data:Byte Ptr, colorspace:Int, has_alpha:Int, bits_per_sample:Int, width:Int, height:Int, ..
                    rowstride:Int, destroy_fn:Byte Ptr, data_fn:Byte Ptr)
	Function gdk_pixbuf_new_from_bytes:Byte Ptr(data:Byte Ptr, colorspace:Int, has_alpha:Int, bits_per_sample:Int, width:Int, height:Int, rowstride:Int)
	Function gdk_pixbuf_get_type:Size_T()
	Function gdk_pixbuf_copy_area(handle:Byte Ptr, sx:Int, sy:Int, width:Int, height:Int, dest:Byte Ptr, dx:Int, dy:Int)
	Function gdk_pixbuf_scale_simple:Byte Ptr(src:Byte Ptr, dw:Int, dh:Int, inter:Int)
	Function gdk_pixbuf_new:Byte Ptr(colorspace:Int, alpha:Int, bps:Int, width:Int, height:Int)
	Function gdk_pixbuf_copy:Byte Ptr(handle:Byte Ptr)
	
	' GtkButton
	Function gtk_button_set_label(handle:Byte Ptr, label:Byte Ptr)
	Function gtk_button_set_use_underline(handle:Byte Ptr, useUnderline:Int)
	Function gtk_button_get_label:Byte Ptr(handle:Byte Ptr)
	Function gtk_button_new_with_label:Byte Ptr(label:Byte Ptr)
	Function gtk_button_set_image(handle:Byte Ptr, image:Byte Ptr)
	Function gtk_button_set_image_position(handle:Byte Ptr, pos:Int)
	
	' GtkBin
	Function gtk_bin_get_child:Byte Ptr(handle:Byte Ptr)
	
	' GtkToggleButton
	Function gtk_toggle_button_get_active:Int(handle:Byte Ptr)
	Function gtk_toggle_button_set_active(handle:Byte Ptr, active:Int)
	Function gtk_toggle_button_set_mode(handle:Byte Ptr, indicator:Int)
	
	' GtkRadioButton
	Function gtk_radio_button_new_with_label:Byte Ptr(handle:Byte Ptr, label:Byte Ptr)
	Function gtk_radio_button_get_group:Byte Ptr(handle:Byte Ptr)
	
	' GtkCheckButton
	Function gtk_check_button_new_with_label:Byte Ptr(label:Byte Ptr)
	
	' GtkEventBox
	Function gtk_event_box_new:Byte Ptr()
	Function gtk_event_box_set_visible_window(handle:Byte Ptr, visibleWindow:Int)
	
	' GtkSeparator
	Function gtk_separator_new:Byte Ptr(orientation:Int)
	
	' GtkFrame
	Function gtk_frame_new:Byte Ptr(label:Byte Ptr)
	Function gtk_frame_set_shadow_type(handle:Byte Ptr, shadowType:Int)
	Function gtk_frame_set_label(handle:Byte Ptr, label:Byte Ptr)
	
	' key values
	Function gdk_keyval_to_unicode:Int(keyval:Int)
	
	' GtkEntry
	Function gtk_entry_new:Byte Ptr()
	Function gtk_entry_set_visibility(handle:Byte Ptr, visible:Int)
	Function gtk_entry_get_text:Byte Ptr(handle:Byte Ptr)
	Function gtk_entry_set_text(handle:Byte Ptr, txt:Byte Ptr)
	
	' GtkEditable
	Function gtk_editable_cut_clipboard(handle:Byte Ptr)
	Function gtk_editable_copy_clipboard(handle:Byte Ptr)
	Function gtk_editable_paste_clipboard(handle:Byte Ptr)
	
	' GtkListStore
	Function gtk_list_store_set_value(handle:Byte Ptr, iter:Byte Ptr, column:Int, value:Byte Ptr)
	Function gtk_list_store_new:Byte Ptr(COLS:Int, type1:Size_T, type2:Size_T)
	Function gtk_list_store_insert(handle:Byte Ptr, iter:Byte Ptr, position:Int)
	Function gtk_list_store_clear(handle:Byte Ptr)
	Function gtk_list_store_remove:Int(handle:Byte Ptr, iter:Byte Ptr)
	
	' GtkTreeStore
	Function gtk_tree_store_set_value(handle:Byte Ptr, iter:Byte Ptr, column:Int, value:Byte Ptr)
	Function gtk_tree_store_append(handle:Byte Ptr, iter:Byte Ptr, parent:Byte Ptr)
	Function gtk_tree_store_insert(handle:Byte Ptr, iter:Byte Ptr, parent:Byte Ptr, position:Int)
	Function gtk_tree_store_remove:Int(handle:Byte Ptr, iter:Byte Ptr)
	Function gtk_tree_store_new:Byte Ptr(columns:Int, _type1:Size_T, _type2:Size_T)
	
	' GtkTreeView
	Function gtk_tree_view_append_column:Int(handle:Byte Ptr, column:Byte Ptr)
	Function gtk_tree_view_new:Byte Ptr()
	Function gtk_tree_view_set_headers_visible(handle:Byte Ptr, visible:Int)
	Function gtk_tree_view_get_selection:Byte Ptr(handle:Byte Ptr)
	Function gtk_tree_view_set_model(handle:Byte Ptr, model:Byte Ptr)
	Function gtk_tree_view_get_path_at_pos:Int(handle:Byte Ptr, x:Int, y:Int, path:Byte Ptr Ptr, column:Byte Ptr Ptr, cellX:Int Ptr, celly:Int Ptr)
	Function gtk_tree_view_expand_row:Int(handle:Byte Ptr, path:Byte Ptr, openAll:Int)
	Function gtk_tree_view_collapse_row:Int(handle:Byte Ptr, path:Byte Ptr)
	
	' GtkTreeViewColumn
	Function gtk_tree_view_column_new:Byte Ptr()
	Function gtk_tree_view_column_pack_start(handle:Byte Ptr, cell:Byte Ptr, expand:Int)
	Function gtk_tree_view_column_pack_end(handle:Byte Ptr, cell:Byte Ptr, expand:Int)
	Function gtk_tree_view_column_add_attribute(handle:Byte Ptr, renderer:Byte Ptr, attr$z, column:Int)
	
	' GtkCellRendererPixbuf
	Function gtk_cell_renderer_pixbuf_new:Byte Ptr()

	' GtkCellRendererText
	Function gtk_cell_renderer_text_new:Byte Ptr()
	
	' GtkCellLayout
	Function gtk_cell_layout_clear(handle:Byte Ptr)
	Function gtk_cell_layout_add_attribute(handle:Byte Ptr, cell:Byte Ptr, attr$z, column:Int)
	Function gtk_cell_layout_pack_start(handle:Byte Ptr, cell:Byte Ptr, expand:Int)
	Function gtk_cell_layout_pack_end(handle:Byte Ptr, cell:Byte Ptr, expand:Int)
	
	' GtkComboBox
	Function gtk_combo_box_new_with_entry:Byte Ptr()
	Function gtk_combo_box_new:Byte Ptr()
	Function gtk_combo_box_set_model(handle:Byte Ptr, model:Byte Ptr)
	Function gtk_combo_box_set_entry_text_column(handle:Byte Ptr, column:Int)
	Function gtk_combo_box_get_active:Int(handle:Byte Ptr)
	Function gtk_combo_box_set_active(handle:Byte Ptr, index:Int)
	Function gtk_combo_box_get_active_iter:Int(handle:Byte Ptr, iter:Byte Ptr)
	
	' GtkTreeModel
	Function gtk_tree_model_iter_nth_child:Int(handle:Byte Ptr, iter:Byte Ptr, parent:Byte Ptr, index:Int)
	Function gtk_tree_model_get_value(handle:Byte Ptr, iter:Byte Ptr, column:Int, value:Byte Ptr)
	Function gtk_tree_model_get_string_from_iter:Byte Ptr(handle:Byte Ptr, iter:Byte Ptr)
	Function gtk_tree_path_to_string:Byte Ptr(handle:Byte Ptr)
	Function gtk_tree_path_free(handle:Byte Ptr)
	Function gtk_tree_path_new_from_string:Byte Ptr(path$z)
	Function gtk_tree_model_get_iter_from_string:Int(handle:Byte Ptr, iter:Byte Ptr, path$z)
	Function gtk_tree_model_get_path:Byte Ptr(handle:Byte Ptr, iter:Byte Ptr)
	
	' GtkScrolledWindow
	Function gtk_scrolled_window_new:Byte Ptr(hadjustment:Byte Ptr, vadjustment:Byte Ptr)
	Function gtk_scrolled_window_set_policy(handle:Byte Ptr, hpolicy:Int, vpolicy:Int)
	
	' GtkTreeSelection
	Function gtk_tree_selection_set_mode(handle:Byte Ptr, _type:Int)
	Function gtk_tree_selection_select_iter(handle:Byte Ptr, iter:Byte Ptr)
	Function gtk_tree_selection_unselect_iter(handle:Byte Ptr, iter:Byte Ptr)
	Function gtk_tree_selection_iter_is_selected:Int(handle:Byte Ptr, iter:Byte Ptr)
	Function gtk_tree_selection_get_selected:Int(handle:Byte Ptr, model:Byte Ptr Ptr, iter:Byte Ptr)
	Function gtk_tree_selection_select_path(handle:Byte Ptr, path:Byte Ptr)
	
	' GtkRange
	Function gtk_range_set_range(handle:Byte Ptr, _min:Double, _max:Double)
	Function gtk_range_set_value(handle:Byte Ptr, value:Double)
	Function gtk_range_get_value:Double(handle:Byte Ptr)
	Function gtk_range_set_round_digits(handle:Byte Ptr, roundDigits:Int)
	Function gtk_range_set_increments(handle:Byte Ptr, _step:Double, _page:Double)
	Function gtk_range_get_adjustment:Byte Ptr(handle:Byte Ptr)
	
	' GtkScale
	Function gtk_scale_new_with_range:Byte Ptr(orientation:Int, _min:Double, _max:Double, _step:Double)
	Function gtk_scale_set_draw_value(handle:Byte Ptr, value:Int)
	
	' GtkScrollbar
	Function gtk_scrollbar_new:Byte Ptr(orientation:Int, adjustment:Byte Ptr)
	
	' GtkAdjustment
	Function gtk_adjustment_set_page_size(handle:Byte Ptr, pageSize:Double)
	
	' GtkSpinButton
	Function gtk_spin_button_new_with_range:Byte Ptr(_min:Double, _max:Double, _step:Double)
	Function gtk_spin_button_set_range(handle:Byte Ptr, _min:Double, _max:Double)
	Function gtk_spin_button_set_increments(handle:Byte Ptr, _step:Double, _page:Double)
	Function gtk_spin_button_set_value(handle:Byte Ptr, value:Double)
	Function gtk_spin_button_get_value:Double(handle:Byte Ptr)
	
	' GtkProgressBar
	Function gtk_progress_bar_new:Byte Ptr()
	Function gtk_progress_bar_set_fraction(handle:Byte Ptr, fraction:Double)
	Function gtk_progress_bar_get_fraction:Double(handle:Byte Ptr)
	
	' GtkToolbar
	Function gtk_toolbar_new:Byte Ptr()
	Function gtk_toolbar_set_style(handle:Byte Ptr, style:Int)
	Function gtk_toolbar_insert(handle:Byte Ptr, item:Byte Ptr, pos:Int)
	Function gtk_toolbar_get_item_index:Int(handle:Byte Ptr, item:Byte Ptr)
	
	' GtkToolButton
	Function gtk_tool_button_set_label(handle:Byte Ptr, label:Byte Ptr)
	Function gtk_tool_button_set_icon_widget(handle:Byte Ptr, icon:Byte Ptr)
	Function gtk_tool_button_new:Byte Ptr(icon:Byte Ptr, label:Byte Ptr)
	Function gtk_tool_button_set_icon_name(handle:Byte Ptr, name$z)
	
	' GtkToggleToolButton
	Function gtk_toggle_tool_button_new:Byte Ptr()
	Function gtk_toggle_tool_button_get_active:Int(handle:Byte Ptr)
	Function gtk_toggle_tool_button_set_active(handle:Byte Ptr, active:Int)
	
	' GtkImage
	Function gtk_image_new_from_pixbuf:Byte Ptr(pixbuf:Byte Ptr)
	Function gtk_image_new:Byte Ptr()
	Function gtk_image_set_from_pixbuf(handle:Byte Ptr, pixbuf:Byte Ptr)
	Function gtk_image_clear(handle:Byte Ptr)
	
	' GtkSeparatorToolItem
	Function gtk_separator_tool_item_new:Byte Ptr()
	
	' GtkToolItem
	Function gtk_tool_item_set_tooltip_text(handle:Byte Ptr, txt:Byte Ptr)
	
	' GtkNotebook
	Function gtk_notebook_new:Byte Ptr()
	Function gtk_notebook_set_scrollable(handle:Byte Ptr, scrollable:Int)
	Function gtk_notebook_get_nth_page:Byte Ptr(handle:Byte Ptr, page:Int)
	Function gtk_notebook_insert_page:Int(handle:Byte Ptr, child:Byte Ptr, label:Byte Ptr, pos:Int)
	Function gtk_notebook_get_tab_label:Byte Ptr(handle:Byte Ptr, child:Byte Ptr)
	Function gtk_notebook_get_current_page:Int(handle:Byte Ptr)
	Function gtk_notebook_remove_page(handle:Byte Ptr, page:Int)
	Function gtk_notebook_set_current_page(handle:Byte Ptr, page:Int)
	
	' GdkWindow
	Function gdk_window_get_device_position:Byte Ptr(handle:Byte Ptr, device:Byte Ptr, x:Int Var, y:Int Var, mask:Int Var)
	Function gdk_window_set_cursor(handle:Byte Ptr, cursor:Byte Ptr)
	
	' GdkCairo
	Function gdk_cairo_create:Byte Ptr(handle:Byte Ptr)
	Function gdk_cairo_set_source_pixbuf(handle:Byte Ptr, pixbuf:Byte Ptr, x:Double, y:Double)
	
	' Cairo
	Function cairo_paint(handle:Byte Ptr)
	Function cairo_fill(handle:Byte Ptr)
	Function cairo_destroy(handle:Byte Ptr)
	
	' atoms
	Function gdk_atom_intern:Byte Ptr(name:Byte Ptr, onlyIfExists:Int)
	
	' GtkClipboard
	Function gtk_clipboard_get:Byte Ptr(selection:Byte Ptr)
	Function gtk_clipboard_set_text(handle:Byte Ptr, txt:Byte Ptr, length:Int)
	Function gtk_clipboard_wait_for_text:Byte Ptr(handle:Byte Ptr)
	
	' GtkTextBuffer
	Function gtk_text_buffer_new:Byte Ptr(table:Byte Ptr)
	Function gtk_text_buffer_get_tag_table:Byte Ptr(handle:Byte Ptr)
	Function gtk_text_buffer_get_end_iter(handle:Byte Ptr, iter:Byte Ptr)
	Function gtk_text_buffer_insert(handle:Byte Ptr, iter:Byte Ptr, txt:Byte Ptr, length:Int)
	Function gtk_text_buffer_get_iter_at_line(handle:Byte Ptr, iter:Byte Ptr, line:Int)
	Function gtk_text_buffer_get_iter_at_offset(handle:Byte Ptr, iter:Byte Ptr, offset:Int)
	Function gtk_text_buffer_get_text:Byte Ptr(handle:Byte Ptr, _start:Byte Ptr, _end:Byte Ptr, includeHidden:Int)
	Function gtk_text_buffer_get_line_count:Int(handle:Byte Ptr)
	Function gtk_text_buffer_get_char_count:Int(handle:Byte Ptr)
	Function gtk_text_buffer_get_selection_bounds:Int(handle:Byte Ptr, _start:Byte Ptr, _end:Byte Ptr)
	Function gtk_text_buffer_set_text(handle:Byte Ptr, txt:Byte Ptr, length:Int)
	Function gtk_text_buffer_place_cursor(handle:Byte Ptr, where_:Byte Ptr)
	Function gtk_text_buffer_select_range(handle:Byte Ptr, ins:Byte Ptr, bound:Byte Ptr)
	Function gtk_text_buffer_cut_clipboard(handle:Byte Ptr, clipboard:Byte Ptr, editable:Int)
	Function gtk_text_buffer_copy_clipboard(handle:Byte Ptr, clipboard:Byte Ptr)
	Function gtk_text_buffer_paste_clipboard(handle:Byte Ptr, clipboard:Byte Ptr, overide:Byte Ptr, editable:Int)
	Function gtk_text_buffer_delete(handle:Byte Ptr, _start:Byte Ptr, _end:Byte Ptr)
	Function gtk_text_buffer_get_insert:Byte Ptr(handle:Byte Ptr)
	Function gtk_text_buffer_remove_all_tags(handle:Byte Ptr, _start:Byte Ptr, _end:Byte Ptr)
	Function gtk_text_buffer_apply_tag(handle:Byte Ptr, tag:Byte Ptr, _start:Byte Ptr, _end:Byte Ptr)
	
	' GtkTextView
	Function gtk_text_view_new_with_buffer:Byte Ptr(handle:Byte Ptr)
	Function gtk_text_view_set_wrap_mode(handle:Byte Ptr, wrapMode:Int)
	Function gtk_text_view_set_editable(handle:Byte Ptr, setting:Int)
	Function gtk_text_view_scroll_to_iter(handle:Byte Ptr, iter:Byte Ptr, withinMargin:Double, useAlign:Int, xAlign:Double, yAlign:Double)
	Function gtk_text_view_scroll_mark_onscreen(handle:Byte Ptr, mark:Byte Ptr)
	Function gtk_text_view_get_tabs:Byte Ptr(handle:Byte Ptr)
	Function gtk_text_view_set_tabs(handle:Byte Ptr, tabs:Byte Ptr)
		
	' GtkTextIter
	Function gtk_text_iter_get_line:Int(handle:Byte Ptr)
	Function gtk_text_iter_get_offset:Int(handle:Byte Ptr)
	Function gtk_text_iter_backward_char:Int(handle:Byte Ptr)
	
	' GtkTextTagTable
	Function gtk_text_tag_table_lookup:Byte Ptr(handle:Byte Ptr, txt$z)
	
	' pango tab array
	Function pango_tab_array_free(handle:Byte Ptr)
	Function pango_tab_array_new_with_positions:Byte Ptr(size:Int, pixels:Int, align:Int, pos:Int)
	
	' GtkSeparatorMenuItem
	Function gtk_separator_menu_item_new:Byte Ptr()
	
	' GtkMenuItem
	Function gtk_menu_item_new_with_mnemonic:Byte Ptr(label:Byte Ptr)
	Function gtk_menu_item_new_with_label:Byte Ptr(label:Byte Ptr)
	Function gtk_menu_item_set_submenu(handle:Byte Ptr, submenu:Byte Ptr)
	
	' GtkMenu
	Function gtk_menu_new:Byte Ptr()
	
	' GtkMenuShell
	Function gtk_menu_shell_append(handle:Byte Ptr, child:Byte Ptr)
	Function gtk_menu_shell_insert(handle:Byte Ptr, child:Byte Ptr, pos:Int)
	
	' settings
	Function gtk_settings_set_string_property(settings:Byte Ptr, name:Byte Ptr, v_string:Byte Ptr, origin:Byte Ptr)
	Function gtk_settings_get_default:Byte Ptr()
	
	' GtkCheckMenuItem
	Function gtk_check_menu_item_get_active:Int(handle:Byte Ptr)
	Function gtk_check_menu_item_new_with_mnemonic:Byte Ptr(label:Byte Ptr)
	Function gtk_check_menu_item_new_with_label:Byte Ptr(label:Byte Ptr)
	Function gtk_check_menu_item_set_active(handle:Byte Ptr, active:Int)

	' GtkDrawingArea
	Function gtk_drawing_area_new:Byte Ptr()

	' GtkIconTheme
	Function gtk_icon_theme_add_builtin_icon(name$z, size:Int, pixbuf:Byte Ptr)

	' GtkColorSelection
	Function gtk_color_selection_dialog_new:Byte Ptr(title:Byte Ptr)
	Function gtk_color_selection_dialog_get_color_selection:Byte Ptr(handle:Byte Ptr)
?bmxng
	Function gtk_color_selection_set_current_rgba(handle:Byte Ptr, rgba:GdkRGBA Var)
	Function gtk_color_selection_get_current_rgba(handle:Byte Ptr, rgba:GdkRGBA Var)
?Not bmxng
	Function gtk_color_selection_set_current_rgba(handle:Byte Ptr, rgba:Byte Ptr)
	Function gtk_color_selection_get_current_rgba(handle:Byte Ptr, rgba:Byte Ptr)
?
	
	' GtkFontChooserDialog
	Function gtk_font_chooser_dialog_new:Byte Ptr(title:Byte Ptr, parent:Byte Ptr)
	Function gtk_font_chooser_set_font_desc(handle:Byte Ptr, desc:Byte Ptr)
	Function gtk_font_chooser_get_font_desc:Byte Ptr(handle:Byte Ptr)
	
	' GdkMonitor
	'Function gdk_display_get_primary_monitor:Byte Ptr(display:Byte Ptr)
	
	' drag n drop
	Function gtk_drag_dest_set(handle:Byte Ptr, flags:Int, targets:Byte Ptr, numTargets:Int, actions:Int)
	Function gtk_drag_dest_add_uri_targets(handle:Byte Ptr)
	
	' glue
	Function bmx_gtk3_gtkdesktop_gethertz:Int()
	Function bmx_gtk3_gvalue_new:Byte Ptr(_type:Int)
	Function bmx_gtk3_gvalue_free(_value:Byte Ptr)
	Function bmx_gtk3_gtktreeiter_new:Byte Ptr()
	Function bmx_gtk3_gtktreeiter_free(handle:Byte Ptr)
	Function bmx_gtk3_stylecontext_get_fontdesc:Byte Ptr(handle:Byte Ptr)
	Function bmx_gtk3_gtktextiter_new:Byte Ptr()
	Function bmx_gtk3_gtktextiter_free(iter:Byte Ptr)
?bmxng
	Function bmx_gtk3_set_text_tag_style:Byte Ptr(handle:Byte Ptr, tag$z, _fg:GdkRGBA Var, _style:Int, _weight:Int, _under:Int, _strike:Int)
	Function bmx_gtk3_set_text_bg_tag:Byte Ptr(handle:Byte Ptr, tag$z, _bg:GdkRGBA Var)
?Not bmxng
	Function bmx_gtk3_set_text_tag_style:Byte Ptr(handle:Byte Ptr, tag$z, _fg:Byte Ptr, _style:Int, _weight:Int, _under:Int, _strike:Int)
	Function bmx_gtk3_set_text_bg_tag:Byte Ptr(handle:Byte Ptr, tag$z, _bg:Byte Ptr)
?
	' event types
	Function bmx_gtk3maxgui_gdkeventbutton(event:Byte Ptr, x:Double Ptr, y:Double Ptr, button:Int Ptr)
	Function bmx_gtk3maxgui_gdkeventmotion(event:Byte Ptr, x:Double Ptr, y:Double Ptr, state:Int Ptr)
	Function bmx_gtk3maxgui_gdkeventscroll(event:Byte Ptr, x:Double Ptr, y:Double Ptr, direction:Int Ptr)
	Function bmx_gtk3maxgui_gdkeventkey(event:Byte Ptr, keyval:Int Ptr, state:Int Ptr)
	Function bmx_gtk3maxgui_gdkeventconfigure(event:Byte Ptr, x:Int Ptr, y:Int Ptr, w:Int Ptr, h:Int Ptr)
	Function bmx_gtk3maxgui_gdkeventwindowstate(event:Byte Ptr, state:Int Ptr)
	Function bmx_gtk3maxgui_gdkeventmotiondevice:Byte Ptr(event:Byte Ptr)

	Function bmx_gtk3_selection_data_get_uris:String[](data:Byte Ptr)
End Extern

' gadget identifiers
Const GTK_WINDOW:Int = 0
Const GTK_BUTTON:Int = 1
Const GTK_RADIOBUTTON:Int = 2
Const GTK_CHECKBUTTON:Int = 3
Const GTK_TOGGLEBUTTON:Int = 4
Const GTK_LABEL:Int = 5
Const GTK_MENUITEM:Int = 6
Const GTK_TEXTFIELD:Int = 7
Const GTK_TEXTAREA:Int = 8
Const GTK_PANEL:Int = 9
Const GTK_COMBOBOX:Int = 10
Const GTK_HTMLVIEW:Int = 11
Const GTK_TABBER:Int = 12
Const GTK_PROGRESSBAR:Int = 13
Const GTK_SCROLLBAR:Int = 14
Const GTK_TRACKBAR:Int = 15
Const GTK_STEPPER:Int = 16
Const GTK_DESKTOP:Int = 17
Const GTK_TOOLBAR:Int = 18
Const GTK_LISTBOX:Int = 19
Const GTK_TREEVIEW:Int = 20
Const GTK_CANVAS:Int = 21


' GtkDialogFlags
Const GTK_DIALOG_MODAL:Int = 0
Const GTK_DIALOG_DESTROY_WITH_PARENT:Int = 1

' GtkButtonsType
Const GTK_BUTTONS_NONE:Int = 0
Const GTK_BUTTONS_OK:Int = 1
Const GTK_BUTTONS_CLOSE:Int = 2
Const GTK_BUTTONS_CANCEL:Int = 3
Const GTK_BUTTONS_YES_NO:Int = 4
Const GTK_BUTTONS_OK_CANCEL:Int = 5

' GtkMessageType
Const GTK_MESSAGE_INFO:Int = 0
Const GTK_MESSAGE_WARNING:Int = 1
Const GTK_MESSAGE_QUESTION:Int = 2
Const GTK_MESSAGE_ERROR:Int = 3
Const GTK_MESSAGE_OTHER:Int = 4

' GtkResponseType
Const GTK_RESPONSE_NONE:Int = -1
Const GTK_RESPONSE_REJECT:Int = -2
Const GTK_RESPONSE_ACCEPT:Int = -3
Const GTK_RESPONSE_DELETE_EVENT:Int = -4
Const GTK_RESPONSE_OK:Int     = -5
Const GTK_RESPONSE_CANCEL:Int = -6
Const GTK_RESPONSE_CLOSE:Int  = -7
Const GTK_RESPONSE_YES:Int    = -8
Const GTK_RESPONSE_NO:Int     = -9
Const GTK_RESPONSE_APPLY:Int  = -10
Const GTK_RESPONSE_HELP:Int   = -11

' GtkFileChooserAction
Const GTK_FILE_CHOOSER_ACTION_OPEN:Int = 0
Const GTK_FILE_CHOOSER_ACTION_SAVE:Int = 1
Const GTK_FILE_CHOOSER_ACTION_SELECT_FOLDER:Int = 2
Const GTK_FILE_CHOOSER_ACTION_CREATE_FOLDER:Int = 3

' PangoStyle
Const PANGO_STYLE_NORMAL:Int = 0
Const PANGO_STYLE_OBLIQUE:Int = 1
Const PANGO_STYLE_ITALIC:Int = 2

' PangoWeight
Const PANGO_WEIGHT_ULTRALIGHT:Int = 200
Const PANGO_WEIGHT_LIGHT:Int = 300
Const PANGO_WEIGHT_NORMAL:Int = 400
Const PANGO_WEIGHT_SEMIBOLD:Int = 600
Const PANGO_WEIGHT_BOLD:Int = 700
Const PANGO_WEIGHT_ULTRABOLD:Int = 800
Const PANGO_WEIGHT_HEAVY:Int = 900

' PangoUnderline
Const PANGO_UNDERLINE_NONE:Int = 0
Const PANGO_UNDERLINE_SINGLE:Int = 1
Const PANGO_UNDERLINE_DOUBLE:Int = 2
Const PANGO_UNDERLINE_LOW:Int = 3
Const PANGO_UNDERLINE_ERROR:Int = 4

' GtkOrientation
Const GTK_ORIENTATION_HORIZONTAL:Int = 0
Const GTK_ORIENTATION_VERTICAL:Int = 1

' gtkwindowtype
Const GTK_WINDOW_TOPLEVEL:Int = 0
Const GTK_WINDOW_POPUP:Int = 1

' gtkwindowposition
Const GTK_WIN_POS_NONE:Int = 0
Const GTK_WIN_POS_CENTER:Int = 1
Const GTK_WIN_POS_MOUSE:Int = 2
Const GTK_WIN_POS_CENTER_ALWAYS:Int = 3
Const GTK_WIN_POS_CENTER_ON_PARENT:Int = 4

' GdkWindowTypeHint
Const GDK_WINDOW_TYPE_HINT_NORMAL:Int       = 0
Const GDK_WINDOW_TYPE_HINT_DIALOG:Int       = 1
Const GDK_WINDOW_TYPE_HINT_MENU:Int         = 2
Const GDK_WINDOW_TYPE_HINT_TOOLBAR:Int      = 3
Const GDK_WINDOW_TYPE_HINT_SPLASHSCREEN:Int = 4
Const GDK_WINDOW_TYPE_HINT_UTILITY:Int      = 5
Const GDK_WINDOW_TYPE_HINT_DOCK:Int         = 6
Const GDK_WINDOW_TYPE_HINT_DESKTOP:Int      = 7
Const GDK_WINDOW_TYPE_HINT_DROPDOWN_MENU:Int= 8  ' A drop down menu (from a menubar)
Const GDK_WINDOW_TYPE_HINT_POPUP_MENU:Int   = 9  ' A popup menu (from Right-click)
Const GDK_WINDOW_TYPE_HINT_TOOLTIP:Int      = 10
Const GDK_WINDOW_TYPE_HINT_NOTIFICATION:Int = 11
Const GDK_WINDOW_TYPE_HINT_COMBO:Int        = 12
Const GDK_WINDOW_TYPE_HINT_DND:Int          = 13

' GdkWindowHints
Const GDK_HINT_POS:Int	     = 1
Const GDK_HINT_MIN_SIZE:Int    = 2
Const GDK_HINT_MAX_SIZE:Int    = 4
Const GDK_HINT_BASE_SIZE:Int   = 8
Const GDK_HINT_ASPECT:Int      = 16
Const GDK_HINT_RESIZE_INC:Int  = 32
Const GDK_HINT_WIN_GRAVITY:Int = 64
Const GDK_HINT_USER_POS:Int    = 128
Const GDK_HINT_USER_SIZE:Int   = 256

' GdkWindowState
Const GDK_WINDOW_STATE_WITHDRAWN:Int  = 1 Shl 0
Const GDK_WINDOW_STATE_ICONIFIED:Int  = 1 Shl 1
Const GDK_WINDOW_STATE_MAXIMIZED:Int  = 1 Shl 2
Const GDK_WINDOW_STATE_STICKY:Int     = 1 Shl 3
Const GDK_WINDOW_STATE_FULLSCREEN:Int = 1 Shl 4
Const GDK_WINDOW_STATE_ABOVE:Int      = 1 Shl 5
Const GDK_WINDOW_STATE_BELOW:Int      = 1 Shl 6
Const GDK_WINDOW_STATE_FOCUSED:Int    = 1 Shl 7
Const GDK_WINDOW_STATE_TILED:Int      = 1 Shl 8

' GdkColorspace
Const GDK_COLORSPACE_RGB:Int = 0

' GtkStateType
Const GTK_STATE_FLAG_NORMAL:Int = 0
Const GTK_STATE_FLAG_ACTIVE:Int = 1
Const GTK_STATE_FLAG_PRELIGHT:Int = 2
Const GTK_STATE_FLAG_SELECTED:Int = 3
Const GTK_STATE_FLAG_INSENSITIVE:Int = 4
Const GTK_STATE_FLAG_INCONSISTENT:Int = 5
Const GTK_STATE_FLAG_FOCUSED:Int = 6
Const GTK_STATE_FLAG_BACKDROP:Int = 7
Const GTK_STATE_FLAG_DIR_LTR:Int = 8
Const GTK_STATE_FLAG_DIR_RTL:Int = 9

' GtkAccelFlags
Const GTK_ACCEL_VISIBLE:Int = 1 ' display in GtkAccelLabel?
Const GTK_ACCEL_LOCKED:Int  = 2 ' is it removable?
Const GTK_ACCEL_MASK:Int    = 7

Const GDK_EXPOSURE_MASK:Int = 1 Shl 1
Const GDK_POINTER_MOTION_MASK:Int = 1 Shl 2
Const GDK_POINTER_MOTION_HINT_MASK:Int = 1 Shl 3
Const GDK_BUTTON_MOTION_MASK:Int = 1 Shl 4
Const GDK_BUTTON1_MOTION_MASK:Int = 1 Shl 5
Const GDK_BUTTON2_MOTION_MASK:Int = 1 Shl 6
Const GDK_BUTTON3_MOTION_MASK:Int = 1 Shl 7
Const GDK_BUTTON_PRESS_MASK:Int = 1 Shl 8
Const GDK_BUTTON_RELEASE_MASK:Int = 1 Shl 9
Const GDK_KEY_PRESS_MASK:Int = 1 Shl 10
Const GDK_KEY_RELEASE_MASK:Int = 1 Shl 11
Const GDK_ENTER_NOTIFY_MASK:Int = 1 Shl 12
Const GDK_LEAVE_NOTIFY_MASK:Int = 1 Shl 13
Const GDK_FOCUS_CHANGE_MASK:Int = 1 Shl 14
Const GDK_STRUCTURE_MASK:Int = 1 Shl 15
Const GDK_PROPERTY_CHANGE_MASK:Int = 1 Shl 16
Const GDK_VISIBILITY_NOTIFY_MASK:Int = 1 Shl 17
Const GDK_PROXIMITY_IN_MASK:Int = 1 Shl 18
Const GDK_PROXIMITY_OUT_MASK:Int = 1 Shl 19
Const GDK_SUBSTRUCTURE_MASK:Int = 1 Shl 20
Const GDK_SCROLL_MASK:Int = 1 Shl 21
Const GDK_TOUCH_MASK:Int = 1 Shl 22
Const GDK_SMOOTH_SCROLL_MASK:Int = 1 Shl 23

' GtkShadowType
Const GTK_SHADOW_NONE:Int = 0
Const GTK_SHADOW_IN:Int = 1
Const GTK_SHADOW_OUT:Int = 2
Const GTK_SHADOW_ETCHED_IN:Int = 3
Const GTK_SHADOW_ETCHED_OUT:Int = 4

' GType
Const G_TYPE_STRING:Int = 16 Shl 2
Const G_TYPE_POINTER:Int = 17 Shl 2

' GtkPolicyType
Const GTK_POLICY_ALWAYS:Int = 0
Const GTK_POLICY_AUTOMATIC:Int = 1
Const GTK_POLICY_NEVER:Int = 2

' GtkSelectionMode
Const GTK_SELECTION_NONE:Int = 0                       ' Nothing can be selected
Const GTK_SELECTION_SINGLE:Int = 1
Const GTK_SELECTION_BROWSE:Int = 2
Const GTK_SELECTION_MULTIPLE:Int = 3

' GtkResizeMode
Const GTK_RESIZE_PARENT:Int = 0
Const GTK_RESIZE_QUEUE:Int = 1
Const GTK_RESIZE_IMMEDIATE:Int = 2

' GtkToolbarStyle
Const GTK_TOOLBAR_ICONS:Int = 0
Const GTK_TOOLBAR_TEXT:Int = 1
Const GTK_TOOLBAR_BOTH:Int = 2
Const GTK_TOOLBAR_BOTH_HORIZ:Int = 3

' GdkScrollDirection
Const GDK_SCROLL_UP:Int = 0
Const GDK_SCROLL_DOWN:Int = 1
Const GDK_SCROLL_LEFT:Int = 2
Const GDK_SCROLL_RIGHT:Int = 3
Const GDK_SCROLL_SMOOTH:Int = 4

' GdkInterpType
Const GDK_INTERP_NEAREST:Int = 0
Const GDK_INTERP_TILES:Int = 1
Const GDK_INTERP_BILINEAR:Int = 2
Const GDK_INTERP_HYPER:Int = 3

' GtkPositionType
Const GTK_POS_LEFT:Int = 0
Const GTK_POS_RIGHT:Int = 1
Const GTK_POS_TOP:Int = 2
Const GTK_POS_BOTTOM:Int = 3

' GtkWrapMode
Const GTK_WRAP_NONE:Int = 0
Const GTK_WRAP_CHAR:Int = 1
Const GTK_WRAP_WORD:Int = 2
Const GTK_WRAP_WORD_CHAR:Int = 3

' PangoTabAlign
Const PANGO_TAB_LEFT:Int = 0
Const PANGO_TAB_RIGHT:Int = 1
Const PANGO_TAB_CENTER:Int = 2
Const PANGO_TAB_NUMERIC:Int = 3

' GdkCursorType
Const GDK_X_CURSOR:Int = 0
Const GDK_ARROW:Int = 2
Const GDK_BASED_ARROW_DOWN:Int = 4
Const GDK_BASED_ARROW_UP:Int = 6
Const GDK_BOAT:Int = 8
Const GDK_BOGOSITY:Int = 10
Const GDK_BOTTOM_LEFT_CORNER:Int = 12
Const GDK_BOTTOM_RIGHT_CORNER:Int = 14
Const GDK_BOTTOM_SIDE:Int = 16
Const GDK_BOTTOM_TEE:Int = 18
Const GDK_BOX_SPIRAL:Int = 20
Const GDK_CENTER_PTR:Int = 22
Const GDK_CIRCLE:Int = 24
Const GDK_CLOCK:Int = 26
Const GDK_COFFEE_MUG:Int = 28
Const GDK_CROSS:Int = 30
Const GDK_CROSS_REVERSE:Int = 32
Const GDK_CROSSHAIR:Int = 34
Const GDK_DIAMOND_CROSS:Int = 36
Const GDK_DOT:Int = 38
Const GDK_DOTBOX:Int = 40
Const GDK_DOUBLE_ARROW:Int = 42
Const GDK_DRAFT_LARGE:Int = 44
Const GDK_DRAFT_SMALL:Int = 46
Const GDK_DRAPED_BOX:Int = 48
Const GDK_EXCHANGE:Int = 50
Const GDK_FLEUR:Int = 52
Const GDK_GOBBLER:Int = 54
Const GDK_GUMBY:Int = 56
Const GDK_HAND1:Int = 58
Const GDK_HAND2:Int = 60
Const GDK_HEART:Int = 62
Const GDK_ICON:Int = 64
Const GDK_IRON_CROSS:Int = 66
Const GDK_LEFT_PTR:Int = 68
Const GDK_LEFT_SIDE:Int = 70
Const GDK_LEFT_TEE:Int = 72
Const GDK_LEFTBUTTON:Int = 74
Const GDK_LL_ANGLE:Int = 76
Const GDK_LR_ANGLE:Int = 78
Const GDK_MAN:Int = 80
Const GDK_MIDDLEBUTTON:Int = 82
Const GDK_MOUSE:Int = 84
Const GDK_PENCIL:Int = 86
Const GDK_PIRATE:Int = 88
Const GDK_PLUS:Int = 90
Const GDK_QUESTION_ARROW:Int = 92
Const GDK_RIGHT_PTR:Int = 94
Const GDK_RIGHT_SIDE:Int = 96
Const GDK_RIGHT_TEE:Int = 98
Const GDK_RIGHTBUTTON:Int = 100
Const GDK_RTL_LOGO:Int = 102
Const GDK_SAILBOAT:Int = 104
Const GDK_SB_DOWN_ARROW:Int = 106
Const GDK_SB_H_DOUBLE_ARROW:Int = 108
Const GDK_SB_LEFT_ARROW:Int = 110
Const GDK_SB_RIGHT_ARROW:Int = 112
Const GDK_SB_UP_ARROW:Int = 114
Const GDK_SB_V_DOUBLE_ARROW:Int = 116
Const GDK_SHUTTLE:Int = 118
Const GDK_SIZING:Int = 120
Const GDK_SPIDER:Int = 122
Const GDK_SPRAYCAN:Int = 124
Const GDK_STAR:Int = 126
Const GDK_TARGET:Int = 128
Const GDK_TCROSS:Int = 130
Const GDK_TOP_LEFT_ARROW:Int = 132
Const GDK_TOP_LEFT_CORNER:Int = 134
Const GDK_TOP_RIGHT_CORNER:Int = 136
Const GDK_TOP_SIDE:Int = 138
Const GDK_TOP_TEE:Int = 140
Const GDK_TREK:Int = 142
Const GDK_UL_ANGLE:Int = 144
Const GDK_UMBRELLA:Int = 146
Const GDK_UR_ANGLE:Int = 148
Const GDK_WATCH:Int = 150
Const GDK_XTERM:Int = 152
Const GDK_BLANK_CURSOR:Int = -2
Const GDK_CURSOR_IS_PIXMAP:Int = -1

' GtkDestDefaults
Const GTK_DEST_DEFAULT_MOTION:Int = 1 Shl 0
Const GTK_DEST_DEFAULT_HIGHLIGHT:Int = 1 Shl 1
Const GTK_DEST_DEFAULT_DROP:Int = 1 Shl 2
Const GTK_DEST_DEFAULT_ALL:Int = $07

' GdkDragAction
Const GDK_ACTION_DEFAULT:Int = 1 Shl 0
Const GDK_ACTION_COPY:Int = 1 Shl 1
Const GDK_ACTION_MOVE:Int = 1 Shl 2
Const GDK_ACTION_LINK:Int = 1 Shl 3
Const GDK_ACTION_PRIVATE:Int = 1 Shl 4
Const GDK_ACTION_ASK:Int = 1 Shl 5

' List of application windows
' We use it for SetPointer etc.
Global gtkWindows:TList = New TList

' I know... cup of cocoa anyone?
Global GadgetMap:TPtrMap=New TPtrMap

' creates an Object out of an "int"
Type TGTKInteger
	Field value:Int
	Function Set:TGTKInteger(value:Int)
		Local this:TGTKInteger = New TGTKInteger
		this.value = value
		Return this
	End Function
	Method Compare:Int(o:Object)
		Return value-TGTKInteger(o).value
	End Method
End Type

Type TGTKGuiFont Extends TGuiFont

	Field fontDesc:Byte Ptr

	Field context:Byte Ptr
	Field layout:Byte Ptr

	Method Delete()
		If fontDesc Then
			pango_font_description_free(fontDesc)
			fontDesc = Null
		EndIf

		If layout Then
			g_object_unref(layout)
			layout = Null
		End If

		If context Then
			g_object_unref(context)
			context = Null
		End If
	EndMethod
	
	Method CharWidth:Int(char:Int)
		If Not fontDesc Then
			getPangoDescriptionFromGuiFont(Self)
		EndIf

		If fontDesc Then
			If Not context Then
				context = gdk_pango_context_get()
				pango_context_set_font_description(context, fontDesc)

				layout = pango_layout_new(context)
			End If

			Local s:Byte Ptr = Chr(char).ToUTF8String()
			pango_layout_set_text(layout, s, 1)
			MemFree(s)

			Local w:Int
			pango_layout_get_pixel_size(layout, Varptr w, Null)

			Return w
		End If

		Return 0
	EndMethod 
		
EndType

Rem
internal: Returns a Pango font description based on a TGuiFont specification. (INTERNAL)
End Rem
Function getPangoDescriptionFromGuiFont(font:TGtkGuiFont)
	If font = Null Then
		Return
	End If
	
	If Not font.fontDesc Then

		Local fontdesc:Byte Ptr = pango_font_description_new()
		Local s:Byte Ptr = font.name.toUTF8String()
			
		pango_font_description_set_family(fontdesc, s)
	
		If font.style & FONT_BOLD Then
			pango_font_description_set_weight(fontdesc, PANGO_WEIGHT_BOLD)
		Else
			pango_font_description_set_weight(fontdesc, PANGO_WEIGHT_NORMAL)
		End If
	
		If font.style & FONT_ITALIC Then
			pango_font_description_set_style(fontdesc, PANGO_STYLE_ITALIC)
		End If
	
		pango_font_description_set_absolute_size(fontdesc, font.size * 1024)
	
		MemFree(s)
		
		font.fontDesc = fontDesc
		
	End If

End Function

Rem
internal: Clear a cached Pango font description for a TGuiFont. (INTERNAL)
End Rem
Function clearPangoDescriptionCacheForGuiFont(font:TGtkGuiFont)
	If font.fontDesc Then
		pango_font_description_free(font.fontDesc)
		font.fontDesc = Null
	EndIf
End Function

Rem
internal: Returns a TGuiFont from a pango description object. (INTERNAL)
End Rem
Function getGuiFontFromPangoDescription:TGuiFont(fontdesc:Byte Ptr)
	Local font:TGtkGuiFont = New TGTKGuiFont

	font.name = String.FromUTF8String(pango_font_description_get_family(fontdesc))
	'font.path = ...
	Local ital:Int = pango_font_description_get_style(fontdesc)
	Local bold:Int = pango_font_description_get_weight(fontdesc)

	If ital = PANGO_STYLE_OBLIQUE Or ital = PANGO_STYLE_ITALIC Then
		font.style:| FONT_ITALIC
	End If

	If bold > PANGO_WEIGHT_NORMAL Then
		font.style:| FONT_BOLD
	End If

	font.size = pango_font_description_get_size(fontdesc) / 1024

	font.fontDesc = fontdesc
	
	Return font
End Function

?bmxng
Struct GdkGeometry
?Not bmxng
Type GdkGeometry
?
	Field minWidth:Int
	Field minHeight:Int
	Field maxWidth:Int
	Field maxHeight:Int
	Field baseWidth:Int
	Field baseHeight:Int
	Field widthInc:Int
	Field heightInc:Int
	Field minAspect:Double
	Field maxAspect:Double
	Field winGravity:Int
?bmxng
End Struct
?Not bmxng
End Type
?

?bmxng
Struct GtkRequisition
	Field width:Int
	Field height:Int
End Struct
?Not bmxng
Type GtkRequisition
	Field width:Int
	Field height:Int
End Type
?

?bmxng
Struct GdkRectangle
	Field x:Int
	Field y:Int
	Field width:Int
	Field height:Int
End Struct
?Not bmxng
Type GdkRectangle
	Field x:Int
	Field y:Int
	Field width:Int
	Field height:Int
End Type
?

?bmxng
Struct GtkAllocation
	Field x:Int
	Field y:Int
	Field width:Int
	Field height:Int
End Struct
?Not bmxng
Type GtkAllocation
	Field x:Int
	Field y:Int
	Field width:Int
	Field height:Int
End Type
?

?bmxng
Struct GdkRGBA
	Field red:Double
	Field green:Double
	Field blue:Double
	Field alpha:Double
	
	Method New(red:Double, green:Double, blue:Double, alpha:Double = 1.0)
		Self.red = red
		Self.green = green
		Self.blue = blue
		Self.alpha = alpha
	End Method
	
End Struct
?Not bmxng
Type GdkRGBA
	Field red:Double
	Field green:Double
	Field blue:Double
	Field alpha:Double

	Method Create:GdkRGBA(red:Double, green:Double, blue:Double, alpha:Double = 1.0)
		Self.red = red
		Self.green = green
		Self.blue = blue
		Self.alpha = alpha
		Return Self
	End Method
End Type
?

Global _gtkKeysDown:Int[] = New Int[255]

' returns True if key is already believed to be DOWN/Pressed
Function gtk3SetKeyDown:Int(key:Int)
	Assert key < 255, "gtkSetKeyDown key is out of range - " + key
	
	If _gtkKeysDown[key] Then
		Return True
	End If
	
	_gtkKeysDown[key] = 1
	Return False
End Function

Function gtk3SetKeyUp(key:Int)
	Assert key < 255, "gtkSetKeyUp key is out of range - " + key
	
	_gtkKeysDown[key] = 0
End Function
