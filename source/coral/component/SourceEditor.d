module coral.component.sourceeditor;

import reef.lua.attrib;

import gtk.ScrolledWindow;
import gsv.SourceView;
import gsv.SourceBuffer;

@LuaExport("SourceEditor")
class SourceEditor : ScrolledWindow
{
    this()
    {
        this(null);
    }
    this(SourceBuffer sb)
    {
        editor = sb ? new SourceView(sb) : new SourceView();
        editor.setAutoIndent(true);
        editor.setHighlightCurrentLine(true);
        editor.setIndentWidth(4);
        editor.setInsertSpacesInsteadOfTabs(true);
        editor.setShowLineNumbers(true);
        editor.setSmartBackspace(true);
        buffer = editor.getBuffer();
        add(editor);
        showAll();
    }
    @LuaExport("source_view", MethodType.none, "getSourceViewStruct()", RetType.none, MemberType.lightud)
    SourceView editor;
    @LuaExport("source_buffer", MethodType.none, "getSourceBufferStruct()", RetType.none, MemberType.lightud)
    SourceBuffer buffer;     
}
