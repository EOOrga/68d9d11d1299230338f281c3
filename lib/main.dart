import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const bool screenshotMode = bool.fromEnvironment('SCREENSHOT_MODE');

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    BessieresOperationsApp(
      repository: screenshotMode
          ? InMemoryOperationsRepository.seeded()
          : LocalOperationsRepository(),
    ),
  );
}

class BessieresOperationsApp extends StatefulWidget {
  const BessieresOperationsApp({super.key, required this.repository});

  final OperationsRepository repository;

  @override
  State<BessieresOperationsApp> createState() => _BessieresOperationsAppState();
}

class _BessieresOperationsAppState extends State<BessieresOperationsApp> {
  late final OperationsController controller;

  @override
  void initState() {
    super.initState();
    controller = OperationsController(widget.repository)..load();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BESSIERES GERALDINE',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          if (!controller.isReady) {
            return const LoadingScreen();
          }
          return OperationsShell(controller: controller);
        },
      ),
    );
  }
}

ThemeData buildAppTheme() {
  const seed = Color(0xFF8BC34A);
  final scheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.light,
    primary: const Color(0xFF0048B8),
    secondary: const Color(0xFF00A6C8),
    tertiary: const Color(0xFF2E7D32),
    surface: const Color(0xFFF7F9FD),
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: const Color(0xFFF7F9FD),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: Color(0xFFF7F9FD),
      foregroundColor: Color(0xFF001238),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFE0E7F2)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: const Color(0xFFE1EEFF),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFD8E1EF)),
      ),
    ),
  );
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class OperationsShell extends StatefulWidget {
  const OperationsShell({super.key, required this.controller});

  final OperationsController controller;

  @override
  State<OperationsShell> createState() => _OperationsShellState();
}

class _OperationsShellState extends State<OperationsShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardScreen(controller: widget.controller),
      LeadsScreen(controller: widget.controller),
      TeamScreen(controller: widget.controller),
      ContainersScreen(controller: widget.controller),
      SettingsScreen(controller: widget.controller),
    ];

    return Scaffold(
      body: SafeArea(child: pages[index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.space_dashboard_outlined),
            selectedIcon: Icon(Icons.space_dashboard),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.handshake_outlined),
            selectedIcon: Icon(Icons.handshake),
            label: 'Leads',
          ),
          NavigationDestination(
            icon: Icon(Icons.badge_outlined),
            selectedIcon: Icon(Icons.badge),
            label: 'Team',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_shipping_outlined),
            selectedIcon: Icon(Icons.local_shipping),
            label: 'Boxes',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.controller});

  final OperationsController controller;

  @override
  Widget build(BuildContext context) {
    final data = controller.snapshot;
    final openLeads = data.leads.where((lead) => !lead.isClosed).length;
    final activeContainers = data.containers
        .where((container) => container.status != ContainerStatus.delivered)
        .length;
    final scheduled = data.interviews.length;
    final staffed = data.employees
        .where((employee) => employee.availability != 'Out')
        .length;

    return ScreenFrame(
      title: 'BESSIERES GERALDINE',
      subtitle: 'Daily operations command center',
      action: IconButton.filledTonal(
        tooltip: 'Schedule interview',
        onPressed: () => showInterviewSheet(context, controller),
        icon: const Icon(Icons.calendar_month),
      ),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              Image.asset(
                'docs/featured.png',
                height: 136,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Container(
                height: 136,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xDD001238), Color(0x66001238)],
                  ),
                ),
              ),
              const Positioned(
                left: 18,
                top: 20,
                right: 18,
                child: Text(
                  'Interviews, leads, people, and container movements in one local workspace.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        MetricsGrid(
          metrics: [
            Metric('Interviews', '$scheduled', Icons.event_available),
            Metric('Open leads', '$openLeads', Icons.trending_up),
            Metric('Containers', '$activeContainers', Icons.inventory_2),
            Metric('Available', '$staffed', Icons.groups_2),
          ],
        ),
        const SizedBox(height: 14),
        SectionHeader(
          title: 'Priority board',
          actionLabel: 'Add lead',
          onAction: () => showLeadSheet(context, controller),
        ),
        ...data.leads.take(3).map((lead) => LeadCard(lead: lead)),
        const SizedBox(height: 10),
        SectionHeader(
          title: 'Next interviews',
          actionLabel: 'Schedule',
          onAction: () => showInterviewSheet(context, controller),
        ),
        ...data.interviews.take(3).map((interview) {
          return InfoTile(
            icon: Icons.calendar_today,
            title: interview.candidate,
            subtitle:
                '${interview.role} with ${interview.interviewer} - ${interview.when}',
            trailing: interview.stage,
          );
        }),
      ],
    );
  }
}

