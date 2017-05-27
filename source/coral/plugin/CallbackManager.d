module coral.plugin.callbackmanager;

import luad.c.all;
import reef.lua.state : State;

class CallbackManager
{
    enum
    {
        EDITOR_CREATED = "on_editor_created",
        EDITOR_CLOSED = "on_editor_closed",
        BEFORE_START = "on_before_start",
        BEFORE_END = "on_before_end"
    }
    this()
    {
        methods[EDITOR_CREATED] = [];
        methods[EDITOR_CLOSED] = [];
    }
    immutable string[] eventNames = [EDITOR_CREATED, EDITOR_CLOSED, BEFORE_START, BEFORE_END];
    void registerModule(State state, string moduleName)
    {
        foreach(name; eventNames)
        {
            import std.string : toStringz;
            lua_getfield(state.state, -1, toStringz(name));
            if(lua_isnil(state.state, -1))
            {
                lua_pop(state.state, 1);
                continue;
            }
            if(lua_type(state.state, -1) == LUA_TFUNCTION)
            {
                methods[name] ~= luaL_ref(state.state, LUA_REGISTRYINDEX);
            }
        }
    }
    void callHandlers(State state, string callbackName, int delegate(State) argPusher)
    {
        import std.stdio : writeln;
        writeln("Call handlers...");
	auto callbackArray = (callbackName in methods);
        //auto callbackArray = methods[callbackName];
	if(callbackArray is null)
	    return;
        foreach(reference; *callbackArray)
        {
            // Place a function on the stack from its reference, we'll just assume that the object is a function since it is check above in registerModule
            lua_rawgeti(state.state, LUA_REGISTRYINDEX, reference);
            // Call our delegate to get arguments on the stack
            int nargs = (!(argPusher is null) ? argPusher(state) : 0);
            // Call the function
            lua_pcall(state.state, nargs, 1, 0);
        }
    }
    private int[][string] methods;
    private static bool instantiated;
    private __gshared CallbackManager instance;
    static CallbackManager get()
    {
	if(!instantiated)
	{
	    synchronized(CallbackManager.classinfo)
	    {
	        if(!instance)
		{
		    instance = new CallbackManager();
		}
		instantiated = true;
	    }
	}
	return instance;
    }
}
