//@dart=2.9

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/layouts/app_layout/app_layout.dart';
import 'package:graduation_project/modules/cancer%20_informations/colon_cancer/colon_informations.dart';
import 'package:graduation_project/modules/login/cubit/login_cubit.dart';
import 'package:graduation_project/modules/login/login_screen.dart';
import 'package:graduation_project/shared/block_observer.dart';
import 'package:graduation_project/shared/components/conestants.dart';
import 'package:graduation_project/shared/cubit/main_cubit.dart';
import 'package:graduation_project/shared/cubit/main_states.dart';
import 'package:graduation_project/shared/network/local/cash_helper.dart';
import 'package:graduation_project/shared/styles/themes.dart';
import 'layouts/app_layout/app_cubit.dart';
import 'modules/chat_screen/chat_doctor_screen.dart';
import 'modules/chat_screen/chat_patient_screen.dart';
import 'modules/on_boarding/on_boarding_screen.dart';
import 'modules/register/cubit/register_cubit.dart';
import 'modules/reservation_screen/patient_reservation.dart';
import 'myTest/audioCall.dart';
import 'myTest/restart_screen.dart';
import 'myTest/videoCall.dart';
import 'notification_service.dart';
Future<void>main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Bloc.observer = MyBlocObserver();
  //DioHelper.init();
  await CacheHelper.init();
  // token = CacheHelper.getData(key: 'token');
  //uId = CacheHelper.getData(key: 'uId');
  Widget widget;
  bool onBoarding = CacheHelper.getData(key: 'onBoarding');
  print(onBoarding);

  if(uId != null)
  {
    widget = const AppLayout();
  }else
  {
    widget = LoginScreen();
  }
  runApp(
      RestartWidget(
          child: MyApp(onBoarding: onBoarding,)));
}

class MyApp extends StatelessWidget {
  const MyApp({Key key, this.onBoarding}) : super(key: key);

  final bool onBoarding;

  @override
  Widget build(BuildContext context) {
    final navkey= GlobalKey<NavigatorState>();
    return  MultiBlocProvider(
        providers: [
          BlocProvider(create: (context)=>MainCubit(),),
          BlocProvider(create: (context)=>AppCubit()),
          BlocProvider(create: (context)=>LoginCubit()),
          BlocProvider(create: (context)=>RegisterCubit(),),
        ],
        child: FutureBuilder(
            future: fireInit(context,navkey),
            builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
              return BlocConsumer<MainCubit, MainStates>(
                listener: (context, state) {},
                builder: (context, state) =>
                MaterialApp(
                        routes: {
                          'chatdoctor':(c)=>ChatDoctorScreen(),
                          'chatpatient':(c)=>ChatPatientScreen(),
                          'videoScreen':(c)=>VideoCallScreen(),
                          'audioScreen':(c)=>const AudioCallScreen(),
                          'showPatientReservation':(c)=>ShowPatientReservation()
                        },
                        navigatorKey: navkey,
                        debugShowCheckedModeBanner: false,
                        theme: lightTheme,
                        //darkTheme: darkTheme,
                        home: onBoarding != null?
                        StreamBuilder(
                            stream:FirebaseAuth.instance.idTokenChanges(),
                            builder: (BuildContext context, AsyncSnapshot<User>snap) {
                              print("the current user is ${FirebaseAuth.instance.currentUser}");
                              return FutureBuilder(
                                  future:fcmInit(navkey) ,
                                  builder: (context,_) {
                                    if (snap.hasData) {
                                      try {
                                        context.read<AppCubit>()
                                            .changeUserModel();
                                        context.read<AppCubit>().currentIndex=2;
                                      }
                                      catch(c){
                                        print("errror");
                                      }
                                      return const AppLayout();
                                    }
                                    else {
                                      if(snap.hasError){
                                        print(snap.error.toString());
                                      }
                                      else if(snap.data==null){
                                        context.read<AppCubit>().currentIndex=2;
                                        return LoginScreen();
                                      }
                                    }
                                  }
                              );
                            }
                        ): const OnBoardingScreen(),
                      )
              );
            })
    );

  }
}
