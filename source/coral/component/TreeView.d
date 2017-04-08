module coral.component.treeview;

import gtk.TreeStore;
import gtkc.gobjecttypes : GType;
import gtkc.gtktypes : GtkImageType;

class TreeView
{
  public this()
  {
    store = new TreeStore(cast(GType[])[GtkImageType.PIXBUF, GType.STRING]);
  }
  TreeStore store;
}