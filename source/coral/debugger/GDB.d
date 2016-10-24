module coral.debugger.GDB;

import core.stdc.stdio;
import core.thread;

import std.string;
import std.stdio;
import std.process;

import coral.debugger.IDebugger;

class GDB : IDebugger
{
  alias OutputHandler = void delegate(string);
  this(string executable, OutputHandler outHandler, OutputHandler errHandler)
  {
    process = pipeProcess(["gdb", "--interpreter=mi", executable]);
    ioReadingThread = new IOReadingThread(process.stdout, process.stderr, outHandler, errHandler);
    ioReadingThread.start();
  }
  ~this()
  {
    if(started)
      stop();
  }

  final void start()
  {
    if(!started)
    {
      process.stdin.writeln("r");
      process.stdin.flush();
      started = true;
    }
  }

  // There's a nuance where destructures will not be called
  // when gtk_main() is finished running.. so i've implemented
  // a guard where stop will not do its tasks again when already called'
  final void stop()
  {
    if(started)
    {
      process.stdin.writeln("q\ny");
      process.stdin.flush();
      ioReadingThread.stop();
      wait(process.pid);
      started = false;
    }
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

  final void cont()
  {
    process.stdin.writeln("c");
    process.stdin.flush();
  }

  final void pause()
  {
    // Pass 'CTRL-3' character code
    process.stdin.writeln([cast(char)0x3]);
    process.stdin.flush();
  }

  final void setBreakpoint(const string filename, int linenum)
  {
    process.stdin.writeln("b ", filename, ':', linenum);
    process.stdin.flush();
  }
private:
  ProcessPipes process;
  IOReadingThread ioReadingThread;
  bool started = false;

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
      synchronized(this) running = false;
    }
  private:
    void run()
    {
      string output = "", error = "";
      for(;;)
      {
        bool keepRunning;
        synchronized(this) keepRunning = running;

        if(!keepRunning)
          break;

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
      writeln("Exiting thread");
    }
    File stdOut, stdErr;
    bool running = true;
    OutputHandler stdOutCallback;
    OutputHandler stdErrCallback;
  }
}

