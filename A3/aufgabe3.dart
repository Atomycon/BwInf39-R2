import 'dart:io';
import 'dart:math' as Math;

void main() async {
  List<String> filenames = [
    "eisbuden1.txt",
    "eisbuden2.txt",
    "eisbuden3.txt",
    "eisbuden4.txt",
    "eisbuden5.txt",
    "eisbuden6.txt",
    "eisbuden7.txt",
  ];

  for (String filename in filenames) {
    File file =
        await File("A3\\beispiele\\$filename"); //TODO beispiele\\$filename
    //readAsLines to also handle CR LF endings
    List<String> lines = await file.readAsLines();
    lines.removeWhere((element) => element.isEmpty); //remove empty lines

    List<String> data = lines[0].split(" ");
    int circumference = int.parse(data[0]);
    int numHouses = int.parse(data[1]);

    List<String> houseText = lines[1].split(" ");

    List<int> houses =
        List.generate(numHouses, (index) => int.parse(houseText[index]));

    var solution = solve(circumference, houses);
    print("Solution for $filename: $solution");
  }
}

List<int> solve(circumference, housePos) {
  List<int> icePos = [];
  List<List<int>> groups = shortestMajority(circumference, housePos);
  for (int i = 0; i < groups.length; i++) {
    print("For group: ${groups[i]}:");
    verifyLocation(groups[i], housePos, circumference);
  }
  return icePos;
}

void verifyLocation(List<int> locations, List<int> houses, int circumference) {
  Map<int, int> shortestDistanceToLocations = {};

  for (var house in houses) {
    var shortestPath = circumference;
    for (var location in locations) {
      shortestPath = Math.min(
          shortestPath, distanceBetween(house, location, circumference));
    }
    shortestDistanceToLocations.putIfAbsent(house, () => shortestPath);
  }
  for (int i = 0; i < circumference; i++) {
    int voteCount = 0;
    for (var house in houses) {
      int distance = shortestDistanceToLocations[house] ?? -1;
      if (distance == -1) {
        throw "null assigned for house distance";
      }
      if (distanceBetween(house, i, circumference) > distance) {
        voteCount++;
      }
    }
    if (voteCount > houses.length) {
      print("Majority vote of $voteCount for to move ice shop to $i");
    }
  }
}

/*
List<int> isolatedShortestMajority(int circumference, List<int> housePos) {

}*/

//returns the shortest path to block a vote (n/2 if n%2=0 or n/2+1 if n%=1), both values inclusive related to array pos
List<List<int>> shortestMajority(int circumference, List<int> houses) {
  //round up/down
  int numMajority = ((houses.length) / 2).round();

  //init with max length
  int shortestPath = circumference;
  List<List<int>> shortestMajority = [];

  for (int arrayPos = 0; arrayPos < numMajority; arrayPos++) {
    int arrayEndPos = arrayPos + numMajority - 1;
    int distance = 0;
    //prevent index out of range
    if (arrayEndPos >= houses.length) arrayEndPos = arrayEndPos - houses.length;

    distance =
        distanceBetween(houses[arrayPos], houses[arrayEndPos], circumference);

    if (distance < shortestPath) {
      shortestPath = distance;
      shortestMajority = [
        [houses[arrayPos], houses[arrayEndPos]]
      ];
    } else if (distance == shortestPath) {
      shortestMajority.add([houses[arrayPos], houses[arrayEndPos]]);
    }
  }
  print(shortestMajority);
  return shortestMajority;
}

//shortest distance between two points
int distanceBetween(int from, int to, int circumference,
    {int initDistance = -1}) {
  int distance = 0;

  //distance over base
  if (from > to) {
    int distanceToBase = circumference - from;
    int distanceFromBase = to;
    distance = distanceToBase + distanceFromBase;
  } else {
    distance = to - from;
  }

  if (initDistance >= 0) {
    return distance <= initDistance ? distance : initDistance;
  }

  //check for the other direction
  return distanceBetween(to, from, circumference, initDistance: distance);
}
