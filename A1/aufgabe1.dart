import 'dart:io';

class Booth {
  Booth(this.id, this.start, this.end, this.width, {int value = 1})
      : this.height = end - start,
        this.hourRevenue = value * width,
        this.revenue = value * (end - start) * width;
  final int id;
  final int start;
  final int end;

  final int height;
  final int width; //length in meter
  final int hourRevenue; //price booth owner is willing to pay per hour
  final int revenue; //price booth owner is willing to pay

  @override
  String toString() {
    return "Booth$id($start to $end width:$width worth:$revenue";
  }
}

//global variable to measure revenue
int revenue = 0;

void main() async {
  List<String> filenames = [
    "flohmarkt0.txt",
    "flohmarkt1.txt",
    "flohmarkt2.txt",
    "flohmarkt3.txt",
    "flohmarkt4.txt",
    "flohmarkt5.txt",
    "flohmarkt6.txt",
    "flohmarkt7.txt",
  ];

  for (String filename in filenames) {
    File file = await File("beispiele\\$filename");
    //readAsLines to also handle CR LF endings
    List<String> lines = await file.readAsLines();
    lines.removeWhere((element) => element.isEmpty); //remove empty lines
    List<Booth> booths = boothsFromLines(lines.sublist(1));

    //properties of the market
    const start = 8;
    const end = 18;
    const width = 1000;

    var solution = solve(start, end, width, booths);
    writeSolutionToFile(filename, solution, revenue);
    revenue = 0;
  }
}

//using knapsack problem
List<List<int>> solve(int start, int end, int width, List<Booth> booths) {
  int height = end - start;
  //sorted booths according to the starting hour
  List<List<Booth>> timeFrames =
      List.filled(height, null).map((e) => <Booth>[]).toList();
  //sorted booths according to the ending hour
  List<List<Booth>> reversedTimeFrames =
      List.filled(height, null).map((e) => <Booth>[]).toList();

  for (int timeFrame = start, i = 0; timeFrame < end; timeFrame++, i++) {
    for (var booth in booths) {
      //sort the booths according to the starting hour
      if (booth.start == timeFrame) {
        timeFrames[i].add(booth);
      }
    }
  }

  for (int timeFrame = end, i = 0; timeFrame > start; timeFrame--, i++) {
    for (var booth in booths) {
      //sort the booths according to the ending hour
      if (booth.end == timeFrame) {
        reversedTimeFrames[i].add(booth);
      }
    }
  }

  //check for most profitable solution
  List<List<int>> topDownSolution = topDown(timeFrames, height, width);
  int topDownRevenue = revenue;
  revenue = 0;
  List<List<int>> bottomUpSolution =
      bottomUp(reversedTimeFrames, height, width);
  int bottomUpRevenue = revenue;

  if (topDownRevenue >= bottomUpRevenue) {
    revenue = topDownRevenue;
    return topDownSolution;
  } else {
    return bottomUpSolution;
  }
}

//solve problem with a top down approach
List<List<int>> topDown(List<List<Booth>> timeFrames, int height, int width) {
  if (timeFrames.length != height) throw "invalid input";

  List<List<int>> solution =
      List.filled(height, null).map((e) => List.filled(width, 0)).toList();

  //sort timeFrames by width so bigger blocks get placed first
  timeFrames.forEach((element) {
    element.sort((a, b) => b.width.compareTo(a.width));
  });

  //first line is the first hour
  for (int line = 0; line < solution.length; line++) {
    fillLine(line, solution, timeFrames[line]);
  }

  return solution;
}

//solve problem with a bottom up approach
List<List<int>> bottomUp(List<List<Booth>> timeFrames, int height, int width) {
  if (timeFrames.length != height) throw "invalid input";

  //from last to first hour
  List<List<int>> solution =
      List.filled(height, null).map((e) => List.filled(width, 0)).toList();

  //sort timeFrames by width so bigger blocks get placed first
  timeFrames.forEach((element) {
    element.sort((a, b) => b.width.compareTo(a.width));
  });

  //first line is last hour
  for (int line = 0; line < solution.length; line++) {
    fillLine(line, solution, timeFrames[line]);
  }

  //correct ordered solution
  List<List<int>> flippedSolution = [];
  for (int i = solution.length - 1; i >= 0; i--) {
    flippedSolution.add(solution[i]);
  }

  return flippedSolution;
}

