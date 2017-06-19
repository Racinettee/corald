module util.app.threads;

import core.thread;

private ThreadGroup threadGroup;

static this()
{
    threadGroup = new ThreadGroup();
}

void joinAll()
{
}
