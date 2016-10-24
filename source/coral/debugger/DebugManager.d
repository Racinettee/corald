module coral.debugger.DebugManager;

import coral.debugger.IDebugger;

DebugManager debugManager;

static this()
{
  debugManager = new DebugManager();
}

class DebugManager
{
  T newSession(T : IDebugger, Args...)(Args a)
  {
    T session = new T(a);
    registerSession(session);
    return session;
  }
  void registerSession(IDebugger instance)
  {
    debugInstances ~= instance;
  }
  void stopAll()
  {
    foreach(instance; debugInstances)
      instance.stop();
  }
  private IDebugger[] debugInstances;
}
