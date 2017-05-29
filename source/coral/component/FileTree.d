module coral.component.filetree;

import core.thread;

import gdk.Pixbuf : Pixbuf;
import gtk.IconTheme : IconTheme;
import gtk.TreeIter : TreeIter;
import gtk.TreeStore : TreeStore;
import gtk.TreeView : TreeView;
import gtkc.gtk : GtkIconLookupFlags;

import reef.lua.attrib;

import std.file;
import std.path;

@LuaExport("treeView")
class FileTree : TreeView
{
  class FileIteratingThread : Thread
  {
    string path;
    TreeStore store;
    Pixbuf fileIcon;
    Pixbuf folderIcon;
    Pixbuf[string] fileIcons;
    IconTheme iconTheme;
    package this(string path, TreeStore initialStore)
    {
      super(&run);
      this.path = path;
      store = initialStore;
      iconTheme = IconTheme.getDefault();
      folderIcon = iconTheme.lookupIcon("folder", 16, GtkIconLookupFlags.FORCE_SVG).loadIcon;
      fileIcon = iconTheme.lookupIcon("text-x-generic", 16, GtkIconLookupFlags.FORCE_SVG).loadIcon;
    }
    private void run()
    {
      TreeIter topParent = store.createIter();
      store.setValue(topParent, 0, folderIcon);
      store.setValue(topParent, 1, baseName(path));
      dirwalk(path, topParent);
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
  }
  public this(string path)
  {
    this.path = path;
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
    new FileIteratingThread(path, store).start();
    appendColumn(column);
    showAll;
  }
  @LuaExport("treeView", MethodType.none, "getTreeViewStruct()", RetType.none, MemberType.lightud)
  FileTree self;
  TreeStore store;
  @LuaExport("path", MethodType.none, "", RetType.none, MemberType.none)
  string path;
}
