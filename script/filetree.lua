lgi = require 'lgi'
lfs = require 'lfs'
Gtk = lgi.require('Gtk')

function print_table(tbl)
    for k,v in pairs(tbl) do
	print(k, v)
    end
end

function editor_created(window)
    local ftree = ScrolledFileTree.new(lfs.currentdir() .. "/script")
    local scrolled_window = Gtk.ScrolledWindow(ftree.window)
    local tree_view = scrolled_window:get_child()
    function tree_view:on_row_activated(s, v)
        print(s, v)
        print("Hola!!!!")
    end
    print("Hola we added an activated handler")
    
    print(getmetatable(ftree))
    print_table(getmetatable(ftree))
    print_table(getmetatable(ftree).__class)
    --local tree = ftree.tree
    --local treeView = Gtk.TreeView(ftree.tree.treeView)
    --print("Tree view?")
    --print(treeView)
    local moonWindow = Gtk.Window {
        title = 'moon',
        default_width = 400,
        default_height = 300
    }
    moonWindow:add(Gtk.ScrolledWindow(ftree.window))
    moonWindow:show()
    print("Hola we made a window")
end
return {
    on_editor_created = editor_created
}
