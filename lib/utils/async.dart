Future<bool> waitForValue(bool Function() test,
    {Duration frequency = const Duration(milliseconds: 300),
    void Function()? failOp}) async {
  if (test()) {
    return true;
  }

  if (failOp != null) {
    failOp();
  }

  await Future.delayed(frequency);

  return waitForValue(test, frequency: frequency);
}
