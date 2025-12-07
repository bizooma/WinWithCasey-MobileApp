import 'package:flutter/material.dart';
import '../models/medical_record.dart';
import '../services/local_storage_service.dart';

class MedicalTrackingScreen extends StatefulWidget {
  const MedicalTrackingScreen({super.key});

  @override
  State<MedicalTrackingScreen> createState() => _MedicalTrackingScreenState();
}

class _MedicalTrackingScreenState extends State<MedicalTrackingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<MedicalAppointment> _appointments = [];
  List<MedicalRecord> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final appointments = await LocalStorageService().getMedicalAppointments();
    final records = await LocalStorageService().getMedicalRecords();
    setState(() {
      _appointments = appointments;
      _records = records;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Tracking'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Appointments'),
            Tab(text: 'Records'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAppointmentsTab(),
                _buildRecordsTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'medicalFab',
        onPressed: _showAddOptions,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }

  Widget _buildAppointmentsTab() {
    if (_appointments.isEmpty) {
      return _buildEmptyState(
        icon: Icons.calendar_today,
        title: 'No Appointments',
        subtitle: 'Track your medical appointments here',
      );
    }

    final upcomingAppointments = _appointments
        .where((apt) => !apt.isCompleted && apt.scheduledDate.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

    final pastAppointments = _appointments
        .where((apt) => apt.isCompleted || apt.scheduledDate.isBefore(DateTime.now()))
        .toList()
      ..sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (upcomingAppointments.isNotEmpty) ...[
            Text(
              'Upcoming Appointments',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...upcomingAppointments.map((apt) => _AppointmentCard(
              appointment: apt,
              onTap: () => _showAppointmentDetails(apt),
            )),
            const SizedBox(height: 16),
          ],
          if (pastAppointments.isNotEmpty) ...[
            Text(
              'Past Appointments',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...pastAppointments.map((apt) => _AppointmentCard(
              appointment: apt,
              onTap: () => _showAppointmentDetails(apt),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildRecordsTab() {
    if (_records.isEmpty) {
      return _buildEmptyState(
        icon: Icons.description,
        title: 'No Medical Records',
        subtitle: 'Document your medical visits and treatments',
      );
    }

    final sortedRecords = List<MedicalRecord>.from(_records)
      ..sort((a, b) => b.date.compareTo(a.date));

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sortedRecords.length,
        itemBuilder: (context, index) {
          final record = sortedRecords[index];
          return _MedicalRecordCard(
            record: record,
            onTap: () => _showRecordDetails(record),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Schedule Appointment'),
              onTap: () {
                Navigator.pop(context);
                _showAddAppointment();
              },
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Add Medical Record'),
              onTap: () {
                Navigator.pop(context);
                _showAddRecord();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAppointmentDetails(MedicalAppointment appointment) {
    // Implementation for showing appointment details
  }

  void _showRecordDetails(MedicalRecord record) {
    // Implementation for showing record details
  }

  void _showAddAppointment() {
    // Implementation for adding appointment
  }

  void _showAddRecord() {
    // Implementation for adding record
  }
}

class _AppointmentCard extends StatelessWidget {
  final MedicalAppointment appointment;
  final VoidCallback onTap;

  const _AppointmentCard({
    required this.appointment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUpcoming = appointment.scheduledDate.isAfter(DateTime.now()) && !appointment.isCompleted;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isUpcoming ? Icons.schedule : Icons.check_circle,
                    color: isUpcoming ? Colors.orange : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      appointment.appointmentType,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                appointment.providerName,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDateTime(appointment.scheduledDate),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      appointment.address,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.phone,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    appointment.phoneNumber,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _MedicalRecordCard extends StatelessWidget {
  final MedicalRecord record;
  final VoidCallback onTap;

  const _MedicalRecordCard({
    required this.record,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.medical_services,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      record.appointmentType,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  _PainLevelIndicator(painLevel: record.painLevel),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                record.providerName,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(record.date),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Symptoms: ${record.symptoms}',
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Treatment: ${record.treatment}',
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (record.cost != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    Text(
                      '\$${record.cost!.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      record.insuranceCovered ? Icons.check : Icons.close,
                      size: 16,
                      color: record.insuranceCovered ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      record.insuranceCovered ? 'Covered' : 'Not Covered',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _PainLevelIndicator extends StatelessWidget {
  final int painLevel;

  const _PainLevelIndicator({required this.painLevel});

  @override
  Widget build(BuildContext context) {
    Color color;
    if (painLevel <= 3) {
      color = Colors.green;
    } else if (painLevel <= 6) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        'Pain: $painLevel/10',
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}