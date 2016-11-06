lgi = require 'lgi'
lfs = require 'lfs'
Gtk = lgi.require('Gtk')

print mainWindow
print mainWindow.__index

print "If you see this image while scrolling you have been visited by the "
print "Dooting peruvian flute skeleton"

mainWindow\openFile lfs.currentdir! .. "/script/moonhello.moon"

moonWindow = with Gtk.Window!
  .title = 'moon'
  .default_width = 400
  .default_height = 300
  \show_all!

class Thing
  name: "unknown"

class Person extends Thing
  say_name: => print "Hello, I am #{@name}!"

with Person!
  .name = "MoonScript"
  \say_name!

say_hello = -> print "Hello there"

say_hello!

print "Good bones and calcium will come to you"
print "But only if you comment 'gracias senor esqueleto'"
print "gracias senor esqueleto"