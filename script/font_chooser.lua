local lfs = require 'lfs'
local lgi = require 'lgi'
local Gtk = lgi.require('Gtk')
local Pango = lgi.require('Pango')



local notebook = Gtk.Notebook(mainWindow.notebook)
function notebook:on_page_added(child_widget, page_number)
	print('Page added: ', page_number)
	local page = notebook:get_nth_page(page_number)
	page:override_font(Pango.FontDescription.from_string('DejaVu Sans Mono Book'))
end

local menuItems = Gtk.MenuBar(mainWindow.menubar):get_children()
for k, menuItem in ipairs(menuItems) do
	if menuItem:get_label() == "_View" then
	
		local submenu = menuItem:get_submenu()
		if submenu == nil then
			submenu = Gtk.Menu()
			menuItem:set_submenu(submenu)
		end
		submenu:append(Gtk.MenuItem {
			label = 'Choose Font',
			on_activate = function()
				local selected_font = ''
				local chooser = Gtk.FontChooserDialog {
					title = 'Select a font',
					transient_for = Gtk.Window(mainWindow.window),
				}
				function chooser:on_response(response_code)
					if response_code == Gtk.ResponseType.OK then
						selected_font = chooser:get_font()
						Gtk.Widget(mainWindow:currentPage()):override_font(Pango.FontDescription.from_string(selected_font))
					end
					chooser:hide()
				end
				chooser:show()
			end
		})
		break
	end
end
menuItems = nil
