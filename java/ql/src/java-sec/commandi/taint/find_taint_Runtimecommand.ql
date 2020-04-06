import semmle.code.java.dataflow.FlowSources
import semmle.code.java.security.ExternalProcess
import DataFlow::PathGraph
/*
寻找Runtime.getRuntime.exec()
*/
class RuntimeExecMethod extends Method{
RuntimeExecMethod(){
  this.getDeclaringType().getQualifiedName()="java.lang.Runtime" and
  (
    //this.getName()="getRuntime" or 
    this.getName()="exec"
  )
}
}

class RuntimeCommandTaint extends TaintTracking::Configuration{
RuntimeCommandTaint(){
    this="Comand Inject TaintTracking"
}

override predicate isSource(DataFlow::Node source){
source instanceof RemoteFlowSource
}

override predicate isSink(DataFlow::Node sink){
//todo
sink.asExpr() instanceof ArgumentToExec
}

}

from RuntimeCommandTaint commandConfig,DataFlow::PathNode source,DataFlow::PathNode sink,StringArgumentToExec execArg
where commandConfig.hasFlowPath(source,sink) and sink.getNode() = DataFlow::exprNode(execArg)
select "untrusted input:",source,"command execute:",sink