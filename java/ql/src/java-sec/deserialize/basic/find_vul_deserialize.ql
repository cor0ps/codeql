import java
/**
ObjectInputStream.readObject
ObjectInputStream.readUnshared
XMLDecoder.readObject
Yaml.load
XStream.fromXML
ObjectMapper.readValue
JSON.parseObject

https://xz.aliyun.com/t/2041
https://meizjm3i.github.io/2019/06/05/FastJson%E5%8F%8D%E5%BA%8F%E5%88%97%E5%8C%96%E8%A7%A3%E6%9E%90%E6%B5%81%E7%A8%8B/
https://www.cnkirito.moe/rpc-serialize-1/
*/

class ReadobjectMethod extends Method{
ReadobjectMethod(){
  this.getDeclaringType().getQualifiedName()="java.io.ObjectInputStream" and
  (
    this.getName()="readObject"
  )
}
}

class ReadUnsharedMethod extends Method{
ReadUnsharedMethod(){
  this.getDeclaringType().getQualifiedName()="java.io.ObjectInputStream" and
  (
    this.getName()="readUnshared"
  )
}
}

class XMLDecoderMethod  extends Method{
XMLDecoderMethod(){
  this.getDeclaringType().getQualifiedName()="java.beans.XMLDecoder" and
  this.getName()="readObject"
}
}

class YamlMethod  extends Method{
YamlMethod(){
  this.getDeclaringType().getQualifiedName()="org.yaml.snakeyaml.Yaml" and
  this.getName()="load"
}
}

class ObjectMapperMethod extends Method{
  ObjectMapperMethod(){
  this.getDeclaringType().getQualifiedName()="com.fasterxml.jackson.databind.ObjectMapper" and
  this.getName()="readValue"
}
}

class XStreamMethod extends Method{
  XStreamMethod(){
  this.getDeclaringType().getQualifiedName()="com.thoughtworks.xstream.XStream" and
  this.getName()="readValue"
}
}

class FastJsonMethod  extends Method{
FastJsonMethod(){
  this.getDeclaringType().getQualifiedName()="com.alibaba.fastjson.parser.DefaultJSONParser" and
  this.getName() ="parseObject"
}
}

class KryoMethod extends Method{
KryoMethod(){
  this.getDeclaringType().getQualifiedName()="com.esotericsoftware.kryo.Kryo" and
  this.getName() ="readObject"
}

}

from MethodAccess methodaccess
where 
 methodaccess.getMethod() instanceof ReadobjectMethod   or
 methodaccess.getMethod() instanceof ReadUnsharedMethod or
 methodaccess.getMethod() instanceof XMLDecoderMethod   or
 methodaccess.getMethod() instanceof YamlMethod         or
 methodaccess.getMethod() instanceof ObjectMapperMethod or
 methodaccess.getMethod() instanceof XStreamMethod      or
 methodaccess.getMethod() instanceof FastJsonMethod     or 
 methodaccess.getMethod() instanceof KryoMethod


 //漏洞名称，漏洞类名，漏洞方法
select "CommandInjection",methodaccess,methodaccess.getCaller(),methodaccess.getFile().getAbsolutePath()


