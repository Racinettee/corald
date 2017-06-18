module coral.util.threads.filewatcher;

import coral.util.threads.stoppable;

import core.atomic;
import core.thread;

import fswatch;

import std.stdio;

package class DirectoryMonitorThread : Thread, IStoppable
{
    this(const string wpath)
    {
        watchPath = wpath;
        super(&run);
    }
    private void run()
    {
        writeln("File watching thread created");
        immutable int period = 200;
        atomicStore(stopToken, false);
        auto watcher = FileWatch(path);
        while(!atomicLoad(stopToken))
        {
            auto events = watcher.getEvents();
            foreach(event; events)
            {
                final switch(event.type) with(FileChangeEventType)
                {
                    case createSelf:
                        break;
                    case removeSelf:
                        break;
                    case create:
                        break;
                    case remove:
                        break;
                    case rename:
                        break;
                    case modify:
                        writeln("A file was modified");
                        break;
                }
            }
            Thread.sleep(period.msecs);
        }
        writeln("File watching thread finished");
    }
    private string watchPath;
    @property const string path() nothrow { return watchPath; }
    private shared bool stopToken;
    void stop()
    {
       atomicStore(stopToken, true);
    }
}
