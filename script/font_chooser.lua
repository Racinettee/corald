local lfs = require 'lfs'
local lgi = require 'lgi'
local Gtk = lgi.require('Gtk')
local Pango = lgi.require('Pango')

return {
	on_editor_created = function(window)
		print("Editor created callback")
		-- Add a handler to update the font in each new tab
		local notebook = Gtk.Notebook(window.notebook)
		function notebook:on_page_added(child_widget, page_number)
			print('Page added: ', page_number)
			local page = notebook:get_nth_page(page_number)
			page:override_font(Pango.FontDescription.from_string('DejaVu Sans Mono Book'))
		end
		-- Add a choose font option to the "View" menu item
		local menuItems = Gtk.MenuBar(window.menubar):get_children()
		for k, menuItem in ipairs(menuItems) do
			if menuItem:get_label() == "_View" then
				local submenu = menuItem:get_submenu()
				if submenu == nil then
					submenu = Gtk.Menu()
					menuItem:set_submenu(submenu)
				end
				print("Will append to the submenu")
				submenu:append(Gtk.MenuItem {
					label = 'Choose Font',
					on_activate = function()
						local chooser = Gtk.FontChooserDialog {
							title = 'Select a font',
							transient_for = Gtk.Window(window.window),
						}
						function chooser:on_response(response_code)
							if response_code == Gtk.ResponseType.OK then
								local font_description = Pango.FontDescription.from_string(chooser:get_font())
								notebook:foreach(function(page)
									page:override_font(font_description)
								end)
							end
							chooser:hide()
						end
						chooser:show()
					end
				})
				break
			end
		end
	end
}
