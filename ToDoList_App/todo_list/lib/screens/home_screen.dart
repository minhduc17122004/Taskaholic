import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../presentation/bloc/task/task_bloc.dart';
import '../presentation/bloc/task/task_event.dart';
import '../presentation/bloc/task/task_state.dart';
import '../domain/entities/task.dart';
import '../widgets/task_category.dart';
import '../widgets/task_search_delegate.dart';
import '../widgets/notifications_bottom_sheet.dart';
import '../widgets/completed_tasks_list.dart';
import '../data/lists_data.dart';
import 'add_task_screen.dart';
import 'debug_screen.dart';
import 'category_screen.dart';
import 'account_screen.dart';

import '../presentation/bloc/auth/auth_bloc.dart';
import '../presentation/bloc/auth/auth_event.dart';
import '../presentation/bloc/auth/auth_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  late TextEditingController _quickTaskController;
  String _currentList = 'Danh sách tất cả';
  int _currentIndex = 0;
  
  // Danh sách các màn hình
  final List<int> _screens = [0, 1, 2, 3]; // Chỉ lưu index thay vì widget
  
  @override
  bool get wantKeepAlive => true; // Giữ trạng thái của widget khi chuyển tab
  
  @override
  void initState() {
    super.initState();
    _quickTaskController = TextEditingController();
    
    // Tải danh sách công việc khi khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskBloc>().add(const LoadTasks(forceRefresh: true));
      
      // Kiểm tra thông tin đăng nhập
      final auth = FirebaseAuth.instance;
      final currentUser = auth.currentUser;
      
      if (currentUser != null) {
        developer.log('Người dùng đã đăng nhập: ${currentUser.uid}', name: 'HomeScreen');
        developer.log('Email: ${currentUser.email}', name: 'HomeScreen');
      } else {
        developer.log('Chưa đăng nhập!', name: 'HomeScreen');
        
        // Hiển thị thông báo chưa đăng nhập
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bạn chưa đăng nhập! Không thể lưu task lên Firestore.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    });
  }
  
  @override
  void dispose() {
    _quickTaskController.dispose();
    super.dispose();
  }

  // Widget cho màn hình Home
  Widget _buildHomeContent() {
    return BlocConsumer<TaskBloc, TaskState>(
      listener: (context, state) {
        if (state is TaskError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
          context.read<TaskBloc>().add(const LoadTasks(forceRefresh: true));
        }
      },
      builder: (context, state) {
        if (state is TaskLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color.fromARGB(255, 1, 115, 182),
            ),
          );
        } else if (state is TaskError) {
          return Center(
            child: Text(
              'Lỗi: ${state.message}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        } else if (state is TasksLoaded) {
          final List<Task> displayedTasks = state.getTasksByList(_currentList);
          final hasTasks = displayedTasks.isNotEmpty;
          final Map<String, List<Task>> tasksByCategory = state.getTasksByCategoryForList(_currentList);

          // Tạo danh sách các nhóm công việc theo danh mục
          final List<Widget> categoryWidgets = [];
          
          // Thêm danh mục "Quá hạn" nếu có
          if (tasksByCategory.containsKey('Quá hạn')) {
            categoryWidgets.add(
              _buildCategorySection(
                'Quá hạn',
                tasksByCategory['Quá hạn']!,
                Colors.redAccent,
              ),
            );
          }
          
          // Thêm danh mục "Hôm nay" nếu có
          if (tasksByCategory.containsKey('Hôm nay')) {
            categoryWidgets.add(
              _buildCategorySection(
                'Hôm nay',
                tasksByCategory['Hôm nay']!,
                Colors.orangeAccent,
              ),
            );
          }
          
          // Thêm danh mục "Ngày mai" nếu có
          if (tasksByCategory.containsKey('Ngày mai')) {
            categoryWidgets.add(
              _buildCategorySection(
                'Ngày mai',
                tasksByCategory['Ngày mai']!,
                Colors.blueAccent,
              ),
            );
          }
          
          // Thêm danh mục "Tuần này" nếu có
          if (tasksByCategory.containsKey('Tuần này')) {
            categoryWidgets.add(
              _buildCategorySection(
                'Tuần này',
                tasksByCategory['Tuần này']!,
                Colors.purpleAccent,
              ),
            );
          }
          
          // Thêm danh mục "Không có ngày" nếu có
          if (tasksByCategory.containsKey('Không có ngày')) {
            categoryWidgets.add(
              _buildCategorySection(
                'Không có ngày',
                tasksByCategory['Không có ngày']!,
                Colors.tealAccent,
              ),
            );
          }
          
          // Các danh mục khác
          for (final category in tasksByCategory.keys) {
            if (!['Quá hạn', 'Hôm nay', 'Ngày mai', 'Tuần này', 'Không có ngày'].contains(category)) {
              categoryWidgets.add(
                _buildCategorySection(
                  category,
                  tasksByCategory[category]!,
                  Colors.greenAccent,
                ),
              );
            }
          }

          return hasTasks
            ? Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color.fromARGB(255, 0, 45, 81),
                      const Color.fromARGB(255, 0, 30, 60),
                    ],
                  ),
                ),
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 100),
                  children: [
                    // Hiển thị số lượng công việc và ngày
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${displayedTasks.length} công việc',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getFormattedDate(),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 1, 115, 182).withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.calendar_today,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Danh sách công việc theo danh mục
                    ...categoryWidgets,
                  ],
                ),
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 1, 63, 113).withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_outline,
                        size: 80,
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Không có công việc nào',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Thêm công việc mới để bắt đầu',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              );
        } else {
          return const Center(
            child: Text(
              'Không có dữ liệu',
              style: TextStyle(color: Colors.white),
            ),
          );
        }
      },
    );
  }
  
  // Widget cho màn hình task đã hoàn thành
  Widget _buildCompletedTasksContent() {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is TaskLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color.fromARGB(255, 1, 115, 182),
            ),
          );
        } else if (state is TaskError) {
          return Center(
            child: Text(
              'Lỗi: ${state.message}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        } else if (state is TasksLoaded) {
          final List<Task> completedTasks = state.completedTasks;
          
          if (completedTasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 1, 63, 113).withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      size: 80,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Không có công việc đã hoàn thành',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Hoàn thành công việc để xem chúng ở đây',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            );
          }
          
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color.fromARGB(255, 0, 45, 81),
                  const Color.fromARGB(255, 0, 30, 60),
                ],
              ),
            ),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 100),
              children: [
                // Hiển thị số lượng công việc đã hoàn thành
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${completedTasks.length} công việc đã hoàn thành',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getFormattedDate(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Sử dụng widget CompletedTasksList để hiển thị danh sách công việc đã hoàn thành
                CompletedTasksList(
                  tasksByList: state.getCompletedTasksByList(),
                  buildTaskItem: _buildTaskItem,
                ),
              ],
            ),
          );
        } else {
          return const Center(
            child: Text(
              'Không có dữ liệu',
              style: TextStyle(color: Colors.white),
            ),
          );
        }
      },
    );
  }
  
  // Lấy ngày hiện tại định dạng đẹp
  String _getFormattedDate() {
    final now = DateTime.now();
    final weekdays = ['Chủ nhật', 'Thứ hai', 'Thứ ba', 'Thứ tư', 'Thứ năm', 'Thứ sáu', 'Thứ bảy'];
    final months = [
      'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6',
      'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'
    ];
    
    return '${weekdays[now.weekday % 7]}, ${now.day} ${months[now.month - 1]} năm ${now.year}';
  }
  
  // Widget hiển thị một danh mục công việc
  Widget _buildCategorySection(String categoryName, List<Task> tasks, Color accentColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 1, 63, 113).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      categoryName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${tasks.length} công việc',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ...tasks.map((task) => _buildTaskItem(task)).toList(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
  
  // Widget hiển thị một công việc
  Widget _buildTaskItem(Task task) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 1, 80, 143).withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: CheckboxListTile(
        title: Text(
          task.title,
          style: TextStyle(
            color: Colors.white,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            decorationColor: Colors.white54,
            fontSize: 16,
          ),
        ),
        subtitle: task.hasTime || task.list != 'Mặc định' 
          ? Row(
              children: [
                if (task.list != 'Mặc định')
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 12, color: Colors.white60),
                      const SizedBox(width: 4),
                      Text(
                        task.getFormattedDate(),
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                if (task.list != 'Mặc định' && task.hasTime)
                  const Text(
                    ' • ',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                if (task.hasTime)
                  Builder(
                    builder: (context) => Row(
                      children: [
                        const Icon(Icons.access_time, size: 12, color: Colors.white60),
                        const SizedBox(width: 4),
                        Text(
                          task.getFormattedTime(context),
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                if (task.list != 'Danh sách tất cả' && task.list != 'Mặc định')
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        task.list,
                        style: const TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                    ),
                  ),
              ],
            )
          : null,
        value: task.isCompleted,
        onChanged: (value) {
          context.read<TaskBloc>().add(ToggleTaskEvent(task.id));
        },
        activeColor: const Color.fromARGB(255, 1, 115, 182),
        checkColor: Colors.white,
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Xử lý khi người dùng chọn tab trong bottom navigation
  void _onBottomNavTapped(int index) {
    // Nếu đang ở tab hiện tại, không làm gì
    if (_currentIndex == index) return;
    
    // Hiệu ứng khi chuyển tab
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Gọi để đảm bảo AutomaticKeepAliveClientMixin hoạt động
    
    // Danh sách tiêu đề cho từng tab
    final List<String> appBarTitles = [
      _currentList, // Tab Home - hiển thị danh sách đã chọn
      'Công việc đã hoàn thành', // Tab Completed
      'Danh mục', // Tab Category
      'Tài khoản', // Tab Account
    ];
    
    // Danh sách icon cho từng tab
    final List<IconData> appBarIcons = [
      Icons.home, // Tab Home
      Icons.check_circle_outline, // Tab Completed
      Icons.category, // Tab Category
      Icons.account_circle, // Tab Account
    ];
    
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 1, 115, 182),
      appBar: (_currentIndex == 2 || _currentIndex == 3) ? null : AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 115, 182),
        elevation: 0,
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.5),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: Text(
            appBarTitles[_currentIndex],
            key: ValueKey<String>(appBarTitles[_currentIndex]),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        leading: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(
              scale: animation,
              child: child,
            );
          },
          child: Icon(
            appBarIcons[_currentIndex],
            key: ValueKey<IconData>(appBarIcons[_currentIndex]),
            color: Colors.white,
          ),
        ),
        titleSpacing: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Hiển thị dialog tìm kiếm
              showSearch(
                context: context,
                delegate: TaskSearchDelegate(
                  context.read<TaskBloc>().state is TasksLoaded
                      ? (context.read<TaskBloc>().state as TasksLoaded).tasks
                      : [],
                  context.read<TaskBloc>().state is TasksLoaded
                      ? (context.read<TaskBloc>().state as TasksLoaded).completedTasks
                      : [],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // Hiển thị bottom sheet thông báo
              showModalBottomSheet(
                context: context,
                backgroundColor: const Color.fromARGB(255, 1, 63, 113),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => const NotificationsBottomSheet(),
              );
            },
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: IndexedStack(
          key: ValueKey<int>(_currentIndex),
          index: _currentIndex,
          children: [
            _buildHomeContent(),
            _buildCompletedTasksContent(),
            const CategoryScreen(),
            const AccountScreen(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 1, 115, 182), // Màu hồng
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddTaskScreen(
                      initialList:
                          _currentList == 'Danh sách tất cả'
                              ? 'Công việc'
                              : _currentList,
                    ),
                  ),
                );
              },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical:0.0),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 1, 115, 182),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            child: BottomAppBar(
              color: Colors.transparent,
              elevation: 0,
              notchMargin: 8,
              padding: EdgeInsets.only(top: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.home,
                      color: _currentIndex == 0 ? Colors.white : Colors.white60,
                      size: 30,
                    ),
                    onPressed: () {
                      _onBottomNavTapped(0);
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.check_circle,
                      color: _currentIndex == 1 ? Colors.white : Colors.white60,
                      size: 30,
                    ),
                    onPressed: () {
                      _onBottomNavTapped(1);
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 40), // Khoảng trống cho FAB
                  IconButton(
                    icon: Icon(
                      Icons.category,
                      color: _currentIndex == 2 ? Colors.white : Colors.white60,
                      size: 30,
                    ),
                    onPressed: () {
                      _onBottomNavTapped(2);
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.account_circle,
                      color: _currentIndex == 3 ? Colors.white : Colors.white60,
                      size: 30,
                    ),
                    onPressed: () {
                      _onBottomNavTapped(3);
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
