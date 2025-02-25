void main() async {
  Stream<String> dataStream = Stream.periodic(Duration(seconds: 1), (count) {
    return 'Data ${count +1}';
  }).take(5);

  await for (var data in dataStream) {
    String fetchedData = await fetchData();
    print('$data: $fetchedData');
  };
}

Future<String> fetchData() async {
  await Future.delayed(Duration(seconds: 2));
  return 'Data received';
}