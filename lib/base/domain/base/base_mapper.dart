// =============================================================================
// BASE MAPPER - Flutter Project Template
// =============================================================================

/// Base mapper interface for converting between different data types
/// T: Source type, R: Result type
abstract class BaseMapper<T, R> {
  /// Map from source type to result type
  R map(T source);
  
  /// Map from result type back to source type (if applicable)
  T? mapReverse(R result);
  
  /// Map a list of source types to result types
  List<R> mapList(List<T> sources) {
    return sources.map((source) => map(source)).toList();
  }
  
  /// Map a list of result types back to source types
  List<T> mapListReverse(List<R> results) {
    return results.map((result) => mapReverse(result)).whereType<T>().toList();
  }
}

/// Base mapper with validation support
abstract class BaseMapperWithValidation<T, R> implements BaseMapper<T, R> {
  /// Validate source before mapping
  bool validateSource(T source);
  
  /// Validate result after mapping
  bool validateResult(R result);
  
  /// Map with validation
  @override
  R map(T source) {
    if (!validateSource(source)) {
      throw ArgumentError('Invalid source for mapping: $source');
    }
    
    final result = _map(source);
    
    if (!validateResult(result)) {
      throw ArgumentError('Invalid result after mapping: $result');
    }
    
    return result;
  }
  
  /// Implement the actual mapping logic here
  R _map(T source);
  
  @override
  T? mapReverse(R result) {
    if (!validateResult(result)) {
      return null;
    }
    
    return _mapReverse(result);
  }
  
  /// Implement the reverse mapping logic here
  T? _mapReverse(R result);
}

/// Base mapper for entity conversions
abstract class BaseEntityMapper<Entity, DTO, Model> {
  /// Convert DTO to Entity
  Entity dtoToEntity(DTO dto);
  
  /// Convert Entity to DTO
  DTO entityToDto(Entity entity);
  
  /// Convert Entity to Model
  Model entityToModel(Entity entity);
  
  /// Convert Model to Entity
  Entity modelToEntity(Model model);
  
  /// Convert lists
  List<Entity> dtoListToEntityList(List<DTO> dtos) {
    return dtos.map((dto) => dtoToEntity(dto)).toList();
  }
  
  List<DTO> entityListToDtoList(List<Entity> entities) {
    return entities.map((entity) => entityToDto(entity)).toList();
  }
  
  List<Model> entityListToModelList(List<Entity> entities) {
    return entities.map((entity) => entityToModel(entity)).toList();
  }
  
  List<Entity> modelListToEntityList(List<Model> models) {
    return models.map((model) => modelToEntity(model)).toList();
  }
}
