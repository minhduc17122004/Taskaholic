import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../presentation/bloc/task/task_bloc.dart';
import '../presentation/bloc/task/task_event.dart';
import '../presentation/bloc/task/task_state.dart';
import '../services/notification_service.dart';

class NotificationsBottomSheet extends StatefulWidget {
  const NotificationsBottomSheet({super.key});

  @override
  State<NotificationsBottomSheet> createState() => _NotificationsBottomSheetState();
}

class _NotificationsBottomSheetState extends State<NotificationsBottomSheet> {
  bool _notificationsEnabled = true;
  
  @override
  void initState() {
    super.initState();
    _checkNotificationStatus();
  }
  
  Future<void> _checkNotificationStatus() async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    setState(() {
      _notificationsEnabled = settings.authorizationStatus == AuthorizationStatus.authorized;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Thông báo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text(
              'Bật thông báo',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              _notificationsEnabled
                  ? 'Bạn sẽ nhận được thông báo khi công việc đến hạn'
                  : 'Bạn sẽ không nhận được thông báo',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            value: _notificationsEnabled,
            activeColor: const Color.fromARGB(255, 1, 115, 182),
            onChanged: (value) async {
              if (value) {
                await NotificationService().requestNotificationPermissions();
                await _checkNotificationStatus();
              } else {
                // Hiển thị dialog hướng dẫn tắt thông báo trong cài đặt
                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: const Color.fromARGB(255, 1, 63, 113),
                      title: const Text(
                        'Tắt thông báo',
                        style: TextStyle(color: Colors.white),
                      ),
                      content: const Text(
                        'Để tắt thông báo, vui lòng vào Cài đặt > Ứng dụng > Todo List > Thông báo',
                        style: TextStyle(color: Colors.white70),
                      ),
                      actions: [
                        TextButton(
                          child: const Text(
                            'Đóng',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Công việc sắp đến hạn',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          BlocBuilder<TaskBloc, TaskState>(
            builder: (context, state) {
              if (state is TasksLoaded) {
                // Lọc các công việc sắp đến hạn (trong vòng 24 giờ)
                final now = DateTime.now();
                final upcomingTasks = state.tasks.where((task) {
                  if (!task.hasTime) return false;
                  
                  final taskTime = DateTime(
                    task.date.year,
                    task.date.month,
                    task.date.day,
                    task.time.hour,
                    task.time.minute,
                  );
                  
                  final difference = taskTime.difference(now);
                  return difference.inHours >= 0 && difference.inHours <= 24;
                }).toList();
                
                if (upcomingTasks.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'Không có công việc nào sắp đến hạn',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  );
                }
                
                return Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: upcomingTasks.length,
                    itemBuilder: (context, index) {
                      final task = upcomingTasks[index];
                      final taskTime = DateTime(
                        task.date.year,
                        task.date.month,
                        task.date.day,
                        task.time.hour,
                        task.time.minute,
                      );
                      
                      final difference = taskTime.difference(now);
                      final hours = difference.inHours;
                      final minutes = difference.inMinutes % 60;
                      
                      String timeLeft;
                      if (hours > 0) {
                        timeLeft = '$hours giờ ${minutes > 0 ? '$minutes phút' : ''}';
                      } else {
                        timeLeft = '$minutes phút';
                      }
                      
                      return ListTile(
                        title: Text(
                          task.title,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          'Còn lại: $timeLeft',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        leading: const Icon(
                          Icons.access_time,
                          color: Colors.orangeAccent,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.notifications_active, color: Colors.white),
                          onPressed: () {
                            // Hủy thông báo cho task này
                            NotificationService().cancelNotification(int.parse(task.id));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã tắt thông báo cho công việc này'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              }
              
              return const Center(
                child: CircularProgressIndicator(
                  color: Color.fromARGB(255, 1, 115, 182),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 1, 115, 182),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                // Tải lại tất cả thông báo
                context.read<TaskBloc>().add(const LoadTasks(forceRefresh: true));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã làm mới thông báo'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Làm mới thông báo'),
            ),
          ),
        ],
      ),
    );
  }
} 