class LeadsScreen extends StatefulWidget {
  const LeadsScreen({super.key, required this.controller});

  final OperationsController controller;

  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  String stage = 'All';

  @override
  Widget build(BuildContext context) {
    final leads = widget.controller.snapshot.leads.where((lead) {
      return stage == 'All' || lead.stage == stage;
    }).toList();

    return ScreenFrame(
      title: 'Lead pipeline',
      subtitle: 'Track prospects from first contact to agreement',
      action: IconButton.filled(
        tooltip: 'Add lead',
        onPressed: () => showLeadSheet(context, widget.controller),
        icon: const Icon(Icons.add),
      ),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['All', 'New', 'Qualified', 'Proposal', 'Won']
              .map(
                (item) => ChoiceChip(
                  label: Text(item),
                  selected: stage == item,
                  onSelected: (_) => setState(() => stage = item),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 14),
        for (final lead in leads)
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => LeadDetailScreen(
                  controller: widget.controller,
                  leadId: lead.id,
                ),
              ),
            ),
            child: LeadCard(lead: lead),
          ),
      ],
    );
  }
}

class LeadDetailScreen extends StatelessWidget {
  const LeadDetailScreen({
    super.key,
    required this.controller,
    required this.leadId,
  });

  final OperationsController controller;
  final String leadId;

  @override
  Widget build(BuildContext context) {
    final lead = controller.snapshot.leads.firstWhere(
      (item) => item.id == leadId,
      orElse: () => controller.snapshot.leads.first,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Lead detail')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lead.company,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      StatusPill(label: lead.stage),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(lead.contact),
                  const SizedBox(height: 16),
                  Text(lead.note),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    children: ['New', 'Qualified', 'Proposal', 'Won']
                        .map(
                          (stage) => ActionChip(
                            label: Text(stage),
                            onPressed: () {
                              controller.updateLeadStage(lead.id, stage);
                              Navigator.of(context).pop();
                            },
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          InfoTile(
            icon: Icons.assignment_turned_in,
            title: 'Next action',
            subtitle: lead.nextAction,
            trailing: 'Owner',
          ),
        ],
      ),
    );
  }
}

class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key, required this.controller});

  final OperationsController controller;

  @override
  Widget build(BuildContext context) {
    final data = controller.snapshot;
    return ScreenFrame(
      title: 'Employee directory',
      subtitle: 'Coverage, roles, and interview owners',
      action: IconButton.filled(
        tooltip: 'Schedule interview',
        onPressed: () => showInterviewSheet(context, controller),
        icon: const Icon(Icons.add),
      ),
      children: [
        for (final employee in data.employees)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFFE1EEFF),
                    child: Text(employee.initials),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee.name,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text('${employee.role} - ${employee.site}'),
                      ],
                    ),
                  ),
                  StatusPill(label: employee.availability),
                ],
              ),
            ),
          ),
        const SizedBox(height: 10),
        const SectionHeader(title: 'Interview plan'),
        for (final interview in data.interviews)
          InfoTile(
            icon: Icons.record_voice_over,
            title: interview.candidate,
            subtitle: '${interview.role} - ${interview.when}',
            trailing: interview.stage,
          ),
      ],
    );
  }
}

class ContainersScreen extends StatelessWidget {
  const ContainersScreen({super.key, required this.controller});

  final OperationsController controller;

