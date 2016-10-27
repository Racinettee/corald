lgi = require 'lgi'
Gtk = lgi.require('Gtk')

moonWindow = with Gtk.Window!
  .title = 'moonWindow'
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
print "Frirnds the tv shows"
a, b, c = 1, 2, 3

say_hello = -> print "Hello there"

say_hello!