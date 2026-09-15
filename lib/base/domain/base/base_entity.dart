// =============================================================================
// BASE ENTITY - Flutter Project Template
// =============================================================================

import 'package:freezed_annotation/freezed_annotation.dart';

/// Base entity class that all domain entities should extend
/// Provides common functionality and structure
abstract class BaseEntity {
  /// Unique identifier for the entity
  String get id;
  
  /// Creation timestamp
  DateTime? get createdAt;
  
  /// Last update timestamp
  DateTime? get updatedAt;
  
  /// Entity version for optimistic locking
  int? get version;
  
  /// Check if entity is valid
  bool get isValid;
  
  /// Validate entity and throw exception if invalid
  void validate();
  
  /// Create a copy of the entity with updated fields
  BaseEntity copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
  });
  
  /// Convert entity to map for serialization
  Map<String, dynamic> toMap();
  
  /// Create entity from map
  static BaseEntity fromMap(Map<String, dynamic> map) {
    throw UnimplementedError('fromMap must be implemented by subclasses');
  }
  
  /// Check if two entities are equal
  @override
  bool operator ==(Object other);
  
  /// Get entity hash code
  @override
  int get hashCode;
  
  /// String representation of entity
  @override
  String toString();
}

/// Base entity with common fields implementation
abstract class BaseEntityImpl implements BaseEntity {
  @override
  final String id;
  
  @override
  final DateTime? createdAt;
  
  @override
  final DateTime? updatedAt;
  
  @override
  final int? version;
  
  const BaseEntityImpl({
    required this.id,
    this.createdAt,
    this.updatedAt,
    this.version,
  });
  
  @override
  bool get isValid => id.isNotEmpty;
  
  @override
  void validate() {
    if (!isValid) {
      throw ArgumentError('Entity is not valid: $this');
    }
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BaseEntityImpl && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() => 'BaseEntityImpl(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, version: $version)';
}
