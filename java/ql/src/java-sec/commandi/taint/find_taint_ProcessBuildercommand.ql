import semmle.code.java.dataflow.FlowSources
import java
import semmle.code.java.StringFormat
/*
寻找Runtime.getRuntime.exec()
*/
//判断string[]中可以控制的


class ProcessBuilderCommandTaint extends TaintTracking::Configuration{
ProcessBuilderCommandTaint(){
    this="Comand Inject TaintTracking"
}

override predicate isSource(DataFlow::Node source){
source instanceof RemoteFlowSource or
source.asExpr() instanceof StringLiteral

}
//new ProcessBuilder(cmdlist)
override predicate isSink(DataFlow::Node sink){
//todo
exists(Call call|call.getArgument(0)=sink.asExpr() and
call.getCallee().(Constructor).getDeclaringType().hasQualifiedName("java.lang", "ProcessBuilder"))
}
}


from ProcessBuilderCommandTaint commandConfig,DataFlow::Node source,DataFlow::Node sink
where commandConfig.hasFlow(source,sink)
select "untrusted input:",source,"command execute:",sink
