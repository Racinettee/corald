module coral.plugin.callbackmanager;

import luad.c.all;
import reef.lua.state : State;

class CallbackManager
{
    enum
    {
        EDITOR_CREATED = "on_editor_created",
	EDITOR_CLOSED = "on_editor_closed"
    }
    immutable string[] eventNames = [EDITOR_CREATED, EDITOR_CLOSED];
    void registerModule(State state, string moduleName)
    {
        foreach(name; eventNames)
        {
            import std.string : toStringz;
            lua_getfield(state.state, -1, toStringz(name));
            if(!lua_isnil(state.state, -1) && lua_type(state.state, -1) == LUA_TFUNCTION)
            {
		import luad.c.lauxlib : luaL_ref;
                methods[name] ~= luaL_ref(state.state, LUA_REGISTRYINDEX);
            }
            lua_pop(state.state, 1);
        }
    }
    void callHandlers(State state, string callbackName, int delegate(State) argPusher)
    {
	auto callbackArray = methods[callbackName];
	foreach(reference; callbackArray)
	{
	    // Place a function on the stack from its reference, we'll just assume that the object is a function since it is check above in registerModule
	    lua_rawgeti(state.state, LUA_REGISTRYINDEX, reference);
	    // Call our delegate to get arguments on the stack
	    int nargs = argPusher(state);
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
