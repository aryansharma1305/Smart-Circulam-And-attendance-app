import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';

class RosterPage extends ConsumerStatefulWidget {
  const RosterPage({super.key});

  @override
  ConsumerState<RosterPage> createState() => _RosterPageState();
}

class _RosterPageState extends ConsumerState<RosterPage> {
  String _selectedClass = 'Class A';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _classes = ['Class A', 'Class B', 'Class C', 'Class D'];

  // Demo student data
  final List<Map<String, dynamic>> _students = [
    {
      'id': '1',
      'name': 'John Doe',
      'rollNumber': '2024001',
      'email': 'john.doe@student.edu',
      'attendance': 95,
      'lastSeen': '2 hours ago',
      'isPresent': true,
    },
    {
      'id': '2',
      'name': 'Jane Smith',
      'rollNumber': '2024002',
      'email': 'jane.smith@student.edu',
      'attendance': 88,
      'lastSeen': '1 day ago',
      'isPresent': false,
    },
    {
      'id': '3',
      'name': 'Mike Johnson',
      'rollNumber': '2024003',
      'email': 'mike.johnson@student.edu',
      'attendance': 92,
      'lastSeen': '3 hours ago',
      'isPresent': true,
    },
    {
      'id': '4',
      'name': 'Sarah Wilson',
      'rollNumber': '2024004',
      'email': 'sarah.wilson@student.edu',
      'attendance': 78,
      'lastSeen': '2 days ago',
      'isPresent': false,
    },
    {
      'id': '5',
      'name': 'David Brown',
      'rollNumber': '2024005',
      'email': 'david.brown@student.edu',
      'attendance': 96,
      'lastSeen': '1 hour ago',
      'isPresent': true,
    },
    {
      'id': '6',
      'name': 'Emily Davis',
      'rollNumber': '2024006',
      'email': 'emily.davis@student.edu',
      'attendance': 89,
      'lastSeen': '4 hours ago',
      'isPresent': false,
    },
    {
      'id': '7',
      'name': 'Chris Miller',
      'rollNumber': '2024007',
      'email': 'chris.miller@student.edu',
      'attendance': 91,
      'lastSeen': '30 minutes ago',
      'isPresent': true,
    },
    {
      'id': '8',
      'name': 'Lisa Garcia',
      'rollNumber': '2024008',
      'email': 'lisa.garcia@student.edu',
      'attendance': 85,
      'lastSeen': '1 day ago',
      'isPresent': false,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredStudents = _getFilteredStudents();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Class Roster',
          style: TextStyle(
            color: AppTheme.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textPrimaryColor),
          onPressed: () => context.go('/teacher'),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppTheme.primaryColor),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Class Selector and Search
          _buildHeader(),

          // Statistics
          _buildStatistics(filteredStudents),

          // Students List
          Expanded(child: _buildStudentsList(filteredStudents)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          // Class Selector
          Row(
            children: [
              const Text(
                'Select Class:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedClass,
                  isExpanded: true,
                  underline: Container(),
                  items: _classes.map((String class_) {
                    return DropdownMenuItem<String>(
                      value: class_,
                      child: Text(class_),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedClass = newValue;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search students...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primaryColor),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(List<Map<String, dynamic>> students) {
    final presentCount = students.where((s) => s['isPresent'] == true).length;
    final totalCount = students.length;
    final attendanceRate = totalCount > 0
        ? (presentCount / totalCount * 100).round()
        : 0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Present',
              presentCount.toString(),
              AppTheme.presentColor,
              Icons.check_circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Absent',
              (totalCount - presentCount).toString(),
              AppTheme.absentColor,
              Icons.cancel,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Attendance',
              '$attendanceRate%',
              AppTheme.primaryColor,
              Icons.trending_up,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStudentsList(List<Map<String, dynamic>> students) {
    if (students.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No students found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search criteria',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        return _buildStudentCard(student);
      },
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: student['isPresent']
                  ? AppTheme.presentColor.withOpacity(0.1)
                  : AppTheme.absentColor.withOpacity(0.1),
              child: Icon(
                student['isPresent'] ? Icons.person : Icons.person_outline,
                color: student['isPresent']
                    ? AppTheme.presentColor
                    : AppTheme.absentColor,
              ),
            ),
            title: Text(
              student['name'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Roll: ${student['rollNumber']}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Last seen: ${student['lastSeen']}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: student['isPresent']
                        ? AppTheme.presentColor.withOpacity(0.1)
                        : AppTheme.absentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    student['isPresent'] ? 'Present' : 'Absent',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: student['isPresent']
                          ? AppTheme.presentColor
                          : AppTheme.absentColor,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${student['attendance']}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
            onTap: () {
              // Handle student tap
              _showStudentDetails(student);
            },
          ),
        )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 300))
        .slideX(begin: 0.3);
  }

  List<Map<String, dynamic>> _getFilteredStudents() {
    return _students.where((student) {
      final matchesSearch =
          student['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          student['rollNumber'].toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
      return matchesSearch;
    }).toList();
  }

  void _showStudentDetails(Map<String, dynamic> student) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 40,
              backgroundColor: student['isPresent']
                  ? AppTheme.presentColor.withOpacity(0.1)
                  : AppTheme.absentColor.withOpacity(0.1),
              child: Icon(
                student['isPresent'] ? Icons.person : Icons.person_outline,
                size: 40,
                color: student['isPresent']
                    ? AppTheme.presentColor
                    : AppTheme.absentColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              student['name'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Roll Number: ${student['rollNumber']}',
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              student['email'],
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDetailItem(
                  'Attendance',
                  '${student['attendance']}%',
                  AppTheme.primaryColor,
                ),
                _buildDetailItem(
                  'Status',
                  student['isPresent'] ? 'Present' : 'Absent',
                  student['isPresent']
                      ? AppTheme.presentColor
                      : AppTheme.absentColor,
                ),
                _buildDetailItem(
                  'Last Seen',
                  student['lastSeen'],
                  AppTheme.textSecondaryColor,
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondaryColor,
          ),
        ),
      ],
    );
  }
}
