import 'dart:io';

class Skewer {
  final List<int> bowlNumbers;
  final List<String> fruits;

  Skewer(this.bowlNumbers, this.fruits);

  bool get isEmpty => bowlNumbers.isEmpty;
  bool get isNotEmpty => bowlNumbers.isNotEmpty;

  //removes overlapping sections of skewer and returns overlapping skewer (empty lists if nothing is overlapping)
  Skewer cutOverlap(Skewer skewer) {
    List<int> overlapBowlNumbers = [];
    List<String> overlapFruits = [];

    //do not cutOverlap the same skewer
    if (this == skewer) {
      return Skewer(overlapBowlNumbers, overlapFruits);
    }
    //add overlap
    for (int i = 0; i < bowlNumbers.length; i++) {
      for (int j = 0; j < skewer.bowlNumbers.length; j++) {
        if (bowlNumbers[i] == skewer.bowlNumbers[j]) {
          overlapBowlNumbers.add(bowlNumbers[i]);
        }
        if (fruits[i] == skewer.fruits[j]) {
          overlapFruits.add(fruits[i]);
        }
      }
    }
    //remove overlapping elements
    skewer.bowlNumbers.removeWhere((element) {
      return overlapBowlNumbers.contains(element);
    });
    skewer.fruits.removeWhere((element) {
      return overlapFruits.contains(element);
    });

    bowlNumbers.removeWhere((element) {
      return overlapBowlNumbers.contains(element);
    });
    fruits.removeWhere((element) {
      return overlapFruits.contains(element);
    });

    return Skewer(overlapBowlNumbers, overlapFruits);
  }

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
    //create skewers
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

    //TODO handle if wanted fruit is not in map or cannot be solved
    Map<String, int> solution = assignFruitForBowl(skewers);
  }
}

Map<String, int> assignFruitForBowl(List<Skewer> skewers) {
  Map<String, int> fruitForBowl = {};
  reduce(skewers);
  print("\n");
  print(skewers);
  return fruitForBowl;
}

List<Skewer> reduce(List<Skewer> skewers) {
  for (int i = 0; i < skewers.length; i++) {
    //j = i everything < i has already been checked for overlapping parts
    for (int j = i; j < skewers.length; j++) {
      Skewer overlapSkewer = skewers[i].cutOverlap(skewers[j]);
      //remove empty skewer
      //if empty, the origin skewers cannot be empty
      if (overlapSkewer.isNotEmpty) {
        skewers.insert(i, overlapSkewer);
        //both skewers empty.
        //if overlapSkewer is placed after the second Skewer (i > j), check for the j position
        if (skewers[i + 1].isEmpty && skewers[i > j ? j : j + 1].isEmpty) {
          //|| skewers[j].isEmpty)
          skewers.removeAt(i + 1);
          skewers.removeAt(j);
          //TODO check
          j--;
        }
        //first skewer empty
        else if (skewers[i + 1].isEmpty) {
          skewers.removeAt(i + 1);
        }
        //second skewer empty
        //if overlapSkewer is placed after the second Skewer (i > j), check for the j position
        else if (skewers[i > j ? j : j + 1].isEmpty) {
          skewers.removeAt(i > j ? j : j + 1);
        }
        //no skewer empty, no action required
      }
    }
  }
  return skewers;
}

List<String> extractFruitsFrom(String text) {
  List<String> fruits = text.split(" ");
  fruits.removeWhere((element) => element.isEmpty); //remove empty lines
  return fruits;
}
