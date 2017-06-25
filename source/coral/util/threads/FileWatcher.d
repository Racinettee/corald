module coral.util.threads.filewatcher;

import coral.util.app.threads;

import core.time;
import std.concurrency;

import fswatch;

import std.stdio;

package class DirectoryMonitorThread : StoppableThread
{
    this(const string wpath)
    {
        watchPath = wpath;
        super(&run, wpath);
    }
    private static void run(string wpath)
    {
        writeln("File watching thread created");
        immutable int period = 200;
        auto watcher = FileWatch(wpath);
        bool running = true;
        while(running)
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
            receiveTimeout(dur!"msecs"(period),
                (bool v) { running = false; });
        }
        writeln("File watching thread finished");
    }
    private string watchPath;
    @property const string path() nothrow { return watchPath; }
}
