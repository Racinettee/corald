module coral.MemUtil;

T alloc(T, Args...) (Args args) 
{
    import std.conv : emplace;
    import core.stdc.stdlib : malloc;
    import core.memory : GC;
 
    // get class size of class instance in bytes
    auto size = __traits(classInstanceSize, T);
 
    // allocate memory for the object
    auto memory = malloc(size)[0..size];
    if(!memory)
    {
        import core.exception : onOutOfMemoryError;
        onOutOfMemoryError();
    }                    
 
    // notify garbage collector that it should scan this memory
    GC.addRange(memory.ptr, size);
 
    // call T's constructor and emplace instance on
    // newly allocated memory
    return emplace!(T, Args)(memory, args);                                    
}
 
void dealloc(T)(T obj) 
{
    import core.stdc.stdlib : free;
    import core.memory : GC;
 
    // calls obj's destructor
    destroy(obj); 
 
    // garbage collector should no longer scan this memory
    GC.removeRange(cast(void*)obj);
 
    // free memory occupied by object
    free(cast(void*)obj);
}