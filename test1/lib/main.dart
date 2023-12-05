import 'package:flutter/material.dart';

import 'model/bmicalculator.dart';


void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});


  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {


  final TextEditingController nameController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController bmiController = TextEditingController();
  final TextEditingController heightController = TextEditingController();


  double bmi = 0;
  String status = '';
  String? gender;
  int femaleCount = 0;
  int maleCount = 0;
  double femaleBmiSum = 0;
  double maleBmiSum = 0;



  Future<void> displaySavedData() async {
    List<BmiCalculator> savedData = await BmiCalculator.loadAll();
    if (savedData.isNotEmpty) {
      // Assuming you want to display the last saved item, you can modify this part as needed
      BmiCalculator lastSavedItem = savedData.last;
      setState(() {
        nameController.text = lastSavedItem.username;
        heightController.text = lastSavedItem.height.toString();
        weightController.text = lastSavedItem.weight.toString();
        bmiController.text = lastSavedItem.bmi_status;
        gender = lastSavedItem.gender;
        // Update status when gender changes
        updateStatus();


        // Count and display the total for each gender
        countAndDisplayGenderTotals(savedData);
      });
    }
  }


  void countAndDisplayGenderTotals(List<BmiCalculator> savedData) {
    // Reset counts and sums
    maleCount = 0;
    femaleCount = 0;
    maleBmiSum = 0;
    femaleBmiSum = 0;


    // Count records for each gender and calculate sum of BMI
    for (var item in savedData) {
      if (item.gender == 'Male') {
        maleCount++;
        maleBmiSum += double.parse(item.bmi_status);
      } else if (item.gender == 'Female') {
        femaleCount++;
        femaleBmiSum += double.parse(item.bmi_status);
      }
    }
  }


  @override
  void initState() {
    super.initState();
    // Wait for the widgets to be initialized before loading saved data
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      displaySavedData();
    });
  }


  void calculateBMI() {
    double height = double.parse(heightController.text);
    double weight = double.parse(weightController.text);


    if (height > 0 && weight > 0) {
      double heightInMeters = height / 100;
      bmi = weight / (heightInMeters * heightInMeters);


      setState(() {
        bmiController.text = bmi.toStringAsFixed(2);
        updateStatus();
        // Save data when BMI is calculated
        saveData();
        // Display saved data after saving
        displaySavedData();
      });
    }
  }


  void saveData() async {
    // Save to local SQLite
    await BmiCalculator(
      nameController.text,
      double.parse(weightController.text),
      double.parse(heightController.text),
      gender!,
      bmi.toStringAsFixed(2), // Save BMI as a formatted string
    ).save();
  }


  void updateStatus() {


    if (gender == 'Male') {
      if (bmi < 18.5) {
        status = 'Underweight. Careful during strong wind!';
      } else if (bmi < 25) {
        status = 'That’s ideal! Please maintain.';
      } else if (bmi < 30) {
        status = 'Overweight! Work out please.';
      } else {
        status = 'Whoa Obese! Dangerous mate!';
      }
    } else {
      if (bmi < 16) {
        status = 'Underweight. Careful during strong wind!';
      } else if (bmi < 22) {
        status = 'That’s ideal! Please maintain.';
      } else if (bmi < 27) {
        status = 'Overweight! Work out please.';
      } else {
        status = 'Whoa Obese! Dangerous mate!';
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("BMI Calculator",
            style: TextStyle(color: Colors.white, fontSize: 32)),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Your Fullname',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: heightController,
                decoration: InputDecoration(
                  labelText: 'Height in cm; 170',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: weightController,
                decoration: InputDecoration(
                  labelText: 'Weight in KG',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: bmiController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'BMI Value',
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Male'),
                    leading: Radio(
                      value: 'Male',
                      groupValue: gender,
                      onChanged: (value) {
                        setState(() {
                          gender = value as String?;
                        });
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('Female'),
                    leading: Radio(
                      value: 'Female',
                      groupValue: gender,
                      onChanged: (value) {
                        setState(() {
                          gender = value as String?;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            // Display the status along with the gender
            ElevatedButton(
              onPressed: () {
                calculateBMI();
              },
              child: Text('Calculate BMI and Save'),
            ),
            Center(
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),


            // Display counts and averages
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Female Count: $femaleCount',
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                  SizedBox(height: 9),


                  // Row 2: Female Count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Male Count: $maleCount',
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                  SizedBox(height: 9),


                  // Row 3: Average Male BMI
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Average of Female BMI: ${femaleCount > 0 ? (femaleBmiSum / femaleCount).toStringAsFixed(2) : ''}',
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),


                  // Row 4: Average Female BMI
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Average of Male BMI: ${maleCount > 0 ? (maleBmiSum / maleCount).toStringAsFixed(2) : ''}',
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
