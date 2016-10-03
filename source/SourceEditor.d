module coral.SourceEditor;

import gtk.ScrolledWindow;
import gsv.SourceView;

class SourceEditor : ScrolledWindow
{
	this()
	{
		editor = new SourceView();
	}
	SourceView editor;
}