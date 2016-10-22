module coral.component.TabLabel;

import gtk.Box;
import gtk.Button;
import gtk.Widget;
import gtk.Label;
import gtk.Image;
import gtkc.gtktypes : StockID;
import gtkc.gtktypes : GtkOrientation;
import gtkc.gtktypes : GtkReliefStyle;

/// This class is the tab in a notebook
class TabLabel : Box
{
	/// Initialize this tablabel which appears in the notebook with
	/// title text, a reference to the object its keeping open, and
	/// the full path to the file its working on
	this(string text, Widget cref, string fullPath)
	{
		super(GtkOrientation.HORIZONTAL, 0);
		textLabel = new Label(text);
		closeButton = new Button(StockID.CLOSE, true);
		closeButton.setRelief(GtkReliefStyle.NONE);
		childRef = cref;
		filePath = fullPath;
		packStart(cast(Widget)textLabel, true, false, 1);
		packEnd(cast(Widget)closeButton, false, false, 1);
		showAll();
	}
	@safe @property const string fullPath () { return filePath; } 
	private string filePath;
	private Widget childRef;
	private Button closeButton;
	private Label textLabel;
}