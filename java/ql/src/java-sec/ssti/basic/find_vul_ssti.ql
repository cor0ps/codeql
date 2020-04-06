import java
/*
https://portswigger.net/research/server-side-template-injection 
目前收集的模板有：freemaker,Velocity,Twig




1、freemaker
https://www.netsparker.com/blog/web-security/server-side-template-injection/
https://xz.aliyun.com/t/4846
2、Velocity
Velocity.evaluate
*/

class FreemakerMethod extends Method{
FreemakerMethod(){
  this.getDeclaringType().getQualifiedName()="org.apache.velocity.app.Velocity" and
  (
    this.getName()="evaluate"
  )
}
}

class VelocityMethod extends Method{
VelocityMethod(){
  this.getDeclaringType().getQualifiedName()="org.apache.velocity.app.Velocity" and
  (
    this.getName()="evaluate"
  )
}
}


from MethodAccess methodaccess
where 
 methodaccess.getMethod() instanceof VelocityMethod  
 //漏洞名称，漏洞类名，漏洞方法
select "SSTI",methodaccess,methodaccess.getCaller(),methodaccess.getFile().getAbsolutePath()


