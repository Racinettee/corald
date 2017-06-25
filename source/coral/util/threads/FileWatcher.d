module coral.util.threads.filewatcher;

import coral.util.app.threads;

import core.time;
import std.concurrency;

import fswatch;

import std.stdio;

package class DirectoryMonitorThread : CancellableThread
{
    this(const string wpath)
    {
        watchPath = wpath;
    }
    override void run()
    {
        writeln("File watching thread created");
        immutable int period = 200;
        auto watcher = FileWatch(watchPath);
        while(true)
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
            if(isCancelled)
                break;
            sleep(period.msecs);
        }
        writeln("File watching thread finished");
    }
    private string watchPath;
    @property const string path() nothrow { return watchPath; }
}
