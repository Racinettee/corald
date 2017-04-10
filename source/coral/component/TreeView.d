module coral.component.treeview;

import gtk.TreeStore;
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
    store = new TreeStore([gdk_pixbuf_get_type(), GType.STRING]);
    dirwalk(path);
  }
  /// Fill out the tree store
  private void dirwalk(string path)
  {
    foreach(DirEntry e; dirEntries(path, SpanMode.shallow))
    {
      writeln(e.name);
    }
  }
  TreeStore store;
}