#include "windows.h"
#include <stdio.h>
#include <tom.h>

extern "C" {

	int bmx_tom_ITextDocument_Range(ITextDocument * doc, int p0, int p1, ITextRange ** range);
	int bmx_tom_ITextDocument_SetDefaultTabStop(ITextDocument * doc, float Value);
	int bmx_tom_ITextDocument_Freeze(ITextDocument * doc, int * count);
	int bmx_tom_ITextDocument_Unfreeze(ITextDocument * doc, int * count);

	int bmx_tom_ITextRange_GetFont(ITextRange * range, ITextFont ** font);
	int bmx_tom_ITextRange_SetText(ITextRange * range, BSTR bstr);
	int bmx_tom_ITextRange_GetText(ITextRange * range, BSTR * bstr);
	
	int bmx_tom_ITextFont_SetForeColor(ITextFont * font, int Value);
	int bmx_tom_ITextFont_SetBold(ITextFont * font, int Value);
	int bmx_tom_ITextFont_SetItalic(ITextFont * font, int Value);
	int bmx_tom_ITextFont_SetStrikeThrough(ITextFont * font, int Value);
	int bmx_tom_ITextFont_SetUnderline(ITextFont * font, int Value);
}


// ********************************************************

int bmx_tom_ITextDocument_Range(ITextDocument * doc, int p0, int p1, ITextRange ** range) {
	return doc->Range(p0, p1, range);
}

int bmx_tom_ITextDocument_SetDefaultTabStop(ITextDocument * doc, float Value) {
	return doc->SetDefaultTabStop(Value);
}

int bmx_tom_ITextDocument_Freeze(ITextDocument * doc, int * count) {
	long c;
	int res = doc->Freeze(&c);
	*count = c;
	return res;
}

int bmx_tom_ITextDocument_Unfreeze(ITextDocument * doc, int * count) {
	long c;
	int res = doc->Unfreeze(&c);
	*count = c;
	return res;
}

// ********************************************************

int bmx_tom_ITextRange_GetFont(ITextRange * range, ITextFont ** font) {
	return range->GetFont(font);
}

int bmx_tom_ITextRange_SetText(ITextRange * range, BSTR bstr) {
	return range->SetText(bstr);
}

int bmx_tom_ITextRange_GetText(ITextRange * range, BSTR * bstr) {
	return range->GetText(bstr);
}

// ********************************************************

int bmx_tom_ITextFont_SetForeColor(ITextFont * font, int Value) {
	return font->SetForeColor(Value);
}

int bmx_tom_ITextFont_SetBold(ITextFont * font, int Value) {
	return font->SetBold(Value);
}

int bmx_tom_ITextFont_SetItalic(ITextFont * font, int Value) {
	return font->SetItalic(Value);
}

int bmx_tom_ITextFont_SetStrikeThrough(ITextFont * font, int Value) {
	return font->SetStrikeThrough(Value);
}

int bmx_tom_ITextFont_SetUnderline(ITextFont * font, int Value) {
	return font->SetUnderline(Value);
}

