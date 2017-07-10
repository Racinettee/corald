lgi = require 'lgi'
lfs = require 'lfs'
Gtk = lgi.require('Gtk')
Gdk = lgi.require('Gdk')

function editor_created(window)
    local function is_file_dir(filepath)
        return lfs.attributes(final_path).mode == 'directory'
    end
    local function path_for_file(filepath)
        return filepath:sub(0, filepath:find("/[^/]*$"))
    end
    local ftree = nil
    local function get_filetree_selection()
        return Gtk.ScrolledWindow(ftree.window):get_child():get_selection()
    end
    local function build_path_to_file(row)
        local fstore = Gtk.TreeStore(ftree.store)
        local row_parent = fstore:iter_parent(row)
        if row_parent == nil then
            return ''
        end
        return build_path_to_file(row_parent) ..
            '/' .. fstore:get_value(row, 1):get_string()
    end
    -- This menu is to appear when a right click occurs on a file tree
    local context_menu = Gtk.Menu()
    context_menu:append(Gtk.MenuItem {
        label = 'New File',
        on_activate = function()
            -- Ftree is expected to have been initialized by the time this function is called
            local selected_row = get_filetree_selection()
            local store, row_iter = selected_row:get_selected()
            if row_iter then
                local file_path = ftree:get_path() .. build_path_to_file(row_iter)
                if not is_file_dir(file_path) then
                    file_path = path_for_file(file_path)
                end
                file = io.open(file_path .. 'New File', 'w')
                file:close()
            end
        end
    })
    context_menu:append(Gtk.MenuItem {
        label = 'New Folder',
        on_activate = function()
            local selected_row = get_filetree_selection()
            local store, row_iter = selected_row:get_selected()
            if row_iter then
                local file_path = ftree:get_path() .. build_path_to_file(row_iter)
                if not is_file_dir(file_path) then
                    file_path = path_for_file(file_path)
                end
                lfs.mkdir(file_path .. 'New Folder')
            end
        end
    })
    context_menu:append(Gtk.MenuItem {
        label = 'Copy',
        on_activate = function()
        end
    })
    context_menu:append(Gtk.MenuItem {
        label = 'Paste',
        on_activate = function()
        end
    })
    context_menu:append(Gtk.MenuItem {
        label = 'Rename',
        on_activate = function()
            local selected_row = get_filetree_selection()
            local store, row_iter = selected_row:get_selected()
        end
    })
    context_menu:append(Gtk.MenuItem {
        label = 'Delete',
        on_activate = function()
        end
    })
    context_menu:show_all()
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
            ftree = ScrolledFileTree.new(path)
            local fstore = Gtk.TreeStore(ftree.store)
            local scrolled_window = Gtk.ScrolledWindow(ftree.window)
            local tree_view = scrolled_window:get_child()
            function tree_view:on_row_activated(treePath, treeColumn)
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
            function tree_view:on_button_press_event(button_event)
                if button_event.button ~= 3 then return false end
                context_menu:popup_at_pointer()
                return false
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

