lgi = require 'lgi'
lfs = require 'lfs'
Gtk = lgi.require('Gtk')

function editor_created(window)
    local menu_bar = Gtk.MenuBar(window.menubar)
    menu_bar:get_children()[1]:get_submenu():insert(Gtk.MenuItem {
        label = 'Open Path',
        on_activate = function()
            local path_chooser = Gtk.FileChooserDialog {
                title = 'Select Folder',
                buttons = {
                    { Gtk.STOCK_OK, Gtk.ResponseType.ACCEPT },
                    { Gtk.STOCK_CANCEL, Gtk.ResponseType.CANCEL },
                },
                action = 'SELECT_FOLDER'
            }
            local path = ''
            if path_chooser:run() == Gtk.ResponseType.Cancel then
                return
            end
            path = path_chooser:get_filename()
            path_chooser:destroy()
            if path == '' then
                return
            end
            local ftree = ScrolledFileTree.new(path)
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
    }, 2)
end
-- Return the callbacks to the plugin system
return {
    on_editor_created = editor_created
}