void fillLine(int lineNumber, List<List<int>> bin, List<Booth> booths) {
  List<int> line = bin[lineNumber];
  //figure out how much space is available
  int start = -1;
  for (int index = 0; index < line.length; index++) {
    int currentFill = line[index];
    //space is free and start has not been assigned yet
    if (start < 0 && currentFill == 0) {
      start = index;
    }

    //start has been assigned and space is ending
    if (start > -1 && (index + 1 == line.length || line[index + 1] != 0)) {
      int end = index;
      int space = end - start + 1;
      //booths that best fit the available space
      List<Booth> toFill = knapsack(booths, space);
      //sort booths by their height
      if (index < 500) {
        //from large to small
        toFill.sort((a, b) => b.height.compareTo(a.height));
      } else {
        //from small to large
        toFill.sort((a, b) => a.height.compareTo(b.height));
      }
      //remove best fit booths
      booths.removeWhere((elementBooth) =>
          toFill.any((elementBestFit) => elementBooth.id == elementBestFit.id));

      //fill bin with booths
      for (var booth in toFill) {
        for (int i = lineNumber; i < (booth.height + lineNumber); i++) {
          bin[i].fillRange(start, start + booth.width, booth.id);
        }
        start += booth.width;
        //increase revenue for market
        revenue += booth.revenue;
      }
      start = -1;
    }
  }
}

//idea taken from https://github.com/williamfiset/Algorithms/blob/master/src/main/java/com/williamfiset/algorithms/dp/Knapsack_01.java
//solving knapsack with tabulation, ignoring height of booth O(n(booths)*c)
List<Booth> knapsack(List<Booth> booths, int capacity) {
  if (capacity == 0 || booths.isEmpty) {
    return [];
  }

  final int nItems = booths.length;

  // table where individual rows represent items
  // and columns represent the weight of the knapsack
  List<List<int>> table =
      List.generate(nItems + 1, (index) => List.filled(capacity + 1, 0));

  for (int i = 1; i <= nItems; i++) {
    Booth booth = booths[i - 1];
    int weight = booth.width, value = booth.hourRevenue;

    for (int sz = 1; sz <= capacity; sz++) {
      // Consider not picking this element
      table[i][sz] = table[i - 1][sz];
      // Consider including the current element and
      // see if this would be more profitable
      if (sz >= weight && table[i - 1][sz - weight] + value > table[i][sz]) {
        table[i][sz] = table[i - 1][sz - weight] + value;
      }
    }
  }

  int sz = capacity;
  List<Booth> boothsSelected = [];

  // Using the information inside the table we can backtrack and determine
  // which items were selected during the dynamic programming phase. The idea
  // is that if table[i][sz] != table[i-1][sz] then the item was selected
  for (int i = nItems; i > 0; i--) {
    if (table[i][sz] != table[i - 1][sz]) {
      Booth booth = booths[i - 1];
      boothsSelected.add(booth);
      sz -= booth.width;
    }
  }
  return boothsSelected;
}

List<Booth> boothsFromLines(List<String> lines) {
  List<Booth> booths = [];
  for (int i = 0; i < lines.length; i++) {
    var line = lines[i];
    var values = line.split(" ");
    int id = i + 2;
    int start = int.parse(values[0]);
    int end = int.parse(values[1]);
    int width = int.parse(values[2]);

    //value is specified
    if (values.length > 3) {
      int value = int.parse(values[3]);
      if (value <= 0) throw "Cost should not be less than 1";
      booths.add(Booth(id, start, end, width, value: value));
    } else {
      booths.add(Booth(id, start, end, width));
    }
  }
  return booths;
}

void writeSolutionToFile(
    String problemName, List<List<int>> solution, int profit) async {
  String name = problemName[0].toUpperCase() +
      problemName.substring(1, problemName.indexOf("."));
  String path = "beispiele\\solution${name}.txt";

  bool exist = await File(path).exists();

  File file;
  if (exist) {
    file = await File(path);
    //clear previous content
    await file.writeAsString("");
  } else {
    file = await File(path).create();
  }

  String solutionString = "";

  solution.forEach((timeFrame) {
    timeFrame.forEach((element) {
      String append;
      if (element < 10) {
        append = "00$element";
      } else if (element < 100) {
        append = "0$element";
      } else {
        append = "$element";
      }
      solutionString += "$append ";
    });
    solutionString += "\n";
  });

  await file.writeAsString(
      "Solution for $problemName with the profit: $profit, is:\n");
  await file.writeAsString(solutionString, mode: FileMode.append);
}
