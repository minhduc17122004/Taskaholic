import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../presentation/bloc/task/task_bloc.dart';
import '../../../presentation/bloc/task/task_state.dart';
import 'category_bloc.dart';
import 'category_event.dart';
import 'category_state.dart';
import '../../../presentation/dialogs/add_list_dialog.dart';
import '../../../presentation/dialogs/edit_category_dialog.dart';
import '../../../presentation/dialogs/delete_confirmation_dialog.dart';
import '../../../screens/add_task_screen.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({Key? key}) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  @override
  void initState() {
    super.initState();
    // Tải danh sách danh mục khi màn hình được khởi tạo
    context.read<CategoryBloc>().add(const LoadCategoriesEvent());
  }

  void _showAddListDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AddListDialog(
          controller: controller,
          onListAdded: (String newList) {
            // Gửi sự kiện thêm danh mục
            context.read<CategoryBloc>().add(AddCategoryEvent(newList));
          },
        );
      },
    );
  }

  void _showEditCategoryDialog(String category) {
    EditCategoryDialog.show(
      context: context,
      initialValue: category,
      onSave: (String newName) {
        // Gửi sự kiện chỉnh sửa danh mục
        context.read<CategoryBloc>().add(EditCategoryEvent(category, newName));
      },
    );
  }

  void _showDeleteCategoryDialog(String category) {
    DeleteConfirmationDialog.show(
      context: context,
      onConfirm: () {
        // Gửi sự kiện xóa danh mục
        context.read<CategoryBloc>().add(DeleteCategoryEvent(category));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 1, 45, 81),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 115, 182),
        elevation: 0,
        title: const Text(
          'Danh mục',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        leading: const Icon(
          Icons.category,
          color: Colors.white,
        ),
        titleSpacing: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            tooltip: 'Tìm kiếm',
            onPressed: () {
              // Hiển thị dialog tìm kiếm
              // Có thể thêm chức năng tìm kiếm danh mục sau này
            },
          ),
          IconButton(
            icon: const Icon(Icons.playlist_add, color: Colors.white, size: 28),
            tooltip: 'Thêm danh mục mới',
            onPressed: _showAddListDialog,
          ),
        ],
      ),
      body: BlocConsumer<CategoryBloc, CategoryState>(
        listener: (context, state) {
          if (state is CategoryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 2),
              ),
            );
            // Tải lại danh sách sau khi hiển thị lỗi
            context.read<CategoryBloc>().add(const LoadCategoriesEvent());
          }
        },
        builder: (context, state) {
          if (state is CategoryLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          } else if (state is CategoriesLoaded) {
            return BlocBuilder<TaskBloc, TaskState>(
              builder: (context, taskState) {
                if (taskState is TasksLoaded) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.categories.length,
                    itemBuilder: (context, index) {
                      final category = state.categories[index];
                      final taskCount = taskState.getTasksByList(category).length;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: const Color.fromARGB(255, 1, 63, 113),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          title: Text(
                            category,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            '$taskCount công việc',
                            style: const TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                ),
                                onPressed: () => _showEditCategoryDialog(category),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.white70,
                                  size: 27,
                                ),
                                onPressed: () => _showDeleteCategoryDialog(category),
                              ),
                            ],
                          ),
                          onTap: () {
                            // Chuyển đến màn hình danh sách công việc của danh mục này
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddTaskScreen(
                                  initialList: category,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(
                    child: Text(
                      'Không thể tải dữ liệu công việc',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
              },
            );
          } else {
            return const Center(
              child: Text(
                'Không thể tải danh mục',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
        },
      ),
    );
  }
} 