module coral.debugger.GDB;

import core.stdc.stdio;

import std.string : toStringz;
import std.stdio : writeln;

import gtkc.glibtypes : GPid, GSpawnFlags;
import gtkc.glib : g_spawn_async_with_pipes;
//import glib.Spawn;
import glib.Source;
import glib.IOChannel;
import gio.File;
import gio.FileIF;

import coral.debugger.IDebugger;

class GDB : IDebugger
{
  this(string executable)
  {
    GError error;
    GError* perror;
    auto command = [toStringz("gdb"), toStringz("--interpreter=mi"), toStringz(executable)];
    int result = g_spawn_async_with_pipes(cast(const(char)*)toStringz("./"),
      cast(char**)command.ptr,
      cast(char**)0, GSpawnFlags.SEARCH_PATH, cast(GSpawnChildSetupFunc)0,
      cast(void*)0, &pid, &stdIn, &stdOut, &stdErr, &perror);

    IOChannel outChannel = new IOChannel(stdOut);
    IOChannel errChannel = new IOChannel(stdErr);
  }

  final void start()
  {
    fputs(toStringz("r\n"), process.standardInput);
  }

  final void stop()
  {
    fputs(toStringz("q\ny\n"), process.standardInput);
  }

  final void stepInto()
  {
    fputs(toStringz("s\n"), process.standardInput);
  }

  final void stepOver()
  {
    fputs(toStringz("n\n"), process.standardInput);
  }

  final void stepOut()
  {
    fputs(toStringz("f\n"), process.standardInput);
  }

  final void setBreakpoint(const string filename, int linenum)
  {
    fprintf(process.standardInput,
      toStringz("b %s:%i"), toStringz(filename), linenum);
  }
  
  GPid pid;
  int stdIn, stdOut, stdErr;

  private bool readStdOut(string line)
  {
    synchronized
    {
    printf(toStringz("GDB Out: "~line));//writeln("GDB Out: "~line);
    return true;
    }
  }

  private bool readStdErr(string line)
  {
    synchronized
    {
    printf(toStringz("GDB Err: "~line));//writeln("GDB Err: " ~line);
    return true;
    }
  }
}

