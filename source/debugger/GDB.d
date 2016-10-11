module coral.debugger.GDB;

import std.process;

import coral.debugger.IDebugger;

class GDB : IDebugger
{
  this(string executable)
  {
    pipes = pipeProcess(["gdb", "--interpreter=mi", executable]);
  }

  final void start()
  {
    pipes.stdin.writeln("r");
  }

  final void stop()
  {
    pipes.stdin.writeln("q\n", "y");
  }

  final void stepIn()
  {
    pipes.stdin.writeln("s");
  }

  final void stepOver()
  {
    pipes.stdin.writeln("n");
  }

  final void stepOut()
  {
    pipes.stdin.writeln("f");
  }

  ProcessPipes pipes;
}

