import '../controller/sqllite_db.dart';


class BmiCalculator {

  static const String SQLiteTable = "bmi";

  String username;
  double weight;
  double height;
  String gender;
  String bmi_status;


  BmiCalculator (this.username, this.weight, this.height, this.gender, this.bmi_status);


  BmiCalculator.fromJson(Map<String, dynamic> json)
      : username = json['_colUsername'] as String,
        weight = double.parse(json['_colWeight'].toString()),
        height = double.parse(json['_colHeight'].toString()),
        gender = json['_colGender'] as String,
        bmi_status = json['_colStatus'] as String;


  // toJson will be automatically called by jsonEncode when necessary
  Map<String, dynamic> toJson() =>
      {'_colUsername': username,
        '_colWeight': weight,
        '_colHeight': height,
        '_colGender': gender,
        '_colStatus': bmi_status,
      };


  Future<bool> save() async {


    // Save to local SQLite
    await SQLiteDB().insert(SQLiteTable, toJson());
    // returning true always for local save
    return true;


  }

  static Future<List<BmiCalculator>> loadAll() async {
    // Local SQLite
    List<Map<String, dynamic>> localResult = await SQLiteDB().queryAll(SQLiteTable);


    // Convert SQLite data to BmiCalc objects
    List<BmiCalculator> result = localResult.map((item) => BmiCalculator.fromJson(item)).toList();


    return result;
  }


}
