' tom.bmx

Import pub.win32

Strict

Import "tom.cpp"

Const TOMTRUE = -1
Const TOMFALSE = 0
Const TOMNONE = 0
Const TOMSINGLE = 1
Const TOMWORDS = 2
Const TOMDOUBLE = 3
Const TOMDOTTED = 4

Extern "win32"
Interface IRichEditOLE_ Extends IUnknown_
	
	Method GetClientSite()
	
	Method GetObjectCount()
	
	Method GetLinkCount()
	
	Method GetObject()
	
	Method InsertObject()

	Method ConvertObject()

	Method ActivateAs()

	Method SetHostNames()

	Method SetLinkAvailable()

	Method SetDvaspect()

	Method HandsOffStorage()
	
	Method SaveCompleted()

	Method InPlaceDeactivate()
	
	Method ContextSensitiveHelp()
	
	Method GetClipboardData()
	
	Method ImportDataObject()

End Interface
End Extern

Extern
	Function bmx_tom_ITextDocument_Range:Int(handle:Byte Ptr, p0:Int, p1:Int, irangePtr:Byte Ptr Ptr)
	Function bmx_tom_ITextDocument_SetDefaultTabStop:Int(handle:Byte Ptr, Value:Float)
	Function bmx_tom_ITextDocument_Freeze:Int(handle:Byte Ptr, count:Int Ptr)
	Function bmx_tom_ITextDocument_Unfreeze:Int(handle:Byte Ptr, count:Int Ptr)
End Extern

