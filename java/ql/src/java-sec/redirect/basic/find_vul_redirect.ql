import java

class HttpServletResponseMethod extends Method{
HttpServletResponseMethod(){

  (this.getDeclaringType().getQualifiedName()="javax.servlet.http.HttpServletResponse" or
  this.getAnOverride().getDeclaringType().getQualifiedName()="javax.servlet.http.HttpServletResponse"
  )
  and
  (
    //this.getName()="getRuntime" or 
    this.getName()="sendRedirect"
  )
}
}



from MethodAccess methodaccess
where 
 methodaccess.getMethod() instanceof HttpServletResponseMethod  

 //漏洞名称，漏洞类名，漏洞方法
select "Redirect",methodaccess,methodaccess.getCaller(),methodaccess.getFile().getAbsolutePath()


