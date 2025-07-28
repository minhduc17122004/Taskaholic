import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({Key? key}) : super(key: key);

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String _authStatus = 'Đang kiểm tra...';
  String _firestoreStatus = 'Đang kiểm tra...';
  List<String> _logs = [];
  
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
    _checkFirestoreConnection();
  }
  
  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)}: $message');
    });
  }
  
  Future<void> _checkAuthStatus() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        setState(() {
          _authStatus = 'Đã đăng nhập: ${user.email} (${user.uid})';
        });
        _addLog('Đã đăng nhập với email: ${user.email}');
      } else {
        setState(() {
          _authStatus = 'Chưa đăng nhập';
        });
        _addLog('Chưa đăng nhập');
      }
    } catch (e) {
      setState(() {
        _authStatus = 'Lỗi: $e';
      });
      _addLog('Lỗi kiểm tra đăng nhập: $e');
    }
  }
  
  Future<void> _checkFirestoreConnection() async {
    try {
      setState(() {
        _firestoreStatus = 'Đang kết nối...';
      });
      
      // Thử tạo một document tạm thời để kiểm tra kết nối
      final docRef = _firestore.collection('debug').doc('connection_test');
      await docRef.set({
        'timestamp': FieldValue.serverTimestamp(),
        'test': 'Connection test',
      });
      
      // Đọc lại document vừa tạo
      final docSnapshot = await docRef.get();
      
      if (docSnapshot.exists) {
        setState(() {
          _firestoreStatus = 'Kết nối thành công! Data: ${docSnapshot.data()}';
        });
        _addLog('Kết nối Firestore thành công');
      } else {
        setState(() {
          _firestoreStatus = 'Kết nối thành công nhưng không đọc được dữ liệu';
        });
        _addLog('Kết nối Firestore thành công nhưng không đọc được dữ liệu');
      }
    } catch (e) {
      setState(() {
        _firestoreStatus = 'Lỗi kết nối: $e';
      });
      _addLog('Lỗi kết nối Firestore: $e');
    }
  }
  
  Future<void> _testAddTask() async {
    try {
      _addLog('Đang thêm task test...');
      
      final user = _auth.currentUser;
      if (user == null) {
        _addLog('Không thể thêm task: Chưa đăng nhập');
        return;
      }
      
      // Thêm một task test
      final docRef = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .add({
            'id': 'test_${DateTime.now().millisecondsSinceEpoch}',
            'title': 'Test task ${DateTime.now().toString().substring(11, 19)}',
            'date': DateTime.now().toIso8601String(),
            'time': '0:0',
            'repeat': 'Không lặp lại',
            'list': 'Mặc định',
            'originalList': 'Mặc định',
            'isCompleted': false,
          });
      
      _addLog('Đã thêm task test với ID: ${docRef.id}');
      
      // Đọc lại task vừa thêm
      final taskSnapshot = await docRef.get();
      if (taskSnapshot.exists) {
        _addLog('Xác nhận task đã được thêm: ${taskSnapshot.data()}');
      } else {
        _addLog('Không thể xác nhận task đã được thêm');
      }
    } catch (e) {
      _addLog('Lỗi khi thêm task test: $e');
    }
  }
  
  Future<void> _listTasks() async {
    try {
      _addLog('Đang lấy danh sách tasks...');
      
      final user = _auth.currentUser;
      if (user == null) {
        _addLog('Không thể lấy tasks: Chưa đăng nhập');
        return;
      }
      
      // Lấy danh sách tasks
      final querySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .get();
      
      _addLog('Đã lấy ${querySnapshot.docs.length} tasks:');
      
      for (var doc in querySnapshot.docs) {
        _addLog('- ${doc.data()['title']} (ID: ${doc.id})');
      }
    } catch (e) {
      _addLog('Lỗi khi lấy danh sách tasks: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 1, 45, 81),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 115, 182),
        title: const Text('Debug Firestore'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Firebase Auth Status
            const Text(
              'Firebase Auth Status:',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(top: 8, bottom: 16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 1, 63, 113),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _authStatus,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            
            // Firestore Status
            const Text(
              'Firestore Status:',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(top: 8, bottom: 16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 1, 63, 113),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _firestoreStatus,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            
            // Action Buttons
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _checkAuthStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 1, 115, 182),
                  ),
                  child: const Text('Kiểm tra Auth'),
                ),
                ElevatedButton(
                  onPressed: _checkFirestoreConnection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 1, 115, 182),
                  ),
                  child: const Text('Kiểm tra Firestore'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _testAddTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 1, 115, 182),
                  ),
                  child: const Text('Thêm Task Test'),
                ),
                ElevatedButton(
                  onPressed: _listTasks,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 1, 115, 182),
                  ),
                  child: const Text('Liệt kê Tasks'),
                ),
              ],
            ),
            
            // Logs
            const SizedBox(height: 24),
            const Text(
              'Logs:',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Container(
              width: double.infinity,
              height: 300,
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 1, 63, 113),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _logs.map((log) => Text(
                    log,
                    style: const TextStyle(color: Colors.white),
                  )).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 