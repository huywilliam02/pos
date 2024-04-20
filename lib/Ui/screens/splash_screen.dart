// import 'dart:async';

import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:citgroupvn_bds/Ui/screens/widgets/Erros/no_internet.dart';
import 'package:citgroupvn_bds/app/default_app_setting.dart';
import 'package:citgroupvn_bds/app/routes.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/flutter_svg.dart';

// import '../app/routes.dart';
import 'package:citgroupvn_bds/data/cubits/profile_setting_cubit.dart';
import 'package:citgroupvn_bds/data/cubits/system/fetch_language_cubit.dart';
import 'package:citgroupvn_bds/data/cubits/system/fetch_system_settings_cubit.dart';
import 'package:citgroupvn_bds/data/model/system_settings_model.dart';
import 'package:citgroupvn_bds/utils/AppIcon.dart';
import 'package:citgroupvn_bds/utils/Extensions/extensions.dart';
import 'package:citgroupvn_bds/utils/api.dart';
import 'package:citgroupvn_bds/utils/ui_utils.dart';
// import 'package:citgroupvn_bds/main.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../app/app.dart';
import '../../app/app_theme.dart';
import '../../data/Repositories/system_repository.dart';
import '../../data/cubits/auth/auth_state_cubit.dart';
import '../../data/cubits/category/fetch_category_cubit.dart';
import '../../data/cubits/outdoorfacility/fetch_outdoor_facility_list.dart';
import '../../data/cubits/subscription/get_subsctiption_package_limits_cubit.dart';
import '../../data/cubits/system/app_theme_cubit.dart';
import '../../utils/constant.dart';
import '../../utils/hive_keys.dart';
import '../../utils/hive_utils.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AuthenticationState authenticationState;

  bool isTimerCompleted = false;
  bool isSettingsLoaded = false;
  bool isLanguageLoaded = false;

  @override
  void initState() {
    context.read<FetchCategoryCubit>().fetchCategories();
    context.read<FetchOutdoorFacilityListCubit>().fetch();
    locationPermission();

    super.initState();

    getDefaultLanguage(
      () {
        isLanguageLoaded = true;
        setState(() {});
      },
    );

    checkIsUserAuthenticated();
    bool isDataAvailable = checkPersistedDataAvailibility();
    Connectivity().checkConnectivity().then((value) {
      if (value == ConnectivityResult.none && !isDataAvailable) {
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) {
            return NoInternet(
              onRetry: () async {
                try {
                  await LoadAppSettings().load();
                  if (context.color.brightness == Brightness.light) {
                    context.read<AppThemeCubit>().changeTheme(AppTheme.light);
                  } else {
                    context.read<AppThemeCubit>().changeTheme(AppTheme.dark);
                  }
                } catch (e) {
                  print("no internet");
                }
                Future.delayed(
                  Duration.zero,
                  () {
                    Navigator.pushReplacementNamed(
                      context,
                      Routes.splash,
                    );
                  },
                );
              },
            );
          },
        ));
      }
    });
    startTimer();
    //get Currency Symbol from Admin Panel
    Future.delayed(Duration.zero, () {
      context.read<ProfileSettingCubit>().fetchProfileSetting(
            context,
            Api.currencySymbol,
          );
    });
  }

  Future<void> locationPermission() async {
    if ((await Permission.location.status) == PermissionStatus.denied) {
      await Permission.location.request();
    }
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    super.dispose();
  }

  void checkIsUserAuthenticated() async {
    authenticationState = context.read<AuthenticationCubit>().state;
    if (authenticationState == AuthenticationState.authenticated) {
      ///Only load sensitive details if user is authenticated
      ///This call will load sensitive details with settings
      context.read<FetchSystemSettingsCubit>().fetchSettings(
            isAnonymouse: false,
            forceRefresh: false,
          );
      completeProfileCheck();
    } else {
      //This call will hide sensitive details.
      context.read<FetchSystemSettingsCubit>().fetchSettings(
            isAnonymouse: true,
            forceRefresh: true,
          );
    }
  }

  Future<void> startTimer() async {
    Timer(const Duration(seconds: 3), () {
      isTimerCompleted = true;
      if (mounted) setState(() {});
    });
  }

  void navigateCheck() {
    ({
      "timer": isTimerCompleted,
      "setting": isSettingsLoaded,
      "language": isLanguageLoaded
    }).logg;

    if (isTimerCompleted && isSettingsLoaded && isLanguageLoaded) {
      navigateToScreen();
    }
  }

  void completeProfileCheck() {
    if (HiveUtils.getUserDetails().name == "" ||
        HiveUtils.getUserDetails().email == "") {
      Future.delayed(
        const Duration(milliseconds: 100),
        () {
          Navigator.pushReplacementNamed(
            context,
            Routes.completeProfile,
            arguments: {
              "from": "login",
            },
          );
        },
      );
    }
  }

  void navigateToScreen() {
    if (context
            .read<FetchSystemSettingsCubit>()
            .getSetting(SystemSetting.maintenanceMode) ==
        "1") {
      Future.delayed(Duration.zero, () {
        Navigator.of(context).pushReplacementNamed(
          Routes.maintenanceMode,
        );
      });
    } else if (authenticationState == AuthenticationState.authenticated) {
      Future.delayed(Duration.zero, () {
        Navigator.of(context)
            .pushReplacementNamed(Routes.main, arguments: {'from': "main"});
      });
    } else if (authenticationState == AuthenticationState.unAuthenticated) {
      if (Hive.box(HiveKeys.userDetailsBox).get("isGuest") == true) {
        Future.delayed(Duration.zero, () {
          Navigator.of(context)
              .pushReplacementNamed(Routes.main, arguments: {"from": "splash"});
        });
      } else {
        Future.delayed(Duration.zero, () {
          Navigator.of(context).pushReplacementNamed(Routes.login);
        });
      }
    } else if (authenticationState == AuthenticationState.firstTime) {
      Future.delayed(Duration.zero, () {
        Navigator.of(context).pushReplacementNamed(Routes.onboarding);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    navigateCheck();

    return BlocListener<FetchLanguageCubit, FetchLanguageState>(
      listener: (context, state) {},
      child: BlocListener<FetchSystemSettingsCubit, FetchSystemSettingsState>(
        listener: (context, state) {
          if (state is FetchSystemSettingsFailure) {}
          if (state is FetchSystemSettingsSuccess) {
            var setting = context
                .read<FetchSystemSettingsCubit>()
                .getSetting(SystemSetting.subscription);
            if ((setting as List).isNotEmpty) {
              if ((setting[0] as Map).containsKey("package_id")) {
                Constant.subscriptionPackageId =
                    setting[0]['package_id'].toString();
                context.read<GetSubsctiptionPackageLimitsCubit>().getLimits(
                      setting[0]['package_id'].toString(),
                    );
              }
            }

            if (state.settings['data'].containsKey("demo_mode")) {
              Constant.isDemoModeOn = state.settings['data']['demo_mode'];
            }
            isSettingsLoaded = true;
            setState(() {});
          }
        },
        child: AnnotatedRegion(
          value: SystemUiOverlayStyle(
            statusBarColor: context.color.tertiaryColor,
          ),
          child: Scaffold(
            backgroundColor: context.color.tertiaryColor,
            body: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                      width: 150,
                      height: 150,
                      child: LoadAppSettings().svg(
                        appSettings.splashLogo!,
                        // color: context.color.secondaryColor,
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    key: const ValueKey("companylogo"),
                    child: UiUtils.getSvg(AppIcons.companyLogo),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future getDefaultLanguage(VoidCallback onSuccess) async {
  try {
    if (HiveUtils.getLanguage() == null ||
        HiveUtils.getLanguage()?['data'] == null) {
      Map result = await SystemRepository().fetchSystemSettings(
        isAnonymouse: true,
      );

      var code = (result['data']['default_language']);

      await Api.get(
        url: Api.getLanguagae,
        queryParameters: {
          Api.languageCode: code,
        },
        useAuthToken: false,
      ).then((value) {
        HiveUtils.storeLanguage({
          "code": value['data']['code'],
          "data": value['data']['file_name'],
          "name": value['data']['name']
        });
        onSuccess.call();
      });
    } else {
      onSuccess.call();
    }
  } catch (e) {
    log("Error while load default language $e");
  }
}

bool checkPersistedDataAvailibility() {
  int dataAvailibile = 0;
  for (Type cubit in Constant.hydratedCubits) {
    if (HydratedBloc.storage.read('$cubit') == null) {
    } else {
      dataAvailibile++;
    }
  }
  if (dataAvailibile == Constant.hydratedCubits.length) {
    return true;
  } else {
    return false;
  }
}
