import semmle.code.java.dataflow.DataFlow
import semmle.code.java.dataflow.FlowSources


class Test extends TaintTracking::Configuration
{
    Test(){
        this="ProcessBuilder Command Inject"
    }

    override predicate isSource(DataFlow::Node source){
        //source instanceof RemoteFlowSource 
        source.asExpr() instanceof StringLiteral
    }

    override predicate isSink(DataFlow::Node sink){
        exists(Call call|call.getArgument(0)=sink.asExpr()  and
        call.getCallee().(Constructor).getDeclaringType().hasQualifiedName("java.lang", "ProcessBuilder")
        )
    }

}

from DataFlow::Node source,DataFlow::Node sink,Test test
where 
  test.hasFlow(source, sink)
select source,sink