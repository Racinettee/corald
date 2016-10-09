module coral.EditorUtil;

import gtk.Notebook;
import gtk.Builder;

import gsv.SourceBuffer;

import coral.TabLabel;
import coral.SourceEditor;

private const string defaultTitle = "New File";

public:
void addNewSourceEditor(Notebook nb, string fullpath = "")
{
  auto sourceEditor = new SourceEditor();
  nb.appendPage(sourceEditor, new TabLabel(defaultTitle, sourceEditor, fullpath));
}

void addNewSourceEditor(Notebook nb, SourceBuffer sb, string fullpath = "")
{
  auto sourceEditor = new SourceEditor(sb);
  nb.appendPage(sourceEditor, new TabLabel(defaultTitle, sourceEditor, fullpath));
}

T getItem(T)(Builder b, string n)
{
  T item = cast(T)b.getObject(n);
  if(item is null)
    throw new Exception("Failed to get object: "~n~" from builder");
  return item;
}