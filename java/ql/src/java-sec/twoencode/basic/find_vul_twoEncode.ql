import java

/*
寻找一些关键的方法，只有方法名，没有固定的类，采用正则表达式匹配规则
*/
class EndsWithMethod extends Method{
EndsWithMethod(){
  this.getName().regexpMatch("endsWith")
}
}


from MethodAccess methodaccess
where 
 methodaccess.getMethod() instanceof EndsWithMethod  
 //漏洞名称，漏洞类名，漏洞方法
select "CommandInjection",methodaccess,methodaccess.getCaller(),methodaccess.getFile().getAbsolutePath()


