module coral.window.scrolledfiletree;

import coral.component.filetree;

import gtk.ScrolledWindow;
import gtk.TreeStore;

import reef.lua.attrib;

/// A scrolled window containing the filetree
@LuaExport("ScrolledFileTree")
class ScrolledFileTree : ScrolledWindow
{
  /// Pass the path to use
  @LuaExport("", MethodType.ctor)
  public this(string path)
  {
    fileTree = new FileTree(path);
    treeStore = fileTree.store;
    self = this;
    add(fileTree);
    showAll;
  }
  @LuaExport("start_rename", MethodType.method, "", RetType.str, MemberType.none)
  public void startRename(GtkTreeIter* iter)
  {
    fileTree.startRename(iter);
  }
  @LuaExport("store", MethodType.none, "getTreeStoreStruct()", RetType.none, MemberType.lightud)
  TreeStore treeStore;
  @LuaExport("tree", MethodType.none, "", RetType.none, MemberType.userdat)
  FileTree fileTree;
  @LuaExport("window", MethodType.none, "getScrolledWindowStruct()", RetType.none, MemberType.lightud)
  ScrolledFileTree self;
  @LuaExport("get_path", MethodType.method, "", RetType.str, MemberType.none)
  string getFilePath() nothrow
  {
    return fileTree.path;
  }
}
