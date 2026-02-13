import 'package:flutter/material.dart';
import 'package:impactguide/models/accident_report.dart';
import 'package:impactguide/models/client_case.dart';
import 'package:impactguide/screens/emergency_response_screen.dart';
import 'package:impactguide/services/local_storage_service.dart';
import 'package:impactguide/widgets/case_timeline.dart';
import 'package:impactguide/widgets/legal_disclaimer_bar.dart';

class CaseManagementScreen extends StatefulWidget {
  const CaseManagementScreen({super.key});

  @override
  State<CaseManagementScreen> createState() => _CaseManagementScreenState();
}

class _CaseManagementScreenState extends State<CaseManagementScreen> {
  List<ClientCase> _cases = [];
  List<AccidentReport> _accidentReports = [];
  bool _isLoading = true;

  static const String _casesDisclaimerText =
      "No information presented within this mobile app should be considered formal legal advice or the formation of a privileged lawyer/attorney-client relationship. When you submit your accident information, we're reviewing it to see if you have a case.";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final cases = await LocalStorageService().getClientCases();
    final reports = await LocalStorageService().getAccidentReports();
    setState(() {
      _cases = cases;
      _accidentReports = reports;
      _isLoading = false;
    });
  }

  Future<void> _startNewCaseFlow() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const EmergencyResponseScreen()),
    );
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accident Reports'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cases.isEmpty
              ? _buildEmptyState()
              : _buildCasesList(),
      bottomNavigationBar: const LegalDisclaimerBar(text: _casesDisclaimerText),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'casesFab',
        onPressed: _startNewCaseFlow,
        icon: const Icon(Icons.add),
        label: const Text('New Report'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Accident Reports Yet',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create an accident report and we’ll keep everything organized here.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCasesList() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16 + LegalDisclaimerBar.preferredHeight,
        ),
        itemCount: _cases.length,
        itemBuilder: (context, index) {
          final clientCase = _cases[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              onTap: () => _showCaseDetails(clientCase),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getStatusIcon(clientCase.status),
                          color: _getStatusColor(clientCase.status),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            clientCase.clientName,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        _StatusChip(status: clientCase.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Report ID: ${clientCase.id}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Created: ${_formatDate(clientCase.createdAt)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.phone,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          clientCase.clientPhone,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.email,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            clientCase.clientEmail,
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: _calculateProgress(clientCase.milestones),
                      backgroundColor: Colors.grey[300],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(_calculateProgress(clientCase.milestones) * 100).toInt()}% Complete',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCaseDetails(ClientCase clientCase) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: true,
      isDismissible: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.88,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => _CaseDetailsSheet(
          clientCase: clientCase,
          scrollController: scrollController,
        ),
      ),
    );
  }

  IconData _getStatusIcon(CaseStatus status) {
    switch (status) {
      case CaseStatus.intake:
        return Icons.assignment;
      case CaseStatus.active:
        return Icons.work;
      case CaseStatus.negotiating:
        return Icons.handshake;
      case CaseStatus.settled:
        return Icons.check_circle;
      case CaseStatus.closed:
        return Icons.archive;
    }
  }

  Color _getStatusColor(CaseStatus status) {
    switch (status) {
      case CaseStatus.intake:
        return Colors.orange;
      case CaseStatus.active:
        return Colors.blue;
      case CaseStatus.negotiating:
        return Colors.purple;
      case CaseStatus.settled:
        return Colors.green;
      case CaseStatus.closed:
        return Colors.grey;
    }
  }

  double _calculateProgress(List<CaseMilestone> milestones) {
    if (milestones.isEmpty) return 0.0;
    final completed = milestones.where((m) => m.isCompleted).length;
    return completed / milestones.length;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatusChip extends StatelessWidget {
  final CaseStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        _getStatusText(),
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: _getStatusColor().withValues(alpha: 0.2),
      side: BorderSide(color: _getStatusColor()),
    );
  }

  String _getStatusText() {
    switch (status) {
      case CaseStatus.intake:
        return 'Intake';
      case CaseStatus.active:
        return 'Active';
      case CaseStatus.negotiating:
        return 'Negotiating';
      case CaseStatus.settled:
        return 'Settled';
      case CaseStatus.closed:
        return 'Closed';
    }
  }

  Color _getStatusColor() {
    switch (status) {
      case CaseStatus.intake:
        return Colors.orange;
      case CaseStatus.active:
        return Colors.blue;
      case CaseStatus.negotiating:
        return Colors.purple;
      case CaseStatus.settled:
        return Colors.green;
      case CaseStatus.closed:
        return Colors.grey;
    }
  }
}

class _CaseDetailsSheet extends StatelessWidget {
  final ClientCase clientCase;
  final ScrollController scrollController;

  const _CaseDetailsSheet({
    required this.clientCase,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Top bar with close
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                const SizedBox(width: 40), // balances the close button width
                Expanded(
                  child: Center(
                    child: Text(
                      'Accident Report Details',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          clientCase.clientName,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      _StatusChip(status: clientCase.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Report #${clientCase.id}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),

                  const SizedBox(height: 24),

                  // Contact Information
                  _SectionTitle('Contact Information'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _InfoRow(
                              Icons.phone, 'Phone', clientCase.clientPhone),
                          const SizedBox(height: 8),
                          _InfoRow(
                              Icons.email, 'Email', clientCase.clientEmail),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  _SectionTitle('Report Progress'),
                  CaseTimelineWidget(milestones: clientCase.milestones),

                  const SizedBox(height: 16),

                  // Recent Communications
                  _SectionTitle('Recent Communications'),
                  ...clientCase.communications
                      .take(3)
                      .map((comm) => _CommunicationTile(communication: comm)),

                  const SizedBox(height: 16),

                  // Attorney Notes
                  if (clientCase.attorneyNotes.isNotEmpty) ...[
                    _SectionTitle('Attorney Notes'),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          clientCase.attorneyNotes,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _CommunicationTile extends StatelessWidget {
  final CommunicationEntry communication;

  const _CommunicationTile({required this.communication});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              communication.fromClient ? Colors.blue : Colors.green,
          child: Icon(
            communication.fromClient ? Icons.person : Icons.gavel,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          communication.fromClient ? 'You' : 'Attorney',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          communication.message,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          _formatTime(communication.timestamp),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }
}
