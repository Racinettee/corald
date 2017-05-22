module coral.window.scrolledfiletree;

import coral.component.filetree;

import gtk.ScrolledWindow;

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
    self = this;
    add(fileTree);
    showAll;
  }
  private FileTree fileTree;
  @LuaExport("window", MethodType.none, "getScrolledWindowStruct()", RetType.none, MemberType.lightud)
  ScrolledFileTree self;
}