Extern "win32"
Interface ITextDocument_ Extends IDispatch_
	Method GetName()
	'End Method

	Method GetSlection()
	'End Method

	Method GetStoryCount( storycount:Int Var)
	'End Method

	Method GetStoryRanges()
	'End Method

	Method GetSaved()
	'End Method

	Method SetSaved()
	'End Method

	Method GetDefaultTabStop(Value# Var)
	'End Method

	Method SetDefaultTabStop(Value:Float)
	'	Return bmx_tom_ITextDocument_SetDefaultTabStop(unknownPtr, Value)
	'End Method

	Method NewDocument()
	'End Method

	Method Open()
	'End Method

	Method Save()
	'End Method

	Method Freeze(count Var)
	'	Return bmx_tom_ITextDocument_Freeze(unknownPtr, Varptr count)
	'End Method

	Method Unfreeze(count Var)
	'	Return bmx_tom_ITextDocument_Unfreeze(unknownPtr, Varptr count)
	'End Method

	Method BeginEditCollection()
	'End Method

	Method EndEditCollection()
	'End Method

	Method Undo()
	'End Method

	Method Redo()
	'End Method

	Method Range(p0,p1,irange:ITextRange_ Var)
	'	If Not irange Then
	'		irange = New ITextRange
	'	End If
	'	Return bmx_tom_ITextDocument_Range(unknownPtr, p0, p1, Varptr irange.unknownPtr)
	'End Method

	Method RangeFromPoint(x,y,irange:ITextRange_ Var)
	'End Method

End Interface 
End Extern

Extern
	Function bmx_tom_ITextRange_GetFont:Int(handle:Byte Ptr, ifontPtr:Byte Ptr Ptr)
	Function bmx_tom_ITextRange_SetText:Int(handle:Byte Ptr, bstr:Short Ptr)
	Function bmx_tom_ITextRange_GetText:Int(handle:Byte Ptr, bstr:Short Ptr Ptr)
End Extern

Extern "win32"
Interface  ITextRange_ Extends IDispatch_
	Method GetText(bstr:Short Ptr Ptr)
	'	Return bmx_tom_ITextRange_GetText(unknownPtr, bstr)
	'End Method
	
	Method SetText(bstr:Short Ptr)
	'	Return bmx_tom_ITextRange_SetText(unknownPtr, bstr)
	'End Method
	
	Method GetChar()
	'End Method
	
	Method SetChar()
	'End Method
	
	Method GetDuplicate(irange:ITextRange_ Var)
	'End Method
	
	Method GetFormattedText()
	'End Method
	
	Method SetFormattedText()
	'End Method
	
	Method GetStart()
	'End Method
	
	Method SetStart()
	'End Method
	
	Method GetEnd()
	'End Method
	
	Method SetEnd()
	'End Method
	
	Method GetFont(ifont:ITextFont_ Var)
	'	If Not ifont Then
	'		ifont = New ITextFont
	'	End If
	'	Return bmx_tom_ITextRange_GetFont(unknownPtr, Varptr ifont.unknownPtr)
	'End Method
	
	Method SetFont(ifont:ITextFont_)
	'End Method
	
'	Method GetPara(para:ITextPara Var)
'	'End Method
	
'	Method SetPara(para:ITextPara)
'	'End Method
	
	Method GetStoryLength( length:Int Var )
	'End Method
	
	Method GetStoryType( storytype:Int Var)
	'End Method
	
	Method Collapse()
	'End Method
	
	Method Expand()
	'End Method
	
	Method GetIndex()
	'End Method
	
	Method SetIndex()
	'End Method
	
	Method SetRange(cp1,cp2)
	'End Method
	
	Method InRange()
	'End Method
	
	Method InStory()
	'End Method
	
	Method IsEqual()
	'End Method
	
	Method Select_()
	'End Method
	
	Method StartOf()
	'End Method
	
	Method EndOf()
	'End Method
	
	Method Move()
	'End Method
	
	Method MoveStart()
	'End Method
	
	Method MoveEnd()
	'End Method
	
	Method MoveWhile()
	'End Method
	
	Method MoveStartWhile()
	'End Method
	
	Method MoveEndWhile()
	'End Method
	
	Method MoveUntil()
	'End Method
	
	Method MoveStartUntil()
	'End Method
	
	Method MoveEndUntil()
	'End Method
	
	Method FindText()
	'End Method
	
	Method FindTextStart()
	'End Method
	
	Method FindTextEnd()
	'End Method
	
	Method Delete_()
	'End Method
	
	Method Cut()
	'End Method
	
	Method Copy()
	'End Method
	
	Method Paste()
	'End Method
	
	Method CanPaste()
	'End Method
	
	Method CanEdit(bool Var)
	'End Method
	
	Method ChangeCase()
	'End Method
	
	Method GetPoint()
	'End Method
	
	Method SetPoint()
	'End Method
	
	Method ScrollIntoView()
	'End Method
	
	Method GetEmbeddedObject()
	'End Method
	
End Interface 
End Extern

Extern
	Function bmx_tom_ITextFont_SetForeColor:Int(handle:Byte Ptr, Value:Int)
	Function bmx_tom_ITextFont_SetBold:Int(handle:Byte Ptr, Value:Int)
	Function bmx_tom_ITextFont_SetItalic:Int(handle:Byte Ptr, Value:Int)
	Function bmx_tom_ITextFont_SetStrikeThrough:Int(handle:Byte Ptr, Value:Int)
	Function bmx_tom_ITextFont_SetUnderline:Int(handle:Byte Ptr, Value:Int)
End Extern

Extern "win32"
Interface ITextFont_ Extends IDispatch_
	Method GetDuplicate(ifont:ITextFont_ Var)
	'End Method
	
	Method SetDuplicate()
	'End Method
	
	Method CanChange()
	'End Method
	
	Method IsEqual() 
	'End Method
	
	Method Reset()
	'End Method
	
	Method GetStyle(Value:Int Ptr)
	'End Method
	
	Method SetStyle(Value)
	'End Method
	
	Method GetAllCaps(Value:Int Ptr)
	'End Method
	
	Method SetAllCaps(Value)
	'End Method
	
	Method GetAnimation(Value:Int Ptr)
	'End Method
	
	Method SetAnimation(Value)
	'End Method
	
	Method GetBackColor(Value:Int Ptr)
	'End Method
	
	Method SetBackColor(Value)
	'End Method
	
	Method GetBold(Value:Int Ptr)
	'End Method
	
	Method SetBold(Value)
	'	Return bmx_tom_ITextFont_SetBold(unknownPtr, Value)
	'End Method
	
	Method GetEmboss(Value:Int Ptr)
	'End Method
	
	Method SetEmboss(Value)
	'End Method
	
	Method GetForeColor(Value:Int Ptr)
	'End Method
	
	Method SetForeColor(Value)
	'	Return bmx_tom_ITextFont_SetForeColor(unknownPtr, Value)
	'End Method
	
	Method GetHidden(Value:Int Ptr)
	'End Method
	
	Method SetHidden(Value)
	'End Method
	
	Method GetEngrave(Value:Int Ptr)
	'End Method
	
	Method SetEngrave(Value)
	'End Method
	
	Method GetItalic(Value:Int Ptr)
	'End Method
	
	Method SetItalic(Value)
	'	Return bmx_tom_ITextFont_SetItalic(unknownPtr, Value)
	'End Method
	
	Method GetKerning(Value:Int Ptr)
	'End Method
	
	Method SetKerning(Value)
	'End Method
	
	Method GetLanguageID()
	'End Method
	
	Method SetLanguageID() 
	'End Method
	
	Method GetName()
	'End Method
	
	Method SetName()
	'End Method
	
	Method GetOutline(Value:Int Ptr)
	'End Method
	
	Method SetOutline(Value)
	'End Method
	
	Method GetPosition(Value:Int Ptr)
	'End Method
	
	Method SetPosition(Value)
	'End Method
	
	Method GetProtected(Value:Int Ptr)
	'End Method
	
	Method SetProtected(Value)
	'End Method
	
	Method GetShadow(Value:Int Ptr)
	'End Method
	
	Method SetShadow(Value)
	'End Method
	
	Method GetSize(Value:Int Ptr)
	'End Method
	
	Method SetSize(Value)
	'End Method
	
	Method GetSmallCaps(Value:Int Ptr)
	'End Method
	
	Method SetSmallCaps(Value)
	'End Method
	
	Method GetSpacing(Value:Int Ptr)
	'End Method
	
	Method SetSpacing(Value)
	'End Method
	
	Method GetStrikeThrough(Value:Int Ptr)
	'End Method
	
	Method SetStrikeThrough(Value)
	'	Return bmx_tom_ITextFont_SetStrikeThrough(unknownPtr, Value)
	'End Method
	
	Method GetSubscript(Value:Int Ptr)
	'End Method
	
	Method SetSubscript(Value)
	'End Method
	
	Method GetSuperscript(Value:Int Ptr)
	'End Method
	
	Method SetSuperscript(Value) 
	'End Method
	
	Method GetUnderline(Value:Int Ptr)
	'End Method
	
	Method SetUnderline(Value)
	'	Return bmx_tom_ITextFont_SetUnderline(unknownPtr, Value)
	'End Method
	
	Method GetWeight(Value:Int Ptr)
	'End Method
	
	Method SetWeight(Value)
	'End Method
	
End Interface 
End Extern

Const ITextDocument_UUID$="{8CC497C0-A1DF-11ce-8098-00AA0047BE5D}"
Rem
Type ITextFont Extends IDispatch
	Method GetDuplicate(ifont:ITextFont Var)
	Method SetDuplicate()
	Method CanChange()
	Method IsEqual() 
	Method Reset()
	Method GetStyle(Value:Int Ptr)
	Method SetStyle(Value)
	Method GetAllCaps(Value:Int Ptr)
	Method SetAllCaps(Value)
	Method GetAnimation(Value:Int Ptr)
	Method SetAnimation(Value)
	Method GetBackColor(Value:Int Ptr)
	Method SetBackColor(Value)
	Method GetBold(Value:Int Ptr)
	Method SetBold(Value)
	Method GetEmboss(Value:Int Ptr)
	Method SetEmboss(Value)
	Method GetForeColor(Value:Int Ptr)
	Method SetForeColor(Value)
	Method GetHidden(Value:Int Ptr)
	Method SetHidden(Value)
	Method GetEngrave(Value:Int Ptr)
	Method SetEngrave(Value)
	Method GetItalic(Value:Int Ptr)
	Method SetItalic(Value)
	Method GetKerning(Value:Int Ptr)
	Method SetKerning(Value)
	Method GetLanguageID()
	Method SetLanguageID() 
	Method GetName()
	Method SetName()
	Method GetOutline(Value:Int Ptr)
	Method SetOutline(Value)
	Method GetPosition(Value:Int Ptr)
	Method SetPosition(Value)
	Method GetProtected(Value:Int Ptr)
	Method SetProtected(Value)
	Method GetShadow(Value:Int Ptr)
	Method SetShadow(Value)
	Method GetSize(Value:Int Ptr)
	Method SetSize(Value)
	Method GetSmallCaps(Value:Int Ptr)
	Method SetSmallCaps(Value)
	Method GetSpacing(Value:Int Ptr)
	Method SetSpacing(Value)
	Method GetStrikeThrough(Value:Int Ptr)
	Method SetStrikeThrough(Value)
	Method GetSubscript(Value:Int Ptr)
	Method SetSubscript(Value)
	Method GetSuperscript(Value:Int Ptr)
	Method SetSuperscript(Value) 
	Method GetUnderline(Value:Int Ptr)
	Method SetUnderline(Value)
	Method GetWeight(Value:Int Ptr)
	Method SetWeight(Value)
End Type

Const ITextPara_UUID$="{8CC497C4-A1DF-11ce-8098-00AA0047BE5D}"

Type ITextPara Extends IDispatch
	Method GetDuplicate(ipara:ITextPara Var)
	Method SetDuplicate()
	Method CanChange()
	Method IsEqual(para)
	Method Reset(value)
	Method GetStyle() 
	Method SetStyle(value)
	Method GetAlignment()
	Method SetAlignment(value)
	Method GetHyphenation()
	Method SetHyphenation(value)
	Method GetFirstLineIndent()
	Method GetKeepTogether()
	Method SetKeepTogether(value)
	Method GetKeepWithNext()
	Method SetKeepWithNext(value)
	Method GetLeftIndent#()
	Method GetLineSpacing#()
	Method GetLineSpacingRule()
	Method GetListAlignment()
	Method SetListAlignment( value)
	Method GetListLevelIndex()
	Method SetListLevelIndex(value)
	Method GetListStart()
	Method SetListStart(value)
	Method GetListTab#()
	Method SetListTab(value#)
	Method GetListType()
	Method SetListType(value)
	Method GetNoLineNumber()
	Method SetNoLineNumber(value)
	Method GetPageBreakBefore()
	Method SetPageBreakBefore(value)
	Method GetRightIndent#()
	Method SetRightIndent(value#)
	Method SetIndents(startindent#,leftindent#,rightindent#)
	Method SetLineSpacing( rule,spacing# )
	Method GetSpaceAfter()
	Method SetSpaceAfter(value#)
	Method GetSpaceBefore#()
	Method SetSpaceBefore(value#)
	Method GetWidowControl()
	Method SetWidowControl(value)
	Method GetTabCount( )
	Method AddTab( pos#,align,leader )
	Method ClearAllTabs()
	Method DeleteTab(pos#)
	Method GetTab(tab,pos,align,leader)	
End Type
End Rem
