module coral.component.filetree;

import coral.util.app.threads;
import coral.util.threads.filewatcher;

import core.time;
import core.thread;
import core.atomic;

import gdk.Pixbuf : Pixbuf;
import gtk.IconTheme : IconTheme;
import gtk.TreeIter : TreeIter;
import gtk.TreeStore : TreeStore;
import gtk.TreeView : TreeView;
import gtk.TreeViewColumn : TreeViewColumn;
//import gtkc.gtk : GtkIconLookupFlags, GtkTreeIter, GtkTreeRowReference, GtkTreePath;
//import gtk.c.functions;
import gtkc.gtktypes;
import gtkc.gtk;
import gtk.CellRendererPixbuf : CellRendererPixbuf;
import gtk.CellRendererText : CellRendererText;

import reef.lua.attrib;

import std.algorithm;
import std.array;
import std.file;
import std.stdio;
import std.path;
import std.typecons;

@LuaExport("treeView")
class FileTree : TreeView
{
  package class FileIteratingThread : CancellableThread
  {
    string path;
    TreeStore store;
    Pixbuf fileIcon;
    Pixbuf folderIcon;
    Pixbuf[string] fileIcons;
    IconTheme iconTheme;
    this(string path, TreeStore initialStore)
    {
      this.path = path;
      store = initialStore;
      iconTheme = IconTheme.getDefault();
      folderIcon = iconTheme.lookupIcon("folder", 16, GtkIconLookupFlags.FORCE_SVG).loadIcon;
      fileIcon = iconTheme.lookupIcon("text-x-generic", 16, GtkIconLookupFlags.FORCE_SVG).loadIcon;
      super(globalCancellation);
    }
    override void run()
    {
      TreeIter topParent = store.createIter();
      store.setValue(topParent, 0, folderIcon);
      store.setValue(topParent, 1, baseName(path));
      dirwalk(path, topParent);
    }
    /// Fill out the tree store
    private void dirwalk(string path, TreeIter parent)
    {
      if(isCancelled)
        return;
      auto nameDirPairs = array(dirEntries(path, SpanMode.shallow).map!(a => tuple(a.name, a.isDir)));
      // Sort the files by name
      sort!((a, b) => a[0] < b[0])(nameDirPairs);
      // Sort the files by isDir
      sort!((a, b) => a[1] > b[1])(nameDirPairs);
      foreach(e; nameDirPairs)
      {
        if(e[1])
        {
          TreeIter newParent = store.append(parent);
          store.setValue(newParent, 0, folderIcon);
          store.setValue(newParent, 1, baseName(e[0]));
          store.setValue(newParent, 2, true);
          dirwalk(e[0], newParent);
        }
        else
        {
          TreeIter newParent = store.append(parent);
          Pixbuf icon = findIcon(baseName(e[0]));
          store.setValue(newParent, 0, icon);
          store.setValue(newParent, 1, baseName(e[0]));
          store.setValue(newParent, 2, true);
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
    self = this;
    import gtkc.gobjecttypes : GType;
    import gtkc.gdkpixbuf : gdk_pixbuf_get_type;
    store = new TreeStore([gdk_pixbuf_get_type(), GType.STRING, GType.BOOLEAN]);
    super(store);
    auto column = new TreeViewColumn();
    primaryColumn = column;
    column.setTitle("Files");
    auto cellRenderPixbuf = new CellRendererPixbuf();
    cellRenderText = new CellRendererText();
    column.packStart(cellRenderPixbuf, false);
    column.packEnd(cellRenderText, true);
    column.addAttribute(cellRenderPixbuf, "pixbuf", 0);
    column.addAttribute(cellRenderText, "text", 1);
    column.addAttribute(cellRenderText, "editable", 2);
    new FileIteratingThread(path, store).start();
    appendColumn(column);
    auto dirMonitorThread = new DirectoryMonitorThread(path);
    dirMonitorThread.start();
    auto watchThreadToken = dirMonitorThread.getCancellationToken;
    addOnDestroy((w) {
        watchThreadToken.cancel();
        dirMonitorThread = null;
        watchThreadToken = null;
    });
    showAll;
  }
  @LuaExport("start_rename", MethodType.method, "", RetType.none)
  public void startRename(GtkTreeIter* iter)
  {
    writeln("Gonna try and rename");
    GtkTreeModel* treeStore = cast(GtkTreeModel*)store.getTreeStoreStruct();
    GtkTreePath* path = gtk_tree_model_get_path(treeStore, iter);
    GtkTreeRowReference* rowref = gtk_tree_row_reference_new(treeStore, path);
    
    gtk_widget_grab_focus(cast(GtkWidget*)getTreeViewStruct);
    
    if (gtk_tree_path_up(path))
        gtk_tree_view_expand_to_path(getTreeViewStruct, path);
        
    gtk_tree_path_free(path);
    
    gtk_tree_view_column_focus_cell(
        primaryColumn.getTreeViewColumnStruct,
        cast(GtkCellRenderer*)cellRenderText.getCellRendererTextStruct);
        
    path = gtk_tree_row_reference_get_path(rowref),
    gtk_tree_view_set_cursor(getTreeViewStruct, path,
    primaryColumn.getTreeViewColumnStruct, 1);
    gtk_tree_path_free(path);
  }
  TreeViewColumn primaryColumn;
  @LuaExport("cell_render_pixbuf", MethodType.none, "getCellRendererPixbufStruct()", RetType.none, MemberType.lightud)
  CellRendererPixbuf cellRenderPixbuf;
  @LuaExport("cell_render_text", MethodType.none, "getCellRendererTextStruct()", RetType.none, MemberType.lightud)
  CellRendererText cellRenderText;
  @LuaExport("treeView", MethodType.none, "getTreeViewStruct()", RetType.none, MemberType.lightud)
  FileTree self;
  TreeStore store;
  @LuaExport("path", MethodType.none, "", RetType.none, MemberType.none)
  string path;
}

