import java

class SpelExpressionParserMethod extends Method{
SpelExpressionParserMethod(){
  this.getDeclaringType().getQualifiedName()="org.springframework.expression.ExpressionParser" and
  (
    this.getName()="parseExpression"
  )
}
}



from MethodAccess methodaccess
where 
 methodaccess.getMethod() instanceof SpelExpressionParserMethod  

 //漏洞名称，漏洞类名，漏洞方法
select "SpEl",methodaccess,methodaccess.getCaller(),methodaccess.getFile().getAbsolutePath()


