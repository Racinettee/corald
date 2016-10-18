module coral.EditorUtil;

import std.string : lastIndexOf;

import gtk.Notebook;
import gtk.Builder;

import gsv.SourceBuffer;

import coral.TabLabel;
import coral.SourceEditor;

private const string defaultTitle = "New File";

public:

pure @safe string shortName(in string fullpath)
in
{
  assert(fullpath.length != 0);
}
body
{
  long index = lastIndexOf(fullpath, '/');
  // If theres no forward slash in fullpath then just return the path
  if(index == -1)
    return fullpath;
  
  return fullpath[index+1..$];
}

void addNewSourceEditor(Notebook nb, string fullpath = "")
{
  auto sourceEditor = new SourceEditor();
  nb.appendPage(sourceEditor, new TabLabel(fullpath == "" ? defaultTitle : shortName(fullpath), sourceEditor, fullpath));
}

void addNewSourceEditor(Notebook nb, SourceBuffer sb, string fullpath = "")
{
  auto sourceEditor = new SourceEditor(sb);
  nb.appendPage(sourceEditor, new TabLabel(fullpath == "" ? defaultTitle : shortName(fullpath), sourceEditor, fullpath));
}

T getItem(T)(Builder b, string n)
{
  T item = cast(T)b.getObject(n);
  if(item is null)
    throw new Exception("Failed to get object: "~n~" from builder");
  return item;
}

int fileOpen(Notebook nb, const string fullpath)
{
  for(size_t i = 0; i < nb.getNPages(); i++)
  {
    const TabLabel tab = cast(TabLabel)nb.getNthPage(i);
    if(tab.fullPath == fullpath)
      return i;
  }
  return -1;
}