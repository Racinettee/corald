module coral.component.treeview;

import gtk.TreeStore;
import gtk.TreeIter;
import gtk.IconTheme;
import gtkc.gtk;
import gtkc.gdk;
import gtkc.gdkpixbuf;
import gtkc.gobjecttypes : GType;
import gdk.Pixbuf;

import std.file;
import std.stdio;

//https://github.com/gtkd-developers/GtkD/search?utf8=%E2%9C%93&q=gdk_pixbuf_get_type&type=

class TreeView
{
  public this(string path)
  {
    //store = new TreeStore([]); //cast(GType[])[GtkImageType.PIXBUF, GType.STRING]);
    folderIcon = IconTheme.getDefault().lookupIcon("folder", 16, GtkIconLookupFlags.FORCE_SVG).loadIcon();
    store = new TreeStore([gdk_pixbuf_get_type(), GType.STRING]);
    TreeIter topParent = store.createIter();
    store.setValue(topParent, 0, folderIcon);
    store.setValue(topParent, 1, "Your folder");
    dirwalk(path, topParent);
  }
  /// Fill out the tree store
  private void dirwalk(string path, TreeIter parent)
  {
    foreach(DirEntry e; dirEntries(path, SpanMode.shallow))
    {
      if(e.isDir)
      {
        TreeIter newParent = store.createIter(parent);
        dirwalk(e.name, newParent);
      }
    }
  }
  Pixbuf folderIcon;
  TreeStore store;
}