import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../presentation/bloc/task/task_bloc.dart';
import '../presentation/bloc/task/task_state.dart';
import '../presentation/pages/category/category_bloc.dart';
import '../presentation/pages/category/category_event.dart';
import '../presentation/pages/category/category_state.dart';
import '../data/lists_data.dart';

class EnhancedCategoryScreen extends StatefulWidget {
  final Function(String)? onCategoryTap;
  
  const EnhancedCategoryScreen({
    super.key,
    this.onCategoryTap,
  });

  @override
  State<EnhancedCategoryScreen> createState() => _EnhancedCategoryScreenState();
}

class _EnhancedCategoryScreenState extends State<EnhancedCategoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _addCategoryController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }
  
  /// Initialize screen with Hot Reload safety
  void _initializeScreen() {
    if (!_isInitialized) {
      _isInitialized = true;
      debugPrint('🔄 Enhanced Category Screen initialized');
      
      // Set up search listener
      _searchController.addListener(() {
        if (mounted) {
          setState(() {
            _searchQuery = _searchController.text.toLowerCase();
          });
        }
      });
      
      // Load categories with safety check
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadCategoriesWithSafety();
      });
    }
  }
  
  /// Load categories with Hot Reload protection
  void _loadCategoriesWithSafety() {
    try {
      if (mounted && context.mounted) {
        context.read<CategoryBloc>().add(const LoadCategoriesEvent());
        debugPrint('✅ Categories loading triggered successfully');
      }
    } catch (e) {
      debugPrint('⚠️ Error loading categories: $e');
      // Retry after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _loadCategoriesWithSafety();
        }
      });
    }
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure screen is properly initialized after Hot Reload
    if (!_isInitialized) {
      _initializeScreen();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _addCategoryController.dispose();
    super.dispose();
  }

  List<String> _filterCategories(List<String> categories) {
    if (_searchQuery.isEmpty) {
      return categories;
    }
    return categories.where((category) => 
      category.toLowerCase().contains(_searchQuery)
    ).toList();
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 1, 63, 113),
        title: const Text(
          'Thêm danh mục mới',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _addCategoryController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Nhập tên danh mục',
                hintStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              autofocus: true,
              onSubmitted: (_) => _addCategory(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _addCategoryController.clear();
            },
            child: const Text('Hủy', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: _addCategory,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 1, 115, 182),
            ),
            child: const Text('Thêm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _addCategory() {
    final categoryName = _addCategoryController.text.trim();
    if (categoryName.isNotEmpty && mounted) {
      try {
        // Add category with immediate feedback
        context.read<CategoryBloc>().add(AddCategoryEvent(categoryName));
        
        if (mounted) {
          Navigator.of(context).pop();
          _addCategoryController.clear();
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Đã thêm danh mục "$categoryName"')),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        debugPrint('⚠️ Error adding category: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi thêm danh mục: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  void _showEditCategoryDialog(String category) {
    final controller = TextEditingController(text: category);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 1, 63, 113),
        title: const Text(
          'Đổi tên danh mục',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Nhập tên mới',
            hintStyle: TextStyle(color: Colors.white70),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white70),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
          autofocus: true,
          onSubmitted: (_) {
            final newName = controller.text.trim();
            if (newName.isNotEmpty && newName != category) {
              context.read<CategoryBloc>().add(EditCategoryEvent(category, newName));
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != category) {
                context.read<CategoryBloc>().add(EditCategoryEvent(category, newName));
                Navigator.of(context).pop();
                
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.edit, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Đã đổi tên thành "$newName"')),
                      ],
                    ),
                    backgroundColor: Colors.blue,
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 1, 115, 182),
            ),
            child: const Text('Lưu', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteCategoryDialog(String category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 1, 63, 113),
        title: const Text(
          'Xác nhận xóa',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa danh mục "$category"?\n\nTất cả công việc trong danh mục này sẽ được chuyển về "Mặc định".',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CategoryBloc>().add(DeleteCategoryEvent(category));
              Navigator.of(context).pop();
              
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.delete, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(child: Text('Đã xóa danh mục "$category"')),
                    ],
                  ),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 1, 45, 81),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 115, 182),
        elevation: 0,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Tìm kiếm danh mục...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                autofocus: true,
              )
            : const Text(
                'Danh mục',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
        leading: _isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchController.clear();
                  });
                },
              )
            : const Icon(
                Icons.category,
                color: Colors.white,
              ),
        titleSpacing: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.clear : Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white, size: 28),
            tooltip: 'Thêm danh mục mới',
            onPressed: _showAddCategoryDialog,
          ),
        ],
      ),
      body: BlocConsumer<CategoryBloc, CategoryState>(
        listener: (context, state) {
          if (state is CategoryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(child: Text(state.message)),
                  ],
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
              ),
            );
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
            final filteredCategories = _filterCategories(state.categories);
            
            if (filteredCategories.isEmpty && _searchQuery.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.search_off,
                      color: Colors.white70,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Không tìm thấy danh mục nào\nphù hợp với "$_searchQuery"',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }

            return BlocBuilder<TaskBloc, TaskState>(
              builder: (context, taskState) {
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredCategories.length,
                  itemBuilder: (context, index) {
                    final category = filteredCategories[index];
                    final taskCount = taskState is TasksLoaded
                        ? taskState.getTasksByList(category).length
                        : 0;
                    
                    final categoryColor = ListsData.getCategoryColor(category);
                    final categoryIcon = ListsData.getCategoryIcon(category);
                    final isSystemCategory = category == 'Công việc' || 
                                           category == 'Mặc định' ||
                                           category == 'Cá nhân' ||
                                           category == 'Học tập' ||
                                           category == 'Sức khỏe' ||
                                           category == 'Mua sắm';
                    
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
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: categoryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            categoryIcon,
                            color: categoryColor,
                            size: 24,
                          ),
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
                            if (!isSystemCategory) ...[
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                ),
                                tooltip: 'Đổi tên',
                                onPressed: () => _showEditCategoryDialog(category),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                  size: 24,
                                ),
                                tooltip: 'Xóa',
                                onPressed: () => _showDeleteCategoryDialog(category),
                              ),
                            ] else ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: categoryColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Mặc định',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        onTap: () {
                          // Use callback if provided, otherwise navigate to AddTaskScreen
                          if (widget.onCategoryTap != null) {
                            widget.onCategoryTap!(category);
                          } else {
                            // Fallback navigation (can be customized)
                            Navigator.pop(context, category);
                          }
                        },
                      ),
                    );
                  },
                );
              },
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.white70,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Không thể tải danh mục',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      context.read<CategoryBloc>().add(const LoadCategoriesEvent());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 1, 115, 182),
                    ),
                    child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
} 