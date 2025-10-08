// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/auth/data/datasource/auth_datasource.dart' as _i43;
import '../../features/auth/data/repo/auth_repo_imp1.dart' as _i367;
import '../../features/auth/domain/repo/auth_repository.dart' as _i2;
import '../../features/auth/domain/usecase/login-user.dart' as _i335;
import '../../features/auth/domain/usecase/logout_user.dart' as _i461;
import '../../features/auth/domain/usecase/register_user.dart' as _i708;
import '../../features/auth/presentation/bloc/auth_bloc.dart' as _i797;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.factory<_i43.AuthDatasource>(() => _i43.AuthDatasourceImpl());
    gh.factory<_i2.AuthRepo>(
      () => _i367.AuthRepoImpl(datasource: gh<_i43.AuthDatasource>()),
    );
    gh.factory<_i335.LoginUsecase>(
      () => _i335.LoginUsecase(repo: gh<_i2.AuthRepo>()),
    );
    gh.factory<_i461.LogoutUser>(
      () => _i461.LogoutUser(repo: gh<_i2.AuthRepo>()),
    );
    gh.factory<_i708.RegisterUsecase>(
      () => _i708.RegisterUsecase(repo: gh<_i2.AuthRepo>()),
    );
    gh.lazySingleton<_i797.AuthBloc>(
      () => _i797.AuthBloc(
        gh<_i335.LoginUsecase>(),
        gh<_i708.RegisterUsecase>(),
        gh<_i461.LogoutUser>(),
      ),
    );
    return this;
  }
}
