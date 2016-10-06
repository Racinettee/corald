module coral.EditorUtil;

import gtk.Notebook;
import gtk.Builder;

import coral.TabLabel;
import coral.SourceEditor;

private const string defaultTitle = "New File";

public:
void addNewSourceEditor(Notebook nb)
{
  auto sourceEditor = new SourceEditor();
  nb.appendPage(sourceEditor, new TabLabel(defaultTitle, sourceEditor, ""));
}

T getItem(T)(Builder b, string n)
{
  T item = cast(T)b.getObject(n);
  if(item is null)
    throw new Exception("Failed to get object: "~n~" from builder");
  return item;
}