module coral.component.filetree;

import gtk.TreeStore;
import gtk.TreeIter;
import gtk.IconTheme;
import gtk.TreeView : GtkTreeView=TreeView;
import gtk.TreeViewColumn;
import gtk.CellRendererPixbuf;
import gtk.CellRendererText;
import gtkc.gtk;
import gtkc.gdk;
import gtkc.gdkpixbuf;
import gtkc.gobjecttypes : GType;
import gdk.Pixbuf;

import std.file;
import std.path;
import std.stdio;

//https://github.com/gtkd-developers/GtkD/search?utf8=%E2%9C%93&q=gdk_pixbuf_get_type&type=

class FileTree : GtkTreeView
{
  public this(string path)
  {
    cellRenderPixbuf = new CellRendererPixbuf();
    cellRenderText = new CellRendererText();
    IconTheme iconTheme = IconTheme.getDefault();
    folderIcon = iconTheme.lookupIcon("folder", 16, GtkIconLookupFlags.FORCE_SVG).loadIcon;
    fileIcon = iconTheme.lookupIcon("text-x-generic", 16, GtkIconLookupFlags.FORCE_SVG).loadIcon;
    column = new TreeViewColumn();
    column.setTitle("Files");
    column.packStart(cellRenderPixbuf, false);
    column.packEnd(cellRenderText, true);
    column.addAttribute(cellRenderPixbuf, "pixbuf", 0);
    column.addAttribute(cellRenderText, "text", 1);
    store = new TreeStore([gdk_pixbuf_get_type(), GType.STRING]);
    super(store);
    TreeIter topParent = store.createIter();
    store.setValue(topParent, 0, folderIcon);
    store.setValue(topParent, 1, baseName(path));
    dirwalk(path, topParent);

    appendColumn(column);
    showAll;
  }
  /// Fill out the tree store
  private void dirwalk(string path, TreeIter parent)
  {
    foreach(DirEntry e; dirEntries(path, SpanMode.shallow))
    {
      if(e.isDir)
      {
        TreeIter newParent = store.append(parent);
        store.setValue(newParent, 0, folderIcon);
        store.setValue(newParent, 1, baseName(e.name));
        dirwalk(e.name, newParent);
      }
      else
      {
        TreeIter newParent = store.append(parent);
        store.setValue(newParent, 0, fileIcon);
        store.setValue(newParent, 1, baseName(e.name));
      }
    }
  }
  Pixbuf folderIcon;
  Pixbuf fileIcon;
  TreeStore store;
  CellRendererPixbuf cellRenderPixbuf;
  CellRendererText cellRenderText;
  TreeViewColumn column;
}