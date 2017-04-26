module coral.component.filetree;

import core.thread;

import gdk.Pixbuf : Pixbuf;
import gtk.IconTheme : IconTheme;
import gtk.TreeIter : TreeIter;
import gtk.TreeStore : TreeStore;
import gtk.TreeView : TreeView;
import gtkc.gtk : GtkIconLookupFlags;

import std.file;
import std.path;

//https://github.com/gtkd-developers/GtkD/search?utf8=%E2%9C%93&q=gdk_pixbuf_get_type&type=

class FileTree : TreeView
{
  class FileIteratingThread : Thread
  {
    FileTree treeView;
    this(FileTree outter)
    {
      super(&run);
      treeView = outter;
    }
    private void run()
    {
      string path = treeView.path;
      TreeStore store = treeView.store;
      TreeIter topParent = store.createIter();
      store.setValue(topParent, 0, folderIcon);
      store.setValue(topParent, 1, baseName(path));
      treeView.dirwalk(path, topParent);
    }
  }
  public this(string path)
  {
    this.path = path;
    iconTheme = IconTheme.getDefault();
    folderIcon = iconTheme.lookupIcon("folder", 16, GtkIconLookupFlags.FORCE_SVG).loadIcon;
    fileIcon = iconTheme.lookupIcon("text-x-generic", 16, GtkIconLookupFlags.FORCE_SVG).loadIcon;
    import gtk.TreeViewColumn : TreeViewColumn;
    auto column = new TreeViewColumn();
    column.setTitle("Files");
    import gtk.CellRendererPixbuf : CellRendererPixbuf;
    import gtk.CellRendererText : CellRendererText;
    auto cellRenderPixbuf = new CellRendererPixbuf();
    auto cellRenderText = new CellRendererText();
    column.packStart(cellRenderPixbuf, false);
    column.packEnd(cellRenderText, true);
    column.addAttribute(cellRenderPixbuf, "pixbuf", 0);
    column.addAttribute(cellRenderText, "text", 1);
    import gtkc.gobjecttypes : GType;
    import gtkc.gdkpixbuf : gdk_pixbuf_get_type;
    store = new TreeStore([gdk_pixbuf_get_type(), GType.STRING]);
    super(store);
    //dirwalk(path, topParent);
    new FileIteratingThread(this).start();

    appendColumn(column);
    showAll;
  }
  /// Fill out the tree store
  package void dirwalk(string path, TreeIter parent)
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
        Pixbuf icon = findIcon(baseName(e.name));
        store.setValue(newParent, 0, icon);
        store.setValue(newParent, 1, baseName(e.name));
      }
    }
  }
  private Pixbuf findIcon(string name, int size=16, GtkIconLookupFlags lookupFlags=GtkIconLookupFlags.FORCE_SVG)
  {
    string extName = name.extension;
    if(extName is null)
      return fileIcon;
    Pixbuf* icon = extName in fileIcons;
    if(icon !is null)
      return *icon;
    bool certainty;
    import std.array : replaceFirst;
    import gio.ContentType : ContentType;
    string fileThemeName = ContentType.typeGuess(name, null, certainty).replaceFirst("/", "-");
    Pixbuf newIcon = iconTheme.hasIcon(fileThemeName) ? iconTheme.lookupIcon(fileThemeName, size, lookupFlags).loadIcon : fileIcon;
    fileIcons[extName] = newIcon;
    return newIcon;
  }
  Pixbuf folderIcon;
  Pixbuf fileIcon;
  Pixbuf[string] fileIcons;
  IconTheme iconTheme;
  TreeStore store;
  string path;
}