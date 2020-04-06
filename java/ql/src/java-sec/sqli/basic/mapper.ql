import java

class MapperAnnotation extends Annotation{
  MapperAnnotation(){
 this.getType().hasQualifiedName("org.apache.ibatis.annotations", "Mapper")
}
}

from MethodAccess methodaccess
where methodaccess.getMethod().getDeclaringType().getAnAnnotation() instanceof MapperAnnotation
select methodaccess