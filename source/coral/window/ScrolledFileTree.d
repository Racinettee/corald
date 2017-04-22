module coral.window.scrolledfiletree;

import coral.component.filetree;

import gtk.ScrolledWindow;

/// A scrolled window containing the filetree
class ScrolledFileTree : ScrolledWindow
{
  /// Pass the path to use
  public this(string path)
  {
    fileTree = new FileTree(path);
    add(fileTree);
    showAll;
  }
  private FileTree fileTree;
}