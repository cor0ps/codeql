import java

class StatementMethod  extends Method{
StatementMethod(){
  this.getDeclaringType().getQualifiedName()="java.sql.Statement" and
 this.getName()="executeQuery" 
}
}

class PrepareStatementMethod extends Method{
PrepareStatementMethod(){
   this.getDeclaringType().getQualifiedName()="java.sql.PreparedStatement" and
 this.getName()="executeQuery" 
}
}

class MapperAnnotation extends Annotation{
  MapperAnnotation(){
 this.getType().hasQualifiedName("org.apache.ibatis.annotations", "Mapper")
}
}

from MethodAccess methodaccess
where 
methodaccess.getMethod() instanceof StatementMethod  or
methodaccess.getMethod() instanceof PrepareStatementMethod or
methodaccess.getMethod().getDeclaringType().getAnAnnotation() instanceof MapperAnnotation

 //漏洞名称，漏洞类名，漏洞方法
select "SQLI_INJECTION",methodaccess,methodaccess.getCaller(),methodaccess.getFile().getAbsolutePath()

