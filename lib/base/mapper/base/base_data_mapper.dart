abstract class BaseDataMapper<R, E> {
  const BaseDataMapper();

  E mapToEntity(R data);

  List<E> mapToListEntity(List<R>? listData) => listData?.map(mapToEntity).toList() ?? List.empty();
}

mixin DataMapperMixin<R, E>  {

  R mapToData(E entity);

  R? mapToNullableData(E? entity) => entity == null ? null : mapToData(entity);

  List<R>? mapToNullableListData(List<E>? entities) => entities?.map(mapToData).toList();

  List<R> mapToListData(List<E>? entities) => mapToNullableListData(entities) ?? List.empty();

}
