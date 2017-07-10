local lfs = require 'lfs'

return {
    is_dir = function(filepath)
        return lfs.attributes(filepath).mode == 'directory'
    end,
    trim_off_filename = function(filepath)
        return filepath:sub(0, filepath:find("/[^/]*$"))
    end
}
