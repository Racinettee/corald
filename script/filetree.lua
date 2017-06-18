lgi = require 'lgi'
lfs = require 'lfs'
Gtk = lgi.require('Gtk')
Gdk = lgi.require('Gdk')

function editor_created(window)
    local menu_item = Gtk.MenuItem {
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
                    local row_parent = fstore:iter_parent(row)
                    if row_parent == nil then
                        return ''
                    end
                    return build_path_to_file(row_parent) ..
                        '/' .. fstore:get_value(row, 1):get_string()
                end
                local final_path = ftree:get_path() .. build_path_to_file(fstore:get_iter(treePath))
                local file_mode = lfs.attributes(final_path).mode
                if file_mode == 'file' then
                    window:openFile(final_path)
                elseif file_mode == 'directory' then
                    if tree_view:row_expanded(treePath) then
                        tree_view:collapse_row(treePath)
                    else
                        tree_view:expand_row(treePath, false)
                    end
                end
            end
            local moonWindow = Gtk.Window {
                title = 'moon',
                default_width = 300,
                default_height = 400
            }
            moonWindow:add(scrolled_window)
            moonWindow:show()
        end
    }
    local menu_bar = Gtk.MenuBar(window.menubar)
    menu_bar:get_children()[1]:get_submenu():insert(menu_item, 2)
    window:add_accelerator(menu_item._native, '<Primary><Shift>O', 'activate')
end
-- Return the callbacks to the plugin system
return {
    on_editor_created = editor_created
}

