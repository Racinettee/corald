module coral.component.sourceeditor;

import gtk.ScrolledWindow;
import gsv.SourceView;
import gsv.SourceBuffer;

class SourceEditor : ScrolledWindow
{
	this()
	{
		editor = new SourceView();
		add(editor);
		showAll();
	}
	this(SourceBuffer sb)
	{
		editor = new SourceView(sb);
		add(editor);
		showAll();
	}
	
	SourceView editor;
}