module coral.component.sourceeditor;

import gtk.ScrolledWindow;
import gsv.SourceView;
import gsv.SourceBuffer;

class SourceEditor : ScrolledWindow
{
    this()
    {
        editor = new SourceView();
        editor.setAutoIndent(true);
        editor.setHighlightCurrentLine(true);
        editor.setIndentWidth(4);
        editor.setInsertSpacesInsteadOfTabs(true);
        editor.setShowLineNumbers(true);
        editor.setSmartBackspace(true);
        add(editor);
        showAll();
    }
    this(SourceBuffer sb)
    {
        editor = new SourceView(sb);
        editor.setAutoIndent(true);
        editor.setHighlightCurrentLine(true);
        editor.setIndentWidth(4);
        editor.setInsertSpacesInsteadOfTabs(true);
        editor.setShowLineNumbers(true);
        editor.setSmartBackspace(true);
        add(editor);
        showAll();
    }

    SourceView editor;
}
