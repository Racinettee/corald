module coral.util.app.threads;

import core.thread;
import core.atomic;

class CancellationToken
{
    this() { }
    this(Thread thread)
    {
        associatedThread = thread;
    }
    pure void opAssign(bool value) nothrow @nogc @safe
    {
        atomicStore(cancel, value);
    }
    pure bool opCast(bool) nothrow @nogc @safe
    {
        return atomicLoad(cancel);
    }
    @property Thread thread() nothrow
    {
        return associatedThread;
    }
    @property bool isCancelled()
    {
        return opCast!(bool);
    }
    private shared bool cancel = false;
    private Thread associatedThread = null;
}

public shared CancellationToken globalCancellation;


abstract class StoppableThread
{
    ~this()
    {
        import std.stdio: writeln;
        writeln("stoppable thread deleted");
    }
    abstract void stop()
}
