import 'dart:io';

class Booth {
  Booth(this.id, this.start, this.end, this.width, {int value = 1})
      : this.height = end - start,
        this.price = value * (end - start) * width;
  final int id;
  final int start;
  final int end;

  final int height;
  final int width; //length in meter
  final int price; //price booth owner is willing to pay

  @override
  String toString() {
    return "Booth$id($start to $end width:$width worth:$price";
  }
}

void main() async {
  List<String> filenames = [
    /*"flohmarkt1.txt",
    "flohmarkt2.txt",
    "flohmarkt3.txt",*/
    "flohmarkt4.txt",
    /*"flohmarkt5.txt",
    "flohmarkt6.txt",
    "flohmarkt7.txt",*/
  ];

  for (String filename in filenames) {
    File file =
        await File("A1\\beispiele\\$filename"); //TODO beispiele\\$filename
    //readAsLines to also handle CR LF endings
    List<String> lines = await file.readAsLines();
    lines.removeWhere((element) => element.isEmpty); //remove empty lines
    int boothCount = int.parse(lines[0]);
    List<Booth> booths = boothsFromLines(lines.sublist(1));

    //Properties of the flea market
    const start = 8;
    const end = 18;
    const width = 1000;

    solve(start, end, width, booths);
  }
}

//using knapsack problem/rectangle packing problem
void solve(int start, int end, int width, List<Booth> booths) {
  //Booth that one a stand by hour
  List<List<Booth>> timeFrames =
      List.filled(end - start, null).map((e) => <Booth>[]).toList();

  //timeframe: from timeframe to timeframe + 1
  for (int timeFrame = start, i = 0; timeFrame < end; timeFrame++, i++) {
    for (var booth in booths) {
      //Booth wants to have stand in timeframe
      if (booth.start == timeFrame) {
        timeFrames[i].add(booth);
      }
    }
  }

  print(topDown(timeFrames, 10, 1000));
}

List<Booth> boothsFromLines(List<String> lines) {
  List<Booth> booths = [];
  for (int i = 0; i < lines.length; i++) {
    var line = lines[i];
    var values = line.split(" ");
    int start = int.parse(values[0]);
    int end = int.parse(values[1]);
    int width = int.parse(values[2]);

    //value is specified
    if (values.length > 3) {
      int value = int.parse(values[3]);
      booths.add(Booth(i + 1, start, end, width, value: value));
    } else {
      booths.add(Booth(i + 1, start, end, width));
    }
  }
  return booths;
}

//fill market top down
List<List<int>> topDown(List<List<Booth>> timeFrames, int height, int width) {
  List<List<int>> solution =
      List.filled(height, null).map((e) => [width]).toList();

  if (timeFrames.length != height) throw "invalid input";

  //for each layer
  for (int i = 0; i < timeFrames.length; i++) {
    List<Booth> timeFrame = timeFrames[i];
    //fill out empty spots
    int start = -1;
    for (int j = 0; j < width; j++) {
      int currentFill = solution[i][j];
      if (start == -1 && currentFill == 0) {
        start = j;
      } else if (start > -1 && (currentFill != 0 || j + 1 == width)) {
        List<Booth> toFill = knapsack(timeFrame, j - start + 1);
        //TODO verify
        toFill.sort((a, b) => a.height.compareTo(b.height));
        for (var booth in toFill) {
          for (int layer = i; i < booth.height; i++) {
            solution[layer].fillRange(start, start + booth.width, booth.id);
          }
          start += booth.width;
          timeFrame.removeWhere((element) => booth.id == element.id);
        }
        start = -1;
      }
    }
  }

  return solution;
}

//taken from https://github.com/williamfiset/Algorithms/blob/master/src/main/java/com/williamfiset/algorithms/dp/Knapsack_01.java
//solving knapsack with tabulation, ignoring height of booth
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
    int weight = booth.width, value = (booth.price / booth.height).round();

    for (int sz = 1; sz <= capacity; sz++) {
      // Consider not picking this element
      table[i][sz] = table[i - 1][sz];
      // Consider including the current element and
      // see if this would be more profitable
      if (sz >= weight && table[i - 1][sz - weight] + value > table[i][sz])
        table[i][sz] = table[i - 1][sz - weight] + value;
    }
  }

  int sz = capacity;
  List<Booth> boothsSelected = [];

  // Using the information inside the table we can backtrack and determine
  // which items were selected during the dynamic programming phase. The idea
  // is that if DP[i][sz] != DP[i-1][sz] then the item was selected
  for (int i = nItems; i > 0; i--) {
    if (table[i][sz] != table[i - 1][sz]) {
      Booth booth = booths[i - 1];
      boothsSelected.add(booth);
      sz -= (booth.price / booth.height).round();
    }
  }
  return boothsSelected;
}
