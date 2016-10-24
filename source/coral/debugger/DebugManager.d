module coral.debugger.DebugManager;

import coral.debugger.IDebugger;

DebugManager debugManager;

void initDebugManager()
{
  debugManager = new DebugManager();
}

void deinitDebugManager()
{
  debugManager.clearAll();
}

class DebugManager
{
  ~this()
  {
    stopAll();
  }
  T newSession(T : IDebugger, Args...)(Args a)
  {
    T session = new T(a);
    registerSession(session);
    return session;
  }
  void registerSession(IDebugger instance)
  {
    synchronized(this) debugInstances ~= instance;
  }
  void stopAll()
  {
    synchronized(this)
    { 
      foreach(instance; debugInstances)
        instance.stop();
    }
  }
  void clearAll()
  {
    synchronized(this)
    {
      stopAll();
      debugInstances = [];
    }
  }
  private IDebugger[] debugInstances;
}
