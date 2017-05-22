lgi = require 'lgi'
lfs = require 'lfs'
Gtk = lgi.require('Gtk')

ftree = ScrolledFileTree.new lfs.currentdir! .. "/script"

moonWindow = with Gtk.Window!
    .title = 'moon'
    .default_width = 400
    .default_height = 300
    \add Gtk.ScrolledWindow(ftree.window)
    \show!

return { }