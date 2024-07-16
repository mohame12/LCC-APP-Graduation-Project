import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/models/doctor_model.dart';
import 'package:graduation_project/models/patient_model.dart';
import 'package:graduation_project/modules/login/cubit/states.dart';
import 'package:graduation_project/shared/components/components.dart';

import '../../../models/user_model.dart';

class LoginCubit extends Cubit<LoginStates> {
  //LoginCubit(LoginStates initialState) : super(initialState);
  LoginCubit():super (LoginInitialState()) ;

  static LoginCubit get(context) => BlocProvider.of(context);

  IconData suffixLogin = Icons.visibility;
  bool isPasswordLogin = true;
  final firebase=FirebaseFirestore.instance;
  void changeLoginPasswordVisibility()
  {
    isPasswordLogin = !isPasswordLogin;
    suffixLogin = isPasswordLogin? Icons.visibility : Icons.visibility_off ;
    emit(LoginPasswordVisibilityState());
  }

  void userLogin({
    required String email,
    required String password,
  }){
    emit(LoginLoadingState());
    FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password).then((value){
      if (kDebugMode) {
        print(value.user?.email);
      }
      print(value.user?.uid);
      emit(LoginSuccessState(FirebaseAuth.instance.currentUser!.uid));
    }).catchError((error){
      var index=(error.toString()).indexOf(']');
      String showerror=(error.toString()).substring(index+1);
      showToast(
          text: '${showerror}', state: ToastStates.ERROR
      );
      emit(LoginErrorState(error.toString()));
    });
  }
  Future<void> signOut() async {
    try {
      emit(LogoutLoadingState());
      //await CacheHelper.removeDate(key: 'uId');
      //await CacheHelper.removeDate(key: 'type');
      //uID=' ';
      await FirebaseAuth.instance.signOut();
    }catch(c){
      print("errroe");

    }
    emit(LoginInitialState());
    print("the user is ${FirebaseAuth.instance.currentUser}");
  }
  // void userLoginUser({
  //   required String email,
  //   required String password,
  // }){
  //   FirebaseFirestore.instance.terminate();
  //   FirebaseFirestore.instance
  //       .clearPersistence()
  //       .then((value) => userLogin(email: email, password: password));
  // }


  DoctorModel docModel = DoctorModel();
  PatientModel patModel= PatientModel();
  //var uID = CacheHelper.getData(key: 'uId');
  //var type=CacheHelper.getData(key: 'type');
  List<DoctorModel> doctors = [];
  List<PatientModel>patients= [];


  Future<String> updateToken({required String userId}) async {
    String?currentToken=await FirebaseMessaging.instance.getToken();
    print("the current token is ${currentToken}");
    print("the user uid is ${userId}");
   UserModel model=UserModel();
    try {
      await firebase.collection("user").doc(
          FirebaseAuth.instance.currentUser!.uid).get().then((value) {
        model = UserModel.fromJson(value.data()!);
      });
    }
    catch(c){
      print("eeeeeeeeeeeeeeeeeeeeeee");
    }
    try {
      if(model.type=="doctor")
      {
        firebase.collection('doctor').doc(userId).update({'token':currentToken});
      }
      else if(model.type=="patient")
      {
        firebase.collection('patient').doc(userId).update({'token':currentToken});
      }
      emit(TokenUpdated());

      return "Token Updated Successfully...";
    } on Exception catch (e) {
      return e.toString();
    }
  }
  Future<void> changeOfflineStatus()async {
    FirebaseFirestore.instance.collection('user').doc(FirebaseAuth.instance.currentUser!.uid).update(
        {'status':'offline'});
    emit(ChangeStatus());

  }
  Future<void> changeOnlineStatus()async {
    FirebaseFirestore.instance.collection('user').doc(FirebaseAuth.instance.currentUser!.uid).update(
        {'status':'online'});
    emit(ChangeStatus());

  }
}
