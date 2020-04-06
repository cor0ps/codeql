import semmle.code.java.dataflow.FlowSources
/*
寻找Runtime.getRuntime.exec()
*/

class RuntimeCommandTaint extends TaintTracking::Configuration{
RuntimeCommandTaint(){
    this="Comand Inject TaintTracking"
}

override predicate isSource(DataFlow::Node source){
source instanceof RemoteFlowSource //and
//(
    //exists(Method m|m.getName()="exec")
//)
}

override predicate isSink(DataFlow::Node sink){
//todo
exists(MethodAccess ma|ma.getMethod().getName()="exec" and ma.getArgument(0)=sink.asExpr())
}

}


from RuntimeCommandTaint commandConfig,DataFlow::Node source,DataFlow::Node sink
where commandConfig.hasFlow(source,sink)
select "untrusted input:",source,"command execute:",sink