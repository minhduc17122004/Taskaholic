import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../presentation/bloc/auth/auth_bloc.dart';
import '../../../presentation/bloc/auth/auth_state.dart';
import '../../../presentation/bloc/task/task_bloc.dart';
import '../../../presentation/bloc/task/task_event.dart';
import '../../../presentation/bloc/task/task_state.dart';
import 'home_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';
import '../../../domain/entities/task.dart';
import '../../../widgets/task_search_delegate.dart';
import '../../../widgets/notifications_bottom_sheet.dart';
import '../../../widgets/completed_tasks_list.dart';
import '../../../screens/add_task_screen.dart';
import '../../../screens/enhanced_category_screen.dart';
import '../../../screens/account_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/lists_data.dart';

/// HomePage - Màn hình chính của ứng dụng sử dụng BLoC pattern
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true; // Giữ trạng thái của widget khi chuyển tab
  
  @override
  void initState() {
    super.initState();
    
    // Thiết lập error builder toàn cục
    ErrorWidget.builder = (FlutterErrorDetails details) {
      developer.log('Lỗi không mong muốn: ${details.exception}', name: 'HomePage', error: details.exception);
      return Container(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        child: const Text(
          'Đã xảy ra lỗi không mong muốn.\nVui lòng thử lại sau.',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      );
    };
    
    // Tải dữ liệu khi khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Đảm bảo widget vẫn mounted trước khi gọi BLoC
      if (!mounted) return;
      
      context.read<HomeBloc>().add(const LoadHomeDataEvent());
      context.read<TaskBloc>().add(const LoadTasks(forceRefresh: true));
      
      // Kiểm tra thông tin đăng nhập thông qua AuthBloc
      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated) {
        developer.log('Người dùng đã đăng nhập: ${authState.user.id}', name: 'HomePage');
        developer.log('Email: ${authState.user.email}', name: 'HomePage');
      } else {
        developer.log('Chưa đăng nhập!', name: 'HomePage');
        
        // Hiển thị thông báo chưa đăng nhập
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bạn chưa đăng nhập! Không thể lưu task lên Firestore.'),
              backgroundColor: AppColors.error,
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
    });
  }

  /// Widget cho màn hình Home
  Widget _buildHomeContent(String currentList) {
    return BlocConsumer<TaskBloc, TaskState>(
      listener: (context, state) {
        if (state is TaskError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
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
        } else if (state is TaskActionSuccess) {
          // Show success feedback for task operations (including toggle)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(state.message)),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is TaskLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        } else if (state is TasksLoaded) {
          final List<Task> displayedTasks = state.getTasksByList(currentList);
          final hasTasks = displayedTasks.isNotEmpty;
          final Map<String, List<Task>> tasksByCategory = state.getTasksByCategoryForList(currentList);

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
                    // Header với ngày và thông tin
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getFormattedDate(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$currentList (${displayedTasks.length})',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Add Task Card
                    _buildAddTaskCard(currentList),
                    
                    // Danh sách các danh mục công việc
                    ...categoryWidgets,
                  ],
                ),
              )
            : Container(
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
                child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundDark.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_outline,
                        size: 80,
                        color: Colors.white70,
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
                        'Hãy bắt đầu bằng việc thêm nhiệm vụ đầu tiên!',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      // Add Task Button in empty state
                      ElevatedButton.icon(
                        onPressed: () {
                          developer.log('Empty state Add Task button pressed', name: 'HomePage');
                          _handleAddTask(currentList);
                        },
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          'Thêm nhiệm vụ mới',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 1, 115, 182),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                    ),
                  ],
                  ),
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

  /// Widget cho màn hình công việc đã hoàn thành
  Widget _buildCompletedTasksContent() {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is TaskLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
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
                      color: const Color.fromARGB(255, 1, 63, 113).withValues(alpha: 0.3),
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [  
                            Text(
                            _getFormattedDate(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 1),
                            Text(
                              '${completedTasks.length} công việc đã hoàn thành',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.3),
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
  
  /// Lấy ngày hiện tại định dạng đẹp
  String _getFormattedDate() {
    final now = DateTime.now();
    final weekdays = ['Chủ nhật', 'Thứ hai', 'Thứ ba', 'Thứ tư', 'Thứ năm', 'Thứ sáu', 'Thứ bảy'];
    final months = [
      'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6',
      'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'
    ];
    
    return '${weekdays[now.weekday % 7]}, ${now.day} ${months[now.month - 1]} năm ${now.year}';
  }
  
  /// Widget hiển thị một danh mục công việc
  Widget _buildCategorySection(String categoryName, List<Task> tasks, Color accentColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 1, 63, 113).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
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
          ...tasks.map((task) => _buildTaskItem(task)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
  
  /// Widget hiển thị card thêm task mới
  Widget _buildAddTaskCard(String currentList) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 4,
        color: const Color.fromARGB(255, 1, 80, 143).withValues(alpha: 0.6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: const Color.fromARGB(255, 1, 115, 182).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            developer.log('Inline Add Task card pressed', name: 'HomePage');
            _handleAddTask(currentList);
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 1, 115, 182),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thêm nhiệm vụ mới',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tạo nhiệm vụ trong "$currentList"',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white60,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  /// Widget hiển thị một công việc
  Widget _buildTaskItem(Task task) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: task.isCompleted 
            ? const Color.fromARGB(255, 1, 80, 143).withValues(alpha: 0.2)
            : const Color.fromARGB(255, 1, 80, 143).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: task.isCompleted ? 0.7 : 1.0,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          splashColor: Colors.white.withValues(alpha: 0.1),
          highlightColor: Colors.white.withValues(alpha: 0.05),
          onTap: () {
            // Navigate to task detail screen when tapping on the task item
            try {
              Navigator.of(context).push(
                MaterialPageRoute(
                  maintainState: true, // Tránh lỗi OpenGL
                  fullscreenDialog: false, // Tránh lỗi OpenGL
                  builder: (context) => AddTaskScreen(existingTask: task),
                ),
              ).then((newCategory) {
                // Reload tasks when returning from task detail screen
                if (mounted) {
                  Future.delayed(const Duration(milliseconds: 300), () {
                    context.read<TaskBloc>().add(const LoadTasks(forceRefresh: true));
                    
                                          // If task category was changed, navigate to the new category
                      if (newCategory != null && newCategory is String) {
                        developer.log('Task category changed to: $newCategory, navigating...', name: 'HomePage');
                        // Update home bloc to switch to the new category
                        context.read<HomeBloc>().add(ChangeCurrentListEvent(newCategory));
                      }
                  });
                }
              }).catchError((error) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Không thể mở chi tiết task: $error'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                  developer.log('Lỗi khi mở chi tiết task: $error', name: 'HomePage');
                }
              });
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lỗi: $e'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
                developer.log('Lỗi khi tạo route đến chi tiết task: $e', name: 'HomePage');
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Checkbox with separate tap handling
                GestureDetector(
                  onTap: () {
                    // Only handle checkbox toggle, prevent task detail navigation
                    context.read<TaskBloc>().add(ToggleTaskEvent(task.id));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: task.isCompleted 
                            ? const Color.fromARGB(255, 1, 115, 182)
                            : Colors.transparent,
                        border: Border.all(
                          color: const Color.fromARGB(255, 1, 115, 182),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: task.isCompleted
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Task content (tappable for navigation)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Task title
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          color: Colors.white,
                          decorationColor: Colors.white54,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        child: Text(task.title),
                      ),
                      // Task details
                      if (task.hasTime || task.getFormattedDate().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              if (task.getFormattedDate().isNotEmpty)
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 12, color: Colors.white60),
                                    const SizedBox(width: 4),
                                    Text(
                                      task.getFormattedDate(),
                                      style: const TextStyle(color: Colors.white60, fontSize: 12),
                                    ),
                                  ],
                                ),
                              if (task.hasTime && task.getFormattedDate().isNotEmpty)
                                const Text(
                                  ', ',
                                  style: TextStyle(color: Colors.white60, fontSize: 12),
                                ),
                              if (task.hasTime)
                                Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 12, color: Colors.white60),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${task.time.hour}:${task.time.minute.toString().padLeft(2, '0')}',
                                      style: const TextStyle(color: Colors.white60, fontSize: 12),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                // Visual indicator that task is tappable
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white38,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Xử lý sự kiện Add Task - Navigate đến AddTaskScreen
  void _handleAddTask(String currentList) {
    developer.log('Add Task pressed - Starting _handleAddTask with currentList: $currentList', name: 'HomePage');
    
    try {
      // Xác định danh mục hợp lệ
      String validCategory;
      try {
        developer.log('Determining valid category for currentList: $currentList', name: 'HomePage');
        
        if (currentList == 'Danh sách tất cả' || currentList == 'Đã hoàn thành') {
          // Lấy danh sách danh mục
          developer.log('Current list is system category, fetching add task options', name: 'HomePage');
          final categories = ListsData.getAddTaskListOptions();
          developer.log('Available categories: $categories', name: 'HomePage');
          
          if (categories.isEmpty) {
            validCategory = 'Công việc';
            developer.log('No categories available, using default: $validCategory', name: 'HomePage');
          } else {
            // Ưu tiên danh mục 'Công việc' nếu có
            if (categories.contains('Công việc')) {
              validCategory = 'Công việc';
              developer.log('Using preferred category: $validCategory', name: 'HomePage');
            } else {
              validCategory = categories[0];
              developer.log('Using first available category: $validCategory', name: 'HomePage');
            }
          }
        } else if (!ListsData.isValidCategoryForAssignment(currentList)) {
          // Nếu danh mục hiện tại không hợp lệ cho task
          developer.log('Current list is not valid for assignment: $currentList', name: 'HomePage');
          final categories = ListsData.getAddTaskListOptions();
          validCategory = categories.isNotEmpty ? categories[0] : 'Công việc';
          developer.log('Using fallback category: $validCategory', name: 'HomePage');
        } else {
          validCategory = currentList;
          developer.log('Using current list as valid category: $validCategory', name: 'HomePage');
        }
      } catch (e) {
        // Nếu có lỗi khi lấy danh mục, sử dụng mặc định
        validCategory = 'Công việc';
        developer.log('Error determining category, using default: $e', name: 'HomePage', error: e);
      }
      
      developer.log('Final category selected: $validCategory', name: 'HomePage');
      
      // Check if context is still mounted
      if (!mounted) {
        developer.log('Widget not mounted, aborting navigation', name: 'HomePage');
        return;
      }
      
      // Use rootNavigator to ensure we can navigate from anywhere in the widget hierarchy
      developer.log('Starting navigation to AddTaskScreen', name: 'HomePage');
      
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          maintainState: true,
          fullscreenDialog: false, // Tránh lỗi OpenGL
          builder: (context) {
            developer.log('Building AddTaskScreen with initialList: $validCategory', name: 'HomePage');
            return AddTaskScreen(
            initialList: validCategory,
            );
          },
        ),
      ).then((newCategory) {
        developer.log('Returned from AddTaskScreen, reloading tasks', name: 'HomePage');
        // Reload tasks sau khi quay về
        if (mounted) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              developer.log('Triggering task reload', name: 'HomePage');
              context.read<TaskBloc>().add(const LoadTasks(forceRefresh: true));
              
              // If task category was changed during creation, navigate to that category
              if (newCategory != null && newCategory is String) {
                developer.log('New task created in category: $newCategory, navigating...', name: 'HomePage');
                // Update home bloc to switch to the new category
                context.read<HomeBloc>().add(ChangeCurrentListEvent(newCategory));
              }
            }
          });
        }
      }).catchError((error) {
        // Xử lý lỗi navigation
        developer.log('Navigation error occurred: $error', name: 'HomePage', error: error);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Không thể mở màn hình thêm task: $error'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
          developer.log('Showed error snackbar for navigation error', name: 'HomePage');
        }
      });
      
      developer.log('Navigation call completed successfully', name: 'HomePage');
      
    } catch (e, stackTrace) {
      // Xử lý các lỗi khác
      developer.log('Unexpected error in _handleAddTask: $e', name: 'HomePage', error: e, stackTrace: stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi không mong muốn: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
        developer.log('Showed error snackbar for unexpected error', name: 'HomePage');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Gọi để đảm bảo AutomaticKeepAliveClientMixin hoạt động
    
    return RepaintBoundary(
      child: BlocConsumer<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is HomeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (state is HomeLoaded) {
            // Danh sách tiêu đề cho từng tab
            final List<String> appBarTitles = [
              state.currentList, // Tab Home - hiển thị danh sách đã chọn
              'Công việc đã hoàn thành', // Tab Completed
              'Danh mục', // Tab Category
              'Tài khoản', // Tab Account
            ];
            
            // Danh sách icon cho từng tab
            final List<IconData> appBarIcons = [
              Icons.home, // Tab Home
              Icons.check_circle, // Tab Completed
              Icons.category, // Tab Category
              Icons.account_circle, // Tab Account
            ];
            
            return Scaffold(
              backgroundColor: const Color.fromARGB(255, 1, 115, 182),
              appBar: (state.currentIndex == 2 || state.currentIndex == 3) ? null : AppBar(
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
                    appBarTitles[state.currentIndex],
                    key: ValueKey<String>(appBarTitles[state.currentIndex]),
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
                    appBarIcons[state.currentIndex],
                    key: ValueKey<IconData>(appBarIcons[state.currentIndex]),
                    color: Colors.white,
                  ),
                ),
                titleSpacing: 0,
                actions: [
                  // Category selection PopupMenuButton
                  if (state.currentIndex == 0) // Only show on Home tab
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                      tooltip: 'Chọn danh mục',
                      color: const Color.fromARGB(255, 1, 63, 113),
                      onSelected: (String selectedCategory) {
                        context.read<HomeBloc>().add(ChangeCurrentListEvent(selectedCategory));
                      },
                      itemBuilder: (BuildContext context) {
                        try {
                          final allCategories = [
                            'Danh sách tất cả',
                            ...ListsData.getSelectableCategories(),
                          ];
                          
                          return allCategories.map((String category) {
                            final isSelected = category == state.currentList;
                            final categoryColor = ListsData.getCategoryColor(category);
                            final categoryIcon = ListsData.getCategoryIcon(category);
                            
                            return PopupMenuItem<String>(
                              value: category,
                              child: Row(
                                children: [
                                  Icon(
                                    categoryIcon,
                                    color: isSelected ? categoryColor : Colors.white70,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      category,
                                      style: TextStyle(
                                        color: isSelected ? categoryColor : Colors.white,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check,
                                      color: categoryColor,
                                      size: 20,
                                    ),
                                ],
                              ),
                            );
                          }).toList();
                        } catch (e) {
                          developer.log('Error building category menu: $e', name: 'HomePage');
                          return [
                            const PopupMenuItem<String>(
                              value: 'Danh sách tất cả',
                              child: Text('Danh sách tất cả', style: TextStyle(color: Colors.white)),
                            ),
                          ];
                        }
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    tooltip: 'Tìm kiếm',
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
                    icon: const Icon(Icons.notifications, color: Colors.white, size: 28),
                    tooltip: 'Thông báo',
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
                  key: ValueKey<int>(state.currentIndex),
                  index: state.currentIndex,
                  sizing: StackFit.expand, // Đảm bảo stack fit với parent
                  children: [
                    // Wrap trong Builder để đảm bảo context mới cho mỗi child
                    Builder(builder: (context) => _buildHomeContent(state.currentList)),
                    Builder(builder: (context) => _buildCompletedTasksContent()),
                    _CategoryScreenWrapper(
                      onCategorySelected: (String selectedCategory) {
                        // Switch to Home tab and change category
                        context.read<HomeBloc>().add(const ChangeTabEvent(0));
                        context.read<HomeBloc>().add(ChangeCurrentListEvent(selectedCategory));
                      },
                    ),
                    const AccountScreen(),
                  ],
                ),
              ),

              bottomNavigationBar: BottomNavigationBar(
                currentIndex: state.currentIndex,
                onTap: (index) {
                  context.read<HomeBloc>().add(ChangeTabEvent(index));
                },
                type: BottomNavigationBarType.fixed,
                backgroundColor: AppColors.primary,
                selectedItemColor: AppColors.cardBackground,
                unselectedItemColor: AppColors.cardBackground.withValues(alpha: 0.6),
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Trang chủ',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.check_circle),
                    label: 'Hoàn thành',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.category),
                    label: 'Danh mục',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings),
                    label: 'Cài đặt',
                  ),
                ],
              ),
            );
          } else {
            return const Scaffold(
              body: Center(
                child: Text('Đã xảy ra lỗi'),
              ),
            );
          }
        },
      ),
    );
  }
}

/// Wrapper widget for CategoryScreen to handle navigation results
class _CategoryScreenWrapper extends StatelessWidget {
  final Function(String) onCategorySelected;

  const _CategoryScreenWrapper({
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedCategoryScreen(
      onCategoryTap: onCategorySelected,
    );
  }
} 