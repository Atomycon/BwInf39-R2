import 'dart:io';

class Skewer {
  final List<int> bowlNumbers;
  final List<String> fruits;

  Skewer(this.bowlNumbers, this.fruits);

  @override
  String toString() {
    return "$bowlNumbers = $fruits";
  }
}

//run by using cmd: 1. go in the current dict 2. run: dart aufgabe2.dart
void main() async {
  List<String> filenames = [
    "spiesse1.txt",
    "spiesse2.txt",
    "spiesse3.txt",
    "spiesse4.txt",
    "spiesse5.txt",
    "spiesse6.txt",
    "spiesse7.txt",
  ];
  for (String filename in filenames) {
    String content = await File("A2\\beispiele\\$filename")
        .readAsString(); //TODO for final beispiele\\$filename
    List<String> lines = content.split("\n");
    lines.removeWhere((element) => element.isEmpty); //remove empty lines
    int nFruits = int.parse(lines[0]);
    List<String> targetFruits = extractFruitsFrom(lines[1]);
    int nSkewer = int.parse(lines[2]);
    List<Skewer> skewers = [];
    for (int n = 3; n < nSkewer * 2 + 3; n += 2) {
      List<int> bowlNumbers = [];

      List<String> tmp = lines[n].split(" ");
      tmp.removeWhere((element) => element.isEmpty);
      bowlNumbers = tmp.map((e) {
        return int.parse(e);
      }).toList();

      List<String> fruits = extractFruitsFrom(lines[n + 1]);

      skewers.add(Skewer(bowlNumbers, fruits));
    }
    print(skewers);
  }
}

List<String> extractFruitsFrom(String text) {
  List<String> fruits = text.split(" ");
  fruits.removeWhere((element) => element.isEmpty); //remove empty lines
  return fruits;
}
