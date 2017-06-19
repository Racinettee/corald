module coral.util.app.threads;

import core.thread;

private static ThreadGroup threadGroup;

static this()
{
    threadGroup = new ThreadGroup();
}

void joinAll()
{
    threadGroup.joinAll();
}
