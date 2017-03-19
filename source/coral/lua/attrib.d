module coral.lua.attrib;

/// Declare above desired field to have luad pick it up
struct LuaExport
{
    /// Name that luad should use (unimplemented yet)
    string name = "";
    /// Help the exporting routine distinguish things like userdata vs lightuserdata
    string type = "function";
    /// Sub-member to refer to during the exporting routine
    string submember = "";
    /// Return type to put on the stack
    string returntype = "";
}