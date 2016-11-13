module coral.util.windows;

import gtk.Window;

enum Response
{
  None = 0,
	/**
	 * an OK button
	 */
	Ok = 1,
	/**
	 * a Close button
	 */
	Close = 2,
	/**
	 * a Cancel button
	 */
	Cancel = 3
}
/// Runs a dialog with ok and cancel buttons, returning the selection
int runOkCancelDialog(Window parent, string message)
{
  import gtk.MessageDialog : MessageDialog;
  import gtkc.gtktypes : GtkDialogFlags, GtkMessageType, GtkButtonsType;
  auto okCancelDialog = new MessageDialog(parent, GtkDialogFlags.MODAL, GtkMessageType.WARNING, GtkButtonsType.OK_CANCEL, message);
  immutable int result = okCancelDialog.run;
  okCancelDialog.destroy();
  return result;
}