  @override
  Widget build(BuildContext context) {
    return ScreenFrame(
      title: 'Container tracking',
      subtitle: 'Monitor references, routes, and delivery status',
      action: IconButton.filled(
        tooltip: 'Add container',
        onPressed: () => showContainerSheet(context, controller),
        icon: const Icon(Icons.add),
      ),
      children: [
        for (final container in controller.snapshot.containers)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          container.reference,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      StatusPill(label: container.status.label),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text('${container.origin} to ${container.destination}'),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: container.status.progress,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: Text('ETA ${container.eta}')),
                      TextButton.icon(
                        onPressed: () =>
                            controller.advanceContainer(container.id),
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Advance'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.controller});

  final OperationsController controller;

  @override
  Widget build(BuildContext context) {
    return ScreenFrame(
      title: 'Settings & privacy',
      subtitle: 'Local records stay on this device',
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Local workspace',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Leads, interview plans, employee notes, and container records are saved only in local app storage.',
                ),
                const SizedBox(height: 14),
                InfoTile(
                  icon: Icons.lock_outline,
                  title: 'No account or sync',
                  subtitle: 'No login, no cloud account, and no data uploads.',
                  trailing: 'Private',
                ),
                InfoTile(
                  icon: Icons.wifi_off,
                  title: 'Offline first',
                  subtitle: 'The app does not use external APIs or analytics.',
                  trailing: 'Local',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Support',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                ),
                const SizedBox(height: 8),
                const Text('BESSIERES GERALDINE'),
                const Text('support@bessieresgeraldine.com'),
                const SizedBox(height: 12),
                Text(
                  '${controller.snapshot.leads.length} leads, ${controller.snapshot.interviews.length} interviews, ${controller.snapshot.containers.length} containers.',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ScreenFrame extends StatelessWidget {
  const ScreenFrame({
    super.key,
    required this.title,
    required this.subtitle,
    this.action,
    required this.children,
  });

  final String title;
  final String subtitle;
  final Widget? action;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF001238),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle),
                ],
              ),
            ),
            ?action,
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
          if (actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

class MetricsGrid extends StatelessWidget {
  const MetricsGrid({super.key, required this.metrics});

  final List<Metric> metrics;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 1.55,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: metrics.map((metric) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(metric.icon, color: Theme.of(context).colorScheme.primary),
                Text(
                  metric.value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(metric.label),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class Metric {
  const Metric(this.label, this.value, this.icon);

  final String label;
  final String value;
  final IconData icon;
}

class LeadCard extends StatelessWidget {
  const LeadCard({super.key, required this.lead});

  final Lead lead;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    lead.company,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),
                ),
                StatusPill(label: lead.stage),
              ],
            ),
            const SizedBox(height: 8),
            Text(lead.contact),
            const SizedBox(height: 8),
            Text(
              lead.nextAction,
              style: const TextStyle(color: Color(0xFF42526B)),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoTile extends StatelessWidget {
  const InfoTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE1EEFF),
          child: Icon(icon, color: const Color(0xFF0048B8)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
        trailing: StatusPill(label: trailing),
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F2FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFC7DBF8)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
      ),
    );
  }
}

Future<void> showLeadSheet(
  BuildContext context,
  OperationsController controller,
) async {
  final company = TextEditingController();
  final contact = TextEditingController();
  final nextAction = TextEditingController();
  final note = TextEditingController();
  var stage = 'New';
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          return FormSheet(
            title: 'Add lead',
            fields: [
              TextField(
                controller: company,
                decoration: const InputDecoration(labelText: 'Company'),
              ),
              TextField(
                controller: contact,
                decoration: const InputDecoration(labelText: 'Contact'),
              ),
              DropdownButtonFormField<String>(
                initialValue: stage,
                decoration: const InputDecoration(labelText: 'Stage'),
                items: ['New', 'Qualified', 'Proposal', 'Won']
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
                onChanged: (value) => setSheetState(() => stage = value!),
              ),
              TextField(
                controller: nextAction,
                decoration: const InputDecoration(labelText: 'Next action'),
              ),
              TextField(
                controller: note,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 2,
              ),
            ],
            onSave: () {
              controller.addLead(
                company: company.text,
                contact: contact.text,
                stage: stage,
                nextAction: nextAction.text,
                note: note.text,
              );
              Navigator.of(context).pop();
            },
          );
        },
      );
    },
  );
}

