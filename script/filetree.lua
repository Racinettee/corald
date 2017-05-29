lgi = require 'lgi'
lfs = require 'lfs'
Gtk = lgi.require('Gtk')

function print_table(tbl)
    for k,v in pairs(tbl) do
       print(k, v)
    end
end

function editor_created(window)
    local ftree = ScrolledFileTree.new(lfs.currentdir() .. '/script')
    local fstore = Gtk.TreeStore(ftree.store)
    local scrolled_window = Gtk.ScrolledWindow(ftree.window)
    local tree_view = scrolled_window:get_child()
    function tree_view:on_row_activated(treePath, treeColumn)
        local function build_path_to_file(row)
            if row == nil then
                return ''
            end
            if fstore:iter_parent(row) == nil then
                return ''
            end
            return build_path_to_file(fstore:iter_parent(row)) ..
                '/' .. fstore:get_value(row, 1):get_string()
        end
        print(treePath, treeColumn)
        window:openFile(ftree:get_path() .. build_path_to_file(fstore:get_iter(treePath)))
    end
    
    local moonWindow = Gtk.Window {
        title = 'moon',
        default_width = 400,
        default_height = 300
    }
    moonWindow:add(scrolled_window)
    moonWindow:show()
end
return {
    on_editor_created = editor_created
}
