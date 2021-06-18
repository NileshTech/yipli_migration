import 'package:country_code_picker/country_code_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'a_pages_index.dart';

late AuthService authService;

class SignUp extends StatelessWidget {
  static const String routeName = "/signup_screen";
  @override
  Widget build(BuildContext context) {
    return SignUpPage();
  }
}

class SignUpPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new SignUpPageState();
}

class SignUpPageState extends State<SignUpPage> {
  static String _name = "";
  static String _emailOrPhoneStr = "";
  String _password = "";
  String? cCode;
  String otpCode = "";
  Function? onSuccess;
  Function? onFailed;

  YipliTextInput? otpInput;
  YipliTextInput? emailInput;

  bool _saving = false;
  bool? showProceedButton;
  bool? showPasswordInput;
  bool? showCountryDropdown = false;
  bool? showSignUpButton = false;
  String? storedString; //Used to store string when next button is pressed
  bool isOTPSent = false;
  bool showOTPInput = false;
  bool isEmailSignUp = true; //if false phone is being sign up
  bool isSIgnUpButtonPressed = false;
  YipliTextInput? passwordInput;
  YipliButton? signUpButton;
  YipliButton? proceedButton;
  bool displayTimer = false;
  int _counter = 60;
  Timer? _timer;
  String? country;
  String? countryCode;

