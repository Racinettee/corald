lgi = require 'lgi'
lfs = require 'lfs'
Gtk = lgi.require('Gtk')

editor_created = (window) ->
	ftree = ScrolledFileTree.new lfs.currentdir! .. "/script"
	moonWindow = with Gtk.Window!
		.title = 'moon'
		.default_width = 400
		.default_height = 300
		\add Gtk.ScrolledWindow(ftree.window)
		\show!

return {
	on_editor_created: editor_created
}
