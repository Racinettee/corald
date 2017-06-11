module coral.component.notebook;

import coral.component.sourceeditor;
import coral.component.tablabel;

import gtk.Notebook : GtkNotebook = Notebook;
import gtk.Widget;

import std.typecons : Tuple;

class Notebook : GtkNotebook
{
    this()
    {
        super();
    }
    TabLabel newPage()
    {
        auto sourceEditor = new SourceEditor();
        return addPage(sourceEditor, "New Page");
    }
    TabLabel addPage(Widget widget, string title, string path="")
    {
        auto tabLabel = new TabLabel(title, widget, path);
        appendPage(widget, tabLabel);
        setTabReorderable(widget, true);
        return tabLabel;
    }
    void addPageForPath(string path)
    {
        if(isFileOpen(path) < 0)
        {
        }
    }
    int isFileOpen(const string fullpath)
    {
        for(int i = 0; i < getNPages(); i++)
        {
            const TabLabel tab = cast(TabLabel)getTabLabel(getNthPage(i));
            if(tab.fullPath == fullpath)
                return i;
        }
        return -1;
    }
}