  void _startTimerForOTP() {
    _counter = 60;
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_counter > 0) {
          _counter--;
        } else {
          displayTimer = false;
          isOTPSent = false;
          _timer!.cancel();
        }
      });
    });
  }

  Future<void> onSignUpPress() async {
    if (isEmailSignUp == false) {
      if (isOTPSent == true && validateOTPAfterLoginPress(otpCode) == null) {
        User user = await (authService.phoneNumberSignUp(
                context, YipliUtils.smsVerificationCode, otpCode)
            as FutureOr<User>);
        Users newUser = new Users(
            user.uid, [], [], _emailOrPhoneStr, "", cCode ?? countryCode);
        await newUser.persist().then((_) {
          YipliUtils.initializeApp();
        });
      } else {
        YipliUtils.showNotification(
            context: context,
            msg: "Enter valid OTP",
            type: SnackbarMessageTypes.ERROR,
            duration: SnackbarDuration.LONG);
      }
    } else if (YipliValidators.validatePassword(_password) == null) {
      //@TODO Add error for signup!
      User? signedUpUser = await validateAndRegister();
      setState(() {
        _saving = true;
      });
      YipliUtils.goToVerificationScreen(signedUpUser, _emailOrPhoneStr);
    } else {
      YipliUtils.showNotification(
          context: context,
          msg: "Enter password greater than 6 characters",
          type: SnackbarMessageTypes.ERROR,
          duration: SnackbarDuration.LONG);
    }

    setState(() {
      isSignupButtonPressed = true;
      // _saving = true;
    });
  }

  Future<void> onProceedButtonPress() async {
    if (YipliValidators.validateEmailAndPhoneNumber(_emailOrPhoneStr) == null) {
      if (YipliValidators.email == true) {
        if (await Users.isEmailRegisteredUnderAnyUser(_emailOrPhoneStr)) {
          //Code to check if the phone no is already registered.
          //show msg and exit
          setState(() {
            YipliUtils.showNotification(
                context: context,
                msg: "This email is registered with Yipli.\nTry to login .",
                type: SnackbarMessageTypes.ERROR,
                duration: SnackbarDuration.LONG);
          });
        } else {
          setState(() {
            showPasswordInput = true;
            showSignUpButton = true;
            storedString = _emailOrPhoneStr;
          });
        }
      } else if (YipliValidators.phoneNumber == true) {
        if (await Users.getUserMatchingPhoneNumber(_emailOrPhoneStr) != null) {
          //Code to check if the phone no is already registered.
          //show msg and exit
          setState(() {
            YipliUtils.showNotification(
                context: context,
                msg:
                    "This phone number is registered with Yipli.\nTry to login .",
                type: SnackbarMessageTypes.ERROR,
                duration: SnackbarDuration.LONG);
          });
        } else {
          print('Generate OTP button pressed');
          setState(() {
            displayTimer = true;
            showSignUpButton = true;
            storedString = _emailOrPhoneStr;
            showOTPInput = true;
            showPasswordInput = false;
            _startTimerForOTP();
          });
          YipliUtils.showNotification(
              context: context,
              msg: "OTP has been sent on your mobile number.",
              type: SnackbarMessageTypes.INFO,
              duration: SnackbarDuration.LONG);
          await YipliUtils.getPhoneOtp(context, _emailOrPhoneStr, onSuccess,
              onFailed, cCode ?? countryCode);
          isOTPSent = true;
          isEmailSignUp = false;
        }
      }
    } else {
      YipliUtils.showNotification(
          context: context,
          msg: "Enter valid email/phone number",
          type: SnackbarMessageTypes.ERROR);
    }
  }

  static void onNameSaved(String name) {
    _name = name;
    print('Name $name saved');
  }

  void onEmailSaved(String? email) {
    _emailOrPhoneStr = email!;
    print('Email $email saved');
    Pattern pattern = (r'^[0-9]+$');
    RegExp regex = new RegExp(pattern as String);
    if (regex.hasMatch(email)) {
      setState(() {
        showCountryDropdown = true;
      });
    } else {
      setState(() {
        showCountryDropdown = false;
      });
    }
    if (showSignUpButton == true) {
      if (email != storedString) {
        setState(() {
          showSignUpButton = false;
          storedString = "";
          showOTPInput = false;
          showPasswordInput = false;
          displayTimer = false;
        });
      }
    }
  }

  void onPasswordSaved(String? password) {
    _password = password!;
    print('Password $password saved');
  }

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<User?> validateAndRegister() async {
    final FormState? form = _formKey.currentState;
    if (_formKey.currentState!.validate()) {
      if (YipliUtils.appConnectionStatus == AppConnectionStatus.CONNECTED) {
        form!.save();
        print("Signing up user! with loader");
        try {
          User newUser = await (authService.signUpUser(
              _name, _emailOrPhoneStr, _password) as FutureOr<User>);
          print("New user created with userId ${newUser.uid}");
          print("Signed up user!");
          return newUser;
        } catch (exp, stackTrace) {
          print('Error Aala');
          print(stackTrace.toString());

          print("Error code is : ${exp.toString()}");
          switch (exp) {
            case "ERROR_INVALID_CREDENTIAL":
            case "invalid-credential":
              YipliUtils.showNotification(
                  context: context,
                  msg:
                      "The supplied auth credential is malformed or has expired.",
                  type: SnackbarMessageTypes.ERROR);
              break;
            case "ERROR_INVALID_EMAIL":
            case "invalid-email":
              YipliUtils.showNotification(
                  context: context,
                  msg: "The email address is badly formatted.",
                  type: SnackbarMessageTypes.ERROR);
              break;
            case "ERROR_WRONG_PASSWORD":
            case "invalid-password":
              YipliUtils.showNotification(
                  context: context,
                  msg:
                      "The password is invalid or the user does not have a password.",
                  type: SnackbarMessageTypes.ERROR);
              break;
            case "ERROR_REQUIRES_RECENT_LOGIN":
              YipliUtils.showNotification(
                  context: context,
                  msg:
                      "This operation is sensitive and requires recent authentication. Log in again before retrying this request.",
                  type: SnackbarMessageTypes.ERROR);
              break;
            case "ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL":
            case "invalid-credential":
              YipliUtils.showNotification(
                  context: context,
                  msg:
                      "An account already exists with the same email address but different sign-in credentials. Sign in using a provider associated with this email address.",
                  type: SnackbarMessageTypes.ERROR);
              break;
            case "ERROR_EMAIL_ALREADY_IN_USE":
            case "email-already-in-use":
            case "ERROR_CREDENTIAL_ALREADY_IN_USE":
              YipliUtils.showNotification(
                  context: context,
                  msg:
                      "This credential is already associated with a different user account.\nLogin using the same account.",
                  type: SnackbarMessageTypes.ERROR);
              break;
            case "ERROR_USER_DISABLED":
            case "invalid-disabled-field":
              YipliUtils.showNotification(
                  context: context,
                  msg:
                      "The user account has been disabled by an administrator.",
                  type: SnackbarMessageTypes.ERROR);
              break;
            case "ERROR_USER_NOT_FOUND":
            case "user-not-found":
              YipliUtils.showNotification(
                  context: context,
                  msg:
                      "There is no user record corresponding to this identifier. The user may have been deleted.",
                  type: SnackbarMessageTypes.ERROR);
              break;
            default:
              print("Signup failed. Exception : ${exp.toString()}");
              YipliUtils.showNotification(
                  context: context,
                  msg:
                      "There was an error logging you in at the moment. If error persists, please contact Yipli Support.",
                  type: SnackbarMessageTypes.ERROR);

              break;
          }
          return null;
        } finally {}
      } else {
        YipliUtils.showNotification(
            context: context,
            msg: "No Internet Connectivity",
            type: SnackbarMessageTypes.ERROR,
            duration: SnackbarDuration.MEDIUM);
      }
    }

    return null;
  }

  @override
  void initState() {
    _formKey = GlobalKey<FormState>();
    super.initState();
    authService = new AuthService();
    isSignupButtonPressed = false;
    country = "IN";
    countryCode = DEFAULT_COUNTRY_CODE_IN;
    super.initState();
  } // our default setting is to login, and we should switch to creating an account when the user chooses to

  SignUpPageState();

  late bool isSignupButtonPressed;
  void onSavedcode(String? code) {
    otpCode = code!;
    print("Contact $code saved");
  }

  String? validateNameAfterSignupPress(String value) {
    if (!isSignupButtonPressed)
      return null;
    else
      return YipliValidators.validateName(value);
  }

  String? validateEmailAfterSignupPress(String value) {
    if (!isSignupButtonPressed)
      return null;
    else
      return YipliValidators.validateEmail(value);
  }

  String? validatePasswordAfterSignupPress(String? value) {
    if (!isSIgnUpButtonPressed) return null;
    if (value!.length < 6)
      return 'Enter valid password';
    else
      return null;
  }

  String? validateOTPAfterLoginPress(String? value) {
    if (!isSIgnUpButtonPressed)
      return null;
    else if (value!.length < 6 || value.length > 6)
      return 'Enter valid OTP';
    else
      return null;
  }

  VerificationScreenInput? inputArgs;
  @override
  Widget build(BuildContext context) {
    inputArgs =
        ModalRoute.of(context)!.settings.arguments as VerificationScreenInput?;
    emailInput = new YipliTextInput(
        "Enter your Email or Phone number",
        "Email or Phone",
        showPasswordInput == true && showSignUpButton == true
            ? FontAwesomeIcons.at
            : showSignUpButton == true && showOTPInput == true
                ? FontAwesomeIcons.phone
                : null,
        false,
        YipliValidators.validateEmailAndPhoneNumber,
        // validateEmailAfterSignupPress,
        onEmailSaved,
        null,
        true,
        null,
        Theme.of(context).primaryColorLight);

    passwordInput = new YipliTextInput(
        "Choose a password with min 6 characters",
        "Password",
        FontAwesomeIcons.lock,
        true, //obscure text is true to have it in encrypted form,value gets change based on visibilty icon
        validatePasswordAfterSignupPress,
        onPasswordSaved,
        null,
        true,
        null,
        Theme.of(context).primaryColorLight,
        null,
        true //password visibility is handled by YipliTextInput itself
        );
    otpInput = new YipliTextInput(
      "",
      "Enter your OTP here",
      Icons.security,
      false,
      validateOTPAfterLoginPress,
      onSavedcode,
      null,
      true,
      TextInputType.numberWithOptions(
        signed: false,
        decimal: false,
      ),
    );

    final Size screenSize = MediaQuery.of(context).size;
    proceedButton = new YipliButton(
      "Proceed",
      null,
      null,
      screenSize.width / 4,
    );

    signUpButton = new YipliButton("Sign Up", null, null, screenSize.width / 3);
    signUpButton!.setClickHandler(onSignUpPress);
    proceedButton!.setClickHandler(onProceedButtonPress);
    if (YipliValidators.validateEmailAndPhoneNumber(_emailOrPhoneStr) == null) {
      setState(() {
        showProceedButton = true;
      });
    }
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: ModalProgressHUD(
          progressIndicator: YipliLoader(),
          inAsyncCall: _saving,
          child: SizedBox(
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: 20.0,
              ),
              child: Container(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: <Widget>[
                    Hero(
                      tag: "yipli-logo",
                      child: YipliLogoAnimatedSmall(),
                    ),
                    Center(
                      child: SizedBox(
                        height: screenSize.height / 20,
                      ),
                    ),
                    Text(
                      'Register with Yipli',
                      style: Theme.of(context).textTheme.subtitle1!.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    SizedBox(
                        height: showOTPInput == true
                            ? 0.4 * screenSize.height
                            : 0.35 * screenSize.height,
                        child: SingleChildScrollView(
                            child: Column(
                          children: [
                            _buildTextFields(context),
                            _buildButtons(context),
                          ],
                        ))),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildValidityDisplayTimer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text("valid for :",
              style: Theme.of(context)
                  .textTheme
                  .bodyText2!
                  .copyWith(color: yipliGray)),
          Text(
            " $_counter",
            style: Theme.of(context)
                .textTheme
                .headline6!
                .copyWith(color: yipliErrorRed),
          ),
        ],
      ),
    );
  }

// login email details, and password
  Widget _buildTextFields(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return Container(
      //height: screenSize.height / 2,
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        //autovalidate: true,
        child: Column(
          children: <Widget>[
            showCountryDropdown!
                ? Center(
                    child: CountryCodePicker(
                      onChanged: onCountryChange,
                      // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                      initialSelection: country,
                      favorite: [countryCode!, country!],
                      // optional. Shows only country name and flag
                      showCountryOnly: true,
                      // optional. Shows only country name and flag when popup is closed.
                      showOnlyCountryWhenClosed: false,
                      // optional. aligns the flag and the Text left
                      alignLeft: false,
                      dialogBackgroundColor: yipliWhite,
                      showDropDownButton: true,
                      hideSearch: false,
                      dialogTextStyle:
                          TextStyle(color: yipliBlack, fontSize: 12),
                      searchStyle: TextStyle(color: yipliBlack, fontSize: 12),
                      // boxDecoration:
                      //     BoxDecoration(border: Border.all(color: yipliWhite)),
                    ),
                  )
                : Container(),
            emailInput!,
            showSignUpButton == true
                ? showPasswordInput != true
                    ? otpInput!
                    : passwordInput!
                : SizedBox(height: 0),
          ],
        ),
      ),
    );
  }

  String? onCountryChange(CountryCode countryCode) {
    //TODO : manipulate the selected country code here
    cCode = countryCode.toString();
    print("cCode is:" + cCode!);
    return cCode;
  }

  Widget buildResendOTPText(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onProceedButtonPress();
      },
      child: displayTimer == false && showPasswordInput == false
          ? Text('Resend OTP',
              style: Theme.of(context).textTheme.bodyText2!.copyWith(
                    color: Theme.of(context).accentColor,
                  ))
          : Container(),
    );
  }

//  signup buttons
  Widget _buildButtons(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(16.0, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: screenSize.height / 60),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    showSignUpButton == true
                        ? displayTimer == true
                            ? _buildValidityDisplayTimer(context)
                            : buildResendOTPText(context)
                        : SizedBox(width: 5),
                    showSignUpButton == true ? signUpButton! : proceedButton!,
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FlatButton(
                      focusColor: yAndroidTVFocusColor,
                      child: Text(
                        'Already have account? Log in.',
                        style: Theme.of(context)
                            .textTheme
                            .bodyText2!
                            .copyWith(decoration: TextDecoration.underline),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushNamed('/login_screen');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
