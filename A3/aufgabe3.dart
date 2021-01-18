import 'dart:io';

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

    List<int> housePos =
        List.generate(numHouses, (index) => int.parse(houseText[index]));

    var solution = solve(circumference, housePos);
    print("Solution for $filename: $solution");
  }
}

List<int> solve(circumference, housePos) {
  List<int> icePos = [];
  shortestMajority(circumference, housePos);
  return icePos;
}

//returns the shortest path to block a vote (n/2 if n%2=0 or n/2+1 if n%=1), both values inclusive
List<List<int>> shortestMajority(int circumference, List<int> housePos) {
  int numMajority = ((housePos.length) / 2).round();

  //init with max length
  int shortestPath = circumference;
  List<List<int>> shortestMajority = [];

  for (int pos = 0; pos < housePos.length; pos++) {
    int endPos = pos + numMajority - 1;

    int distance = 0;

    //prevent index out of range
    if (endPos >= housePos.length) {
      //base refers to 0
      int distanceToBase = circumference - housePos[pos];
      //overriding endpos
      endPos = endPos - housePos.length;
      int distanceFromBase = housePos[endPos];
      distance = distanceToBase + distanceFromBase;
    } else {
      distance = housePos[endPos] - housePos[pos];
    }
    if (distance < shortestPath) {
      shortestPath = distance;
      shortestMajority = [
        [pos, endPos]
      ];
    } else if (distance == shortestPath) {
      shortestMajority.add([pos, endPos]);
    }
    //print(distance);
  }
  print(shortestMajority);
  return [];
}
