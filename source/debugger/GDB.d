module coral.debugger.GDB;

import core.stdc.stdio;
import core.thread;

import std.string;
import std.stdio;
import std.process;

import coral.debugger.IDebugger;

class GDB : IDebugger
{
  // extern(C) int function(void* userData) GSourceFunc
  this(string executable)
  {
    process = pipeProcess(["gdb", "--interpreter=mi", executable]);
    ioReadingThread = new IOReadingThread(process.stdout, process.stderr, &readStdOut, &readStdErr);
    ioReadingThread.start();
  }
  ~this()
  {
    if(started)
      stop();
  }

  final void start()
  {
    process.stdin.writeln("r");
    process.stdin.flush();
    started = true;
  }

  final void stop()
  {
    process.stdin.writeln("q\ny");
    process.stdin.flush();
    ioReadingThread.stop();
    wait(process.pid);
    started = false;
  }

  final void stepInto()
  {
    process.stdin.writeln("s");
    process.stdin.flush();
  }

  final void stepOver()
  {
    process.stdin.writeln("n");
    process.stdin.flush();
  }

  final void stepOut()
  {
    process.stdin.writeln("f");
    process.stdin.flush();
  }

  final void setBreakpoint(const string filename, int linenum)
  {
    process.stdin.writefln("B %s:%i", filename, linenum);
    process.stdin.flush();
  }
  
  ProcessPipes process;
  IOReadingThread ioReadingThread;
  private bool started = false;

  alias OutputHandler = void delegate(string);

  class IOReadingThread : Thread
  {
    this(File stdOutput, File stdError, OutputHandler stdOutHandler, OutputHandler stdErrHandler)
    {
      super(&run);
      stdOut = stdOutput;
      stdErr = stdError;
      stdOutCallback = stdOutHandler;
      stdErrCallback = stdErrHandler;
    }
    @safe void stop()
    {
      running = false;
    }
  private:
    void run()
    {
      string output = "", error = "";
      while(running)
      {
        while(!stdOut.eof)
        {
          output = stdOut.readln();
          stdOutCallback(output);
        }
        while(!stdErr.eof)
        {
          error = stdErr.readln();
          stdErrCallback(error);
        }
        sleep(dur!("msecs")( 80 ));
      }
    }
    File stdOut, stdErr;
    bool running = true;
    OutputHandler stdOutCallback;
    OutputHandler stdErrCallback;
  }


  private void readStdOut(string line)
  {
    synchronized(this)
    {
      writeln("GDB Out: "~line);
    }
  }

  private void readStdErr(string line)
  {
    synchronized(this)
    {
      writeln("GDB Err: "~line);
    }
  }
}

