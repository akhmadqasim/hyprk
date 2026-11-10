import ghidra.app.script.GhidraScript;
import ghidra.app.decompiler.*;
import ghidra.program.model.listing.*;
import ghidra.program.model.address.*;
import java.io.*;
public class DumpRange extends GhidraScript {
  public void run() throws Exception {
    String[] a = getScriptArgs();
    Address lo = toAddr(a[0]), hi = toAddr(a[1]);
    PrintWriter w = new PrintWriter(new FileWriter(a[2]));
    DecompInterface d = new DecompInterface(); d.openProgram(currentProgram);
    FunctionIterator it = currentProgram.getFunctionManager().getFunctions(lo, true);
    while (it.hasNext()) { Function f = it.next(); if (f.getEntryPoint().compareTo(hi) > 0) break;
      DecompileResults r = d.decompileFunction(f, 60, monitor);
      w.println("//==== " + f.getEntryPoint() + " " + f.getName());
      if (r != null && r.getDecompiledFunction() != null) w.println(r.getDecompiledFunction().getC());
    }
    w.close();
  }
}
