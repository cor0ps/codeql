import java

class RuntimeExecMethod extends Method{
RuntimeExecMethod(){
  this.getDeclaringType().getQualifiedName()="java.lang.Runtime" and
  (
    //this.getName()="getRuntime" or 
    this.getName()="exec"
  )
}
}

class ProcessBuilderMethod extends Method{
ProcessBuilderMethod(){
  this.getDeclaringType().getQualifiedName()="java.lang.ProcessBuilder" and
  this.getName()="start"
}
}

class ChannelExecMethod  extends Method{
ChannelExecMethod(){
  this.getDeclaringType().getQualifiedName()="com.jcraft.jsch.ChannelExec" and
  this.getName()="setCommand"
}
}

from MethodAccess methodaccess
where 
 methodaccess.getMethod() instanceof RuntimeExecMethod  or
 methodaccess.getMethod() instanceof ProcessBuilderMethod or
 methodaccess.getMethod() instanceof ChannelExecMethod
 //漏洞名称，漏洞类名，漏洞方法
select "CommandInjection",methodaccess,methodaccess.getCaller(),methodaccess.getFile().getAbsolutePath()


