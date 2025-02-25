import 'dart:isolate';

void main() async {
  final receivePort = ReceivePort();
  await Isolate.spawn(isolateFunction, receivePort.sendPort);

  receivePort.listen((data) {
    print('Received from isolate: $data');
    if (data == 'done') {
      receivePort.close();
    }
  });
}

void isolateFunction(SendPort sendPort) {
  for (int i = 0; i < 5; i++) {
    int result = i * i;
    sendPort.send('Result of $i is $result');
  }
  sendPort.send('done');
}

