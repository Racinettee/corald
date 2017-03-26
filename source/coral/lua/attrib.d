module coral.lua.attrib;

/// Specifies the type of method that the binding will deal with
enum MethodType : string
{
    none = "none",
    func = "function",
    method = "method",
    ctor = "ctor"
}
/// Specifies the kind of return value the binding will deal in
enum RetType : string
{
    none = "none",
    lightud = "lightud",
    userdat = "userdat"
}
/// Specifies the type of data that the binding should treat as
enum MemberType : string
{
    none = "none",
    lightud = "lightud",
    userdat = "userdat",
}
/// Declare above desired field to have the luabinding pick it up
/// For classes, only the name field matters
struct LuaExport
{
    /// Name that luad should use (unimplemented yet)
    string name = "";
    /// Help the exporting routine distinguish things like userdata vs lightuserdata
    MethodType type;
    /// Sub-member to refer to during the exporting routine
    string submember = "";
    /// Return type to put on the stack
    RetType rtype;
    /// Member type
    MemberType memtype;
}