import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:in_and_ex/screen/signin_screen.dart'; 
import 'package:in_and_ex/screen/signup_screen.dart';
import 'package:intl/intl.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // Initialize Firebase for Web
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyB4awOE1oNXPgCQAZMgms5bXqVbT-n_kOA",
        authDomain: "in-and-ex-2b8d0.firebaseapp.com",
        projectId: "in-and-ex-2b8d0",
        storageBucket: "in-and-ex-2b8d0.appspot.com",
        messagingSenderId: "300735211217",
        appId: "1:300735211217:web:263a2da6b1bd290de2c7f0"
      ),
    );
  } else {
    // Initialize Firebase for Android or iOS
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Income and Expense Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Start with SigninScreen
      home: SigninScreen(), 
      routes: {
        '/signin': (context) => SigninScreen(),
        '/signup': (context) => SignupScreen(),
        // Add other routes here if necessary
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final CollectionReference _recordsCollection = FirebaseFirestore.instance.collection('records');
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String? _type; // 'income' or 'expense'
  DateTime _selectedDate = DateTime.now();

  double _totalIncome = 0;
  double _totalExpense = 0;

  // ฟังก์ชันเพิ่มรายการ
  void _addRecord() async {
    if (_amountController.text.isNotEmpty && _type != null) {
      try {
        await _recordsCollection.add({
          'amount': double.parse(_amountController.text),
          'date': _selectedDate,
          'type': _type,  // 'income' หรือ 'expense'
          'note': _noteController.text,
        });
        // ล้างค่าหลังจากบันทึก
        _amountController.clear();
        _noteController.clear();
        _type = null;
      } catch (e) {
        print("Error adding record: $e"); // แสดงข้อผิดพลาด
      }
    } else {
      print("Amount or type is missing."); // แจ้งว่าข้อมูลไม่เพียงพอ
    }
  }

  // ฟังก์ชันแสดง dialog เพื่อเพิ่มรายการ
  void _showAddRecordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Income/Expense"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(hintText: 'Enter amount'),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                value: _type,
                onChanged: (String? newValue) {
                  setState(() {
                    _type = newValue!;
                  });
                },
                items: ['income', 'expense'].map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                decoration: const InputDecoration(hintText: 'Select type'),
              ),
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(hintText: 'Enter note'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel")),
            TextButton(
              onPressed: () {
                _addRecord();
                Navigator.of(context).pop();
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  // ฟังก์ชันคำนวณยอดรวมรายรับ-รายจ่าย
  void _calculateTotals() {
    _recordsCollection.snapshots().listen(
      (snapshot) {
        double income = 0;
        double expense = 0;

        snapshot.docs.forEach((doc) {
          if (doc['type'] == 'income') {
            income += doc['amount'];
          } else if (doc['type'] == 'expense') {
            expense += doc['amount'];
          }
        });

        setState(() {
          _totalIncome = income;
          _totalExpense = expense;
        });
      },
      onError: (error) {
        print("Error listening to Firestore: $error");
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _calculateTotals();
  }

  // ส่วนที่แสดงยอดรวม
  Widget _buildTotalSummary() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text('Total Income: ${_totalIncome.toStringAsFixed(2)} Baht'),
          Text('Total Expense: ${_totalExpense.toStringAsFixed(2)} Baht'),
          Text('Balance: ${( _totalIncome - _totalExpense).toStringAsFixed(2)} Baht'),
        ],
      ),
    );
  }

  // ฟังก์ชันลงชื่อออก
  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/signin'); // Navigate to SigninScreen after sign-out
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('InAndEX',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 227, 138, 100),
            letterSpacing: 1.5,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 118, 231, 116),
        actions: [
          // Add Sign Out Button with Icon
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.signOutAlt), // FontAwesome Sign Out icon
            onPressed: _signOut, // Call sign-out function
            color: const Color.fromARGB(255, 227, 138, 100),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _buildTotalSummary(),
          Expanded(
            child: StreamBuilder(
              stream: _recordsCollection.snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    return ListTile(
                      title: Text('${doc['amount']} Baht (${doc['type']})'),
                      subtitle: Text('${doc['note']} - ${DateFormat('yyyy-MM-dd').format(doc['date'].toDate())}'), // ปรับวันที่
                      leading: Icon(
                        doc['type'] == 'income' ? Icons.arrow_downward : Icons.arrow_upward,
                        color: doc['type'] == 'income' ? Colors.green : Colors.red,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _recordsCollection.doc(doc.id).delete(),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddRecordDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
