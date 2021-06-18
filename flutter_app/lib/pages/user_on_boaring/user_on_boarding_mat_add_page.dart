// import 'package:audio_session/audio_session.dart';
// import 'package:flare_flutter/flare_actor.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_app/classes/userOnBoardingFlow.dart';
// import 'package:flutter_app/helpers/color_scheme.dart';
// import 'package:flutter_app/helpers/utils.dart';
// import 'package:flutter_app/widgets/buttons.dart';
// import 'package:flutter_app/widgets/confirmation_box/confirmation_widget.dart';
// //import 'package:flutter_app/widgets/confirmation_box/confirmation_widget.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../a_pages_index.dart';

// const YIPLI_ON_BOARDING_PAGE_HEADING =
//     "Just few steps away from Yipli Gaming Experience !!!";

// const REGISTER_MAT_TITLE = "Let's register your Mat";
// const ADD_MAT_SKIPP_INSTRUCRION = "If you exit you can't use Yipli";

// class UserOnBoardingMatAddPage extends StatefulWidget {
//   static const String routeName = '/user_on_boarding_mat_add_page';

//   final UserOnBoardingFlows flowValue;
//   @override
//   _UserOnBoardingMatAddPageState createState() =>
//       _UserOnBoardingMatAddPageState();

//   UserOnBoardingMatAddPage(this.flowValue) {}
// }

// class _UserOnBoardingMatAddPageState extends State<UserOnBoardingMatAddPage>
//     with WidgetsBindingObserver {
//   void onNextPress() {
//     _audioPlayer.dispose();
//     // YipliUtils.gotoAddMatPageFromOnBoardingPage(widget.flowValue);
//   }

//   AudioPlayer _audioPlayer;

//   ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(children: [
//     AudioSource.uri(
//       Uri.parse(YipliConstants.AudioAssetDirPath + "WelcomeToYipliTUFGC.mp3"),
//     ),
//     AudioSource.uri(
//       Uri.parse(YipliConstants.AudioAssetDirPath + "LetsRegistermat.mp3"),
//     ),
//   ]);
//   @override
//   void initState() {
//     super.initState();
//     _audioPlayer = AudioPlayer();
//     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
//       statusBarColor: Colors.black,
//     ));
//     _initAudioPlayer();
//     WidgetsBinding.instance.addObserver(this);
//   }

//   _initAudioPlayer() async {
//     final session = await AudioSession.instance;
//     await session.configure(AudioSessionConfiguration.speech());
//     try {
//       await _audioPlayer.setAudioSource(_playlist);
//       print('Audio source loaded');
//     } catch (e) {
//       // catch load errors: 404, invalid url ...
//       print("An error occured in audio source setting : $e");
//     }
//   }

//   @override
//   void dispose() {
//     _audioPlayer.dispose();
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.paused) {
//       //stop audio player
//       _audioPlayer.pause();
//     } else {
//       _audioPlayer.play();
//       print(state.toString());
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     Size screenSize = MediaQuery.of(context).size;
//     YipliButton nextButton;

//     //yipli widget called -'Process Cancel Confirmation Dialog'.
//     ProcessCancelConfirmationDialog exitConfirmationDialog =
//         ProcessCancelConfirmationDialog(
//       titleText: "Exit Setup ?",
//       subTitleText: ADD_MAT_SKIPP_INSTRUCRION,
//       buttonText: "Continue Setting-Up",
//       pressToExitText: "Skip for now",
//     );

//     exitConfirmationDialog.setClickHandler(() {
//       _audioPlayer.dispose();
//       YipliUtils.goToHomeScreen();
//       YipliUtils.showNotification(
//           context: context,
//           msg: "No Mat added.\nAdd Mat from Menu -> My Mats.",
//           type: SnackbarMessageTypes.ERROR,
//           duration: SnackbarDuration.LONG);
//     });

//     nextButton = new YipliButton(
//       "Next",
//       null,
//       null,
//       screenSize.width / 5,
//     );

//     nextButton.setClickHandler(onNextPress);

//     return Scaffold(
//       backgroundColor: Theme.of(context).primaryColor,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Container(
//             decoration: BoxDecoration(
//               border: Border.all(
//                 color: yipliNewBlue,
//                 width: 1,
//               ),
//               borderRadius: BorderRadius.all(
//                 Radius.circular(10),
//               ),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(15.0),
//               child: StreamBuilder<SequenceState>(
//                   stream: _audioPlayer.sequenceStateStream,
//                   builder: (context, snapshot) {
//                     final state = snapshot.data;
//                     if (state?.sequence?.isEmpty ?? true) return SizedBox();
//                     // print("Calling Play AudioSource");
//                     _audioPlayer.play();
//                     return Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Column(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           crossAxisAlignment: CrossAxisAlignment.end,
//                           children: [
//                             Text("Step",
//                                 textAlign: TextAlign.center,
//                                 style: Theme.of(context)
//                                     .textTheme
//                                     .bodyText1
//                                     .copyWith(color: yipliGray)),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.end,
//                               children: [
//                                 Text("1",
//                                     textAlign: TextAlign.center,
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .bodyText2
//                                         .copyWith(fontWeight: FontWeight.w600)),
//                                 Text(" / 2",
//                                     textAlign: TextAlign.center,
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .bodyText1
//                                         .copyWith(color: yipliGray)),
//                               ],
//                             ),
//                           ],
//                         ),
//                         Expanded(
//                           child: Align(
//                             alignment: Alignment.center,
//                             child: Text(
//                               REGISTER_MAT_TITLE,
//                               style: Theme.of(context).textTheme.headline5,
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                         ),
//                         Expanded(
//                           flex: 2,
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                             children: [
//                               Expanded(
//                                 flex: 2,
//                                 child: Align(
//                                   alignment: Alignment.center,
//                                   child: ClipRRect(
//                                     borderRadius: BorderRadius.circular(15.0),
//                                     child: Image.asset(
//                                       YipliAssets.yipliMatImage,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               // ),
//                               Expanded(
//                                 child: Text(YIPLI_ON_BOARDING_PAGE_HEADING,
//                                     textAlign: TextAlign.center,
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .headline6
//                                         .copyWith(color: yipliGray)),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Expanded(
//                           child: Align(
//                             alignment: Alignment.bottomCenter,
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 InkWell(
//                                   onTap: () async {
//                                     SharedPreferences prefs =
//                                         await SharedPreferences.getInstance();
//                                     prefs.setBool('mat_add_skipped', true);
//                                     prefs.setBool('player_add_skipped', true);

//                                     showDialog(
//                                         context: context,
//                                         barrierDismissible: false,
//                                         builder: (BuildContext context) =>
//                                             exitConfirmationDialog);
//                                   },
//                                   child: Text(
//                                     'Not now',
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .bodyText2
//                                         .copyWith(color: yipliErrorRed),
//                                   ),
//                                 ),
//                                 nextButton,
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     );
//                   }),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
