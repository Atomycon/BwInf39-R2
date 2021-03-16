import 'dart:io';
import 'dart:math' as Math;

void main() async {
  List<String> filenames = [
    "eisbuden1.txt",
    "eisbuden2.txt",
    "eisbuden3.txt",
    /*"eisbuden4.txt",
    "eisbuden5.txt",
    "eisbuden6.txt",
    "eisbuden7.txt",*/
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

    var solution = solve(houses, circumference);
    print("Solution for $filename: $solution");
  }
}

List<int> solve(List<int> houses, int circumference) {
  return bruteForce(houses, circumference);
}

List<int> bruteForce(List<int> houses, int circumference) {
  int shortestPath = circumference * houses.length;
  List<List<int>> shortestPathLocations = [];

  List<Map<int, int>> solution = [];
  List<Map<int, int>> scenarios = [];

  for (int i = 0; i < circumference; i++) {
    for (int j = i; j < circumference; j++) {
      for (int k = j; k < circumference; k++) {
        List<int> location = [i, j, k];
        Map<int, int> houseDistanceToLocation =
            mapDistanceToLocation(location, houses, circumference);

        //assign shortestPath
        int pathLengths = 0;
        List<int> values = houseDistanceToLocation.values.toList();
        for (var value in values) {
          pathLengths += value;
        }
        if (pathLengths < shortestPath) {
          shortestPath = pathLengths;
          shortestPathLocations = [location];
        } else if (pathLengths == shortestPath) {
          shortestPathLocations.add(location);
        }

        //add location
        for (int i = 1; i <= location.length; i++) {
          houseDistanceToLocation.putIfAbsent(-i, () => location[i - 1]);
        }

        scenarios.add(houseDistanceToLocation);
      }
    }
  }

  print("$shortestPath with $shortestPathLocations");

  int majority = (houses.length / 2).round();

  loop:
  for (int i = 0; i < scenarios.length; i++) {
    Map<int, int> scenario = scenarios[i];

    for (int j = 0; j < scenarios.length; j++) {
      if (i == j) continue;
      Map<int, int> testingScenario = scenarios[j];
      int voteCount = 0;
      for (var house in houses) {
        int currentDistance = scenario[house] ?? -1;
        int tempDistance = testingScenario[house] ?? -1;

        if (currentDistance > tempDistance) {
          voteCount++;
        }
      }
      if (voteCount >= majority) continue loop;
    }
    solution.add(scenario);
  }

  print(solution);
  return [];
}

Map<int, int> mapDistanceToLocation(
    List<int> locations, List<int> houses, int circumference) {
  Map<int, int> distanceToLocation = {};

  for (var house in houses) {
    int minDistance = circumference;
    for (var location in locations) {
      minDistance = Math.min(
          minDistance, distanceBetween(house, location, circumference));
    }

    distanceToLocation.putIfAbsent(house, () => minDistance);
  }
  return distanceToLocation;
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
    if (to != from &&
        (distance <= initDistance ? distance : initDistance) == 0) {
      print("Something wrong here I can feel it");
    }
    return distance <= initDistance ? distance : initDistance;
  }

  //check for the other direction
  return distanceBetween(to, from, circumference, initDistance: distance);
}
