import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../helpers/database_helper.dart';
import '../../models/task.dart';
import '../../models/user.dart';

class PriorityTab extends StatefulWidget {
  final int userId;

  PriorityTab({required this.userId});

  @override
  _PriorityTabState createState() => _PriorityTabState();
}

class _PriorityTabState extends State<PriorityTab> {
  List<Task> _allTasks = [];
  List<Task> _filteredTasks = [];
  bool _isLoading = true;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = await DatabaseHelper.instance.getUserById(widget.userId);
      final tasks = await DatabaseHelper.instance.getTasksByUserId(widget.userId);

      // Sort by priority (high first) then by date
      tasks.sort((a, b) {
        if (a.priority == 'high' && b.priority == 'low') return -1;
        if (a.priority == 'low' && b.priority == 'high') return 1;
        return a.dateTime.compareTo(b.dateTime);
      });

      setState(() {
        _currentUser = user;
        _allTasks = tasks;
        _filteredTasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterTasks(String query) {
    final lowerQuery = query.toLowerCase();
    final filtered = _allTasks.where((task) {
      return task.title.toLowerCase().contains(lowerQuery) ||
          task.description.toLowerCase().contains(lowerQuery) ||
          task.priority.toLowerCase().contains(lowerQuery);
    }).toList();

    setState(() {
      _filteredTasks = filtered;
    });
  }

  Future<void> _updateTaskPriority(Task task, String newPriority) async {
    final updatedTask = Task(
      id: task.id,
      title: task.title,
      description: task.description,
      dateTime: task.dateTime,
      isCompleted: task.isCompleted,
      priority: newPriority,
      userId: task.userId,
    );

    await DatabaseHelper.instance.updateTask(updatedTask);
    _loadData();
  }

  Future<void> _toggleTaskCompletion(Task task) async {
    final updatedTask = Task(
      id: task.id,
      title: task.title,
      description: task.description,
      dateTime: task.dateTime,
      isCompleted: !task.isCompleted,
      priority: task.priority,
      userId: task.userId,
    );

    await DatabaseHelper.instance.updateTask(updatedTask);
    _loadData();
  }

  Widget _buildTasksByDate() {
    Map<String, List<Task>> tasksByDate = {};

    for (Task task in _filteredTasks) {
      String dateKey = DateFormat('EEEE, dd MMMM').format(task.dateTime);
      if (tasksByDate[dateKey] == null) {
        tasksByDate[dateKey] = [];
      }
      tasksByDate[dateKey]!.add(task);
    }

    return ListView.builder(
      itemCount: tasksByDate.keys.length,
      itemBuilder: (context, index) {
        String dateKey = tasksByDate.keys.elementAt(index);
        List<Task> tasks = tasksByDate[dateKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 5),
              child: Text(
                dateKey,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            ...tasks.map((task) => Container(
              margin: EdgeInsets.only(bottom: 10),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _toggleTaskCompletion(task),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: task.isCompleted
                              ? Colors.green
                              : Colors.grey,
                          width: 2,
                        ),
                        color: task.isCompleted
                            ? Colors.green
                            : Colors.transparent,
                      ),
                      child: task.isCompleted
                          ? Icon(
                        Icons.check,
                        size: 14,
                        color: Colors.white,
                      )
                          : null,
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        if (task.description.isNotEmpty)
                          Text(
                            task.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          String newPriority = task.priority == 'high' ? 'low' : 'high';
                          _updateTaskPriority(task, newPriority);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: task.priority == 'high'
                                ? Colors.red
                                : Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            task.priority.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        DateFormat('HH:mm').format(task.dateTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )).toList(),
          ],
        );
      },
    );
  }

  String _getGreetingMessage() {
    final hour = DateTime.now().hour;

    if (hour >= 6 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 18) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE3F2FD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_getGreetingMessage()}, ${_currentUser?.username ?? 'User'}',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(
              Icons.notifications_outlined,
              color: Colors.black87,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'search task...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(15),
                ),
                onChanged: _filterTasks,
              ),
            ),
            SizedBox(height: 30),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _filteredTasks.isEmpty
                  ? Center(
                child: Text(
                  'No tasks available',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              )
                  : _buildTasksByDate(),
            ),
          ],
        ),
      ),
    );
  }
}
