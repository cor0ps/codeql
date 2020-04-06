import java
import semmle.code.java.dataflow.DataFlow

from Constructor c,Call call,Expr expr
where 
     c.getDeclaringType().hasQualifiedName("java.lang", "ProcessBuilder") and
     call.getCallee()=c  and
     DataFlow::localFlow(DataFlow::exprNode(expr), DataFlow::exprNode(call.getArgument(0)))
select expr