// =============================================================================
// BASE LAYER EXPORTS - Flutter Project Template
// =============================================================================

// =============================================================================
// CORE UTILITIES
// =============================================================================
export 'utils/utils.dart';
export 'utils/currency_symbols.dart';
export 'utils/debouncer.dart';
export 'utils/device_id_util.dart';
export 'utils/function/scope_functions.dart';
export 'utils/validation/validation_utils.dart';

// =============================================================================
// ERROR HANDLING & EXCEPTIONS
// =============================================================================
export 'errors/base/app_exception.dart';
export 'errors/base/app_exception_wrapper.dart';
export 'errors/base/exception_mapper.dart';
export 'errors/mapper/exception_message_mapper.dart';
export 'errors/remote/remote_exception.dart';
export 'errors/remote/server_error.dart';
export 'errors/remote/server_error_detail.dart';
export 'errors/uncaught/app_uncaught_exception.dart';

// =============================================================================
// NETWORK & API
// =============================================================================
export 'network/base/api_client_default_settings.dart';
export 'network/base/dio_builder.dart';
export 'network/error_mapper/rest_exception_mapper.dart';
export 'network/interceptor/access_token_interceptor.dart';
export 'network/interceptor/admin_token_interceptor.dart';
export 'network/interceptor/authorization_interceptor.dart';
export 'network/interceptor/base_interceptor.dart';
export 'network/interceptor/connectivity_interceptor.dart';
export 'network/interceptor/custom_log_interceptor.dart';

// =============================================================================
// DATA MAPPING & TRANSFORMATION
// =============================================================================
export 'mapper/base/base_data_mapper.dart';
export 'mapper/base/base_error_response_mapper.dart';
export 'mapper/base/base_success_response_mapper.dart';
export 'mapper/base_error_mapper/json_array_error_mapper.dart';
export 'mapper/base_error_mapper/json_object_error_mapper.dart';
export 'mapper/base_success_mapper/json_array_success_mapper.dart';
export 'mapper/base_success_mapper/json_object_success_mapper.dart';

// =============================================================================
// STORAGE & PREFERENCES
// =============================================================================
export 'preference/app_preferences.dart';

// =============================================================================
// LOGGING & MONITORING
// =============================================================================
export 'log/config.dart';
export 'log/log_config.dart';
export 'log/log_utils.dart';

// =============================================================================
// EXTENSIONS & UTILITIES
// =============================================================================
export 'extensions/extensions.dart';
export 'extensions/context_ext.dart';
export 'extensions/list_ext.dart';
export 'extensions/num_ext.dart';
export 'extensions/stream_ext.dart';
export 'extensions/string_ext.dart';
export 'extensions/widget_ext.dart';

// =============================================================================
// COMMON WIDGETS & COMPONENTS
// =============================================================================
export 'common_widget/common_widget.dart';
export 'common_widget/custom_back_button.dart';
export 'common_widget/custom_button.dart';
export 'common_widget/custom_tap.dart';
export 'common_widget/drop_down_menu_widget.dart';
export 'common_widget/loading_dialogs.dart';
export 'common_widget/outline_text_field.dart';
export 'common_widget/page_loading_widget.dart';
export 'common_widget/price_view.dart';
export 'common_widget/status_widget.dart';
export 'common_widget/swipe_button.dart';
export 'common_widget/touchable_opacity.dart';

// =============================================================================
// BASE WIDGETS & TRANSITIONS
// =============================================================================
export 'widget/page_transition.dart';

// =============================================================================
// DOMAIN MODELS & ENTITIES
// =============================================================================
export 'domain/entity/page_info_entity.dart';

// =============================================================================
// CONSTANTS & CONFIGURATION
// =============================================================================
export 'constants/constants.dart';
export 'constants/app/app_environment.dart';
export 'constants/app/flavor_extension.dart';
export 'constants/environment/environment_constants.dart';
export 'constants/model/shared_enum.dart';
export 'constants/model/typedef.dart';
export 'constants/preference/shared_preference_constants.dart';
export 'constants/server/server_request_response_constants.dart';
export 'constants/server/server_timeout_constants.dart';


