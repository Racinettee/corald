local lgi = require 'lgi'
local Gtk = lgi.require('Gtk')
local Pango = lgi.require('Pango')

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
						local page = Gtk.Widget(mainWindow:currentPage())
						print('gonna override that font ; )')
						for k,v in pairs(Pango) do
							print(k)
						end
						page:override_font(Pango.FontDescription.from_string(selected_font))
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
