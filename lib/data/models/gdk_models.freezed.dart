// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gdk_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GdkConfig _$GdkConfigFromJson(Map<String, dynamic> json) {
  return _GdkConfig.fromJson(json);
}

/// @nodoc
mixin _$GdkConfig {
  @JsonKey(name: 'datadir')
  String? get dataDir => throw _privateConstructorUsedError;
  @JsonKey(name: 'tordir')
  String? get torDir => throw _privateConstructorUsedError;
  @JsonKey(name: 'registrydir')
  String? get registryDir => throw _privateConstructorUsedError;
  @JsonKey(name: 'log_level', defaultValue: GdkConfigLogLevelEnum.info)
  GdkConfigLogLevelEnum? get logLevel => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkConfigCopyWith<GdkConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkConfigCopyWith<$Res> {
  factory $GdkConfigCopyWith(GdkConfig value, $Res Function(GdkConfig) then) =
      _$GdkConfigCopyWithImpl<$Res, GdkConfig>;
  @useResult
  $Res call(
      {@JsonKey(name: 'datadir') String? dataDir,
      @JsonKey(name: 'tordir') String? torDir,
      @JsonKey(name: 'registrydir') String? registryDir,
      @JsonKey(name: 'log_level', defaultValue: GdkConfigLogLevelEnum.info)
      GdkConfigLogLevelEnum? logLevel});
}

/// @nodoc
class _$GdkConfigCopyWithImpl<$Res, $Val extends GdkConfig>
    implements $GdkConfigCopyWith<$Res> {
  _$GdkConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dataDir = freezed,
    Object? torDir = freezed,
    Object? registryDir = freezed,
    Object? logLevel = freezed,
  }) {
    return _then(_value.copyWith(
      dataDir: freezed == dataDir
          ? _value.dataDir
          : dataDir // ignore: cast_nullable_to_non_nullable
              as String?,
      torDir: freezed == torDir
          ? _value.torDir
          : torDir // ignore: cast_nullable_to_non_nullable
              as String?,
      registryDir: freezed == registryDir
          ? _value.registryDir
          : registryDir // ignore: cast_nullable_to_non_nullable
              as String?,
      logLevel: freezed == logLevel
          ? _value.logLevel
          : logLevel // ignore: cast_nullable_to_non_nullable
              as GdkConfigLogLevelEnum?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GdkConfigImplCopyWith<$Res>
    implements $GdkConfigCopyWith<$Res> {
  factory _$$GdkConfigImplCopyWith(
          _$GdkConfigImpl value, $Res Function(_$GdkConfigImpl) then) =
      __$$GdkConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'datadir') String? dataDir,
      @JsonKey(name: 'tordir') String? torDir,
      @JsonKey(name: 'registrydir') String? registryDir,
      @JsonKey(name: 'log_level', defaultValue: GdkConfigLogLevelEnum.info)
      GdkConfigLogLevelEnum? logLevel});
}

/// @nodoc
class __$$GdkConfigImplCopyWithImpl<$Res>
    extends _$GdkConfigCopyWithImpl<$Res, _$GdkConfigImpl>
    implements _$$GdkConfigImplCopyWith<$Res> {
  __$$GdkConfigImplCopyWithImpl(
      _$GdkConfigImpl _value, $Res Function(_$GdkConfigImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dataDir = freezed,
    Object? torDir = freezed,
    Object? registryDir = freezed,
    Object? logLevel = freezed,
  }) {
    return _then(_$GdkConfigImpl(
      dataDir: freezed == dataDir
          ? _value.dataDir
          : dataDir // ignore: cast_nullable_to_non_nullable
              as String?,
      torDir: freezed == torDir
          ? _value.torDir
          : torDir // ignore: cast_nullable_to_non_nullable
              as String?,
      registryDir: freezed == registryDir
          ? _value.registryDir
          : registryDir // ignore: cast_nullable_to_non_nullable
              as String?,
      logLevel: freezed == logLevel
          ? _value.logLevel
          : logLevel // ignore: cast_nullable_to_non_nullable
              as GdkConfigLogLevelEnum?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkConfigImpl extends _GdkConfig {
  const _$GdkConfigImpl(
      {@JsonKey(name: 'datadir') this.dataDir,
      @JsonKey(name: 'tordir') this.torDir,
      @JsonKey(name: 'registrydir') this.registryDir,
      @JsonKey(name: 'log_level', defaultValue: GdkConfigLogLevelEnum.info)
      this.logLevel})
      : super._();

  factory _$GdkConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$GdkConfigImplFromJson(json);

  @override
  @JsonKey(name: 'datadir')
  final String? dataDir;
  @override
  @JsonKey(name: 'tordir')
  final String? torDir;
  @override
  @JsonKey(name: 'registrydir')
  final String? registryDir;
  @override
  @JsonKey(name: 'log_level', defaultValue: GdkConfigLogLevelEnum.info)
  final GdkConfigLogLevelEnum? logLevel;

  @override
  String toString() {
    return 'GdkConfig(dataDir: $dataDir, torDir: $torDir, registryDir: $registryDir, logLevel: $logLevel)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkConfigImpl &&
            (identical(other.dataDir, dataDir) || other.dataDir == dataDir) &&
            (identical(other.torDir, torDir) || other.torDir == torDir) &&
            (identical(other.registryDir, registryDir) ||
                other.registryDir == registryDir) &&
            (identical(other.logLevel, logLevel) ||
                other.logLevel == logLevel));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, dataDir, torDir, registryDir, logLevel);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkConfigImplCopyWith<_$GdkConfigImpl> get copyWith =>
      __$$GdkConfigImplCopyWithImpl<_$GdkConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkConfigImplToJson(
      this,
    );
  }
}

abstract class _GdkConfig extends GdkConfig {
  const factory _GdkConfig(
      {@JsonKey(name: 'datadir') final String? dataDir,
      @JsonKey(name: 'tordir') final String? torDir,
      @JsonKey(name: 'registrydir') final String? registryDir,
      @JsonKey(name: 'log_level', defaultValue: GdkConfigLogLevelEnum.info)
      final GdkConfigLogLevelEnum? logLevel}) = _$GdkConfigImpl;
  const _GdkConfig._() : super._();

  factory _GdkConfig.fromJson(Map<String, dynamic> json) =
      _$GdkConfigImpl.fromJson;

  @override
  @JsonKey(name: 'datadir')
  String? get dataDir;
  @override
  @JsonKey(name: 'tordir')
  String? get torDir;
  @override
  @JsonKey(name: 'registrydir')
  String? get registryDir;
  @override
  @JsonKey(name: 'log_level', defaultValue: GdkConfigLogLevelEnum.info)
  GdkConfigLogLevelEnum? get logLevel;
  @override
  @JsonKey(ignore: true)
  _$$GdkConfigImplCopyWith<_$GdkConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GdkConnectionParams _$GdkConnectionParamsFromJson(Map<String, dynamic> json) {
  return _GdkConnectionParams.fromJson(json);
}

/// @nodoc
mixin _$GdkConnectionParams {
  String? get name => throw _privateConstructorUsedError;
  String? get proxy => throw _privateConstructorUsedError;
  @JsonKey(name: 'use_tor')
  bool? get useTor => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_agent')
  String? get userAgent => throw _privateConstructorUsedError;
  @JsonKey(name: 'spv_enabled')
  bool? get spvEnabled => throw _privateConstructorUsedError;
  @JsonKey(name: 'cert_expiry_threshold')
  int? get certExpiryThreshold => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkConnectionParamsCopyWith<GdkConnectionParams> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkConnectionParamsCopyWith<$Res> {
  factory $GdkConnectionParamsCopyWith(
          GdkConnectionParams value, $Res Function(GdkConnectionParams) then) =
      _$GdkConnectionParamsCopyWithImpl<$Res, GdkConnectionParams>;
  @useResult
  $Res call(
      {String? name,
      String? proxy,
      @JsonKey(name: 'use_tor') bool? useTor,
      @JsonKey(name: 'user_agent') String? userAgent,
      @JsonKey(name: 'spv_enabled') bool? spvEnabled,
      @JsonKey(name: 'cert_expiry_threshold') int? certExpiryThreshold});
}

/// @nodoc
class _$GdkConnectionParamsCopyWithImpl<$Res, $Val extends GdkConnectionParams>
    implements $GdkConnectionParamsCopyWith<$Res> {
  _$GdkConnectionParamsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? proxy = freezed,
    Object? useTor = freezed,
    Object? userAgent = freezed,
    Object? spvEnabled = freezed,
    Object? certExpiryThreshold = freezed,
  }) {
    return _then(_value.copyWith(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      proxy: freezed == proxy
          ? _value.proxy
          : proxy // ignore: cast_nullable_to_non_nullable
              as String?,
      useTor: freezed == useTor
          ? _value.useTor
          : useTor // ignore: cast_nullable_to_non_nullable
              as bool?,
      userAgent: freezed == userAgent
          ? _value.userAgent
          : userAgent // ignore: cast_nullable_to_non_nullable
              as String?,
      spvEnabled: freezed == spvEnabled
          ? _value.spvEnabled
          : spvEnabled // ignore: cast_nullable_to_non_nullable
              as bool?,
      certExpiryThreshold: freezed == certExpiryThreshold
          ? _value.certExpiryThreshold
          : certExpiryThreshold // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GdkConnectionParamsImplCopyWith<$Res>
    implements $GdkConnectionParamsCopyWith<$Res> {
  factory _$$GdkConnectionParamsImplCopyWith(_$GdkConnectionParamsImpl value,
          $Res Function(_$GdkConnectionParamsImpl) then) =
      __$$GdkConnectionParamsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? name,
      String? proxy,
      @JsonKey(name: 'use_tor') bool? useTor,
      @JsonKey(name: 'user_agent') String? userAgent,
      @JsonKey(name: 'spv_enabled') bool? spvEnabled,
      @JsonKey(name: 'cert_expiry_threshold') int? certExpiryThreshold});
}

/// @nodoc
class __$$GdkConnectionParamsImplCopyWithImpl<$Res>
    extends _$GdkConnectionParamsCopyWithImpl<$Res, _$GdkConnectionParamsImpl>
    implements _$$GdkConnectionParamsImplCopyWith<$Res> {
  __$$GdkConnectionParamsImplCopyWithImpl(_$GdkConnectionParamsImpl _value,
      $Res Function(_$GdkConnectionParamsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? proxy = freezed,
    Object? useTor = freezed,
    Object? userAgent = freezed,
    Object? spvEnabled = freezed,
    Object? certExpiryThreshold = freezed,
  }) {
    return _then(_$GdkConnectionParamsImpl(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      proxy: freezed == proxy
          ? _value.proxy
          : proxy // ignore: cast_nullable_to_non_nullable
              as String?,
      useTor: freezed == useTor
          ? _value.useTor
          : useTor // ignore: cast_nullable_to_non_nullable
              as bool?,
      userAgent: freezed == userAgent
          ? _value.userAgent
          : userAgent // ignore: cast_nullable_to_non_nullable
              as String?,
      spvEnabled: freezed == spvEnabled
          ? _value.spvEnabled
          : spvEnabled // ignore: cast_nullable_to_non_nullable
              as bool?,
      certExpiryThreshold: freezed == certExpiryThreshold
          ? _value.certExpiryThreshold
          : certExpiryThreshold // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkConnectionParamsImpl extends _GdkConnectionParams {
  const _$GdkConnectionParamsImpl(
      {this.name,
      this.proxy,
      @JsonKey(name: 'use_tor') this.useTor = false,
      @JsonKey(name: 'user_agent') this.userAgent = 'aqua',
      @JsonKey(name: 'spv_enabled') this.spvEnabled,
      @JsonKey(name: 'cert_expiry_threshold') this.certExpiryThreshold})
      : super._();

  factory _$GdkConnectionParamsImpl.fromJson(Map<String, dynamic> json) =>
      _$$GdkConnectionParamsImplFromJson(json);

  @override
  final String? name;
  @override
  final String? proxy;
  @override
  @JsonKey(name: 'use_tor')
  final bool? useTor;
  @override
  @JsonKey(name: 'user_agent')
  final String? userAgent;
  @override
  @JsonKey(name: 'spv_enabled')
  final bool? spvEnabled;
  @override
  @JsonKey(name: 'cert_expiry_threshold')
  final int? certExpiryThreshold;

  @override
  String toString() {
    return 'GdkConnectionParams(name: $name, proxy: $proxy, useTor: $useTor, userAgent: $userAgent, spvEnabled: $spvEnabled, certExpiryThreshold: $certExpiryThreshold)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkConnectionParamsImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.proxy, proxy) || other.proxy == proxy) &&
            (identical(other.useTor, useTor) || other.useTor == useTor) &&
            (identical(other.userAgent, userAgent) ||
                other.userAgent == userAgent) &&
            (identical(other.spvEnabled, spvEnabled) ||
                other.spvEnabled == spvEnabled) &&
            (identical(other.certExpiryThreshold, certExpiryThreshold) ||
                other.certExpiryThreshold == certExpiryThreshold));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, name, proxy, useTor, userAgent,
      spvEnabled, certExpiryThreshold);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkConnectionParamsImplCopyWith<_$GdkConnectionParamsImpl> get copyWith =>
      __$$GdkConnectionParamsImplCopyWithImpl<_$GdkConnectionParamsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkConnectionParamsImplToJson(
      this,
    );
  }
}

abstract class _GdkConnectionParams extends GdkConnectionParams {
  const factory _GdkConnectionParams(
      {final String? name,
      final String? proxy,
      @JsonKey(name: 'use_tor') final bool? useTor,
      @JsonKey(name: 'user_agent') final String? userAgent,
      @JsonKey(name: 'spv_enabled') final bool? spvEnabled,
      @JsonKey(name: 'cert_expiry_threshold')
      final int? certExpiryThreshold}) = _$GdkConnectionParamsImpl;
  const _GdkConnectionParams._() : super._();

  factory _GdkConnectionParams.fromJson(Map<String, dynamic> json) =
      _$GdkConnectionParamsImpl.fromJson;

  @override
  String? get name;
  @override
  String? get proxy;
  @override
  @JsonKey(name: 'use_tor')
  bool? get useTor;
  @override
  @JsonKey(name: 'user_agent')
  String? get userAgent;
  @override
  @JsonKey(name: 'spv_enabled')
  bool? get spvEnabled;
  @override
  @JsonKey(name: 'cert_expiry_threshold')
  int? get certExpiryThreshold;
  @override
  @JsonKey(ignore: true)
  _$$GdkConnectionParamsImplCopyWith<_$GdkConnectionParamsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GdkPinData _$GdkPinDataFromJson(Map<String, dynamic> json) {
  return _GdkPinData.fromJson(json);
}

/// @nodoc
mixin _$GdkPinData {
  @JsonKey(name: 'encrypted_data')
  String? get encryptedData => throw _privateConstructorUsedError;
  @JsonKey(name: 'pin_identifier')
  String? get pinIdentifier => throw _privateConstructorUsedError;
  String? get salt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkPinDataCopyWith<GdkPinData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkPinDataCopyWith<$Res> {
  factory $GdkPinDataCopyWith(
          GdkPinData value, $Res Function(GdkPinData) then) =
      _$GdkPinDataCopyWithImpl<$Res, GdkPinData>;
  @useResult
  $Res call(
      {@JsonKey(name: 'encrypted_data') String? encryptedData,
      @JsonKey(name: 'pin_identifier') String? pinIdentifier,
      String? salt});
}

/// @nodoc
class _$GdkPinDataCopyWithImpl<$Res, $Val extends GdkPinData>
    implements $GdkPinDataCopyWith<$Res> {
  _$GdkPinDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? encryptedData = freezed,
    Object? pinIdentifier = freezed,
    Object? salt = freezed,
  }) {
    return _then(_value.copyWith(
      encryptedData: freezed == encryptedData
          ? _value.encryptedData
          : encryptedData // ignore: cast_nullable_to_non_nullable
              as String?,
      pinIdentifier: freezed == pinIdentifier
          ? _value.pinIdentifier
          : pinIdentifier // ignore: cast_nullable_to_non_nullable
              as String?,
      salt: freezed == salt
          ? _value.salt
          : salt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GdkPinDataImplCopyWith<$Res>
    implements $GdkPinDataCopyWith<$Res> {
  factory _$$GdkPinDataImplCopyWith(
          _$GdkPinDataImpl value, $Res Function(_$GdkPinDataImpl) then) =
      __$$GdkPinDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'encrypted_data') String? encryptedData,
      @JsonKey(name: 'pin_identifier') String? pinIdentifier,
      String? salt});
}

/// @nodoc
class __$$GdkPinDataImplCopyWithImpl<$Res>
    extends _$GdkPinDataCopyWithImpl<$Res, _$GdkPinDataImpl>
    implements _$$GdkPinDataImplCopyWith<$Res> {
  __$$GdkPinDataImplCopyWithImpl(
      _$GdkPinDataImpl _value, $Res Function(_$GdkPinDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? encryptedData = freezed,
    Object? pinIdentifier = freezed,
    Object? salt = freezed,
  }) {
    return _then(_$GdkPinDataImpl(
      encryptedData: freezed == encryptedData
          ? _value.encryptedData
          : encryptedData // ignore: cast_nullable_to_non_nullable
              as String?,
      pinIdentifier: freezed == pinIdentifier
          ? _value.pinIdentifier
          : pinIdentifier // ignore: cast_nullable_to_non_nullable
              as String?,
      salt: freezed == salt
          ? _value.salt
          : salt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkPinDataImpl implements _GdkPinData {
  const _$GdkPinDataImpl(
      {@JsonKey(name: 'encrypted_data') this.encryptedData,
      @JsonKey(name: 'pin_identifier') this.pinIdentifier,
      this.salt});

  factory _$GdkPinDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$GdkPinDataImplFromJson(json);

  @override
  @JsonKey(name: 'encrypted_data')
  final String? encryptedData;
  @override
  @JsonKey(name: 'pin_identifier')
  final String? pinIdentifier;
  @override
  final String? salt;

  @override
  String toString() {
    return 'GdkPinData(encryptedData: $encryptedData, pinIdentifier: $pinIdentifier, salt: $salt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkPinDataImpl &&
            (identical(other.encryptedData, encryptedData) ||
                other.encryptedData == encryptedData) &&
            (identical(other.pinIdentifier, pinIdentifier) ||
                other.pinIdentifier == pinIdentifier) &&
            (identical(other.salt, salt) || other.salt == salt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, encryptedData, pinIdentifier, salt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkPinDataImplCopyWith<_$GdkPinDataImpl> get copyWith =>
      __$$GdkPinDataImplCopyWithImpl<_$GdkPinDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkPinDataImplToJson(
      this,
    );
  }
}

abstract class _GdkPinData implements GdkPinData {
  const factory _GdkPinData(
      {@JsonKey(name: 'encrypted_data') final String? encryptedData,
      @JsonKey(name: 'pin_identifier') final String? pinIdentifier,
      final String? salt}) = _$GdkPinDataImpl;

  factory _GdkPinData.fromJson(Map<String, dynamic> json) =
      _$GdkPinDataImpl.fromJson;

  @override
  @JsonKey(name: 'encrypted_data')
  String? get encryptedData;
  @override
  @JsonKey(name: 'pin_identifier')
  String? get pinIdentifier;
  @override
  String? get salt;
  @override
  @JsonKey(ignore: true)
  _$$GdkPinDataImplCopyWith<_$GdkPinDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GdkLoginCredentials _$GdkLoginCredentialsFromJson(Map<String, dynamic> json) {
  return _GdkLoginCredentials.fromJson(json);
}

/// @nodoc
mixin _$GdkLoginCredentials {
  String get mnemonic => throw _privateConstructorUsedError;
  String? get username => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;
  @JsonKey(name: 'bip39_passphrase')
  String? get bip39Passphrase => throw _privateConstructorUsedError;
  String? get pin => throw _privateConstructorUsedError;
  @JsonKey(name: 'pin_data')
  GdkPinData? get pinData => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkLoginCredentialsCopyWith<GdkLoginCredentials> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkLoginCredentialsCopyWith<$Res> {
  factory $GdkLoginCredentialsCopyWith(
          GdkLoginCredentials value, $Res Function(GdkLoginCredentials) then) =
      _$GdkLoginCredentialsCopyWithImpl<$Res, GdkLoginCredentials>;
  @useResult
  $Res call(
      {String mnemonic,
      String? username,
      String password,
      @JsonKey(name: 'bip39_passphrase') String? bip39Passphrase,
      String? pin,
      @JsonKey(name: 'pin_data') GdkPinData? pinData});

  $GdkPinDataCopyWith<$Res>? get pinData;
}

/// @nodoc
class _$GdkLoginCredentialsCopyWithImpl<$Res, $Val extends GdkLoginCredentials>
    implements $GdkLoginCredentialsCopyWith<$Res> {
  _$GdkLoginCredentialsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mnemonic = null,
    Object? username = freezed,
    Object? password = null,
    Object? bip39Passphrase = freezed,
    Object? pin = freezed,
    Object? pinData = freezed,
  }) {
    return _then(_value.copyWith(
      mnemonic: null == mnemonic
          ? _value.mnemonic
          : mnemonic // ignore: cast_nullable_to_non_nullable
              as String,
      username: freezed == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String?,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      bip39Passphrase: freezed == bip39Passphrase
          ? _value.bip39Passphrase
          : bip39Passphrase // ignore: cast_nullable_to_non_nullable
              as String?,
      pin: freezed == pin
          ? _value.pin
          : pin // ignore: cast_nullable_to_non_nullable
              as String?,
      pinData: freezed == pinData
          ? _value.pinData
          : pinData // ignore: cast_nullable_to_non_nullable
              as GdkPinData?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $GdkPinDataCopyWith<$Res>? get pinData {
    if (_value.pinData == null) {
      return null;
    }

    return $GdkPinDataCopyWith<$Res>(_value.pinData!, (value) {
      return _then(_value.copyWith(pinData: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GdkLoginCredentialsImplCopyWith<$Res>
    implements $GdkLoginCredentialsCopyWith<$Res> {
  factory _$$GdkLoginCredentialsImplCopyWith(_$GdkLoginCredentialsImpl value,
          $Res Function(_$GdkLoginCredentialsImpl) then) =
      __$$GdkLoginCredentialsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String mnemonic,
      String? username,
      String password,
      @JsonKey(name: 'bip39_passphrase') String? bip39Passphrase,
      String? pin,
      @JsonKey(name: 'pin_data') GdkPinData? pinData});

  @override
  $GdkPinDataCopyWith<$Res>? get pinData;
}

/// @nodoc
class __$$GdkLoginCredentialsImplCopyWithImpl<$Res>
    extends _$GdkLoginCredentialsCopyWithImpl<$Res, _$GdkLoginCredentialsImpl>
    implements _$$GdkLoginCredentialsImplCopyWith<$Res> {
  __$$GdkLoginCredentialsImplCopyWithImpl(_$GdkLoginCredentialsImpl _value,
      $Res Function(_$GdkLoginCredentialsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mnemonic = null,
    Object? username = freezed,
    Object? password = null,
    Object? bip39Passphrase = freezed,
    Object? pin = freezed,
    Object? pinData = freezed,
  }) {
    return _then(_$GdkLoginCredentialsImpl(
      mnemonic: null == mnemonic
          ? _value.mnemonic
          : mnemonic // ignore: cast_nullable_to_non_nullable
              as String,
      username: freezed == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String?,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      bip39Passphrase: freezed == bip39Passphrase
          ? _value.bip39Passphrase
          : bip39Passphrase // ignore: cast_nullable_to_non_nullable
              as String?,
      pin: freezed == pin
          ? _value.pin
          : pin // ignore: cast_nullable_to_non_nullable
              as String?,
      pinData: freezed == pinData
          ? _value.pinData
          : pinData // ignore: cast_nullable_to_non_nullable
              as GdkPinData?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkLoginCredentialsImpl extends _GdkLoginCredentials {
  const _$GdkLoginCredentialsImpl(
      {required this.mnemonic,
      this.username,
      this.password = '',
      @JsonKey(name: 'bip39_passphrase') this.bip39Passphrase,
      this.pin,
      @JsonKey(name: 'pin_data') this.pinData})
      : super._();

  factory _$GdkLoginCredentialsImpl.fromJson(Map<String, dynamic> json) =>
      _$$GdkLoginCredentialsImplFromJson(json);

  @override
  final String mnemonic;
  @override
  final String? username;
  @override
  @JsonKey()
  final String password;
  @override
  @JsonKey(name: 'bip39_passphrase')
  final String? bip39Passphrase;
  @override
  final String? pin;
  @override
  @JsonKey(name: 'pin_data')
  final GdkPinData? pinData;

  @override
  String toString() {
    return 'GdkLoginCredentials(mnemonic: $mnemonic, username: $username, password: $password, bip39Passphrase: $bip39Passphrase, pin: $pin, pinData: $pinData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkLoginCredentialsImpl &&
            (identical(other.mnemonic, mnemonic) ||
                other.mnemonic == mnemonic) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.bip39Passphrase, bip39Passphrase) ||
                other.bip39Passphrase == bip39Passphrase) &&
            (identical(other.pin, pin) || other.pin == pin) &&
            (identical(other.pinData, pinData) || other.pinData == pinData));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, mnemonic, username, password, bip39Passphrase, pin, pinData);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkLoginCredentialsImplCopyWith<_$GdkLoginCredentialsImpl> get copyWith =>
      __$$GdkLoginCredentialsImplCopyWithImpl<_$GdkLoginCredentialsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkLoginCredentialsImplToJson(
      this,
    );
  }
}

abstract class _GdkLoginCredentials extends GdkLoginCredentials {
  const factory _GdkLoginCredentials(
          {required final String mnemonic,
          final String? username,
          final String password,
          @JsonKey(name: 'bip39_passphrase') final String? bip39Passphrase,
          final String? pin,
          @JsonKey(name: 'pin_data') final GdkPinData? pinData}) =
      _$GdkLoginCredentialsImpl;
  const _GdkLoginCredentials._() : super._();

  factory _GdkLoginCredentials.fromJson(Map<String, dynamic> json) =
      _$GdkLoginCredentialsImpl.fromJson;

  @override
  String get mnemonic;
  @override
  String? get username;
  @override
  String get password;
  @override
  @JsonKey(name: 'bip39_passphrase')
  String? get bip39Passphrase;
  @override
  String? get pin;
  @override
  @JsonKey(name: 'pin_data')
  GdkPinData? get pinData;
  @override
  @JsonKey(ignore: true)
  _$$GdkLoginCredentialsImplCopyWith<_$GdkLoginCredentialsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GdkDevice _$GdkDeviceFromJson(Map<String, dynamic> json) {
  return _GdkDevice.fromJson(json);
}

/// @nodoc
mixin _$GdkDevice {
  String? get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'supports_ae_protocol')
  int? get supportsAeProtocol => throw _privateConstructorUsedError;
  @JsonKey(name: 'supports_arbitrary_scripts')
  bool? get supportsArbitraryScripts => throw _privateConstructorUsedError;
  @JsonKey(name: 'supports_host_unblinding')
  bool? get supportsHostUnblinding => throw _privateConstructorUsedError;
  @JsonKey(name: 'supports_liquid')
  int? get supportsLiquid => throw _privateConstructorUsedError;
  @JsonKey(name: 'supports_low_r')
  bool? get supportsLowR => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkDeviceCopyWith<GdkDevice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkDeviceCopyWith<$Res> {
  factory $GdkDeviceCopyWith(GdkDevice value, $Res Function(GdkDevice) then) =
      _$GdkDeviceCopyWithImpl<$Res, GdkDevice>;
  @useResult
  $Res call(
      {String? name,
      @JsonKey(name: 'supports_ae_protocol') int? supportsAeProtocol,
      @JsonKey(name: 'supports_arbitrary_scripts')
      bool? supportsArbitraryScripts,
      @JsonKey(name: 'supports_host_unblinding') bool? supportsHostUnblinding,
      @JsonKey(name: 'supports_liquid') int? supportsLiquid,
      @JsonKey(name: 'supports_low_r') bool? supportsLowR});
}

/// @nodoc
class _$GdkDeviceCopyWithImpl<$Res, $Val extends GdkDevice>
    implements $GdkDeviceCopyWith<$Res> {
  _$GdkDeviceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? supportsAeProtocol = freezed,
    Object? supportsArbitraryScripts = freezed,
    Object? supportsHostUnblinding = freezed,
    Object? supportsLiquid = freezed,
    Object? supportsLowR = freezed,
  }) {
    return _then(_value.copyWith(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      supportsAeProtocol: freezed == supportsAeProtocol
          ? _value.supportsAeProtocol
          : supportsAeProtocol // ignore: cast_nullable_to_non_nullable
              as int?,
      supportsArbitraryScripts: freezed == supportsArbitraryScripts
          ? _value.supportsArbitraryScripts
          : supportsArbitraryScripts // ignore: cast_nullable_to_non_nullable
              as bool?,
      supportsHostUnblinding: freezed == supportsHostUnblinding
          ? _value.supportsHostUnblinding
          : supportsHostUnblinding // ignore: cast_nullable_to_non_nullable
              as bool?,
      supportsLiquid: freezed == supportsLiquid
          ? _value.supportsLiquid
          : supportsLiquid // ignore: cast_nullable_to_non_nullable
              as int?,
      supportsLowR: freezed == supportsLowR
          ? _value.supportsLowR
          : supportsLowR // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GdkDeviceImplCopyWith<$Res>
    implements $GdkDeviceCopyWith<$Res> {
  factory _$$GdkDeviceImplCopyWith(
          _$GdkDeviceImpl value, $Res Function(_$GdkDeviceImpl) then) =
      __$$GdkDeviceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? name,
      @JsonKey(name: 'supports_ae_protocol') int? supportsAeProtocol,
      @JsonKey(name: 'supports_arbitrary_scripts')
      bool? supportsArbitraryScripts,
      @JsonKey(name: 'supports_host_unblinding') bool? supportsHostUnblinding,
      @JsonKey(name: 'supports_liquid') int? supportsLiquid,
      @JsonKey(name: 'supports_low_r') bool? supportsLowR});
}

/// @nodoc
class __$$GdkDeviceImplCopyWithImpl<$Res>
    extends _$GdkDeviceCopyWithImpl<$Res, _$GdkDeviceImpl>
    implements _$$GdkDeviceImplCopyWith<$Res> {
  __$$GdkDeviceImplCopyWithImpl(
      _$GdkDeviceImpl _value, $Res Function(_$GdkDeviceImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? supportsAeProtocol = freezed,
    Object? supportsArbitraryScripts = freezed,
    Object? supportsHostUnblinding = freezed,
    Object? supportsLiquid = freezed,
    Object? supportsLowR = freezed,
  }) {
    return _then(_$GdkDeviceImpl(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      supportsAeProtocol: freezed == supportsAeProtocol
          ? _value.supportsAeProtocol
          : supportsAeProtocol // ignore: cast_nullable_to_non_nullable
              as int?,
      supportsArbitraryScripts: freezed == supportsArbitraryScripts
          ? _value.supportsArbitraryScripts
          : supportsArbitraryScripts // ignore: cast_nullable_to_non_nullable
              as bool?,
      supportsHostUnblinding: freezed == supportsHostUnblinding
          ? _value.supportsHostUnblinding
          : supportsHostUnblinding // ignore: cast_nullable_to_non_nullable
              as bool?,
      supportsLiquid: freezed == supportsLiquid
          ? _value.supportsLiquid
          : supportsLiquid // ignore: cast_nullable_to_non_nullable
              as int?,
      supportsLowR: freezed == supportsLowR
          ? _value.supportsLowR
          : supportsLowR // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkDeviceImpl extends _GdkDevice {
  const _$GdkDeviceImpl(
      {this.name,
      @JsonKey(name: 'supports_ae_protocol') this.supportsAeProtocol,
      @JsonKey(name: 'supports_arbitrary_scripts')
      this.supportsArbitraryScripts,
      @JsonKey(name: 'supports_host_unblinding') this.supportsHostUnblinding,
      @JsonKey(name: 'supports_liquid') this.supportsLiquid,
      @JsonKey(name: 'supports_low_r') this.supportsLowR})
      : super._();

  factory _$GdkDeviceImpl.fromJson(Map<String, dynamic> json) =>
      _$$GdkDeviceImplFromJson(json);

  @override
  final String? name;
  @override
  @JsonKey(name: 'supports_ae_protocol')
  final int? supportsAeProtocol;
  @override
  @JsonKey(name: 'supports_arbitrary_scripts')
  final bool? supportsArbitraryScripts;
  @override
  @JsonKey(name: 'supports_host_unblinding')
  final bool? supportsHostUnblinding;
  @override
  @JsonKey(name: 'supports_liquid')
  final int? supportsLiquid;
  @override
  @JsonKey(name: 'supports_low_r')
  final bool? supportsLowR;

  @override
  String toString() {
    return 'GdkDevice(name: $name, supportsAeProtocol: $supportsAeProtocol, supportsArbitraryScripts: $supportsArbitraryScripts, supportsHostUnblinding: $supportsHostUnblinding, supportsLiquid: $supportsLiquid, supportsLowR: $supportsLowR)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkDeviceImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.supportsAeProtocol, supportsAeProtocol) ||
                other.supportsAeProtocol == supportsAeProtocol) &&
            (identical(
                    other.supportsArbitraryScripts, supportsArbitraryScripts) ||
                other.supportsArbitraryScripts == supportsArbitraryScripts) &&
            (identical(other.supportsHostUnblinding, supportsHostUnblinding) ||
                other.supportsHostUnblinding == supportsHostUnblinding) &&
            (identical(other.supportsLiquid, supportsLiquid) ||
                other.supportsLiquid == supportsLiquid) &&
            (identical(other.supportsLowR, supportsLowR) ||
                other.supportsLowR == supportsLowR));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      supportsAeProtocol,
      supportsArbitraryScripts,
      supportsHostUnblinding,
      supportsLiquid,
      supportsLowR);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkDeviceImplCopyWith<_$GdkDeviceImpl> get copyWith =>
      __$$GdkDeviceImplCopyWithImpl<_$GdkDeviceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkDeviceImplToJson(
      this,
    );
  }
}

abstract class _GdkDevice extends GdkDevice {
  const factory _GdkDevice(
          {final String? name,
          @JsonKey(name: 'supports_ae_protocol') final int? supportsAeProtocol,
          @JsonKey(name: 'supports_arbitrary_scripts')
          final bool? supportsArbitraryScripts,
          @JsonKey(name: 'supports_host_unblinding')
          final bool? supportsHostUnblinding,
          @JsonKey(name: 'supports_liquid') final int? supportsLiquid,
          @JsonKey(name: 'supports_low_r') final bool? supportsLowR}) =
      _$GdkDeviceImpl;
  const _GdkDevice._() : super._();

  factory _GdkDevice.fromJson(Map<String, dynamic> json) =
      _$GdkDeviceImpl.fromJson;

  @override
  String? get name;
  @override
  @JsonKey(name: 'supports_ae_protocol')
  int? get supportsAeProtocol;
  @override
  @JsonKey(name: 'supports_arbitrary_scripts')
  bool? get supportsArbitraryScripts;
  @override
  @JsonKey(name: 'supports_host_unblinding')
  bool? get supportsHostUnblinding;
  @override
  @JsonKey(name: 'supports_liquid')
  int? get supportsLiquid;
  @override
  @JsonKey(name: 'supports_low_r')
  bool? get supportsLowR;
  @override
  @JsonKey(ignore: true)
  _$$GdkDeviceImplCopyWith<_$GdkDeviceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GdkHwDevice _$GdkHwDeviceFromJson(Map<String, dynamic> json) {
  return _GdkHwDevice.fromJson(json);
}

/// @nodoc
mixin _$GdkHwDevice {
  GdkDevice? get device => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkHwDeviceCopyWith<GdkHwDevice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkHwDeviceCopyWith<$Res> {
  factory $GdkHwDeviceCopyWith(
          GdkHwDevice value, $Res Function(GdkHwDevice) then) =
      _$GdkHwDeviceCopyWithImpl<$Res, GdkHwDevice>;
  @useResult
  $Res call({GdkDevice? device});

  $GdkDeviceCopyWith<$Res>? get device;
}

/// @nodoc
class _$GdkHwDeviceCopyWithImpl<$Res, $Val extends GdkHwDevice>
    implements $GdkHwDeviceCopyWith<$Res> {
  _$GdkHwDeviceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? device = freezed,
  }) {
    return _then(_value.copyWith(
      device: freezed == device
          ? _value.device
          : device // ignore: cast_nullable_to_non_nullable
              as GdkDevice?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $GdkDeviceCopyWith<$Res>? get device {
    if (_value.device == null) {
      return null;
    }

    return $GdkDeviceCopyWith<$Res>(_value.device!, (value) {
      return _then(_value.copyWith(device: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GdkHwDeviceImplCopyWith<$Res>
    implements $GdkHwDeviceCopyWith<$Res> {
  factory _$$GdkHwDeviceImplCopyWith(
          _$GdkHwDeviceImpl value, $Res Function(_$GdkHwDeviceImpl) then) =
      __$$GdkHwDeviceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({GdkDevice? device});

  @override
  $GdkDeviceCopyWith<$Res>? get device;
}

/// @nodoc
class __$$GdkHwDeviceImplCopyWithImpl<$Res>
    extends _$GdkHwDeviceCopyWithImpl<$Res, _$GdkHwDeviceImpl>
    implements _$$GdkHwDeviceImplCopyWith<$Res> {
  __$$GdkHwDeviceImplCopyWithImpl(
      _$GdkHwDeviceImpl _value, $Res Function(_$GdkHwDeviceImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? device = freezed,
  }) {
    return _then(_$GdkHwDeviceImpl(
      device: freezed == device
          ? _value.device
          : device // ignore: cast_nullable_to_non_nullable
              as GdkDevice?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkHwDeviceImpl extends _GdkHwDevice {
  const _$GdkHwDeviceImpl({this.device}) : super._();

  factory _$GdkHwDeviceImpl.fromJson(Map<String, dynamic> json) =>
      _$$GdkHwDeviceImplFromJson(json);

  @override
  final GdkDevice? device;

  @override
  String toString() {
    return 'GdkHwDevice(device: $device)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkHwDeviceImpl &&
            (identical(other.device, device) || other.device == device));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, device);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkHwDeviceImplCopyWith<_$GdkHwDeviceImpl> get copyWith =>
      __$$GdkHwDeviceImplCopyWithImpl<_$GdkHwDeviceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkHwDeviceImplToJson(
      this,
    );
  }
}

abstract class _GdkHwDevice extends GdkHwDevice {
  const factory _GdkHwDevice({final GdkDevice? device}) = _$GdkHwDeviceImpl;
  const _GdkHwDevice._() : super._();

  factory _GdkHwDevice.fromJson(Map<String, dynamic> json) =
      _$GdkHwDeviceImpl.fromJson;

  @override
  GdkDevice? get device;
  @override
  @JsonKey(ignore: true)
  _$$GdkHwDeviceImplCopyWith<_$GdkHwDeviceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GdkSubaccount _$GdkSubaccountFromJson(Map<String, dynamic> json) {
  return _GdkSubaccount.fromJson(json);
}

/// @nodoc
mixin _$GdkSubaccount {
  bool? get hidden => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  int? get pointer => throw _privateConstructorUsedError;
  @JsonKey(name: 'receiving_id')
  String? get receivingId => throw _privateConstructorUsedError;
  @JsonKey(name: 'recovery_chain_code')
  String? get recoveryChainCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'recovery_pub_key')
  String? get recoveryPubKey => throw _privateConstructorUsedError;
  @JsonKey(name: 'recovery_xpub')
  String? get recoveryXpub => throw _privateConstructorUsedError;
  @JsonKey(name: 'required_ca')
  int? get requiredCa => throw _privateConstructorUsedError;
  GdkSubaccountTypeEnum? get type => throw _privateConstructorUsedError;
  @JsonKey(name: 'bip44_discovered')
  bool? get bip44Discovered => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkSubaccountCopyWith<GdkSubaccount> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkSubaccountCopyWith<$Res> {
  factory $GdkSubaccountCopyWith(
          GdkSubaccount value, $Res Function(GdkSubaccount) then) =
      _$GdkSubaccountCopyWithImpl<$Res, GdkSubaccount>;
  @useResult
  $Res call(
      {bool? hidden,
      String? name,
      int? pointer,
      @JsonKey(name: 'receiving_id') String? receivingId,
      @JsonKey(name: 'recovery_chain_code') String? recoveryChainCode,
      @JsonKey(name: 'recovery_pub_key') String? recoveryPubKey,
      @JsonKey(name: 'recovery_xpub') String? recoveryXpub,
      @JsonKey(name: 'required_ca') int? requiredCa,
      GdkSubaccountTypeEnum? type,
      @JsonKey(name: 'bip44_discovered') bool? bip44Discovered});
}

/// @nodoc
class _$GdkSubaccountCopyWithImpl<$Res, $Val extends GdkSubaccount>
    implements $GdkSubaccountCopyWith<$Res> {
  _$GdkSubaccountCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hidden = freezed,
    Object? name = freezed,
    Object? pointer = freezed,
    Object? receivingId = freezed,
    Object? recoveryChainCode = freezed,
    Object? recoveryPubKey = freezed,
    Object? recoveryXpub = freezed,
    Object? requiredCa = freezed,
    Object? type = freezed,
    Object? bip44Discovered = freezed,
  }) {
    return _then(_value.copyWith(
      hidden: freezed == hidden
          ? _value.hidden
          : hidden // ignore: cast_nullable_to_non_nullable
              as bool?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      pointer: freezed == pointer
          ? _value.pointer
          : pointer // ignore: cast_nullable_to_non_nullable
              as int?,
      receivingId: freezed == receivingId
          ? _value.receivingId
          : receivingId // ignore: cast_nullable_to_non_nullable
              as String?,
      recoveryChainCode: freezed == recoveryChainCode
          ? _value.recoveryChainCode
          : recoveryChainCode // ignore: cast_nullable_to_non_nullable
              as String?,
      recoveryPubKey: freezed == recoveryPubKey
          ? _value.recoveryPubKey
          : recoveryPubKey // ignore: cast_nullable_to_non_nullable
              as String?,
      recoveryXpub: freezed == recoveryXpub
          ? _value.recoveryXpub
          : recoveryXpub // ignore: cast_nullable_to_non_nullable
              as String?,
      requiredCa: freezed == requiredCa
          ? _value.requiredCa
          : requiredCa // ignore: cast_nullable_to_non_nullable
              as int?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as GdkSubaccountTypeEnum?,
      bip44Discovered: freezed == bip44Discovered
          ? _value.bip44Discovered
          : bip44Discovered // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GdkSubaccountImplCopyWith<$Res>
    implements $GdkSubaccountCopyWith<$Res> {
  factory _$$GdkSubaccountImplCopyWith(
          _$GdkSubaccountImpl value, $Res Function(_$GdkSubaccountImpl) then) =
      __$$GdkSubaccountImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool? hidden,
      String? name,
      int? pointer,
      @JsonKey(name: 'receiving_id') String? receivingId,
      @JsonKey(name: 'recovery_chain_code') String? recoveryChainCode,
      @JsonKey(name: 'recovery_pub_key') String? recoveryPubKey,
      @JsonKey(name: 'recovery_xpub') String? recoveryXpub,
      @JsonKey(name: 'required_ca') int? requiredCa,
      GdkSubaccountTypeEnum? type,
      @JsonKey(name: 'bip44_discovered') bool? bip44Discovered});
}

/// @nodoc
class __$$GdkSubaccountImplCopyWithImpl<$Res>
    extends _$GdkSubaccountCopyWithImpl<$Res, _$GdkSubaccountImpl>
    implements _$$GdkSubaccountImplCopyWith<$Res> {
  __$$GdkSubaccountImplCopyWithImpl(
      _$GdkSubaccountImpl _value, $Res Function(_$GdkSubaccountImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hidden = freezed,
    Object? name = freezed,
    Object? pointer = freezed,
    Object? receivingId = freezed,
    Object? recoveryChainCode = freezed,
    Object? recoveryPubKey = freezed,
    Object? recoveryXpub = freezed,
    Object? requiredCa = freezed,
    Object? type = freezed,
    Object? bip44Discovered = freezed,
  }) {
    return _then(_$GdkSubaccountImpl(
      hidden: freezed == hidden
          ? _value.hidden
          : hidden // ignore: cast_nullable_to_non_nullable
              as bool?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      pointer: freezed == pointer
          ? _value.pointer
          : pointer // ignore: cast_nullable_to_non_nullable
              as int?,
      receivingId: freezed == receivingId
          ? _value.receivingId
          : receivingId // ignore: cast_nullable_to_non_nullable
              as String?,
      recoveryChainCode: freezed == recoveryChainCode
          ? _value.recoveryChainCode
          : recoveryChainCode // ignore: cast_nullable_to_non_nullable
              as String?,
      recoveryPubKey: freezed == recoveryPubKey
          ? _value.recoveryPubKey
          : recoveryPubKey // ignore: cast_nullable_to_non_nullable
              as String?,
      recoveryXpub: freezed == recoveryXpub
          ? _value.recoveryXpub
          : recoveryXpub // ignore: cast_nullable_to_non_nullable
              as String?,
      requiredCa: freezed == requiredCa
          ? _value.requiredCa
          : requiredCa // ignore: cast_nullable_to_non_nullable
              as int?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as GdkSubaccountTypeEnum?,
      bip44Discovered: freezed == bip44Discovered
          ? _value.bip44Discovered
          : bip44Discovered // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkSubaccountImpl extends _GdkSubaccount {
  const _$GdkSubaccountImpl(
      {this.hidden = false,
      this.name = 'Managed Assets',
      this.pointer,
      @JsonKey(name: 'receiving_id') this.receivingId,
      @JsonKey(name: 'recovery_chain_code') this.recoveryChainCode,
      @JsonKey(name: 'recovery_pub_key') this.recoveryPubKey,
      @JsonKey(name: 'recovery_xpub') this.recoveryXpub,
      @JsonKey(name: 'required_ca') this.requiredCa,
      this.type = GdkSubaccountTypeEnum.type_p2sh_p2wpkh,
      @JsonKey(name: 'bip44_discovered') this.bip44Discovered})
      : super._();

  factory _$GdkSubaccountImpl.fromJson(Map<String, dynamic> json) =>
      _$$GdkSubaccountImplFromJson(json);

  @override
  @JsonKey()
  final bool? hidden;
  @override
  @JsonKey()
  final String? name;
  @override
  final int? pointer;
  @override
  @JsonKey(name: 'receiving_id')
  final String? receivingId;
  @override
  @JsonKey(name: 'recovery_chain_code')
  final String? recoveryChainCode;
  @override
  @JsonKey(name: 'recovery_pub_key')
  final String? recoveryPubKey;
  @override
  @JsonKey(name: 'recovery_xpub')
  final String? recoveryXpub;
  @override
  @JsonKey(name: 'required_ca')
  final int? requiredCa;
  @override
  @JsonKey()
  final GdkSubaccountTypeEnum? type;
  @override
  @JsonKey(name: 'bip44_discovered')
  final bool? bip44Discovered;

  @override
  String toString() {
    return 'GdkSubaccount(hidden: $hidden, name: $name, pointer: $pointer, receivingId: $receivingId, recoveryChainCode: $recoveryChainCode, recoveryPubKey: $recoveryPubKey, recoveryXpub: $recoveryXpub, requiredCa: $requiredCa, type: $type, bip44Discovered: $bip44Discovered)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkSubaccountImpl &&
            (identical(other.hidden, hidden) || other.hidden == hidden) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.pointer, pointer) || other.pointer == pointer) &&
            (identical(other.receivingId, receivingId) ||
                other.receivingId == receivingId) &&
            (identical(other.recoveryChainCode, recoveryChainCode) ||
                other.recoveryChainCode == recoveryChainCode) &&
            (identical(other.recoveryPubKey, recoveryPubKey) ||
                other.recoveryPubKey == recoveryPubKey) &&
            (identical(other.recoveryXpub, recoveryXpub) ||
                other.recoveryXpub == recoveryXpub) &&
            (identical(other.requiredCa, requiredCa) ||
                other.requiredCa == requiredCa) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.bip44Discovered, bip44Discovered) ||
                other.bip44Discovered == bip44Discovered));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      hidden,
      name,
      pointer,
      receivingId,
      recoveryChainCode,
      recoveryPubKey,
      recoveryXpub,
      requiredCa,
      type,
      bip44Discovered);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkSubaccountImplCopyWith<_$GdkSubaccountImpl> get copyWith =>
      __$$GdkSubaccountImplCopyWithImpl<_$GdkSubaccountImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkSubaccountImplToJson(
      this,
    );
  }
}

abstract class _GdkSubaccount extends GdkSubaccount {
  const factory _GdkSubaccount(
          {final bool? hidden,
          final String? name,
          final int? pointer,
          @JsonKey(name: 'receiving_id') final String? receivingId,
          @JsonKey(name: 'recovery_chain_code') final String? recoveryChainCode,
          @JsonKey(name: 'recovery_pub_key') final String? recoveryPubKey,
          @JsonKey(name: 'recovery_xpub') final String? recoveryXpub,
          @JsonKey(name: 'required_ca') final int? requiredCa,
          final GdkSubaccountTypeEnum? type,
          @JsonKey(name: 'bip44_discovered') final bool? bip44Discovered}) =
      _$GdkSubaccountImpl;
  const _GdkSubaccount._() : super._();

  factory _GdkSubaccount.fromJson(Map<String, dynamic> json) =
      _$GdkSubaccountImpl.fromJson;

  @override
  bool? get hidden;
  @override
  String? get name;
  @override
  int? get pointer;
  @override
  @JsonKey(name: 'receiving_id')
  String? get receivingId;
  @override
  @JsonKey(name: 'recovery_chain_code')
  String? get recoveryChainCode;
  @override
  @JsonKey(name: 'recovery_pub_key')
  String? get recoveryPubKey;
  @override
  @JsonKey(name: 'recovery_xpub')
  String? get recoveryXpub;
  @override
  @JsonKey(name: 'required_ca')
  int? get requiredCa;
  @override
  GdkSubaccountTypeEnum? get type;
  @override
  @JsonKey(name: 'bip44_discovered')
  bool? get bip44Discovered;
  @override
  @JsonKey(ignore: true)
  _$$GdkSubaccountImplCopyWith<_$GdkSubaccountImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GdkLoginUser _$GdkLoginUserFromJson(Map<String, dynamic> json) {
  return _GdkLoginUser.fromJson(json);
}

/// @nodoc
mixin _$GdkLoginUser {
  @JsonKey(name: 'wallet_hash_id')
  String? get walletHashId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkLoginUserCopyWith<GdkLoginUser> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkLoginUserCopyWith<$Res> {
  factory $GdkLoginUserCopyWith(
          GdkLoginUser value, $Res Function(GdkLoginUser) then) =
      _$GdkLoginUserCopyWithImpl<$Res, GdkLoginUser>;
  @useResult
  $Res call({@JsonKey(name: 'wallet_hash_id') String? walletHashId});
}

/// @nodoc
class _$GdkLoginUserCopyWithImpl<$Res, $Val extends GdkLoginUser>
    implements $GdkLoginUserCopyWith<$Res> {
  _$GdkLoginUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? walletHashId = freezed,
  }) {
    return _then(_value.copyWith(
      walletHashId: freezed == walletHashId
          ? _value.walletHashId
          : walletHashId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GdkLoginUserImplCopyWith<$Res>
    implements $GdkLoginUserCopyWith<$Res> {
  factory _$$GdkLoginUserImplCopyWith(
          _$GdkLoginUserImpl value, $Res Function(_$GdkLoginUserImpl) then) =
      __$$GdkLoginUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@JsonKey(name: 'wallet_hash_id') String? walletHashId});
}

/// @nodoc
class __$$GdkLoginUserImplCopyWithImpl<$Res>
    extends _$GdkLoginUserCopyWithImpl<$Res, _$GdkLoginUserImpl>
    implements _$$GdkLoginUserImplCopyWith<$Res> {
  __$$GdkLoginUserImplCopyWithImpl(
      _$GdkLoginUserImpl _value, $Res Function(_$GdkLoginUserImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? walletHashId = freezed,
  }) {
    return _then(_$GdkLoginUserImpl(
      walletHashId: freezed == walletHashId
          ? _value.walletHashId
          : walletHashId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkLoginUserImpl implements _GdkLoginUser {
  const _$GdkLoginUserImpl(
      {@JsonKey(name: 'wallet_hash_id') this.walletHashId});

  factory _$GdkLoginUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$GdkLoginUserImplFromJson(json);

  @override
  @JsonKey(name: 'wallet_hash_id')
  final String? walletHashId;

  @override
  String toString() {
    return 'GdkLoginUser(walletHashId: $walletHashId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkLoginUserImpl &&
            (identical(other.walletHashId, walletHashId) ||
                other.walletHashId == walletHashId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, walletHashId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkLoginUserImplCopyWith<_$GdkLoginUserImpl> get copyWith =>
      __$$GdkLoginUserImplCopyWithImpl<_$GdkLoginUserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkLoginUserImplToJson(
      this,
    );
  }
}

abstract class _GdkLoginUser implements GdkLoginUser {
  const factory _GdkLoginUser(
          {@JsonKey(name: 'wallet_hash_id') final String? walletHashId}) =
      _$GdkLoginUserImpl;

  factory _GdkLoginUser.fromJson(Map<String, dynamic> json) =
      _$GdkLoginUserImpl.fromJson;

  @override
  @JsonKey(name: 'wallet_hash_id')
  String? get walletHashId;
  @override
  @JsonKey(ignore: true)
  _$$GdkLoginUserImplCopyWith<_$GdkLoginUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GdkGetBalance _$GdkGetBalanceFromJson(Map<String, dynamic> json) {
  return _GdkGetBalance.fromJson(json);
}

/// @nodoc
mixin _$GdkGetBalance {
  int? get subaccount => throw _privateConstructorUsedError;
  @JsonKey(name: 'num_confs')
  int? get numConfs => throw _privateConstructorUsedError;
  @JsonKey(name: 'all_coins', defaultValue: true)
  bool? get allCoins => throw _privateConstructorUsedError;
  @JsonKey(name: 'expired_at')
  int? get expiredAt => throw _privateConstructorUsedError;
  @JsonKey(defaultValue: false)
  bool? get confidential => throw _privateConstructorUsedError;
  @JsonKey(name: 'dust_limit')
  int? get dustLimit => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkGetBalanceCopyWith<GdkGetBalance> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkGetBalanceCopyWith<$Res> {
  factory $GdkGetBalanceCopyWith(
          GdkGetBalance value, $Res Function(GdkGetBalance) then) =
      _$GdkGetBalanceCopyWithImpl<$Res, GdkGetBalance>;
  @useResult
  $Res call(
      {int? subaccount,
      @JsonKey(name: 'num_confs') int? numConfs,
      @JsonKey(name: 'all_coins', defaultValue: true) bool? allCoins,
      @JsonKey(name: 'expired_at') int? expiredAt,
      @JsonKey(defaultValue: false) bool? confidential,
      @JsonKey(name: 'dust_limit') int? dustLimit});
}

/// @nodoc
class _$GdkGetBalanceCopyWithImpl<$Res, $Val extends GdkGetBalance>
    implements $GdkGetBalanceCopyWith<$Res> {
  _$GdkGetBalanceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subaccount = freezed,
    Object? numConfs = freezed,
    Object? allCoins = freezed,
    Object? expiredAt = freezed,
    Object? confidential = freezed,
    Object? dustLimit = freezed,
  }) {
    return _then(_value.copyWith(
      subaccount: freezed == subaccount
          ? _value.subaccount
          : subaccount // ignore: cast_nullable_to_non_nullable
              as int?,
      numConfs: freezed == numConfs
          ? _value.numConfs
          : numConfs // ignore: cast_nullable_to_non_nullable
              as int?,
      allCoins: freezed == allCoins
          ? _value.allCoins
          : allCoins // ignore: cast_nullable_to_non_nullable
              as bool?,
      expiredAt: freezed == expiredAt
          ? _value.expiredAt
          : expiredAt // ignore: cast_nullable_to_non_nullable
              as int?,
      confidential: freezed == confidential
          ? _value.confidential
          : confidential // ignore: cast_nullable_to_non_nullable
              as bool?,
      dustLimit: freezed == dustLimit
          ? _value.dustLimit
          : dustLimit // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GdkGetBalanceImplCopyWith<$Res>
    implements $GdkGetBalanceCopyWith<$Res> {
  factory _$$GdkGetBalanceImplCopyWith(
          _$GdkGetBalanceImpl value, $Res Function(_$GdkGetBalanceImpl) then) =
      __$$GdkGetBalanceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? subaccount,
      @JsonKey(name: 'num_confs') int? numConfs,
      @JsonKey(name: 'all_coins', defaultValue: true) bool? allCoins,
      @JsonKey(name: 'expired_at') int? expiredAt,
      @JsonKey(defaultValue: false) bool? confidential,
      @JsonKey(name: 'dust_limit') int? dustLimit});
}

/// @nodoc
class __$$GdkGetBalanceImplCopyWithImpl<$Res>
    extends _$GdkGetBalanceCopyWithImpl<$Res, _$GdkGetBalanceImpl>
    implements _$$GdkGetBalanceImplCopyWith<$Res> {
  __$$GdkGetBalanceImplCopyWithImpl(
      _$GdkGetBalanceImpl _value, $Res Function(_$GdkGetBalanceImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subaccount = freezed,
    Object? numConfs = freezed,
    Object? allCoins = freezed,
    Object? expiredAt = freezed,
    Object? confidential = freezed,
    Object? dustLimit = freezed,
  }) {
    return _then(_$GdkGetBalanceImpl(
      subaccount: freezed == subaccount
          ? _value.subaccount
          : subaccount // ignore: cast_nullable_to_non_nullable
              as int?,
      numConfs: freezed == numConfs
          ? _value.numConfs
          : numConfs // ignore: cast_nullable_to_non_nullable
              as int?,
      allCoins: freezed == allCoins
          ? _value.allCoins
          : allCoins // ignore: cast_nullable_to_non_nullable
              as bool?,
      expiredAt: freezed == expiredAt
          ? _value.expiredAt
          : expiredAt // ignore: cast_nullable_to_non_nullable
              as int?,
      confidential: freezed == confidential
          ? _value.confidential
          : confidential // ignore: cast_nullable_to_non_nullable
              as bool?,
      dustLimit: freezed == dustLimit
          ? _value.dustLimit
          : dustLimit // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkGetBalanceImpl extends _GdkGetBalance {
  const _$GdkGetBalanceImpl(
      {this.subaccount = 1,
      @JsonKey(name: 'num_confs') this.numConfs = 0,
      @JsonKey(name: 'all_coins', defaultValue: true) this.allCoins,
      @JsonKey(name: 'expired_at') this.expiredAt,
      @JsonKey(defaultValue: false) this.confidential,
      @JsonKey(name: 'dust_limit') this.dustLimit})
      : super._();

  factory _$GdkGetBalanceImpl.fromJson(Map<String, dynamic> json) =>
      _$$GdkGetBalanceImplFromJson(json);

  @override
  @JsonKey()
  final int? subaccount;
  @override
  @JsonKey(name: 'num_confs')
  final int? numConfs;
  @override
  @JsonKey(name: 'all_coins', defaultValue: true)
  final bool? allCoins;
  @override
  @JsonKey(name: 'expired_at')
  final int? expiredAt;
  @override
  @JsonKey(defaultValue: false)
  final bool? confidential;
  @override
  @JsonKey(name: 'dust_limit')
  final int? dustLimit;

  @override
  String toString() {
    return 'GdkGetBalance(subaccount: $subaccount, numConfs: $numConfs, allCoins: $allCoins, expiredAt: $expiredAt, confidential: $confidential, dustLimit: $dustLimit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkGetBalanceImpl &&
            (identical(other.subaccount, subaccount) ||
                other.subaccount == subaccount) &&
            (identical(other.numConfs, numConfs) ||
                other.numConfs == numConfs) &&
            (identical(other.allCoins, allCoins) ||
                other.allCoins == allCoins) &&
            (identical(other.expiredAt, expiredAt) ||
                other.expiredAt == expiredAt) &&
            (identical(other.confidential, confidential) ||
                other.confidential == confidential) &&
            (identical(other.dustLimit, dustLimit) ||
                other.dustLimit == dustLimit));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, subaccount, numConfs, allCoins,
      expiredAt, confidential, dustLimit);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkGetBalanceImplCopyWith<_$GdkGetBalanceImpl> get copyWith =>
      __$$GdkGetBalanceImplCopyWithImpl<_$GdkGetBalanceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkGetBalanceImplToJson(
      this,
    );
  }
}

abstract class _GdkGetBalance extends GdkGetBalance {
  const factory _GdkGetBalance(
      {final int? subaccount,
      @JsonKey(name: 'num_confs') final int? numConfs,
      @JsonKey(name: 'all_coins', defaultValue: true) final bool? allCoins,
      @JsonKey(name: 'expired_at') final int? expiredAt,
      @JsonKey(defaultValue: false) final bool? confidential,
      @JsonKey(name: 'dust_limit') final int? dustLimit}) = _$GdkGetBalanceImpl;
  const _GdkGetBalance._() : super._();

  factory _GdkGetBalance.fromJson(Map<String, dynamic> json) =
      _$GdkGetBalanceImpl.fromJson;

  @override
  int? get subaccount;
  @override
  @JsonKey(name: 'num_confs')
  int? get numConfs;
  @override
  @JsonKey(name: 'all_coins', defaultValue: true)
  bool? get allCoins;
  @override
  @JsonKey(name: 'expired_at')
  int? get expiredAt;
  @override
  @JsonKey(defaultValue: false)
  bool? get confidential;
  @override
  @JsonKey(name: 'dust_limit')
  int? get dustLimit;
  @override
  @JsonKey(ignore: true)
  _$$GdkGetBalanceImplCopyWith<_$GdkGetBalanceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GdkAssetsParameters _$GdkAssetsParametersFromJson(Map<String, dynamic> json) {
  return _GdkAssetsParameters.fromJson(json);
}

/// @nodoc
mixin _$GdkAssetsParameters {
  bool? get icons => throw _privateConstructorUsedError;
  bool? get assets => throw _privateConstructorUsedError;
  bool? get refresh => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkAssetsParametersCopyWith<GdkAssetsParameters> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkAssetsParametersCopyWith<$Res> {
  factory $GdkAssetsParametersCopyWith(
          GdkAssetsParameters value, $Res Function(GdkAssetsParameters) then) =
      _$GdkAssetsParametersCopyWithImpl<$Res, GdkAssetsParameters>;
  @useResult
  $Res call({bool? icons, bool? assets, bool? refresh});
}

/// @nodoc
class _$GdkAssetsParametersCopyWithImpl<$Res, $Val extends GdkAssetsParameters>
    implements $GdkAssetsParametersCopyWith<$Res> {
  _$GdkAssetsParametersCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? icons = freezed,
    Object? assets = freezed,
    Object? refresh = freezed,
  }) {
    return _then(_value.copyWith(
      icons: freezed == icons
          ? _value.icons
          : icons // ignore: cast_nullable_to_non_nullable
              as bool?,
      assets: freezed == assets
          ? _value.assets
          : assets // ignore: cast_nullable_to_non_nullable
              as bool?,
      refresh: freezed == refresh
          ? _value.refresh
          : refresh // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GdkAssetsParametersImplCopyWith<$Res>
    implements $GdkAssetsParametersCopyWith<$Res> {
  factory _$$GdkAssetsParametersImplCopyWith(_$GdkAssetsParametersImpl value,
          $Res Function(_$GdkAssetsParametersImpl) then) =
      __$$GdkAssetsParametersImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool? icons, bool? assets, bool? refresh});
}

/// @nodoc
class __$$GdkAssetsParametersImplCopyWithImpl<$Res>
    extends _$GdkAssetsParametersCopyWithImpl<$Res, _$GdkAssetsParametersImpl>
    implements _$$GdkAssetsParametersImplCopyWith<$Res> {
  __$$GdkAssetsParametersImplCopyWithImpl(_$GdkAssetsParametersImpl _value,
      $Res Function(_$GdkAssetsParametersImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? icons = freezed,
    Object? assets = freezed,
    Object? refresh = freezed,
  }) {
    return _then(_$GdkAssetsParametersImpl(
      icons: freezed == icons
          ? _value.icons
          : icons // ignore: cast_nullable_to_non_nullable
              as bool?,
      assets: freezed == assets
          ? _value.assets
          : assets // ignore: cast_nullable_to_non_nullable
              as bool?,
      refresh: freezed == refresh
          ? _value.refresh
          : refresh // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkAssetsParametersImpl extends _GdkAssetsParameters {
  const _$GdkAssetsParametersImpl(
      {this.icons = true, this.assets = true, this.refresh = true})
      : super._();

  factory _$GdkAssetsParametersImpl.fromJson(Map<String, dynamic> json) =>
      _$$GdkAssetsParametersImplFromJson(json);

  @override
  @JsonKey()
  final bool? icons;
  @override
  @JsonKey()
  final bool? assets;
  @override
  @JsonKey()
  final bool? refresh;

  @override
  String toString() {
    return 'GdkAssetsParameters(icons: $icons, assets: $assets, refresh: $refresh)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkAssetsParametersImpl &&
            (identical(other.icons, icons) || other.icons == icons) &&
            (identical(other.assets, assets) || other.assets == assets) &&
            (identical(other.refresh, refresh) || other.refresh == refresh));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, icons, assets, refresh);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkAssetsParametersImplCopyWith<_$GdkAssetsParametersImpl> get copyWith =>
      __$$GdkAssetsParametersImplCopyWithImpl<_$GdkAssetsParametersImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkAssetsParametersImplToJson(
      this,
    );
  }
}

abstract class _GdkAssetsParameters extends GdkAssetsParameters {
  const factory _GdkAssetsParameters(
      {final bool? icons,
      final bool? assets,
      final bool? refresh}) = _$GdkAssetsParametersImpl;
  const _GdkAssetsParameters._() : super._();

  factory _GdkAssetsParameters.fromJson(Map<String, dynamic> json) =
      _$GdkAssetsParametersImpl.fromJson;

  @override
  bool? get icons;
  @override
  bool? get assets;
  @override
  bool? get refresh;
  @override
  @JsonKey(ignore: true)
  _$$GdkAssetsParametersImplCopyWith<_$GdkAssetsParametersImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GdkGetAssetsParameters _$GdkGetAssetsParametersFromJson(
    Map<String, dynamic> json) {
  return _GdkGetAssetsParameters.fromJson(json);
}

/// @nodoc
mixin _$GdkGetAssetsParameters {
  List<String>? get assets_id => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkGetAssetsParametersCopyWith<GdkGetAssetsParameters> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkGetAssetsParametersCopyWith<$Res> {
  factory $GdkGetAssetsParametersCopyWith(GdkGetAssetsParameters value,
          $Res Function(GdkGetAssetsParameters) then) =
      _$GdkGetAssetsParametersCopyWithImpl<$Res, GdkGetAssetsParameters>;
  @useResult
  $Res call({List<String>? assets_id});
}

/// @nodoc
class _$GdkGetAssetsParametersCopyWithImpl<$Res,
        $Val extends GdkGetAssetsParameters>
    implements $GdkGetAssetsParametersCopyWith<$Res> {
  _$GdkGetAssetsParametersCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? assets_id = freezed,
  }) {
    return _then(_value.copyWith(
      assets_id: freezed == assets_id
          ? _value.assets_id
          : assets_id // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GdkGetAssetsParametersImplCopyWith<$Res>
    implements $GdkGetAssetsParametersCopyWith<$Res> {
  factory _$$GdkGetAssetsParametersImplCopyWith(
          _$GdkGetAssetsParametersImpl value,
          $Res Function(_$GdkGetAssetsParametersImpl) then) =
      __$$GdkGetAssetsParametersImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<String>? assets_id});
}

/// @nodoc
class __$$GdkGetAssetsParametersImplCopyWithImpl<$Res>
    extends _$GdkGetAssetsParametersCopyWithImpl<$Res,
        _$GdkGetAssetsParametersImpl>
    implements _$$GdkGetAssetsParametersImplCopyWith<$Res> {
  __$$GdkGetAssetsParametersImplCopyWithImpl(
      _$GdkGetAssetsParametersImpl _value,
      $Res Function(_$GdkGetAssetsParametersImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? assets_id = freezed,
  }) {
    return _then(_$GdkGetAssetsParametersImpl(
      assets_id: freezed == assets_id
          ? _value._assets_id
          : assets_id // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkGetAssetsParametersImpl extends _GdkGetAssetsParameters {
  const _$GdkGetAssetsParametersImpl({final List<String>? assets_id})
      : _assets_id = assets_id,
        super._();

  factory _$GdkGetAssetsParametersImpl.fromJson(Map<String, dynamic> json) =>
      _$$GdkGetAssetsParametersImplFromJson(json);

  final List<String>? _assets_id;
  @override
  List<String>? get assets_id {
    final value = _assets_id;
    if (value == null) return null;
    if (_assets_id is EqualUnmodifiableListView) return _assets_id;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'GdkGetAssetsParameters(assets_id: $assets_id)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkGetAssetsParametersImpl &&
            const DeepCollectionEquality()
                .equals(other._assets_id, _assets_id));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_assets_id));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkGetAssetsParametersImplCopyWith<_$GdkGetAssetsParametersImpl>
      get copyWith => __$$GdkGetAssetsParametersImplCopyWithImpl<
          _$GdkGetAssetsParametersImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkGetAssetsParametersImplToJson(
      this,
    );
  }
}

abstract class _GdkGetAssetsParameters extends GdkGetAssetsParameters {
  const factory _GdkGetAssetsParameters({final List<String>? assets_id}) =
      _$GdkGetAssetsParametersImpl;
  const _GdkGetAssetsParameters._() : super._();

  factory _GdkGetAssetsParameters.fromJson(Map<String, dynamic> json) =
      _$GdkGetAssetsParametersImpl.fromJson;

  @override
  List<String>? get assets_id;
  @override
  @JsonKey(ignore: true)
  _$$GdkGetAssetsParametersImplCopyWith<_$GdkGetAssetsParametersImpl>
      get copyWith => throw _privateConstructorUsedError;
}

GdkAuthHandlerStatusResult _$GdkAuthHandlerStatusResultFromJson(
    Map<String, dynamic> json) {
  return _GdkAuthHandlerStatusResult.fromJson(json);
}

/// @nodoc
mixin _$GdkAuthHandlerStatusResult {
  @JsonKey(name: 'login_user')
  GdkLoginUser? get loginUser => throw _privateConstructorUsedError;
  List<GdkTransaction>? get transactions => throw _privateConstructorUsedError;
  Map<String, dynamic>? get balance => throw _privateConstructorUsedError;
  @JsonKey(name: 'get_subaccount')
  GdkWallet? get getSubaccount => throw _privateConstructorUsedError;
  @JsonKey(name: 'get_receive_address')
  GdkReceiveAddressDetails? get getReceiveAddress =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'last_pointer')
  int? get lastPointer => throw _privateConstructorUsedError;
  List<GdkPreviousAddress>? get list => throw _privateConstructorUsedError;
  @JsonKey(name: 'create_transaction')
  GdkNewTransactionReply? get createTransaction =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'sign_tx')
  GdkNewTransactionReply? get signTx => throw _privateConstructorUsedError;
  @JsonKey(name: 'send_raw_tx')
  GdkNewTransactionReply? get sendRawTx => throw _privateConstructorUsedError;
  @JsonKey(name: 'create_pset')
  GdkCreatePsetDetailsReply? get createPset =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'sign_pset')
  GdkSignPsetDetailsReply? get signPset => throw _privateConstructorUsedError;
  @JsonKey(name: 'sign_psbt')
  GdkSignPsbtResult? get signPsbt => throw _privateConstructorUsedError;
  @JsonKey(name: 'unspent_outputs')
  GdkUnspentOutputsReply? get unspentOutputs =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkAuthHandlerStatusResultCopyWith<GdkAuthHandlerStatusResult>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkAuthHandlerStatusResultCopyWith<$Res> {
  factory $GdkAuthHandlerStatusResultCopyWith(GdkAuthHandlerStatusResult value,
          $Res Function(GdkAuthHandlerStatusResult) then) =
      _$GdkAuthHandlerStatusResultCopyWithImpl<$Res,
          GdkAuthHandlerStatusResult>;
  @useResult
  $Res call(
      {@JsonKey(name: 'login_user') GdkLoginUser? loginUser,
      List<GdkTransaction>? transactions,
      Map<String, dynamic>? balance,
      @JsonKey(name: 'get_subaccount') GdkWallet? getSubaccount,
      @JsonKey(name: 'get_receive_address')
      GdkReceiveAddressDetails? getReceiveAddress,
      @JsonKey(name: 'last_pointer') int? lastPointer,
      List<GdkPreviousAddress>? list,
      @JsonKey(name: 'create_transaction')
      GdkNewTransactionReply? createTransaction,
      @JsonKey(name: 'sign_tx') GdkNewTransactionReply? signTx,
      @JsonKey(name: 'send_raw_tx') GdkNewTransactionReply? sendRawTx,
      @JsonKey(name: 'create_pset') GdkCreatePsetDetailsReply? createPset,
      @JsonKey(name: 'sign_pset') GdkSignPsetDetailsReply? signPset,
      @JsonKey(name: 'sign_psbt') GdkSignPsbtResult? signPsbt,
      @JsonKey(name: 'unspent_outputs')
      GdkUnspentOutputsReply? unspentOutputs});

  $GdkLoginUserCopyWith<$Res>? get loginUser;
  $GdkWalletCopyWith<$Res>? get getSubaccount;
  $GdkReceiveAddressDetailsCopyWith<$Res>? get getReceiveAddress;
  $GdkNewTransactionReplyCopyWith<$Res>? get createTransaction;
  $GdkNewTransactionReplyCopyWith<$Res>? get signTx;
  $GdkNewTransactionReplyCopyWith<$Res>? get sendRawTx;
  $GdkCreatePsetDetailsReplyCopyWith<$Res>? get createPset;
  $GdkSignPsetDetailsReplyCopyWith<$Res>? get signPset;
  $GdkSignPsbtResultCopyWith<$Res>? get signPsbt;
  $GdkUnspentOutputsReplyCopyWith<$Res>? get unspentOutputs;
}

/// @nodoc
class _$GdkAuthHandlerStatusResultCopyWithImpl<$Res,
        $Val extends GdkAuthHandlerStatusResult>
    implements $GdkAuthHandlerStatusResultCopyWith<$Res> {
  _$GdkAuthHandlerStatusResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? loginUser = freezed,
    Object? transactions = freezed,
    Object? balance = freezed,
    Object? getSubaccount = freezed,
    Object? getReceiveAddress = freezed,
    Object? lastPointer = freezed,
    Object? list = freezed,
    Object? createTransaction = freezed,
    Object? signTx = freezed,
    Object? sendRawTx = freezed,
    Object? createPset = freezed,
    Object? signPset = freezed,
    Object? signPsbt = freezed,
    Object? unspentOutputs = freezed,
  }) {
    return _then(_value.copyWith(
      loginUser: freezed == loginUser
          ? _value.loginUser
          : loginUser // ignore: cast_nullable_to_non_nullable
              as GdkLoginUser?,
      transactions: freezed == transactions
          ? _value.transactions
          : transactions // ignore: cast_nullable_to_non_nullable
              as List<GdkTransaction>?,
      balance: freezed == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      getSubaccount: freezed == getSubaccount
          ? _value.getSubaccount
          : getSubaccount // ignore: cast_nullable_to_non_nullable
              as GdkWallet?,
      getReceiveAddress: freezed == getReceiveAddress
          ? _value.getReceiveAddress
          : getReceiveAddress // ignore: cast_nullable_to_non_nullable
              as GdkReceiveAddressDetails?,
      lastPointer: freezed == lastPointer
          ? _value.lastPointer
          : lastPointer // ignore: cast_nullable_to_non_nullable
              as int?,
      list: freezed == list
          ? _value.list
          : list // ignore: cast_nullable_to_non_nullable
              as List<GdkPreviousAddress>?,
      createTransaction: freezed == createTransaction
          ? _value.createTransaction
          : createTransaction // ignore: cast_nullable_to_non_nullable
              as GdkNewTransactionReply?,
      signTx: freezed == signTx
          ? _value.signTx
          : signTx // ignore: cast_nullable_to_non_nullable
              as GdkNewTransactionReply?,
      sendRawTx: freezed == sendRawTx
          ? _value.sendRawTx
          : sendRawTx // ignore: cast_nullable_to_non_nullable
              as GdkNewTransactionReply?,
      createPset: freezed == createPset
          ? _value.createPset
          : createPset // ignore: cast_nullable_to_non_nullable
              as GdkCreatePsetDetailsReply?,
      signPset: freezed == signPset
          ? _value.signPset
          : signPset // ignore: cast_nullable_to_non_nullable
              as GdkSignPsetDetailsReply?,
      signPsbt: freezed == signPsbt
          ? _value.signPsbt
          : signPsbt // ignore: cast_nullable_to_non_nullable
              as GdkSignPsbtResult?,
      unspentOutputs: freezed == unspentOutputs
          ? _value.unspentOutputs
          : unspentOutputs // ignore: cast_nullable_to_non_nullable
              as GdkUnspentOutputsReply?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $GdkLoginUserCopyWith<$Res>? get loginUser {
    if (_value.loginUser == null) {
      return null;
    }

    return $GdkLoginUserCopyWith<$Res>(_value.loginUser!, (value) {
      return _then(_value.copyWith(loginUser: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $GdkWalletCopyWith<$Res>? get getSubaccount {
    if (_value.getSubaccount == null) {
      return null;
    }

    return $GdkWalletCopyWith<$Res>(_value.getSubaccount!, (value) {
      return _then(_value.copyWith(getSubaccount: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $GdkReceiveAddressDetailsCopyWith<$Res>? get getReceiveAddress {
    if (_value.getReceiveAddress == null) {
      return null;
    }

    return $GdkReceiveAddressDetailsCopyWith<$Res>(_value.getReceiveAddress!,
        (value) {
      return _then(_value.copyWith(getReceiveAddress: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $GdkNewTransactionReplyCopyWith<$Res>? get createTransaction {
    if (_value.createTransaction == null) {
      return null;
    }

    return $GdkNewTransactionReplyCopyWith<$Res>(_value.createTransaction!,
        (value) {
      return _then(_value.copyWith(createTransaction: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $GdkNewTransactionReplyCopyWith<$Res>? get signTx {
    if (_value.signTx == null) {
      return null;
    }

    return $GdkNewTransactionReplyCopyWith<$Res>(_value.signTx!, (value) {
      return _then(_value.copyWith(signTx: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $GdkNewTransactionReplyCopyWith<$Res>? get sendRawTx {
    if (_value.sendRawTx == null) {
      return null;
    }

    return $GdkNewTransactionReplyCopyWith<$Res>(_value.sendRawTx!, (value) {
      return _then(_value.copyWith(sendRawTx: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $GdkCreatePsetDetailsReplyCopyWith<$Res>? get createPset {
    if (_value.createPset == null) {
      return null;
    }

    return $GdkCreatePsetDetailsReplyCopyWith<$Res>(_value.createPset!,
        (value) {
      return _then(_value.copyWith(createPset: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $GdkSignPsetDetailsReplyCopyWith<$Res>? get signPset {
    if (_value.signPset == null) {
      return null;
    }

    return $GdkSignPsetDetailsReplyCopyWith<$Res>(_value.signPset!, (value) {
      return _then(_value.copyWith(signPset: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $GdkSignPsbtResultCopyWith<$Res>? get signPsbt {
    if (_value.signPsbt == null) {
      return null;
    }

    return $GdkSignPsbtResultCopyWith<$Res>(_value.signPsbt!, (value) {
      return _then(_value.copyWith(signPsbt: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $GdkUnspentOutputsReplyCopyWith<$Res>? get unspentOutputs {
    if (_value.unspentOutputs == null) {
      return null;
    }

    return $GdkUnspentOutputsReplyCopyWith<$Res>(_value.unspentOutputs!,
        (value) {
      return _then(_value.copyWith(unspentOutputs: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GdkAuthHandlerStatusResultImplCopyWith<$Res>
    implements $GdkAuthHandlerStatusResultCopyWith<$Res> {
  factory _$$GdkAuthHandlerStatusResultImplCopyWith(
          _$GdkAuthHandlerStatusResultImpl value,
          $Res Function(_$GdkAuthHandlerStatusResultImpl) then) =
      __$$GdkAuthHandlerStatusResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'login_user') GdkLoginUser? loginUser,
      List<GdkTransaction>? transactions,
      Map<String, dynamic>? balance,
      @JsonKey(name: 'get_subaccount') GdkWallet? getSubaccount,
      @JsonKey(name: 'get_receive_address')
      GdkReceiveAddressDetails? getReceiveAddress,
      @JsonKey(name: 'last_pointer') int? lastPointer,
      List<GdkPreviousAddress>? list,
      @JsonKey(name: 'create_transaction')
      GdkNewTransactionReply? createTransaction,
      @JsonKey(name: 'sign_tx') GdkNewTransactionReply? signTx,
      @JsonKey(name: 'send_raw_tx') GdkNewTransactionReply? sendRawTx,
      @JsonKey(name: 'create_pset') GdkCreatePsetDetailsReply? createPset,
      @JsonKey(name: 'sign_pset') GdkSignPsetDetailsReply? signPset,
      @JsonKey(name: 'sign_psbt') GdkSignPsbtResult? signPsbt,
      @JsonKey(name: 'unspent_outputs')
      GdkUnspentOutputsReply? unspentOutputs});

  @override
  $GdkLoginUserCopyWith<$Res>? get loginUser;
  @override
  $GdkWalletCopyWith<$Res>? get getSubaccount;
  @override
  $GdkReceiveAddressDetailsCopyWith<$Res>? get getReceiveAddress;
  @override
  $GdkNewTransactionReplyCopyWith<$Res>? get createTransaction;
  @override
  $GdkNewTransactionReplyCopyWith<$Res>? get signTx;
  @override
  $GdkNewTransactionReplyCopyWith<$Res>? get sendRawTx;
  @override
  $GdkCreatePsetDetailsReplyCopyWith<$Res>? get createPset;
  @override
  $GdkSignPsetDetailsReplyCopyWith<$Res>? get signPset;
  @override
  $GdkSignPsbtResultCopyWith<$Res>? get signPsbt;
  @override
  $GdkUnspentOutputsReplyCopyWith<$Res>? get unspentOutputs;
}

/// @nodoc
class __$$GdkAuthHandlerStatusResultImplCopyWithImpl<$Res>
    extends _$GdkAuthHandlerStatusResultCopyWithImpl<$Res,
        _$GdkAuthHandlerStatusResultImpl>
    implements _$$GdkAuthHandlerStatusResultImplCopyWith<$Res> {
  __$$GdkAuthHandlerStatusResultImplCopyWithImpl(
      _$GdkAuthHandlerStatusResultImpl _value,
      $Res Function(_$GdkAuthHandlerStatusResultImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? loginUser = freezed,
    Object? transactions = freezed,
    Object? balance = freezed,
    Object? getSubaccount = freezed,
    Object? getReceiveAddress = freezed,
    Object? lastPointer = freezed,
    Object? list = freezed,
    Object? createTransaction = freezed,
    Object? signTx = freezed,
    Object? sendRawTx = freezed,
    Object? createPset = freezed,
    Object? signPset = freezed,
    Object? signPsbt = freezed,
    Object? unspentOutputs = freezed,
  }) {
    return _then(_$GdkAuthHandlerStatusResultImpl(
      loginUser: freezed == loginUser
          ? _value.loginUser
          : loginUser // ignore: cast_nullable_to_non_nullable
              as GdkLoginUser?,
      transactions: freezed == transactions
          ? _value._transactions
          : transactions // ignore: cast_nullable_to_non_nullable
              as List<GdkTransaction>?,
      balance: freezed == balance
          ? _value._balance
          : balance // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      getSubaccount: freezed == getSubaccount
          ? _value.getSubaccount
          : getSubaccount // ignore: cast_nullable_to_non_nullable
              as GdkWallet?,
      getReceiveAddress: freezed == getReceiveAddress
          ? _value.getReceiveAddress
          : getReceiveAddress // ignore: cast_nullable_to_non_nullable
              as GdkReceiveAddressDetails?,
      lastPointer: freezed == lastPointer
          ? _value.lastPointer
          : lastPointer // ignore: cast_nullable_to_non_nullable
              as int?,
      list: freezed == list
          ? _value._list
          : list // ignore: cast_nullable_to_non_nullable
              as List<GdkPreviousAddress>?,
      createTransaction: freezed == createTransaction
          ? _value.createTransaction
          : createTransaction // ignore: cast_nullable_to_non_nullable
              as GdkNewTransactionReply?,
      signTx: freezed == signTx
          ? _value.signTx
          : signTx // ignore: cast_nullable_to_non_nullable
              as GdkNewTransactionReply?,
      sendRawTx: freezed == sendRawTx
          ? _value.sendRawTx
          : sendRawTx // ignore: cast_nullable_to_non_nullable
              as GdkNewTransactionReply?,
      createPset: freezed == createPset
          ? _value.createPset
          : createPset // ignore: cast_nullable_to_non_nullable
              as GdkCreatePsetDetailsReply?,
      signPset: freezed == signPset
          ? _value.signPset
          : signPset // ignore: cast_nullable_to_non_nullable
              as GdkSignPsetDetailsReply?,
      signPsbt: freezed == signPsbt
          ? _value.signPsbt
          : signPsbt // ignore: cast_nullable_to_non_nullable
              as GdkSignPsbtResult?,
      unspentOutputs: freezed == unspentOutputs
          ? _value.unspentOutputs
          : unspentOutputs // ignore: cast_nullable_to_non_nullable
              as GdkUnspentOutputsReply?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkAuthHandlerStatusResultImpl implements _GdkAuthHandlerStatusResult {
  const _$GdkAuthHandlerStatusResultImpl(
      {@JsonKey(name: 'login_user') this.loginUser,
      final List<GdkTransaction>? transactions,
      final Map<String, dynamic>? balance,
      @JsonKey(name: 'get_subaccount') this.getSubaccount,
      @JsonKey(name: 'get_receive_address') this.getReceiveAddress,
      @JsonKey(name: 'last_pointer') this.lastPointer,
      final List<GdkPreviousAddress>? list,
      @JsonKey(name: 'create_transaction') this.createTransaction,
      @JsonKey(name: 'sign_tx') this.signTx,
      @JsonKey(name: 'send_raw_tx') this.sendRawTx,
      @JsonKey(name: 'create_pset') this.createPset,
      @JsonKey(name: 'sign_pset') this.signPset,
      @JsonKey(name: 'sign_psbt') this.signPsbt,
      @JsonKey(name: 'unspent_outputs') this.unspentOutputs})
      : _transactions = transactions,
        _balance = balance,
        _list = list;

  factory _$GdkAuthHandlerStatusResultImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$GdkAuthHandlerStatusResultImplFromJson(json);

  @override
  @JsonKey(name: 'login_user')
  final GdkLoginUser? loginUser;
  final List<GdkTransaction>? _transactions;
  @override
  List<GdkTransaction>? get transactions {
    final value = _transactions;
    if (value == null) return null;
    if (_transactions is EqualUnmodifiableListView) return _transactions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final Map<String, dynamic>? _balance;
  @override
  Map<String, dynamic>? get balance {
    final value = _balance;
    if (value == null) return null;
    if (_balance is EqualUnmodifiableMapView) return _balance;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey(name: 'get_subaccount')
  final GdkWallet? getSubaccount;
  @override
  @JsonKey(name: 'get_receive_address')
  final GdkReceiveAddressDetails? getReceiveAddress;
  @override
  @JsonKey(name: 'last_pointer')
  final int? lastPointer;
  final List<GdkPreviousAddress>? _list;
  @override
  List<GdkPreviousAddress>? get list {
    final value = _list;
    if (value == null) return null;
    if (_list is EqualUnmodifiableListView) return _list;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'create_transaction')
  final GdkNewTransactionReply? createTransaction;
  @override
  @JsonKey(name: 'sign_tx')
  final GdkNewTransactionReply? signTx;
  @override
  @JsonKey(name: 'send_raw_tx')
  final GdkNewTransactionReply? sendRawTx;
  @override
  @JsonKey(name: 'create_pset')
  final GdkCreatePsetDetailsReply? createPset;
  @override
  @JsonKey(name: 'sign_pset')
  final GdkSignPsetDetailsReply? signPset;
  @override
  @JsonKey(name: 'sign_psbt')
  final GdkSignPsbtResult? signPsbt;
  @override
  @JsonKey(name: 'unspent_outputs')
  final GdkUnspentOutputsReply? unspentOutputs;

  @override
  String toString() {
    return 'GdkAuthHandlerStatusResult(loginUser: $loginUser, transactions: $transactions, balance: $balance, getSubaccount: $getSubaccount, getReceiveAddress: $getReceiveAddress, lastPointer: $lastPointer, list: $list, createTransaction: $createTransaction, signTx: $signTx, sendRawTx: $sendRawTx, createPset: $createPset, signPset: $signPset, signPsbt: $signPsbt, unspentOutputs: $unspentOutputs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkAuthHandlerStatusResultImpl &&
            (identical(other.loginUser, loginUser) ||
                other.loginUser == loginUser) &&
            const DeepCollectionEquality()
                .equals(other._transactions, _transactions) &&
            const DeepCollectionEquality().equals(other._balance, _balance) &&
            (identical(other.getSubaccount, getSubaccount) ||
                other.getSubaccount == getSubaccount) &&
            (identical(other.getReceiveAddress, getReceiveAddress) ||
                other.getReceiveAddress == getReceiveAddress) &&
            (identical(other.lastPointer, lastPointer) ||
                other.lastPointer == lastPointer) &&
            const DeepCollectionEquality().equals(other._list, _list) &&
            (identical(other.createTransaction, createTransaction) ||
                other.createTransaction == createTransaction) &&
            (identical(other.signTx, signTx) || other.signTx == signTx) &&
            (identical(other.sendRawTx, sendRawTx) ||
                other.sendRawTx == sendRawTx) &&
            (identical(other.createPset, createPset) ||
                other.createPset == createPset) &&
            (identical(other.signPset, signPset) ||
                other.signPset == signPset) &&
            (identical(other.signPsbt, signPsbt) ||
                other.signPsbt == signPsbt) &&
            (identical(other.unspentOutputs, unspentOutputs) ||
                other.unspentOutputs == unspentOutputs));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      loginUser,
      const DeepCollectionEquality().hash(_transactions),
      const DeepCollectionEquality().hash(_balance),
      getSubaccount,
      getReceiveAddress,
      lastPointer,
      const DeepCollectionEquality().hash(_list),
      createTransaction,
      signTx,
      sendRawTx,
      createPset,
      signPset,
      signPsbt,
      unspentOutputs);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkAuthHandlerStatusResultImplCopyWith<_$GdkAuthHandlerStatusResultImpl>
      get copyWith => __$$GdkAuthHandlerStatusResultImplCopyWithImpl<
          _$GdkAuthHandlerStatusResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkAuthHandlerStatusResultImplToJson(
      this,
    );
  }
}

abstract class _GdkAuthHandlerStatusResult
    implements GdkAuthHandlerStatusResult {
  const factory _GdkAuthHandlerStatusResult(
      {@JsonKey(name: 'login_user') final GdkLoginUser? loginUser,
      final List<GdkTransaction>? transactions,
      final Map<String, dynamic>? balance,
      @JsonKey(name: 'get_subaccount') final GdkWallet? getSubaccount,
      @JsonKey(name: 'get_receive_address')
      final GdkReceiveAddressDetails? getReceiveAddress,
      @JsonKey(name: 'last_pointer') final int? lastPointer,
      final List<GdkPreviousAddress>? list,
      @JsonKey(name: 'create_transaction')
      final GdkNewTransactionReply? createTransaction,
      @JsonKey(name: 'sign_tx') final GdkNewTransactionReply? signTx,
      @JsonKey(name: 'send_raw_tx') final GdkNewTransactionReply? sendRawTx,
      @JsonKey(name: 'create_pset') final GdkCreatePsetDetailsReply? createPset,
      @JsonKey(name: 'sign_pset') final GdkSignPsetDetailsReply? signPset,
      @JsonKey(name: 'sign_psbt') final GdkSignPsbtResult? signPsbt,
      @JsonKey(name: 'unspent_outputs')
      final GdkUnspentOutputsReply?
          unspentOutputs}) = _$GdkAuthHandlerStatusResultImpl;

  factory _GdkAuthHandlerStatusResult.fromJson(Map<String, dynamic> json) =
      _$GdkAuthHandlerStatusResultImpl.fromJson;

  @override
  @JsonKey(name: 'login_user')
  GdkLoginUser? get loginUser;
  @override
  List<GdkTransaction>? get transactions;
  @override
  Map<String, dynamic>? get balance;
  @override
  @JsonKey(name: 'get_subaccount')
  GdkWallet? get getSubaccount;
  @override
  @JsonKey(name: 'get_receive_address')
  GdkReceiveAddressDetails? get getReceiveAddress;
  @override
  @JsonKey(name: 'last_pointer')
  int? get lastPointer;
  @override
  List<GdkPreviousAddress>? get list;
  @override
  @JsonKey(name: 'create_transaction')
  GdkNewTransactionReply? get createTransaction;
  @override
  @JsonKey(name: 'sign_tx')
  GdkNewTransactionReply? get signTx;
  @override
  @JsonKey(name: 'send_raw_tx')
  GdkNewTransactionReply? get sendRawTx;
  @override
  @JsonKey(name: 'create_pset')
  GdkCreatePsetDetailsReply? get createPset;
  @override
  @JsonKey(name: 'sign_pset')
  GdkSignPsetDetailsReply? get signPset;
  @override
  @JsonKey(name: 'sign_psbt')
  GdkSignPsbtResult? get signPsbt;
  @override
  @JsonKey(name: 'unspent_outputs')
  GdkUnspentOutputsReply? get unspentOutputs;
  @override
  @JsonKey(ignore: true)
  _$$GdkAuthHandlerStatusResultImplCopyWith<_$GdkAuthHandlerStatusResultImpl>
      get copyWith => throw _privateConstructorUsedError;
}

GdkAuthHandlerStatus _$GdkAuthHandlerStatusFromJson(Map<String, dynamic> json) {
  return _GdkAuthHandlerStatus.fromJson(json);
}

/// @nodoc
mixin _$GdkAuthHandlerStatus {
  GdkAuthHandlerStatusEnum get status => throw _privateConstructorUsedError;
  GdkAuthHandlerStatusResult? get result => throw _privateConstructorUsedError;
  List<String>? get methods => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  String? get action => throw _privateConstructorUsedError;
  @JsonKey(name: 'auth_data')
  Map<String, dynamic>? get authData => throw _privateConstructorUsedError;
  @JsonKey(name: 'attempts_remaining')
  int? get attemptsRemaining => throw _privateConstructorUsedError;
  String? get device => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  String? get authHandlerId => throw _privateConstructorUsedError;
  @JsonKey(name: 'required_data')
  Map<String, dynamic>? get requiredData => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkAuthHandlerStatusCopyWith<GdkAuthHandlerStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkAuthHandlerStatusCopyWith<$Res> {
  factory $GdkAuthHandlerStatusCopyWith(GdkAuthHandlerStatus value,
          $Res Function(GdkAuthHandlerStatus) then) =
      _$GdkAuthHandlerStatusCopyWithImpl<$Res, GdkAuthHandlerStatus>;
  @useResult
  $Res call(
      {GdkAuthHandlerStatusEnum status,
      GdkAuthHandlerStatusResult? result,
      List<String>? methods,
      String? error,
      String? action,
      @JsonKey(name: 'auth_data') Map<String, dynamic>? authData,
      @JsonKey(name: 'attempts_remaining') int? attemptsRemaining,
      String? device,
      String? message,
      String? authHandlerId,
      @JsonKey(name: 'required_data') Map<String, dynamic>? requiredData});

  $GdkAuthHandlerStatusResultCopyWith<$Res>? get result;
}

/// @nodoc
class _$GdkAuthHandlerStatusCopyWithImpl<$Res,
        $Val extends GdkAuthHandlerStatus>
    implements $GdkAuthHandlerStatusCopyWith<$Res> {
  _$GdkAuthHandlerStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? result = freezed,
    Object? methods = freezed,
    Object? error = freezed,
    Object? action = freezed,
    Object? authData = freezed,
    Object? attemptsRemaining = freezed,
    Object? device = freezed,
    Object? message = freezed,
    Object? authHandlerId = freezed,
    Object? requiredData = freezed,
  }) {
    return _then(_value.copyWith(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as GdkAuthHandlerStatusEnum,
      result: freezed == result
          ? _value.result
          : result // ignore: cast_nullable_to_non_nullable
              as GdkAuthHandlerStatusResult?,
      methods: freezed == methods
          ? _value.methods
          : methods // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      action: freezed == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as String?,
      authData: freezed == authData
          ? _value.authData
          : authData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      attemptsRemaining: freezed == attemptsRemaining
          ? _value.attemptsRemaining
          : attemptsRemaining // ignore: cast_nullable_to_non_nullable
              as int?,
      device: freezed == device
          ? _value.device
          : device // ignore: cast_nullable_to_non_nullable
              as String?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      authHandlerId: freezed == authHandlerId
          ? _value.authHandlerId
          : authHandlerId // ignore: cast_nullable_to_non_nullable
              as String?,
      requiredData: freezed == requiredData
          ? _value.requiredData
          : requiredData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $GdkAuthHandlerStatusResultCopyWith<$Res>? get result {
    if (_value.result == null) {
      return null;
    }

    return $GdkAuthHandlerStatusResultCopyWith<$Res>(_value.result!, (value) {
      return _then(_value.copyWith(result: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GdkAuthHandlerStatusImplCopyWith<$Res>
    implements $GdkAuthHandlerStatusCopyWith<$Res> {
  factory _$$GdkAuthHandlerStatusImplCopyWith(_$GdkAuthHandlerStatusImpl value,
          $Res Function(_$GdkAuthHandlerStatusImpl) then) =
      __$$GdkAuthHandlerStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {GdkAuthHandlerStatusEnum status,
      GdkAuthHandlerStatusResult? result,
      List<String>? methods,
      String? error,
      String? action,
      @JsonKey(name: 'auth_data') Map<String, dynamic>? authData,
      @JsonKey(name: 'attempts_remaining') int? attemptsRemaining,
      String? device,
      String? message,
      String? authHandlerId,
      @JsonKey(name: 'required_data') Map<String, dynamic>? requiredData});

  @override
  $GdkAuthHandlerStatusResultCopyWith<$Res>? get result;
}

/// @nodoc
class __$$GdkAuthHandlerStatusImplCopyWithImpl<$Res>
    extends _$GdkAuthHandlerStatusCopyWithImpl<$Res, _$GdkAuthHandlerStatusImpl>
    implements _$$GdkAuthHandlerStatusImplCopyWith<$Res> {
  __$$GdkAuthHandlerStatusImplCopyWithImpl(_$GdkAuthHandlerStatusImpl _value,
      $Res Function(_$GdkAuthHandlerStatusImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? result = freezed,
    Object? methods = freezed,
    Object? error = freezed,
    Object? action = freezed,
    Object? authData = freezed,
    Object? attemptsRemaining = freezed,
    Object? device = freezed,
    Object? message = freezed,
    Object? authHandlerId = freezed,
    Object? requiredData = freezed,
  }) {
    return _then(_$GdkAuthHandlerStatusImpl(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as GdkAuthHandlerStatusEnum,
      result: freezed == result
          ? _value.result
          : result // ignore: cast_nullable_to_non_nullable
              as GdkAuthHandlerStatusResult?,
      methods: freezed == methods
          ? _value._methods
          : methods // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      action: freezed == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as String?,
      authData: freezed == authData
          ? _value._authData
          : authData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      attemptsRemaining: freezed == attemptsRemaining
          ? _value.attemptsRemaining
          : attemptsRemaining // ignore: cast_nullable_to_non_nullable
              as int?,
      device: freezed == device
          ? _value.device
          : device // ignore: cast_nullable_to_non_nullable
              as String?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      authHandlerId: freezed == authHandlerId
          ? _value.authHandlerId
          : authHandlerId // ignore: cast_nullable_to_non_nullable
              as String?,
      requiredData: freezed == requiredData
          ? _value._requiredData
          : requiredData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkAuthHandlerStatusImpl extends _GdkAuthHandlerStatus {
  const _$GdkAuthHandlerStatusImpl(
      {required this.status,
      this.result,
      final List<String>? methods,
      this.error,
      this.action,
      @JsonKey(name: 'auth_data') final Map<String, dynamic>? authData,
      @JsonKey(name: 'attempts_remaining') this.attemptsRemaining,
      this.device,
      this.message,
      this.authHandlerId,
      @JsonKey(name: 'required_data') final Map<String, dynamic>? requiredData})
      : _methods = methods,
        _authData = authData,
        _requiredData = requiredData,
        super._();

  factory _$GdkAuthHandlerStatusImpl.fromJson(Map<String, dynamic> json) =>
      _$$GdkAuthHandlerStatusImplFromJson(json);

  @override
  final GdkAuthHandlerStatusEnum status;
  @override
  final GdkAuthHandlerStatusResult? result;
  final List<String>? _methods;
  @override
  List<String>? get methods {
    final value = _methods;
    if (value == null) return null;
    if (_methods is EqualUnmodifiableListView) return _methods;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? error;
  @override
  final String? action;
  final Map<String, dynamic>? _authData;
  @override
  @JsonKey(name: 'auth_data')
  Map<String, dynamic>? get authData {
    final value = _authData;
    if (value == null) return null;
    if (_authData is EqualUnmodifiableMapView) return _authData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey(name: 'attempts_remaining')
  final int? attemptsRemaining;
  @override
  final String? device;
  @override
  final String? message;
  @override
  final String? authHandlerId;
  final Map<String, dynamic>? _requiredData;
  @override
  @JsonKey(name: 'required_data')
  Map<String, dynamic>? get requiredData {
    final value = _requiredData;
    if (value == null) return null;
    if (_requiredData is EqualUnmodifiableMapView) return _requiredData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'GdkAuthHandlerStatus(status: $status, result: $result, methods: $methods, error: $error, action: $action, authData: $authData, attemptsRemaining: $attemptsRemaining, device: $device, message: $message, authHandlerId: $authHandlerId, requiredData: $requiredData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkAuthHandlerStatusImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.result, result) || other.result == result) &&
            const DeepCollectionEquality().equals(other._methods, _methods) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.action, action) || other.action == action) &&
            const DeepCollectionEquality().equals(other._authData, _authData) &&
            (identical(other.attemptsRemaining, attemptsRemaining) ||
                other.attemptsRemaining == attemptsRemaining) &&
            (identical(other.device, device) || other.device == device) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.authHandlerId, authHandlerId) ||
                other.authHandlerId == authHandlerId) &&
            const DeepCollectionEquality()
                .equals(other._requiredData, _requiredData));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      status,
      result,
      const DeepCollectionEquality().hash(_methods),
      error,
      action,
      const DeepCollectionEquality().hash(_authData),
      attemptsRemaining,
      device,
      message,
      authHandlerId,
      const DeepCollectionEquality().hash(_requiredData));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkAuthHandlerStatusImplCopyWith<_$GdkAuthHandlerStatusImpl>
      get copyWith =>
          __$$GdkAuthHandlerStatusImplCopyWithImpl<_$GdkAuthHandlerStatusImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkAuthHandlerStatusImplToJson(
      this,
    );
  }
}

abstract class _GdkAuthHandlerStatus extends GdkAuthHandlerStatus {
  const factory _GdkAuthHandlerStatus(
      {required final GdkAuthHandlerStatusEnum status,
      final GdkAuthHandlerStatusResult? result,
      final List<String>? methods,
      final String? error,
      final String? action,
      @JsonKey(name: 'auth_data') final Map<String, dynamic>? authData,
      @JsonKey(name: 'attempts_remaining') final int? attemptsRemaining,
      final String? device,
      final String? message,
      final String? authHandlerId,
      @JsonKey(name: 'required_data')
      final Map<String, dynamic>? requiredData}) = _$GdkAuthHandlerStatusImpl;
  const _GdkAuthHandlerStatus._() : super._();

  factory _GdkAuthHandlerStatus.fromJson(Map<String, dynamic> json) =
      _$GdkAuthHandlerStatusImpl.fromJson;

  @override
  GdkAuthHandlerStatusEnum get status;
  @override
  GdkAuthHandlerStatusResult? get result;
  @override
  List<String>? get methods;
  @override
  String? get error;
  @override
  String? get action;
  @override
  @JsonKey(name: 'auth_data')
  Map<String, dynamic>? get authData;
  @override
  @JsonKey(name: 'attempts_remaining')
  int? get attemptsRemaining;
  @override
  String? get device;
  @override
  String? get message;
  @override
  String? get authHandlerId;
  @override
  @JsonKey(name: 'required_data')
  Map<String, dynamic>? get requiredData;
  @override
  @JsonKey(ignore: true)
  _$$GdkAuthHandlerStatusImplCopyWith<_$GdkAuthHandlerStatusImpl>
      get copyWith => throw _privateConstructorUsedError;
}

GdkGetTransactionsDetails _$GdkGetTransactionsDetailsFromJson(
    Map<String, dynamic> json) {
  return _GdkGetTransactionsDetails.fromJson(json);
}

/// @nodoc
mixin _$GdkGetTransactionsDetails {
  int? get subaccount => throw _privateConstructorUsedError;
  int? get first => throw _privateConstructorUsedError;
  int? get count => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkGetTransactionsDetailsCopyWith<GdkGetTransactionsDetails> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkGetTransactionsDetailsCopyWith<$Res> {
  factory $GdkGetTransactionsDetailsCopyWith(GdkGetTransactionsDetails value,
          $Res Function(GdkGetTransactionsDetails) then) =
      _$GdkGetTransactionsDetailsCopyWithImpl<$Res, GdkGetTransactionsDetails>;
  @useResult
  $Res call({int? subaccount, int? first, int? count});
}

/// @nodoc
class _$GdkGetTransactionsDetailsCopyWithImpl<$Res,
        $Val extends GdkGetTransactionsDetails>
    implements $GdkGetTransactionsDetailsCopyWith<$Res> {
  _$GdkGetTransactionsDetailsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subaccount = freezed,
    Object? first = freezed,
    Object? count = freezed,
  }) {
    return _then(_value.copyWith(
      subaccount: freezed == subaccount
          ? _value.subaccount
          : subaccount // ignore: cast_nullable_to_non_nullable
              as int?,
      first: freezed == first
          ? _value.first
          : first // ignore: cast_nullable_to_non_nullable
              as int?,
      count: freezed == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GdkGetTransactionsDetailsImplCopyWith<$Res>
    implements $GdkGetTransactionsDetailsCopyWith<$Res> {
  factory _$$GdkGetTransactionsDetailsImplCopyWith(
          _$GdkGetTransactionsDetailsImpl value,
          $Res Function(_$GdkGetTransactionsDetailsImpl) then) =
      __$$GdkGetTransactionsDetailsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int? subaccount, int? first, int? count});
}

/// @nodoc
class __$$GdkGetTransactionsDetailsImplCopyWithImpl<$Res>
    extends _$GdkGetTransactionsDetailsCopyWithImpl<$Res,
        _$GdkGetTransactionsDetailsImpl>
    implements _$$GdkGetTransactionsDetailsImplCopyWith<$Res> {
  __$$GdkGetTransactionsDetailsImplCopyWithImpl(
      _$GdkGetTransactionsDetailsImpl _value,
      $Res Function(_$GdkGetTransactionsDetailsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subaccount = freezed,
    Object? first = freezed,
    Object? count = freezed,
  }) {
    return _then(_$GdkGetTransactionsDetailsImpl(
      subaccount: freezed == subaccount
          ? _value.subaccount
          : subaccount // ignore: cast_nullable_to_non_nullable
              as int?,
      first: freezed == first
          ? _value.first
          : first // ignore: cast_nullable_to_non_nullable
              as int?,
      count: freezed == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkGetTransactionsDetailsImpl extends _GdkGetTransactionsDetails {
  const _$GdkGetTransactionsDetailsImpl(
      {this.subaccount = 1, this.first = 0, this.count = 100})
      : super._();

  factory _$GdkGetTransactionsDetailsImpl.fromJson(Map<String, dynamic> json) =>
      _$$GdkGetTransactionsDetailsImplFromJson(json);

  @override
  @JsonKey()
  final int? subaccount;
  @override
  @JsonKey()
  final int? first;
  @override
  @JsonKey()
  final int? count;

  @override
  String toString() {
    return 'GdkGetTransactionsDetails(subaccount: $subaccount, first: $first, count: $count)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkGetTransactionsDetailsImpl &&
            (identical(other.subaccount, subaccount) ||
                other.subaccount == subaccount) &&
            (identical(other.first, first) || other.first == first) &&
            (identical(other.count, count) || other.count == count));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, subaccount, first, count);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkGetTransactionsDetailsImplCopyWith<_$GdkGetTransactionsDetailsImpl>
      get copyWith => __$$GdkGetTransactionsDetailsImplCopyWithImpl<
          _$GdkGetTransactionsDetailsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkGetTransactionsDetailsImplToJson(
      this,
    );
  }
}

abstract class _GdkGetTransactionsDetails extends GdkGetTransactionsDetails {
  const factory _GdkGetTransactionsDetails(
      {final int? subaccount,
      final int? first,
      final int? count}) = _$GdkGetTransactionsDetailsImpl;
  const _GdkGetTransactionsDetails._() : super._();

  factory _GdkGetTransactionsDetails.fromJson(Map<String, dynamic> json) =
      _$GdkGetTransactionsDetailsImpl.fromJson;

  @override
  int? get subaccount;
  @override
  int? get first;
  @override
  int? get count;
  @override
  @JsonKey(ignore: true)
  _$$GdkGetTransactionsDetailsImplCopyWith<_$GdkGetTransactionsDetailsImpl>
      get copyWith => throw _privateConstructorUsedError;
}

GdkTransactionInOut _$GdkTransactionInOutFromJson(Map<String, dynamic> json) {
  return _GdkTransactionInOut.fromJson(json);
}

/// @nodoc
mixin _$GdkTransactionInOut {
  String? get address => throw _privateConstructorUsedError;
  @JsonKey(name: 'address_type')
  String? get addressType => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_output')
  bool? get isOutput => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_relevant')
  bool? get isRelevant => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_spent')
  bool? get isSpent => throw _privateConstructorUsedError;
  int? get pointer => throw _privateConstructorUsedError;
  @JsonKey(name: 'pt_idx')
  int? get ptIdx => throw _privateConstructorUsedError;
  int? get satoshi => throw _privateConstructorUsedError;
  @JsonKey(name: 'script_type')
  int? get scriptType => throw _privateConstructorUsedError;
  int? get subaccount => throw _privateConstructorUsedError;
  int? get subtype => throw _privateConstructorUsedError;
  @JsonKey(name: 'asset_id')
  String? get assetId => throw _privateConstructorUsedError;
  @JsonKey(name: 'assetblinder')
  String? get assetBlinder => throw _privateConstructorUsedError;
  @JsonKey(name: 'amountblinder')
  String? get amountBlinder => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkTransactionInOutCopyWith<GdkTransactionInOut> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkTransactionInOutCopyWith<$Res> {
  factory $GdkTransactionInOutCopyWith(
          GdkTransactionInOut value, $Res Function(GdkTransactionInOut) then) =
      _$GdkTransactionInOutCopyWithImpl<$Res, GdkTransactionInOut>;
  @useResult
  $Res call(
      {String? address,
      @JsonKey(name: 'address_type') String? addressType,
      @JsonKey(name: 'is_output') bool? isOutput,
      @JsonKey(name: 'is_relevant') bool? isRelevant,
      @JsonKey(name: 'is_spent') bool? isSpent,
      int? pointer,
      @JsonKey(name: 'pt_idx') int? ptIdx,
      int? satoshi,
      @JsonKey(name: 'script_type') int? scriptType,
      int? subaccount,
      int? subtype,
      @JsonKey(name: 'asset_id') String? assetId,
      @JsonKey(name: 'assetblinder') String? assetBlinder,
      @JsonKey(name: 'amountblinder') String? amountBlinder});
}

/// @nodoc
class _$GdkTransactionInOutCopyWithImpl<$Res, $Val extends GdkTransactionInOut>
    implements $GdkTransactionInOutCopyWith<$Res> {
  _$GdkTransactionInOutCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? address = freezed,
    Object? addressType = freezed,
    Object? isOutput = freezed,
    Object? isRelevant = freezed,
    Object? isSpent = freezed,
    Object? pointer = freezed,
    Object? ptIdx = freezed,
    Object? satoshi = freezed,
    Object? scriptType = freezed,
    Object? subaccount = freezed,
    Object? subtype = freezed,
    Object? assetId = freezed,
    Object? assetBlinder = freezed,
    Object? amountBlinder = freezed,
  }) {
    return _then(_value.copyWith(
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      addressType: freezed == addressType
          ? _value.addressType
          : addressType // ignore: cast_nullable_to_non_nullable
              as String?,
      isOutput: freezed == isOutput
          ? _value.isOutput
          : isOutput // ignore: cast_nullable_to_non_nullable
              as bool?,
      isRelevant: freezed == isRelevant
          ? _value.isRelevant
          : isRelevant // ignore: cast_nullable_to_non_nullable
              as bool?,
      isSpent: freezed == isSpent
          ? _value.isSpent
          : isSpent // ignore: cast_nullable_to_non_nullable
              as bool?,
      pointer: freezed == pointer
          ? _value.pointer
          : pointer // ignore: cast_nullable_to_non_nullable
              as int?,
      ptIdx: freezed == ptIdx
          ? _value.ptIdx
          : ptIdx // ignore: cast_nullable_to_non_nullable
              as int?,
      satoshi: freezed == satoshi
          ? _value.satoshi
          : satoshi // ignore: cast_nullable_to_non_nullable
              as int?,
      scriptType: freezed == scriptType
          ? _value.scriptType
          : scriptType // ignore: cast_nullable_to_non_nullable
              as int?,
      subaccount: freezed == subaccount
          ? _value.subaccount
          : subaccount // ignore: cast_nullable_to_non_nullable
              as int?,
      subtype: freezed == subtype
          ? _value.subtype
          : subtype // ignore: cast_nullable_to_non_nullable
              as int?,
      assetId: freezed == assetId
          ? _value.assetId
          : assetId // ignore: cast_nullable_to_non_nullable
              as String?,
      assetBlinder: freezed == assetBlinder
          ? _value.assetBlinder
          : assetBlinder // ignore: cast_nullable_to_non_nullable
              as String?,
      amountBlinder: freezed == amountBlinder
          ? _value.amountBlinder
          : amountBlinder // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GdkTransactionInOutImplCopyWith<$Res>
    implements $GdkTransactionInOutCopyWith<$Res> {
  factory _$$GdkTransactionInOutImplCopyWith(_$GdkTransactionInOutImpl value,
          $Res Function(_$GdkTransactionInOutImpl) then) =
      __$$GdkTransactionInOutImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? address,
      @JsonKey(name: 'address_type') String? addressType,
      @JsonKey(name: 'is_output') bool? isOutput,
      @JsonKey(name: 'is_relevant') bool? isRelevant,
      @JsonKey(name: 'is_spent') bool? isSpent,
      int? pointer,
      @JsonKey(name: 'pt_idx') int? ptIdx,
      int? satoshi,
      @JsonKey(name: 'script_type') int? scriptType,
      int? subaccount,
      int? subtype,
      @JsonKey(name: 'asset_id') String? assetId,
      @JsonKey(name: 'assetblinder') String? assetBlinder,
      @JsonKey(name: 'amountblinder') String? amountBlinder});
}

/// @nodoc
class __$$GdkTransactionInOutImplCopyWithImpl<$Res>
    extends _$GdkTransactionInOutCopyWithImpl<$Res, _$GdkTransactionInOutImpl>
    implements _$$GdkTransactionInOutImplCopyWith<$Res> {
  __$$GdkTransactionInOutImplCopyWithImpl(_$GdkTransactionInOutImpl _value,
      $Res Function(_$GdkTransactionInOutImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? address = freezed,
    Object? addressType = freezed,
    Object? isOutput = freezed,
    Object? isRelevant = freezed,
    Object? isSpent = freezed,
    Object? pointer = freezed,
    Object? ptIdx = freezed,
    Object? satoshi = freezed,
    Object? scriptType = freezed,
    Object? subaccount = freezed,
    Object? subtype = freezed,
    Object? assetId = freezed,
    Object? assetBlinder = freezed,
    Object? amountBlinder = freezed,
  }) {
    return _then(_$GdkTransactionInOutImpl(
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      addressType: freezed == addressType
          ? _value.addressType
          : addressType // ignore: cast_nullable_to_non_nullable
              as String?,
      isOutput: freezed == isOutput
          ? _value.isOutput
          : isOutput // ignore: cast_nullable_to_non_nullable
              as bool?,
      isRelevant: freezed == isRelevant
          ? _value.isRelevant
          : isRelevant // ignore: cast_nullable_to_non_nullable
              as bool?,
      isSpent: freezed == isSpent
          ? _value.isSpent
          : isSpent // ignore: cast_nullable_to_non_nullable
              as bool?,
      pointer: freezed == pointer
          ? _value.pointer
          : pointer // ignore: cast_nullable_to_non_nullable
              as int?,
      ptIdx: freezed == ptIdx
          ? _value.ptIdx
          : ptIdx // ignore: cast_nullable_to_non_nullable
              as int?,
      satoshi: freezed == satoshi
          ? _value.satoshi
          : satoshi // ignore: cast_nullable_to_non_nullable
              as int?,
      scriptType: freezed == scriptType
          ? _value.scriptType
          : scriptType // ignore: cast_nullable_to_non_nullable
              as int?,
      subaccount: freezed == subaccount
          ? _value.subaccount
          : subaccount // ignore: cast_nullable_to_non_nullable
              as int?,
      subtype: freezed == subtype
          ? _value.subtype
          : subtype // ignore: cast_nullable_to_non_nullable
              as int?,
      assetId: freezed == assetId
          ? _value.assetId
          : assetId // ignore: cast_nullable_to_non_nullable
              as String?,
      assetBlinder: freezed == assetBlinder
          ? _value.assetBlinder
          : assetBlinder // ignore: cast_nullable_to_non_nullable
              as String?,
      amountBlinder: freezed == amountBlinder
          ? _value.amountBlinder
          : amountBlinder // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkTransactionInOutImpl implements _GdkTransactionInOut {
  const _$GdkTransactionInOutImpl(
      {this.address,
      @JsonKey(name: 'address_type') this.addressType,
      @JsonKey(name: 'is_output') this.isOutput,
      @JsonKey(name: 'is_relevant') this.isRelevant,
      @JsonKey(name: 'is_spent') this.isSpent,
      this.pointer,
      @JsonKey(name: 'pt_idx') this.ptIdx,
      this.satoshi,
      @JsonKey(name: 'script_type') this.scriptType,
      this.subaccount = 1,
      this.subtype,
      @JsonKey(name: 'asset_id') this.assetId,
      @JsonKey(name: 'assetblinder') this.assetBlinder,
      @JsonKey(name: 'amountblinder') this.amountBlinder});

  factory _$GdkTransactionInOutImpl.fromJson(Map<String, dynamic> json) =>
      _$$GdkTransactionInOutImplFromJson(json);

  @override
  final String? address;
  @override
  @JsonKey(name: 'address_type')
  final String? addressType;
  @override
  @JsonKey(name: 'is_output')
  final bool? isOutput;
  @override
  @JsonKey(name: 'is_relevant')
  final bool? isRelevant;
  @override
  @JsonKey(name: 'is_spent')
  final bool? isSpent;
  @override
  final int? pointer;
  @override
  @JsonKey(name: 'pt_idx')
  final int? ptIdx;
  @override
  final int? satoshi;
  @override
  @JsonKey(name: 'script_type')
  final int? scriptType;
  @override
  @JsonKey()
  final int? subaccount;
  @override
  final int? subtype;
  @override
  @JsonKey(name: 'asset_id')
  final String? assetId;
  @override
  @JsonKey(name: 'assetblinder')
  final String? assetBlinder;
  @override
  @JsonKey(name: 'amountblinder')
  final String? amountBlinder;

  @override
  String toString() {
    return 'GdkTransactionInOut(address: $address, addressType: $addressType, isOutput: $isOutput, isRelevant: $isRelevant, isSpent: $isSpent, pointer: $pointer, ptIdx: $ptIdx, satoshi: $satoshi, scriptType: $scriptType, subaccount: $subaccount, subtype: $subtype, assetId: $assetId, assetBlinder: $assetBlinder, amountBlinder: $amountBlinder)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkTransactionInOutImpl &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.addressType, addressType) ||
                other.addressType == addressType) &&
            (identical(other.isOutput, isOutput) ||
                other.isOutput == isOutput) &&
            (identical(other.isRelevant, isRelevant) ||
                other.isRelevant == isRelevant) &&
            (identical(other.isSpent, isSpent) || other.isSpent == isSpent) &&
            (identical(other.pointer, pointer) || other.pointer == pointer) &&
            (identical(other.ptIdx, ptIdx) || other.ptIdx == ptIdx) &&
            (identical(other.satoshi, satoshi) || other.satoshi == satoshi) &&
            (identical(other.scriptType, scriptType) ||
                other.scriptType == scriptType) &&
            (identical(other.subaccount, subaccount) ||
                other.subaccount == subaccount) &&
            (identical(other.subtype, subtype) || other.subtype == subtype) &&
            (identical(other.assetId, assetId) || other.assetId == assetId) &&
            (identical(other.assetBlinder, assetBlinder) ||
                other.assetBlinder == assetBlinder) &&
            (identical(other.amountBlinder, amountBlinder) ||
                other.amountBlinder == amountBlinder));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      address,
      addressType,
      isOutput,
      isRelevant,
      isSpent,
      pointer,
      ptIdx,
      satoshi,
      scriptType,
      subaccount,
      subtype,
      assetId,
      assetBlinder,
      amountBlinder);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkTransactionInOutImplCopyWith<_$GdkTransactionInOutImpl> get copyWith =>
      __$$GdkTransactionInOutImplCopyWithImpl<_$GdkTransactionInOutImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkTransactionInOutImplToJson(
      this,
    );
  }
}

abstract class _GdkTransactionInOut implements GdkTransactionInOut {
  const factory _GdkTransactionInOut(
          {final String? address,
          @JsonKey(name: 'address_type') final String? addressType,
          @JsonKey(name: 'is_output') final bool? isOutput,
          @JsonKey(name: 'is_relevant') final bool? isRelevant,
          @JsonKey(name: 'is_spent') final bool? isSpent,
          final int? pointer,
          @JsonKey(name: 'pt_idx') final int? ptIdx,
          final int? satoshi,
          @JsonKey(name: 'script_type') final int? scriptType,
          final int? subaccount,
          final int? subtype,
          @JsonKey(name: 'asset_id') final String? assetId,
          @JsonKey(name: 'assetblinder') final String? assetBlinder,
          @JsonKey(name: 'amountblinder') final String? amountBlinder}) =
      _$GdkTransactionInOutImpl;

  factory _GdkTransactionInOut.fromJson(Map<String, dynamic> json) =
      _$GdkTransactionInOutImpl.fromJson;

  @override
  String? get address;
  @override
  @JsonKey(name: 'address_type')
  String? get addressType;
  @override
  @JsonKey(name: 'is_output')
  bool? get isOutput;
  @override
  @JsonKey(name: 'is_relevant')
  bool? get isRelevant;
  @override
  @JsonKey(name: 'is_spent')
  bool? get isSpent;
  @override
  int? get pointer;
  @override
  @JsonKey(name: 'pt_idx')
  int? get ptIdx;
  @override
  int? get satoshi;
  @override
  @JsonKey(name: 'script_type')
  int? get scriptType;
  @override
  int? get subaccount;
  @override
  int? get subtype;
  @override
  @JsonKey(name: 'asset_id')
  String? get assetId;
  @override
  @JsonKey(name: 'assetblinder')
  String? get assetBlinder;
  @override
  @JsonKey(name: 'amountblinder')
  String? get amountBlinder;
  @override
  @JsonKey(ignore: true)
  _$$GdkTransactionInOutImplCopyWith<_$GdkTransactionInOutImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GdkTransaction _$GdkTransactionFromJson(Map<String, dynamic> json) {
  return _GdkTransaction.fromJson(json);
}

/// @nodoc
mixin _$GdkTransaction {
  List<String>? get addressees => throw _privateConstructorUsedError;
  @JsonKey(name: 'block_height')
  int? get blockHeight => throw _privateConstructorUsedError;
  @JsonKey(name: 'calculated_fee_rate')
  int? get calculatedFeeRate => throw _privateConstructorUsedError;
  @JsonKey(name: 'can_cpfp')
  bool? get canCpfp => throw _privateConstructorUsedError;
  @JsonKey(name: 'can_rbf')
  bool? get canRbf => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at_ts')
  int? get createdAtTs => throw _privateConstructorUsedError;
  int? get fee => throw _privateConstructorUsedError;
  @JsonKey(name: 'fee_rate')
  int? get feeRate => throw _privateConstructorUsedError;
  @JsonKey(name: 'has_payment_request')
  bool? get hasPaymentRequest => throw _privateConstructorUsedError;
  List<GdkTransactionInOut>? get inputs => throw _privateConstructorUsedError;
  bool? get instant => throw _privateConstructorUsedError;
  String? get memo => throw _privateConstructorUsedError;
  List<GdkTransactionInOut>? get outputs => throw _privateConstructorUsedError;
  @JsonKey(name: 'rbf_optin')
  bool? get rbfOptin => throw _privateConstructorUsedError;
  Map<String, int>? get satoshi => throw _privateConstructorUsedError;
  @JsonKey(name: 'server_signed')
  bool? get serverSigned => throw _privateConstructorUsedError;
  @JsonKey(name: 'spv_verified')
  String? get spvVerified => throw _privateConstructorUsedError;
  String? get transaction => throw _privateConstructorUsedError;
  @JsonKey(name: 'transaction_locktime')
  int? get transactionLocktime => throw _privateConstructorUsedError;
  @JsonKey(name: 'transaction_outputs')
  List<String>? get transactionOutputs => throw _privateConstructorUsedError;
  @JsonKey(name: 'transaction_size')
  int? get transactionSize => throw _privateConstructorUsedError;
  @JsonKey(name: 'transaction_version')
  int? get transactionVersion => throw _privateConstructorUsedError;
  @JsonKey(name: 'transaction_vsize')
  int? get transactionVsize => throw _privateConstructorUsedError;
  @JsonKey(name: 'transaction_weight')
  int? get transactionWeight => throw _privateConstructorUsedError;
  String? get txhash => throw _privateConstructorUsedError;
  GdkTransactionTypeEnum? get type => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_signed')
  bool? get userSigned => throw _privateConstructorUsedError;
  int? get vsize => throw _privateConstructorUsedError;
  String? get swapOutgoingAssetId => throw _privateConstructorUsedError;
  int? get swapOutgoingSatoshi => throw _privateConstructorUsedError;
  String? get swapIncomingAssetId => throw _privateConstructorUsedError;
  int? get swapIncomingSatoshi => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkTransactionCopyWith<GdkTransaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkTransactionCopyWith<$Res> {
  factory $GdkTransactionCopyWith(
          GdkTransaction value, $Res Function(GdkTransaction) then) =
      _$GdkTransactionCopyWithImpl<$Res, GdkTransaction>;
  @useResult
  $Res call(
      {List<String>? addressees,
      @JsonKey(name: 'block_height') int? blockHeight,
      @JsonKey(name: 'calculated_fee_rate') int? calculatedFeeRate,
      @JsonKey(name: 'can_cpfp') bool? canCpfp,
      @JsonKey(name: 'can_rbf') bool? canRbf,
      @JsonKey(name: 'created_at_ts') int? createdAtTs,
      int? fee,
      @JsonKey(name: 'fee_rate') int? feeRate,
      @JsonKey(name: 'has_payment_request') bool? hasPaymentRequest,
      List<GdkTransactionInOut>? inputs,
      bool? instant,
      String? memo,
      List<GdkTransactionInOut>? outputs,
      @JsonKey(name: 'rbf_optin') bool? rbfOptin,
      Map<String, int>? satoshi,
      @JsonKey(name: 'server_signed') bool? serverSigned,
      @JsonKey(name: 'spv_verified') String? spvVerified,
      String? transaction,
      @JsonKey(name: 'transaction_locktime') int? transactionLocktime,
      @JsonKey(name: 'transaction_outputs') List<String>? transactionOutputs,
      @JsonKey(name: 'transaction_size') int? transactionSize,
      @JsonKey(name: 'transaction_version') int? transactionVersion,
      @JsonKey(name: 'transaction_vsize') int? transactionVsize,
      @JsonKey(name: 'transaction_weight') int? transactionWeight,
      String? txhash,
      GdkTransactionTypeEnum? type,
      @JsonKey(name: 'user_signed') bool? userSigned,
      int? vsize,
      String? swapOutgoingAssetId,
      int? swapOutgoingSatoshi,
      String? swapIncomingAssetId,
      int? swapIncomingSatoshi});
}

/// @nodoc
class _$GdkTransactionCopyWithImpl<$Res, $Val extends GdkTransaction>
    implements $GdkTransactionCopyWith<$Res> {
  _$GdkTransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? addressees = freezed,
    Object? blockHeight = freezed,
    Object? calculatedFeeRate = freezed,
    Object? canCpfp = freezed,
    Object? canRbf = freezed,
    Object? createdAtTs = freezed,
    Object? fee = freezed,
    Object? feeRate = freezed,
    Object? hasPaymentRequest = freezed,
    Object? inputs = freezed,
    Object? instant = freezed,
    Object? memo = freezed,
    Object? outputs = freezed,
    Object? rbfOptin = freezed,
    Object? satoshi = freezed,
    Object? serverSigned = freezed,
    Object? spvVerified = freezed,
    Object? transaction = freezed,
    Object? transactionLocktime = freezed,
    Object? transactionOutputs = freezed,
    Object? transactionSize = freezed,
    Object? transactionVersion = freezed,
    Object? transactionVsize = freezed,
    Object? transactionWeight = freezed,
    Object? txhash = freezed,
    Object? type = freezed,
    Object? userSigned = freezed,
    Object? vsize = freezed,
    Object? swapOutgoingAssetId = freezed,
    Object? swapOutgoingSatoshi = freezed,
    Object? swapIncomingAssetId = freezed,
    Object? swapIncomingSatoshi = freezed,
  }) {
    return _then(_value.copyWith(
      addressees: freezed == addressees
          ? _value.addressees
          : addressees // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      blockHeight: freezed == blockHeight
          ? _value.blockHeight
          : blockHeight // ignore: cast_nullable_to_non_nullable
              as int?,
      calculatedFeeRate: freezed == calculatedFeeRate
          ? _value.calculatedFeeRate
          : calculatedFeeRate // ignore: cast_nullable_to_non_nullable
              as int?,
      canCpfp: freezed == canCpfp
          ? _value.canCpfp
          : canCpfp // ignore: cast_nullable_to_non_nullable
              as bool?,
      canRbf: freezed == canRbf
          ? _value.canRbf
          : canRbf // ignore: cast_nullable_to_non_nullable
              as bool?,
      createdAtTs: freezed == createdAtTs
          ? _value.createdAtTs
          : createdAtTs // ignore: cast_nullable_to_non_nullable
              as int?,
      fee: freezed == fee
          ? _value.fee
          : fee // ignore: cast_nullable_to_non_nullable
              as int?,
      feeRate: freezed == feeRate
          ? _value.feeRate
          : feeRate // ignore: cast_nullable_to_non_nullable
              as int?,
      hasPaymentRequest: freezed == hasPaymentRequest
          ? _value.hasPaymentRequest
          : hasPaymentRequest // ignore: cast_nullable_to_non_nullable
              as bool?,
      inputs: freezed == inputs
          ? _value.inputs
          : inputs // ignore: cast_nullable_to_non_nullable
              as List<GdkTransactionInOut>?,
      instant: freezed == instant
          ? _value.instant
          : instant // ignore: cast_nullable_to_non_nullable
              as bool?,
      memo: freezed == memo
          ? _value.memo
          : memo // ignore: cast_nullable_to_non_nullable
              as String?,
      outputs: freezed == outputs
          ? _value.outputs
          : outputs // ignore: cast_nullable_to_non_nullable
              as List<GdkTransactionInOut>?,
      rbfOptin: freezed == rbfOptin
          ? _value.rbfOptin
          : rbfOptin // ignore: cast_nullable_to_non_nullable
              as bool?,
      satoshi: freezed == satoshi
          ? _value.satoshi
          : satoshi // ignore: cast_nullable_to_non_nullable
              as Map<String, int>?,
      serverSigned: freezed == serverSigned
          ? _value.serverSigned
          : serverSigned // ignore: cast_nullable_to_non_nullable
              as bool?,
      spvVerified: freezed == spvVerified
          ? _value.spvVerified
          : spvVerified // ignore: cast_nullable_to_non_nullable
              as String?,
      transaction: freezed == transaction
          ? _value.transaction
          : transaction // ignore: cast_nullable_to_non_nullable
              as String?,
      transactionLocktime: freezed == transactionLocktime
          ? _value.transactionLocktime
          : transactionLocktime // ignore: cast_nullable_to_non_nullable
              as int?,
      transactionOutputs: freezed == transactionOutputs
          ? _value.transactionOutputs
          : transactionOutputs // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      transactionSize: freezed == transactionSize
          ? _value.transactionSize
          : transactionSize // ignore: cast_nullable_to_non_nullable
              as int?,
      transactionVersion: freezed == transactionVersion
          ? _value.transactionVersion
          : transactionVersion // ignore: cast_nullable_to_non_nullable
              as int?,
      transactionVsize: freezed == transactionVsize
          ? _value.transactionVsize
          : transactionVsize // ignore: cast_nullable_to_non_nullable
              as int?,
      transactionWeight: freezed == transactionWeight
          ? _value.transactionWeight
          : transactionWeight // ignore: cast_nullable_to_non_nullable
              as int?,
      txhash: freezed == txhash
          ? _value.txhash
          : txhash // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as GdkTransactionTypeEnum?,
      userSigned: freezed == userSigned
          ? _value.userSigned
          : userSigned // ignore: cast_nullable_to_non_nullable
              as bool?,
      vsize: freezed == vsize
          ? _value.vsize
          : vsize // ignore: cast_nullable_to_non_nullable
              as int?,
      swapOutgoingAssetId: freezed == swapOutgoingAssetId
          ? _value.swapOutgoingAssetId
          : swapOutgoingAssetId // ignore: cast_nullable_to_non_nullable
              as String?,
      swapOutgoingSatoshi: freezed == swapOutgoingSatoshi
          ? _value.swapOutgoingSatoshi
          : swapOutgoingSatoshi // ignore: cast_nullable_to_non_nullable
              as int?,
      swapIncomingAssetId: freezed == swapIncomingAssetId
          ? _value.swapIncomingAssetId
          : swapIncomingAssetId // ignore: cast_nullable_to_non_nullable
              as String?,
      swapIncomingSatoshi: freezed == swapIncomingSatoshi
          ? _value.swapIncomingSatoshi
          : swapIncomingSatoshi // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GdkTransactionImplCopyWith<$Res>
    implements $GdkTransactionCopyWith<$Res> {
  factory _$$GdkTransactionImplCopyWith(_$GdkTransactionImpl value,
          $Res Function(_$GdkTransactionImpl) then) =
      __$$GdkTransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<String>? addressees,
      @JsonKey(name: 'block_height') int? blockHeight,
      @JsonKey(name: 'calculated_fee_rate') int? calculatedFeeRate,
      @JsonKey(name: 'can_cpfp') bool? canCpfp,
      @JsonKey(name: 'can_rbf') bool? canRbf,
      @JsonKey(name: 'created_at_ts') int? createdAtTs,
      int? fee,
      @JsonKey(name: 'fee_rate') int? feeRate,
      @JsonKey(name: 'has_payment_request') bool? hasPaymentRequest,
      List<GdkTransactionInOut>? inputs,
      bool? instant,
      String? memo,
      List<GdkTransactionInOut>? outputs,
      @JsonKey(name: 'rbf_optin') bool? rbfOptin,
      Map<String, int>? satoshi,
      @JsonKey(name: 'server_signed') bool? serverSigned,
      @JsonKey(name: 'spv_verified') String? spvVerified,
      String? transaction,
      @JsonKey(name: 'transaction_locktime') int? transactionLocktime,
      @JsonKey(name: 'transaction_outputs') List<String>? transactionOutputs,
      @JsonKey(name: 'transaction_size') int? transactionSize,
      @JsonKey(name: 'transaction_version') int? transactionVersion,
      @JsonKey(name: 'transaction_vsize') int? transactionVsize,
      @JsonKey(name: 'transaction_weight') int? transactionWeight,
      String? txhash,
      GdkTransactionTypeEnum? type,
      @JsonKey(name: 'user_signed') bool? userSigned,
      int? vsize,
      String? swapOutgoingAssetId,
      int? swapOutgoingSatoshi,
      String? swapIncomingAssetId,
      int? swapIncomingSatoshi});
}

/// @nodoc
class __$$GdkTransactionImplCopyWithImpl<$Res>
    extends _$GdkTransactionCopyWithImpl<$Res, _$GdkTransactionImpl>
    implements _$$GdkTransactionImplCopyWith<$Res> {
  __$$GdkTransactionImplCopyWithImpl(
      _$GdkTransactionImpl _value, $Res Function(_$GdkTransactionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? addressees = freezed,
    Object? blockHeight = freezed,
    Object? calculatedFeeRate = freezed,
    Object? canCpfp = freezed,
    Object? canRbf = freezed,
    Object? createdAtTs = freezed,
    Object? fee = freezed,
    Object? feeRate = freezed,
    Object? hasPaymentRequest = freezed,
    Object? inputs = freezed,
    Object? instant = freezed,
    Object? memo = freezed,
    Object? outputs = freezed,
    Object? rbfOptin = freezed,
    Object? satoshi = freezed,
    Object? serverSigned = freezed,
    Object? spvVerified = freezed,
    Object? transaction = freezed,
    Object? transactionLocktime = freezed,
    Object? transactionOutputs = freezed,
    Object? transactionSize = freezed,
    Object? transactionVersion = freezed,
    Object? transactionVsize = freezed,
    Object? transactionWeight = freezed,
    Object? txhash = freezed,
    Object? type = freezed,
    Object? userSigned = freezed,
    Object? vsize = freezed,
    Object? swapOutgoingAssetId = freezed,
    Object? swapOutgoingSatoshi = freezed,
    Object? swapIncomingAssetId = freezed,
    Object? swapIncomingSatoshi = freezed,
  }) {
    return _then(_$GdkTransactionImpl(
      addressees: freezed == addressees
          ? _value._addressees
          : addressees // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      blockHeight: freezed == blockHeight
          ? _value.blockHeight
          : blockHeight // ignore: cast_nullable_to_non_nullable
              as int?,
      calculatedFeeRate: freezed == calculatedFeeRate
          ? _value.calculatedFeeRate
          : calculatedFeeRate // ignore: cast_nullable_to_non_nullable
              as int?,
      canCpfp: freezed == canCpfp
          ? _value.canCpfp
          : canCpfp // ignore: cast_nullable_to_non_nullable
              as bool?,
      canRbf: freezed == canRbf
          ? _value.canRbf
          : canRbf // ignore: cast_nullable_to_non_nullable
              as bool?,
      createdAtTs: freezed == createdAtTs
          ? _value.createdAtTs
          : createdAtTs // ignore: cast_nullable_to_non_nullable
              as int?,
      fee: freezed == fee
          ? _value.fee
          : fee // ignore: cast_nullable_to_non_nullable
              as int?,
      feeRate: freezed == feeRate
          ? _value.feeRate
          : feeRate // ignore: cast_nullable_to_non_nullable
              as int?,
      hasPaymentRequest: freezed == hasPaymentRequest
          ? _value.hasPaymentRequest
          : hasPaymentRequest // ignore: cast_nullable_to_non_nullable
              as bool?,
      inputs: freezed == inputs
          ? _value._inputs
          : inputs // ignore: cast_nullable_to_non_nullable
              as List<GdkTransactionInOut>?,
      instant: freezed == instant
          ? _value.instant
          : instant // ignore: cast_nullable_to_non_nullable
              as bool?,
      memo: freezed == memo
          ? _value.memo
          : memo // ignore: cast_nullable_to_non_nullable
              as String?,
      outputs: freezed == outputs
          ? _value._outputs
          : outputs // ignore: cast_nullable_to_non_nullable
              as List<GdkTransactionInOut>?,
      rbfOptin: freezed == rbfOptin
          ? _value.rbfOptin
          : rbfOptin // ignore: cast_nullable_to_non_nullable
              as bool?,
      satoshi: freezed == satoshi
          ? _value._satoshi
          : satoshi // ignore: cast_nullable_to_non_nullable
              as Map<String, int>?,
      serverSigned: freezed == serverSigned
          ? _value.serverSigned
          : serverSigned // ignore: cast_nullable_to_non_nullable
              as bool?,
      spvVerified: freezed == spvVerified
          ? _value.spvVerified
          : spvVerified // ignore: cast_nullable_to_non_nullable
              as String?,
      transaction: freezed == transaction
          ? _value.transaction
          : transaction // ignore: cast_nullable_to_non_nullable
              as String?,
      transactionLocktime: freezed == transactionLocktime
          ? _value.transactionLocktime
          : transactionLocktime // ignore: cast_nullable_to_non_nullable
              as int?,
      transactionOutputs: freezed == transactionOutputs
          ? _value._transactionOutputs
          : transactionOutputs // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      transactionSize: freezed == transactionSize
          ? _value.transactionSize
          : transactionSize // ignore: cast_nullable_to_non_nullable
              as int?,
      transactionVersion: freezed == transactionVersion
          ? _value.transactionVersion
          : transactionVersion // ignore: cast_nullable_to_non_nullable
              as int?,
      transactionVsize: freezed == transactionVsize
          ? _value.transactionVsize
          : transactionVsize // ignore: cast_nullable_to_non_nullable
              as int?,
      transactionWeight: freezed == transactionWeight
          ? _value.transactionWeight
          : transactionWeight // ignore: cast_nullable_to_non_nullable
              as int?,
      txhash: freezed == txhash
          ? _value.txhash
          : txhash // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as GdkTransactionTypeEnum?,
      userSigned: freezed == userSigned
          ? _value.userSigned
          : userSigned // ignore: cast_nullable_to_non_nullable
              as bool?,
      vsize: freezed == vsize
          ? _value.vsize
          : vsize // ignore: cast_nullable_to_non_nullable
              as int?,
      swapOutgoingAssetId: freezed == swapOutgoingAssetId
          ? _value.swapOutgoingAssetId
          : swapOutgoingAssetId // ignore: cast_nullable_to_non_nullable
              as String?,
      swapOutgoingSatoshi: freezed == swapOutgoingSatoshi
          ? _value.swapOutgoingSatoshi
          : swapOutgoingSatoshi // ignore: cast_nullable_to_non_nullable
              as int?,
      swapIncomingAssetId: freezed == swapIncomingAssetId
          ? _value.swapIncomingAssetId
          : swapIncomingAssetId // ignore: cast_nullable_to_non_nullable
              as String?,
      swapIncomingSatoshi: freezed == swapIncomingSatoshi
          ? _value.swapIncomingSatoshi
          : swapIncomingSatoshi // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkTransactionImpl extends _GdkTransaction {
  const _$GdkTransactionImpl(
      {final List<String>? addressees,
      @JsonKey(name: 'block_height') this.blockHeight,
      @JsonKey(name: 'calculated_fee_rate') this.calculatedFeeRate,
      @JsonKey(name: 'can_cpfp') this.canCpfp,
      @JsonKey(name: 'can_rbf') this.canRbf,
      @JsonKey(name: 'created_at_ts') this.createdAtTs,
      this.fee,
      @JsonKey(name: 'fee_rate') this.feeRate,
      @JsonKey(name: 'has_payment_request') this.hasPaymentRequest,
      final List<GdkTransactionInOut>? inputs,
      this.instant,
      this.memo,
      final List<GdkTransactionInOut>? outputs,
      @JsonKey(name: 'rbf_optin') this.rbfOptin,
      final Map<String, int>? satoshi,
      @JsonKey(name: 'server_signed') this.serverSigned,
      @JsonKey(name: 'spv_verified') this.spvVerified,
      this.transaction,
      @JsonKey(name: 'transaction_locktime') this.transactionLocktime,
      @JsonKey(name: 'transaction_outputs')
      final List<String>? transactionOutputs,
      @JsonKey(name: 'transaction_size') this.transactionSize,
      @JsonKey(name: 'transaction_version') this.transactionVersion,
      @JsonKey(name: 'transaction_vsize') this.transactionVsize,
      @JsonKey(name: 'transaction_weight') this.transactionWeight,
      this.txhash,
      this.type,
      @JsonKey(name: 'user_signed') this.userSigned,
      this.vsize,
      this.swapOutgoingAssetId,
      this.swapOutgoingSatoshi,
      this.swapIncomingAssetId,
      this.swapIncomingSatoshi})
      : _addressees = addressees,
        _inputs = inputs,
        _outputs = outputs,
        _satoshi = satoshi,
        _transactionOutputs = transactionOutputs,
        super._();

  factory _$GdkTransactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$GdkTransactionImplFromJson(json);

  final List<String>? _addressees;
  @override
  List<String>? get addressees {
    final value = _addressees;
    if (value == null) return null;
    if (_addressees is EqualUnmodifiableListView) return _addressees;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'block_height')
  final int? blockHeight;
  @override
  @JsonKey(name: 'calculated_fee_rate')
  final int? calculatedFeeRate;
  @override
  @JsonKey(name: 'can_cpfp')
  final bool? canCpfp;
  @override
  @JsonKey(name: 'can_rbf')
  final bool? canRbf;
  @override
  @JsonKey(name: 'created_at_ts')
  final int? createdAtTs;
  @override
  final int? fee;
  @override
  @JsonKey(name: 'fee_rate')
  final int? feeRate;
  @override
  @JsonKey(name: 'has_payment_request')
  final bool? hasPaymentRequest;
  final List<GdkTransactionInOut>? _inputs;
  @override
  List<GdkTransactionInOut>? get inputs {
    final value = _inputs;
    if (value == null) return null;
    if (_inputs is EqualUnmodifiableListView) return _inputs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final bool? instant;
  @override
  final String? memo;
  final List<GdkTransactionInOut>? _outputs;
  @override
  List<GdkTransactionInOut>? get outputs {
    final value = _outputs;
    if (value == null) return null;
    if (_outputs is EqualUnmodifiableListView) return _outputs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'rbf_optin')
  final bool? rbfOptin;
  final Map<String, int>? _satoshi;
  @override
  Map<String, int>? get satoshi {
    final value = _satoshi;
    if (value == null) return null;
    if (_satoshi is EqualUnmodifiableMapView) return _satoshi;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey(name: 'server_signed')
  final bool? serverSigned;
  @override
  @JsonKey(name: 'spv_verified')
  final String? spvVerified;
  @override
  final String? transaction;
  @override
  @JsonKey(name: 'transaction_locktime')
  final int? transactionLocktime;
  final List<String>? _transactionOutputs;
  @override
  @JsonKey(name: 'transaction_outputs')
  List<String>? get transactionOutputs {
    final value = _transactionOutputs;
    if (value == null) return null;
    if (_transactionOutputs is EqualUnmodifiableListView)
      return _transactionOutputs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'transaction_size')
  final int? transactionSize;
  @override
  @JsonKey(name: 'transaction_version')
  final int? transactionVersion;
  @override
  @JsonKey(name: 'transaction_vsize')
  final int? transactionVsize;
  @override
  @JsonKey(name: 'transaction_weight')
  final int? transactionWeight;
  @override
  final String? txhash;
  @override
  final GdkTransactionTypeEnum? type;
  @override
  @JsonKey(name: 'user_signed')
  final bool? userSigned;
  @override
  final int? vsize;
  @override
  final String? swapOutgoingAssetId;
  @override
  final int? swapOutgoingSatoshi;
  @override
  final String? swapIncomingAssetId;
  @override
  final int? swapIncomingSatoshi;

  @override
  String toString() {
    return 'GdkTransaction(addressees: $addressees, blockHeight: $blockHeight, calculatedFeeRate: $calculatedFeeRate, canCpfp: $canCpfp, canRbf: $canRbf, createdAtTs: $createdAtTs, fee: $fee, feeRate: $feeRate, hasPaymentRequest: $hasPaymentRequest, inputs: $inputs, instant: $instant, memo: $memo, outputs: $outputs, rbfOptin: $rbfOptin, satoshi: $satoshi, serverSigned: $serverSigned, spvVerified: $spvVerified, transaction: $transaction, transactionLocktime: $transactionLocktime, transactionOutputs: $transactionOutputs, transactionSize: $transactionSize, transactionVersion: $transactionVersion, transactionVsize: $transactionVsize, transactionWeight: $transactionWeight, txhash: $txhash, type: $type, userSigned: $userSigned, vsize: $vsize, swapOutgoingAssetId: $swapOutgoingAssetId, swapOutgoingSatoshi: $swapOutgoingSatoshi, swapIncomingAssetId: $swapIncomingAssetId, swapIncomingSatoshi: $swapIncomingSatoshi)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkTransactionImpl &&
            const DeepCollectionEquality()
                .equals(other._addressees, _addressees) &&
            (identical(other.blockHeight, blockHeight) ||
                other.blockHeight == blockHeight) &&
            (identical(other.calculatedFeeRate, calculatedFeeRate) ||
                other.calculatedFeeRate == calculatedFeeRate) &&
            (identical(other.canCpfp, canCpfp) || other.canCpfp == canCpfp) &&
            (identical(other.canRbf, canRbf) || other.canRbf == canRbf) &&
            (identical(other.createdAtTs, createdAtTs) ||
                other.createdAtTs == createdAtTs) &&
            (identical(other.fee, fee) || other.fee == fee) &&
            (identical(other.feeRate, feeRate) || other.feeRate == feeRate) &&
            (identical(other.hasPaymentRequest, hasPaymentRequest) ||
                other.hasPaymentRequest == hasPaymentRequest) &&
            const DeepCollectionEquality().equals(other._inputs, _inputs) &&
            (identical(other.instant, instant) || other.instant == instant) &&
            (identical(other.memo, memo) || other.memo == memo) &&
            const DeepCollectionEquality().equals(other._outputs, _outputs) &&
            (identical(other.rbfOptin, rbfOptin) ||
                other.rbfOptin == rbfOptin) &&
            const DeepCollectionEquality().equals(other._satoshi, _satoshi) &&
            (identical(other.serverSigned, serverSigned) ||
                other.serverSigned == serverSigned) &&
            (identical(other.spvVerified, spvVerified) ||
                other.spvVerified == spvVerified) &&
            (identical(other.transaction, transaction) ||
                other.transaction == transaction) &&
            (identical(other.transactionLocktime, transactionLocktime) ||
                other.transactionLocktime == transactionLocktime) &&
            const DeepCollectionEquality()
                .equals(other._transactionOutputs, _transactionOutputs) &&
            (identical(other.transactionSize, transactionSize) ||
                other.transactionSize == transactionSize) &&
            (identical(other.transactionVersion, transactionVersion) ||
                other.transactionVersion == transactionVersion) &&
            (identical(other.transactionVsize, transactionVsize) ||
                other.transactionVsize == transactionVsize) &&
            (identical(other.transactionWeight, transactionWeight) ||
                other.transactionWeight == transactionWeight) &&
            (identical(other.txhash, txhash) || other.txhash == txhash) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.userSigned, userSigned) ||
                other.userSigned == userSigned) &&
            (identical(other.vsize, vsize) || other.vsize == vsize) &&
            (identical(other.swapOutgoingAssetId, swapOutgoingAssetId) ||
                other.swapOutgoingAssetId == swapOutgoingAssetId) &&
            (identical(other.swapOutgoingSatoshi, swapOutgoingSatoshi) ||
                other.swapOutgoingSatoshi == swapOutgoingSatoshi) &&
            (identical(other.swapIncomingAssetId, swapIncomingAssetId) ||
                other.swapIncomingAssetId == swapIncomingAssetId) &&
            (identical(other.swapIncomingSatoshi, swapIncomingSatoshi) ||
                other.swapIncomingSatoshi == swapIncomingSatoshi));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        const DeepCollectionEquality().hash(_addressees),
        blockHeight,
        calculatedFeeRate,
        canCpfp,
        canRbf,
        createdAtTs,
        fee,
        feeRate,
        hasPaymentRequest,
        const DeepCollectionEquality().hash(_inputs),
        instant,
        memo,
        const DeepCollectionEquality().hash(_outputs),
        rbfOptin,
        const DeepCollectionEquality().hash(_satoshi),
        serverSigned,
        spvVerified,
        transaction,
        transactionLocktime,
        const DeepCollectionEquality().hash(_transactionOutputs),
        transactionSize,
        transactionVersion,
        transactionVsize,
        transactionWeight,
        txhash,
        type,
        userSigned,
        vsize,
        swapOutgoingAssetId,
        swapOutgoingSatoshi,
        swapIncomingAssetId,
        swapIncomingSatoshi
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkTransactionImplCopyWith<_$GdkTransactionImpl> get copyWith =>
      __$$GdkTransactionImplCopyWithImpl<_$GdkTransactionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkTransactionImplToJson(
      this,
    );
  }
}

abstract class _GdkTransaction extends GdkTransaction {
  const factory _GdkTransaction(
      {final List<String>? addressees,
      @JsonKey(name: 'block_height') final int? blockHeight,
      @JsonKey(name: 'calculated_fee_rate') final int? calculatedFeeRate,
      @JsonKey(name: 'can_cpfp') final bool? canCpfp,
      @JsonKey(name: 'can_rbf') final bool? canRbf,
      @JsonKey(name: 'created_at_ts') final int? createdAtTs,
      final int? fee,
      @JsonKey(name: 'fee_rate') final int? feeRate,
      @JsonKey(name: 'has_payment_request') final bool? hasPaymentRequest,
      final List<GdkTransactionInOut>? inputs,
      final bool? instant,
      final String? memo,
      final List<GdkTransactionInOut>? outputs,
      @JsonKey(name: 'rbf_optin') final bool? rbfOptin,
      final Map<String, int>? satoshi,
      @JsonKey(name: 'server_signed') final bool? serverSigned,
      @JsonKey(name: 'spv_verified') final String? spvVerified,
      final String? transaction,
      @JsonKey(name: 'transaction_locktime') final int? transactionLocktime,
      @JsonKey(name: 'transaction_outputs')
      final List<String>? transactionOutputs,
      @JsonKey(name: 'transaction_size') final int? transactionSize,
      @JsonKey(name: 'transaction_version') final int? transactionVersion,
      @JsonKey(name: 'transaction_vsize') final int? transactionVsize,
      @JsonKey(name: 'transaction_weight') final int? transactionWeight,
      final String? txhash,
      final GdkTransactionTypeEnum? type,
      @JsonKey(name: 'user_signed') final bool? userSigned,
      final int? vsize,
      final String? swapOutgoingAssetId,
      final int? swapOutgoingSatoshi,
      final String? swapIncomingAssetId,
      final int? swapIncomingSatoshi}) = _$GdkTransactionImpl;
  const _GdkTransaction._() : super._();

  factory _GdkTransaction.fromJson(Map<String, dynamic> json) =
      _$GdkTransactionImpl.fromJson;

  @override
  List<String>? get addressees;
  @override
  @JsonKey(name: 'block_height')
  int? get blockHeight;
  @override
  @JsonKey(name: 'calculated_fee_rate')
  int? get calculatedFeeRate;
  @override
  @JsonKey(name: 'can_cpfp')
  bool? get canCpfp;
  @override
  @JsonKey(name: 'can_rbf')
  bool? get canRbf;
  @override
  @JsonKey(name: 'created_at_ts')
  int? get createdAtTs;
  @override
  int? get fee;
  @override
  @JsonKey(name: 'fee_rate')
  int? get feeRate;
  @override
  @JsonKey(name: 'has_payment_request')
  bool? get hasPaymentRequest;
  @override
  List<GdkTransactionInOut>? get inputs;
  @override
  bool? get instant;
  @override
  String? get memo;
  @override
  List<GdkTransactionInOut>? get outputs;
  @override
  @JsonKey(name: 'rbf_optin')
  bool? get rbfOptin;
  @override
  Map<String, int>? get satoshi;
  @override
  @JsonKey(name: 'server_signed')
  bool? get serverSigned;
  @override
  @JsonKey(name: 'spv_verified')
  String? get spvVerified;
  @override
  String? get transaction;
  @override
  @JsonKey(name: 'transaction_locktime')
  int? get transactionLocktime;
  @override
  @JsonKey(name: 'transaction_outputs')
  List<String>? get transactionOutputs;
  @override
  @JsonKey(name: 'transaction_size')
  int? get transactionSize;
  @override
  @JsonKey(name: 'transaction_version')
  int? get transactionVersion;
  @override
  @JsonKey(name: 'transaction_vsize')
  int? get transactionVsize;
  @override
  @JsonKey(name: 'transaction_weight')
  int? get transactionWeight;
  @override
  String? get txhash;
  @override
  GdkTransactionTypeEnum? get type;
  @override
  @JsonKey(name: 'user_signed')
  bool? get userSigned;
  @override
  int? get vsize;
  @override
  String? get swapOutgoingAssetId;
  @override
  int? get swapOutgoingSatoshi;
  @override
  String? get swapIncomingAssetId;
  @override
  int? get swapIncomingSatoshi;
  @override
  @JsonKey(ignore: true)
  _$$GdkTransactionImplCopyWith<_$GdkTransactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GdkEntity _$GdkEntityFromJson(Map<String, dynamic> json) {
  return _GdkEntity.fromJson(json);
}

/// @nodoc
mixin _$GdkEntity {
  String? get domain => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkEntityCopyWith<GdkEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkEntityCopyWith<$Res> {
  factory $GdkEntityCopyWith(GdkEntity value, $Res Function(GdkEntity) then) =
      _$GdkEntityCopyWithImpl<$Res, GdkEntity>;
  @useResult
  $Res call({String? domain});
}

/// @nodoc
class _$GdkEntityCopyWithImpl<$Res, $Val extends GdkEntity>
    implements $GdkEntityCopyWith<$Res> {
  _$GdkEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? domain = freezed,
  }) {
    return _then(_value.copyWith(
      domain: freezed == domain
          ? _value.domain
          : domain // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GdkEntityImplCopyWith<$Res>
    implements $GdkEntityCopyWith<$Res> {
  factory _$$GdkEntityImplCopyWith(
          _$GdkEntityImpl value, $Res Function(_$GdkEntityImpl) then) =
      __$$GdkEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? domain});
}

/// @nodoc
class __$$GdkEntityImplCopyWithImpl<$Res>
    extends _$GdkEntityCopyWithImpl<$Res, _$GdkEntityImpl>
    implements _$$GdkEntityImplCopyWith<$Res> {
  __$$GdkEntityImplCopyWithImpl(
      _$GdkEntityImpl _value, $Res Function(_$GdkEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? domain = freezed,
  }) {
    return _then(_$GdkEntityImpl(
      domain: freezed == domain
          ? _value.domain
          : domain // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkEntityImpl implements _GdkEntity {
  const _$GdkEntityImpl({this.domain});

  factory _$GdkEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$GdkEntityImplFromJson(json);

  @override
  final String? domain;

  @override
  String toString() {
    return 'GdkEntity(domain: $domain)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkEntityImpl &&
            (identical(other.domain, domain) || other.domain == domain));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, domain);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkEntityImplCopyWith<_$GdkEntityImpl> get copyWith =>
      __$$GdkEntityImplCopyWithImpl<_$GdkEntityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkEntityImplToJson(
      this,
    );
  }
}

abstract class _GdkEntity implements GdkEntity {
  const factory _GdkEntity({final String? domain}) = _$GdkEntityImpl;

  factory _GdkEntity.fromJson(Map<String, dynamic> json) =
      _$GdkEntityImpl.fromJson;

  @override
  String? get domain;
  @override
  @JsonKey(ignore: true)
  _$$GdkEntityImplCopyWith<_$GdkEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GdkContract _$GdkContractFromJson(Map<String, dynamic> json) {
  return _GdkContract.fromJson(json);
}

/// @nodoc
mixin _$GdkContract {
  GdkEntity? get entity => throw _privateConstructorUsedError;
  @JsonKey(name: 'issuer_pubkey')
  String? get issuerPubkey => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get nonce => throw _privateConstructorUsedError;
  int? get precision => throw _privateConstructorUsedError;
  String? get ticker => throw _privateConstructorUsedError;
  int? get version => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkContractCopyWith<GdkContract> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkContractCopyWith<$Res> {
  factory $GdkContractCopyWith(
          GdkContract value, $Res Function(GdkContract) then) =
      _$GdkContractCopyWithImpl<$Res, GdkContract>;
  @useResult
  $Res call(
      {GdkEntity? entity,
      @JsonKey(name: 'issuer_pubkey') String? issuerPubkey,
      String? name,
      String? nonce,
      int? precision,
      String? ticker,
      int? version});

  $GdkEntityCopyWith<$Res>? get entity;
}

/// @nodoc
class _$GdkContractCopyWithImpl<$Res, $Val extends GdkContract>
    implements $GdkContractCopyWith<$Res> {
  _$GdkContractCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? entity = freezed,
    Object? issuerPubkey = freezed,
    Object? name = freezed,
    Object? nonce = freezed,
    Object? precision = freezed,
    Object? ticker = freezed,
    Object? version = freezed,
  }) {
    return _then(_value.copyWith(
      entity: freezed == entity
          ? _value.entity
          : entity // ignore: cast_nullable_to_non_nullable
              as GdkEntity?,
      issuerPubkey: freezed == issuerPubkey
          ? _value.issuerPubkey
          : issuerPubkey // ignore: cast_nullable_to_non_nullable
              as String?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      nonce: freezed == nonce
          ? _value.nonce
          : nonce // ignore: cast_nullable_to_non_nullable
              as String?,
      precision: freezed == precision
          ? _value.precision
          : precision // ignore: cast_nullable_to_non_nullable
              as int?,
      ticker: freezed == ticker
          ? _value.ticker
          : ticker // ignore: cast_nullable_to_non_nullable
              as String?,
      version: freezed == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $GdkEntityCopyWith<$Res>? get entity {
    if (_value.entity == null) {
      return null;
    }

    return $GdkEntityCopyWith<$Res>(_value.entity!, (value) {
      return _then(_value.copyWith(entity: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GdkContractImplCopyWith<$Res>
    implements $GdkContractCopyWith<$Res> {
  factory _$$GdkContractImplCopyWith(
          _$GdkContractImpl value, $Res Function(_$GdkContractImpl) then) =
      __$$GdkContractImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {GdkEntity? entity,
      @JsonKey(name: 'issuer_pubkey') String? issuerPubkey,
      String? name,
      String? nonce,
      int? precision,
      String? ticker,
      int? version});

  @override
  $GdkEntityCopyWith<$Res>? get entity;
}

/// @nodoc
class __$$GdkContractImplCopyWithImpl<$Res>
    extends _$GdkContractCopyWithImpl<$Res, _$GdkContractImpl>
    implements _$$GdkContractImplCopyWith<$Res> {
  __$$GdkContractImplCopyWithImpl(
      _$GdkContractImpl _value, $Res Function(_$GdkContractImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? entity = freezed,
    Object? issuerPubkey = freezed,
    Object? name = freezed,
    Object? nonce = freezed,
    Object? precision = freezed,
    Object? ticker = freezed,
    Object? version = freezed,
  }) {
    return _then(_$GdkContractImpl(
      entity: freezed == entity
          ? _value.entity
          : entity // ignore: cast_nullable_to_non_nullable
              as GdkEntity?,
      issuerPubkey: freezed == issuerPubkey
          ? _value.issuerPubkey
          : issuerPubkey // ignore: cast_nullable_to_non_nullable
              as String?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      nonce: freezed == nonce
          ? _value.nonce
          : nonce // ignore: cast_nullable_to_non_nullable
              as String?,
      precision: freezed == precision
          ? _value.precision
          : precision // ignore: cast_nullable_to_non_nullable
              as int?,
      ticker: freezed == ticker
          ? _value.ticker
          : ticker // ignore: cast_nullable_to_non_nullable
              as String?,
      version: freezed == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkContractImpl implements _GdkContract {
  const _$GdkContractImpl(
      {this.entity,
      @JsonKey(name: 'issuer_pubkey') this.issuerPubkey,
      this.name,
      this.nonce,
      this.precision,
      this.ticker,
      this.version});

  factory _$GdkContractImpl.fromJson(Map<String, dynamic> json) =>
      _$$GdkContractImplFromJson(json);

  @override
  final GdkEntity? entity;
  @override
  @JsonKey(name: 'issuer_pubkey')
  final String? issuerPubkey;
  @override
  final String? name;
  @override
  final String? nonce;
  @override
  final int? precision;
  @override
  final String? ticker;
  @override
  final int? version;

  @override
  String toString() {
    return 'GdkContract(entity: $entity, issuerPubkey: $issuerPubkey, name: $name, nonce: $nonce, precision: $precision, ticker: $ticker, version: $version)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkContractImpl &&
            (identical(other.entity, entity) || other.entity == entity) &&
            (identical(other.issuerPubkey, issuerPubkey) ||
                other.issuerPubkey == issuerPubkey) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.nonce, nonce) || other.nonce == nonce) &&
            (identical(other.precision, precision) ||
                other.precision == precision) &&
            (identical(other.ticker, ticker) || other.ticker == ticker) &&
            (identical(other.version, version) || other.version == version));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, entity, issuerPubkey, name,
      nonce, precision, ticker, version);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkContractImplCopyWith<_$GdkContractImpl> get copyWith =>
      __$$GdkContractImplCopyWithImpl<_$GdkContractImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkContractImplToJson(
      this,
    );
  }
}

abstract class _GdkContract implements GdkContract {
  const factory _GdkContract(
      {final GdkEntity? entity,
      @JsonKey(name: 'issuer_pubkey') final String? issuerPubkey,
      final String? name,
      final String? nonce,
      final int? precision,
      final String? ticker,
      final int? version}) = _$GdkContractImpl;

  factory _GdkContract.fromJson(Map<String, dynamic> json) =
      _$GdkContractImpl.fromJson;

  @override
  GdkEntity? get entity;
  @override
  @JsonKey(name: 'issuer_pubkey')
  String? get issuerPubkey;
  @override
  String? get name;
  @override
  String? get nonce;
  @override
  int? get precision;
  @override
  String? get ticker;
  @override
  int? get version;
  @override
  @JsonKey(ignore: true)
  _$$GdkContractImplCopyWith<_$GdkContractImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GdkIssuance _$GdkIssuanceFromJson(Map<String, dynamic> json) {
  return _GdkIssuance.fromJson(json);
}

/// @nodoc
mixin _$GdkIssuance {
  String? get txid => throw _privateConstructorUsedError;
  int? get vout => throw _privateConstructorUsedError;
  int? get vin => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkIssuanceCopyWith<GdkIssuance> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkIssuanceCopyWith<$Res> {
  factory $GdkIssuanceCopyWith(
          GdkIssuance value, $Res Function(GdkIssuance) then) =
      _$GdkIssuanceCopyWithImpl<$Res, GdkIssuance>;
  @useResult
  $Res call({String? txid, int? vout, int? vin});
}

/// @nodoc
class _$GdkIssuanceCopyWithImpl<$Res, $Val extends GdkIssuance>
    implements $GdkIssuanceCopyWith<$Res> {
  _$GdkIssuanceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? txid = freezed,
    Object? vout = freezed,
    Object? vin = freezed,
  }) {
    return _then(_value.copyWith(
      txid: freezed == txid
          ? _value.txid
          : txid // ignore: cast_nullable_to_non_nullable
              as String?,
      vout: freezed == vout
          ? _value.vout
          : vout // ignore: cast_nullable_to_non_nullable
              as int?,
      vin: freezed == vin
          ? _value.vin
          : vin // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GdkIssuanceImplCopyWith<$Res>
    implements $GdkIssuanceCopyWith<$Res> {
  factory _$$GdkIssuanceImplCopyWith(
          _$GdkIssuanceImpl value, $Res Function(_$GdkIssuanceImpl) then) =
      __$$GdkIssuanceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? txid, int? vout, int? vin});
}

/// @nodoc
class __$$GdkIssuanceImplCopyWithImpl<$Res>
    extends _$GdkIssuanceCopyWithImpl<$Res, _$GdkIssuanceImpl>
    implements _$$GdkIssuanceImplCopyWith<$Res> {
  __$$GdkIssuanceImplCopyWithImpl(
      _$GdkIssuanceImpl _value, $Res Function(_$GdkIssuanceImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? txid = freezed,
    Object? vout = freezed,
    Object? vin = freezed,
  }) {
    return _then(_$GdkIssuanceImpl(
      txid: freezed == txid
          ? _value.txid
          : txid // ignore: cast_nullable_to_non_nullable
              as String?,
      vout: freezed == vout
          ? _value.vout
          : vout // ignore: cast_nullable_to_non_nullable
              as int?,
      vin: freezed == vin
          ? _value.vin
          : vin // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkIssuanceImpl implements _GdkIssuance {
  const _$GdkIssuanceImpl({this.txid, this.vout, this.vin});

  factory _$GdkIssuanceImpl.fromJson(Map<String, dynamic> json) =>
      _$$GdkIssuanceImplFromJson(json);

  @override
  final String? txid;
  @override
  final int? vout;
  @override
  final int? vin;

  @override
  String toString() {
    return 'GdkIssuance(txid: $txid, vout: $vout, vin: $vin)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkIssuanceImpl &&
            (identical(other.txid, txid) || other.txid == txid) &&
            (identical(other.vout, vout) || other.vout == vout) &&
            (identical(other.vin, vin) || other.vin == vin));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, txid, vout, vin);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkIssuanceImplCopyWith<_$GdkIssuanceImpl> get copyWith =>
      __$$GdkIssuanceImplCopyWithImpl<_$GdkIssuanceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkIssuanceImplToJson(
      this,
    );
  }
}

abstract class _GdkIssuance implements GdkIssuance {
  const factory _GdkIssuance(
      {final String? txid,
      final int? vout,
      final int? vin}) = _$GdkIssuanceImpl;

  factory _GdkIssuance.fromJson(Map<String, dynamic> json) =
      _$GdkIssuanceImpl.fromJson;

  @override
  String? get txid;
  @override
  int? get vout;
  @override
  int? get vin;
  @override
  @JsonKey(ignore: true)
  _$$GdkIssuanceImplCopyWith<_$GdkIssuanceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GdkAssetInformation _$GdkAssetInformationFromJson(Map<String, dynamic> json) {
  return _GdkAssetInformation.fromJson(json);
}

/// @nodoc
mixin _$GdkAssetInformation {
  @JsonKey(name: 'asset_id')
  String? get assetId => throw _privateConstructorUsedError;
  GdkContract? get contract => throw _privateConstructorUsedError;
  GdkEntity? get entity => throw _privateConstructorUsedError;
  @JsonKey(name: 'issuance_prevout')
  GdkIssuance? get issuancePrevout => throw _privateConstructorUsedError;
  @JsonKey(name: 'issuance_txin')
  GdkIssuance? get issuanceTxin => throw _privateConstructorUsedError;
  @JsonKey(name: 'issuer_pubkey')
  String? get issuerPubkey => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  int? get precision => throw _privateConstructorUsedError;
  String? get ticker => throw _privateConstructorUsedError;
  int? get version => throw _privateConstructorUsedError;
  String? get icon => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkAssetInformationCopyWith<GdkAssetInformation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkAssetInformationCopyWith<$Res> {
  factory $GdkAssetInformationCopyWith(
          GdkAssetInformation value, $Res Function(GdkAssetInformation) then) =
      _$GdkAssetInformationCopyWithImpl<$Res, GdkAssetInformation>;
  @useResult
  $Res call(
      {@JsonKey(name: 'asset_id') String? assetId,
      GdkContract? contract,
      GdkEntity? entity,
      @JsonKey(name: 'issuance_prevout') GdkIssuance? issuancePrevout,
      @JsonKey(name: 'issuance_txin') GdkIssuance? issuanceTxin,
      @JsonKey(name: 'issuer_pubkey') String? issuerPubkey,
      String? name,
      int? precision,
      String? ticker,
      int? version,
      String? icon});

  $GdkContractCopyWith<$Res>? get contract;
  $GdkEntityCopyWith<$Res>? get entity;
  $GdkIssuanceCopyWith<$Res>? get issuancePrevout;
  $GdkIssuanceCopyWith<$Res>? get issuanceTxin;
}

/// @nodoc
class _$GdkAssetInformationCopyWithImpl<$Res, $Val extends GdkAssetInformation>
    implements $GdkAssetInformationCopyWith<$Res> {
  _$GdkAssetInformationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? assetId = freezed,
    Object? contract = freezed,
    Object? entity = freezed,
    Object? issuancePrevout = freezed,
    Object? issuanceTxin = freezed,
    Object? issuerPubkey = freezed,
    Object? name = freezed,
    Object? precision = freezed,
    Object? ticker = freezed,
    Object? version = freezed,
    Object? icon = freezed,
  }) {
    return _then(_value.copyWith(
      assetId: freezed == assetId
          ? _value.assetId
          : assetId // ignore: cast_nullable_to_non_nullable
              as String?,
      contract: freezed == contract
          ? _value.contract
          : contract // ignore: cast_nullable_to_non_nullable
              as GdkContract?,
      entity: freezed == entity
          ? _value.entity
          : entity // ignore: cast_nullable_to_non_nullable
              as GdkEntity?,
      issuancePrevout: freezed == issuancePrevout
          ? _value.issuancePrevout
          : issuancePrevout // ignore: cast_nullable_to_non_nullable
              as GdkIssuance?,
      issuanceTxin: freezed == issuanceTxin
          ? _value.issuanceTxin
          : issuanceTxin // ignore: cast_nullable_to_non_nullable
              as GdkIssuance?,
      issuerPubkey: freezed == issuerPubkey
          ? _value.issuerPubkey
          : issuerPubkey // ignore: cast_nullable_to_non_nullable
              as String?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      precision: freezed == precision
          ? _value.precision
          : precision // ignore: cast_nullable_to_non_nullable
              as int?,
      ticker: freezed == ticker
          ? _value.ticker
          : ticker // ignore: cast_nullable_to_non_nullable
              as String?,
      version: freezed == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as int?,
      icon: freezed == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $GdkContractCopyWith<$Res>? get contract {
    if (_value.contract == null) {
      return null;
    }

    return $GdkContractCopyWith<$Res>(_value.contract!, (value) {
      return _then(_value.copyWith(contract: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $GdkEntityCopyWith<$Res>? get entity {
    if (_value.entity == null) {
      return null;
    }

    return $GdkEntityCopyWith<$Res>(_value.entity!, (value) {
      return _then(_value.copyWith(entity: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $GdkIssuanceCopyWith<$Res>? get issuancePrevout {
    if (_value.issuancePrevout == null) {
      return null;
    }

    return $GdkIssuanceCopyWith<$Res>(_value.issuancePrevout!, (value) {
      return _then(_value.copyWith(issuancePrevout: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $GdkIssuanceCopyWith<$Res>? get issuanceTxin {
    if (_value.issuanceTxin == null) {
      return null;
    }

    return $GdkIssuanceCopyWith<$Res>(_value.issuanceTxin!, (value) {
      return _then(_value.copyWith(issuanceTxin: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GdkAssetInformationImplCopyWith<$Res>
    implements $GdkAssetInformationCopyWith<$Res> {
  factory _$$GdkAssetInformationImplCopyWith(_$GdkAssetInformationImpl value,
          $Res Function(_$GdkAssetInformationImpl) then) =
      __$$GdkAssetInformationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'asset_id') String? assetId,
      GdkContract? contract,
      GdkEntity? entity,
      @JsonKey(name: 'issuance_prevout') GdkIssuance? issuancePrevout,
      @JsonKey(name: 'issuance_txin') GdkIssuance? issuanceTxin,
      @JsonKey(name: 'issuer_pubkey') String? issuerPubkey,
      String? name,
      int? precision,
      String? ticker,
      int? version,
      String? icon});

  @override
  $GdkContractCopyWith<$Res>? get contract;
  @override
  $GdkEntityCopyWith<$Res>? get entity;
  @override
  $GdkIssuanceCopyWith<$Res>? get issuancePrevout;
  @override
  $GdkIssuanceCopyWith<$Res>? get issuanceTxin;
}

/// @nodoc
class __$$GdkAssetInformationImplCopyWithImpl<$Res>
    extends _$GdkAssetInformationCopyWithImpl<$Res, _$GdkAssetInformationImpl>
    implements _$$GdkAssetInformationImplCopyWith<$Res> {
  __$$GdkAssetInformationImplCopyWithImpl(_$GdkAssetInformationImpl _value,
      $Res Function(_$GdkAssetInformationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? assetId = freezed,
    Object? contract = freezed,
    Object? entity = freezed,
    Object? issuancePrevout = freezed,
    Object? issuanceTxin = freezed,
    Object? issuerPubkey = freezed,
    Object? name = freezed,
    Object? precision = freezed,
    Object? ticker = freezed,
    Object? version = freezed,
    Object? icon = freezed,
  }) {
    return _then(_$GdkAssetInformationImpl(
      assetId: freezed == assetId
          ? _value.assetId
          : assetId // ignore: cast_nullable_to_non_nullable
              as String?,
      contract: freezed == contract
          ? _value.contract
          : contract // ignore: cast_nullable_to_non_nullable
              as GdkContract?,
      entity: freezed == entity
          ? _value.entity
          : entity // ignore: cast_nullable_to_non_nullable
              as GdkEntity?,
      issuancePrevout: freezed == issuancePrevout
          ? _value.issuancePrevout
          : issuancePrevout // ignore: cast_nullable_to_non_nullable
              as GdkIssuance?,
      issuanceTxin: freezed == issuanceTxin
          ? _value.issuanceTxin
          : issuanceTxin // ignore: cast_nullable_to_non_nullable
              as GdkIssuance?,
      issuerPubkey: freezed == issuerPubkey
          ? _value.issuerPubkey
          : issuerPubkey // ignore: cast_nullable_to_non_nullable
              as String?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      precision: freezed == precision
          ? _value.precision
          : precision // ignore: cast_nullable_to_non_nullable
              as int?,
      ticker: freezed == ticker
          ? _value.ticker
          : ticker // ignore: cast_nullable_to_non_nullable
              as String?,
      version: freezed == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as int?,
      icon: freezed == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkAssetInformationImpl implements _GdkAssetInformation {
  const _$GdkAssetInformationImpl(
      {@JsonKey(name: 'asset_id') this.assetId,
      this.contract,
      this.entity,
      @JsonKey(name: 'issuance_prevout') this.issuancePrevout,
      @JsonKey(name: 'issuance_txin') this.issuanceTxin,
      @JsonKey(name: 'issuer_pubkey') this.issuerPubkey,
      this.name,
      this.precision,
      this.ticker,
      this.version,
      this.icon});

  factory _$GdkAssetInformationImpl.fromJson(Map<String, dynamic> json) =>
      _$$GdkAssetInformationImplFromJson(json);

  @override
  @JsonKey(name: 'asset_id')
  final String? assetId;
  @override
  final GdkContract? contract;
  @override
  final GdkEntity? entity;
  @override
  @JsonKey(name: 'issuance_prevout')
  final GdkIssuance? issuancePrevout;
  @override
  @JsonKey(name: 'issuance_txin')
  final GdkIssuance? issuanceTxin;
  @override
  @JsonKey(name: 'issuer_pubkey')
  final String? issuerPubkey;
  @override
  final String? name;
  @override
  final int? precision;
  @override
  final String? ticker;
  @override
  final int? version;
  @override
  final String? icon;

  @override
  String toString() {
    return 'GdkAssetInformation(assetId: $assetId, contract: $contract, entity: $entity, issuancePrevout: $issuancePrevout, issuanceTxin: $issuanceTxin, issuerPubkey: $issuerPubkey, name: $name, precision: $precision, ticker: $ticker, version: $version, icon: $icon)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkAssetInformationImpl &&
            (identical(other.assetId, assetId) || other.assetId == assetId) &&
            (identical(other.contract, contract) ||
                other.contract == contract) &&
            (identical(other.entity, entity) || other.entity == entity) &&
            (identical(other.issuancePrevout, issuancePrevout) ||
                other.issuancePrevout == issuancePrevout) &&
            (identical(other.issuanceTxin, issuanceTxin) ||
                other.issuanceTxin == issuanceTxin) &&
            (identical(other.issuerPubkey, issuerPubkey) ||
                other.issuerPubkey == issuerPubkey) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.precision, precision) ||
                other.precision == precision) &&
            (identical(other.ticker, ticker) || other.ticker == ticker) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.icon, icon) || other.icon == icon));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      assetId,
      contract,
      entity,
      issuancePrevout,
      issuanceTxin,
      issuerPubkey,
      name,
      precision,
      ticker,
      version,
      icon);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkAssetInformationImplCopyWith<_$GdkAssetInformationImpl> get copyWith =>
      __$$GdkAssetInformationImplCopyWithImpl<_$GdkAssetInformationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkAssetInformationImplToJson(
      this,
    );
  }
}

abstract class _GdkAssetInformation implements GdkAssetInformation {
  const factory _GdkAssetInformation(
      {@JsonKey(name: 'asset_id') final String? assetId,
      final GdkContract? contract,
      final GdkEntity? entity,
      @JsonKey(name: 'issuance_prevout') final GdkIssuance? issuancePrevout,
      @JsonKey(name: 'issuance_txin') final GdkIssuance? issuanceTxin,
      @JsonKey(name: 'issuer_pubkey') final String? issuerPubkey,
      final String? name,
      final int? precision,
      final String? ticker,
      final int? version,
      final String? icon}) = _$GdkAssetInformationImpl;

  factory _GdkAssetInformation.fromJson(Map<String, dynamic> json) =
      _$GdkAssetInformationImpl.fromJson;

  @override
  @JsonKey(name: 'asset_id')
  String? get assetId;
  @override
  GdkContract? get contract;
  @override
  GdkEntity? get entity;
  @override
  @JsonKey(name: 'issuance_prevout')
  GdkIssuance? get issuancePrevout;
  @override
  @JsonKey(name: 'issuance_txin')
  GdkIssuance? get issuanceTxin;
  @override
  @JsonKey(name: 'issuer_pubkey')
  String? get issuerPubkey;
  @override
  String? get name;
  @override
  int? get precision;
  @override
  String? get ticker;
  @override
  int? get version;
  @override
  String? get icon;
  @override
  @JsonKey(ignore: true)
  _$$GdkAssetInformationImplCopyWith<_$GdkAssetInformationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GdkNetworks _$GdkNetworksFromJson(Map<String, dynamic> json) {
  return _GdkNetworks.fromJson(json);
}

/// @nodoc
mixin _$GdkNetworks {
  List<String>? get allNetworks => throw _privateConstructorUsedError;
  Map<String, GdkNetwork>? get networks => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkNetworksCopyWith<GdkNetworks> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkNetworksCopyWith<$Res> {
  factory $GdkNetworksCopyWith(
          GdkNetworks value, $Res Function(GdkNetworks) then) =
      _$GdkNetworksCopyWithImpl<$Res, GdkNetworks>;
  @useResult
  $Res call({List<String>? allNetworks, Map<String, GdkNetwork>? networks});
}

/// @nodoc
class _$GdkNetworksCopyWithImpl<$Res, $Val extends GdkNetworks>
    implements $GdkNetworksCopyWith<$Res> {
  _$GdkNetworksCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? allNetworks = freezed,
    Object? networks = freezed,
  }) {
    return _then(_value.copyWith(
      allNetworks: freezed == allNetworks
          ? _value.allNetworks
          : allNetworks // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      networks: freezed == networks
          ? _value.networks
          : networks // ignore: cast_nullable_to_non_nullable
              as Map<String, GdkNetwork>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GdkNetworksImplCopyWith<$Res>
    implements $GdkNetworksCopyWith<$Res> {
  factory _$$GdkNetworksImplCopyWith(
          _$GdkNetworksImpl value, $Res Function(_$GdkNetworksImpl) then) =
      __$$GdkNetworksImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<String>? allNetworks, Map<String, GdkNetwork>? networks});
}

/// @nodoc
class __$$GdkNetworksImplCopyWithImpl<$Res>
    extends _$GdkNetworksCopyWithImpl<$Res, _$GdkNetworksImpl>
    implements _$$GdkNetworksImplCopyWith<$Res> {
  __$$GdkNetworksImplCopyWithImpl(
      _$GdkNetworksImpl _value, $Res Function(_$GdkNetworksImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? allNetworks = freezed,
    Object? networks = freezed,
  }) {
    return _then(_$GdkNetworksImpl(
      allNetworks: freezed == allNetworks
          ? _value._allNetworks
          : allNetworks // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      networks: freezed == networks
          ? _value._networks
          : networks // ignore: cast_nullable_to_non_nullable
              as Map<String, GdkNetwork>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkNetworksImpl extends _GdkNetworks {
  const _$GdkNetworksImpl(
      {final List<String>? allNetworks,
      final Map<String, GdkNetwork>? networks})
      : _allNetworks = allNetworks,
        _networks = networks,
        super._();

  factory _$GdkNetworksImpl.fromJson(Map<String, dynamic> json) =>
      _$$GdkNetworksImplFromJson(json);

  final List<String>? _allNetworks;
  @override
  List<String>? get allNetworks {
    final value = _allNetworks;
    if (value == null) return null;
    if (_allNetworks is EqualUnmodifiableListView) return _allNetworks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final Map<String, GdkNetwork>? _networks;
  @override
  Map<String, GdkNetwork>? get networks {
    final value = _networks;
    if (value == null) return null;
    if (_networks is EqualUnmodifiableMapView) return _networks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'GdkNetworks(allNetworks: $allNetworks, networks: $networks)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkNetworksImpl &&
            const DeepCollectionEquality()
                .equals(other._allNetworks, _allNetworks) &&
            const DeepCollectionEquality().equals(other._networks, _networks));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_allNetworks),
      const DeepCollectionEquality().hash(_networks));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkNetworksImplCopyWith<_$GdkNetworksImpl> get copyWith =>
      __$$GdkNetworksImplCopyWithImpl<_$GdkNetworksImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkNetworksImplToJson(
      this,
    );
  }
}

abstract class _GdkNetworks extends GdkNetworks {
  const factory _GdkNetworks(
      {final List<String>? allNetworks,
      final Map<String, GdkNetwork>? networks}) = _$GdkNetworksImpl;
  const _GdkNetworks._() : super._();

  factory _GdkNetworks.fromJson(Map<String, dynamic> json) =
      _$GdkNetworksImpl.fromJson;

  @override
  List<String>? get allNetworks;
  @override
  Map<String, GdkNetwork>? get networks;
  @override
  @JsonKey(ignore: true)
  _$$GdkNetworksImplCopyWith<_$GdkNetworksImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GdkNetwork _$GdkNetworkFromJson(Map<String, dynamic> json) {
  return _GdkNetwork.fromJson(json);
}

/// @nodoc
mixin _$GdkNetwork {
  @JsonKey(name: 'address_explorer_url')
  String? get addressExplorerUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'address_registry_onion_url')
  String? get assetRegistryOnionUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'asset_registry_url')
  String? get assetRegistryUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'bech32_prefix')
  String? get bech32Prefix => throw _privateConstructorUsedError;
  @JsonKey(name: 'bip21_prefix')
  String? get bip21Prefix => throw _privateConstructorUsedError;
  @JsonKey(name: 'blech32_prefix')
  String? get blech32Prefix => throw _privateConstructorUsedError;
  @JsonKey(name: 'blinded_prefix')
  int? get blindedPrefix => throw _privateConstructorUsedError;
  @JsonKey(name: 'csv_buckets')
  List<int>? get csvBuckets => throw _privateConstructorUsedError;
  @JsonKey(name: 'ct_bits')
  int? get ctBits => throw _privateConstructorUsedError;
  @JsonKey(name: 'ct_exponent')
  int? get ctExponent => throw _privateConstructorUsedError;
  bool? get development => throw _privateConstructorUsedError;
  @JsonKey(name: 'electrum_tls')
  bool? get electrumTls => throw _privateConstructorUsedError;
  @JsonKey(name: 'electrum_url')
  String? get electrumUrl => throw _privateConstructorUsedError;
  bool? get liquid => throw _privateConstructorUsedError;
  bool? get mainnet => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get network => throw _privateConstructorUsedError;
  @JsonKey(name: 'p2pkh_version')
  int? get p2PkhVersion => throw _privateConstructorUsedError;
  @JsonKey(name: 'p2sh_version')
  int? get p2ShVersion => throw _privateConstructorUsedError;
  @JsonKey(name: 'policy_asset')
  String? get policyAsset => throw _privateConstructorUsedError;
  @JsonKey(name: 'server_type')
  ServerTypeEnum? get serverType => throw _privateConstructorUsedError;
  @JsonKey(name: 'service_chain_code')
  String? get serviceChainCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'service_pubkey')
  String? get servicePubkey => throw _privateConstructorUsedError;
  @JsonKey(name: 'spv_enabled')
  bool? get spvEnabled => throw _privateConstructorUsedError;
  @JsonKey(name: 'spv_multi')
  bool? get spvMulti => throw _privateConstructorUsedError;
  @JsonKey(name: 'spv_servers')
  List<dynamic>? get spvServers => throw _privateConstructorUsedError;
  @JsonKey(name: 'tx_explorer_url')
  String? get txExplorerUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'wamp_cert_pins')
  List<String>? get wampCertPins => throw _privateConstructorUsedError;
  @JsonKey(name: 'wamp_cert_roots')
  List<String>? get wampCertRoots => throw _privateConstructorUsedError;
  @JsonKey(name: 'wamp_onion_url')
  String? get wampOnionUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'wamp_url')
  String? get wampUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkNetworkCopyWith<GdkNetwork> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkNetworkCopyWith<$Res> {
  factory $GdkNetworkCopyWith(
          GdkNetwork value, $Res Function(GdkNetwork) then) =
      _$GdkNetworkCopyWithImpl<$Res, GdkNetwork>;
  @useResult
  $Res call(
      {@JsonKey(name: 'address_explorer_url') String? addressExplorerUrl,
      @JsonKey(name: 'address_registry_onion_url')
      String? assetRegistryOnionUrl,
      @JsonKey(name: 'asset_registry_url') String? assetRegistryUrl,
      @JsonKey(name: 'bech32_prefix') String? bech32Prefix,
      @JsonKey(name: 'bip21_prefix') String? bip21Prefix,
      @JsonKey(name: 'blech32_prefix') String? blech32Prefix,
      @JsonKey(name: 'blinded_prefix') int? blindedPrefix,
      @JsonKey(name: 'csv_buckets') List<int>? csvBuckets,
      @JsonKey(name: 'ct_bits') int? ctBits,
      @JsonKey(name: 'ct_exponent') int? ctExponent,
      bool? development,
      @JsonKey(name: 'electrum_tls') bool? electrumTls,
      @JsonKey(name: 'electrum_url') String? electrumUrl,
      bool? liquid,
      bool? mainnet,
      String? name,
      String? network,
      @JsonKey(name: 'p2pkh_version') int? p2PkhVersion,
      @JsonKey(name: 'p2sh_version') int? p2ShVersion,
      @JsonKey(name: 'policy_asset') String? policyAsset,
      @JsonKey(name: 'server_type') ServerTypeEnum? serverType,
      @JsonKey(name: 'service_chain_code') String? serviceChainCode,
      @JsonKey(name: 'service_pubkey') String? servicePubkey,
      @JsonKey(name: 'spv_enabled') bool? spvEnabled,
      @JsonKey(name: 'spv_multi') bool? spvMulti,
      @JsonKey(name: 'spv_servers') List<dynamic>? spvServers,
      @JsonKey(name: 'tx_explorer_url') String? txExplorerUrl,
      @JsonKey(name: 'wamp_cert_pins') List<String>? wampCertPins,
      @JsonKey(name: 'wamp_cert_roots') List<String>? wampCertRoots,
      @JsonKey(name: 'wamp_onion_url') String? wampOnionUrl,
      @JsonKey(name: 'wamp_url') String? wampUrl});
}

/// @nodoc
class _$GdkNetworkCopyWithImpl<$Res, $Val extends GdkNetwork>
    implements $GdkNetworkCopyWith<$Res> {
  _$GdkNetworkCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? addressExplorerUrl = freezed,
    Object? assetRegistryOnionUrl = freezed,
    Object? assetRegistryUrl = freezed,
    Object? bech32Prefix = freezed,
    Object? bip21Prefix = freezed,
    Object? blech32Prefix = freezed,
    Object? blindedPrefix = freezed,
    Object? csvBuckets = freezed,
    Object? ctBits = freezed,
    Object? ctExponent = freezed,
    Object? development = freezed,
    Object? electrumTls = freezed,
    Object? electrumUrl = freezed,
    Object? liquid = freezed,
    Object? mainnet = freezed,
    Object? name = freezed,
    Object? network = freezed,
    Object? p2PkhVersion = freezed,
    Object? p2ShVersion = freezed,
    Object? policyAsset = freezed,
    Object? serverType = freezed,
    Object? serviceChainCode = freezed,
    Object? servicePubkey = freezed,
    Object? spvEnabled = freezed,
    Object? spvMulti = freezed,
    Object? spvServers = freezed,
    Object? txExplorerUrl = freezed,
    Object? wampCertPins = freezed,
    Object? wampCertRoots = freezed,
    Object? wampOnionUrl = freezed,
    Object? wampUrl = freezed,
  }) {
    return _then(_value.copyWith(
      addressExplorerUrl: freezed == addressExplorerUrl
          ? _value.addressExplorerUrl
          : addressExplorerUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      assetRegistryOnionUrl: freezed == assetRegistryOnionUrl
          ? _value.assetRegistryOnionUrl
          : assetRegistryOnionUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      assetRegistryUrl: freezed == assetRegistryUrl
          ? _value.assetRegistryUrl
          : assetRegistryUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      bech32Prefix: freezed == bech32Prefix
          ? _value.bech32Prefix
          : bech32Prefix // ignore: cast_nullable_to_non_nullable
              as String?,
      bip21Prefix: freezed == bip21Prefix
          ? _value.bip21Prefix
          : bip21Prefix // ignore: cast_nullable_to_non_nullable
              as String?,
      blech32Prefix: freezed == blech32Prefix
          ? _value.blech32Prefix
          : blech32Prefix // ignore: cast_nullable_to_non_nullable
              as String?,
      blindedPrefix: freezed == blindedPrefix
          ? _value.blindedPrefix
          : blindedPrefix // ignore: cast_nullable_to_non_nullable
              as int?,
      csvBuckets: freezed == csvBuckets
          ? _value.csvBuckets
          : csvBuckets // ignore: cast_nullable_to_non_nullable
              as List<int>?,
      ctBits: freezed == ctBits
          ? _value.ctBits
          : ctBits // ignore: cast_nullable_to_non_nullable
              as int?,
      ctExponent: freezed == ctExponent
          ? _value.ctExponent
          : ctExponent // ignore: cast_nullable_to_non_nullable
              as int?,
      development: freezed == development
          ? _value.development
          : development // ignore: cast_nullable_to_non_nullable
              as bool?,
      electrumTls: freezed == electrumTls
          ? _value.electrumTls
          : electrumTls // ignore: cast_nullable_to_non_nullable
              as bool?,
      electrumUrl: freezed == electrumUrl
          ? _value.electrumUrl
          : electrumUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      liquid: freezed == liquid
          ? _value.liquid
          : liquid // ignore: cast_nullable_to_non_nullable
              as bool?,
      mainnet: freezed == mainnet
          ? _value.mainnet
          : mainnet // ignore: cast_nullable_to_non_nullable
              as bool?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      network: freezed == network
          ? _value.network
          : network // ignore: cast_nullable_to_non_nullable
              as String?,
      p2PkhVersion: freezed == p2PkhVersion
          ? _value.p2PkhVersion
          : p2PkhVersion // ignore: cast_nullable_to_non_nullable
              as int?,
      p2ShVersion: freezed == p2ShVersion
          ? _value.p2ShVersion
          : p2ShVersion // ignore: cast_nullable_to_non_nullable
              as int?,
      policyAsset: freezed == policyAsset
          ? _value.policyAsset
          : policyAsset // ignore: cast_nullable_to_non_nullable
              as String?,
      serverType: freezed == serverType
          ? _value.serverType
          : serverType // ignore: cast_nullable_to_non_nullable
              as ServerTypeEnum?,
      serviceChainCode: freezed == serviceChainCode
          ? _value.serviceChainCode
          : serviceChainCode // ignore: cast_nullable_to_non_nullable
              as String?,
      servicePubkey: freezed == servicePubkey
          ? _value.servicePubkey
          : servicePubkey // ignore: cast_nullable_to_non_nullable
              as String?,
      spvEnabled: freezed == spvEnabled
          ? _value.spvEnabled
          : spvEnabled // ignore: cast_nullable_to_non_nullable
              as bool?,
      spvMulti: freezed == spvMulti
          ? _value.spvMulti
          : spvMulti // ignore: cast_nullable_to_non_nullable
              as bool?,
      spvServers: freezed == spvServers
          ? _value.spvServers
          : spvServers // ignore: cast_nullable_to_non_nullable
              as List<dynamic>?,
      txExplorerUrl: freezed == txExplorerUrl
          ? _value.txExplorerUrl
          : txExplorerUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      wampCertPins: freezed == wampCertPins
          ? _value.wampCertPins
          : wampCertPins // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      wampCertRoots: freezed == wampCertRoots
          ? _value.wampCertRoots
          : wampCertRoots // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      wampOnionUrl: freezed == wampOnionUrl
          ? _value.wampOnionUrl
          : wampOnionUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      wampUrl: freezed == wampUrl
          ? _value.wampUrl
          : wampUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GdkNetworkImplCopyWith<$Res>
    implements $GdkNetworkCopyWith<$Res> {
  factory _$$GdkNetworkImplCopyWith(
          _$GdkNetworkImpl value, $Res Function(_$GdkNetworkImpl) then) =
      __$$GdkNetworkImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'address_explorer_url') String? addressExplorerUrl,
      @JsonKey(name: 'address_registry_onion_url')
      String? assetRegistryOnionUrl,
      @JsonKey(name: 'asset_registry_url') String? assetRegistryUrl,
      @JsonKey(name: 'bech32_prefix') String? bech32Prefix,
      @JsonKey(name: 'bip21_prefix') String? bip21Prefix,
      @JsonKey(name: 'blech32_prefix') String? blech32Prefix,
      @JsonKey(name: 'blinded_prefix') int? blindedPrefix,
      @JsonKey(name: 'csv_buckets') List<int>? csvBuckets,
      @JsonKey(name: 'ct_bits') int? ctBits,
      @JsonKey(name: 'ct_exponent') int? ctExponent,
      bool? development,
      @JsonKey(name: 'electrum_tls') bool? electrumTls,
      @JsonKey(name: 'electrum_url') String? electrumUrl,
      bool? liquid,
      bool? mainnet,
      String? name,
      String? network,
      @JsonKey(name: 'p2pkh_version') int? p2PkhVersion,
      @JsonKey(name: 'p2sh_version') int? p2ShVersion,
      @JsonKey(name: 'policy_asset') String? policyAsset,
      @JsonKey(name: 'server_type') ServerTypeEnum? serverType,
      @JsonKey(name: 'service_chain_code') String? serviceChainCode,
      @JsonKey(name: 'service_pubkey') String? servicePubkey,
      @JsonKey(name: 'spv_enabled') bool? spvEnabled,
      @JsonKey(name: 'spv_multi') bool? spvMulti,
      @JsonKey(name: 'spv_servers') List<dynamic>? spvServers,
      @JsonKey(name: 'tx_explorer_url') String? txExplorerUrl,
      @JsonKey(name: 'wamp_cert_pins') List<String>? wampCertPins,
      @JsonKey(name: 'wamp_cert_roots') List<String>? wampCertRoots,
      @JsonKey(name: 'wamp_onion_url') String? wampOnionUrl,
      @JsonKey(name: 'wamp_url') String? wampUrl});
}

/// @nodoc
class __$$GdkNetworkImplCopyWithImpl<$Res>
    extends _$GdkNetworkCopyWithImpl<$Res, _$GdkNetworkImpl>
    implements _$$GdkNetworkImplCopyWith<$Res> {
  __$$GdkNetworkImplCopyWithImpl(
      _$GdkNetworkImpl _value, $Res Function(_$GdkNetworkImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? addressExplorerUrl = freezed,
    Object? assetRegistryOnionUrl = freezed,
    Object? assetRegistryUrl = freezed,
    Object? bech32Prefix = freezed,
    Object? bip21Prefix = freezed,
    Object? blech32Prefix = freezed,
    Object? blindedPrefix = freezed,
    Object? csvBuckets = freezed,
    Object? ctBits = freezed,
    Object? ctExponent = freezed,
    Object? development = freezed,
    Object? electrumTls = freezed,
    Object? electrumUrl = freezed,
    Object? liquid = freezed,
    Object? mainnet = freezed,
    Object? name = freezed,
    Object? network = freezed,
    Object? p2PkhVersion = freezed,
    Object? p2ShVersion = freezed,
    Object? policyAsset = freezed,
    Object? serverType = freezed,
    Object? serviceChainCode = freezed,
    Object? servicePubkey = freezed,
    Object? spvEnabled = freezed,
    Object? spvMulti = freezed,
    Object? spvServers = freezed,
    Object? txExplorerUrl = freezed,
    Object? wampCertPins = freezed,
    Object? wampCertRoots = freezed,
    Object? wampOnionUrl = freezed,
    Object? wampUrl = freezed,
  }) {
    return _then(_$GdkNetworkImpl(
      addressExplorerUrl: freezed == addressExplorerUrl
          ? _value.addressExplorerUrl
          : addressExplorerUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      assetRegistryOnionUrl: freezed == assetRegistryOnionUrl
          ? _value.assetRegistryOnionUrl
          : assetRegistryOnionUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      assetRegistryUrl: freezed == assetRegistryUrl
          ? _value.assetRegistryUrl
          : assetRegistryUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      bech32Prefix: freezed == bech32Prefix
          ? _value.bech32Prefix
          : bech32Prefix // ignore: cast_nullable_to_non_nullable
              as String?,
      bip21Prefix: freezed == bip21Prefix
          ? _value.bip21Prefix
          : bip21Prefix // ignore: cast_nullable_to_non_nullable
              as String?,
      blech32Prefix: freezed == blech32Prefix
          ? _value.blech32Prefix
          : blech32Prefix // ignore: cast_nullable_to_non_nullable
              as String?,
      blindedPrefix: freezed == blindedPrefix
          ? _value.blindedPrefix
          : blindedPrefix // ignore: cast_nullable_to_non_nullable
              as int?,
      csvBuckets: freezed == csvBuckets
          ? _value._csvBuckets
          : csvBuckets // ignore: cast_nullable_to_non_nullable
              as List<int>?,
      ctBits: freezed == ctBits
          ? _value.ctBits
          : ctBits // ignore: cast_nullable_to_non_nullable
              as int?,
      ctExponent: freezed == ctExponent
          ? _value.ctExponent
          : ctExponent // ignore: cast_nullable_to_non_nullable
              as int?,
      development: freezed == development
          ? _value.development
          : development // ignore: cast_nullable_to_non_nullable
              as bool?,
      electrumTls: freezed == electrumTls
          ? _value.electrumTls
          : electrumTls // ignore: cast_nullable_to_non_nullable
              as bool?,
      electrumUrl: freezed == electrumUrl
          ? _value.electrumUrl
          : electrumUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      liquid: freezed == liquid
          ? _value.liquid
          : liquid // ignore: cast_nullable_to_non_nullable
              as bool?,
      mainnet: freezed == mainnet
          ? _value.mainnet
          : mainnet // ignore: cast_nullable_to_non_nullable
              as bool?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      network: freezed == network
          ? _value.network
          : network // ignore: cast_nullable_to_non_nullable
              as String?,
      p2PkhVersion: freezed == p2PkhVersion
          ? _value.p2PkhVersion
          : p2PkhVersion // ignore: cast_nullable_to_non_nullable
              as int?,
      p2ShVersion: freezed == p2ShVersion
          ? _value.p2ShVersion
          : p2ShVersion // ignore: cast_nullable_to_non_nullable
              as int?,
      policyAsset: freezed == policyAsset
          ? _value.policyAsset
          : policyAsset // ignore: cast_nullable_to_non_nullable
              as String?,
      serverType: freezed == serverType
          ? _value.serverType
          : serverType // ignore: cast_nullable_to_non_nullable
              as ServerTypeEnum?,
      serviceChainCode: freezed == serviceChainCode
          ? _value.serviceChainCode
          : serviceChainCode // ignore: cast_nullable_to_non_nullable
              as String?,
      servicePubkey: freezed == servicePubkey
          ? _value.servicePubkey
          : servicePubkey // ignore: cast_nullable_to_non_nullable
              as String?,
      spvEnabled: freezed == spvEnabled
          ? _value.spvEnabled
          : spvEnabled // ignore: cast_nullable_to_non_nullable
              as bool?,
      spvMulti: freezed == spvMulti
          ? _value.spvMulti
          : spvMulti // ignore: cast_nullable_to_non_nullable
              as bool?,
      spvServers: freezed == spvServers
          ? _value._spvServers
          : spvServers // ignore: cast_nullable_to_non_nullable
              as List<dynamic>?,
      txExplorerUrl: freezed == txExplorerUrl
          ? _value.txExplorerUrl
          : txExplorerUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      wampCertPins: freezed == wampCertPins
          ? _value._wampCertPins
          : wampCertPins // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      wampCertRoots: freezed == wampCertRoots
          ? _value._wampCertRoots
          : wampCertRoots // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      wampOnionUrl: freezed == wampOnionUrl
          ? _value.wampOnionUrl
          : wampOnionUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      wampUrl: freezed == wampUrl
          ? _value.wampUrl
          : wampUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkNetworkImpl extends _GdkNetwork {
  const _$GdkNetworkImpl(
      {@JsonKey(name: 'address_explorer_url') this.addressExplorerUrl,
      @JsonKey(name: 'address_registry_onion_url') this.assetRegistryOnionUrl,
      @JsonKey(name: 'asset_registry_url') this.assetRegistryUrl,
      @JsonKey(name: 'bech32_prefix') this.bech32Prefix,
      @JsonKey(name: 'bip21_prefix') this.bip21Prefix,
      @JsonKey(name: 'blech32_prefix') this.blech32Prefix,
      @JsonKey(name: 'blinded_prefix') this.blindedPrefix,
      @JsonKey(name: 'csv_buckets') final List<int>? csvBuckets,
      @JsonKey(name: 'ct_bits') this.ctBits,
      @JsonKey(name: 'ct_exponent') this.ctExponent,
      this.development,
      @JsonKey(name: 'electrum_tls') this.electrumTls,
      @JsonKey(name: 'electrum_url') this.electrumUrl,
      this.liquid,
      this.mainnet,
      this.name,
      this.network,
      @JsonKey(name: 'p2pkh_version') this.p2PkhVersion,
      @JsonKey(name: 'p2sh_version') this.p2ShVersion,
      @JsonKey(name: 'policy_asset') this.policyAsset,
      @JsonKey(name: 'server_type') this.serverType,
      @JsonKey(name: 'service_chain_code') this.serviceChainCode,
      @JsonKey(name: 'service_pubkey') this.servicePubkey,
      @JsonKey(name: 'spv_enabled') this.spvEnabled,
      @JsonKey(name: 'spv_multi') this.spvMulti,
      @JsonKey(name: 'spv_servers') final List<dynamic>? spvServers,
      @JsonKey(name: 'tx_explorer_url') this.txExplorerUrl,
      @JsonKey(name: 'wamp_cert_pins') final List<String>? wampCertPins,
      @JsonKey(name: 'wamp_cert_roots') final List<String>? wampCertRoots,
      @JsonKey(name: 'wamp_onion_url') this.wampOnionUrl,
      @JsonKey(name: 'wamp_url') this.wampUrl})
      : _csvBuckets = csvBuckets,
        _spvServers = spvServers,
        _wampCertPins = wampCertPins,
        _wampCertRoots = wampCertRoots,
        super._();

  factory _$GdkNetworkImpl.fromJson(Map<String, dynamic> json) =>
      _$$GdkNetworkImplFromJson(json);

  @override
  @JsonKey(name: 'address_explorer_url')
  final String? addressExplorerUrl;
  @override
  @JsonKey(name: 'address_registry_onion_url')
  final String? assetRegistryOnionUrl;
  @override
  @JsonKey(name: 'asset_registry_url')
  final String? assetRegistryUrl;
  @override
  @JsonKey(name: 'bech32_prefix')
  final String? bech32Prefix;
  @override
  @JsonKey(name: 'bip21_prefix')
  final String? bip21Prefix;
  @override
  @JsonKey(name: 'blech32_prefix')
  final String? blech32Prefix;
  @override
  @JsonKey(name: 'blinded_prefix')
  final int? blindedPrefix;
  final List<int>? _csvBuckets;
  @override
  @JsonKey(name: 'csv_buckets')
  List<int>? get csvBuckets {
    final value = _csvBuckets;
    if (value == null) return null;
    if (_csvBuckets is EqualUnmodifiableListView) return _csvBuckets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'ct_bits')
  final int? ctBits;
  @override
  @JsonKey(name: 'ct_exponent')
  final int? ctExponent;
  @override
  final bool? development;
  @override
  @JsonKey(name: 'electrum_tls')
  final bool? electrumTls;
  @override
  @JsonKey(name: 'electrum_url')
  final String? electrumUrl;
  @override
  final bool? liquid;
  @override
  final bool? mainnet;
  @override
  final String? name;
  @override
  final String? network;
  @override
  @JsonKey(name: 'p2pkh_version')
  final int? p2PkhVersion;
  @override
  @JsonKey(name: 'p2sh_version')
  final int? p2ShVersion;
  @override
  @JsonKey(name: 'policy_asset')
  final String? policyAsset;
  @override
  @JsonKey(name: 'server_type')
  final ServerTypeEnum? serverType;
  @override
  @JsonKey(name: 'service_chain_code')
  final String? serviceChainCode;
  @override
  @JsonKey(name: 'service_pubkey')
  final String? servicePubkey;
  @override
  @JsonKey(name: 'spv_enabled')
  final bool? spvEnabled;
  @override
  @JsonKey(name: 'spv_multi')
  final bool? spvMulti;
  final List<dynamic>? _spvServers;
  @override
  @JsonKey(name: 'spv_servers')
  List<dynamic>? get spvServers {
    final value = _spvServers;
    if (value == null) return null;
    if (_spvServers is EqualUnmodifiableListView) return _spvServers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'tx_explorer_url')
  final String? txExplorerUrl;
  final List<String>? _wampCertPins;
  @override
  @JsonKey(name: 'wamp_cert_pins')
  List<String>? get wampCertPins {
    final value = _wampCertPins;
    if (value == null) return null;
    if (_wampCertPins is EqualUnmodifiableListView) return _wampCertPins;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _wampCertRoots;
  @override
  @JsonKey(name: 'wamp_cert_roots')
  List<String>? get wampCertRoots {
    final value = _wampCertRoots;
    if (value == null) return null;
    if (_wampCertRoots is EqualUnmodifiableListView) return _wampCertRoots;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'wamp_onion_url')
  final String? wampOnionUrl;
  @override
  @JsonKey(name: 'wamp_url')
  final String? wampUrl;

  @override
  String toString() {
    return 'GdkNetwork(addressExplorerUrl: $addressExplorerUrl, assetRegistryOnionUrl: $assetRegistryOnionUrl, assetRegistryUrl: $assetRegistryUrl, bech32Prefix: $bech32Prefix, bip21Prefix: $bip21Prefix, blech32Prefix: $blech32Prefix, blindedPrefix: $blindedPrefix, csvBuckets: $csvBuckets, ctBits: $ctBits, ctExponent: $ctExponent, development: $development, electrumTls: $electrumTls, electrumUrl: $electrumUrl, liquid: $liquid, mainnet: $mainnet, name: $name, network: $network, p2PkhVersion: $p2PkhVersion, p2ShVersion: $p2ShVersion, policyAsset: $policyAsset, serverType: $serverType, serviceChainCode: $serviceChainCode, servicePubkey: $servicePubkey, spvEnabled: $spvEnabled, spvMulti: $spvMulti, spvServers: $spvServers, txExplorerUrl: $txExplorerUrl, wampCertPins: $wampCertPins, wampCertRoots: $wampCertRoots, wampOnionUrl: $wampOnionUrl, wampUrl: $wampUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkNetworkImpl &&
            (identical(other.addressExplorerUrl, addressExplorerUrl) ||
                other.addressExplorerUrl == addressExplorerUrl) &&
            (identical(other.assetRegistryOnionUrl, assetRegistryOnionUrl) ||
                other.assetRegistryOnionUrl == assetRegistryOnionUrl) &&
            (identical(other.assetRegistryUrl, assetRegistryUrl) ||
                other.assetRegistryUrl == assetRegistryUrl) &&
            (identical(other.bech32Prefix, bech32Prefix) ||
                other.bech32Prefix == bech32Prefix) &&
            (identical(other.bip21Prefix, bip21Prefix) ||
                other.bip21Prefix == bip21Prefix) &&
            (identical(other.blech32Prefix, blech32Prefix) ||
                other.blech32Prefix == blech32Prefix) &&
            (identical(other.blindedPrefix, blindedPrefix) ||
                other.blindedPrefix == blindedPrefix) &&
            const DeepCollectionEquality()
                .equals(other._csvBuckets, _csvBuckets) &&
            (identical(other.ctBits, ctBits) || other.ctBits == ctBits) &&
            (identical(other.ctExponent, ctExponent) ||
                other.ctExponent == ctExponent) &&
            (identical(other.development, development) ||
                other.development == development) &&
            (identical(other.electrumTls, electrumTls) ||
                other.electrumTls == electrumTls) &&
            (identical(other.electrumUrl, electrumUrl) ||
                other.electrumUrl == electrumUrl) &&
            (identical(other.liquid, liquid) || other.liquid == liquid) &&
            (identical(other.mainnet, mainnet) || other.mainnet == mainnet) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.network, network) || other.network == network) &&
            (identical(other.p2PkhVersion, p2PkhVersion) ||
                other.p2PkhVersion == p2PkhVersion) &&
            (identical(other.p2ShVersion, p2ShVersion) ||
                other.p2ShVersion == p2ShVersion) &&
            (identical(other.policyAsset, policyAsset) ||
                other.policyAsset == policyAsset) &&
            (identical(other.serverType, serverType) ||
                other.serverType == serverType) &&
            (identical(other.serviceChainCode, serviceChainCode) ||
                other.serviceChainCode == serviceChainCode) &&
            (identical(other.servicePubkey, servicePubkey) ||
                other.servicePubkey == servicePubkey) &&
            (identical(other.spvEnabled, spvEnabled) ||
                other.spvEnabled == spvEnabled) &&
            (identical(other.spvMulti, spvMulti) ||
                other.spvMulti == spvMulti) &&
            const DeepCollectionEquality()
                .equals(other._spvServers, _spvServers) &&
            (identical(other.txExplorerUrl, txExplorerUrl) ||
                other.txExplorerUrl == txExplorerUrl) &&
            const DeepCollectionEquality()
                .equals(other._wampCertPins, _wampCertPins) &&
            const DeepCollectionEquality()
                .equals(other._wampCertRoots, _wampCertRoots) &&
            (identical(other.wampOnionUrl, wampOnionUrl) ||
                other.wampOnionUrl == wampOnionUrl) &&
            (identical(other.wampUrl, wampUrl) || other.wampUrl == wampUrl));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        addressExplorerUrl,
        assetRegistryOnionUrl,
        assetRegistryUrl,
        bech32Prefix,
        bip21Prefix,
        blech32Prefix,
        blindedPrefix,
        const DeepCollectionEquality().hash(_csvBuckets),
        ctBits,
        ctExponent,
        development,
        electrumTls,
        electrumUrl,
        liquid,
        mainnet,
        name,
        network,
        p2PkhVersion,
        p2ShVersion,
        policyAsset,
        serverType,
        serviceChainCode,
        servicePubkey,
        spvEnabled,
        spvMulti,
        const DeepCollectionEquality().hash(_spvServers),
        txExplorerUrl,
        const DeepCollectionEquality().hash(_wampCertPins),
        const DeepCollectionEquality().hash(_wampCertRoots),
        wampOnionUrl,
        wampUrl
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkNetworkImplCopyWith<_$GdkNetworkImpl> get copyWith =>
      __$$GdkNetworkImplCopyWithImpl<_$GdkNetworkImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkNetworkImplToJson(
      this,
    );
  }
}

abstract class _GdkNetwork extends GdkNetwork {
  const factory _GdkNetwork(
      {@JsonKey(name: 'address_explorer_url') final String? addressExplorerUrl,
      @JsonKey(name: 'address_registry_onion_url')
      final String? assetRegistryOnionUrl,
      @JsonKey(name: 'asset_registry_url') final String? assetRegistryUrl,
      @JsonKey(name: 'bech32_prefix') final String? bech32Prefix,
      @JsonKey(name: 'bip21_prefix') final String? bip21Prefix,
      @JsonKey(name: 'blech32_prefix') final String? blech32Prefix,
      @JsonKey(name: 'blinded_prefix') final int? blindedPrefix,
      @JsonKey(name: 'csv_buckets') final List<int>? csvBuckets,
      @JsonKey(name: 'ct_bits') final int? ctBits,
      @JsonKey(name: 'ct_exponent') final int? ctExponent,
      final bool? development,
      @JsonKey(name: 'electrum_tls') final bool? electrumTls,
      @JsonKey(name: 'electrum_url') final String? electrumUrl,
      final bool? liquid,
      final bool? mainnet,
      final String? name,
      final String? network,
      @JsonKey(name: 'p2pkh_version') final int? p2PkhVersion,
      @JsonKey(name: 'p2sh_version') final int? p2ShVersion,
      @JsonKey(name: 'policy_asset') final String? policyAsset,
      @JsonKey(name: 'server_type') final ServerTypeEnum? serverType,
      @JsonKey(name: 'service_chain_code') final String? serviceChainCode,
      @JsonKey(name: 'service_pubkey') final String? servicePubkey,
      @JsonKey(name: 'spv_enabled') final bool? spvEnabled,
      @JsonKey(name: 'spv_multi') final bool? spvMulti,
      @JsonKey(name: 'spv_servers') final List<dynamic>? spvServers,
      @JsonKey(name: 'tx_explorer_url') final String? txExplorerUrl,
      @JsonKey(name: 'wamp_cert_pins') final List<String>? wampCertPins,
      @JsonKey(name: 'wamp_cert_roots') final List<String>? wampCertRoots,
      @JsonKey(name: 'wamp_onion_url') final String? wampOnionUrl,
      @JsonKey(name: 'wamp_url') final String? wampUrl}) = _$GdkNetworkImpl;
  const _GdkNetwork._() : super._();

  factory _GdkNetwork.fromJson(Map<String, dynamic> json) =
      _$GdkNetworkImpl.fromJson;

  @override
  @JsonKey(name: 'address_explorer_url')
  String? get addressExplorerUrl;
  @override
  @JsonKey(name: 'address_registry_onion_url')
  String? get assetRegistryOnionUrl;
  @override
  @JsonKey(name: 'asset_registry_url')
  String? get assetRegistryUrl;
  @override
  @JsonKey(name: 'bech32_prefix')
  String? get bech32Prefix;
  @override
  @JsonKey(name: 'bip21_prefix')
  String? get bip21Prefix;
  @override
  @JsonKey(name: 'blech32_prefix')
  String? get blech32Prefix;
  @override
  @JsonKey(name: 'blinded_prefix')
  int? get blindedPrefix;
  @override
  @JsonKey(name: 'csv_buckets')
  List<int>? get csvBuckets;
  @override
  @JsonKey(name: 'ct_bits')
  int? get ctBits;
  @override
  @JsonKey(name: 'ct_exponent')
  int? get ctExponent;
  @override
  bool? get development;
  @override
  @JsonKey(name: 'electrum_tls')
  bool? get electrumTls;
  @override
  @JsonKey(name: 'electrum_url')
  String? get electrumUrl;
  @override
  bool? get liquid;
  @override
  bool? get mainnet;
  @override
  String? get name;
  @override
  String? get network;
  @override
  @JsonKey(name: 'p2pkh_version')
  int? get p2PkhVersion;
  @override
  @JsonKey(name: 'p2sh_version')
  int? get p2ShVersion;
  @override
  @JsonKey(name: 'policy_asset')
  String? get policyAsset;
  @override
  @JsonKey(name: 'server_type')
  ServerTypeEnum? get serverType;
  @override
  @JsonKey(name: 'service_chain_code')
  String? get serviceChainCode;
  @override
  @JsonKey(name: 'service_pubkey')
  String? get servicePubkey;
  @override
  @JsonKey(name: 'spv_enabled')
  bool? get spvEnabled;
  @override
  @JsonKey(name: 'spv_multi')
  bool? get spvMulti;
  @override
  @JsonKey(name: 'spv_servers')
  List<dynamic>? get spvServers;
  @override
  @JsonKey(name: 'tx_explorer_url')
  String? get txExplorerUrl;
  @override
  @JsonKey(name: 'wamp_cert_pins')
  List<String>? get wampCertPins;
  @override
  @JsonKey(name: 'wamp_cert_roots')
  List<String>? get wampCertRoots;
  @override
  @JsonKey(name: 'wamp_onion_url')
  String? get wampOnionUrl;
  @override
  @JsonKey(name: 'wamp_url')
  String? get wampUrl;
  @override
  @JsonKey(ignore: true)
  _$$GdkNetworkImplCopyWith<_$GdkNetworkImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GdkWallet _$GdkWalletFromJson(Map<String, dynamic> json) {
  return _GdkWallet.fromJson(json);
}

/// @nodoc
mixin _$GdkWallet {
  @JsonKey(name: 'has_transactions')
  bool? get hasTransactions => throw _privateConstructorUsedError;
  bool? get hidden => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  int? get pointer => throw _privateConstructorUsedError;
  @JsonKey(name: 'receiving_id')
  String? get receivingId => throw _privateConstructorUsedError;
  @JsonKey(name: 'required_ca')
  int? get requiredCa => throw _privateConstructorUsedError;
  Map<String, int>? get satoshi => throw _privateConstructorUsedError;
  String? get type => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkWalletCopyWith<GdkWallet> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkWalletCopyWith<$Res> {
  factory $GdkWalletCopyWith(GdkWallet value, $Res Function(GdkWallet) then) =
      _$GdkWalletCopyWithImpl<$Res, GdkWallet>;
  @useResult
  $Res call(
      {@JsonKey(name: 'has_transactions') bool? hasTransactions,
      bool? hidden,
      String? name,
      int? pointer,
      @JsonKey(name: 'receiving_id') String? receivingId,
      @JsonKey(name: 'required_ca') int? requiredCa,
      Map<String, int>? satoshi,
      String? type});
}

/// @nodoc
class _$GdkWalletCopyWithImpl<$Res, $Val extends GdkWallet>
    implements $GdkWalletCopyWith<$Res> {
  _$GdkWalletCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hasTransactions = freezed,
    Object? hidden = freezed,
    Object? name = freezed,
    Object? pointer = freezed,
    Object? receivingId = freezed,
    Object? requiredCa = freezed,
    Object? satoshi = freezed,
    Object? type = freezed,
  }) {
    return _then(_value.copyWith(
      hasTransactions: freezed == hasTransactions
          ? _value.hasTransactions
          : hasTransactions // ignore: cast_nullable_to_non_nullable
              as bool?,
      hidden: freezed == hidden
          ? _value.hidden
          : hidden // ignore: cast_nullable_to_non_nullable
              as bool?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      pointer: freezed == pointer
          ? _value.pointer
          : pointer // ignore: cast_nullable_to_non_nullable
              as int?,
      receivingId: freezed == receivingId
          ? _value.receivingId
          : receivingId // ignore: cast_nullable_to_non_nullable
              as String?,
      requiredCa: freezed == requiredCa
          ? _value.requiredCa
          : requiredCa // ignore: cast_nullable_to_non_nullable
              as int?,
      satoshi: freezed == satoshi
          ? _value.satoshi
          : satoshi // ignore: cast_nullable_to_non_nullable
              as Map<String, int>?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GdkWalletImplCopyWith<$Res>
    implements $GdkWalletCopyWith<$Res> {
  factory _$$GdkWalletImplCopyWith(
          _$GdkWalletImpl value, $Res Function(_$GdkWalletImpl) then) =
      __$$GdkWalletImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'has_transactions') bool? hasTransactions,
      bool? hidden,
      String? name,
      int? pointer,
      @JsonKey(name: 'receiving_id') String? receivingId,
      @JsonKey(name: 'required_ca') int? requiredCa,
      Map<String, int>? satoshi,
      String? type});
}

/// @nodoc
class __$$GdkWalletImplCopyWithImpl<$Res>
    extends _$GdkWalletCopyWithImpl<$Res, _$GdkWalletImpl>
    implements _$$GdkWalletImplCopyWith<$Res> {
  __$$GdkWalletImplCopyWithImpl(
      _$GdkWalletImpl _value, $Res Function(_$GdkWalletImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hasTransactions = freezed,
    Object? hidden = freezed,
    Object? name = freezed,
    Object? pointer = freezed,
    Object? receivingId = freezed,
    Object? requiredCa = freezed,
    Object? satoshi = freezed,
    Object? type = freezed,
  }) {
    return _then(_$GdkWalletImpl(
      hasTransactions: freezed == hasTransactions
          ? _value.hasTransactions
          : hasTransactions // ignore: cast_nullable_to_non_nullable
              as bool?,
      hidden: freezed == hidden
          ? _value.hidden
          : hidden // ignore: cast_nullable_to_non_nullable
              as bool?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      pointer: freezed == pointer
          ? _value.pointer
          : pointer // ignore: cast_nullable_to_non_nullable
              as int?,
      receivingId: freezed == receivingId
          ? _value.receivingId
          : receivingId // ignore: cast_nullable_to_non_nullable
              as String?,
      requiredCa: freezed == requiredCa
          ? _value.requiredCa
          : requiredCa // ignore: cast_nullable_to_non_nullable
              as int?,
      satoshi: freezed == satoshi
          ? _value._satoshi
          : satoshi // ignore: cast_nullable_to_non_nullable
              as Map<String, int>?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkWalletImpl implements _GdkWallet {
  const _$GdkWalletImpl(
      {@JsonKey(name: 'has_transactions') this.hasTransactions,
      this.hidden,
      this.name,
      this.pointer,
      @JsonKey(name: 'receiving_id') this.receivingId,
      @JsonKey(name: 'required_ca') this.requiredCa,
      final Map<String, int>? satoshi,
      this.type})
      : _satoshi = satoshi;

  factory _$GdkWalletImpl.fromJson(Map<String, dynamic> json) =>
      _$$GdkWalletImplFromJson(json);

  @override
  @JsonKey(name: 'has_transactions')
  final bool? hasTransactions;
  @override
  final bool? hidden;
  @override
  final String? name;
  @override
  final int? pointer;
  @override
  @JsonKey(name: 'receiving_id')
  final String? receivingId;
  @override
  @JsonKey(name: 'required_ca')
  final int? requiredCa;
  final Map<String, int>? _satoshi;
  @override
  Map<String, int>? get satoshi {
    final value = _satoshi;
    if (value == null) return null;
    if (_satoshi is EqualUnmodifiableMapView) return _satoshi;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? type;

  @override
  String toString() {
    return 'GdkWallet(hasTransactions: $hasTransactions, hidden: $hidden, name: $name, pointer: $pointer, receivingId: $receivingId, requiredCa: $requiredCa, satoshi: $satoshi, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkWalletImpl &&
            (identical(other.hasTransactions, hasTransactions) ||
                other.hasTransactions == hasTransactions) &&
            (identical(other.hidden, hidden) || other.hidden == hidden) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.pointer, pointer) || other.pointer == pointer) &&
            (identical(other.receivingId, receivingId) ||
                other.receivingId == receivingId) &&
            (identical(other.requiredCa, requiredCa) ||
                other.requiredCa == requiredCa) &&
            const DeepCollectionEquality().equals(other._satoshi, _satoshi) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      hasTransactions,
      hidden,
      name,
      pointer,
      receivingId,
      requiredCa,
      const DeepCollectionEquality().hash(_satoshi),
      type);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkWalletImplCopyWith<_$GdkWalletImpl> get copyWith =>
      __$$GdkWalletImplCopyWithImpl<_$GdkWalletImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkWalletImplToJson(
      this,
    );
  }
}

abstract class _GdkWallet implements GdkWallet {
  const factory _GdkWallet(
      {@JsonKey(name: 'has_transactions') final bool? hasTransactions,
      final bool? hidden,
      final String? name,
      final int? pointer,
      @JsonKey(name: 'receiving_id') final String? receivingId,
      @JsonKey(name: 'required_ca') final int? requiredCa,
      final Map<String, int>? satoshi,
      final String? type}) = _$GdkWalletImpl;

  factory _GdkWallet.fromJson(Map<String, dynamic> json) =
      _$GdkWalletImpl.fromJson;

  @override
  @JsonKey(name: 'has_transactions')
  bool? get hasTransactions;
  @override
  bool? get hidden;
  @override
  String? get name;
  @override
  int? get pointer;
  @override
  @JsonKey(name: 'receiving_id')
  String? get receivingId;
  @override
  @JsonKey(name: 'required_ca')
  int? get requiredCa;
  @override
  Map<String, int>? get satoshi;
  @override
  String? get type;
  @override
  @JsonKey(ignore: true)
  _$$GdkWalletImplCopyWith<_$GdkWalletImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GdkReceiveAddressDetails _$GdkReceiveAddressDetailsFromJson(
    Map<String, dynamic> json) {
  return _GdkReceiveAddressDetails.fromJson(json);
}

/// @nodoc
mixin _$GdkReceiveAddressDetails {
  String? get address => throw _privateConstructorUsedError;
  @JsonKey(name: 'address_type', defaultValue: GdkAddressTypeEnum.csv)
  GdkAddressTypeEnum? get addressType => throw _privateConstructorUsedError;
  int? get branch => throw _privateConstructorUsedError;
  int? get pointer => throw _privateConstructorUsedError;
  String? get script => throw _privateConstructorUsedError;
  @JsonKey(name: 'script_type')
  int? get scriptType => throw _privateConstructorUsedError;
  int? get subaccount => throw _privateConstructorUsedError;
  int? get subtype => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_path')
  List<int>? get userPath => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkReceiveAddressDetailsCopyWith<GdkReceiveAddressDetails> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkReceiveAddressDetailsCopyWith<$Res> {
  factory $GdkReceiveAddressDetailsCopyWith(GdkReceiveAddressDetails value,
          $Res Function(GdkReceiveAddressDetails) then) =
      _$GdkReceiveAddressDetailsCopyWithImpl<$Res, GdkReceiveAddressDetails>;
  @useResult
  $Res call(
      {String? address,
      @JsonKey(name: 'address_type', defaultValue: GdkAddressTypeEnum.csv)
      GdkAddressTypeEnum? addressType,
      int? branch,
      int? pointer,
      String? script,
      @JsonKey(name: 'script_type') int? scriptType,
      int? subaccount,
      int? subtype,
      @JsonKey(name: 'user_path') List<int>? userPath});
}

/// @nodoc
class _$GdkReceiveAddressDetailsCopyWithImpl<$Res,
        $Val extends GdkReceiveAddressDetails>
    implements $GdkReceiveAddressDetailsCopyWith<$Res> {
  _$GdkReceiveAddressDetailsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? address = freezed,
    Object? addressType = freezed,
    Object? branch = freezed,
    Object? pointer = freezed,
    Object? script = freezed,
    Object? scriptType = freezed,
    Object? subaccount = freezed,
    Object? subtype = freezed,
    Object? userPath = freezed,
  }) {
    return _then(_value.copyWith(
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      addressType: freezed == addressType
          ? _value.addressType
          : addressType // ignore: cast_nullable_to_non_nullable
              as GdkAddressTypeEnum?,
      branch: freezed == branch
          ? _value.branch
          : branch // ignore: cast_nullable_to_non_nullable
              as int?,
      pointer: freezed == pointer
          ? _value.pointer
          : pointer // ignore: cast_nullable_to_non_nullable
              as int?,
      script: freezed == script
          ? _value.script
          : script // ignore: cast_nullable_to_non_nullable
              as String?,
      scriptType: freezed == scriptType
          ? _value.scriptType
          : scriptType // ignore: cast_nullable_to_non_nullable
              as int?,
      subaccount: freezed == subaccount
          ? _value.subaccount
          : subaccount // ignore: cast_nullable_to_non_nullable
              as int?,
      subtype: freezed == subtype
          ? _value.subtype
          : subtype // ignore: cast_nullable_to_non_nullable
              as int?,
      userPath: freezed == userPath
          ? _value.userPath
          : userPath // ignore: cast_nullable_to_non_nullable
              as List<int>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GdkReceiveAddressDetailsImplCopyWith<$Res>
    implements $GdkReceiveAddressDetailsCopyWith<$Res> {
  factory _$$GdkReceiveAddressDetailsImplCopyWith(
          _$GdkReceiveAddressDetailsImpl value,
          $Res Function(_$GdkReceiveAddressDetailsImpl) then) =
      __$$GdkReceiveAddressDetailsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? address,
      @JsonKey(name: 'address_type', defaultValue: GdkAddressTypeEnum.csv)
      GdkAddressTypeEnum? addressType,
      int? branch,
      int? pointer,
      String? script,
      @JsonKey(name: 'script_type') int? scriptType,
      int? subaccount,
      int? subtype,
      @JsonKey(name: 'user_path') List<int>? userPath});
}

/// @nodoc
class __$$GdkReceiveAddressDetailsImplCopyWithImpl<$Res>
    extends _$GdkReceiveAddressDetailsCopyWithImpl<$Res,
        _$GdkReceiveAddressDetailsImpl>
    implements _$$GdkReceiveAddressDetailsImplCopyWith<$Res> {
  __$$GdkReceiveAddressDetailsImplCopyWithImpl(
      _$GdkReceiveAddressDetailsImpl _value,
      $Res Function(_$GdkReceiveAddressDetailsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? address = freezed,
    Object? addressType = freezed,
    Object? branch = freezed,
    Object? pointer = freezed,
    Object? script = freezed,
    Object? scriptType = freezed,
    Object? subaccount = freezed,
    Object? subtype = freezed,
    Object? userPath = freezed,
  }) {
    return _then(_$GdkReceiveAddressDetailsImpl(
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      addressType: freezed == addressType
          ? _value.addressType
          : addressType // ignore: cast_nullable_to_non_nullable
              as GdkAddressTypeEnum?,
      branch: freezed == branch
          ? _value.branch
          : branch // ignore: cast_nullable_to_non_nullable
              as int?,
      pointer: freezed == pointer
          ? _value.pointer
          : pointer // ignore: cast_nullable_to_non_nullable
              as int?,
      script: freezed == script
          ? _value.script
          : script // ignore: cast_nullable_to_non_nullable
              as String?,
      scriptType: freezed == scriptType
          ? _value.scriptType
          : scriptType // ignore: cast_nullable_to_non_nullable
              as int?,
      subaccount: freezed == subaccount
          ? _value.subaccount
          : subaccount // ignore: cast_nullable_to_non_nullable
              as int?,
      subtype: freezed == subtype
          ? _value.subtype
          : subtype // ignore: cast_nullable_to_non_nullable
              as int?,
      userPath: freezed == userPath
          ? _value._userPath
          : userPath // ignore: cast_nullable_to_non_nullable
              as List<int>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkReceiveAddressDetailsImpl extends _GdkReceiveAddressDetails {
  const _$GdkReceiveAddressDetailsImpl(
      {this.address,
      @JsonKey(name: 'address_type', defaultValue: GdkAddressTypeEnum.csv)
      this.addressType,
      this.branch,
      this.pointer,
      this.script,
      @JsonKey(name: 'script_type') this.scriptType,
      this.subaccount = 1,
      this.subtype,
      @JsonKey(name: 'user_path') final List<int>? userPath})
      : _userPath = userPath,
        super._();

  factory _$GdkReceiveAddressDetailsImpl.fromJson(Map<String, dynamic> json) =>
      _$$GdkReceiveAddressDetailsImplFromJson(json);

  @override
  final String? address;
  @override
  @JsonKey(name: 'address_type', defaultValue: GdkAddressTypeEnum.csv)
  final GdkAddressTypeEnum? addressType;
  @override
  final int? branch;
  @override
  final int? pointer;
  @override
  final String? script;
  @override
  @JsonKey(name: 'script_type')
  final int? scriptType;
  @override
  @JsonKey()
  final int? subaccount;
  @override
  final int? subtype;
  final List<int>? _userPath;
  @override
  @JsonKey(name: 'user_path')
  List<int>? get userPath {
    final value = _userPath;
    if (value == null) return null;
    if (_userPath is EqualUnmodifiableListView) return _userPath;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'GdkReceiveAddressDetails(address: $address, addressType: $addressType, branch: $branch, pointer: $pointer, script: $script, scriptType: $scriptType, subaccount: $subaccount, subtype: $subtype, userPath: $userPath)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkReceiveAddressDetailsImpl &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.addressType, addressType) ||
                other.addressType == addressType) &&
            (identical(other.branch, branch) || other.branch == branch) &&
            (identical(other.pointer, pointer) || other.pointer == pointer) &&
            (identical(other.script, script) || other.script == script) &&
            (identical(other.scriptType, scriptType) ||
                other.scriptType == scriptType) &&
            (identical(other.subaccount, subaccount) ||
                other.subaccount == subaccount) &&
            (identical(other.subtype, subtype) || other.subtype == subtype) &&
            const DeepCollectionEquality().equals(other._userPath, _userPath));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      address,
      addressType,
      branch,
      pointer,
      script,
      scriptType,
      subaccount,
      subtype,
      const DeepCollectionEquality().hash(_userPath));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkReceiveAddressDetailsImplCopyWith<_$GdkReceiveAddressDetailsImpl>
      get copyWith => __$$GdkReceiveAddressDetailsImplCopyWithImpl<
          _$GdkReceiveAddressDetailsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkReceiveAddressDetailsImplToJson(
      this,
    );
  }
}

abstract class _GdkReceiveAddressDetails extends GdkReceiveAddressDetails {
  const factory _GdkReceiveAddressDetails(
          {final String? address,
          @JsonKey(name: 'address_type', defaultValue: GdkAddressTypeEnum.csv)
          final GdkAddressTypeEnum? addressType,
          final int? branch,
          final int? pointer,
          final String? script,
          @JsonKey(name: 'script_type') final int? scriptType,
          final int? subaccount,
          final int? subtype,
          @JsonKey(name: 'user_path') final List<int>? userPath}) =
      _$GdkReceiveAddressDetailsImpl;
  const _GdkReceiveAddressDetails._() : super._();

  factory _GdkReceiveAddressDetails.fromJson(Map<String, dynamic> json) =
      _$GdkReceiveAddressDetailsImpl.fromJson;

  @override
  String? get address;
  @override
  @JsonKey(name: 'address_type', defaultValue: GdkAddressTypeEnum.csv)
  GdkAddressTypeEnum? get addressType;
  @override
  int? get branch;
  @override
  int? get pointer;
  @override
  String? get script;
  @override
  @JsonKey(name: 'script_type')
  int? get scriptType;
  @override
  int? get subaccount;
  @override
  int? get subtype;
  @override
  @JsonKey(name: 'user_path')
  List<int>? get userPath;
  @override
  @JsonKey(ignore: true)
  _$$GdkReceiveAddressDetailsImplCopyWith<_$GdkReceiveAddressDetailsImpl>
      get copyWith => throw _privateConstructorUsedError;
}

GdkPreviousAddressesDetails _$GdkPreviousAddressesDetailsFromJson(
    Map<String, dynamic> json) {
  return _GdkPreviousAddressesDetails.fromJson(json);
}

/// @nodoc
mixin _$GdkPreviousAddressesDetails {
  int get subaccount => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_pointer')
  int? get lastPointer => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_internal')
  bool? get isInternal => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkPreviousAddressesDetailsCopyWith<GdkPreviousAddressesDetails>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkPreviousAddressesDetailsCopyWith<$Res> {
  factory $GdkPreviousAddressesDetailsCopyWith(
          GdkPreviousAddressesDetails value,
          $Res Function(GdkPreviousAddressesDetails) then) =
      _$GdkPreviousAddressesDetailsCopyWithImpl<$Res,
          GdkPreviousAddressesDetails>;
  @useResult
  $Res call(
      {int subaccount,
      @JsonKey(name: 'last_pointer') int? lastPointer,
      @JsonKey(name: 'is_internal') bool? isInternal});
}

/// @nodoc
class _$GdkPreviousAddressesDetailsCopyWithImpl<$Res,
        $Val extends GdkPreviousAddressesDetails>
    implements $GdkPreviousAddressesDetailsCopyWith<$Res> {
  _$GdkPreviousAddressesDetailsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subaccount = null,
    Object? lastPointer = freezed,
    Object? isInternal = freezed,
  }) {
    return _then(_value.copyWith(
      subaccount: null == subaccount
          ? _value.subaccount
          : subaccount // ignore: cast_nullable_to_non_nullable
              as int,
      lastPointer: freezed == lastPointer
          ? _value.lastPointer
          : lastPointer // ignore: cast_nullable_to_non_nullable
              as int?,
      isInternal: freezed == isInternal
          ? _value.isInternal
          : isInternal // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GdkPreviousAddressesDetailsImplCopyWith<$Res>
    implements $GdkPreviousAddressesDetailsCopyWith<$Res> {
  factory _$$GdkPreviousAddressesDetailsImplCopyWith(
          _$GdkPreviousAddressesDetailsImpl value,
          $Res Function(_$GdkPreviousAddressesDetailsImpl) then) =
      __$$GdkPreviousAddressesDetailsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int subaccount,
      @JsonKey(name: 'last_pointer') int? lastPointer,
      @JsonKey(name: 'is_internal') bool? isInternal});
}

/// @nodoc
class __$$GdkPreviousAddressesDetailsImplCopyWithImpl<$Res>
    extends _$GdkPreviousAddressesDetailsCopyWithImpl<$Res,
        _$GdkPreviousAddressesDetailsImpl>
    implements _$$GdkPreviousAddressesDetailsImplCopyWith<$Res> {
  __$$GdkPreviousAddressesDetailsImplCopyWithImpl(
      _$GdkPreviousAddressesDetailsImpl _value,
      $Res Function(_$GdkPreviousAddressesDetailsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subaccount = null,
    Object? lastPointer = freezed,
    Object? isInternal = freezed,
  }) {
    return _then(_$GdkPreviousAddressesDetailsImpl(
      subaccount: null == subaccount
          ? _value.subaccount
          : subaccount // ignore: cast_nullable_to_non_nullable
              as int,
      lastPointer: freezed == lastPointer
          ? _value.lastPointer
          : lastPointer // ignore: cast_nullable_to_non_nullable
              as int?,
      isInternal: freezed == isInternal
          ? _value.isInternal
          : isInternal // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkPreviousAddressesDetailsImpl extends _GdkPreviousAddressesDetails {
  const _$GdkPreviousAddressesDetailsImpl(
      {this.subaccount = 0,
      @JsonKey(name: 'last_pointer') this.lastPointer,
      @JsonKey(name: 'is_internal') this.isInternal})
      : super._();

  factory _$GdkPreviousAddressesDetailsImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$GdkPreviousAddressesDetailsImplFromJson(json);

  @override
  @JsonKey()
  final int subaccount;
  @override
  @JsonKey(name: 'last_pointer')
  final int? lastPointer;
  @override
  @JsonKey(name: 'is_internal')
  final bool? isInternal;

  @override
  String toString() {
    return 'GdkPreviousAddressesDetails(subaccount: $subaccount, lastPointer: $lastPointer, isInternal: $isInternal)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkPreviousAddressesDetailsImpl &&
            (identical(other.subaccount, subaccount) ||
                other.subaccount == subaccount) &&
            (identical(other.lastPointer, lastPointer) ||
                other.lastPointer == lastPointer) &&
            (identical(other.isInternal, isInternal) ||
                other.isInternal == isInternal));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, subaccount, lastPointer, isInternal);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkPreviousAddressesDetailsImplCopyWith<_$GdkPreviousAddressesDetailsImpl>
      get copyWith => __$$GdkPreviousAddressesDetailsImplCopyWithImpl<
          _$GdkPreviousAddressesDetailsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkPreviousAddressesDetailsImplToJson(
      this,
    );
  }
}

abstract class _GdkPreviousAddressesDetails
    extends GdkPreviousAddressesDetails {
  const factory _GdkPreviousAddressesDetails(
          {final int subaccount,
          @JsonKey(name: 'last_pointer') final int? lastPointer,
          @JsonKey(name: 'is_internal') final bool? isInternal}) =
      _$GdkPreviousAddressesDetailsImpl;
  const _GdkPreviousAddressesDetails._() : super._();

  factory _GdkPreviousAddressesDetails.fromJson(Map<String, dynamic> json) =
      _$GdkPreviousAddressesDetailsImpl.fromJson;

  @override
  int get subaccount;
  @override
  @JsonKey(name: 'last_pointer')
  int? get lastPointer;
  @override
  @JsonKey(name: 'is_internal')
  bool? get isInternal;
  @override
  @JsonKey(ignore: true)
  _$$GdkPreviousAddressesDetailsImplCopyWith<_$GdkPreviousAddressesDetailsImpl>
      get copyWith => throw _privateConstructorUsedError;
}

GdkPreviousAddress _$GdkPreviousAddressFromJson(Map<String, dynamic> json) {
  return _GdkPreviousAddress.fromJson(json);
}

/// @nodoc
mixin _$GdkPreviousAddress {
  @JsonKey(name: 'address')
  String? get address => throw _privateConstructorUsedError;
  @JsonKey(name: 'address_type')
  String? get addressType => throw _privateConstructorUsedError;
  @JsonKey(name: 'subaccount')
  int? get subaccount => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_internal')
  bool? get isInternal => throw _privateConstructorUsedError;
  @JsonKey(name: 'pointer')
  int? get pointer => throw _privateConstructorUsedError;
  @JsonKey(name: 'script_pubkey')
  String? get scriptPubkey => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_path')
  List<int>? get userPath => throw _privateConstructorUsedError;
  @JsonKey(name: 'tx_count')
  int? get txCount => throw _privateConstructorUsedError; // For liquid only
  @JsonKey(name: 'is_blinded')
  bool? get isBlinded => throw _privateConstructorUsedError;
  @JsonKey(name: 'unblinded_address')
  String? get unblindedAddress => throw _privateConstructorUsedError;
  @JsonKey(name: 'blinding_script')
  String? get blindingScript => throw _privateConstructorUsedError;
  @JsonKey(name: 'blinding_key')
  String? get blindingKey => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkPreviousAddressCopyWith<GdkPreviousAddress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkPreviousAddressCopyWith<$Res> {
  factory $GdkPreviousAddressCopyWith(
          GdkPreviousAddress value, $Res Function(GdkPreviousAddress) then) =
      _$GdkPreviousAddressCopyWithImpl<$Res, GdkPreviousAddress>;
  @useResult
  $Res call(
      {@JsonKey(name: 'address') String? address,
      @JsonKey(name: 'address_type') String? addressType,
      @JsonKey(name: 'subaccount') int? subaccount,
      @JsonKey(name: 'is_internal') bool? isInternal,
      @JsonKey(name: 'pointer') int? pointer,
      @JsonKey(name: 'script_pubkey') String? scriptPubkey,
      @JsonKey(name: 'user_path') List<int>? userPath,
      @JsonKey(name: 'tx_count') int? txCount,
      @JsonKey(name: 'is_blinded') bool? isBlinded,
      @JsonKey(name: 'unblinded_address') String? unblindedAddress,
      @JsonKey(name: 'blinding_script') String? blindingScript,
      @JsonKey(name: 'blinding_key') String? blindingKey});
}

/// @nodoc
class _$GdkPreviousAddressCopyWithImpl<$Res, $Val extends GdkPreviousAddress>
    implements $GdkPreviousAddressCopyWith<$Res> {
  _$GdkPreviousAddressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? address = freezed,
    Object? addressType = freezed,
    Object? subaccount = freezed,
    Object? isInternal = freezed,
    Object? pointer = freezed,
    Object? scriptPubkey = freezed,
    Object? userPath = freezed,
    Object? txCount = freezed,
    Object? isBlinded = freezed,
    Object? unblindedAddress = freezed,
    Object? blindingScript = freezed,
    Object? blindingKey = freezed,
  }) {
    return _then(_value.copyWith(
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      addressType: freezed == addressType
          ? _value.addressType
          : addressType // ignore: cast_nullable_to_non_nullable
              as String?,
      subaccount: freezed == subaccount
          ? _value.subaccount
          : subaccount // ignore: cast_nullable_to_non_nullable
              as int?,
      isInternal: freezed == isInternal
          ? _value.isInternal
          : isInternal // ignore: cast_nullable_to_non_nullable
              as bool?,
      pointer: freezed == pointer
          ? _value.pointer
          : pointer // ignore: cast_nullable_to_non_nullable
              as int?,
      scriptPubkey: freezed == scriptPubkey
          ? _value.scriptPubkey
          : scriptPubkey // ignore: cast_nullable_to_non_nullable
              as String?,
      userPath: freezed == userPath
          ? _value.userPath
          : userPath // ignore: cast_nullable_to_non_nullable
              as List<int>?,
      txCount: freezed == txCount
          ? _value.txCount
          : txCount // ignore: cast_nullable_to_non_nullable
              as int?,
      isBlinded: freezed == isBlinded
          ? _value.isBlinded
          : isBlinded // ignore: cast_nullable_to_non_nullable
              as bool?,
      unblindedAddress: freezed == unblindedAddress
          ? _value.unblindedAddress
          : unblindedAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      blindingScript: freezed == blindingScript
          ? _value.blindingScript
          : blindingScript // ignore: cast_nullable_to_non_nullable
              as String?,
      blindingKey: freezed == blindingKey
          ? _value.blindingKey
          : blindingKey // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GdkPreviousAddressImplCopyWith<$Res>
    implements $GdkPreviousAddressCopyWith<$Res> {
  factory _$$GdkPreviousAddressImplCopyWith(_$GdkPreviousAddressImpl value,
          $Res Function(_$GdkPreviousAddressImpl) then) =
      __$$GdkPreviousAddressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'address') String? address,
      @JsonKey(name: 'address_type') String? addressType,
      @JsonKey(name: 'subaccount') int? subaccount,
      @JsonKey(name: 'is_internal') bool? isInternal,
      @JsonKey(name: 'pointer') int? pointer,
      @JsonKey(name: 'script_pubkey') String? scriptPubkey,
      @JsonKey(name: 'user_path') List<int>? userPath,
      @JsonKey(name: 'tx_count') int? txCount,
      @JsonKey(name: 'is_blinded') bool? isBlinded,
      @JsonKey(name: 'unblinded_address') String? unblindedAddress,
      @JsonKey(name: 'blinding_script') String? blindingScript,
      @JsonKey(name: 'blinding_key') String? blindingKey});
}

/// @nodoc
class __$$GdkPreviousAddressImplCopyWithImpl<$Res>
    extends _$GdkPreviousAddressCopyWithImpl<$Res, _$GdkPreviousAddressImpl>
    implements _$$GdkPreviousAddressImplCopyWith<$Res> {
  __$$GdkPreviousAddressImplCopyWithImpl(_$GdkPreviousAddressImpl _value,
      $Res Function(_$GdkPreviousAddressImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? address = freezed,
    Object? addressType = freezed,
    Object? subaccount = freezed,
    Object? isInternal = freezed,
    Object? pointer = freezed,
    Object? scriptPubkey = freezed,
    Object? userPath = freezed,
    Object? txCount = freezed,
    Object? isBlinded = freezed,
    Object? unblindedAddress = freezed,
    Object? blindingScript = freezed,
    Object? blindingKey = freezed,
  }) {
    return _then(_$GdkPreviousAddressImpl(
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      addressType: freezed == addressType
          ? _value.addressType
          : addressType // ignore: cast_nullable_to_non_nullable
              as String?,
      subaccount: freezed == subaccount
          ? _value.subaccount
          : subaccount // ignore: cast_nullable_to_non_nullable
              as int?,
      isInternal: freezed == isInternal
          ? _value.isInternal
          : isInternal // ignore: cast_nullable_to_non_nullable
              as bool?,
      pointer: freezed == pointer
          ? _value.pointer
          : pointer // ignore: cast_nullable_to_non_nullable
              as int?,
      scriptPubkey: freezed == scriptPubkey
          ? _value.scriptPubkey
          : scriptPubkey // ignore: cast_nullable_to_non_nullable
              as String?,
      userPath: freezed == userPath
          ? _value._userPath
          : userPath // ignore: cast_nullable_to_non_nullable
              as List<int>?,
      txCount: freezed == txCount
          ? _value.txCount
          : txCount // ignore: cast_nullable_to_non_nullable
              as int?,
      isBlinded: freezed == isBlinded
          ? _value.isBlinded
          : isBlinded // ignore: cast_nullable_to_non_nullable
              as bool?,
      unblindedAddress: freezed == unblindedAddress
          ? _value.unblindedAddress
          : unblindedAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      blindingScript: freezed == blindingScript
          ? _value.blindingScript
          : blindingScript // ignore: cast_nullable_to_non_nullable
              as String?,
      blindingKey: freezed == blindingKey
          ? _value.blindingKey
          : blindingKey // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkPreviousAddressImpl extends _GdkPreviousAddress {
  const _$GdkPreviousAddressImpl(
      {@JsonKey(name: 'address') this.address,
      @JsonKey(name: 'address_type') this.addressType,
      @JsonKey(name: 'subaccount') this.subaccount = 1,
      @JsonKey(name: 'is_internal') this.isInternal,
      @JsonKey(name: 'pointer') this.pointer,
      @JsonKey(name: 'script_pubkey') this.scriptPubkey,
      @JsonKey(name: 'user_path') final List<int>? userPath,
      @JsonKey(name: 'tx_count') this.txCount,
      @JsonKey(name: 'is_blinded') this.isBlinded,
      @JsonKey(name: 'unblinded_address') this.unblindedAddress,
      @JsonKey(name: 'blinding_script') this.blindingScript,
      @JsonKey(name: 'blinding_key') this.blindingKey})
      : _userPath = userPath,
        super._();

  factory _$GdkPreviousAddressImpl.fromJson(Map<String, dynamic> json) =>
      _$$GdkPreviousAddressImplFromJson(json);

  @override
  @JsonKey(name: 'address')
  final String? address;
  @override
  @JsonKey(name: 'address_type')
  final String? addressType;
  @override
  @JsonKey(name: 'subaccount')
  final int? subaccount;
  @override
  @JsonKey(name: 'is_internal')
  final bool? isInternal;
  @override
  @JsonKey(name: 'pointer')
  final int? pointer;
  @override
  @JsonKey(name: 'script_pubkey')
  final String? scriptPubkey;
  final List<int>? _userPath;
  @override
  @JsonKey(name: 'user_path')
  List<int>? get userPath {
    final value = _userPath;
    if (value == null) return null;
    if (_userPath is EqualUnmodifiableListView) return _userPath;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'tx_count')
  final int? txCount;
// For liquid only
  @override
  @JsonKey(name: 'is_blinded')
  final bool? isBlinded;
  @override
  @JsonKey(name: 'unblinded_address')
  final String? unblindedAddress;
  @override
  @JsonKey(name: 'blinding_script')
  final String? blindingScript;
  @override
  @JsonKey(name: 'blinding_key')
  final String? blindingKey;

  @override
  String toString() {
    return 'GdkPreviousAddress(address: $address, addressType: $addressType, subaccount: $subaccount, isInternal: $isInternal, pointer: $pointer, scriptPubkey: $scriptPubkey, userPath: $userPath, txCount: $txCount, isBlinded: $isBlinded, unblindedAddress: $unblindedAddress, blindingScript: $blindingScript, blindingKey: $blindingKey)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkPreviousAddressImpl &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.addressType, addressType) ||
                other.addressType == addressType) &&
            (identical(other.subaccount, subaccount) ||
                other.subaccount == subaccount) &&
            (identical(other.isInternal, isInternal) ||
                other.isInternal == isInternal) &&
            (identical(other.pointer, pointer) || other.pointer == pointer) &&
            (identical(other.scriptPubkey, scriptPubkey) ||
                other.scriptPubkey == scriptPubkey) &&
            const DeepCollectionEquality().equals(other._userPath, _userPath) &&
            (identical(other.txCount, txCount) || other.txCount == txCount) &&
            (identical(other.isBlinded, isBlinded) ||
                other.isBlinded == isBlinded) &&
            (identical(other.unblindedAddress, unblindedAddress) ||
                other.unblindedAddress == unblindedAddress) &&
            (identical(other.blindingScript, blindingScript) ||
                other.blindingScript == blindingScript) &&
            (identical(other.blindingKey, blindingKey) ||
                other.blindingKey == blindingKey));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      address,
      addressType,
      subaccount,
      isInternal,
      pointer,
      scriptPubkey,
      const DeepCollectionEquality().hash(_userPath),
      txCount,
      isBlinded,
      unblindedAddress,
      blindingScript,
      blindingKey);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkPreviousAddressImplCopyWith<_$GdkPreviousAddressImpl> get copyWith =>
      __$$GdkPreviousAddressImplCopyWithImpl<_$GdkPreviousAddressImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkPreviousAddressImplToJson(
      this,
    );
  }
}

abstract class _GdkPreviousAddress extends GdkPreviousAddress {
  const factory _GdkPreviousAddress(
          {@JsonKey(name: 'address') final String? address,
          @JsonKey(name: 'address_type') final String? addressType,
          @JsonKey(name: 'subaccount') final int? subaccount,
          @JsonKey(name: 'is_internal') final bool? isInternal,
          @JsonKey(name: 'pointer') final int? pointer,
          @JsonKey(name: 'script_pubkey') final String? scriptPubkey,
          @JsonKey(name: 'user_path') final List<int>? userPath,
          @JsonKey(name: 'tx_count') final int? txCount,
          @JsonKey(name: 'is_blinded') final bool? isBlinded,
          @JsonKey(name: 'unblinded_address') final String? unblindedAddress,
          @JsonKey(name: 'blinding_script') final String? blindingScript,
          @JsonKey(name: 'blinding_key') final String? blindingKey}) =
      _$GdkPreviousAddressImpl;
  const _GdkPreviousAddress._() : super._();

  factory _GdkPreviousAddress.fromJson(Map<String, dynamic> json) =
      _$GdkPreviousAddressImpl.fromJson;

  @override
  @JsonKey(name: 'address')
  String? get address;
  @override
  @JsonKey(name: 'address_type')
  String? get addressType;
  @override
  @JsonKey(name: 'subaccount')
  int? get subaccount;
  @override
  @JsonKey(name: 'is_internal')
  bool? get isInternal;
  @override
  @JsonKey(name: 'pointer')
  int? get pointer;
  @override
  @JsonKey(name: 'script_pubkey')
  String? get scriptPubkey;
  @override
  @JsonKey(name: 'user_path')
  List<int>? get userPath;
  @override
  @JsonKey(name: 'tx_count')
  int? get txCount;
  @override // For liquid only
  @JsonKey(name: 'is_blinded')
  bool? get isBlinded;
  @override
  @JsonKey(name: 'unblinded_address')
  String? get unblindedAddress;
  @override
  @JsonKey(name: 'blinding_script')
  String? get blindingScript;
  @override
  @JsonKey(name: 'blinding_key')
  String? get blindingKey;
  @override
  @JsonKey(ignore: true)
  _$$GdkPreviousAddressImplCopyWith<_$GdkPreviousAddressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GdkCreatePsetDetails _$GdkCreatePsetDetailsFromJson(Map<String, dynamic> json) {
  return _GdkCreatePsetDetails.fromJson(json);
}

/// @nodoc
mixin _$GdkCreatePsetDetails {
  List<GdkAddressee>? get addressees => throw _privateConstructorUsedError;
  int? get subaccount => throw _privateConstructorUsedError;
  @JsonKey(name: 'send_asset')
  String? get sendAsset => throw _privateConstructorUsedError;
  @JsonKey(name: 'send_amount')
  int? get sendAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'recv_asset')
  String? get recvAsset => throw _privateConstructorUsedError;
  @JsonKey(name: 'recv_amount')
  int? get recvAmount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkCreatePsetDetailsCopyWith<GdkCreatePsetDetails> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkCreatePsetDetailsCopyWith<$Res> {
  factory $GdkCreatePsetDetailsCopyWith(GdkCreatePsetDetails value,
          $Res Function(GdkCreatePsetDetails) then) =
      _$GdkCreatePsetDetailsCopyWithImpl<$Res, GdkCreatePsetDetails>;
  @useResult
  $Res call(
      {List<GdkAddressee>? addressees,
      int? subaccount,
      @JsonKey(name: 'send_asset') String? sendAsset,
      @JsonKey(name: 'send_amount') int? sendAmount,
      @JsonKey(name: 'recv_asset') String? recvAsset,
      @JsonKey(name: 'recv_amount') int? recvAmount});
}

/// @nodoc
class _$GdkCreatePsetDetailsCopyWithImpl<$Res,
        $Val extends GdkCreatePsetDetails>
    implements $GdkCreatePsetDetailsCopyWith<$Res> {
  _$GdkCreatePsetDetailsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? addressees = freezed,
    Object? subaccount = freezed,
    Object? sendAsset = freezed,
    Object? sendAmount = freezed,
    Object? recvAsset = freezed,
    Object? recvAmount = freezed,
  }) {
    return _then(_value.copyWith(
      addressees: freezed == addressees
          ? _value.addressees
          : addressees // ignore: cast_nullable_to_non_nullable
              as List<GdkAddressee>?,
      subaccount: freezed == subaccount
          ? _value.subaccount
          : subaccount // ignore: cast_nullable_to_non_nullable
              as int?,
      sendAsset: freezed == sendAsset
          ? _value.sendAsset
          : sendAsset // ignore: cast_nullable_to_non_nullable
              as String?,
      sendAmount: freezed == sendAmount
          ? _value.sendAmount
          : sendAmount // ignore: cast_nullable_to_non_nullable
              as int?,
      recvAsset: freezed == recvAsset
          ? _value.recvAsset
          : recvAsset // ignore: cast_nullable_to_non_nullable
              as String?,
      recvAmount: freezed == recvAmount
          ? _value.recvAmount
          : recvAmount // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GdkCreatePsetDetailsImplCopyWith<$Res>
    implements $GdkCreatePsetDetailsCopyWith<$Res> {
  factory _$$GdkCreatePsetDetailsImplCopyWith(_$GdkCreatePsetDetailsImpl value,
          $Res Function(_$GdkCreatePsetDetailsImpl) then) =
      __$$GdkCreatePsetDetailsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<GdkAddressee>? addressees,
      int? subaccount,
      @JsonKey(name: 'send_asset') String? sendAsset,
      @JsonKey(name: 'send_amount') int? sendAmount,
      @JsonKey(name: 'recv_asset') String? recvAsset,
      @JsonKey(name: 'recv_amount') int? recvAmount});
}

/// @nodoc
class __$$GdkCreatePsetDetailsImplCopyWithImpl<$Res>
    extends _$GdkCreatePsetDetailsCopyWithImpl<$Res, _$GdkCreatePsetDetailsImpl>
    implements _$$GdkCreatePsetDetailsImplCopyWith<$Res> {
  __$$GdkCreatePsetDetailsImplCopyWithImpl(_$GdkCreatePsetDetailsImpl _value,
      $Res Function(_$GdkCreatePsetDetailsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? addressees = freezed,
    Object? subaccount = freezed,
    Object? sendAsset = freezed,
    Object? sendAmount = freezed,
    Object? recvAsset = freezed,
    Object? recvAmount = freezed,
  }) {
    return _then(_$GdkCreatePsetDetailsImpl(
      addressees: freezed == addressees
          ? _value._addressees
          : addressees // ignore: cast_nullable_to_non_nullable
              as List<GdkAddressee>?,
      subaccount: freezed == subaccount
          ? _value.subaccount
          : subaccount // ignore: cast_nullable_to_non_nullable
              as int?,
      sendAsset: freezed == sendAsset
          ? _value.sendAsset
          : sendAsset // ignore: cast_nullable_to_non_nullable
              as String?,
      sendAmount: freezed == sendAmount
          ? _value.sendAmount
          : sendAmount // ignore: cast_nullable_to_non_nullable
              as int?,
      recvAsset: freezed == recvAsset
          ? _value.recvAsset
          : recvAsset // ignore: cast_nullable_to_non_nullable
              as String?,
      recvAmount: freezed == recvAmount
          ? _value.recvAmount
          : recvAmount // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkCreatePsetDetailsImpl extends _GdkCreatePsetDetails {
  const _$GdkCreatePsetDetailsImpl(
      {final List<GdkAddressee>? addressees,
      this.subaccount = 1,
      @JsonKey(name: 'send_asset') this.sendAsset,
      @JsonKey(name: 'send_amount') this.sendAmount,
      @JsonKey(name: 'recv_asset') this.recvAsset,
      @JsonKey(name: 'recv_amount') this.recvAmount})
      : _addressees = addressees,
        super._();

  factory _$GdkCreatePsetDetailsImpl.fromJson(Map<String, dynamic> json) =>
      _$$GdkCreatePsetDetailsImplFromJson(json);

  final List<GdkAddressee>? _addressees;
  @override
  List<GdkAddressee>? get addressees {
    final value = _addressees;
    if (value == null) return null;
    if (_addressees is EqualUnmodifiableListView) return _addressees;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey()
  final int? subaccount;
  @override
  @JsonKey(name: 'send_asset')
  final String? sendAsset;
  @override
  @JsonKey(name: 'send_amount')
  final int? sendAmount;
  @override
  @JsonKey(name: 'recv_asset')
  final String? recvAsset;
  @override
  @JsonKey(name: 'recv_amount')
  final int? recvAmount;

  @override
  String toString() {
    return 'GdkCreatePsetDetails(addressees: $addressees, subaccount: $subaccount, sendAsset: $sendAsset, sendAmount: $sendAmount, recvAsset: $recvAsset, recvAmount: $recvAmount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkCreatePsetDetailsImpl &&
            const DeepCollectionEquality()
                .equals(other._addressees, _addressees) &&
            (identical(other.subaccount, subaccount) ||
                other.subaccount == subaccount) &&
            (identical(other.sendAsset, sendAsset) ||
                other.sendAsset == sendAsset) &&
            (identical(other.sendAmount, sendAmount) ||
                other.sendAmount == sendAmount) &&
            (identical(other.recvAsset, recvAsset) ||
                other.recvAsset == recvAsset) &&
            (identical(other.recvAmount, recvAmount) ||
                other.recvAmount == recvAmount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_addressees),
      subaccount,
      sendAsset,
      sendAmount,
      recvAsset,
      recvAmount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkCreatePsetDetailsImplCopyWith<_$GdkCreatePsetDetailsImpl>
      get copyWith =>
          __$$GdkCreatePsetDetailsImplCopyWithImpl<_$GdkCreatePsetDetailsImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkCreatePsetDetailsImplToJson(
      this,
    );
  }
}

abstract class _GdkCreatePsetDetails extends GdkCreatePsetDetails {
  const factory _GdkCreatePsetDetails(
          {final List<GdkAddressee>? addressees,
          final int? subaccount,
          @JsonKey(name: 'send_asset') final String? sendAsset,
          @JsonKey(name: 'send_amount') final int? sendAmount,
          @JsonKey(name: 'recv_asset') final String? recvAsset,
          @JsonKey(name: 'recv_amount') final int? recvAmount}) =
      _$GdkCreatePsetDetailsImpl;
  const _GdkCreatePsetDetails._() : super._();

  factory _GdkCreatePsetDetails.fromJson(Map<String, dynamic> json) =
      _$GdkCreatePsetDetailsImpl.fromJson;

  @override
  List<GdkAddressee>? get addressees;
  @override
  int? get subaccount;
  @override
  @JsonKey(name: 'send_asset')
  String? get sendAsset;
  @override
  @JsonKey(name: 'send_amount')
  int? get sendAmount;
  @override
  @JsonKey(name: 'recv_asset')
  String? get recvAsset;
  @override
  @JsonKey(name: 'recv_amount')
  int? get recvAmount;
  @override
  @JsonKey(ignore: true)
  _$$GdkCreatePsetDetailsImplCopyWith<_$GdkCreatePsetDetailsImpl>
      get copyWith => throw _privateConstructorUsedError;
}

GdkCreatePsetInputs _$GdkCreatePsetInputsFromJson(Map<String, dynamic> json) {
  return _GdkCreatePsetInputs.fromJson(json);
}

/// @nodoc
mixin _$GdkCreatePsetInputs {
  String? get asset => throw _privateConstructorUsedError;
  @JsonKey(name: 'asset_bf')
  String? get assetBf => throw _privateConstructorUsedError;
  String? get txid => throw _privateConstructorUsedError;
  int? get value => throw _privateConstructorUsedError;
  @JsonKey(name: 'value_bf')
  String? get valueBf => throw _privateConstructorUsedError;
  int? get vout => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkCreatePsetInputsCopyWith<GdkCreatePsetInputs> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkCreatePsetInputsCopyWith<$Res> {
  factory $GdkCreatePsetInputsCopyWith(
          GdkCreatePsetInputs value, $Res Function(GdkCreatePsetInputs) then) =
      _$GdkCreatePsetInputsCopyWithImpl<$Res, GdkCreatePsetInputs>;
  @useResult
  $Res call(
      {String? asset,
      @JsonKey(name: 'asset_bf') String? assetBf,
      String? txid,
      int? value,
      @JsonKey(name: 'value_bf') String? valueBf,
      int? vout});
}

/// @nodoc
class _$GdkCreatePsetInputsCopyWithImpl<$Res, $Val extends GdkCreatePsetInputs>
    implements $GdkCreatePsetInputsCopyWith<$Res> {
  _$GdkCreatePsetInputsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? asset = freezed,
    Object? assetBf = freezed,
    Object? txid = freezed,
    Object? value = freezed,
    Object? valueBf = freezed,
    Object? vout = freezed,
  }) {
    return _then(_value.copyWith(
      asset: freezed == asset
          ? _value.asset
          : asset // ignore: cast_nullable_to_non_nullable
              as String?,
      assetBf: freezed == assetBf
          ? _value.assetBf
          : assetBf // ignore: cast_nullable_to_non_nullable
              as String?,
      txid: freezed == txid
          ? _value.txid
          : txid // ignore: cast_nullable_to_non_nullable
              as String?,
      value: freezed == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as int?,
      valueBf: freezed == valueBf
          ? _value.valueBf
          : valueBf // ignore: cast_nullable_to_non_nullable
              as String?,
      vout: freezed == vout
          ? _value.vout
          : vout // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GdkCreatePsetInputsImplCopyWith<$Res>
    implements $GdkCreatePsetInputsCopyWith<$Res> {
  factory _$$GdkCreatePsetInputsImplCopyWith(_$GdkCreatePsetInputsImpl value,
          $Res Function(_$GdkCreatePsetInputsImpl) then) =
      __$$GdkCreatePsetInputsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? asset,
      @JsonKey(name: 'asset_bf') String? assetBf,
      String? txid,
      int? value,
      @JsonKey(name: 'value_bf') String? valueBf,
      int? vout});
}

/// @nodoc
class __$$GdkCreatePsetInputsImplCopyWithImpl<$Res>
    extends _$GdkCreatePsetInputsCopyWithImpl<$Res, _$GdkCreatePsetInputsImpl>
    implements _$$GdkCreatePsetInputsImplCopyWith<$Res> {
  __$$GdkCreatePsetInputsImplCopyWithImpl(_$GdkCreatePsetInputsImpl _value,
      $Res Function(_$GdkCreatePsetInputsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? asset = freezed,
    Object? assetBf = freezed,
    Object? txid = freezed,
    Object? value = freezed,
    Object? valueBf = freezed,
    Object? vout = freezed,
  }) {
    return _then(_$GdkCreatePsetInputsImpl(
      asset: freezed == asset
          ? _value.asset
          : asset // ignore: cast_nullable_to_non_nullable
              as String?,
      assetBf: freezed == assetBf
          ? _value.assetBf
          : assetBf // ignore: cast_nullable_to_non_nullable
              as String?,
      txid: freezed == txid
          ? _value.txid
          : txid // ignore: cast_nullable_to_non_nullable
              as String?,
      value: freezed == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as int?,
      valueBf: freezed == valueBf
          ? _value.valueBf
          : valueBf // ignore: cast_nullable_to_non_nullable
              as String?,
      vout: freezed == vout
          ? _value.vout
          : vout // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkCreatePsetInputsImpl implements _GdkCreatePsetInputs {
  const _$GdkCreatePsetInputsImpl(
      {this.asset,
      @JsonKey(name: 'asset_bf') this.assetBf,
      this.txid,
      this.value,
      @JsonKey(name: 'value_bf') this.valueBf,
      this.vout});

  factory _$GdkCreatePsetInputsImpl.fromJson(Map<String, dynamic> json) =>
      _$$GdkCreatePsetInputsImplFromJson(json);

  @override
  final String? asset;
  @override
  @JsonKey(name: 'asset_bf')
  final String? assetBf;
  @override
  final String? txid;
  @override
  final int? value;
  @override
  @JsonKey(name: 'value_bf')
  final String? valueBf;
  @override
  final int? vout;

  @override
  String toString() {
    return 'GdkCreatePsetInputs(asset: $asset, assetBf: $assetBf, txid: $txid, value: $value, valueBf: $valueBf, vout: $vout)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkCreatePsetInputsImpl &&
            (identical(other.asset, asset) || other.asset == asset) &&
            (identical(other.assetBf, assetBf) || other.assetBf == assetBf) &&
            (identical(other.txid, txid) || other.txid == txid) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.valueBf, valueBf) || other.valueBf == valueBf) &&
            (identical(other.vout, vout) || other.vout == vout));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, asset, assetBf, txid, value, valueBf, vout);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkCreatePsetInputsImplCopyWith<_$GdkCreatePsetInputsImpl> get copyWith =>
      __$$GdkCreatePsetInputsImplCopyWithImpl<_$GdkCreatePsetInputsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkCreatePsetInputsImplToJson(
      this,
    );
  }
}

abstract class _GdkCreatePsetInputs implements GdkCreatePsetInputs {
  const factory _GdkCreatePsetInputs(
      {final String? asset,
      @JsonKey(name: 'asset_bf') final String? assetBf,
      final String? txid,
      final int? value,
      @JsonKey(name: 'value_bf') final String? valueBf,
      final int? vout}) = _$GdkCreatePsetInputsImpl;

  factory _GdkCreatePsetInputs.fromJson(Map<String, dynamic> json) =
      _$GdkCreatePsetInputsImpl.fromJson;

  @override
  String? get asset;
  @override
  @JsonKey(name: 'asset_bf')
  String? get assetBf;
  @override
  String? get txid;
  @override
  int? get value;
  @override
  @JsonKey(name: 'value_bf')
  String? get valueBf;
  @override
  int? get vout;
  @override
  @JsonKey(ignore: true)
  _$$GdkCreatePsetInputsImplCopyWith<_$GdkCreatePsetInputsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GdkCreatePsetDetailsReply _$GdkCreatePsetDetailsReplyFromJson(
    Map<String, dynamic> json) {
  return _GdkCreatePsetDetailsReply.fromJson(json);
}

/// @nodoc
mixin _$GdkCreatePsetDetailsReply {
  @JsonKey(name: 'change_addr')
  String? get changeAddr => throw _privateConstructorUsedError;
  List<GdkCreatePsetInputs>? get inputs => throw _privateConstructorUsedError;
  @JsonKey(name: 'recv_addr')
  String? get recvAddr => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkCreatePsetDetailsReplyCopyWith<GdkCreatePsetDetailsReply> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkCreatePsetDetailsReplyCopyWith<$Res> {
  factory $GdkCreatePsetDetailsReplyCopyWith(GdkCreatePsetDetailsReply value,
          $Res Function(GdkCreatePsetDetailsReply) then) =
      _$GdkCreatePsetDetailsReplyCopyWithImpl<$Res, GdkCreatePsetDetailsReply>;
  @useResult
  $Res call(
      {@JsonKey(name: 'change_addr') String? changeAddr,
      List<GdkCreatePsetInputs>? inputs,
      @JsonKey(name: 'recv_addr') String? recvAddr});
}

/// @nodoc
class _$GdkCreatePsetDetailsReplyCopyWithImpl<$Res,
        $Val extends GdkCreatePsetDetailsReply>
    implements $GdkCreatePsetDetailsReplyCopyWith<$Res> {
  _$GdkCreatePsetDetailsReplyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? changeAddr = freezed,
    Object? inputs = freezed,
    Object? recvAddr = freezed,
  }) {
    return _then(_value.copyWith(
      changeAddr: freezed == changeAddr
          ? _value.changeAddr
          : changeAddr // ignore: cast_nullable_to_non_nullable
              as String?,
      inputs: freezed == inputs
          ? _value.inputs
          : inputs // ignore: cast_nullable_to_non_nullable
              as List<GdkCreatePsetInputs>?,
      recvAddr: freezed == recvAddr
          ? _value.recvAddr
          : recvAddr // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GdkCreatePsetDetailsReplyImplCopyWith<$Res>
    implements $GdkCreatePsetDetailsReplyCopyWith<$Res> {
  factory _$$GdkCreatePsetDetailsReplyImplCopyWith(
          _$GdkCreatePsetDetailsReplyImpl value,
          $Res Function(_$GdkCreatePsetDetailsReplyImpl) then) =
      __$$GdkCreatePsetDetailsReplyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'change_addr') String? changeAddr,
      List<GdkCreatePsetInputs>? inputs,
      @JsonKey(name: 'recv_addr') String? recvAddr});
}

/// @nodoc
class __$$GdkCreatePsetDetailsReplyImplCopyWithImpl<$Res>
    extends _$GdkCreatePsetDetailsReplyCopyWithImpl<$Res,
        _$GdkCreatePsetDetailsReplyImpl>
    implements _$$GdkCreatePsetDetailsReplyImplCopyWith<$Res> {
  __$$GdkCreatePsetDetailsReplyImplCopyWithImpl(
      _$GdkCreatePsetDetailsReplyImpl _value,
      $Res Function(_$GdkCreatePsetDetailsReplyImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? changeAddr = freezed,
    Object? inputs = freezed,
    Object? recvAddr = freezed,
  }) {
    return _then(_$GdkCreatePsetDetailsReplyImpl(
      changeAddr: freezed == changeAddr
          ? _value.changeAddr
          : changeAddr // ignore: cast_nullable_to_non_nullable
              as String?,
      inputs: freezed == inputs
          ? _value._inputs
          : inputs // ignore: cast_nullable_to_non_nullable
              as List<GdkCreatePsetInputs>?,
      recvAddr: freezed == recvAddr
          ? _value.recvAddr
          : recvAddr // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkCreatePsetDetailsReplyImpl extends _GdkCreatePsetDetailsReply {
  const _$GdkCreatePsetDetailsReplyImpl(
      {@JsonKey(name: 'change_addr') this.changeAddr,
      final List<GdkCreatePsetInputs>? inputs,
      @JsonKey(name: 'recv_addr') this.recvAddr})
      : _inputs = inputs,
        super._();

  factory _$GdkCreatePsetDetailsReplyImpl.fromJson(Map<String, dynamic> json) =>
      _$$GdkCreatePsetDetailsReplyImplFromJson(json);

  @override
  @JsonKey(name: 'change_addr')
  final String? changeAddr;
  final List<GdkCreatePsetInputs>? _inputs;
  @override
  List<GdkCreatePsetInputs>? get inputs {
    final value = _inputs;
    if (value == null) return null;
    if (_inputs is EqualUnmodifiableListView) return _inputs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'recv_addr')
  final String? recvAddr;

  @override
  String toString() {
    return 'GdkCreatePsetDetailsReply(changeAddr: $changeAddr, inputs: $inputs, recvAddr: $recvAddr)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkCreatePsetDetailsReplyImpl &&
            (identical(other.changeAddr, changeAddr) ||
                other.changeAddr == changeAddr) &&
            const DeepCollectionEquality().equals(other._inputs, _inputs) &&
            (identical(other.recvAddr, recvAddr) ||
                other.recvAddr == recvAddr));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, changeAddr,
      const DeepCollectionEquality().hash(_inputs), recvAddr);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkCreatePsetDetailsReplyImplCopyWith<_$GdkCreatePsetDetailsReplyImpl>
      get copyWith => __$$GdkCreatePsetDetailsReplyImplCopyWithImpl<
          _$GdkCreatePsetDetailsReplyImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkCreatePsetDetailsReplyImplToJson(
      this,
    );
  }
}

abstract class _GdkCreatePsetDetailsReply extends GdkCreatePsetDetailsReply {
  const factory _GdkCreatePsetDetailsReply(
          {@JsonKey(name: 'change_addr') final String? changeAddr,
          final List<GdkCreatePsetInputs>? inputs,
          @JsonKey(name: 'recv_addr') final String? recvAddr}) =
      _$GdkCreatePsetDetailsReplyImpl;
  const _GdkCreatePsetDetailsReply._() : super._();

  factory _GdkCreatePsetDetailsReply.fromJson(Map<String, dynamic> json) =
      _$GdkCreatePsetDetailsReplyImpl.fromJson;

  @override
  @JsonKey(name: 'change_addr')
  String? get changeAddr;
  @override
  List<GdkCreatePsetInputs>? get inputs;
  @override
  @JsonKey(name: 'recv_addr')
  String? get recvAddr;
  @override
  @JsonKey(ignore: true)
  _$$GdkCreatePsetDetailsReplyImplCopyWith<_$GdkCreatePsetDetailsReplyImpl>
      get copyWith => throw _privateConstructorUsedError;
}

GdkSignPsetDetails _$GdkSignPsetDetailsFromJson(Map<String, dynamic> json) {
  return _GdkSignPsetDetails.fromJson(json);
}

/// @nodoc
mixin _$GdkSignPsetDetails {
  List<GdkAddressee>? get addressees => throw _privateConstructorUsedError;
  int? get subaccount => throw _privateConstructorUsedError;
  @JsonKey(name: 'pset')
  String? get pset => throw _privateConstructorUsedError;
  @JsonKey(name: 'send_asset')
  String? get sendAsset => throw _privateConstructorUsedError;
  @JsonKey(name: 'send_amount')
  int? get sendAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'recv_asset')
  String? get recvAsset => throw _privateConstructorUsedError;
  @JsonKey(name: 'recv_amount')
  int? get recvAmount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkSignPsetDetailsCopyWith<GdkSignPsetDetails> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkSignPsetDetailsCopyWith<$Res> {
  factory $GdkSignPsetDetailsCopyWith(
          GdkSignPsetDetails value, $Res Function(GdkSignPsetDetails) then) =
      _$GdkSignPsetDetailsCopyWithImpl<$Res, GdkSignPsetDetails>;
  @useResult
  $Res call(
      {List<GdkAddressee>? addressees,
      int? subaccount,
      @JsonKey(name: 'pset') String? pset,
      @JsonKey(name: 'send_asset') String? sendAsset,
      @JsonKey(name: 'send_amount') int? sendAmount,
      @JsonKey(name: 'recv_asset') String? recvAsset,
      @JsonKey(name: 'recv_amount') int? recvAmount});
}

/// @nodoc
class _$GdkSignPsetDetailsCopyWithImpl<$Res, $Val extends GdkSignPsetDetails>
    implements $GdkSignPsetDetailsCopyWith<$Res> {
  _$GdkSignPsetDetailsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? addressees = freezed,
    Object? subaccount = freezed,
    Object? pset = freezed,
    Object? sendAsset = freezed,
    Object? sendAmount = freezed,
    Object? recvAsset = freezed,
    Object? recvAmount = freezed,
  }) {
    return _then(_value.copyWith(
      addressees: freezed == addressees
          ? _value.addressees
          : addressees // ignore: cast_nullable_to_non_nullable
              as List<GdkAddressee>?,
      subaccount: freezed == subaccount
          ? _value.subaccount
          : subaccount // ignore: cast_nullable_to_non_nullable
              as int?,
      pset: freezed == pset
          ? _value.pset
          : pset // ignore: cast_nullable_to_non_nullable
              as String?,
      sendAsset: freezed == sendAsset
          ? _value.sendAsset
          : sendAsset // ignore: cast_nullable_to_non_nullable
              as String?,
      sendAmount: freezed == sendAmount
          ? _value.sendAmount
          : sendAmount // ignore: cast_nullable_to_non_nullable
              as int?,
      recvAsset: freezed == recvAsset
          ? _value.recvAsset
          : recvAsset // ignore: cast_nullable_to_non_nullable
              as String?,
      recvAmount: freezed == recvAmount
          ? _value.recvAmount
          : recvAmount // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GdkSignPsetDetailsImplCopyWith<$Res>
    implements $GdkSignPsetDetailsCopyWith<$Res> {
  factory _$$GdkSignPsetDetailsImplCopyWith(_$GdkSignPsetDetailsImpl value,
          $Res Function(_$GdkSignPsetDetailsImpl) then) =
      __$$GdkSignPsetDetailsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<GdkAddressee>? addressees,
      int? subaccount,
      @JsonKey(name: 'pset') String? pset,
      @JsonKey(name: 'send_asset') String? sendAsset,
      @JsonKey(name: 'send_amount') int? sendAmount,
      @JsonKey(name: 'recv_asset') String? recvAsset,
      @JsonKey(name: 'recv_amount') int? recvAmount});
}

/// @nodoc
class __$$GdkSignPsetDetailsImplCopyWithImpl<$Res>
    extends _$GdkSignPsetDetailsCopyWithImpl<$Res, _$GdkSignPsetDetailsImpl>
    implements _$$GdkSignPsetDetailsImplCopyWith<$Res> {
  __$$GdkSignPsetDetailsImplCopyWithImpl(_$GdkSignPsetDetailsImpl _value,
      $Res Function(_$GdkSignPsetDetailsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? addressees = freezed,
    Object? subaccount = freezed,
    Object? pset = freezed,
    Object? sendAsset = freezed,
    Object? sendAmount = freezed,
    Object? recvAsset = freezed,
    Object? recvAmount = freezed,
  }) {
    return _then(_$GdkSignPsetDetailsImpl(
      addressees: freezed == addressees
          ? _value._addressees
          : addressees // ignore: cast_nullable_to_non_nullable
              as List<GdkAddressee>?,
      subaccount: freezed == subaccount
          ? _value.subaccount
          : subaccount // ignore: cast_nullable_to_non_nullable
              as int?,
      pset: freezed == pset
          ? _value.pset
          : pset // ignore: cast_nullable_to_non_nullable
              as String?,
      sendAsset: freezed == sendAsset
          ? _value.sendAsset
          : sendAsset // ignore: cast_nullable_to_non_nullable
              as String?,
      sendAmount: freezed == sendAmount
          ? _value.sendAmount
          : sendAmount // ignore: cast_nullable_to_non_nullable
              as int?,
      recvAsset: freezed == recvAsset
          ? _value.recvAsset
          : recvAsset // ignore: cast_nullable_to_non_nullable
              as String?,
      recvAmount: freezed == recvAmount
          ? _value.recvAmount
          : recvAmount // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkSignPsetDetailsImpl extends _GdkSignPsetDetails {
  const _$GdkSignPsetDetailsImpl(
      {final List<GdkAddressee>? addressees,
      this.subaccount = 1,
      @JsonKey(name: 'pset') this.pset,
      @JsonKey(name: 'send_asset') this.sendAsset,
      @JsonKey(name: 'send_amount') this.sendAmount,
      @JsonKey(name: 'recv_asset') this.recvAsset,
      @JsonKey(name: 'recv_amount') this.recvAmount})
      : _addressees = addressees,
        super._();

  factory _$GdkSignPsetDetailsImpl.fromJson(Map<String, dynamic> json) =>
      _$$GdkSignPsetDetailsImplFromJson(json);

  final List<GdkAddressee>? _addressees;
  @override
  List<GdkAddressee>? get addressees {
    final value = _addressees;
    if (value == null) return null;
    if (_addressees is EqualUnmodifiableListView) return _addressees;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey()
  final int? subaccount;
  @override
  @JsonKey(name: 'pset')
  final String? pset;
  @override
  @JsonKey(name: 'send_asset')
  final String? sendAsset;
  @override
  @JsonKey(name: 'send_amount')
  final int? sendAmount;
  @override
  @JsonKey(name: 'recv_asset')
  final String? recvAsset;
  @override
  @JsonKey(name: 'recv_amount')
  final int? recvAmount;

  @override
  String toString() {
    return 'GdkSignPsetDetails(addressees: $addressees, subaccount: $subaccount, pset: $pset, sendAsset: $sendAsset, sendAmount: $sendAmount, recvAsset: $recvAsset, recvAmount: $recvAmount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkSignPsetDetailsImpl &&
            const DeepCollectionEquality()
                .equals(other._addressees, _addressees) &&
            (identical(other.subaccount, subaccount) ||
                other.subaccount == subaccount) &&
            (identical(other.pset, pset) || other.pset == pset) &&
            (identical(other.sendAsset, sendAsset) ||
                other.sendAsset == sendAsset) &&
            (identical(other.sendAmount, sendAmount) ||
                other.sendAmount == sendAmount) &&
            (identical(other.recvAsset, recvAsset) ||
                other.recvAsset == recvAsset) &&
            (identical(other.recvAmount, recvAmount) ||
                other.recvAmount == recvAmount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_addressees),
      subaccount,
      pset,
      sendAsset,
      sendAmount,
      recvAsset,
      recvAmount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkSignPsetDetailsImplCopyWith<_$GdkSignPsetDetailsImpl> get copyWith =>
      __$$GdkSignPsetDetailsImplCopyWithImpl<_$GdkSignPsetDetailsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkSignPsetDetailsImplToJson(
      this,
    );
  }
}

abstract class _GdkSignPsetDetails extends GdkSignPsetDetails {
  const factory _GdkSignPsetDetails(
          {final List<GdkAddressee>? addressees,
          final int? subaccount,
          @JsonKey(name: 'pset') final String? pset,
          @JsonKey(name: 'send_asset') final String? sendAsset,
          @JsonKey(name: 'send_amount') final int? sendAmount,
          @JsonKey(name: 'recv_asset') final String? recvAsset,
          @JsonKey(name: 'recv_amount') final int? recvAmount}) =
      _$GdkSignPsetDetailsImpl;
  const _GdkSignPsetDetails._() : super._();

  factory _GdkSignPsetDetails.fromJson(Map<String, dynamic> json) =
      _$GdkSignPsetDetailsImpl.fromJson;

  @override
  List<GdkAddressee>? get addressees;
  @override
  int? get subaccount;
  @override
  @JsonKey(name: 'pset')
  String? get pset;
  @override
  @JsonKey(name: 'send_asset')
  String? get sendAsset;
  @override
  @JsonKey(name: 'send_amount')
  int? get sendAmount;
  @override
  @JsonKey(name: 'recv_asset')
  String? get recvAsset;
  @override
  @JsonKey(name: 'recv_amount')
  int? get recvAmount;
  @override
  @JsonKey(ignore: true)
  _$$GdkSignPsetDetailsImplCopyWith<_$GdkSignPsetDetailsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GdkSignPsetDetailsReply _$GdkSignPsetDetailsReplyFromJson(
    Map<String, dynamic> json) {
  return _GdkSignPsetDetailsReply.fromJson(json);
}

/// @nodoc
mixin _$GdkSignPsetDetailsReply {
  List<GdkAddressee>? get addressees => throw _privateConstructorUsedError;
  @JsonKey(name: 'pset')
  String? get pset => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkSignPsetDetailsReplyCopyWith<GdkSignPsetDetailsReply> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkSignPsetDetailsReplyCopyWith<$Res> {
  factory $GdkSignPsetDetailsReplyCopyWith(GdkSignPsetDetailsReply value,
          $Res Function(GdkSignPsetDetailsReply) then) =
      _$GdkSignPsetDetailsReplyCopyWithImpl<$Res, GdkSignPsetDetailsReply>;
  @useResult
  $Res call(
      {List<GdkAddressee>? addressees, @JsonKey(name: 'pset') String? pset});
}

/// @nodoc
class _$GdkSignPsetDetailsReplyCopyWithImpl<$Res,
        $Val extends GdkSignPsetDetailsReply>
    implements $GdkSignPsetDetailsReplyCopyWith<$Res> {
  _$GdkSignPsetDetailsReplyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? addressees = freezed,
    Object? pset = freezed,
  }) {
    return _then(_value.copyWith(
      addressees: freezed == addressees
          ? _value.addressees
          : addressees // ignore: cast_nullable_to_non_nullable
              as List<GdkAddressee>?,
      pset: freezed == pset
          ? _value.pset
          : pset // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GdkSignPsetDetailsReplyImplCopyWith<$Res>
    implements $GdkSignPsetDetailsReplyCopyWith<$Res> {
  factory _$$GdkSignPsetDetailsReplyImplCopyWith(
          _$GdkSignPsetDetailsReplyImpl value,
          $Res Function(_$GdkSignPsetDetailsReplyImpl) then) =
      __$$GdkSignPsetDetailsReplyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<GdkAddressee>? addressees, @JsonKey(name: 'pset') String? pset});
}

/// @nodoc
class __$$GdkSignPsetDetailsReplyImplCopyWithImpl<$Res>
    extends _$GdkSignPsetDetailsReplyCopyWithImpl<$Res,
        _$GdkSignPsetDetailsReplyImpl>
    implements _$$GdkSignPsetDetailsReplyImplCopyWith<$Res> {
  __$$GdkSignPsetDetailsReplyImplCopyWithImpl(
      _$GdkSignPsetDetailsReplyImpl _value,
      $Res Function(_$GdkSignPsetDetailsReplyImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? addressees = freezed,
    Object? pset = freezed,
  }) {
    return _then(_$GdkSignPsetDetailsReplyImpl(
      addressees: freezed == addressees
          ? _value._addressees
          : addressees // ignore: cast_nullable_to_non_nullable
              as List<GdkAddressee>?,
      pset: freezed == pset
          ? _value.pset
          : pset // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkSignPsetDetailsReplyImpl extends _GdkSignPsetDetailsReply {
  const _$GdkSignPsetDetailsReplyImpl(
      {final List<GdkAddressee>? addressees, @JsonKey(name: 'pset') this.pset})
      : _addressees = addressees,
        super._();

  factory _$GdkSignPsetDetailsReplyImpl.fromJson(Map<String, dynamic> json) =>
      _$$GdkSignPsetDetailsReplyImplFromJson(json);

  final List<GdkAddressee>? _addressees;
  @override
  List<GdkAddressee>? get addressees {
    final value = _addressees;
    if (value == null) return null;
    if (_addressees is EqualUnmodifiableListView) return _addressees;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'pset')
  final String? pset;

  @override
  String toString() {
    return 'GdkSignPsetDetailsReply(addressees: $addressees, pset: $pset)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkSignPsetDetailsReplyImpl &&
            const DeepCollectionEquality()
                .equals(other._addressees, _addressees) &&
            (identical(other.pset, pset) || other.pset == pset));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_addressees), pset);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkSignPsetDetailsReplyImplCopyWith<_$GdkSignPsetDetailsReplyImpl>
      get copyWith => __$$GdkSignPsetDetailsReplyImplCopyWithImpl<
          _$GdkSignPsetDetailsReplyImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkSignPsetDetailsReplyImplToJson(
      this,
    );
  }
}

abstract class _GdkSignPsetDetailsReply extends GdkSignPsetDetailsReply {
  const factory _GdkSignPsetDetailsReply(
          {final List<GdkAddressee>? addressees,
          @JsonKey(name: 'pset') final String? pset}) =
      _$GdkSignPsetDetailsReplyImpl;
  const _GdkSignPsetDetailsReply._() : super._();

  factory _GdkSignPsetDetailsReply.fromJson(Map<String, dynamic> json) =
      _$GdkSignPsetDetailsReplyImpl.fromJson;

  @override
  List<GdkAddressee>? get addressees;
  @override
  @JsonKey(name: 'pset')
  String? get pset;
  @override
  @JsonKey(ignore: true)
  _$$GdkSignPsetDetailsReplyImplCopyWith<_$GdkSignPsetDetailsReplyImpl>
      get copyWith => throw _privateConstructorUsedError;
}

GdkSignPsbtDetails _$GdkSignPsbtDetailsFromJson(Map<String, dynamic> json) {
  return _GdkSignPsbtDetails.fromJson(json);
}

/// @nodoc
mixin _$GdkSignPsbtDetails {
  @JsonKey(name: 'psbt')
  String get psbt => throw _privateConstructorUsedError;
  @JsonKey(name: 'utxos')
  List<Map<String, dynamic>> get utxos => throw _privateConstructorUsedError;
  @JsonKey(name: 'blinding_nonces')
  List<String>? get blindingNonces => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkSignPsbtDetailsCopyWith<GdkSignPsbtDetails> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkSignPsbtDetailsCopyWith<$Res> {
  factory $GdkSignPsbtDetailsCopyWith(
          GdkSignPsbtDetails value, $Res Function(GdkSignPsbtDetails) then) =
      _$GdkSignPsbtDetailsCopyWithImpl<$Res, GdkSignPsbtDetails>;
  @useResult
  $Res call(
      {@JsonKey(name: 'psbt') String psbt,
      @JsonKey(name: 'utxos') List<Map<String, dynamic>> utxos,
      @JsonKey(name: 'blinding_nonces') List<String>? blindingNonces});
}

/// @nodoc
class _$GdkSignPsbtDetailsCopyWithImpl<$Res, $Val extends GdkSignPsbtDetails>
    implements $GdkSignPsbtDetailsCopyWith<$Res> {
  _$GdkSignPsbtDetailsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? psbt = null,
    Object? utxos = null,
    Object? blindingNonces = freezed,
  }) {
    return _then(_value.copyWith(
      psbt: null == psbt
          ? _value.psbt
          : psbt // ignore: cast_nullable_to_non_nullable
              as String,
      utxos: null == utxos
          ? _value.utxos
          : utxos // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      blindingNonces: freezed == blindingNonces
          ? _value.blindingNonces
          : blindingNonces // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GdkSignPsbtDetailsImplCopyWith<$Res>
    implements $GdkSignPsbtDetailsCopyWith<$Res> {
  factory _$$GdkSignPsbtDetailsImplCopyWith(_$GdkSignPsbtDetailsImpl value,
          $Res Function(_$GdkSignPsbtDetailsImpl) then) =
      __$$GdkSignPsbtDetailsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'psbt') String psbt,
      @JsonKey(name: 'utxos') List<Map<String, dynamic>> utxos,
      @JsonKey(name: 'blinding_nonces') List<String>? blindingNonces});
}

/// @nodoc
class __$$GdkSignPsbtDetailsImplCopyWithImpl<$Res>
    extends _$GdkSignPsbtDetailsCopyWithImpl<$Res, _$GdkSignPsbtDetailsImpl>
    implements _$$GdkSignPsbtDetailsImplCopyWith<$Res> {
  __$$GdkSignPsbtDetailsImplCopyWithImpl(_$GdkSignPsbtDetailsImpl _value,
      $Res Function(_$GdkSignPsbtDetailsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? psbt = null,
    Object? utxos = null,
    Object? blindingNonces = freezed,
  }) {
    return _then(_$GdkSignPsbtDetailsImpl(
      psbt: null == psbt
          ? _value.psbt
          : psbt // ignore: cast_nullable_to_non_nullable
              as String,
      utxos: null == utxos
          ? _value._utxos
          : utxos // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      blindingNonces: freezed == blindingNonces
          ? _value._blindingNonces
          : blindingNonces // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkSignPsbtDetailsImpl extends _GdkSignPsbtDetails {
  const _$GdkSignPsbtDetailsImpl(
      {@JsonKey(name: 'psbt') required this.psbt,
      @JsonKey(name: 'utxos') required final List<Map<String, dynamic>> utxos,
      @JsonKey(name: 'blinding_nonces') final List<String>? blindingNonces})
      : _utxos = utxos,
        _blindingNonces = blindingNonces,
        super._();

  factory _$GdkSignPsbtDetailsImpl.fromJson(Map<String, dynamic> json) =>
      _$$GdkSignPsbtDetailsImplFromJson(json);

  @override
  @JsonKey(name: 'psbt')
  final String psbt;
  final List<Map<String, dynamic>> _utxos;
  @override
  @JsonKey(name: 'utxos')
  List<Map<String, dynamic>> get utxos {
    if (_utxos is EqualUnmodifiableListView) return _utxos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_utxos);
  }

  final List<String>? _blindingNonces;
  @override
  @JsonKey(name: 'blinding_nonces')
  List<String>? get blindingNonces {
    final value = _blindingNonces;
    if (value == null) return null;
    if (_blindingNonces is EqualUnmodifiableListView) return _blindingNonces;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'GdkSignPsbtDetails(psbt: $psbt, utxos: $utxos, blindingNonces: $blindingNonces)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkSignPsbtDetailsImpl &&
            (identical(other.psbt, psbt) || other.psbt == psbt) &&
            const DeepCollectionEquality().equals(other._utxos, _utxos) &&
            const DeepCollectionEquality()
                .equals(other._blindingNonces, _blindingNonces));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      psbt,
      const DeepCollectionEquality().hash(_utxos),
      const DeepCollectionEquality().hash(_blindingNonces));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkSignPsbtDetailsImplCopyWith<_$GdkSignPsbtDetailsImpl> get copyWith =>
      __$$GdkSignPsbtDetailsImplCopyWithImpl<_$GdkSignPsbtDetailsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkSignPsbtDetailsImplToJson(
      this,
    );
  }
}

abstract class _GdkSignPsbtDetails extends GdkSignPsbtDetails {
  const factory _GdkSignPsbtDetails(
      {@JsonKey(name: 'psbt') required final String psbt,
      @JsonKey(name: 'utxos') required final List<Map<String, dynamic>> utxos,
      @JsonKey(name: 'blinding_nonces')
      final List<String>? blindingNonces}) = _$GdkSignPsbtDetailsImpl;
  const _GdkSignPsbtDetails._() : super._();

  factory _GdkSignPsbtDetails.fromJson(Map<String, dynamic> json) =
      _$GdkSignPsbtDetailsImpl.fromJson;

  @override
  @JsonKey(name: 'psbt')
  String get psbt;
  @override
  @JsonKey(name: 'utxos')
  List<Map<String, dynamic>> get utxos;
  @override
  @JsonKey(name: 'blinding_nonces')
  List<String>? get blindingNonces;
  @override
  @JsonKey(ignore: true)
  _$$GdkSignPsbtDetailsImplCopyWith<_$GdkSignPsbtDetailsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GdkSignPsbtResult _$GdkSignPsbtResultFromJson(Map<String, dynamic> json) {
  return _GdkSignPsbtResult.fromJson(json);
}

/// @nodoc
mixin _$GdkSignPsbtResult {
  @JsonKey(name: 'psbt')
  String get psbt => throw _privateConstructorUsedError;
  @JsonKey(name: 'utxos')
  List<Map<String, dynamic>> get utxos => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkSignPsbtResultCopyWith<GdkSignPsbtResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkSignPsbtResultCopyWith<$Res> {
  factory $GdkSignPsbtResultCopyWith(
          GdkSignPsbtResult value, $Res Function(GdkSignPsbtResult) then) =
      _$GdkSignPsbtResultCopyWithImpl<$Res, GdkSignPsbtResult>;
  @useResult
  $Res call(
      {@JsonKey(name: 'psbt') String psbt,
      @JsonKey(name: 'utxos') List<Map<String, dynamic>> utxos});
}

/// @nodoc
class _$GdkSignPsbtResultCopyWithImpl<$Res, $Val extends GdkSignPsbtResult>
    implements $GdkSignPsbtResultCopyWith<$Res> {
  _$GdkSignPsbtResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? psbt = null,
    Object? utxos = null,
  }) {
    return _then(_value.copyWith(
      psbt: null == psbt
          ? _value.psbt
          : psbt // ignore: cast_nullable_to_non_nullable
              as String,
      utxos: null == utxos
          ? _value.utxos
          : utxos // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GdkSignPsbtResultImplCopyWith<$Res>
    implements $GdkSignPsbtResultCopyWith<$Res> {
  factory _$$GdkSignPsbtResultImplCopyWith(_$GdkSignPsbtResultImpl value,
          $Res Function(_$GdkSignPsbtResultImpl) then) =
      __$$GdkSignPsbtResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'psbt') String psbt,
      @JsonKey(name: 'utxos') List<Map<String, dynamic>> utxos});
}

/// @nodoc
class __$$GdkSignPsbtResultImplCopyWithImpl<$Res>
    extends _$GdkSignPsbtResultCopyWithImpl<$Res, _$GdkSignPsbtResultImpl>
    implements _$$GdkSignPsbtResultImplCopyWith<$Res> {
  __$$GdkSignPsbtResultImplCopyWithImpl(_$GdkSignPsbtResultImpl _value,
      $Res Function(_$GdkSignPsbtResultImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? psbt = null,
    Object? utxos = null,
  }) {
    return _then(_$GdkSignPsbtResultImpl(
      psbt: null == psbt
          ? _value.psbt
          : psbt // ignore: cast_nullable_to_non_nullable
              as String,
      utxos: null == utxos
          ? _value._utxos
          : utxos // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkSignPsbtResultImpl extends _GdkSignPsbtResult {
  const _$GdkSignPsbtResultImpl(
      {@JsonKey(name: 'psbt') required this.psbt,
      @JsonKey(name: 'utxos') required final List<Map<String, dynamic>> utxos})
      : _utxos = utxos,
        super._();

  factory _$GdkSignPsbtResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$GdkSignPsbtResultImplFromJson(json);

  @override
  @JsonKey(name: 'psbt')
  final String psbt;
  final List<Map<String, dynamic>> _utxos;
  @override
  @JsonKey(name: 'utxos')
  List<Map<String, dynamic>> get utxos {
    if (_utxos is EqualUnmodifiableListView) return _utxos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_utxos);
  }

  @override
  String toString() {
    return 'GdkSignPsbtResult(psbt: $psbt, utxos: $utxos)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkSignPsbtResultImpl &&
            (identical(other.psbt, psbt) || other.psbt == psbt) &&
            const DeepCollectionEquality().equals(other._utxos, _utxos));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, psbt, const DeepCollectionEquality().hash(_utxos));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkSignPsbtResultImplCopyWith<_$GdkSignPsbtResultImpl> get copyWith =>
      __$$GdkSignPsbtResultImplCopyWithImpl<_$GdkSignPsbtResultImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkSignPsbtResultImplToJson(
      this,
    );
  }
}

abstract class _GdkSignPsbtResult extends GdkSignPsbtResult {
  const factory _GdkSignPsbtResult(
          {@JsonKey(name: 'psbt') required final String psbt,
          @JsonKey(name: 'utxos')
          required final List<Map<String, dynamic>> utxos}) =
      _$GdkSignPsbtResultImpl;
  const _GdkSignPsbtResult._() : super._();

  factory _GdkSignPsbtResult.fromJson(Map<String, dynamic> json) =
      _$GdkSignPsbtResultImpl.fromJson;

  @override
  @JsonKey(name: 'psbt')
  String get psbt;
  @override
  @JsonKey(name: 'utxos')
  List<Map<String, dynamic>> get utxos;
  @override
  @JsonKey(ignore: true)
  _$$GdkSignPsbtResultImplCopyWith<_$GdkSignPsbtResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GdkGetFeeEstimatesEvent _$GdkGetFeeEstimatesEventFromJson(
    Map<String, dynamic> json) {
  return _GdkGetFeeEstimatesEvent.fromJson(json);
}

/// @nodoc
mixin _$GdkGetFeeEstimatesEvent {
  List<int>? get fees => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkGetFeeEstimatesEventCopyWith<GdkGetFeeEstimatesEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkGetFeeEstimatesEventCopyWith<$Res> {
  factory $GdkGetFeeEstimatesEventCopyWith(GdkGetFeeEstimatesEvent value,
          $Res Function(GdkGetFeeEstimatesEvent) then) =
      _$GdkGetFeeEstimatesEventCopyWithImpl<$Res, GdkGetFeeEstimatesEvent>;
  @useResult
  $Res call({List<int>? fees});
}

/// @nodoc
class _$GdkGetFeeEstimatesEventCopyWithImpl<$Res,
        $Val extends GdkGetFeeEstimatesEvent>
    implements $GdkGetFeeEstimatesEventCopyWith<$Res> {
  _$GdkGetFeeEstimatesEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fees = freezed,
  }) {
    return _then(_value.copyWith(
      fees: freezed == fees
          ? _value.fees
          : fees // ignore: cast_nullable_to_non_nullable
              as List<int>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GdkGetFeeEstimatesEventImplCopyWith<$Res>
    implements $GdkGetFeeEstimatesEventCopyWith<$Res> {
  factory _$$GdkGetFeeEstimatesEventImplCopyWith(
          _$GdkGetFeeEstimatesEventImpl value,
          $Res Function(_$GdkGetFeeEstimatesEventImpl) then) =
      __$$GdkGetFeeEstimatesEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<int>? fees});
}

/// @nodoc
class __$$GdkGetFeeEstimatesEventImplCopyWithImpl<$Res>
    extends _$GdkGetFeeEstimatesEventCopyWithImpl<$Res,
        _$GdkGetFeeEstimatesEventImpl>
    implements _$$GdkGetFeeEstimatesEventImplCopyWith<$Res> {
  __$$GdkGetFeeEstimatesEventImplCopyWithImpl(
      _$GdkGetFeeEstimatesEventImpl _value,
      $Res Function(_$GdkGetFeeEstimatesEventImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fees = freezed,
  }) {
    return _then(_$GdkGetFeeEstimatesEventImpl(
      fees: freezed == fees
          ? _value._fees
          : fees // ignore: cast_nullable_to_non_nullable
              as List<int>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkGetFeeEstimatesEventImpl implements _GdkGetFeeEstimatesEvent {
  const _$GdkGetFeeEstimatesEventImpl({final List<int>? fees}) : _fees = fees;

  factory _$GdkGetFeeEstimatesEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$GdkGetFeeEstimatesEventImplFromJson(json);

  final List<int>? _fees;
  @override
  List<int>? get fees {
    final value = _fees;
    if (value == null) return null;
    if (_fees is EqualUnmodifiableListView) return _fees;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'GdkGetFeeEstimatesEvent(fees: $fees)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkGetFeeEstimatesEventImpl &&
            const DeepCollectionEquality().equals(other._fees, _fees));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_fees));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkGetFeeEstimatesEventImplCopyWith<_$GdkGetFeeEstimatesEventImpl>
      get copyWith => __$$GdkGetFeeEstimatesEventImplCopyWithImpl<
          _$GdkGetFeeEstimatesEventImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkGetFeeEstimatesEventImplToJson(
      this,
    );
  }
}

abstract class _GdkGetFeeEstimatesEvent implements GdkGetFeeEstimatesEvent {
  const factory _GdkGetFeeEstimatesEvent({final List<int>? fees}) =
      _$GdkGetFeeEstimatesEventImpl;

  factory _GdkGetFeeEstimatesEvent.fromJson(Map<String, dynamic> json) =
      _$GdkGetFeeEstimatesEventImpl.fromJson;

  @override
  List<int>? get fees;
  @override
  @JsonKey(ignore: true)
  _$$GdkGetFeeEstimatesEventImplCopyWith<_$GdkGetFeeEstimatesEventImpl>
      get copyWith => throw _privateConstructorUsedError;
}

GdkBlockEvent _$GdkBlockEventFromJson(Map<String, dynamic> json) {
  return _GdkBlockEvent.fromJson(json);
}

/// @nodoc
mixin _$GdkBlockEvent {
  @JsonKey(name: 'block_hash')
  String? get blockHash => throw _privateConstructorUsedError;
  @JsonKey(name: 'block_height')
  int? get blockHeight => throw _privateConstructorUsedError;
  @JsonKey(name: 'initial_timestamp')
  int? get initialTimestamp => throw _privateConstructorUsedError;
  @JsonKey(name: 'previous_hash')
  String? get previousHash => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkBlockEventCopyWith<GdkBlockEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkBlockEventCopyWith<$Res> {
  factory $GdkBlockEventCopyWith(
          GdkBlockEvent value, $Res Function(GdkBlockEvent) then) =
      _$GdkBlockEventCopyWithImpl<$Res, GdkBlockEvent>;
  @useResult
  $Res call(
      {@JsonKey(name: 'block_hash') String? blockHash,
      @JsonKey(name: 'block_height') int? blockHeight,
      @JsonKey(name: 'initial_timestamp') int? initialTimestamp,
      @JsonKey(name: 'previous_hash') String? previousHash});
}

/// @nodoc
class _$GdkBlockEventCopyWithImpl<$Res, $Val extends GdkBlockEvent>
    implements $GdkBlockEventCopyWith<$Res> {
  _$GdkBlockEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? blockHash = freezed,
    Object? blockHeight = freezed,
    Object? initialTimestamp = freezed,
    Object? previousHash = freezed,
  }) {
    return _then(_value.copyWith(
      blockHash: freezed == blockHash
          ? _value.blockHash
          : blockHash // ignore: cast_nullable_to_non_nullable
              as String?,
      blockHeight: freezed == blockHeight
          ? _value.blockHeight
          : blockHeight // ignore: cast_nullable_to_non_nullable
              as int?,
      initialTimestamp: freezed == initialTimestamp
          ? _value.initialTimestamp
          : initialTimestamp // ignore: cast_nullable_to_non_nullable
              as int?,
      previousHash: freezed == previousHash
          ? _value.previousHash
          : previousHash // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GdkBlockEventImplCopyWith<$Res>
    implements $GdkBlockEventCopyWith<$Res> {
  factory _$$GdkBlockEventImplCopyWith(
          _$GdkBlockEventImpl value, $Res Function(_$GdkBlockEventImpl) then) =
      __$$GdkBlockEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'block_hash') String? blockHash,
      @JsonKey(name: 'block_height') int? blockHeight,
      @JsonKey(name: 'initial_timestamp') int? initialTimestamp,
      @JsonKey(name: 'previous_hash') String? previousHash});
}

/// @nodoc
class __$$GdkBlockEventImplCopyWithImpl<$Res>
    extends _$GdkBlockEventCopyWithImpl<$Res, _$GdkBlockEventImpl>
    implements _$$GdkBlockEventImplCopyWith<$Res> {
  __$$GdkBlockEventImplCopyWithImpl(
      _$GdkBlockEventImpl _value, $Res Function(_$GdkBlockEventImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? blockHash = freezed,
    Object? blockHeight = freezed,
    Object? initialTimestamp = freezed,
    Object? previousHash = freezed,
  }) {
    return _then(_$GdkBlockEventImpl(
      blockHash: freezed == blockHash
          ? _value.blockHash
          : blockHash // ignore: cast_nullable_to_non_nullable
              as String?,
      blockHeight: freezed == blockHeight
          ? _value.blockHeight
          : blockHeight // ignore: cast_nullable_to_non_nullable
              as int?,
      initialTimestamp: freezed == initialTimestamp
          ? _value.initialTimestamp
          : initialTimestamp // ignore: cast_nullable_to_non_nullable
              as int?,
      previousHash: freezed == previousHash
          ? _value.previousHash
          : previousHash // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkBlockEventImpl implements _GdkBlockEvent {
  const _$GdkBlockEventImpl(
      {@JsonKey(name: 'block_hash') this.blockHash,
      @JsonKey(name: 'block_height') this.blockHeight,
      @JsonKey(name: 'initial_timestamp') this.initialTimestamp,
      @JsonKey(name: 'previous_hash') this.previousHash});

  factory _$GdkBlockEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$GdkBlockEventImplFromJson(json);

  @override
  @JsonKey(name: 'block_hash')
  final String? blockHash;
  @override
  @JsonKey(name: 'block_height')
  final int? blockHeight;
  @override
  @JsonKey(name: 'initial_timestamp')
  final int? initialTimestamp;
  @override
  @JsonKey(name: 'previous_hash')
  final String? previousHash;

  @override
  String toString() {
    return 'GdkBlockEvent(blockHash: $blockHash, blockHeight: $blockHeight, initialTimestamp: $initialTimestamp, previousHash: $previousHash)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkBlockEventImpl &&
            (identical(other.blockHash, blockHash) ||
                other.blockHash == blockHash) &&
            (identical(other.blockHeight, blockHeight) ||
                other.blockHeight == blockHeight) &&
            (identical(other.initialTimestamp, initialTimestamp) ||
                other.initialTimestamp == initialTimestamp) &&
            (identical(other.previousHash, previousHash) ||
                other.previousHash == previousHash));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, blockHash, blockHeight, initialTimestamp, previousHash);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkBlockEventImplCopyWith<_$GdkBlockEventImpl> get copyWith =>
      __$$GdkBlockEventImplCopyWithImpl<_$GdkBlockEventImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkBlockEventImplToJson(
      this,
    );
  }
}

abstract class _GdkBlockEvent implements GdkBlockEvent {
  const factory _GdkBlockEvent(
          {@JsonKey(name: 'block_hash') final String? blockHash,
          @JsonKey(name: 'block_height') final int? blockHeight,
          @JsonKey(name: 'initial_timestamp') final int? initialTimestamp,
          @JsonKey(name: 'previous_hash') final String? previousHash}) =
      _$GdkBlockEventImpl;

  factory _GdkBlockEvent.fromJson(Map<String, dynamic> json) =
      _$GdkBlockEventImpl.fromJson;

  @override
  @JsonKey(name: 'block_hash')
  String? get blockHash;
  @override
  @JsonKey(name: 'block_height')
  int? get blockHeight;
  @override
  @JsonKey(name: 'initial_timestamp')
  int? get initialTimestamp;
  @override
  @JsonKey(name: 'previous_hash')
  String? get previousHash;
  @override
  @JsonKey(ignore: true)
  _$$GdkBlockEventImplCopyWith<_$GdkBlockEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GdkSettingsEventNotifications _$GdkSettingsEventNotificationsFromJson(
    Map<String, dynamic> json) {
  return _GdkSettingsEventNotifications.fromJson(json);
}

/// @nodoc
mixin _$GdkSettingsEventNotifications {
  @JsonValue('email_incoming')
  bool? get emailIncoming => throw _privateConstructorUsedError;
  @JsonValue('email_outgoing')
  bool? get emailOutgoing => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkSettingsEventNotificationsCopyWith<GdkSettingsEventNotifications>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkSettingsEventNotificationsCopyWith<$Res> {
  factory $GdkSettingsEventNotificationsCopyWith(
          GdkSettingsEventNotifications value,
          $Res Function(GdkSettingsEventNotifications) then) =
      _$GdkSettingsEventNotificationsCopyWithImpl<$Res,
          GdkSettingsEventNotifications>;
  @useResult
  $Res call(
      {@JsonValue('email_incoming') bool? emailIncoming,
      @JsonValue('email_outgoing') bool? emailOutgoing});
}

/// @nodoc
class _$GdkSettingsEventNotificationsCopyWithImpl<$Res,
        $Val extends GdkSettingsEventNotifications>
    implements $GdkSettingsEventNotificationsCopyWith<$Res> {
  _$GdkSettingsEventNotificationsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? emailIncoming = freezed,
    Object? emailOutgoing = freezed,
  }) {
    return _then(_value.copyWith(
      emailIncoming: freezed == emailIncoming
          ? _value.emailIncoming
          : emailIncoming // ignore: cast_nullable_to_non_nullable
              as bool?,
      emailOutgoing: freezed == emailOutgoing
          ? _value.emailOutgoing
          : emailOutgoing // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GdkSettingsEventNotificationsImplCopyWith<$Res>
    implements $GdkSettingsEventNotificationsCopyWith<$Res> {
  factory _$$GdkSettingsEventNotificationsImplCopyWith(
          _$GdkSettingsEventNotificationsImpl value,
          $Res Function(_$GdkSettingsEventNotificationsImpl) then) =
      __$$GdkSettingsEventNotificationsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonValue('email_incoming') bool? emailIncoming,
      @JsonValue('email_outgoing') bool? emailOutgoing});
}

/// @nodoc
class __$$GdkSettingsEventNotificationsImplCopyWithImpl<$Res>
    extends _$GdkSettingsEventNotificationsCopyWithImpl<$Res,
        _$GdkSettingsEventNotificationsImpl>
    implements _$$GdkSettingsEventNotificationsImplCopyWith<$Res> {
  __$$GdkSettingsEventNotificationsImplCopyWithImpl(
      _$GdkSettingsEventNotificationsImpl _value,
      $Res Function(_$GdkSettingsEventNotificationsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? emailIncoming = freezed,
    Object? emailOutgoing = freezed,
  }) {
    return _then(_$GdkSettingsEventNotificationsImpl(
      emailIncoming: freezed == emailIncoming
          ? _value.emailIncoming
          : emailIncoming // ignore: cast_nullable_to_non_nullable
              as bool?,
      emailOutgoing: freezed == emailOutgoing
          ? _value.emailOutgoing
          : emailOutgoing // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkSettingsEventNotificationsImpl
    implements _GdkSettingsEventNotifications {
  const _$GdkSettingsEventNotificationsImpl(
      {@JsonValue('email_incoming') this.emailIncoming,
      @JsonValue('email_outgoing') this.emailOutgoing});

  factory _$GdkSettingsEventNotificationsImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$GdkSettingsEventNotificationsImplFromJson(json);

  @override
  @JsonValue('email_incoming')
  final bool? emailIncoming;
  @override
  @JsonValue('email_outgoing')
  final bool? emailOutgoing;

  @override
  String toString() {
    return 'GdkSettingsEventNotifications(emailIncoming: $emailIncoming, emailOutgoing: $emailOutgoing)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkSettingsEventNotificationsImpl &&
            (identical(other.emailIncoming, emailIncoming) ||
                other.emailIncoming == emailIncoming) &&
            (identical(other.emailOutgoing, emailOutgoing) ||
                other.emailOutgoing == emailOutgoing));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, emailIncoming, emailOutgoing);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkSettingsEventNotificationsImplCopyWith<
          _$GdkSettingsEventNotificationsImpl>
      get copyWith => __$$GdkSettingsEventNotificationsImplCopyWithImpl<
          _$GdkSettingsEventNotificationsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkSettingsEventNotificationsImplToJson(
      this,
    );
  }
}

abstract class _GdkSettingsEventNotifications
    implements GdkSettingsEventNotifications {
  const factory _GdkSettingsEventNotifications(
          {@JsonValue('email_incoming') final bool? emailIncoming,
          @JsonValue('email_outgoing') final bool? emailOutgoing}) =
      _$GdkSettingsEventNotificationsImpl;

  factory _GdkSettingsEventNotifications.fromJson(Map<String, dynamic> json) =
      _$GdkSettingsEventNotificationsImpl.fromJson;

  @override
  @JsonValue('email_incoming')
  bool? get emailIncoming;
  @override
  @JsonValue('email_outgoing')
  bool? get emailOutgoing;
  @override
  @JsonKey(ignore: true)
  _$$GdkSettingsEventNotificationsImplCopyWith<
          _$GdkSettingsEventNotificationsImpl>
      get copyWith => throw _privateConstructorUsedError;
}

GdkSettingsEvent _$GdkSettingsEventFromJson(Map<String, dynamic> json) {
  return _GdkSettingsEvent.fromJson(json);
}

/// @nodoc
mixin _$GdkSettingsEvent {
  int? get altimeout => throw _privateConstructorUsedError;
  int? get csvtime => throw _privateConstructorUsedError;
  int? get nlocktime => throw _privateConstructorUsedError;
  GdkSettingsEventNotifications? get notifications =>
      throw _privateConstructorUsedError;
  String? get pgp => throw _privateConstructorUsedError;
  GdkPricing? get pricing => throw _privateConstructorUsedError;
  @JsonKey(name: 'required_num_blocks')
  int? get requiredNumBlocks => throw _privateConstructorUsedError;
  bool? get sound => throw _privateConstructorUsedError;
  String? get unit => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkSettingsEventCopyWith<GdkSettingsEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkSettingsEventCopyWith<$Res> {
  factory $GdkSettingsEventCopyWith(
          GdkSettingsEvent value, $Res Function(GdkSettingsEvent) then) =
      _$GdkSettingsEventCopyWithImpl<$Res, GdkSettingsEvent>;
  @useResult
  $Res call(
      {int? altimeout,
      int? csvtime,
      int? nlocktime,
      GdkSettingsEventNotifications? notifications,
      String? pgp,
      GdkPricing? pricing,
      @JsonKey(name: 'required_num_blocks') int? requiredNumBlocks,
      bool? sound,
      String? unit});

  $GdkSettingsEventNotificationsCopyWith<$Res>? get notifications;
  $GdkPricingCopyWith<$Res>? get pricing;
}

/// @nodoc
class _$GdkSettingsEventCopyWithImpl<$Res, $Val extends GdkSettingsEvent>
    implements $GdkSettingsEventCopyWith<$Res> {
  _$GdkSettingsEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? altimeout = freezed,
    Object? csvtime = freezed,
    Object? nlocktime = freezed,
    Object? notifications = freezed,
    Object? pgp = freezed,
    Object? pricing = freezed,
    Object? requiredNumBlocks = freezed,
    Object? sound = freezed,
    Object? unit = freezed,
  }) {
    return _then(_value.copyWith(
      altimeout: freezed == altimeout
          ? _value.altimeout
          : altimeout // ignore: cast_nullable_to_non_nullable
              as int?,
      csvtime: freezed == csvtime
          ? _value.csvtime
          : csvtime // ignore: cast_nullable_to_non_nullable
              as int?,
      nlocktime: freezed == nlocktime
          ? _value.nlocktime
          : nlocktime // ignore: cast_nullable_to_non_nullable
              as int?,
      notifications: freezed == notifications
          ? _value.notifications
          : notifications // ignore: cast_nullable_to_non_nullable
              as GdkSettingsEventNotifications?,
      pgp: freezed == pgp
          ? _value.pgp
          : pgp // ignore: cast_nullable_to_non_nullable
              as String?,
      pricing: freezed == pricing
          ? _value.pricing
          : pricing // ignore: cast_nullable_to_non_nullable
              as GdkPricing?,
      requiredNumBlocks: freezed == requiredNumBlocks
          ? _value.requiredNumBlocks
          : requiredNumBlocks // ignore: cast_nullable_to_non_nullable
              as int?,
      sound: freezed == sound
          ? _value.sound
          : sound // ignore: cast_nullable_to_non_nullable
              as bool?,
      unit: freezed == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $GdkSettingsEventNotificationsCopyWith<$Res>? get notifications {
    if (_value.notifications == null) {
      return null;
    }

    return $GdkSettingsEventNotificationsCopyWith<$Res>(_value.notifications!,
        (value) {
      return _then(_value.copyWith(notifications: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $GdkPricingCopyWith<$Res>? get pricing {
    if (_value.pricing == null) {
      return null;
    }

    return $GdkPricingCopyWith<$Res>(_value.pricing!, (value) {
      return _then(_value.copyWith(pricing: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GdkSettingsEventImplCopyWith<$Res>
    implements $GdkSettingsEventCopyWith<$Res> {
  factory _$$GdkSettingsEventImplCopyWith(_$GdkSettingsEventImpl value,
          $Res Function(_$GdkSettingsEventImpl) then) =
      __$$GdkSettingsEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? altimeout,
      int? csvtime,
      int? nlocktime,
      GdkSettingsEventNotifications? notifications,
      String? pgp,
      GdkPricing? pricing,
      @JsonKey(name: 'required_num_blocks') int? requiredNumBlocks,
      bool? sound,
      String? unit});

  @override
  $GdkSettingsEventNotificationsCopyWith<$Res>? get notifications;
  @override
  $GdkPricingCopyWith<$Res>? get pricing;
}

/// @nodoc
class __$$GdkSettingsEventImplCopyWithImpl<$Res>
    extends _$GdkSettingsEventCopyWithImpl<$Res, _$GdkSettingsEventImpl>
    implements _$$GdkSettingsEventImplCopyWith<$Res> {
  __$$GdkSettingsEventImplCopyWithImpl(_$GdkSettingsEventImpl _value,
      $Res Function(_$GdkSettingsEventImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? altimeout = freezed,
    Object? csvtime = freezed,
    Object? nlocktime = freezed,
    Object? notifications = freezed,
    Object? pgp = freezed,
    Object? pricing = freezed,
    Object? requiredNumBlocks = freezed,
    Object? sound = freezed,
    Object? unit = freezed,
  }) {
    return _then(_$GdkSettingsEventImpl(
      altimeout: freezed == altimeout
          ? _value.altimeout
          : altimeout // ignore: cast_nullable_to_non_nullable
              as int?,
      csvtime: freezed == csvtime
          ? _value.csvtime
          : csvtime // ignore: cast_nullable_to_non_nullable
              as int?,
      nlocktime: freezed == nlocktime
          ? _value.nlocktime
          : nlocktime // ignore: cast_nullable_to_non_nullable
              as int?,
      notifications: freezed == notifications
          ? _value.notifications
          : notifications // ignore: cast_nullable_to_non_nullable
              as GdkSettingsEventNotifications?,
      pgp: freezed == pgp
          ? _value.pgp
          : pgp // ignore: cast_nullable_to_non_nullable
              as String?,
      pricing: freezed == pricing
          ? _value.pricing
          : pricing // ignore: cast_nullable_to_non_nullable
              as GdkPricing?,
      requiredNumBlocks: freezed == requiredNumBlocks
          ? _value.requiredNumBlocks
          : requiredNumBlocks // ignore: cast_nullable_to_non_nullable
              as int?,
      sound: freezed == sound
          ? _value.sound
          : sound // ignore: cast_nullable_to_non_nullable
              as bool?,
      unit: freezed == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkSettingsEventImpl implements _GdkSettingsEvent {
  const _$GdkSettingsEventImpl(
      {this.altimeout,
      this.csvtime,
      this.nlocktime,
      this.notifications,
      this.pgp,
      this.pricing,
      @JsonKey(name: 'required_num_blocks') this.requiredNumBlocks,
      this.sound,
      this.unit});

  factory _$GdkSettingsEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$GdkSettingsEventImplFromJson(json);

  @override
  final int? altimeout;
  @override
  final int? csvtime;
  @override
  final int? nlocktime;
  @override
  final GdkSettingsEventNotifications? notifications;
  @override
  final String? pgp;
  @override
  final GdkPricing? pricing;
  @override
  @JsonKey(name: 'required_num_blocks')
  final int? requiredNumBlocks;
  @override
  final bool? sound;
  @override
  final String? unit;

  @override
  String toString() {
    return 'GdkSettingsEvent(altimeout: $altimeout, csvtime: $csvtime, nlocktime: $nlocktime, notifications: $notifications, pgp: $pgp, pricing: $pricing, requiredNumBlocks: $requiredNumBlocks, sound: $sound, unit: $unit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkSettingsEventImpl &&
            (identical(other.altimeout, altimeout) ||
                other.altimeout == altimeout) &&
            (identical(other.csvtime, csvtime) || other.csvtime == csvtime) &&
            (identical(other.nlocktime, nlocktime) ||
                other.nlocktime == nlocktime) &&
            (identical(other.notifications, notifications) ||
                other.notifications == notifications) &&
            (identical(other.pgp, pgp) || other.pgp == pgp) &&
            (identical(other.pricing, pricing) || other.pricing == pricing) &&
            (identical(other.requiredNumBlocks, requiredNumBlocks) ||
                other.requiredNumBlocks == requiredNumBlocks) &&
            (identical(other.sound, sound) || other.sound == sound) &&
            (identical(other.unit, unit) || other.unit == unit));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, altimeout, csvtime, nlocktime,
      notifications, pgp, pricing, requiredNumBlocks, sound, unit);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkSettingsEventImplCopyWith<_$GdkSettingsEventImpl> get copyWith =>
      __$$GdkSettingsEventImplCopyWithImpl<_$GdkSettingsEventImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkSettingsEventImplToJson(
      this,
    );
  }
}

abstract class _GdkSettingsEvent implements GdkSettingsEvent {
  const factory _GdkSettingsEvent(
      {final int? altimeout,
      final int? csvtime,
      final int? nlocktime,
      final GdkSettingsEventNotifications? notifications,
      final String? pgp,
      final GdkPricing? pricing,
      @JsonKey(name: 'required_num_blocks') final int? requiredNumBlocks,
      final bool? sound,
      final String? unit}) = _$GdkSettingsEventImpl;

  factory _GdkSettingsEvent.fromJson(Map<String, dynamic> json) =
      _$GdkSettingsEventImpl.fromJson;

  @override
  int? get altimeout;
  @override
  int? get csvtime;
  @override
  int? get nlocktime;
  @override
  GdkSettingsEventNotifications? get notifications;
  @override
  String? get pgp;
  @override
  GdkPricing? get pricing;
  @override
  @JsonKey(name: 'required_num_blocks')
  int? get requiredNumBlocks;
  @override
  bool? get sound;
  @override
  String? get unit;
  @override
  @JsonKey(ignore: true)
  _$$GdkSettingsEventImplCopyWith<_$GdkSettingsEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GdkTransactionEvent _$GdkTransactionEventFromJson(Map<String, dynamic> json) {
  return _GdkTransactionEvent.fromJson(json);
}

/// @nodoc
mixin _$GdkTransactionEvent {
  int? get satoshi => throw _privateConstructorUsedError;
  List<int>? get subaccounts => throw _privateConstructorUsedError;
  String? get txhash => throw _privateConstructorUsedError;
  GdkTransactionEventEnum? get type => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkTransactionEventCopyWith<GdkTransactionEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkTransactionEventCopyWith<$Res> {
  factory $GdkTransactionEventCopyWith(
          GdkTransactionEvent value, $Res Function(GdkTransactionEvent) then) =
      _$GdkTransactionEventCopyWithImpl<$Res, GdkTransactionEvent>;
  @useResult
  $Res call(
      {int? satoshi,
      List<int>? subaccounts,
      String? txhash,
      GdkTransactionEventEnum? type});
}

/// @nodoc
class _$GdkTransactionEventCopyWithImpl<$Res, $Val extends GdkTransactionEvent>
    implements $GdkTransactionEventCopyWith<$Res> {
  _$GdkTransactionEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? satoshi = freezed,
    Object? subaccounts = freezed,
    Object? txhash = freezed,
    Object? type = freezed,
  }) {
    return _then(_value.copyWith(
      satoshi: freezed == satoshi
          ? _value.satoshi
          : satoshi // ignore: cast_nullable_to_non_nullable
              as int?,
      subaccounts: freezed == subaccounts
          ? _value.subaccounts
          : subaccounts // ignore: cast_nullable_to_non_nullable
              as List<int>?,
      txhash: freezed == txhash
          ? _value.txhash
          : txhash // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as GdkTransactionEventEnum?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GdkTransactionEventImplCopyWith<$Res>
    implements $GdkTransactionEventCopyWith<$Res> {
  factory _$$GdkTransactionEventImplCopyWith(_$GdkTransactionEventImpl value,
          $Res Function(_$GdkTransactionEventImpl) then) =
      __$$GdkTransactionEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? satoshi,
      List<int>? subaccounts,
      String? txhash,
      GdkTransactionEventEnum? type});
}

/// @nodoc
class __$$GdkTransactionEventImplCopyWithImpl<$Res>
    extends _$GdkTransactionEventCopyWithImpl<$Res, _$GdkTransactionEventImpl>
    implements _$$GdkTransactionEventImplCopyWith<$Res> {
  __$$GdkTransactionEventImplCopyWithImpl(_$GdkTransactionEventImpl _value,
      $Res Function(_$GdkTransactionEventImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? satoshi = freezed,
    Object? subaccounts = freezed,
    Object? txhash = freezed,
    Object? type = freezed,
  }) {
    return _then(_$GdkTransactionEventImpl(
      satoshi: freezed == satoshi
          ? _value.satoshi
          : satoshi // ignore: cast_nullable_to_non_nullable
              as int?,
      subaccounts: freezed == subaccounts
          ? _value._subaccounts
          : subaccounts // ignore: cast_nullable_to_non_nullable
              as List<int>?,
      txhash: freezed == txhash
          ? _value.txhash
          : txhash // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as GdkTransactionEventEnum?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkTransactionEventImpl implements _GdkTransactionEvent {
  const _$GdkTransactionEventImpl(
      {this.satoshi, final List<int>? subaccounts, this.txhash, this.type})
      : _subaccounts = subaccounts;

  factory _$GdkTransactionEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$GdkTransactionEventImplFromJson(json);

  @override
  final int? satoshi;
  final List<int>? _subaccounts;
  @override
  List<int>? get subaccounts {
    final value = _subaccounts;
    if (value == null) return null;
    if (_subaccounts is EqualUnmodifiableListView) return _subaccounts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? txhash;
  @override
  final GdkTransactionEventEnum? type;

  @override
  String toString() {
    return 'GdkTransactionEvent(satoshi: $satoshi, subaccounts: $subaccounts, txhash: $txhash, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkTransactionEventImpl &&
            (identical(other.satoshi, satoshi) || other.satoshi == satoshi) &&
            const DeepCollectionEquality()
                .equals(other._subaccounts, _subaccounts) &&
            (identical(other.txhash, txhash) || other.txhash == txhash) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, satoshi,
      const DeepCollectionEquality().hash(_subaccounts), txhash, type);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkTransactionEventImplCopyWith<_$GdkTransactionEventImpl> get copyWith =>
      __$$GdkTransactionEventImplCopyWithImpl<_$GdkTransactionEventImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkTransactionEventImplToJson(
      this,
    );
  }
}

abstract class _GdkTransactionEvent implements GdkTransactionEvent {
  const factory _GdkTransactionEvent(
      {final int? satoshi,
      final List<int>? subaccounts,
      final String? txhash,
      final GdkTransactionEventEnum? type}) = _$GdkTransactionEventImpl;

  factory _GdkTransactionEvent.fromJson(Map<String, dynamic> json) =
      _$GdkTransactionEventImpl.fromJson;

  @override
  int? get satoshi;
  @override
  List<int>? get subaccounts;
  @override
  String? get txhash;
  @override
  GdkTransactionEventEnum? get type;
  @override
  @JsonKey(ignore: true)
  _$$GdkTransactionEventImplCopyWith<_$GdkTransactionEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GdkPricing _$GdkPricingFromJson(Map<String, dynamic> json) {
  return _GdkPricing.fromJson(json);
}

/// @nodoc
mixin _$GdkPricing {
  String? get currency => throw _privateConstructorUsedError;
  String? get exchange => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkPricingCopyWith<GdkPricing> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkPricingCopyWith<$Res> {
  factory $GdkPricingCopyWith(
          GdkPricing value, $Res Function(GdkPricing) then) =
      _$GdkPricingCopyWithImpl<$Res, GdkPricing>;
  @useResult
  $Res call({String? currency, String? exchange});
}

/// @nodoc
class _$GdkPricingCopyWithImpl<$Res, $Val extends GdkPricing>
    implements $GdkPricingCopyWith<$Res> {
  _$GdkPricingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currency = freezed,
    Object? exchange = freezed,
  }) {
    return _then(_value.copyWith(
      currency: freezed == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String?,
      exchange: freezed == exchange
          ? _value.exchange
          : exchange // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GdkPricingImplCopyWith<$Res>
    implements $GdkPricingCopyWith<$Res> {
  factory _$$GdkPricingImplCopyWith(
          _$GdkPricingImpl value, $Res Function(_$GdkPricingImpl) then) =
      __$$GdkPricingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? currency, String? exchange});
}

/// @nodoc
class __$$GdkPricingImplCopyWithImpl<$Res>
    extends _$GdkPricingCopyWithImpl<$Res, _$GdkPricingImpl>
    implements _$$GdkPricingImplCopyWith<$Res> {
  __$$GdkPricingImplCopyWithImpl(
      _$GdkPricingImpl _value, $Res Function(_$GdkPricingImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currency = freezed,
    Object? exchange = freezed,
  }) {
    return _then(_$GdkPricingImpl(
      currency: freezed == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String?,
      exchange: freezed == exchange
          ? _value.exchange
          : exchange // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkPricingImpl implements _GdkPricing {
  const _$GdkPricingImpl({this.currency, this.exchange});

  factory _$GdkPricingImpl.fromJson(Map<String, dynamic> json) =>
      _$$GdkPricingImplFromJson(json);

  @override
  final String? currency;
  @override
  final String? exchange;

  @override
  String toString() {
    return 'GdkPricing(currency: $currency, exchange: $exchange)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkPricingImpl &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.exchange, exchange) ||
                other.exchange == exchange));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, currency, exchange);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkPricingImplCopyWith<_$GdkPricingImpl> get copyWith =>
      __$$GdkPricingImplCopyWithImpl<_$GdkPricingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkPricingImplToJson(
      this,
    );
  }
}

abstract class _GdkPricing implements GdkPricing {
  const factory _GdkPricing({final String? currency, final String? exchange}) =
      _$GdkPricingImpl;

  factory _GdkPricing.fromJson(Map<String, dynamic> json) =
      _$GdkPricingImpl.fromJson;

  @override
  String? get currency;
  @override
  String? get exchange;
  @override
  @JsonKey(ignore: true)
  _$$GdkPricingImplCopyWith<_$GdkPricingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GdkAddressee _$GdkAddresseeFromJson(Map<String, dynamic> json) {
  return _GdkAddressee.fromJson(json);
}

/// @nodoc
mixin _$GdkAddressee {
  String? get address => throw _privateConstructorUsedError;
  int? get satoshi => throw _privateConstructorUsedError;
  @JsonKey(name: 'asset_id')
  String? get assetId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkAddresseeCopyWith<GdkAddressee> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkAddresseeCopyWith<$Res> {
  factory $GdkAddresseeCopyWith(
          GdkAddressee value, $Res Function(GdkAddressee) then) =
      _$GdkAddresseeCopyWithImpl<$Res, GdkAddressee>;
  @useResult
  $Res call(
      {String? address,
      int? satoshi,
      @JsonKey(name: 'asset_id') String? assetId});
}

/// @nodoc
class _$GdkAddresseeCopyWithImpl<$Res, $Val extends GdkAddressee>
    implements $GdkAddresseeCopyWith<$Res> {
  _$GdkAddresseeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? address = freezed,
    Object? satoshi = freezed,
    Object? assetId = freezed,
  }) {
    return _then(_value.copyWith(
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      satoshi: freezed == satoshi
          ? _value.satoshi
          : satoshi // ignore: cast_nullable_to_non_nullable
              as int?,
      assetId: freezed == assetId
          ? _value.assetId
          : assetId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GdkAddresseeImplCopyWith<$Res>
    implements $GdkAddresseeCopyWith<$Res> {
  factory _$$GdkAddresseeImplCopyWith(
          _$GdkAddresseeImpl value, $Res Function(_$GdkAddresseeImpl) then) =
      __$$GdkAddresseeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? address,
      int? satoshi,
      @JsonKey(name: 'asset_id') String? assetId});
}

/// @nodoc
class __$$GdkAddresseeImplCopyWithImpl<$Res>
    extends _$GdkAddresseeCopyWithImpl<$Res, _$GdkAddresseeImpl>
    implements _$$GdkAddresseeImplCopyWith<$Res> {
  __$$GdkAddresseeImplCopyWithImpl(
      _$GdkAddresseeImpl _value, $Res Function(_$GdkAddresseeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? address = freezed,
    Object? satoshi = freezed,
    Object? assetId = freezed,
  }) {
    return _then(_$GdkAddresseeImpl(
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      satoshi: freezed == satoshi
          ? _value.satoshi
          : satoshi // ignore: cast_nullable_to_non_nullable
              as int?,
      assetId: freezed == assetId
          ? _value.assetId
          : assetId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkAddresseeImpl implements _GdkAddressee {
  const _$GdkAddresseeImpl(
      {this.address, this.satoshi, @JsonKey(name: 'asset_id') this.assetId});

  factory _$GdkAddresseeImpl.fromJson(Map<String, dynamic> json) =>
      _$$GdkAddresseeImplFromJson(json);

  @override
  final String? address;
  @override
  final int? satoshi;
  @override
  @JsonKey(name: 'asset_id')
  final String? assetId;

  @override
  String toString() {
    return 'GdkAddressee(address: $address, satoshi: $satoshi, assetId: $assetId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkAddresseeImpl &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.satoshi, satoshi) || other.satoshi == satoshi) &&
            (identical(other.assetId, assetId) || other.assetId == assetId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, address, satoshi, assetId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkAddresseeImplCopyWith<_$GdkAddresseeImpl> get copyWith =>
      __$$GdkAddresseeImplCopyWithImpl<_$GdkAddresseeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkAddresseeImplToJson(
      this,
    );
  }
}

abstract class _GdkAddressee implements GdkAddressee {
  const factory _GdkAddressee(
      {final String? address,
      final int? satoshi,
      @JsonKey(name: 'asset_id') final String? assetId}) = _$GdkAddresseeImpl;

  factory _GdkAddressee.fromJson(Map<String, dynamic> json) =
      _$GdkAddresseeImpl.fromJson;

  @override
  String? get address;
  @override
  int? get satoshi;
  @override
  @JsonKey(name: 'asset_id')
  String? get assetId;
  @override
  @JsonKey(ignore: true)
  _$$GdkAddresseeImplCopyWith<_$GdkAddresseeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GdkNewTransaction _$GdkNewTransactionFromJson(Map<String, dynamic> json) {
  return _GdkNewTransaction.fromJson(json);
}

/// @nodoc
mixin _$GdkNewTransaction {
  List<GdkAddressee>? get addressees => throw _privateConstructorUsedError;
  int? get subaccount => throw _privateConstructorUsedError;
  @JsonKey(name: 'fee_rate')
  int? get feeRate => throw _privateConstructorUsedError;
  @JsonKey(name: 'send_all')
  bool? get sendAll => throw _privateConstructorUsedError;
  @JsonKey(name: 'utxo_strategy')
  GdkUtxoStrategyEnum? get utxoStrategy => throw _privateConstructorUsedError;
  @JsonKey(name: 'used_utxos')
  String? get usedUtxos => throw _privateConstructorUsedError;
  String? get memo => throw _privateConstructorUsedError;
  Map<String, List<GdkUnspentOutputs>>? get utxos =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkNewTransactionCopyWith<GdkNewTransaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkNewTransactionCopyWith<$Res> {
  factory $GdkNewTransactionCopyWith(
          GdkNewTransaction value, $Res Function(GdkNewTransaction) then) =
      _$GdkNewTransactionCopyWithImpl<$Res, GdkNewTransaction>;
  @useResult
  $Res call(
      {List<GdkAddressee>? addressees,
      int? subaccount,
      @JsonKey(name: 'fee_rate') int? feeRate,
      @JsonKey(name: 'send_all') bool? sendAll,
      @JsonKey(name: 'utxo_strategy') GdkUtxoStrategyEnum? utxoStrategy,
      @JsonKey(name: 'used_utxos') String? usedUtxos,
      String? memo,
      Map<String, List<GdkUnspentOutputs>>? utxos});
}

/// @nodoc
class _$GdkNewTransactionCopyWithImpl<$Res, $Val extends GdkNewTransaction>
    implements $GdkNewTransactionCopyWith<$Res> {
  _$GdkNewTransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? addressees = freezed,
    Object? subaccount = freezed,
    Object? feeRate = freezed,
    Object? sendAll = freezed,
    Object? utxoStrategy = freezed,
    Object? usedUtxos = freezed,
    Object? memo = freezed,
    Object? utxos = freezed,
  }) {
    return _then(_value.copyWith(
      addressees: freezed == addressees
          ? _value.addressees
          : addressees // ignore: cast_nullable_to_non_nullable
              as List<GdkAddressee>?,
      subaccount: freezed == subaccount
          ? _value.subaccount
          : subaccount // ignore: cast_nullable_to_non_nullable
              as int?,
      feeRate: freezed == feeRate
          ? _value.feeRate
          : feeRate // ignore: cast_nullable_to_non_nullable
              as int?,
      sendAll: freezed == sendAll
          ? _value.sendAll
          : sendAll // ignore: cast_nullable_to_non_nullable
              as bool?,
      utxoStrategy: freezed == utxoStrategy
          ? _value.utxoStrategy
          : utxoStrategy // ignore: cast_nullable_to_non_nullable
              as GdkUtxoStrategyEnum?,
      usedUtxos: freezed == usedUtxos
          ? _value.usedUtxos
          : usedUtxos // ignore: cast_nullable_to_non_nullable
              as String?,
      memo: freezed == memo
          ? _value.memo
          : memo // ignore: cast_nullable_to_non_nullable
              as String?,
      utxos: freezed == utxos
          ? _value.utxos
          : utxos // ignore: cast_nullable_to_non_nullable
              as Map<String, List<GdkUnspentOutputs>>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GdkNewTransactionImplCopyWith<$Res>
    implements $GdkNewTransactionCopyWith<$Res> {
  factory _$$GdkNewTransactionImplCopyWith(_$GdkNewTransactionImpl value,
          $Res Function(_$GdkNewTransactionImpl) then) =
      __$$GdkNewTransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<GdkAddressee>? addressees,
      int? subaccount,
      @JsonKey(name: 'fee_rate') int? feeRate,
      @JsonKey(name: 'send_all') bool? sendAll,
      @JsonKey(name: 'utxo_strategy') GdkUtxoStrategyEnum? utxoStrategy,
      @JsonKey(name: 'used_utxos') String? usedUtxos,
      String? memo,
      Map<String, List<GdkUnspentOutputs>>? utxos});
}

/// @nodoc
class __$$GdkNewTransactionImplCopyWithImpl<$Res>
    extends _$GdkNewTransactionCopyWithImpl<$Res, _$GdkNewTransactionImpl>
    implements _$$GdkNewTransactionImplCopyWith<$Res> {
  __$$GdkNewTransactionImplCopyWithImpl(_$GdkNewTransactionImpl _value,
      $Res Function(_$GdkNewTransactionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? addressees = freezed,
    Object? subaccount = freezed,
    Object? feeRate = freezed,
    Object? sendAll = freezed,
    Object? utxoStrategy = freezed,
    Object? usedUtxos = freezed,
    Object? memo = freezed,
    Object? utxos = freezed,
  }) {
    return _then(_$GdkNewTransactionImpl(
      addressees: freezed == addressees
          ? _value._addressees
          : addressees // ignore: cast_nullable_to_non_nullable
              as List<GdkAddressee>?,
      subaccount: freezed == subaccount
          ? _value.subaccount
          : subaccount // ignore: cast_nullable_to_non_nullable
              as int?,
      feeRate: freezed == feeRate
          ? _value.feeRate
          : feeRate // ignore: cast_nullable_to_non_nullable
              as int?,
      sendAll: freezed == sendAll
          ? _value.sendAll
          : sendAll // ignore: cast_nullable_to_non_nullable
              as bool?,
      utxoStrategy: freezed == utxoStrategy
          ? _value.utxoStrategy
          : utxoStrategy // ignore: cast_nullable_to_non_nullable
              as GdkUtxoStrategyEnum?,
      usedUtxos: freezed == usedUtxos
          ? _value.usedUtxos
          : usedUtxos // ignore: cast_nullable_to_non_nullable
              as String?,
      memo: freezed == memo
          ? _value.memo
          : memo // ignore: cast_nullable_to_non_nullable
              as String?,
      utxos: freezed == utxos
          ? _value._utxos
          : utxos // ignore: cast_nullable_to_non_nullable
              as Map<String, List<GdkUnspentOutputs>>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkNewTransactionImpl extends _GdkNewTransaction {
  const _$GdkNewTransactionImpl(
      {final List<GdkAddressee>? addressees,
      this.subaccount = 1,
      @JsonKey(name: 'fee_rate') this.feeRate = 1000,
      @JsonKey(name: 'send_all') this.sendAll = false,
      @JsonKey(name: 'utxo_strategy')
      this.utxoStrategy = GdkUtxoStrategyEnum.defaultStrategy,
      @JsonKey(name: 'used_utxos') this.usedUtxos,
      this.memo,
      final Map<String, List<GdkUnspentOutputs>>? utxos})
      : _addressees = addressees,
        _utxos = utxos,
        super._();

  factory _$GdkNewTransactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$GdkNewTransactionImplFromJson(json);

  final List<GdkAddressee>? _addressees;
  @override
  List<GdkAddressee>? get addressees {
    final value = _addressees;
    if (value == null) return null;
    if (_addressees is EqualUnmodifiableListView) return _addressees;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey()
  final int? subaccount;
  @override
  @JsonKey(name: 'fee_rate')
  final int? feeRate;
  @override
  @JsonKey(name: 'send_all')
  final bool? sendAll;
  @override
  @JsonKey(name: 'utxo_strategy')
  final GdkUtxoStrategyEnum? utxoStrategy;
  @override
  @JsonKey(name: 'used_utxos')
  final String? usedUtxos;
  @override
  final String? memo;
  final Map<String, List<GdkUnspentOutputs>>? _utxos;
  @override
  Map<String, List<GdkUnspentOutputs>>? get utxos {
    final value = _utxos;
    if (value == null) return null;
    if (_utxos is EqualUnmodifiableMapView) return _utxos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'GdkNewTransaction(addressees: $addressees, subaccount: $subaccount, feeRate: $feeRate, sendAll: $sendAll, utxoStrategy: $utxoStrategy, usedUtxos: $usedUtxos, memo: $memo, utxos: $utxos)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkNewTransactionImpl &&
            const DeepCollectionEquality()
                .equals(other._addressees, _addressees) &&
            (identical(other.subaccount, subaccount) ||
                other.subaccount == subaccount) &&
            (identical(other.feeRate, feeRate) || other.feeRate == feeRate) &&
            (identical(other.sendAll, sendAll) || other.sendAll == sendAll) &&
            (identical(other.utxoStrategy, utxoStrategy) ||
                other.utxoStrategy == utxoStrategy) &&
            (identical(other.usedUtxos, usedUtxos) ||
                other.usedUtxos == usedUtxos) &&
            (identical(other.memo, memo) || other.memo == memo) &&
            const DeepCollectionEquality().equals(other._utxos, _utxos));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_addressees),
      subaccount,
      feeRate,
      sendAll,
      utxoStrategy,
      usedUtxos,
      memo,
      const DeepCollectionEquality().hash(_utxos));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkNewTransactionImplCopyWith<_$GdkNewTransactionImpl> get copyWith =>
      __$$GdkNewTransactionImplCopyWithImpl<_$GdkNewTransactionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkNewTransactionImplToJson(
      this,
    );
  }
}

abstract class _GdkNewTransaction extends GdkNewTransaction {
  const factory _GdkNewTransaction(
      {final List<GdkAddressee>? addressees,
      final int? subaccount,
      @JsonKey(name: 'fee_rate') final int? feeRate,
      @JsonKey(name: 'send_all') final bool? sendAll,
      @JsonKey(name: 'utxo_strategy') final GdkUtxoStrategyEnum? utxoStrategy,
      @JsonKey(name: 'used_utxos') final String? usedUtxos,
      final String? memo,
      final Map<String, List<GdkUnspentOutputs>>?
          utxos}) = _$GdkNewTransactionImpl;
  const _GdkNewTransaction._() : super._();

  factory _GdkNewTransaction.fromJson(Map<String, dynamic> json) =
      _$GdkNewTransactionImpl.fromJson;

  @override
  List<GdkAddressee>? get addressees;
  @override
  int? get subaccount;
  @override
  @JsonKey(name: 'fee_rate')
  int? get feeRate;
  @override
  @JsonKey(name: 'send_all')
  bool? get sendAll;
  @override
  @JsonKey(name: 'utxo_strategy')
  GdkUtxoStrategyEnum? get utxoStrategy;
  @override
  @JsonKey(name: 'used_utxos')
  String? get usedUtxos;
  @override
  String? get memo;
  @override
  Map<String, List<GdkUnspentOutputs>>? get utxos;
  @override
  @JsonKey(ignore: true)
  _$$GdkNewTransactionImplCopyWith<_$GdkNewTransactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GdkNewTransactionReply _$GdkNewTransactionReplyFromJson(
    Map<String, dynamic> json) {
  return _GdkNewTransactionReply.fromJson(json);
}

/// @nodoc
mixin _$GdkNewTransactionReply {
  List<GdkAddressee>? get addressees => throw _privateConstructorUsedError;
  @JsonKey(name: 'addressees_have_assets')
  bool? get addresseesHaveAssets => throw _privateConstructorUsedError;
  @JsonKey(name: 'addressees_read_only')
  bool? get addresseesReadOnly => throw _privateConstructorUsedError;
  @JsonKey(name: 'changes_used')
  int? get changesUsed => throw _privateConstructorUsedError;
  @JsonKey(name: 'confidential_utxos_only')
  bool? get confidentialUtxosOnly => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  int? get fee => throw _privateConstructorUsedError;
  @JsonKey(name: 'fee_rate')
  int? get feeRate => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_sweep')
  bool? get isSweep => throw _privateConstructorUsedError;
  String? get network => throw _privateConstructorUsedError;
  @JsonKey(name: 'num_confs')
  int? get numConfs => throw _privateConstructorUsedError;
  @JsonKey(name: 'rbf_optin')
  bool? get rbfOptin => throw _privateConstructorUsedError;
  Map<String, dynamic>? get satoshi => throw _privateConstructorUsedError;
  @JsonKey(name: 'send_all')
  bool? get sendAll => throw _privateConstructorUsedError;
  @JsonKey(name: 'spv_verified')
  String? get spvVerified => throw _privateConstructorUsedError;
  int? get subaccount => throw _privateConstructorUsedError;
  int? get timestamp => throw _privateConstructorUsedError;
  String? get transaction => throw _privateConstructorUsedError;
  @JsonKey(name: 'transaction_size')
  int? get transactionSize => throw _privateConstructorUsedError;
  @JsonKey(name: 'transaction_vsize')
  int? get transactionVsize => throw _privateConstructorUsedError;
  @JsonKey(name: 'transaction_weight')
  int? get transactionWeight => throw _privateConstructorUsedError;
  @JsonKey(name: 'transaction_version')
  int? get transactionVersion => throw _privateConstructorUsedError;
  @JsonKey(name: 'transaction_locktime')
  int? get transactionLocktime => throw _privateConstructorUsedError;
  @JsonKey(name: 'transaction_outputs')
  dynamic get transactionOutputs => throw _privateConstructorUsedError;
  @JsonKey(name: 'used_utxos')
  dynamic get usedUtxos => throw _privateConstructorUsedError;
  String? get txhash => throw _privateConstructorUsedError;
  GdkTransactionTypeEnum? get type => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_signed')
  bool? get userSigned => throw _privateConstructorUsedError;
  @JsonKey(name: 'utxo_strategy')
  String? get utxoStrategy => throw _privateConstructorUsedError;
  String? get memo => throw _privateConstructorUsedError;
  Map<String, dynamic>? get utxos => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkNewTransactionReplyCopyWith<GdkNewTransactionReply> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkNewTransactionReplyCopyWith<$Res> {
  factory $GdkNewTransactionReplyCopyWith(GdkNewTransactionReply value,
          $Res Function(GdkNewTransactionReply) then) =
      _$GdkNewTransactionReplyCopyWithImpl<$Res, GdkNewTransactionReply>;
  @useResult
  $Res call(
      {List<GdkAddressee>? addressees,
      @JsonKey(name: 'addressees_have_assets') bool? addresseesHaveAssets,
      @JsonKey(name: 'addressees_read_only') bool? addresseesReadOnly,
      @JsonKey(name: 'changes_used') int? changesUsed,
      @JsonKey(name: 'confidential_utxos_only') bool? confidentialUtxosOnly,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      String? error,
      int? fee,
      @JsonKey(name: 'fee_rate') int? feeRate,
      @JsonKey(name: 'is_sweep') bool? isSweep,
      String? network,
      @JsonKey(name: 'num_confs') int? numConfs,
      @JsonKey(name: 'rbf_optin') bool? rbfOptin,
      Map<String, dynamic>? satoshi,
      @JsonKey(name: 'send_all') bool? sendAll,
      @JsonKey(name: 'spv_verified') String? spvVerified,
      int? subaccount,
      int? timestamp,
      String? transaction,
      @JsonKey(name: 'transaction_size') int? transactionSize,
      @JsonKey(name: 'transaction_vsize') int? transactionVsize,
      @JsonKey(name: 'transaction_weight') int? transactionWeight,
      @JsonKey(name: 'transaction_version') int? transactionVersion,
      @JsonKey(name: 'transaction_locktime') int? transactionLocktime,
      @JsonKey(name: 'transaction_outputs') dynamic transactionOutputs,
      @JsonKey(name: 'used_utxos') dynamic usedUtxos,
      String? txhash,
      GdkTransactionTypeEnum? type,
      @JsonKey(name: 'user_signed') bool? userSigned,
      @JsonKey(name: 'utxo_strategy') String? utxoStrategy,
      String? memo,
      Map<String, dynamic>? utxos});
}

/// @nodoc
class _$GdkNewTransactionReplyCopyWithImpl<$Res,
        $Val extends GdkNewTransactionReply>
    implements $GdkNewTransactionReplyCopyWith<$Res> {
  _$GdkNewTransactionReplyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? addressees = freezed,
    Object? addresseesHaveAssets = freezed,
    Object? addresseesReadOnly = freezed,
    Object? changesUsed = freezed,
    Object? confidentialUtxosOnly = freezed,
    Object? createdAt = freezed,
    Object? error = freezed,
    Object? fee = freezed,
    Object? feeRate = freezed,
    Object? isSweep = freezed,
    Object? network = freezed,
    Object? numConfs = freezed,
    Object? rbfOptin = freezed,
    Object? satoshi = freezed,
    Object? sendAll = freezed,
    Object? spvVerified = freezed,
    Object? subaccount = freezed,
    Object? timestamp = freezed,
    Object? transaction = freezed,
    Object? transactionSize = freezed,
    Object? transactionVsize = freezed,
    Object? transactionWeight = freezed,
    Object? transactionVersion = freezed,
    Object? transactionLocktime = freezed,
    Object? transactionOutputs = freezed,
    Object? usedUtxos = freezed,
    Object? txhash = freezed,
    Object? type = freezed,
    Object? userSigned = freezed,
    Object? utxoStrategy = freezed,
    Object? memo = freezed,
    Object? utxos = freezed,
  }) {
    return _then(_value.copyWith(
      addressees: freezed == addressees
          ? _value.addressees
          : addressees // ignore: cast_nullable_to_non_nullable
              as List<GdkAddressee>?,
      addresseesHaveAssets: freezed == addresseesHaveAssets
          ? _value.addresseesHaveAssets
          : addresseesHaveAssets // ignore: cast_nullable_to_non_nullable
              as bool?,
      addresseesReadOnly: freezed == addresseesReadOnly
          ? _value.addresseesReadOnly
          : addresseesReadOnly // ignore: cast_nullable_to_non_nullable
              as bool?,
      changesUsed: freezed == changesUsed
          ? _value.changesUsed
          : changesUsed // ignore: cast_nullable_to_non_nullable
              as int?,
      confidentialUtxosOnly: freezed == confidentialUtxosOnly
          ? _value.confidentialUtxosOnly
          : confidentialUtxosOnly // ignore: cast_nullable_to_non_nullable
              as bool?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      fee: freezed == fee
          ? _value.fee
          : fee // ignore: cast_nullable_to_non_nullable
              as int?,
      feeRate: freezed == feeRate
          ? _value.feeRate
          : feeRate // ignore: cast_nullable_to_non_nullable
              as int?,
      isSweep: freezed == isSweep
          ? _value.isSweep
          : isSweep // ignore: cast_nullable_to_non_nullable
              as bool?,
      network: freezed == network
          ? _value.network
          : network // ignore: cast_nullable_to_non_nullable
              as String?,
      numConfs: freezed == numConfs
          ? _value.numConfs
          : numConfs // ignore: cast_nullable_to_non_nullable
              as int?,
      rbfOptin: freezed == rbfOptin
          ? _value.rbfOptin
          : rbfOptin // ignore: cast_nullable_to_non_nullable
              as bool?,
      satoshi: freezed == satoshi
          ? _value.satoshi
          : satoshi // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      sendAll: freezed == sendAll
          ? _value.sendAll
          : sendAll // ignore: cast_nullable_to_non_nullable
              as bool?,
      spvVerified: freezed == spvVerified
          ? _value.spvVerified
          : spvVerified // ignore: cast_nullable_to_non_nullable
              as String?,
      subaccount: freezed == subaccount
          ? _value.subaccount
          : subaccount // ignore: cast_nullable_to_non_nullable
              as int?,
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as int?,
      transaction: freezed == transaction
          ? _value.transaction
          : transaction // ignore: cast_nullable_to_non_nullable
              as String?,
      transactionSize: freezed == transactionSize
          ? _value.transactionSize
          : transactionSize // ignore: cast_nullable_to_non_nullable
              as int?,
      transactionVsize: freezed == transactionVsize
          ? _value.transactionVsize
          : transactionVsize // ignore: cast_nullable_to_non_nullable
              as int?,
      transactionWeight: freezed == transactionWeight
          ? _value.transactionWeight
          : transactionWeight // ignore: cast_nullable_to_non_nullable
              as int?,
      transactionVersion: freezed == transactionVersion
          ? _value.transactionVersion
          : transactionVersion // ignore: cast_nullable_to_non_nullable
              as int?,
      transactionLocktime: freezed == transactionLocktime
          ? _value.transactionLocktime
          : transactionLocktime // ignore: cast_nullable_to_non_nullable
              as int?,
      transactionOutputs: freezed == transactionOutputs
          ? _value.transactionOutputs
          : transactionOutputs // ignore: cast_nullable_to_non_nullable
              as dynamic,
      usedUtxos: freezed == usedUtxos
          ? _value.usedUtxos
          : usedUtxos // ignore: cast_nullable_to_non_nullable
              as dynamic,
      txhash: freezed == txhash
          ? _value.txhash
          : txhash // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as GdkTransactionTypeEnum?,
      userSigned: freezed == userSigned
          ? _value.userSigned
          : userSigned // ignore: cast_nullable_to_non_nullable
              as bool?,
      utxoStrategy: freezed == utxoStrategy
          ? _value.utxoStrategy
          : utxoStrategy // ignore: cast_nullable_to_non_nullable
              as String?,
      memo: freezed == memo
          ? _value.memo
          : memo // ignore: cast_nullable_to_non_nullable
              as String?,
      utxos: freezed == utxos
          ? _value.utxos
          : utxos // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GdkNewTransactionReplyImplCopyWith<$Res>
    implements $GdkNewTransactionReplyCopyWith<$Res> {
  factory _$$GdkNewTransactionReplyImplCopyWith(
          _$GdkNewTransactionReplyImpl value,
          $Res Function(_$GdkNewTransactionReplyImpl) then) =
      __$$GdkNewTransactionReplyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<GdkAddressee>? addressees,
      @JsonKey(name: 'addressees_have_assets') bool? addresseesHaveAssets,
      @JsonKey(name: 'addressees_read_only') bool? addresseesReadOnly,
      @JsonKey(name: 'changes_used') int? changesUsed,
      @JsonKey(name: 'confidential_utxos_only') bool? confidentialUtxosOnly,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      String? error,
      int? fee,
      @JsonKey(name: 'fee_rate') int? feeRate,
      @JsonKey(name: 'is_sweep') bool? isSweep,
      String? network,
      @JsonKey(name: 'num_confs') int? numConfs,
      @JsonKey(name: 'rbf_optin') bool? rbfOptin,
      Map<String, dynamic>? satoshi,
      @JsonKey(name: 'send_all') bool? sendAll,
      @JsonKey(name: 'spv_verified') String? spvVerified,
      int? subaccount,
      int? timestamp,
      String? transaction,
      @JsonKey(name: 'transaction_size') int? transactionSize,
      @JsonKey(name: 'transaction_vsize') int? transactionVsize,
      @JsonKey(name: 'transaction_weight') int? transactionWeight,
      @JsonKey(name: 'transaction_version') int? transactionVersion,
      @JsonKey(name: 'transaction_locktime') int? transactionLocktime,
      @JsonKey(name: 'transaction_outputs') dynamic transactionOutputs,
      @JsonKey(name: 'used_utxos') dynamic usedUtxos,
      String? txhash,
      GdkTransactionTypeEnum? type,
      @JsonKey(name: 'user_signed') bool? userSigned,
      @JsonKey(name: 'utxo_strategy') String? utxoStrategy,
      String? memo,
      Map<String, dynamic>? utxos});
}

/// @nodoc
class __$$GdkNewTransactionReplyImplCopyWithImpl<$Res>
    extends _$GdkNewTransactionReplyCopyWithImpl<$Res,
        _$GdkNewTransactionReplyImpl>
    implements _$$GdkNewTransactionReplyImplCopyWith<$Res> {
  __$$GdkNewTransactionReplyImplCopyWithImpl(
      _$GdkNewTransactionReplyImpl _value,
      $Res Function(_$GdkNewTransactionReplyImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? addressees = freezed,
    Object? addresseesHaveAssets = freezed,
    Object? addresseesReadOnly = freezed,
    Object? changesUsed = freezed,
    Object? confidentialUtxosOnly = freezed,
    Object? createdAt = freezed,
    Object? error = freezed,
    Object? fee = freezed,
    Object? feeRate = freezed,
    Object? isSweep = freezed,
    Object? network = freezed,
    Object? numConfs = freezed,
    Object? rbfOptin = freezed,
    Object? satoshi = freezed,
    Object? sendAll = freezed,
    Object? spvVerified = freezed,
    Object? subaccount = freezed,
    Object? timestamp = freezed,
    Object? transaction = freezed,
    Object? transactionSize = freezed,
    Object? transactionVsize = freezed,
    Object? transactionWeight = freezed,
    Object? transactionVersion = freezed,
    Object? transactionLocktime = freezed,
    Object? transactionOutputs = freezed,
    Object? usedUtxos = freezed,
    Object? txhash = freezed,
    Object? type = freezed,
    Object? userSigned = freezed,
    Object? utxoStrategy = freezed,
    Object? memo = freezed,
    Object? utxos = freezed,
  }) {
    return _then(_$GdkNewTransactionReplyImpl(
      addressees: freezed == addressees
          ? _value._addressees
          : addressees // ignore: cast_nullable_to_non_nullable
              as List<GdkAddressee>?,
      addresseesHaveAssets: freezed == addresseesHaveAssets
          ? _value.addresseesHaveAssets
          : addresseesHaveAssets // ignore: cast_nullable_to_non_nullable
              as bool?,
      addresseesReadOnly: freezed == addresseesReadOnly
          ? _value.addresseesReadOnly
          : addresseesReadOnly // ignore: cast_nullable_to_non_nullable
              as bool?,
      changesUsed: freezed == changesUsed
          ? _value.changesUsed
          : changesUsed // ignore: cast_nullable_to_non_nullable
              as int?,
      confidentialUtxosOnly: freezed == confidentialUtxosOnly
          ? _value.confidentialUtxosOnly
          : confidentialUtxosOnly // ignore: cast_nullable_to_non_nullable
              as bool?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      fee: freezed == fee
          ? _value.fee
          : fee // ignore: cast_nullable_to_non_nullable
              as int?,
      feeRate: freezed == feeRate
          ? _value.feeRate
          : feeRate // ignore: cast_nullable_to_non_nullable
              as int?,
      isSweep: freezed == isSweep
          ? _value.isSweep
          : isSweep // ignore: cast_nullable_to_non_nullable
              as bool?,
      network: freezed == network
          ? _value.network
          : network // ignore: cast_nullable_to_non_nullable
              as String?,
      numConfs: freezed == numConfs
          ? _value.numConfs
          : numConfs // ignore: cast_nullable_to_non_nullable
              as int?,
      rbfOptin: freezed == rbfOptin
          ? _value.rbfOptin
          : rbfOptin // ignore: cast_nullable_to_non_nullable
              as bool?,
      satoshi: freezed == satoshi
          ? _value._satoshi
          : satoshi // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      sendAll: freezed == sendAll
          ? _value.sendAll
          : sendAll // ignore: cast_nullable_to_non_nullable
              as bool?,
      spvVerified: freezed == spvVerified
          ? _value.spvVerified
          : spvVerified // ignore: cast_nullable_to_non_nullable
              as String?,
      subaccount: freezed == subaccount
          ? _value.subaccount
          : subaccount // ignore: cast_nullable_to_non_nullable
              as int?,
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as int?,
      transaction: freezed == transaction
          ? _value.transaction
          : transaction // ignore: cast_nullable_to_non_nullable
              as String?,
      transactionSize: freezed == transactionSize
          ? _value.transactionSize
          : transactionSize // ignore: cast_nullable_to_non_nullable
              as int?,
      transactionVsize: freezed == transactionVsize
          ? _value.transactionVsize
          : transactionVsize // ignore: cast_nullable_to_non_nullable
              as int?,
      transactionWeight: freezed == transactionWeight
          ? _value.transactionWeight
          : transactionWeight // ignore: cast_nullable_to_non_nullable
              as int?,
      transactionVersion: freezed == transactionVersion
          ? _value.transactionVersion
          : transactionVersion // ignore: cast_nullable_to_non_nullable
              as int?,
      transactionLocktime: freezed == transactionLocktime
          ? _value.transactionLocktime
          : transactionLocktime // ignore: cast_nullable_to_non_nullable
              as int?,
      transactionOutputs: freezed == transactionOutputs
          ? _value.transactionOutputs
          : transactionOutputs // ignore: cast_nullable_to_non_nullable
              as dynamic,
      usedUtxos: freezed == usedUtxos
          ? _value.usedUtxos
          : usedUtxos // ignore: cast_nullable_to_non_nullable
              as dynamic,
      txhash: freezed == txhash
          ? _value.txhash
          : txhash // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as GdkTransactionTypeEnum?,
      userSigned: freezed == userSigned
          ? _value.userSigned
          : userSigned // ignore: cast_nullable_to_non_nullable
              as bool?,
      utxoStrategy: freezed == utxoStrategy
          ? _value.utxoStrategy
          : utxoStrategy // ignore: cast_nullable_to_non_nullable
              as String?,
      memo: freezed == memo
          ? _value.memo
          : memo // ignore: cast_nullable_to_non_nullable
              as String?,
      utxos: freezed == utxos
          ? _value._utxos
          : utxos // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkNewTransactionReplyImpl extends _GdkNewTransactionReply {
  const _$GdkNewTransactionReplyImpl(
      {final List<GdkAddressee>? addressees,
      @JsonKey(name: 'addressees_have_assets') this.addresseesHaveAssets,
      @JsonKey(name: 'addressees_read_only') this.addresseesReadOnly,
      @JsonKey(name: 'changes_used') this.changesUsed,
      @JsonKey(name: 'confidential_utxos_only') this.confidentialUtxosOnly,
      @JsonKey(name: 'created_at') this.createdAt,
      this.error,
      this.fee,
      @JsonKey(name: 'fee_rate') this.feeRate,
      @JsonKey(name: 'is_sweep') this.isSweep,
      this.network,
      @JsonKey(name: 'num_confs') this.numConfs,
      @JsonKey(name: 'rbf_optin') this.rbfOptin = true,
      final Map<String, dynamic>? satoshi,
      @JsonKey(name: 'send_all') this.sendAll,
      @JsonKey(name: 'spv_verified') this.spvVerified,
      this.subaccount = 1,
      this.timestamp,
      this.transaction,
      @JsonKey(name: 'transaction_size') this.transactionSize,
      @JsonKey(name: 'transaction_vsize') this.transactionVsize,
      @JsonKey(name: 'transaction_weight') this.transactionWeight,
      @JsonKey(name: 'transaction_version') this.transactionVersion,
      @JsonKey(name: 'transaction_locktime') this.transactionLocktime,
      @JsonKey(name: 'transaction_outputs') this.transactionOutputs,
      @JsonKey(name: 'used_utxos') this.usedUtxos,
      this.txhash,
      this.type,
      @JsonKey(name: 'user_signed') this.userSigned,
      @JsonKey(name: 'utxo_strategy') this.utxoStrategy,
      this.memo,
      final Map<String, dynamic>? utxos})
      : _addressees = addressees,
        _satoshi = satoshi,
        _utxos = utxos,
        super._();

  factory _$GdkNewTransactionReplyImpl.fromJson(Map<String, dynamic> json) =>
      _$$GdkNewTransactionReplyImplFromJson(json);

  final List<GdkAddressee>? _addressees;
  @override
  List<GdkAddressee>? get addressees {
    final value = _addressees;
    if (value == null) return null;
    if (_addressees is EqualUnmodifiableListView) return _addressees;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'addressees_have_assets')
  final bool? addresseesHaveAssets;
  @override
  @JsonKey(name: 'addressees_read_only')
  final bool? addresseesReadOnly;
  @override
  @JsonKey(name: 'changes_used')
  final int? changesUsed;
  @override
  @JsonKey(name: 'confidential_utxos_only')
  final bool? confidentialUtxosOnly;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  final String? error;
  @override
  final int? fee;
  @override
  @JsonKey(name: 'fee_rate')
  final int? feeRate;
  @override
  @JsonKey(name: 'is_sweep')
  final bool? isSweep;
  @override
  final String? network;
  @override
  @JsonKey(name: 'num_confs')
  final int? numConfs;
  @override
  @JsonKey(name: 'rbf_optin')
  final bool? rbfOptin;
  final Map<String, dynamic>? _satoshi;
  @override
  Map<String, dynamic>? get satoshi {
    final value = _satoshi;
    if (value == null) return null;
    if (_satoshi is EqualUnmodifiableMapView) return _satoshi;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey(name: 'send_all')
  final bool? sendAll;
  @override
  @JsonKey(name: 'spv_verified')
  final String? spvVerified;
  @override
  @JsonKey()
  final int? subaccount;
  @override
  final int? timestamp;
  @override
  final String? transaction;
  @override
  @JsonKey(name: 'transaction_size')
  final int? transactionSize;
  @override
  @JsonKey(name: 'transaction_vsize')
  final int? transactionVsize;
  @override
  @JsonKey(name: 'transaction_weight')
  final int? transactionWeight;
  @override
  @JsonKey(name: 'transaction_version')
  final int? transactionVersion;
  @override
  @JsonKey(name: 'transaction_locktime')
  final int? transactionLocktime;
  @override
  @JsonKey(name: 'transaction_outputs')
  final dynamic transactionOutputs;
  @override
  @JsonKey(name: 'used_utxos')
  final dynamic usedUtxos;
  @override
  final String? txhash;
  @override
  final GdkTransactionTypeEnum? type;
  @override
  @JsonKey(name: 'user_signed')
  final bool? userSigned;
  @override
  @JsonKey(name: 'utxo_strategy')
  final String? utxoStrategy;
  @override
  final String? memo;
  final Map<String, dynamic>? _utxos;
  @override
  Map<String, dynamic>? get utxos {
    final value = _utxos;
    if (value == null) return null;
    if (_utxos is EqualUnmodifiableMapView) return _utxos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'GdkNewTransactionReply(addressees: $addressees, addresseesHaveAssets: $addresseesHaveAssets, addresseesReadOnly: $addresseesReadOnly, changesUsed: $changesUsed, confidentialUtxosOnly: $confidentialUtxosOnly, createdAt: $createdAt, error: $error, fee: $fee, feeRate: $feeRate, isSweep: $isSweep, network: $network, numConfs: $numConfs, rbfOptin: $rbfOptin, satoshi: $satoshi, sendAll: $sendAll, spvVerified: $spvVerified, subaccount: $subaccount, timestamp: $timestamp, transaction: $transaction, transactionSize: $transactionSize, transactionVsize: $transactionVsize, transactionWeight: $transactionWeight, transactionVersion: $transactionVersion, transactionLocktime: $transactionLocktime, transactionOutputs: $transactionOutputs, usedUtxos: $usedUtxos, txhash: $txhash, type: $type, userSigned: $userSigned, utxoStrategy: $utxoStrategy, memo: $memo, utxos: $utxos)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkNewTransactionReplyImpl &&
            const DeepCollectionEquality()
                .equals(other._addressees, _addressees) &&
            (identical(other.addresseesHaveAssets, addresseesHaveAssets) ||
                other.addresseesHaveAssets == addresseesHaveAssets) &&
            (identical(other.addresseesReadOnly, addresseesReadOnly) ||
                other.addresseesReadOnly == addresseesReadOnly) &&
            (identical(other.changesUsed, changesUsed) ||
                other.changesUsed == changesUsed) &&
            (identical(other.confidentialUtxosOnly, confidentialUtxosOnly) ||
                other.confidentialUtxosOnly == confidentialUtxosOnly) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.fee, fee) || other.fee == fee) &&
            (identical(other.feeRate, feeRate) || other.feeRate == feeRate) &&
            (identical(other.isSweep, isSweep) || other.isSweep == isSweep) &&
            (identical(other.network, network) || other.network == network) &&
            (identical(other.numConfs, numConfs) ||
                other.numConfs == numConfs) &&
            (identical(other.rbfOptin, rbfOptin) ||
                other.rbfOptin == rbfOptin) &&
            const DeepCollectionEquality().equals(other._satoshi, _satoshi) &&
            (identical(other.sendAll, sendAll) || other.sendAll == sendAll) &&
            (identical(other.spvVerified, spvVerified) ||
                other.spvVerified == spvVerified) &&
            (identical(other.subaccount, subaccount) ||
                other.subaccount == subaccount) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.transaction, transaction) ||
                other.transaction == transaction) &&
            (identical(other.transactionSize, transactionSize) ||
                other.transactionSize == transactionSize) &&
            (identical(other.transactionVsize, transactionVsize) ||
                other.transactionVsize == transactionVsize) &&
            (identical(other.transactionWeight, transactionWeight) ||
                other.transactionWeight == transactionWeight) &&
            (identical(other.transactionVersion, transactionVersion) ||
                other.transactionVersion == transactionVersion) &&
            (identical(other.transactionLocktime, transactionLocktime) ||
                other.transactionLocktime == transactionLocktime) &&
            const DeepCollectionEquality()
                .equals(other.transactionOutputs, transactionOutputs) &&
            const DeepCollectionEquality().equals(other.usedUtxos, usedUtxos) &&
            (identical(other.txhash, txhash) || other.txhash == txhash) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.userSigned, userSigned) ||
                other.userSigned == userSigned) &&
            (identical(other.utxoStrategy, utxoStrategy) ||
                other.utxoStrategy == utxoStrategy) &&
            (identical(other.memo, memo) || other.memo == memo) &&
            const DeepCollectionEquality().equals(other._utxos, _utxos));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        const DeepCollectionEquality().hash(_addressees),
        addresseesHaveAssets,
        addresseesReadOnly,
        changesUsed,
        confidentialUtxosOnly,
        createdAt,
        error,
        fee,
        feeRate,
        isSweep,
        network,
        numConfs,
        rbfOptin,
        const DeepCollectionEquality().hash(_satoshi),
        sendAll,
        spvVerified,
        subaccount,
        timestamp,
        transaction,
        transactionSize,
        transactionVsize,
        transactionWeight,
        transactionVersion,
        transactionLocktime,
        const DeepCollectionEquality().hash(transactionOutputs),
        const DeepCollectionEquality().hash(usedUtxos),
        txhash,
        type,
        userSigned,
        utxoStrategy,
        memo,
        const DeepCollectionEquality().hash(_utxos)
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkNewTransactionReplyImplCopyWith<_$GdkNewTransactionReplyImpl>
      get copyWith => __$$GdkNewTransactionReplyImplCopyWithImpl<
          _$GdkNewTransactionReplyImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkNewTransactionReplyImplToJson(
      this,
    );
  }
}

abstract class _GdkNewTransactionReply extends GdkNewTransactionReply {
  const factory _GdkNewTransactionReply(
      {final List<GdkAddressee>? addressees,
      @JsonKey(name: 'addressees_have_assets') final bool? addresseesHaveAssets,
      @JsonKey(name: 'addressees_read_only') final bool? addresseesReadOnly,
      @JsonKey(name: 'changes_used') final int? changesUsed,
      @JsonKey(name: 'confidential_utxos_only')
      final bool? confidentialUtxosOnly,
      @JsonKey(name: 'created_at') final DateTime? createdAt,
      final String? error,
      final int? fee,
      @JsonKey(name: 'fee_rate') final int? feeRate,
      @JsonKey(name: 'is_sweep') final bool? isSweep,
      final String? network,
      @JsonKey(name: 'num_confs') final int? numConfs,
      @JsonKey(name: 'rbf_optin') final bool? rbfOptin,
      final Map<String, dynamic>? satoshi,
      @JsonKey(name: 'send_all') final bool? sendAll,
      @JsonKey(name: 'spv_verified') final String? spvVerified,
      final int? subaccount,
      final int? timestamp,
      final String? transaction,
      @JsonKey(name: 'transaction_size') final int? transactionSize,
      @JsonKey(name: 'transaction_vsize') final int? transactionVsize,
      @JsonKey(name: 'transaction_weight') final int? transactionWeight,
      @JsonKey(name: 'transaction_version') final int? transactionVersion,
      @JsonKey(name: 'transaction_locktime') final int? transactionLocktime,
      @JsonKey(name: 'transaction_outputs') final dynamic transactionOutputs,
      @JsonKey(name: 'used_utxos') final dynamic usedUtxos,
      final String? txhash,
      final GdkTransactionTypeEnum? type,
      @JsonKey(name: 'user_signed') final bool? userSigned,
      @JsonKey(name: 'utxo_strategy') final String? utxoStrategy,
      final String? memo,
      final Map<String, dynamic>? utxos}) = _$GdkNewTransactionReplyImpl;
  const _GdkNewTransactionReply._() : super._();

  factory _GdkNewTransactionReply.fromJson(Map<String, dynamic> json) =
      _$GdkNewTransactionReplyImpl.fromJson;

  @override
  List<GdkAddressee>? get addressees;
  @override
  @JsonKey(name: 'addressees_have_assets')
  bool? get addresseesHaveAssets;
  @override
  @JsonKey(name: 'addressees_read_only')
  bool? get addresseesReadOnly;
  @override
  @JsonKey(name: 'changes_used')
  int? get changesUsed;
  @override
  @JsonKey(name: 'confidential_utxos_only')
  bool? get confidentialUtxosOnly;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  String? get error;
  @override
  int? get fee;
  @override
  @JsonKey(name: 'fee_rate')
  int? get feeRate;
  @override
  @JsonKey(name: 'is_sweep')
  bool? get isSweep;
  @override
  String? get network;
  @override
  @JsonKey(name: 'num_confs')
  int? get numConfs;
  @override
  @JsonKey(name: 'rbf_optin')
  bool? get rbfOptin;
  @override
  Map<String, dynamic>? get satoshi;
  @override
  @JsonKey(name: 'send_all')
  bool? get sendAll;
  @override
  @JsonKey(name: 'spv_verified')
  String? get spvVerified;
  @override
  int? get subaccount;
  @override
  int? get timestamp;
  @override
  String? get transaction;
  @override
  @JsonKey(name: 'transaction_size')
  int? get transactionSize;
  @override
  @JsonKey(name: 'transaction_vsize')
  int? get transactionVsize;
  @override
  @JsonKey(name: 'transaction_weight')
  int? get transactionWeight;
  @override
  @JsonKey(name: 'transaction_version')
  int? get transactionVersion;
  @override
  @JsonKey(name: 'transaction_locktime')
  int? get transactionLocktime;
  @override
  @JsonKey(name: 'transaction_outputs')
  dynamic get transactionOutputs;
  @override
  @JsonKey(name: 'used_utxos')
  dynamic get usedUtxos;
  @override
  String? get txhash;
  @override
  GdkTransactionTypeEnum? get type;
  @override
  @JsonKey(name: 'user_signed')
  bool? get userSigned;
  @override
  @JsonKey(name: 'utxo_strategy')
  String? get utxoStrategy;
  @override
  String? get memo;
  @override
  Map<String, dynamic>? get utxos;
  @override
  @JsonKey(ignore: true)
  _$$GdkNewTransactionReplyImplCopyWith<_$GdkNewTransactionReplyImpl>
      get copyWith => throw _privateConstructorUsedError;
}

GdkRegisterNetworkData _$GdkRegisterNetworkDataFromJson(
    Map<String, dynamic> json) {
  return _GdkRegisterNetworkData.fromJson(json);
}

/// @nodoc
mixin _$GdkRegisterNetworkData {
  String? get name => throw _privateConstructorUsedError;
  GdkNetwork? get networkDetails => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkRegisterNetworkDataCopyWith<GdkRegisterNetworkData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkRegisterNetworkDataCopyWith<$Res> {
  factory $GdkRegisterNetworkDataCopyWith(GdkRegisterNetworkData value,
          $Res Function(GdkRegisterNetworkData) then) =
      _$GdkRegisterNetworkDataCopyWithImpl<$Res, GdkRegisterNetworkData>;
  @useResult
  $Res call({String? name, GdkNetwork? networkDetails});

  $GdkNetworkCopyWith<$Res>? get networkDetails;
}

/// @nodoc
class _$GdkRegisterNetworkDataCopyWithImpl<$Res,
        $Val extends GdkRegisterNetworkData>
    implements $GdkRegisterNetworkDataCopyWith<$Res> {
  _$GdkRegisterNetworkDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? networkDetails = freezed,
  }) {
    return _then(_value.copyWith(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      networkDetails: freezed == networkDetails
          ? _value.networkDetails
          : networkDetails // ignore: cast_nullable_to_non_nullable
              as GdkNetwork?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $GdkNetworkCopyWith<$Res>? get networkDetails {
    if (_value.networkDetails == null) {
      return null;
    }

    return $GdkNetworkCopyWith<$Res>(_value.networkDetails!, (value) {
      return _then(_value.copyWith(networkDetails: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GdkRegisterNetworkDataImplCopyWith<$Res>
    implements $GdkRegisterNetworkDataCopyWith<$Res> {
  factory _$$GdkRegisterNetworkDataImplCopyWith(
          _$GdkRegisterNetworkDataImpl value,
          $Res Function(_$GdkRegisterNetworkDataImpl) then) =
      __$$GdkRegisterNetworkDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? name, GdkNetwork? networkDetails});

  @override
  $GdkNetworkCopyWith<$Res>? get networkDetails;
}

/// @nodoc
class __$$GdkRegisterNetworkDataImplCopyWithImpl<$Res>
    extends _$GdkRegisterNetworkDataCopyWithImpl<$Res,
        _$GdkRegisterNetworkDataImpl>
    implements _$$GdkRegisterNetworkDataImplCopyWith<$Res> {
  __$$GdkRegisterNetworkDataImplCopyWithImpl(
      _$GdkRegisterNetworkDataImpl _value,
      $Res Function(_$GdkRegisterNetworkDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? networkDetails = freezed,
  }) {
    return _then(_$GdkRegisterNetworkDataImpl(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      networkDetails: freezed == networkDetails
          ? _value.networkDetails
          : networkDetails // ignore: cast_nullable_to_non_nullable
              as GdkNetwork?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkRegisterNetworkDataImpl implements _GdkRegisterNetworkData {
  const _$GdkRegisterNetworkDataImpl({this.name, this.networkDetails});

  factory _$GdkRegisterNetworkDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$GdkRegisterNetworkDataImplFromJson(json);

  @override
  final String? name;
  @override
  final GdkNetwork? networkDetails;

  @override
  String toString() {
    return 'GdkRegisterNetworkData(name: $name, networkDetails: $networkDetails)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkRegisterNetworkDataImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.networkDetails, networkDetails) ||
                other.networkDetails == networkDetails));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, name, networkDetails);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkRegisterNetworkDataImplCopyWith<_$GdkRegisterNetworkDataImpl>
      get copyWith => __$$GdkRegisterNetworkDataImplCopyWithImpl<
          _$GdkRegisterNetworkDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkRegisterNetworkDataImplToJson(
      this,
    );
  }
}

abstract class _GdkRegisterNetworkData implements GdkRegisterNetworkData {
  const factory _GdkRegisterNetworkData(
      {final String? name,
      final GdkNetwork? networkDetails}) = _$GdkRegisterNetworkDataImpl;

  factory _GdkRegisterNetworkData.fromJson(Map<String, dynamic> json) =
      _$GdkRegisterNetworkDataImpl.fromJson;

  @override
  String? get name;
  @override
  GdkNetwork? get networkDetails;
  @override
  @JsonKey(ignore: true)
  _$$GdkRegisterNetworkDataImplCopyWith<_$GdkRegisterNetworkDataImpl>
      get copyWith => throw _privateConstructorUsedError;
}

GdkSessionEvent _$GdkSessionEventFromJson(Map<String, dynamic> json) {
  return _GdkSessionEvent.fromJson(json);
}

/// @nodoc
mixin _$GdkSessionEvent {
  bool? get connected => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkSessionEventCopyWith<GdkSessionEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkSessionEventCopyWith<$Res> {
  factory $GdkSessionEventCopyWith(
          GdkSessionEvent value, $Res Function(GdkSessionEvent) then) =
      _$GdkSessionEventCopyWithImpl<$Res, GdkSessionEvent>;
  @useResult
  $Res call({bool? connected});
}

/// @nodoc
class _$GdkSessionEventCopyWithImpl<$Res, $Val extends GdkSessionEvent>
    implements $GdkSessionEventCopyWith<$Res> {
  _$GdkSessionEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? connected = freezed,
  }) {
    return _then(_value.copyWith(
      connected: freezed == connected
          ? _value.connected
          : connected // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GdkSessionEventImplCopyWith<$Res>
    implements $GdkSessionEventCopyWith<$Res> {
  factory _$$GdkSessionEventImplCopyWith(_$GdkSessionEventImpl value,
          $Res Function(_$GdkSessionEventImpl) then) =
      __$$GdkSessionEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool? connected});
}

/// @nodoc
class __$$GdkSessionEventImplCopyWithImpl<$Res>
    extends _$GdkSessionEventCopyWithImpl<$Res, _$GdkSessionEventImpl>
    implements _$$GdkSessionEventImplCopyWith<$Res> {
  __$$GdkSessionEventImplCopyWithImpl(
      _$GdkSessionEventImpl _value, $Res Function(_$GdkSessionEventImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? connected = freezed,
  }) {
    return _then(_$GdkSessionEventImpl(
      connected: freezed == connected
          ? _value.connected
          : connected // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkSessionEventImpl implements _GdkSessionEvent {
  const _$GdkSessionEventImpl({this.connected});

  factory _$GdkSessionEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$GdkSessionEventImplFromJson(json);

  @override
  final bool? connected;

  @override
  String toString() {
    return 'GdkSessionEvent(connected: $connected)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkSessionEventImpl &&
            (identical(other.connected, connected) ||
                other.connected == connected));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, connected);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkSessionEventImplCopyWith<_$GdkSessionEventImpl> get copyWith =>
      __$$GdkSessionEventImplCopyWithImpl<_$GdkSessionEventImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkSessionEventImplToJson(
      this,
    );
  }
}

abstract class _GdkSessionEvent implements GdkSessionEvent {
  const factory _GdkSessionEvent({final bool? connected}) =
      _$GdkSessionEventImpl;

  factory _GdkSessionEvent.fromJson(Map<String, dynamic> json) =
      _$GdkSessionEventImpl.fromJson;

  @override
  bool? get connected;
  @override
  @JsonKey(ignore: true)
  _$$GdkSessionEventImplCopyWith<_$GdkSessionEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GdkNetworkEvent _$GdkNetworkEventFromJson(Map<String, dynamic> json) {
  return _GdkNetworkEvent.fromJson(json);
}

/// @nodoc
mixin _$GdkNetworkEvent {
  @JsonKey(name: 'wait_ms')
  int? get waitMs => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_state')
  GdkNetworkEventStateEnum? get currentState =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'next_state')
  GdkNetworkEventStateEnum? get nextState => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkNetworkEventCopyWith<GdkNetworkEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkNetworkEventCopyWith<$Res> {
  factory $GdkNetworkEventCopyWith(
          GdkNetworkEvent value, $Res Function(GdkNetworkEvent) then) =
      _$GdkNetworkEventCopyWithImpl<$Res, GdkNetworkEvent>;
  @useResult
  $Res call(
      {@JsonKey(name: 'wait_ms') int? waitMs,
      @JsonKey(name: 'current_state') GdkNetworkEventStateEnum? currentState,
      @JsonKey(name: 'next_state') GdkNetworkEventStateEnum? nextState});
}

/// @nodoc
class _$GdkNetworkEventCopyWithImpl<$Res, $Val extends GdkNetworkEvent>
    implements $GdkNetworkEventCopyWith<$Res> {
  _$GdkNetworkEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? waitMs = freezed,
    Object? currentState = freezed,
    Object? nextState = freezed,
  }) {
    return _then(_value.copyWith(
      waitMs: freezed == waitMs
          ? _value.waitMs
          : waitMs // ignore: cast_nullable_to_non_nullable
              as int?,
      currentState: freezed == currentState
          ? _value.currentState
          : currentState // ignore: cast_nullable_to_non_nullable
              as GdkNetworkEventStateEnum?,
      nextState: freezed == nextState
          ? _value.nextState
          : nextState // ignore: cast_nullable_to_non_nullable
              as GdkNetworkEventStateEnum?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GdkNetworkEventImplCopyWith<$Res>
    implements $GdkNetworkEventCopyWith<$Res> {
  factory _$$GdkNetworkEventImplCopyWith(_$GdkNetworkEventImpl value,
          $Res Function(_$GdkNetworkEventImpl) then) =
      __$$GdkNetworkEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'wait_ms') int? waitMs,
      @JsonKey(name: 'current_state') GdkNetworkEventStateEnum? currentState,
      @JsonKey(name: 'next_state') GdkNetworkEventStateEnum? nextState});
}

/// @nodoc
class __$$GdkNetworkEventImplCopyWithImpl<$Res>
    extends _$GdkNetworkEventCopyWithImpl<$Res, _$GdkNetworkEventImpl>
    implements _$$GdkNetworkEventImplCopyWith<$Res> {
  __$$GdkNetworkEventImplCopyWithImpl(
      _$GdkNetworkEventImpl _value, $Res Function(_$GdkNetworkEventImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? waitMs = freezed,
    Object? currentState = freezed,
    Object? nextState = freezed,
  }) {
    return _then(_$GdkNetworkEventImpl(
      waitMs: freezed == waitMs
          ? _value.waitMs
          : waitMs // ignore: cast_nullable_to_non_nullable
              as int?,
      currentState: freezed == currentState
          ? _value.currentState
          : currentState // ignore: cast_nullable_to_non_nullable
              as GdkNetworkEventStateEnum?,
      nextState: freezed == nextState
          ? _value.nextState
          : nextState // ignore: cast_nullable_to_non_nullable
              as GdkNetworkEventStateEnum?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkNetworkEventImpl implements _GdkNetworkEvent {
  const _$GdkNetworkEventImpl(
      {@JsonKey(name: 'wait_ms') this.waitMs,
      @JsonKey(name: 'current_state') this.currentState,
      @JsonKey(name: 'next_state') this.nextState});

  factory _$GdkNetworkEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$GdkNetworkEventImplFromJson(json);

  @override
  @JsonKey(name: 'wait_ms')
  final int? waitMs;
  @override
  @JsonKey(name: 'current_state')
  final GdkNetworkEventStateEnum? currentState;
  @override
  @JsonKey(name: 'next_state')
  final GdkNetworkEventStateEnum? nextState;

  @override
  String toString() {
    return 'GdkNetworkEvent(waitMs: $waitMs, currentState: $currentState, nextState: $nextState)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkNetworkEventImpl &&
            (identical(other.waitMs, waitMs) || other.waitMs == waitMs) &&
            (identical(other.currentState, currentState) ||
                other.currentState == currentState) &&
            (identical(other.nextState, nextState) ||
                other.nextState == nextState));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, waitMs, currentState, nextState);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkNetworkEventImplCopyWith<_$GdkNetworkEventImpl> get copyWith =>
      __$$GdkNetworkEventImplCopyWithImpl<_$GdkNetworkEventImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkNetworkEventImplToJson(
      this,
    );
  }
}

abstract class _GdkNetworkEvent implements GdkNetworkEvent {
  const factory _GdkNetworkEvent(
      {@JsonKey(name: 'wait_ms') final int? waitMs,
      @JsonKey(name: 'current_state')
      final GdkNetworkEventStateEnum? currentState,
      @JsonKey(name: 'next_state')
      final GdkNetworkEventStateEnum? nextState}) = _$GdkNetworkEventImpl;

  factory _GdkNetworkEvent.fromJson(Map<String, dynamic> json) =
      _$GdkNetworkEventImpl.fromJson;

  @override
  @JsonKey(name: 'wait_ms')
  int? get waitMs;
  @override
  @JsonKey(name: 'current_state')
  GdkNetworkEventStateEnum? get currentState;
  @override
  @JsonKey(name: 'next_state')
  GdkNetworkEventStateEnum? get nextState;
  @override
  @JsonKey(ignore: true)
  _$$GdkNetworkEventImplCopyWith<_$GdkNetworkEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GdkConvertData _$GdkConvertDataFromJson(Map<String, dynamic> json) {
  return _GdkConvertData.fromJson(json);
}

/// @nodoc
mixin _$GdkConvertData {
  int? get satoshi => throw _privateConstructorUsedError;
  String? get bits => throw _privateConstructorUsedError;
  @JsonKey(name: 'fiat_currenct')
  String? get fiatCurrency => throw _privateConstructorUsedError;
  @JsonKey(name: 'fiat_rate')
  String? get fiatRate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkConvertDataCopyWith<GdkConvertData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkConvertDataCopyWith<$Res> {
  factory $GdkConvertDataCopyWith(
          GdkConvertData value, $Res Function(GdkConvertData) then) =
      _$GdkConvertDataCopyWithImpl<$Res, GdkConvertData>;
  @useResult
  $Res call(
      {int? satoshi,
      String? bits,
      @JsonKey(name: 'fiat_currenct') String? fiatCurrency,
      @JsonKey(name: 'fiat_rate') String? fiatRate});
}

/// @nodoc
class _$GdkConvertDataCopyWithImpl<$Res, $Val extends GdkConvertData>
    implements $GdkConvertDataCopyWith<$Res> {
  _$GdkConvertDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? satoshi = freezed,
    Object? bits = freezed,
    Object? fiatCurrency = freezed,
    Object? fiatRate = freezed,
  }) {
    return _then(_value.copyWith(
      satoshi: freezed == satoshi
          ? _value.satoshi
          : satoshi // ignore: cast_nullable_to_non_nullable
              as int?,
      bits: freezed == bits
          ? _value.bits
          : bits // ignore: cast_nullable_to_non_nullable
              as String?,
      fiatCurrency: freezed == fiatCurrency
          ? _value.fiatCurrency
          : fiatCurrency // ignore: cast_nullable_to_non_nullable
              as String?,
      fiatRate: freezed == fiatRate
          ? _value.fiatRate
          : fiatRate // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GdkConvertDataImplCopyWith<$Res>
    implements $GdkConvertDataCopyWith<$Res> {
  factory _$$GdkConvertDataImplCopyWith(_$GdkConvertDataImpl value,
          $Res Function(_$GdkConvertDataImpl) then) =
      __$$GdkConvertDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? satoshi,
      String? bits,
      @JsonKey(name: 'fiat_currenct') String? fiatCurrency,
      @JsonKey(name: 'fiat_rate') String? fiatRate});
}

/// @nodoc
class __$$GdkConvertDataImplCopyWithImpl<$Res>
    extends _$GdkConvertDataCopyWithImpl<$Res, _$GdkConvertDataImpl>
    implements _$$GdkConvertDataImplCopyWith<$Res> {
  __$$GdkConvertDataImplCopyWithImpl(
      _$GdkConvertDataImpl _value, $Res Function(_$GdkConvertDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? satoshi = freezed,
    Object? bits = freezed,
    Object? fiatCurrency = freezed,
    Object? fiatRate = freezed,
  }) {
    return _then(_$GdkConvertDataImpl(
      satoshi: freezed == satoshi
          ? _value.satoshi
          : satoshi // ignore: cast_nullable_to_non_nullable
              as int?,
      bits: freezed == bits
          ? _value.bits
          : bits // ignore: cast_nullable_to_non_nullable
              as String?,
      fiatCurrency: freezed == fiatCurrency
          ? _value.fiatCurrency
          : fiatCurrency // ignore: cast_nullable_to_non_nullable
              as String?,
      fiatRate: freezed == fiatRate
          ? _value.fiatRate
          : fiatRate // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkConvertDataImpl extends _GdkConvertData {
  const _$GdkConvertDataImpl(
      {this.satoshi = 0,
      this.bits,
      @JsonKey(name: 'fiat_currenct') this.fiatCurrency,
      @JsonKey(name: 'fiat_rate') this.fiatRate})
      : super._();

  factory _$GdkConvertDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$GdkConvertDataImplFromJson(json);

  @override
  @JsonKey()
  final int? satoshi;
  @override
  final String? bits;
  @override
  @JsonKey(name: 'fiat_currenct')
  final String? fiatCurrency;
  @override
  @JsonKey(name: 'fiat_rate')
  final String? fiatRate;

  @override
  String toString() {
    return 'GdkConvertData(satoshi: $satoshi, bits: $bits, fiatCurrency: $fiatCurrency, fiatRate: $fiatRate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkConvertDataImpl &&
            (identical(other.satoshi, satoshi) || other.satoshi == satoshi) &&
            (identical(other.bits, bits) || other.bits == bits) &&
            (identical(other.fiatCurrency, fiatCurrency) ||
                other.fiatCurrency == fiatCurrency) &&
            (identical(other.fiatRate, fiatRate) ||
                other.fiatRate == fiatRate));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, satoshi, bits, fiatCurrency, fiatRate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkConvertDataImplCopyWith<_$GdkConvertDataImpl> get copyWith =>
      __$$GdkConvertDataImplCopyWithImpl<_$GdkConvertDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkConvertDataImplToJson(
      this,
    );
  }
}

abstract class _GdkConvertData extends GdkConvertData {
  const factory _GdkConvertData(
          {final int? satoshi,
          final String? bits,
          @JsonKey(name: 'fiat_currenct') final String? fiatCurrency,
          @JsonKey(name: 'fiat_rate') final String? fiatRate}) =
      _$GdkConvertDataImpl;
  const _GdkConvertData._() : super._();

  factory _GdkConvertData.fromJson(Map<String, dynamic> json) =
      _$GdkConvertDataImpl.fromJson;

  @override
  int? get satoshi;
  @override
  String? get bits;
  @override
  @JsonKey(name: 'fiat_currenct')
  String? get fiatCurrency;
  @override
  @JsonKey(name: 'fiat_rate')
  String? get fiatRate;
  @override
  @JsonKey(ignore: true)
  _$$GdkConvertDataImplCopyWith<_$GdkConvertDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GdkAmountData _$GdkAmountDataFromJson(Map<String, dynamic> json) {
  return _GdkAmountData.fromJson(json);
}

/// @nodoc
mixin _$GdkAmountData {
  String? get bits => throw _privateConstructorUsedError;
  String? get btc => throw _privateConstructorUsedError;
  String? get fiat => throw _privateConstructorUsedError;
  @JsonKey(name: 'fiat_currency')
  String? get fiatCurrency => throw _privateConstructorUsedError;
  @JsonKey(name: 'fiat_rate')
  String? get fiatRate => throw _privateConstructorUsedError;
  String? get mbtc => throw _privateConstructorUsedError;
  int? get satoshi => throw _privateConstructorUsedError;
  String? get sats => throw _privateConstructorUsedError;
  int? get subaccount => throw _privateConstructorUsedError;
  String? get ubtc => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_current')
  bool? get isCurrent => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkAmountDataCopyWith<GdkAmountData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkAmountDataCopyWith<$Res> {
  factory $GdkAmountDataCopyWith(
          GdkAmountData value, $Res Function(GdkAmountData) then) =
      _$GdkAmountDataCopyWithImpl<$Res, GdkAmountData>;
  @useResult
  $Res call(
      {String? bits,
      String? btc,
      String? fiat,
      @JsonKey(name: 'fiat_currency') String? fiatCurrency,
      @JsonKey(name: 'fiat_rate') String? fiatRate,
      String? mbtc,
      int? satoshi,
      String? sats,
      int? subaccount,
      String? ubtc,
      @JsonKey(name: 'is_current') bool? isCurrent});
}

/// @nodoc
class _$GdkAmountDataCopyWithImpl<$Res, $Val extends GdkAmountData>
    implements $GdkAmountDataCopyWith<$Res> {
  _$GdkAmountDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bits = freezed,
    Object? btc = freezed,
    Object? fiat = freezed,
    Object? fiatCurrency = freezed,
    Object? fiatRate = freezed,
    Object? mbtc = freezed,
    Object? satoshi = freezed,
    Object? sats = freezed,
    Object? subaccount = freezed,
    Object? ubtc = freezed,
    Object? isCurrent = freezed,
  }) {
    return _then(_value.copyWith(
      bits: freezed == bits
          ? _value.bits
          : bits // ignore: cast_nullable_to_non_nullable
              as String?,
      btc: freezed == btc
          ? _value.btc
          : btc // ignore: cast_nullable_to_non_nullable
              as String?,
      fiat: freezed == fiat
          ? _value.fiat
          : fiat // ignore: cast_nullable_to_non_nullable
              as String?,
      fiatCurrency: freezed == fiatCurrency
          ? _value.fiatCurrency
          : fiatCurrency // ignore: cast_nullable_to_non_nullable
              as String?,
      fiatRate: freezed == fiatRate
          ? _value.fiatRate
          : fiatRate // ignore: cast_nullable_to_non_nullable
              as String?,
      mbtc: freezed == mbtc
          ? _value.mbtc
          : mbtc // ignore: cast_nullable_to_non_nullable
              as String?,
      satoshi: freezed == satoshi
          ? _value.satoshi
          : satoshi // ignore: cast_nullable_to_non_nullable
              as int?,
      sats: freezed == sats
          ? _value.sats
          : sats // ignore: cast_nullable_to_non_nullable
              as String?,
      subaccount: freezed == subaccount
          ? _value.subaccount
          : subaccount // ignore: cast_nullable_to_non_nullable
              as int?,
      ubtc: freezed == ubtc
          ? _value.ubtc
          : ubtc // ignore: cast_nullable_to_non_nullable
              as String?,
      isCurrent: freezed == isCurrent
          ? _value.isCurrent
          : isCurrent // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GdkAmountDataImplCopyWith<$Res>
    implements $GdkAmountDataCopyWith<$Res> {
  factory _$$GdkAmountDataImplCopyWith(
          _$GdkAmountDataImpl value, $Res Function(_$GdkAmountDataImpl) then) =
      __$$GdkAmountDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? bits,
      String? btc,
      String? fiat,
      @JsonKey(name: 'fiat_currency') String? fiatCurrency,
      @JsonKey(name: 'fiat_rate') String? fiatRate,
      String? mbtc,
      int? satoshi,
      String? sats,
      int? subaccount,
      String? ubtc,
      @JsonKey(name: 'is_current') bool? isCurrent});
}

/// @nodoc
class __$$GdkAmountDataImplCopyWithImpl<$Res>
    extends _$GdkAmountDataCopyWithImpl<$Res, _$GdkAmountDataImpl>
    implements _$$GdkAmountDataImplCopyWith<$Res> {
  __$$GdkAmountDataImplCopyWithImpl(
      _$GdkAmountDataImpl _value, $Res Function(_$GdkAmountDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bits = freezed,
    Object? btc = freezed,
    Object? fiat = freezed,
    Object? fiatCurrency = freezed,
    Object? fiatRate = freezed,
    Object? mbtc = freezed,
    Object? satoshi = freezed,
    Object? sats = freezed,
    Object? subaccount = freezed,
    Object? ubtc = freezed,
    Object? isCurrent = freezed,
  }) {
    return _then(_$GdkAmountDataImpl(
      bits: freezed == bits
          ? _value.bits
          : bits // ignore: cast_nullable_to_non_nullable
              as String?,
      btc: freezed == btc
          ? _value.btc
          : btc // ignore: cast_nullable_to_non_nullable
              as String?,
      fiat: freezed == fiat
          ? _value.fiat
          : fiat // ignore: cast_nullable_to_non_nullable
              as String?,
      fiatCurrency: freezed == fiatCurrency
          ? _value.fiatCurrency
          : fiatCurrency // ignore: cast_nullable_to_non_nullable
              as String?,
      fiatRate: freezed == fiatRate
          ? _value.fiatRate
          : fiatRate // ignore: cast_nullable_to_non_nullable
              as String?,
      mbtc: freezed == mbtc
          ? _value.mbtc
          : mbtc // ignore: cast_nullable_to_non_nullable
              as String?,
      satoshi: freezed == satoshi
          ? _value.satoshi
          : satoshi // ignore: cast_nullable_to_non_nullable
              as int?,
      sats: freezed == sats
          ? _value.sats
          : sats // ignore: cast_nullable_to_non_nullable
              as String?,
      subaccount: freezed == subaccount
          ? _value.subaccount
          : subaccount // ignore: cast_nullable_to_non_nullable
              as int?,
      ubtc: freezed == ubtc
          ? _value.ubtc
          : ubtc // ignore: cast_nullable_to_non_nullable
              as String?,
      isCurrent: freezed == isCurrent
          ? _value.isCurrent
          : isCurrent // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkAmountDataImpl implements _GdkAmountData {
  const _$GdkAmountDataImpl(
      {this.bits,
      this.btc,
      this.fiat,
      @JsonKey(name: 'fiat_currency') this.fiatCurrency,
      @JsonKey(name: 'fiat_rate') this.fiatRate,
      this.mbtc,
      this.satoshi,
      this.sats,
      this.subaccount = 1,
      this.ubtc,
      @JsonKey(name: 'is_current') this.isCurrent});

  factory _$GdkAmountDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$GdkAmountDataImplFromJson(json);

  @override
  final String? bits;
  @override
  final String? btc;
  @override
  final String? fiat;
  @override
  @JsonKey(name: 'fiat_currency')
  final String? fiatCurrency;
  @override
  @JsonKey(name: 'fiat_rate')
  final String? fiatRate;
  @override
  final String? mbtc;
  @override
  final int? satoshi;
  @override
  final String? sats;
  @override
  @JsonKey()
  final int? subaccount;
  @override
  final String? ubtc;
  @override
  @JsonKey(name: 'is_current')
  final bool? isCurrent;

  @override
  String toString() {
    return 'GdkAmountData(bits: $bits, btc: $btc, fiat: $fiat, fiatCurrency: $fiatCurrency, fiatRate: $fiatRate, mbtc: $mbtc, satoshi: $satoshi, sats: $sats, subaccount: $subaccount, ubtc: $ubtc, isCurrent: $isCurrent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkAmountDataImpl &&
            (identical(other.bits, bits) || other.bits == bits) &&
            (identical(other.btc, btc) || other.btc == btc) &&
            (identical(other.fiat, fiat) || other.fiat == fiat) &&
            (identical(other.fiatCurrency, fiatCurrency) ||
                other.fiatCurrency == fiatCurrency) &&
            (identical(other.fiatRate, fiatRate) ||
                other.fiatRate == fiatRate) &&
            (identical(other.mbtc, mbtc) || other.mbtc == mbtc) &&
            (identical(other.satoshi, satoshi) || other.satoshi == satoshi) &&
            (identical(other.sats, sats) || other.sats == sats) &&
            (identical(other.subaccount, subaccount) ||
                other.subaccount == subaccount) &&
            (identical(other.ubtc, ubtc) || other.ubtc == ubtc) &&
            (identical(other.isCurrent, isCurrent) ||
                other.isCurrent == isCurrent));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, bits, btc, fiat, fiatCurrency,
      fiatRate, mbtc, satoshi, sats, subaccount, ubtc, isCurrent);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkAmountDataImplCopyWith<_$GdkAmountDataImpl> get copyWith =>
      __$$GdkAmountDataImplCopyWithImpl<_$GdkAmountDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkAmountDataImplToJson(
      this,
    );
  }
}

abstract class _GdkAmountData implements GdkAmountData {
  const factory _GdkAmountData(
          {final String? bits,
          final String? btc,
          final String? fiat,
          @JsonKey(name: 'fiat_currency') final String? fiatCurrency,
          @JsonKey(name: 'fiat_rate') final String? fiatRate,
          final String? mbtc,
          final int? satoshi,
          final String? sats,
          final int? subaccount,
          final String? ubtc,
          @JsonKey(name: 'is_current') final bool? isCurrent}) =
      _$GdkAmountDataImpl;

  factory _GdkAmountData.fromJson(Map<String, dynamic> json) =
      _$GdkAmountDataImpl.fromJson;

  @override
  String? get bits;
  @override
  String? get btc;
  @override
  String? get fiat;
  @override
  @JsonKey(name: 'fiat_currency')
  String? get fiatCurrency;
  @override
  @JsonKey(name: 'fiat_rate')
  String? get fiatRate;
  @override
  String? get mbtc;
  @override
  int? get satoshi;
  @override
  String? get sats;
  @override
  int? get subaccount;
  @override
  String? get ubtc;
  @override
  @JsonKey(name: 'is_current')
  bool? get isCurrent;
  @override
  @JsonKey(ignore: true)
  _$$GdkAmountDataImplCopyWith<_$GdkAmountDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GdkGetUnspentOutputs _$GdkGetUnspentOutputsFromJson(Map<String, dynamic> json) {
  return _GdkGetUnspentOutputs.fromJson(json);
}

/// @nodoc
mixin _$GdkGetUnspentOutputs {
  int? get subaccount => throw _privateConstructorUsedError;
  @JsonKey(name: 'num_confs')
  int? get numConfs => throw _privateConstructorUsedError;
  @JsonKey(name: 'all_coins')
  bool? get allCoins => throw _privateConstructorUsedError;
  @JsonKey(name: 'expired_at')
  int? get expiredAt => throw _privateConstructorUsedError;
  bool? get confidential => throw _privateConstructorUsedError;
  @JsonKey(name: 'dust_limit')
  int? get dustLimit => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkGetUnspentOutputsCopyWith<GdkGetUnspentOutputs> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkGetUnspentOutputsCopyWith<$Res> {
  factory $GdkGetUnspentOutputsCopyWith(GdkGetUnspentOutputs value,
          $Res Function(GdkGetUnspentOutputs) then) =
      _$GdkGetUnspentOutputsCopyWithImpl<$Res, GdkGetUnspentOutputs>;
  @useResult
  $Res call(
      {int? subaccount,
      @JsonKey(name: 'num_confs') int? numConfs,
      @JsonKey(name: 'all_coins') bool? allCoins,
      @JsonKey(name: 'expired_at') int? expiredAt,
      bool? confidential,
      @JsonKey(name: 'dust_limit') int? dustLimit});
}

/// @nodoc
class _$GdkGetUnspentOutputsCopyWithImpl<$Res,
        $Val extends GdkGetUnspentOutputs>
    implements $GdkGetUnspentOutputsCopyWith<$Res> {
  _$GdkGetUnspentOutputsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subaccount = freezed,
    Object? numConfs = freezed,
    Object? allCoins = freezed,
    Object? expiredAt = freezed,
    Object? confidential = freezed,
    Object? dustLimit = freezed,
  }) {
    return _then(_value.copyWith(
      subaccount: freezed == subaccount
          ? _value.subaccount
          : subaccount // ignore: cast_nullable_to_non_nullable
              as int?,
      numConfs: freezed == numConfs
          ? _value.numConfs
          : numConfs // ignore: cast_nullable_to_non_nullable
              as int?,
      allCoins: freezed == allCoins
          ? _value.allCoins
          : allCoins // ignore: cast_nullable_to_non_nullable
              as bool?,
      expiredAt: freezed == expiredAt
          ? _value.expiredAt
          : expiredAt // ignore: cast_nullable_to_non_nullable
              as int?,
      confidential: freezed == confidential
          ? _value.confidential
          : confidential // ignore: cast_nullable_to_non_nullable
              as bool?,
      dustLimit: freezed == dustLimit
          ? _value.dustLimit
          : dustLimit // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GdkGetUnspentOutputsImplCopyWith<$Res>
    implements $GdkGetUnspentOutputsCopyWith<$Res> {
  factory _$$GdkGetUnspentOutputsImplCopyWith(_$GdkGetUnspentOutputsImpl value,
          $Res Function(_$GdkGetUnspentOutputsImpl) then) =
      __$$GdkGetUnspentOutputsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? subaccount,
      @JsonKey(name: 'num_confs') int? numConfs,
      @JsonKey(name: 'all_coins') bool? allCoins,
      @JsonKey(name: 'expired_at') int? expiredAt,
      bool? confidential,
      @JsonKey(name: 'dust_limit') int? dustLimit});
}

/// @nodoc
class __$$GdkGetUnspentOutputsImplCopyWithImpl<$Res>
    extends _$GdkGetUnspentOutputsCopyWithImpl<$Res, _$GdkGetUnspentOutputsImpl>
    implements _$$GdkGetUnspentOutputsImplCopyWith<$Res> {
  __$$GdkGetUnspentOutputsImplCopyWithImpl(_$GdkGetUnspentOutputsImpl _value,
      $Res Function(_$GdkGetUnspentOutputsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subaccount = freezed,
    Object? numConfs = freezed,
    Object? allCoins = freezed,
    Object? expiredAt = freezed,
    Object? confidential = freezed,
    Object? dustLimit = freezed,
  }) {
    return _then(_$GdkGetUnspentOutputsImpl(
      subaccount: freezed == subaccount
          ? _value.subaccount
          : subaccount // ignore: cast_nullable_to_non_nullable
              as int?,
      numConfs: freezed == numConfs
          ? _value.numConfs
          : numConfs // ignore: cast_nullable_to_non_nullable
              as int?,
      allCoins: freezed == allCoins
          ? _value.allCoins
          : allCoins // ignore: cast_nullable_to_non_nullable
              as bool?,
      expiredAt: freezed == expiredAt
          ? _value.expiredAt
          : expiredAt // ignore: cast_nullable_to_non_nullable
              as int?,
      confidential: freezed == confidential
          ? _value.confidential
          : confidential // ignore: cast_nullable_to_non_nullable
              as bool?,
      dustLimit: freezed == dustLimit
          ? _value.dustLimit
          : dustLimit // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkGetUnspentOutputsImpl extends _GdkGetUnspentOutputs {
  const _$GdkGetUnspentOutputsImpl(
      {this.subaccount = 1,
      @JsonKey(name: 'num_confs') this.numConfs = 0,
      @JsonKey(name: 'all_coins') this.allCoins = false,
      @JsonKey(name: 'expired_at') this.expiredAt,
      this.confidential = false,
      @JsonKey(name: 'dust_limit') this.dustLimit})
      : super._();

  factory _$GdkGetUnspentOutputsImpl.fromJson(Map<String, dynamic> json) =>
      _$$GdkGetUnspentOutputsImplFromJson(json);

  @override
  @JsonKey()
  final int? subaccount;
  @override
  @JsonKey(name: 'num_confs')
  final int? numConfs;
  @override
  @JsonKey(name: 'all_coins')
  final bool? allCoins;
  @override
  @JsonKey(name: 'expired_at')
  final int? expiredAt;
  @override
  @JsonKey()
  final bool? confidential;
  @override
  @JsonKey(name: 'dust_limit')
  final int? dustLimit;

  @override
  String toString() {
    return 'GdkGetUnspentOutputs(subaccount: $subaccount, numConfs: $numConfs, allCoins: $allCoins, expiredAt: $expiredAt, confidential: $confidential, dustLimit: $dustLimit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkGetUnspentOutputsImpl &&
            (identical(other.subaccount, subaccount) ||
                other.subaccount == subaccount) &&
            (identical(other.numConfs, numConfs) ||
                other.numConfs == numConfs) &&
            (identical(other.allCoins, allCoins) ||
                other.allCoins == allCoins) &&
            (identical(other.expiredAt, expiredAt) ||
                other.expiredAt == expiredAt) &&
            (identical(other.confidential, confidential) ||
                other.confidential == confidential) &&
            (identical(other.dustLimit, dustLimit) ||
                other.dustLimit == dustLimit));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, subaccount, numConfs, allCoins,
      expiredAt, confidential, dustLimit);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkGetUnspentOutputsImplCopyWith<_$GdkGetUnspentOutputsImpl>
      get copyWith =>
          __$$GdkGetUnspentOutputsImplCopyWithImpl<_$GdkGetUnspentOutputsImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkGetUnspentOutputsImplToJson(
      this,
    );
  }
}

abstract class _GdkGetUnspentOutputs extends GdkGetUnspentOutputs {
  const factory _GdkGetUnspentOutputs(
          {final int? subaccount,
          @JsonKey(name: 'num_confs') final int? numConfs,
          @JsonKey(name: 'all_coins') final bool? allCoins,
          @JsonKey(name: 'expired_at') final int? expiredAt,
          final bool? confidential,
          @JsonKey(name: 'dust_limit') final int? dustLimit}) =
      _$GdkGetUnspentOutputsImpl;
  const _GdkGetUnspentOutputs._() : super._();

  factory _GdkGetUnspentOutputs.fromJson(Map<String, dynamic> json) =
      _$GdkGetUnspentOutputsImpl.fromJson;

  @override
  int? get subaccount;
  @override
  @JsonKey(name: 'num_confs')
  int? get numConfs;
  @override
  @JsonKey(name: 'all_coins')
  bool? get allCoins;
  @override
  @JsonKey(name: 'expired_at')
  int? get expiredAt;
  @override
  bool? get confidential;
  @override
  @JsonKey(name: 'dust_limit')
  int? get dustLimit;
  @override
  @JsonKey(ignore: true)
  _$$GdkGetUnspentOutputsImplCopyWith<_$GdkGetUnspentOutputsImpl>
      get copyWith => throw _privateConstructorUsedError;
}

GdkUnspentOutputsReply _$GdkUnspentOutputsReplyFromJson(
    Map<String, dynamic> json) {
  return _GdkUnspentOutputsReply.fromJson(json);
}

/// @nodoc
mixin _$GdkUnspentOutputsReply {
  @JsonKey(name: 'unspent_outputs')
  Map<String, List<GdkUnspentOutputs>>? get unsentOutputs =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkUnspentOutputsReplyCopyWith<GdkUnspentOutputsReply> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkUnspentOutputsReplyCopyWith<$Res> {
  factory $GdkUnspentOutputsReplyCopyWith(GdkUnspentOutputsReply value,
          $Res Function(GdkUnspentOutputsReply) then) =
      _$GdkUnspentOutputsReplyCopyWithImpl<$Res, GdkUnspentOutputsReply>;
  @useResult
  $Res call(
      {@JsonKey(name: 'unspent_outputs')
      Map<String, List<GdkUnspentOutputs>>? unsentOutputs});
}

/// @nodoc
class _$GdkUnspentOutputsReplyCopyWithImpl<$Res,
        $Val extends GdkUnspentOutputsReply>
    implements $GdkUnspentOutputsReplyCopyWith<$Res> {
  _$GdkUnspentOutputsReplyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? unsentOutputs = freezed,
  }) {
    return _then(_value.copyWith(
      unsentOutputs: freezed == unsentOutputs
          ? _value.unsentOutputs
          : unsentOutputs // ignore: cast_nullable_to_non_nullable
              as Map<String, List<GdkUnspentOutputs>>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GdkUnspentOutputsReplyImplCopyWith<$Res>
    implements $GdkUnspentOutputsReplyCopyWith<$Res> {
  factory _$$GdkUnspentOutputsReplyImplCopyWith(
          _$GdkUnspentOutputsReplyImpl value,
          $Res Function(_$GdkUnspentOutputsReplyImpl) then) =
      __$$GdkUnspentOutputsReplyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'unspent_outputs')
      Map<String, List<GdkUnspentOutputs>>? unsentOutputs});
}

/// @nodoc
class __$$GdkUnspentOutputsReplyImplCopyWithImpl<$Res>
    extends _$GdkUnspentOutputsReplyCopyWithImpl<$Res,
        _$GdkUnspentOutputsReplyImpl>
    implements _$$GdkUnspentOutputsReplyImplCopyWith<$Res> {
  __$$GdkUnspentOutputsReplyImplCopyWithImpl(
      _$GdkUnspentOutputsReplyImpl _value,
      $Res Function(_$GdkUnspentOutputsReplyImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? unsentOutputs = freezed,
  }) {
    return _then(_$GdkUnspentOutputsReplyImpl(
      unsentOutputs: freezed == unsentOutputs
          ? _value._unsentOutputs
          : unsentOutputs // ignore: cast_nullable_to_non_nullable
              as Map<String, List<GdkUnspentOutputs>>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkUnspentOutputsReplyImpl implements _GdkUnspentOutputsReply {
  const _$GdkUnspentOutputsReplyImpl(
      {@JsonKey(name: 'unspent_outputs')
      final Map<String, List<GdkUnspentOutputs>>? unsentOutputs})
      : _unsentOutputs = unsentOutputs;

  factory _$GdkUnspentOutputsReplyImpl.fromJson(Map<String, dynamic> json) =>
      _$$GdkUnspentOutputsReplyImplFromJson(json);

  final Map<String, List<GdkUnspentOutputs>>? _unsentOutputs;
  @override
  @JsonKey(name: 'unspent_outputs')
  Map<String, List<GdkUnspentOutputs>>? get unsentOutputs {
    final value = _unsentOutputs;
    if (value == null) return null;
    if (_unsentOutputs is EqualUnmodifiableMapView) return _unsentOutputs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'GdkUnspentOutputsReply(unsentOutputs: $unsentOutputs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkUnspentOutputsReplyImpl &&
            const DeepCollectionEquality()
                .equals(other._unsentOutputs, _unsentOutputs));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_unsentOutputs));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkUnspentOutputsReplyImplCopyWith<_$GdkUnspentOutputsReplyImpl>
      get copyWith => __$$GdkUnspentOutputsReplyImplCopyWithImpl<
          _$GdkUnspentOutputsReplyImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkUnspentOutputsReplyImplToJson(
      this,
    );
  }
}

abstract class _GdkUnspentOutputsReply implements GdkUnspentOutputsReply {
  const factory _GdkUnspentOutputsReply(
          {@JsonKey(name: 'unspent_outputs')
          final Map<String, List<GdkUnspentOutputs>>? unsentOutputs}) =
      _$GdkUnspentOutputsReplyImpl;

  factory _GdkUnspentOutputsReply.fromJson(Map<String, dynamic> json) =
      _$GdkUnspentOutputsReplyImpl.fromJson;

  @override
  @JsonKey(name: 'unspent_outputs')
  Map<String, List<GdkUnspentOutputs>>? get unsentOutputs;
  @override
  @JsonKey(ignore: true)
  _$$GdkUnspentOutputsReplyImplCopyWith<_$GdkUnspentOutputsReplyImpl>
      get copyWith => throw _privateConstructorUsedError;
}

GdkUnspentOutputs _$GdkUnspentOutputsFromJson(Map<String, dynamic> json) {
  return _GdkUnspentOutputs.fromJson(json);
}

/// @nodoc
mixin _$GdkUnspentOutputs {
  @JsonKey(name: 'address_type')
  String? get addressType => throw _privateConstructorUsedError;
  @JsonKey(name: 'block_height')
  int? get blockHeight => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_internal')
  bool? get isInternal => throw _privateConstructorUsedError;
  int? get pointer => throw _privateConstructorUsedError;
  @JsonKey(name: 'pt_idx')
  int? get ptIdx => throw _privateConstructorUsedError;
  int? get satoshi => throw _privateConstructorUsedError;
  int? get subaccount => throw _privateConstructorUsedError;
  String? get txhash => throw _privateConstructorUsedError;
  @JsonKey(name: 'prevout_script')
  String? get prevoutScript => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_path')
  List<int>? get userPath => throw _privateConstructorUsedError;
  @JsonKey(name: 'public_key')
  String? get publicKey => throw _privateConstructorUsedError;
  @JsonKey(name: 'expiry_height')
  int? get expiryHeight => throw _privateConstructorUsedError;
  @JsonKey(name: 'script_type')
  int? get scriptType => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_status')
  int? get userStatus => throw _privateConstructorUsedError;
  int? get subtype => throw _privateConstructorUsedError; // Liquid specific
  bool? get confidential => throw _privateConstructorUsedError;
  @JsonKey(name: 'asset_id')
  String? get assetId => throw _privateConstructorUsedError;
  @JsonKey(name: 'assetblinder')
  String? get assetBlinder => throw _privateConstructorUsedError;
  @JsonKey(name: 'amountblinder')
  String? get amountBlinder => throw _privateConstructorUsedError;
  @JsonKey(name: 'asset_tag')
  String? get assetTag => throw _privateConstructorUsedError;
  String? get commitment => throw _privateConstructorUsedError;
  @JsonKey(name: 'nonce_commitment')
  String? get nonceCommitment => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkUnspentOutputsCopyWith<GdkUnspentOutputs> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkUnspentOutputsCopyWith<$Res> {
  factory $GdkUnspentOutputsCopyWith(
          GdkUnspentOutputs value, $Res Function(GdkUnspentOutputs) then) =
      _$GdkUnspentOutputsCopyWithImpl<$Res, GdkUnspentOutputs>;
  @useResult
  $Res call(
      {@JsonKey(name: 'address_type') String? addressType,
      @JsonKey(name: 'block_height') int? blockHeight,
      @JsonKey(name: 'is_internal') bool? isInternal,
      int? pointer,
      @JsonKey(name: 'pt_idx') int? ptIdx,
      int? satoshi,
      int? subaccount,
      String? txhash,
      @JsonKey(name: 'prevout_script') String? prevoutScript,
      @JsonKey(name: 'user_path') List<int>? userPath,
      @JsonKey(name: 'public_key') String? publicKey,
      @JsonKey(name: 'expiry_height') int? expiryHeight,
      @JsonKey(name: 'script_type') int? scriptType,
      @JsonKey(name: 'user_status') int? userStatus,
      int? subtype,
      bool? confidential,
      @JsonKey(name: 'asset_id') String? assetId,
      @JsonKey(name: 'assetblinder') String? assetBlinder,
      @JsonKey(name: 'amountblinder') String? amountBlinder,
      @JsonKey(name: 'asset_tag') String? assetTag,
      String? commitment,
      @JsonKey(name: 'nonce_commitment') String? nonceCommitment});
}

/// @nodoc
class _$GdkUnspentOutputsCopyWithImpl<$Res, $Val extends GdkUnspentOutputs>
    implements $GdkUnspentOutputsCopyWith<$Res> {
  _$GdkUnspentOutputsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? addressType = freezed,
    Object? blockHeight = freezed,
    Object? isInternal = freezed,
    Object? pointer = freezed,
    Object? ptIdx = freezed,
    Object? satoshi = freezed,
    Object? subaccount = freezed,
    Object? txhash = freezed,
    Object? prevoutScript = freezed,
    Object? userPath = freezed,
    Object? publicKey = freezed,
    Object? expiryHeight = freezed,
    Object? scriptType = freezed,
    Object? userStatus = freezed,
    Object? subtype = freezed,
    Object? confidential = freezed,
    Object? assetId = freezed,
    Object? assetBlinder = freezed,
    Object? amountBlinder = freezed,
    Object? assetTag = freezed,
    Object? commitment = freezed,
    Object? nonceCommitment = freezed,
  }) {
    return _then(_value.copyWith(
      addressType: freezed == addressType
          ? _value.addressType
          : addressType // ignore: cast_nullable_to_non_nullable
              as String?,
      blockHeight: freezed == blockHeight
          ? _value.blockHeight
          : blockHeight // ignore: cast_nullable_to_non_nullable
              as int?,
      isInternal: freezed == isInternal
          ? _value.isInternal
          : isInternal // ignore: cast_nullable_to_non_nullable
              as bool?,
      pointer: freezed == pointer
          ? _value.pointer
          : pointer // ignore: cast_nullable_to_non_nullable
              as int?,
      ptIdx: freezed == ptIdx
          ? _value.ptIdx
          : ptIdx // ignore: cast_nullable_to_non_nullable
              as int?,
      satoshi: freezed == satoshi
          ? _value.satoshi
          : satoshi // ignore: cast_nullable_to_non_nullable
              as int?,
      subaccount: freezed == subaccount
          ? _value.subaccount
          : subaccount // ignore: cast_nullable_to_non_nullable
              as int?,
      txhash: freezed == txhash
          ? _value.txhash
          : txhash // ignore: cast_nullable_to_non_nullable
              as String?,
      prevoutScript: freezed == prevoutScript
          ? _value.prevoutScript
          : prevoutScript // ignore: cast_nullable_to_non_nullable
              as String?,
      userPath: freezed == userPath
          ? _value.userPath
          : userPath // ignore: cast_nullable_to_non_nullable
              as List<int>?,
      publicKey: freezed == publicKey
          ? _value.publicKey
          : publicKey // ignore: cast_nullable_to_non_nullable
              as String?,
      expiryHeight: freezed == expiryHeight
          ? _value.expiryHeight
          : expiryHeight // ignore: cast_nullable_to_non_nullable
              as int?,
      scriptType: freezed == scriptType
          ? _value.scriptType
          : scriptType // ignore: cast_nullable_to_non_nullable
              as int?,
      userStatus: freezed == userStatus
          ? _value.userStatus
          : userStatus // ignore: cast_nullable_to_non_nullable
              as int?,
      subtype: freezed == subtype
          ? _value.subtype
          : subtype // ignore: cast_nullable_to_non_nullable
              as int?,
      confidential: freezed == confidential
          ? _value.confidential
          : confidential // ignore: cast_nullable_to_non_nullable
              as bool?,
      assetId: freezed == assetId
          ? _value.assetId
          : assetId // ignore: cast_nullable_to_non_nullable
              as String?,
      assetBlinder: freezed == assetBlinder
          ? _value.assetBlinder
          : assetBlinder // ignore: cast_nullable_to_non_nullable
              as String?,
      amountBlinder: freezed == amountBlinder
          ? _value.amountBlinder
          : amountBlinder // ignore: cast_nullable_to_non_nullable
              as String?,
      assetTag: freezed == assetTag
          ? _value.assetTag
          : assetTag // ignore: cast_nullable_to_non_nullable
              as String?,
      commitment: freezed == commitment
          ? _value.commitment
          : commitment // ignore: cast_nullable_to_non_nullable
              as String?,
      nonceCommitment: freezed == nonceCommitment
          ? _value.nonceCommitment
          : nonceCommitment // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GdkUnspentOutputsImplCopyWith<$Res>
    implements $GdkUnspentOutputsCopyWith<$Res> {
  factory _$$GdkUnspentOutputsImplCopyWith(_$GdkUnspentOutputsImpl value,
          $Res Function(_$GdkUnspentOutputsImpl) then) =
      __$$GdkUnspentOutputsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'address_type') String? addressType,
      @JsonKey(name: 'block_height') int? blockHeight,
      @JsonKey(name: 'is_internal') bool? isInternal,
      int? pointer,
      @JsonKey(name: 'pt_idx') int? ptIdx,
      int? satoshi,
      int? subaccount,
      String? txhash,
      @JsonKey(name: 'prevout_script') String? prevoutScript,
      @JsonKey(name: 'user_path') List<int>? userPath,
      @JsonKey(name: 'public_key') String? publicKey,
      @JsonKey(name: 'expiry_height') int? expiryHeight,
      @JsonKey(name: 'script_type') int? scriptType,
      @JsonKey(name: 'user_status') int? userStatus,
      int? subtype,
      bool? confidential,
      @JsonKey(name: 'asset_id') String? assetId,
      @JsonKey(name: 'assetblinder') String? assetBlinder,
      @JsonKey(name: 'amountblinder') String? amountBlinder,
      @JsonKey(name: 'asset_tag') String? assetTag,
      String? commitment,
      @JsonKey(name: 'nonce_commitment') String? nonceCommitment});
}

/// @nodoc
class __$$GdkUnspentOutputsImplCopyWithImpl<$Res>
    extends _$GdkUnspentOutputsCopyWithImpl<$Res, _$GdkUnspentOutputsImpl>
    implements _$$GdkUnspentOutputsImplCopyWith<$Res> {
  __$$GdkUnspentOutputsImplCopyWithImpl(_$GdkUnspentOutputsImpl _value,
      $Res Function(_$GdkUnspentOutputsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? addressType = freezed,
    Object? blockHeight = freezed,
    Object? isInternal = freezed,
    Object? pointer = freezed,
    Object? ptIdx = freezed,
    Object? satoshi = freezed,
    Object? subaccount = freezed,
    Object? txhash = freezed,
    Object? prevoutScript = freezed,
    Object? userPath = freezed,
    Object? publicKey = freezed,
    Object? expiryHeight = freezed,
    Object? scriptType = freezed,
    Object? userStatus = freezed,
    Object? subtype = freezed,
    Object? confidential = freezed,
    Object? assetId = freezed,
    Object? assetBlinder = freezed,
    Object? amountBlinder = freezed,
    Object? assetTag = freezed,
    Object? commitment = freezed,
    Object? nonceCommitment = freezed,
  }) {
    return _then(_$GdkUnspentOutputsImpl(
      addressType: freezed == addressType
          ? _value.addressType
          : addressType // ignore: cast_nullable_to_non_nullable
              as String?,
      blockHeight: freezed == blockHeight
          ? _value.blockHeight
          : blockHeight // ignore: cast_nullable_to_non_nullable
              as int?,
      isInternal: freezed == isInternal
          ? _value.isInternal
          : isInternal // ignore: cast_nullable_to_non_nullable
              as bool?,
      pointer: freezed == pointer
          ? _value.pointer
          : pointer // ignore: cast_nullable_to_non_nullable
              as int?,
      ptIdx: freezed == ptIdx
          ? _value.ptIdx
          : ptIdx // ignore: cast_nullable_to_non_nullable
              as int?,
      satoshi: freezed == satoshi
          ? _value.satoshi
          : satoshi // ignore: cast_nullable_to_non_nullable
              as int?,
      subaccount: freezed == subaccount
          ? _value.subaccount
          : subaccount // ignore: cast_nullable_to_non_nullable
              as int?,
      txhash: freezed == txhash
          ? _value.txhash
          : txhash // ignore: cast_nullable_to_non_nullable
              as String?,
      prevoutScript: freezed == prevoutScript
          ? _value.prevoutScript
          : prevoutScript // ignore: cast_nullable_to_non_nullable
              as String?,
      userPath: freezed == userPath
          ? _value._userPath
          : userPath // ignore: cast_nullable_to_non_nullable
              as List<int>?,
      publicKey: freezed == publicKey
          ? _value.publicKey
          : publicKey // ignore: cast_nullable_to_non_nullable
              as String?,
      expiryHeight: freezed == expiryHeight
          ? _value.expiryHeight
          : expiryHeight // ignore: cast_nullable_to_non_nullable
              as int?,
      scriptType: freezed == scriptType
          ? _value.scriptType
          : scriptType // ignore: cast_nullable_to_non_nullable
              as int?,
      userStatus: freezed == userStatus
          ? _value.userStatus
          : userStatus // ignore: cast_nullable_to_non_nullable
              as int?,
      subtype: freezed == subtype
          ? _value.subtype
          : subtype // ignore: cast_nullable_to_non_nullable
              as int?,
      confidential: freezed == confidential
          ? _value.confidential
          : confidential // ignore: cast_nullable_to_non_nullable
              as bool?,
      assetId: freezed == assetId
          ? _value.assetId
          : assetId // ignore: cast_nullable_to_non_nullable
              as String?,
      assetBlinder: freezed == assetBlinder
          ? _value.assetBlinder
          : assetBlinder // ignore: cast_nullable_to_non_nullable
              as String?,
      amountBlinder: freezed == amountBlinder
          ? _value.amountBlinder
          : amountBlinder // ignore: cast_nullable_to_non_nullable
              as String?,
      assetTag: freezed == assetTag
          ? _value.assetTag
          : assetTag // ignore: cast_nullable_to_non_nullable
              as String?,
      commitment: freezed == commitment
          ? _value.commitment
          : commitment // ignore: cast_nullable_to_non_nullable
              as String?,
      nonceCommitment: freezed == nonceCommitment
          ? _value.nonceCommitment
          : nonceCommitment // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkUnspentOutputsImpl implements _GdkUnspentOutputs {
  const _$GdkUnspentOutputsImpl(
      {@JsonKey(name: 'address_type') this.addressType,
      @JsonKey(name: 'block_height') this.blockHeight,
      @JsonKey(name: 'is_internal') this.isInternal,
      this.pointer,
      @JsonKey(name: 'pt_idx') this.ptIdx,
      this.satoshi,
      this.subaccount = 1,
      this.txhash,
      @JsonKey(name: 'prevout_script') this.prevoutScript,
      @JsonKey(name: 'user_path') final List<int>? userPath,
      @JsonKey(name: 'public_key') this.publicKey,
      @JsonKey(name: 'expiry_height') this.expiryHeight,
      @JsonKey(name: 'script_type') this.scriptType,
      @JsonKey(name: 'user_status') this.userStatus,
      this.subtype,
      this.confidential,
      @JsonKey(name: 'asset_id') this.assetId,
      @JsonKey(name: 'assetblinder') this.assetBlinder,
      @JsonKey(name: 'amountblinder') this.amountBlinder,
      @JsonKey(name: 'asset_tag') this.assetTag,
      this.commitment,
      @JsonKey(name: 'nonce_commitment') this.nonceCommitment})
      : _userPath = userPath;

  factory _$GdkUnspentOutputsImpl.fromJson(Map<String, dynamic> json) =>
      _$$GdkUnspentOutputsImplFromJson(json);

  @override
  @JsonKey(name: 'address_type')
  final String? addressType;
  @override
  @JsonKey(name: 'block_height')
  final int? blockHeight;
  @override
  @JsonKey(name: 'is_internal')
  final bool? isInternal;
  @override
  final int? pointer;
  @override
  @JsonKey(name: 'pt_idx')
  final int? ptIdx;
  @override
  final int? satoshi;
  @override
  @JsonKey()
  final int? subaccount;
  @override
  final String? txhash;
  @override
  @JsonKey(name: 'prevout_script')
  final String? prevoutScript;
  final List<int>? _userPath;
  @override
  @JsonKey(name: 'user_path')
  List<int>? get userPath {
    final value = _userPath;
    if (value == null) return null;
    if (_userPath is EqualUnmodifiableListView) return _userPath;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'public_key')
  final String? publicKey;
  @override
  @JsonKey(name: 'expiry_height')
  final int? expiryHeight;
  @override
  @JsonKey(name: 'script_type')
  final int? scriptType;
  @override
  @JsonKey(name: 'user_status')
  final int? userStatus;
  @override
  final int? subtype;
// Liquid specific
  @override
  final bool? confidential;
  @override
  @JsonKey(name: 'asset_id')
  final String? assetId;
  @override
  @JsonKey(name: 'assetblinder')
  final String? assetBlinder;
  @override
  @JsonKey(name: 'amountblinder')
  final String? amountBlinder;
  @override
  @JsonKey(name: 'asset_tag')
  final String? assetTag;
  @override
  final String? commitment;
  @override
  @JsonKey(name: 'nonce_commitment')
  final String? nonceCommitment;

  @override
  String toString() {
    return 'GdkUnspentOutputs(addressType: $addressType, blockHeight: $blockHeight, isInternal: $isInternal, pointer: $pointer, ptIdx: $ptIdx, satoshi: $satoshi, subaccount: $subaccount, txhash: $txhash, prevoutScript: $prevoutScript, userPath: $userPath, publicKey: $publicKey, expiryHeight: $expiryHeight, scriptType: $scriptType, userStatus: $userStatus, subtype: $subtype, confidential: $confidential, assetId: $assetId, assetBlinder: $assetBlinder, amountBlinder: $amountBlinder, assetTag: $assetTag, commitment: $commitment, nonceCommitment: $nonceCommitment)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkUnspentOutputsImpl &&
            (identical(other.addressType, addressType) ||
                other.addressType == addressType) &&
            (identical(other.blockHeight, blockHeight) ||
                other.blockHeight == blockHeight) &&
            (identical(other.isInternal, isInternal) ||
                other.isInternal == isInternal) &&
            (identical(other.pointer, pointer) || other.pointer == pointer) &&
            (identical(other.ptIdx, ptIdx) || other.ptIdx == ptIdx) &&
            (identical(other.satoshi, satoshi) || other.satoshi == satoshi) &&
            (identical(other.subaccount, subaccount) ||
                other.subaccount == subaccount) &&
            (identical(other.txhash, txhash) || other.txhash == txhash) &&
            (identical(other.prevoutScript, prevoutScript) ||
                other.prevoutScript == prevoutScript) &&
            const DeepCollectionEquality().equals(other._userPath, _userPath) &&
            (identical(other.publicKey, publicKey) ||
                other.publicKey == publicKey) &&
            (identical(other.expiryHeight, expiryHeight) ||
                other.expiryHeight == expiryHeight) &&
            (identical(other.scriptType, scriptType) ||
                other.scriptType == scriptType) &&
            (identical(other.userStatus, userStatus) ||
                other.userStatus == userStatus) &&
            (identical(other.subtype, subtype) || other.subtype == subtype) &&
            (identical(other.confidential, confidential) ||
                other.confidential == confidential) &&
            (identical(other.assetId, assetId) || other.assetId == assetId) &&
            (identical(other.assetBlinder, assetBlinder) ||
                other.assetBlinder == assetBlinder) &&
            (identical(other.amountBlinder, amountBlinder) ||
                other.amountBlinder == amountBlinder) &&
            (identical(other.assetTag, assetTag) ||
                other.assetTag == assetTag) &&
            (identical(other.commitment, commitment) ||
                other.commitment == commitment) &&
            (identical(other.nonceCommitment, nonceCommitment) ||
                other.nonceCommitment == nonceCommitment));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        addressType,
        blockHeight,
        isInternal,
        pointer,
        ptIdx,
        satoshi,
        subaccount,
        txhash,
        prevoutScript,
        const DeepCollectionEquality().hash(_userPath),
        publicKey,
        expiryHeight,
        scriptType,
        userStatus,
        subtype,
        confidential,
        assetId,
        assetBlinder,
        amountBlinder,
        assetTag,
        commitment,
        nonceCommitment
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkUnspentOutputsImplCopyWith<_$GdkUnspentOutputsImpl> get copyWith =>
      __$$GdkUnspentOutputsImplCopyWithImpl<_$GdkUnspentOutputsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkUnspentOutputsImplToJson(
      this,
    );
  }
}

abstract class _GdkUnspentOutputs implements GdkUnspentOutputs {
  const factory _GdkUnspentOutputs(
          {@JsonKey(name: 'address_type') final String? addressType,
          @JsonKey(name: 'block_height') final int? blockHeight,
          @JsonKey(name: 'is_internal') final bool? isInternal,
          final int? pointer,
          @JsonKey(name: 'pt_idx') final int? ptIdx,
          final int? satoshi,
          final int? subaccount,
          final String? txhash,
          @JsonKey(name: 'prevout_script') final String? prevoutScript,
          @JsonKey(name: 'user_path') final List<int>? userPath,
          @JsonKey(name: 'public_key') final String? publicKey,
          @JsonKey(name: 'expiry_height') final int? expiryHeight,
          @JsonKey(name: 'script_type') final int? scriptType,
          @JsonKey(name: 'user_status') final int? userStatus,
          final int? subtype,
          final bool? confidential,
          @JsonKey(name: 'asset_id') final String? assetId,
          @JsonKey(name: 'assetblinder') final String? assetBlinder,
          @JsonKey(name: 'amountblinder') final String? amountBlinder,
          @JsonKey(name: 'asset_tag') final String? assetTag,
          final String? commitment,
          @JsonKey(name: 'nonce_commitment') final String? nonceCommitment}) =
      _$GdkUnspentOutputsImpl;

  factory _GdkUnspentOutputs.fromJson(Map<String, dynamic> json) =
      _$GdkUnspentOutputsImpl.fromJson;

  @override
  @JsonKey(name: 'address_type')
  String? get addressType;
  @override
  @JsonKey(name: 'block_height')
  int? get blockHeight;
  @override
  @JsonKey(name: 'is_internal')
  bool? get isInternal;
  @override
  int? get pointer;
  @override
  @JsonKey(name: 'pt_idx')
  int? get ptIdx;
  @override
  int? get satoshi;
  @override
  int? get subaccount;
  @override
  String? get txhash;
  @override
  @JsonKey(name: 'prevout_script')
  String? get prevoutScript;
  @override
  @JsonKey(name: 'user_path')
  List<int>? get userPath;
  @override
  @JsonKey(name: 'public_key')
  String? get publicKey;
  @override
  @JsonKey(name: 'expiry_height')
  int? get expiryHeight;
  @override
  @JsonKey(name: 'script_type')
  int? get scriptType;
  @override
  @JsonKey(name: 'user_status')
  int? get userStatus;
  @override
  int? get subtype;
  @override // Liquid specific
  bool? get confidential;
  @override
  @JsonKey(name: 'asset_id')
  String? get assetId;
  @override
  @JsonKey(name: 'assetblinder')
  String? get assetBlinder;
  @override
  @JsonKey(name: 'amountblinder')
  String? get amountBlinder;
  @override
  @JsonKey(name: 'asset_tag')
  String? get assetTag;
  @override
  String? get commitment;
  @override
  @JsonKey(name: 'nonce_commitment')
  String? get nonceCommitment;
  @override
  @JsonKey(ignore: true)
  _$$GdkUnspentOutputsImplCopyWith<_$GdkUnspentOutputsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GdkCurrencyData _$GdkCurrencyDataFromJson(Map<String, dynamic> json) {
  return _GdkCurrencyData.fromJson(json);
}

/// @nodoc
mixin _$GdkCurrencyData {
  List<String>? get all => throw _privateConstructorUsedError;
  @JsonKey(name: 'per_exchange')
  Map<String, List<String>>? get perExchange =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GdkCurrencyDataCopyWith<GdkCurrencyData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GdkCurrencyDataCopyWith<$Res> {
  factory $GdkCurrencyDataCopyWith(
          GdkCurrencyData value, $Res Function(GdkCurrencyData) then) =
      _$GdkCurrencyDataCopyWithImpl<$Res, GdkCurrencyData>;
  @useResult
  $Res call(
      {List<String>? all,
      @JsonKey(name: 'per_exchange') Map<String, List<String>>? perExchange});
}

/// @nodoc
class _$GdkCurrencyDataCopyWithImpl<$Res, $Val extends GdkCurrencyData>
    implements $GdkCurrencyDataCopyWith<$Res> {
  _$GdkCurrencyDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? all = freezed,
    Object? perExchange = freezed,
  }) {
    return _then(_value.copyWith(
      all: freezed == all
          ? _value.all
          : all // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      perExchange: freezed == perExchange
          ? _value.perExchange
          : perExchange // ignore: cast_nullable_to_non_nullable
              as Map<String, List<String>>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GdkCurrencyDataImplCopyWith<$Res>
    implements $GdkCurrencyDataCopyWith<$Res> {
  factory _$$GdkCurrencyDataImplCopyWith(_$GdkCurrencyDataImpl value,
          $Res Function(_$GdkCurrencyDataImpl) then) =
      __$$GdkCurrencyDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<String>? all,
      @JsonKey(name: 'per_exchange') Map<String, List<String>>? perExchange});
}

/// @nodoc
class __$$GdkCurrencyDataImplCopyWithImpl<$Res>
    extends _$GdkCurrencyDataCopyWithImpl<$Res, _$GdkCurrencyDataImpl>
    implements _$$GdkCurrencyDataImplCopyWith<$Res> {
  __$$GdkCurrencyDataImplCopyWithImpl(
      _$GdkCurrencyDataImpl _value, $Res Function(_$GdkCurrencyDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? all = freezed,
    Object? perExchange = freezed,
  }) {
    return _then(_$GdkCurrencyDataImpl(
      all: freezed == all
          ? _value._all
          : all // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      perExchange: freezed == perExchange
          ? _value._perExchange
          : perExchange // ignore: cast_nullable_to_non_nullable
              as Map<String, List<String>>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GdkCurrencyDataImpl implements _GdkCurrencyData {
  _$GdkCurrencyDataImpl(
      {final List<String>? all,
      @JsonKey(name: 'per_exchange')
      final Map<String, List<String>>? perExchange})
      : _all = all,
        _perExchange = perExchange;

  factory _$GdkCurrencyDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$GdkCurrencyDataImplFromJson(json);

  final List<String>? _all;
  @override
  List<String>? get all {
    final value = _all;
    if (value == null) return null;
    if (_all is EqualUnmodifiableListView) return _all;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final Map<String, List<String>>? _perExchange;
  @override
  @JsonKey(name: 'per_exchange')
  Map<String, List<String>>? get perExchange {
    final value = _perExchange;
    if (value == null) return null;
    if (_perExchange is EqualUnmodifiableMapView) return _perExchange;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'GdkCurrencyData(all: $all, perExchange: $perExchange)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GdkCurrencyDataImpl &&
            const DeepCollectionEquality().equals(other._all, _all) &&
            const DeepCollectionEquality()
                .equals(other._perExchange, _perExchange));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_all),
      const DeepCollectionEquality().hash(_perExchange));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GdkCurrencyDataImplCopyWith<_$GdkCurrencyDataImpl> get copyWith =>
      __$$GdkCurrencyDataImplCopyWithImpl<_$GdkCurrencyDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GdkCurrencyDataImplToJson(
      this,
    );
  }
}

abstract class _GdkCurrencyData implements GdkCurrencyData {
  factory _GdkCurrencyData(
      {final List<String>? all,
      @JsonKey(name: 'per_exchange')
      final Map<String, List<String>>? perExchange}) = _$GdkCurrencyDataImpl;

  factory _GdkCurrencyData.fromJson(Map<String, dynamic> json) =
      _$GdkCurrencyDataImpl.fromJson;

  @override
  List<String>? get all;
  @override
  @JsonKey(name: 'per_exchange')
  Map<String, List<String>>? get perExchange;
  @override
  @JsonKey(ignore: true)
  _$$GdkCurrencyDataImplCopyWith<_$GdkCurrencyDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