Future<void> showInterviewSheet(
  BuildContext context,
  OperationsController controller,
) async {
  final candidate = TextEditingController();
  final role = TextEditingController();
  final interviewer = TextEditingController();
  final when = TextEditingController();
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return FormSheet(
        title: 'Schedule interview',
        fields: [
          TextField(
            controller: candidate,
            decoration: const InputDecoration(labelText: 'Candidate'),
          ),
          TextField(
            controller: role,
            decoration: const InputDecoration(labelText: 'Role'),
          ),
          TextField(
            controller: interviewer,
            decoration: const InputDecoration(labelText: 'Interviewer'),
          ),
          TextField(
            controller: when,
            decoration: const InputDecoration(labelText: 'When'),
          ),
        ],
        onSave: () {
          controller.addInterview(
            candidate: candidate.text,
            role: role.text,
            interviewer: interviewer.text,
            when: when.text,
          );
          Navigator.of(context).pop();
        },
      );
    },
  );
}

Future<void> showContainerSheet(
  BuildContext context,
  OperationsController controller,
) async {
  final reference = TextEditingController();
  final origin = TextEditingController();
  final destination = TextEditingController();
  final eta = TextEditingController();
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return FormSheet(
        title: 'Add container',
        fields: [
          TextField(
            controller: reference,
            decoration: const InputDecoration(labelText: 'Reference'),
          ),
          TextField(
            controller: origin,
            decoration: const InputDecoration(labelText: 'Origin'),
          ),
          TextField(
            controller: destination,
            decoration: const InputDecoration(labelText: 'Destination'),
          ),
          TextField(
            controller: eta,
            decoration: const InputDecoration(labelText: 'ETA'),
          ),
        ],
        onSave: () {
          controller.addContainer(
            reference: reference.text,
            origin: origin.text,
            destination: destination.text,
            eta: eta.text,
          );
          Navigator.of(context).pop();
        },
      );
    },
  );
}

class FormSheet extends StatelessWidget {
  const FormSheet({
    super.key,
    required this.title,
    required this.fields,
    required this.onSave,
  });

