module coral.util.app.threads;

import core.thread;

class StoppableThread: Thread
{
    abstract void run();
    abstract void stop();
    this()
    {
        super(&runWrapper);
    }
    private void runWrapper()
    {
        run();
    }
}

private static ThreadGroup threadGroup;

static this()
{
    threadGroup = new ThreadGroup();
}

void addThread(StoppableThread thread)
{
    threadGroup.add(thread);
}

void joinAllThreads()
{
    threadGroup.joinAll();
}
