Future<bool> waitForValue(bool Function() test,
    {Duration frequency = const Duration(milliseconds: 300),
    Future<void> Function()? failOp}) async {
  if (test()) {
    return true;
  }

  if (failOp != null) {
    await failOp();
  }

  await Future.delayed(frequency);

  return waitForValue(test, frequency: frequency, failOp: failOp);
}
