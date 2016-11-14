module coral.component.tablabel;

import gtk.Box;
import gtk.Button;
import gtk.Widget;
import gtk.Label;
import gtk.Image;
import gtk.Notebook;
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
		textLabel = new Label(titleText = text);
		closeButton = new Button(StockID.CLOSE, true);
		closeButton.setRelief(GtkReliefStyle.NONE);
		childRef = cref;
		closeButton.addOnClicked(&this.close);
		filePath = fullPath;
		packStart(cast(Widget)textLabel, true, false, 1);
		packEnd(cast(Widget)closeButton, false, false, 1);
		showAll();
	}
	void close(Button)
	{
		Notebook notebook = cast(Notebook)getParent;
		int pageNum = notebook.pageNum(childRef);
		notebook.removePage(pageNum);
	}
	void setTitle(const string title)
	{
		textLabel.setText(titleText = title);
	}
	void setTitleAndPath(const string path)
	{
		filePath = path;
		import std.path : baseName;
		setTitle(baseName(path));
	}
	@safe @nogc @property 
	immutable(bool) noPath () const nothrow { return filePath.length == 0; }
	@safe @nogc @property 
	immutable(string) fullPath () const nothrow { return filePath; }
	@safe @nogc @property 
	immutable(string) title() const nothrow { return titleText; }
	
	private string titleText;
	private string filePath;
	private Widget childRef;
	private Button closeButton;
	private Label textLabel;
}