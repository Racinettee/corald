module coral.TabLabel;

import gtk.Box;
import gtk.Button;
import gtk.Widget;
import gtkc.gtktypes : GtkOrientation;

/// This class is the tab in a notebook
class TabLabel : Box
{
	/// Initialize this tablabel which appears in the notebook with
	/// title text, a reference to the object its keeping open, and
	/// the full path to the file its working on
	this(string text, Widget cref, string fullPath)
	{
		super(GtkOrientation.HORIZONTAL, 2);
		closeButton = new Button(text);
		childRef = cref;
	}
	private Widget childRef;
	private Button closeButton;
}