module coral.plugin.callbackmanager;

import reef.lua.state : State;

class CallbackManager
{
    immutable string[] eventNames = ["on_editor_created", "on_editor_closed"];
    bool hasMethod(string methodName)
    {
        return (methodName in methods) !is null;
    }
    void addMethod(string methodName)
    {
        methods[methodName] = true;
    }
    void registerModule(State state, string moduleName)
    {
        foreach(name; eventNames)
        {
            import luad.c.lua : lua_getfield, lua_isnil;
            import std.string : toStringz;
            lua_getfield(state.state, -1, toStringz(name));
            if(!lua_isnil(state.state, -1))
            {
                methods[name~"-"~moduleName] = true;
            }
            lua_pop(2);
        }
    }
    private bool[string] methods;
}
