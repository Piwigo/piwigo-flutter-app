class AppRegexp {
  static final RegExp urlCheck = RegExp(
    r'[-a-zA-Z\d@:%._+~#=]{1,256}\.[a-zA-Z\d()]{1,256}\b([-a-zA-Z\d()@:%_+.~#?&/=]*)',
  );
}
