lgi = require 'lgi'
lfs = require 'lfs'
Gtk = lgi.require('Gtk')

moonWindow = with Gtk.Window!
    .title = 'moon'
    .default_width = 400
    .default_height = 300
    \show_all!

mainWindow\openFile lfs.currentdir! .. "/script/moonhello.moon"
