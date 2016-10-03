module coral.SourceEditor;

import gtk.ScrolledWindow;
import gsv.SourceView;

class SourceEditor : ScrolledWindow
{
	this()
	{
		editor = new SourceView();
		add(editor);
		showAll();
	}
	SourceView editor;
}