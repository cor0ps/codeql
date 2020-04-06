import java

class FileMethod extends Method{
FileMethod(){
  this.getDeclaringType().getQualifiedName()="java.io.File" 
}
}
class FileInputStreamMethod extends Method{
FileInputStreamMethod(){
  this.getDeclaringType().getQualifiedName()="java.io.FileInputStreamMethod" 
}
}

class NioFilesMethod extends Method{
NioFilesMethod(){
  this.getDeclaringType().getQualifiedName()="java.nio.file.Files" 
}
}
class RandomAccessFileMethod extends Method{
RandomAccessFileMethod(){
  this.getDeclaringType().getQualifiedName()="java.io.RandomAccessFile" 
}
}


from MethodAccess methodaccess
where 
 methodaccess.getMethod() instanceof FileMethod   or
 methodaccess.getMethod() instanceof FileInputStreamMethod or
 methodaccess.getMethod() instanceof NioFilesMethod  or
 methodaccess.getMethod() instanceof RandomAccessFileMethod
 //漏洞名称，漏洞类名，漏洞方法
select "Path_Traversal",methodaccess,methodaccess.getCaller(),methodaccess.getFile().getAbsolutePath()


