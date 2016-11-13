module coral.util.windows;

import gtk.Window;

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