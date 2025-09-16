import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/teacher.dart';
import '../../models/class_model.dart';

class TeacherManagementPage extends StatefulWidget {
  const TeacherManagementPage({super.key});

  @override
  State<TeacherManagementPage> createState() => _TeacherManagementPageState();
}

class _TeacherManagementPageState extends State<TeacherManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<Teacher> _teachers = [];
  List<Teacher> _filteredTeachers = [];
  final List<ClassModel> _availableClasses = [];

  @override
  void initState() {
    super.initState();
    _loadMockData();
    _filteredTeachers = _teachers;
    _searchController.addListener(_filterTeachers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadMockData() {
    _teachers.addAll([
      Teacher(
        id: '1',
        name: 'Dr. Sarah Johnson',
        email: 'sarah.johnson@school.edu',
        department: 'Mathematics',
        phoneNumber: '+1234567890',
        isActive: true,
        assignedClasses: ['MATH101', 'MATH201'],
        createdAt: DateTime.now(),
      ),
      Teacher(
        id: '2',
        name: 'Prof. Michael Chen',
        email: 'michael.chen@school.edu',
        department: 'Computer Science',
        phoneNumber: '+1234567891',
        isActive: true,
        assignedClasses: ['CS101', 'CS301'],
        createdAt: DateTime.now(),
      ),
      Teacher(
        id: '3',
        name: 'Dr. Emily Rodriguez',
        email: 'emily.rodriguez@school.edu',
        department: 'Physics',
        phoneNumber: '+1234567892',
        isActive: false,
        assignedClasses: ['PHY101'],
        createdAt: DateTime.now(),
      ),
    ]);

    _availableClasses.addAll([
      ClassModel(
        id: 'MATH101',
        name: 'Calculus I',
        section: 'A',
        grade: '12',
        teacherId: '1',
        teacherName: 'Dr. Sarah Johnson',
        academicYear: '2024-25',
        createdAt: DateTime.now(),
      ),
      ClassModel(
        id: 'MATH201',
        name: 'Linear Algebra',
        section: 'B',
        grade: '12',
        teacherId: '1',
        teacherName: 'Dr. Sarah Johnson',
        academicYear: '2024-25',
        createdAt: DateTime.now(),
      ),
      ClassModel(
        id: 'CS101',
        name: 'Introduction to Programming',
        section: 'A',
        grade: '11',
        teacherId: '2',
        teacherName: 'Prof. Michael Chen',
        academicYear: '2024-25',
        createdAt: DateTime.now(),
      ),
      ClassModel(
        id: 'CS301',
        name: 'Data Structures',
        section: 'B',
        grade: '11',
        teacherId: '2',
        teacherName: 'Prof. Michael Chen',
        academicYear: '2024-25',
        createdAt: DateTime.now(),
      ),
      ClassModel(
        id: 'PHY101',
        name: 'General Physics',
        section: 'A',
        grade: '10',
        teacherId: '3',
        teacherName: 'Dr. Emily Rodriguez',
        academicYear: '2024-25',
        createdAt: DateTime.now(),
      ),
    ]);
  }

  void _filterTeachers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTeachers = _teachers.where((teacher) {
        return teacher.name.toLowerCase().contains(query) ||
            teacher.email.toLowerCase().contains(query) ||
            teacher.department.toLowerCase().contains(query) ||
            teacher.id.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _showAddTeacherDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddTeacherDialog(
        availableClasses: _availableClasses,
        onTeacherAdded: (teacher) {
          setState(() {
            _teachers.add(teacher);
            _filterTeachers();
          });
        },
      ),
    );
  }

  void _showEditTeacherDialog(Teacher teacher) {
    showDialog(
      context: context,
      builder: (context) => _EditTeacherDialog(
        teacher: teacher,
        availableClasses: _availableClasses,
        onTeacherUpdated: (updatedTeacher) {
          setState(() {
            final index = _teachers.indexWhere((t) => t.id == teacher.id);
            if (index != -1) {
              _teachers[index] = updatedTeacher;
              _filterTeachers();
            }
          });
        },
      ),
    );
  }

  void _toggleTeacherStatus(Teacher teacher) {
    setState(() {
      final index = _teachers.indexWhere((t) => t.id == teacher.id);
      if (index != -1) {
        _teachers[index] = teacher.copyWith(isActive: !teacher.isActive);
        _filterTeachers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Management'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search and Add Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search teachers...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Add Teacher Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _showAddTeacherDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add New Teacher'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ).animate().slideY(begin: -0.3, duration: 600.ms),

          // Teachers List
          Expanded(
            child: _filteredTeachers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_search,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No teachers found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredTeachers.length,
                    itemBuilder: (context, index) {
                      final teacher = _filteredTeachers[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: teacher.isActive
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                            child: Icon(
                              Icons.person,
                              color: teacher.isActive
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                            ),
                          ),
                          title: Text(
                            teacher.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('${teacher.department} • ID: ${teacher.id}'),
                              Text(teacher.email),
                              if (teacher.assignedClasses.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Classes: ${teacher.assignedClasses.join(', ')}',
                                  style: TextStyle(
                                    color: Colors.blue.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              switch (value) {
                                case 'edit':
                                  _showEditTeacherDialog(teacher);
                                  break;
                                case 'toggle':
                                  _toggleTeacherStatus(teacher);
                                  break;
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: ListTile(
                                  leading: Icon(Icons.edit),
                                  title: Text('Edit'),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                              PopupMenuItem(
                                value: 'toggle',
                                child: ListTile(
                                  leading: Icon(
                                    teacher.isActive
                                        ? Icons.person_off
                                        : Icons.person,
                                  ),
                                  title: Text(
                                    teacher.isActive
                                        ? 'Deactivate'
                                        : 'Activate',
                                  ),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().slideX(
                        begin: 0.3,
                        duration: 400.ms,
                        delay: (index * 100).ms,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _AddTeacherDialog extends StatefulWidget {
  final List<ClassModel> availableClasses;
  final Function(Teacher) onTeacherAdded;

  const _AddTeacherDialog({
    required this.availableClasses,
    required this.onTeacherAdded,
  });

  @override
  State<_AddTeacherDialog> createState() => _AddTeacherDialogState();
}

class _AddTeacherDialogState extends State<_AddTeacherDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedDepartment = 'Mathematics';
  List<String> _selectedClasses = [];

  final List<String> _departments = [
    'Mathematics',
    'Computer Science',
    'Physics',
    'Chemistry',
    'Biology',
    'English',
    'History',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _addTeacher() {
    if (_formKey.currentState!.validate()) {
      final teacher = Teacher(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        department: _selectedDepartment,
        phoneNumber: _phoneController.text.trim(),
        isActive: true,
        assignedClasses: _selectedClasses,
        createdAt: DateTime.now(),
      );

      widget.onTeacherAdded(teacher);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add New Teacher',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter teacher name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: _selectedDepartment,
                        decoration: const InputDecoration(
                          labelText: 'Department',
                          border: OutlineInputBorder(),
                        ),
                        items: _departments.map((dept) {
                          return DropdownMenuItem(
                            value: dept,
                            child: Text(dept),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDepartment = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Class Assignment
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Assign Classes:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.builder(
                          itemCount: widget.availableClasses.length,
                          itemBuilder: (context, index) {
                            final classModel = widget.availableClasses[index];
                            return CheckboxListTile(
                              title: Text(classModel.name),
                              subtitle: Text(
                                '${classModel.grade}-${classModel.section}',
                              ),
                              value: _selectedClasses.contains(classModel.id),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedClasses.add(classModel.id);
                                  } else {
                                    _selectedClasses.remove(classModel.id);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _addTeacher,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Add Teacher'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditTeacherDialog extends StatefulWidget {
  final Teacher teacher;
  final List<ClassModel> availableClasses;
  final Function(Teacher) onTeacherUpdated;

  const _EditTeacherDialog({
    required this.teacher,
    required this.availableClasses,
    required this.onTeacherUpdated,
  });

  @override
  State<_EditTeacherDialog> createState() => _EditTeacherDialogState();
}

class _EditTeacherDialogState extends State<_EditTeacherDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late String _selectedDepartment;
  late List<String> _selectedClasses;

  final List<String> _departments = [
    'Mathematics',
    'Computer Science',
    'Physics',
    'Chemistry',
    'Biology',
    'English',
    'History',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.teacher.name);
    _emailController = TextEditingController(text: widget.teacher.email);
    _phoneController = TextEditingController(text: widget.teacher.phoneNumber);
    _selectedDepartment = widget.teacher.department;
    _selectedClasses = List.from(widget.teacher.assignedClasses);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _updateTeacher() {
    if (_formKey.currentState!.validate()) {
      final updatedTeacher = widget.teacher.copyWith(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        department: _selectedDepartment,
        phoneNumber: _phoneController.text.trim(),
        assignedClasses: _selectedClasses,
      );

      widget.onTeacherUpdated(updatedTeacher);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Teacher',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter teacher name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: _selectedDepartment,
                        decoration: const InputDecoration(
                          labelText: 'Department',
                          border: OutlineInputBorder(),
                        ),
                        items: _departments.map((dept) {
                          return DropdownMenuItem(
                            value: dept,
                            child: Text(dept),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDepartment = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Class Assignment
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Assign Classes:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.builder(
                          itemCount: widget.availableClasses.length,
                          itemBuilder: (context, index) {
                            final classModel = widget.availableClasses[index];
                            return CheckboxListTile(
                              title: Text(classModel.name),
                              subtitle: Text(
                                '${classModel.grade}-${classModel.section}',
                              ),
                              value: _selectedClasses.contains(classModel.id),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedClasses.add(classModel.id);
                                  } else {
                                    _selectedClasses.remove(classModel.id);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _updateTeacher,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Update Teacher'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
