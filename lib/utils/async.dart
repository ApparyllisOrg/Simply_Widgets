
Future<bool> waitForValue(bool Function() test, {Duration frequency = const Duration(milliseconds: 300)}) async
{
  if (test())
  {
    return true;
  }

  await Future.delayed(frequency);

  return waitForValue(test, frequency: frequency);  
}