lgi = require 'lgi'
lfs = require 'lfs'
Gtk = lgi.require('Gtk')

editor_created = (window) ->
    ftree = ScrolledFileTree.new lfs.currentdir! .. "/script"
    print "Hola we added an activated handler"
    treeView = Gtk.TreeView(ftree.tree.treeView)
    print "Tree view?"
    print treeView
    moonWindow = with Gtk.Window!
        .title = 'moon'
        .default_width = 400
        .default_height = 300
        \add Gtk.ScrolledWindow(ftree.window)
        \show!
    print "Hola we made a window"

return {
    on_editor_created: editor_created
}
