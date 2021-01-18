import 'dart:io';

class Booth {
  Booth(this.id, this.start, this.end, this.width, {this.value = 1});
  final int id;
  final int start;
  final int end;
  final int width; //length in meter
  final int value; //price booth owner is willing to pay per meter

  @override
  String toString() {
    return "Booth($id, $start, $end, $width, $value";
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
      if (booth.start <= timeFrame && timeFrame < booth.end) {
        timeFrames[i].add(booth);
      }
    }
  }

  print(timeFrames);
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
      booths.add(Booth(i, start, end, width, value: value));
    } else {
      booths.add(Booth(i, start, end, width));
    }
  }
  return booths;
}
