import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class RemindersScreen extends StatefulWidget {
  @override
  _RemindersScreenState createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Box remindersBox;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initHive();
  }

  Future<void> _initHive() async {
    remindersBox = await Hive.openBox('reminders');
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _addReminder(HealthReminder reminder) async {
    await remindersBox.add(reminder.toMap());
    setState(() {});
  }

  List<HealthReminder> _getReminders(ReminderType type) {
    return remindersBox.values
        .map((data) => HealthReminder.fromMap(Map<String, dynamic>.from(data)))
        .where((reminder) => reminder.type == type)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text('Health Reminders', style: TextStyle(color: Colors.black87)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: [
            Tab(text: 'Medications'),
            Tab(text: 'Appointments'),
            Tab(text: 'Activities'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReminderList(ReminderType.medication),
          _buildReminderList(ReminderType.appointment),
          _buildReminderList(ReminderType.activity),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddReminderDialog(context),
        child: Icon(Icons.add),
        tooltip: 'Add Reminder',
      ),
    );
  }

  Widget _buildReminderList(ReminderType type) {
    final reminders = _getReminders(type);
    return ListView(
      padding: EdgeInsets.all(16),
      children: reminders.map((reminder) => _buildReminderCard(reminder)).toList(),
    );
  }

  Widget _buildReminderCard(HealthReminder reminder) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: ListTile(
        leading: _buildReminderIcon(reminder),
        title: Text(reminder.title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_formatTime(reminder.time)),
            if (reminder.dosage != null) Text('Dosage: ${reminder.dosage}'),
            if (reminder.notes != null) Text(reminder.notes!),
          ],
        ),
        trailing: Switch(
          value: reminder.isActive,
          onChanged: (bool value) {
            setState(() {
              reminder.isActive = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildReminderIcon(HealthReminder reminder) {
    IconData icon;
    Color color;

    switch (reminder.type) {
      case ReminderType.medication:
        icon = Icons.medication;
        color = Colors.blue;
        break;
      case ReminderType.appointment:
        icon = Icons.calendar_today;
        color = Colors.purple;
        break;
      case ReminderType.activity:
        icon = Icons.directions_run;
        color = Colors.green;
        break;
    }

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color),
    );
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat.jm();
    return format.format(dt);
  }

  void _showAddReminderDialog(BuildContext context) {
    String title = '';
    ReminderType? type;
    TimeOfDay? time;
    DateTime? date;
    String? dosage;
    String? notes;
    String frequency = 'Daily';
    Set<int> daysOfWeek = {};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add New Reminder', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(labelText: 'Title'),
              onChanged: (value) => title = value,
            ),
            DropdownButtonFormField<ReminderType>(
              decoration: InputDecoration(labelText: 'Type'),
              items: ReminderType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.toString().split('.').last),
                );
              }).toList(),
              onChanged: (value) => type = value,
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Time',
                suffixIcon: Icon(Icons.access_time),
              ),
              readOnly: true,
              onTap: () async {
                final selectedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                if (selectedTime != null) setState(() => time = selectedTime);
              },
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Date',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (selectedDate != null) setState(() => date = selectedDate);
              },
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Dosage (optional)'),
              onChanged: (value) => dosage = value,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Notes (optional)'),
              onChanged: (value) => notes = value,
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Frequency'),
              value: frequency,
              items: ['Daily', 'Weekly', 'Monthly'].map((freq) {
                return DropdownMenuItem(
                  value: freq,
                  child: Text(freq),
                );
              }).toList(),
              onChanged: (value) => frequency = value!,
            ),
            ElevatedButton(
              onPressed: () {
                if (type != null && time != null) {
                  final newReminder = HealthReminder(
                    title: title,
                    time: time!,
                    type: type!,
                    frequency: frequency,
                    dosage: dosage,
                    notes: notes,
                    date: date,
                    daysOfWeek: daysOfWeek,
                    isActive: true,
                  );
                  _addReminder(newReminder);
                  Navigator.pop(context);
                }
              },
              child: Text('Save Reminder'),
            ),
          ],
        ),
      ),
    );
  }
}

enum ReminderType { medication, appointment, activity }

class HealthReminder {
  final String title;
  final TimeOfDay time;
  final ReminderType type;
  final String frequency;
  final String? dosage;
  final String? notes;
  final DateTime? date;
  bool isActive;
  final Set<int> daysOfWeek;
  final Duration? repeatInterval;

  HealthReminder({
    required this.title,
    required this.time,
    required this.type,
    required this.frequency,
    this.dosage,
    this.notes,
    this.date,
    this.isActive = true,
    this.daysOfWeek = const {},
    this.repeatInterval,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'time': {'hour': time.hour, 'minute': time.minute},
      'type': type.index,
      'frequency': frequency,
      'dosage': dosage,
      'notes': notes,
      'date': date?.toIso8601String(),
      'isActive': isActive,
      'daysOfWeek': daysOfWeek.toList(),
    };
  }

  static HealthReminder fromMap(Map<String, dynamic> map) {
    return HealthReminder(
      title: map['title'],
      time: TimeOfDay(hour: map['time']['hour'], minute: map['time']['minute']),
      type: ReminderType.values[map['type']],
      frequency: map['frequency'],
      dosage: map['dosage'],
      notes: map['notes'],
      date: map['date'] != null ? DateTime.parse(map['date']) : null,
      isActive: map['isActive'],
      daysOfWeek: Set<int>.from(map['daysOfWeek'] ?? []),
    );
  }
}