  final String title;
  final List<Widget> fields;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 18,
        bottom: MediaQuery.of(context).viewInsets.bottom + 18,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            for (final field in fields) ...[field, const SizedBox(height: 10)],
            FilledButton.icon(
              onPressed: onSave,
              icon: const Icon(Icons.save),
              label: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class OperationsController extends ChangeNotifier {
  OperationsController(this.repository);

  final OperationsRepository repository;
  OperationsSnapshot snapshot = OperationsSnapshot.empty();
  bool isReady = false;

  Future<void> load() async {
    snapshot = await repository.load();
    isReady = true;
    notifyListeners();
  }

  Future<void> addLead({
    required String company,
    required String contact,
    required String stage,
    required String nextAction,
    required String note,
  }) async {
    final value = Lead(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      company: company.trim().isEmpty ? 'New opportunity' : company.trim(),
      contact: contact.trim().isEmpty ? 'Contact pending' : contact.trim(),
      stage: stage,
      nextAction: nextAction.trim().isEmpty
          ? 'Set next follow-up'
          : nextAction.trim(),
      note: note.trim().isEmpty ? 'No note added yet.' : note.trim(),
    );
    snapshot = snapshot.copyWith(leads: [value, ...snapshot.leads]);
    await repository.save(snapshot);
    notifyListeners();
  }

  Future<void> updateLeadStage(String id, String stage) async {
    snapshot = snapshot.copyWith(
      leads: snapshot.leads
          .map((lead) => lead.id == id ? lead.copyWith(stage: stage) : lead)
          .toList(),
    );
    await repository.save(snapshot);
    notifyListeners();
  }

  Future<void> addInterview({
    required String candidate,
    required String role,
    required String interviewer,
    required String when,
  }) async {
    final value = Interview(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      candidate: candidate.trim().isEmpty ? 'Candidate name' : candidate.trim(),
      role: role.trim().isEmpty ? 'Operations role' : role.trim(),
      interviewer: interviewer.trim().isEmpty
          ? 'BESSIERES GERALDINE'
          : interviewer.trim(),
      when: when.trim().isEmpty ? 'Tomorrow 09:00' : when.trim(),
      stage: 'Planned',
    );
    snapshot = snapshot.copyWith(interviews: [value, ...snapshot.interviews]);
    await repository.save(snapshot);
    notifyListeners();
  }

  Future<void> addContainer({
    required String reference,
    required String origin,
    required String destination,
    required String eta,
  }) async {
    final value = ContainerRecord(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      reference: reference.trim().isEmpty
          ? 'CNT-${snapshot.containers.length + 1}'
          : reference.trim(),
      origin: origin.trim().isEmpty ? 'Origin site' : origin.trim(),
      destination: destination.trim().isEmpty
          ? 'Destination site'
          : destination.trim(),
      eta: eta.trim().isEmpty ? 'This week' : eta.trim(),
      status: ContainerStatus.booked,
    );
    snapshot = snapshot.copyWith(containers: [value, ...snapshot.containers]);
    await repository.save(snapshot);
    notifyListeners();
  }

  Future<void> advanceContainer(String id) async {
    snapshot = snapshot.copyWith(
      containers: snapshot.containers.map((container) {
        if (container.id != id) {
          return container;
        }
        return container.copyWith(status: container.status.next);
      }).toList(),
    );
    await repository.save(snapshot);
    notifyListeners();
  }
}

abstract class OperationsRepository {
  Future<OperationsSnapshot> load();
  Future<void> save(OperationsSnapshot snapshot);
}

class LocalOperationsRepository implements OperationsRepository {
  static const key = 'bessieres_operations_state_v1';

  LocalOperationsRepository({DeviceLocalStore? store})
    : store = store ?? const DeviceLocalStore();

  final DeviceLocalStore store;

  @override
  Future<OperationsSnapshot> load() async {
    final encoded = await store.read(key);
    if (encoded == null) {
      return OperationsSnapshot.seeded();
    }
    try {
      return OperationsSnapshot.fromJson(jsonDecode(encoded));
    } on FormatException {
      return OperationsSnapshot.seeded();
    } on TypeError {
      return OperationsSnapshot.seeded();
    }
  }

  @override
  Future<void> save(OperationsSnapshot snapshot) async {
    await store.write(key, jsonEncode(snapshot.toJson()));
  }
}

class DeviceLocalStore {
  const DeviceLocalStore();

  static const _channel = MethodChannel(
    'com.bessieresgeraldine.operations/local_store',
  );
  static final Map<String, String> _memory = {};

  Future<String?> read(String key) async {
    if (kIsWeb) {
      return _memory[key];
    }
    try {
      return await _channel.invokeMethod<String>('read', {'key': key});
    } on MissingPluginException {
      return _memory[key];
    } on PlatformException {
      return _memory[key];
    }
  }

  Future<void> write(String key, String value) async {
    if (kIsWeb) {
      _memory[key] = value;
      return;
    }
    try {
      await _channel.invokeMethod<void>('write', {'key': key, 'value': value});
    } on MissingPluginException {
      _memory[key] = value;
    } on PlatformException {
      _memory[key] = value;
    }
  }
}

class InMemoryOperationsRepository implements OperationsRepository {
  InMemoryOperationsRepository(this.snapshot);

  factory InMemoryOperationsRepository.seeded() {
    return InMemoryOperationsRepository(OperationsSnapshot.seeded());
  }

  OperationsSnapshot snapshot;

  @override
  Future<OperationsSnapshot> load() async => snapshot;

  @override
  Future<void> save(OperationsSnapshot snapshot) async {
    this.snapshot = snapshot;
  }
}

class OperationsSnapshot {
  const OperationsSnapshot({
    required this.leads,
    required this.interviews,
    required this.employees,
    required this.containers,
  });

  final List<Lead> leads;
  final List<Interview> interviews;
  final List<Employee> employees;
  final List<ContainerRecord> containers;

  factory OperationsSnapshot.empty() {
    return const OperationsSnapshot(
      leads: [],
      interviews: [],
      employees: [],
      containers: [],
    );
  }

  factory OperationsSnapshot.seeded() {
    return OperationsSnapshot(
      leads: const [
        Lead(
          id: 'lead-1',
          company: 'Nord Port Services',
          contact: 'Claire Martin - Logistics buyer',
          stage: 'Proposal',
          nextAction: 'Send revised staffing quote before 16:00',
          note: 'Needs coverage for evening container intake.',
        ),
        Lead(
          id: 'lead-2',
          company: 'Atelier Roche',
          contact: 'Romain Pelissier - Site manager',
          stage: 'Qualified',
          nextAction: 'Confirm interview slots for forklift team',
          note: 'Prefers a single weekly operations review.',
        ),
        Lead(
          id: 'lead-3',
          company: 'Transit Bleu',
          contact: 'Nadia Blanc - Operations lead',
          stage: 'New',
          nextAction: 'Prepare first call checklist',
          note: 'Requested employee directory and shift coverage details.',
        ),
      ],
      interviews: const [
        Interview(
          id: 'int-1',
          candidate: 'Malo Garnier',
          role: 'Warehouse coordinator',
          interviewer: 'Geraldine',
          when: 'Today 10:30',
          stage: 'Confirmed',
        ),
        Interview(
          id: 'int-2',
          candidate: 'Lea Moreau',
          role: 'Lead dispatcher',
          interviewer: 'Camille',
          when: 'Today 14:00',
          stage: 'Prep',
        ),
        Interview(
          id: 'int-3',
          candidate: 'Hugo Perez',
          role: 'Container clerk',
          interviewer: 'Geraldine',
          when: 'Tomorrow 09:15',
          stage: 'Planned',
        ),
      ],
      employees: const [
        Employee(
          id: 'emp-1',
          name: 'Camille Laurent',
          role: 'Lead dispatcher',
          site: 'Bessieres HQ',
          availability: 'On site',
          initials: 'CL',
        ),
        Employee(
          id: 'emp-2',
          name: 'Sofia Bernard',
          role: 'Recruiting coordinator',
          site: 'Remote desk',
          availability: 'Available',
          initials: 'SB',
        ),
        Employee(
          id: 'emp-3',
          name: 'Jules Caron',
          role: 'Container supervisor',
          site: 'North yard',
          availability: 'Yard',
          initials: 'JC',
        ),
        Employee(
          id: 'emp-4',
          name: 'Emma Girard',
          role: 'Operations assistant',
          site: 'Client intake',
          availability: 'Out',
          initials: 'EG',
        ),
      ],
      containers: const [
        ContainerRecord(
          id: 'box-1',
          reference: 'BSG-2047',
          origin: 'Le Havre',
          destination: 'Toulouse yard',
          eta: 'May 14',
          status: ContainerStatus.inTransit,
        ),
        ContainerRecord(
          id: 'box-2',
          reference: 'BSG-2052',
          origin: 'Marseille',
          destination: 'Client dock 3',
          eta: 'May 15',
          status: ContainerStatus.customs,
        ),
        ContainerRecord(
          id: 'box-3',
          reference: 'BSG-2056',
          origin: 'Lyon depot',
          destination: 'Bessieres HQ',
          eta: 'May 18',
          status: ContainerStatus.booked,
        ),
      ],
    );
  }

  OperationsSnapshot copyWith({
    List<Lead>? leads,
    List<Interview>? interviews,
    List<Employee>? employees,
    List<ContainerRecord>? containers,
  }) {
    return OperationsSnapshot(
      leads: leads ?? this.leads,
      interviews: interviews ?? this.interviews,
      employees: employees ?? this.employees,
      containers: containers ?? this.containers,
    );
  }

  factory OperationsSnapshot.fromJson(Map<String, dynamic> json) {
    return OperationsSnapshot(
      leads: (json['leads'] as List<dynamic>? ?? [])
          .map((item) => Lead.fromJson(item))
          .toList(),
      interviews: (json['interviews'] as List<dynamic>? ?? [])
          .map((item) => Interview.fromJson(item))
          .toList(),
      employees: (json['employees'] as List<dynamic>? ?? [])
          .map((item) => Employee.fromJson(item))
          .toList(),
      containers: (json['containers'] as List<dynamic>? ?? [])
          .map((item) => ContainerRecord.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'leads': leads.map((item) => item.toJson()).toList(),
      'interviews': interviews.map((item) => item.toJson()).toList(),
      'employees': employees.map((item) => item.toJson()).toList(),
      'containers': containers.map((item) => item.toJson()).toList(),
    };
  }
}

class Lead {
  const Lead({
    required this.id,
    required this.company,
    required this.contact,
    required this.stage,
    required this.nextAction,
    required this.note,
  });

  final String id;
  final String company;
  final String contact;
  final String stage;
  final String nextAction;
  final String note;

  bool get isClosed => stage == 'Won';

  Lead copyWith({String? stage}) {
    return Lead(
      id: id,
      company: company,
      contact: contact,
      stage: stage ?? this.stage,
      nextAction: nextAction,
      note: note,
    );
  }

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      id: json['id'] as String,
      company: json['company'] as String,
      contact: json['contact'] as String,
      stage: json['stage'] as String,
      nextAction: json['nextAction'] as String,
      note: json['note'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company': company,
      'contact': contact,
      'stage': stage,
      'nextAction': nextAction,
      'note': note,
    };
  }
}

class Interview {
  const Interview({
    required this.id,
    required this.candidate,
    required this.role,
    required this.interviewer,
    required this.when,
    required this.stage,
  });

  final String id;
  final String candidate;
  final String role;
  final String interviewer;
  final String when;
  final String stage;

  factory Interview.fromJson(Map<String, dynamic> json) {
    return Interview(
      id: json['id'] as String,
      candidate: json['candidate'] as String,
      role: json['role'] as String,
      interviewer: json['interviewer'] as String,
      when: json['when'] as String,
      stage: json['stage'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'candidate': candidate,
      'role': role,
      'interviewer': interviewer,
      'when': when,
      'stage': stage,
    };
  }
}

class Employee {
  const Employee({
    required this.id,
    required this.name,
    required this.role,
    required this.site,
    required this.availability,
    required this.initials,
  });

  final String id;
  final String name;
  final String role;
  final String site;
  final String availability;
  final String initials;

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      site: json['site'] as String,
      availability: json['availability'] as String,
      initials: json['initials'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'site': site,
      'availability': availability,
      'initials': initials,
    };
  }
}

enum ContainerStatus {
  booked('Booked', .18),
  inTransit('In transit', .48),
  customs('Customs', .72),
  delivered('Delivered', 1);

  const ContainerStatus(this.label, this.progress);

  final String label;
  final double progress;

  ContainerStatus get next {
    switch (this) {
      case ContainerStatus.booked:
        return ContainerStatus.inTransit;
      case ContainerStatus.inTransit:
        return ContainerStatus.customs;
      case ContainerStatus.customs:
        return ContainerStatus.delivered;
      case ContainerStatus.delivered:
        return ContainerStatus.booked;
    }
  }
}

class ContainerRecord {
  const ContainerRecord({
    required this.id,
    required this.reference,
    required this.origin,
    required this.destination,
    required this.eta,
    required this.status,
  });

  final String id;
  final String reference;
  final String origin;
  final String destination;
  final String eta;
  final ContainerStatus status;

  ContainerRecord copyWith({ContainerStatus? status}) {
    return ContainerRecord(
      id: id,
      reference: reference,
      origin: origin,
      destination: destination,
      eta: eta,
      status: status ?? this.status,
    );
  }

  factory ContainerRecord.fromJson(Map<String, dynamic> json) {
    return ContainerRecord(
      id: json['id'] as String,
      reference: json['reference'] as String,
      origin: json['origin'] as String,
      destination: json['destination'] as String,
      eta: json['eta'] as String,
      status: ContainerStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => ContainerStatus.booked,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference': reference,
      'origin': origin,
      'destination': destination,
      'eta': eta,
      'status': status.name,
    };
  }
}
