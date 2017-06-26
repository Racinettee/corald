module coral.util.app.threads;

import core.thread;
import core.atomic;

shared class CancellationToken
{
    this() { }
    pure void cancel() nothrow @nogc @safe
    {
        atomicStore(cancelToken, true);
    }
    @property pure bool isCancelled() nothrow @nogc @safe
    {
        return atomicLoad(cancelToken);
    }
    private shared bool cancelToken = false;
}

public shared CancellationToken globalCancellation;
private shared CancellationToken[ThreadID] cancellationTokens;
private ThreadGroup threadGroup;

static this()
{
    threadGroup = new ThreadGroup;
}
shared static this()
{
    globalCancellation = new shared CancellationToken;
}

void joinAllThreads()
{
    foreach(token; cancellationTokens.byValue)
        token.cancel;
    threadGroup.joinAll();
}

abstract class CancellableThread : Thread
{
    private shared CancellationToken cancellationToken = null;
    
    this()
    {
        this(new shared CancellationToken);
    }
    this(shared CancellationToken token)
    {
        cancellationToken = token;
        cancellationTokens[id] = cancellationToken;
        threadGroup.add(this);
        super(&runWrapper);
    }
    ~this()
    {
        cancellationToken = null;
    }
    @property pure bool isCancelled() @nogc @safe
    {
        return cancellationToken.isCancelled;
    }
    shared(CancellationToken) getCancellationToken() nothrow @nogc @safe
    {
        return cancellationToken;
    }
    abstract void run();
    private void runWrapper()
    {
        run();
        cancellationTokens.remove(id);
    }
}
