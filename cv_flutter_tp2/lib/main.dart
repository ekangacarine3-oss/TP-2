import 'package:flutter/material.dart';
import 'data/cv_data.dart';
import 'models/famille_membre.dart';
import 'services/api_service.dart';

void main() {
  runApp(const MonCvApp());
}

class MonCvApp extends StatefulWidget {
  const MonCvApp({super.key});

  @override
  State<MonCvApp> createState() => _MonCvAppState();
}

class _MonCvAppState extends State<MonCvApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    const primarySeed = Color(0xFF0F294A);

    return MaterialApp(
      title: 'Mon CV & Famille — TP2 Premium',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primarySeed,
          secondary: const Color(0xFFD97706),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F7FB),
        cardTheme: CardTheme(
          elevation: 1.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          filled: true,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primarySeed,
          secondary: const Color(0xFFF59E0B),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          filled: true,
        ),
      ),
      home: LoginPage(
        isDarkMode: _themeMode == ThemeMode.dark,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

// ============================================================================
// ÉCRAN 1 : CONNEXION / INSCRIPTION PREMIUM
// ============================================================================

class LoginPage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const LoginPage({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isRegisterMode = false;
  bool _obscurePassword = true;
  String? _statusMessage;
  bool _statusIsError = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _statusMessage = null;
      _statusIsError = false;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final result = _isRegisterMode
        ? await ApiService.inscrire(email, password)
        : await ApiService.seConnecter(email, password);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      if (_isRegisterMode) {
        setState(() {
          _isRegisterMode = false;
          _statusMessage =
              'Compte créé avec succès ! Vous pouvez maintenant vous connecter.';
          _statusIsError = false;
        });
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => MainNavigation(
              userEmail: email,
              isDarkMode: widget.isDarkMode,
              onToggleTheme: widget.onToggleTheme,
            ),
          ),
        );
      }
    } else {
      setState(() {
        _statusMessage = result.message;
        _statusIsError = true;
      });
    }
  }

  Future<void> _testApi() async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });
    final result = await ApiService.testerConnexion();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _statusMessage = result.message;
      _statusIsError = !result.success;
    });
  }

  Future<void> _showServerConfigDialog() async {
    final controller = TextEditingController(text: ApiService.baseUrl);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Configuration du serveur API'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Windows (XAMPP) : http://localhost/api-test/public\n'
                'Émulateur Android : http://10.0.2.2/api-test/public\n'
                'Téléphone physique : http://IP_DU_PC/api-test/public',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'URL de base de l\'API',
                  prefixIcon: Icon(Icons.link),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                final clean = controller.text.trim().replaceAll(RegExp(r'/+$'), '');
                if (clean.isNotEmpty) {
                  setState(() => ApiService.baseUrl = clean);
                }
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TP2 Flutter — ISIG GOMA'),
        actions: [
          IconButton(
            tooltip: 'Changer le thème',
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
          ),
          IconButton(
            tooltip: 'Configurer l\'URL API',
            icon: const Icon(Icons.settings_ethernet),
            onPressed: _showServerConfigDialog,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.isDarkMode
                ? [const Color(0xFF0B1220), const Color(0xFF152238)]
                : [const Color(0xFFEAF0F8), const Color(0xFFF8FAFC)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0F294A), Color(0xFF2563EB)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.family_restroom_rounded,
                              color: Colors.white,
                              size: 38,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isRegisterMode ? 'Créer un compte' : 'Connexion',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Mon CV & Gestion Familiale • API REST PHP / MySQL',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Adresse email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (v) {
                            final val = v?.trim() ?? '';
                            if (val.isEmpty || !val.contains('@')) {
                              return 'Veuillez saisir un email valide.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() => _obscurePassword = !_obscurePassword);
                              },
                            ),
                          ),
                          validator: (v) {
                            if ((v ?? '').length < 6) {
                              return 'Au moins 6 caractères requis.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        if (_statusMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: _statusIsError
                                  ? colorScheme.errorContainer
                                  : colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _statusMessage!,
                              style: TextStyle(
                                color: _statusIsError
                                    ? colorScheme.onErrorContainer
                                    : colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        FilledButton(
                          onPressed: _isLoading ? null : _submit,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(
                                  _isRegisterMode ? 'Créer mon compte' : 'Se connecter',
                                ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      setState(() {
                                        _isRegisterMode = !_isRegisterMode;
                                        _statusMessage = null;
                                      });
                                    },
                              child: Text(
                                _isRegisterMode ? 'Se connecter' : 'Créer un compte',
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _isLoading ? null : _testApi,
                              icon: const Icon(Icons.wifi_tethering, size: 18),
                              label: const Text('Tester API'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// ÉCRAN 2 : NAVIGATION PRINCIPALE (CV + TABLEAU DE BORD + FAMILLE)
// ============================================================================

class MainNavigation extends StatefulWidget {
  final String userEmail;
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const MainNavigation({
    super.key,
    required this.userEmail,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final titles = [
      'Mon CV — Profil complet',
      'Tableau de bord MySQL',
      'Membres de famille',
    ];
    final pages = [
      CvPage(userEmail: widget.userEmail),
      const DashboardPage(),
      const FamilyPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
        actions: [
          IconButton(
            tooltip: 'Changer de thème',
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
          ),
          IconButton(
            tooltip: 'Déconnexion',
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => LoginPage(
                    isDarkMode: widget.isDarkMode,
                    onToggleTheme: widget.onToggleTheme,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.badge_outlined),
            selectedIcon: Icon(Icons.badge),
            label: 'Mon CV',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Famille',
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ONGLET 1 : CV COMPLET (TOUS LES ÉLÉMENTS DU CV)
// ============================================================================

class CvPage extends StatelessWidget {
  final String userEmail;

  const CvPage({super.key, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Bannière en-tête CV
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F294A), Color(0xFF1D4ED8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 38,
                backgroundColor: Colors.white.withValues(alpha: 0.18),
                child: const Text(
                  CvData.initials,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      CvData.fullName,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      CvData.title,
                      style: TextStyle(color: Color(0xFFDBEAFE), fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      CvData.subtitle,
                      style: TextStyle(color: Color(0xFFFDE68A), fontSize: 13),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 12,
                      runSpacing: 6,
                      children: [
                        _headerPill(Icons.location_on_outlined, CvData.location),
                        _headerPill(Icons.email_outlined, userEmail),
                        _headerPill(Icons.phone_outlined, CvData.phone),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // À propos
        _sectionCard(
          context,
          icon: Icons.person_outline,
          title: 'À propos de moi',
          child: const Text(CvData.about, style: TextStyle(height: 1.5)),
        ),
        const SizedBox(height: 14),

        // Formation
        _sectionCard(
          context,
          icon: Icons.school_outlined,
          title: 'Formation académique',
          child: Column(
            children: CvData.educations
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            e.period,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e.degree,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                e.institution,
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                e.details,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 14),

        // Compétences techniques avec barres de progression
        _sectionCard(
          context,
          icon: Icons.code_rounded,
          title: 'Compétences techniques',
          child: Column(
            children: CvData.skills
                .map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              s.name,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text('${(s.level * 100).round()}%'),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: s.level,
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 14),

        // Projets réalisés
        _sectionCard(
          context,
          icon: Icons.work_outline,
          title: 'Projets académiques & réalisations',
          child: Column(
            children: CvData.projects
                .map(
                  (p) => Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          p.stack,
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(p.description, style: const TextStyle(height: 1.4)),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 14),

        // Langues
        _sectionCard(
          context,
          icon: Icons.translate_rounded,
          title: 'Langues',
          child: Column(
            children: CvData.languages
                .map(
                  (l) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 90,
                          child: Text(
                            l.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: l.progress,
                              minHeight: 7,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(l.level, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 14),

        // Qualités & Centres d'intérêt
        _sectionCard(
          context,
          icon: Icons.auto_awesome_outlined,
          title: 'Qualités & Centres d\'intérêt',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Qualités humaines',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: CvData.softSkills
                    .map((q) => Chip(label: Text(q)))
                    .toList(),
              ),
              const SizedBox(height: 14),
              const Text(
                'Centres d\'intérêt',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: CvData.interests
                    .map((i) => Chip(
                          avatar: const Icon(Icons.star_outline, size: 16),
                          label: Text(i),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Coordonnées & GitHub
        _sectionCard(
          context,
          icon: Icons.contact_mail_outlined,
          title: 'Coordonnées & Liens',
          child: Column(
            children: [
              ListTile(
                dense: true,
                leading: const Icon(Icons.school),
                title: const Text(CvData.institution),
                subtitle: const Text(CvData.location),
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.link),
                title: const Text('Dépôt GitHub du projet'),
                subtitle: const Text(CvData.githubUrl),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _headerPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 5),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// ONGLET 2 : TABLEAU DE BORD & STATISTIQUES MYSQL (NOUVEAU)
// ============================================================================

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<FamilleStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = ApiService.getStats();
  }

  void _refresh() {
    setState(() {
      _statsFuture = ApiService.getStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _refresh();
        await _statsFuture;
      },
      child: FutureBuilder<FamilleStats>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Impossible de charger les statistiques : ${snapshot.error}'),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final stats = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _kpiCard(
                      context,
                      title: 'Membres MySQL',
                      value: '${stats.totalMembres}',
                      icon: Icons.groups_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _kpiCard(
                      context,
                      title: 'Comptes actifs',
                      value: '${stats.totalComptes}',
                      icon: Icons.verified_user_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _kpiCard(
                      context,
                      title: 'Villes / Lieux',
                      value: '${stats.parLieu.length}',
                      icon: Icons.location_city_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Répartition par lien de parenté',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      if (stats.parParente.isEmpty)
                        const Text('Aucune donnée enregistrée.')
                      else
                        ...stats.parParente.entries.map((e) {
                          final ratio = stats.totalMembres > 0
                              ? e.value / stats.totalMembres
                              : 0.0;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(e.key),
                                    Text('${e.value}'),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: ratio,
                                    minHeight: 8,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Répartition par lieu de naissance',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      if (stats.parLieu.isEmpty)
                        const Text('Aucune donnée enregistrée.')
                      else
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: stats.parLieu.entries
                              .map(
                                (e) => Chip(
                                  avatar: const Icon(Icons.place_outlined, size: 16),
                                  label: Text('${e.key} (${e.value})'),
                                ),
                              )
                              .toList(),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _kpiCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colorScheme.primary, size: 28),
            const SizedBox(height: 10),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// ONGLET 3 : GESTION FAMILLE (RECHERCHE + FILTRES + FICHE DÉTAIL + CRUD)
// ============================================================================

class FamilyPage extends StatefulWidget {
  const FamilyPage({super.key});

  @override
  State<FamilyPage> createState() => _FamilyPageState();
}

class _FamilyPageState extends State<FamilyPage> {
  final TextEditingController _searchController = TextEditingController();
  late Future<List<FamilleMembre>> _membersFuture;
  String _activeQuery = '';
  String _selectedParente = 'Tous';

  static const List<String> _parenteFilters = [
    'Tous',
    'Père',
    'Mère',
    'Frère',
    'Sœur',
    'Autre',
  ];

  @override
  void initState() {
    super.initState();
    _membersFuture = ApiService.getFamilyMembers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reloadMembers({String? query, String? parente}) {
    final q = query ?? _activeQuery;
    final p = parente ?? _selectedParente;
    setState(() {
      _activeQuery = q;
      _selectedParente = p;
      _membersFuture = ApiService.getFamilyMembers(query: q, parente: p);
    });
  }

  void _showMemberDetails(FamilleMembre m) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    child: Text(
                      m.nom.isNotEmpty ? m.nom[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.nomComplet,
                          style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          '${m.parente} • ID MySQL #${m.id}',
                          style: Theme.of(sheetContext).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              ListTile(
                dense: true,
                leading: const Icon(Icons.location_on_outlined),
                title: const Text('Lieu de naissance'),
                subtitle: Text(m.lieuNaissance),
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.cake_outlined),
                title: const Text('Date de naissance'),
                subtitle: Text(
                  m.age != null
                      ? '${m.dateNaissance} (${m.age} ans)'
                      : m.dateNaissance,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      _openMemberDialog(membre: m);
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Modifier'),
                  ),
                  const SizedBox(width: 10),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(sheetContext).colorScheme.error,
                    ),
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      _confirmDelete(m);
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Supprimer'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openMemberDialog({FamilleMembre? membre}) async {
    final isEdit = membre != null;
    final formKey = GlobalKey<FormState>();

    final nomCtrl = TextEditingController(text: membre?.nom ?? '');
    final postnomCtrl = TextEditingController(text: membre?.postnom ?? '');
    final prenomCtrl = TextEditingController(text: membre?.prenom ?? '');
    final lieuCtrl = TextEditingController(text: membre?.lieuNaissance ?? '');
    final dateCtrl = TextEditingController(text: membre?.dateNaissance ?? '');
    final parenteCtrl = TextEditingController(text: membre?.parente ?? '');

    bool saving = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            Future<void> pickDate() async {
              final initial =
                  DateTime.tryParse(dateCtrl.text.trim()) ?? DateTime(2000, 1, 1);
              final picked = await showDatePicker(
                context: dialogContext,
                initialDate: initial,
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (picked != null && dialogContext.mounted) {
                final y = picked.year.toString().padLeft(4, '0');
                final m = picked.month.toString().padLeft(2, '0');
                final d = picked.day.toString().padLeft(2, '0');
                setDialogState(() => dateCtrl.text = '$y-$m-$d');
              }
            }

            Future<void> save() async {
              if (!formKey.currentState!.validate()) return;
              setDialogState(() => saving = true);

              final result = isEdit
                  ? await ApiService.modifierMembre(
                      id: membre.id,
                      nom: nomCtrl.text,
                      postnom: postnomCtrl.text,
                      prenom: prenomCtrl.text,
                      lieuNaissance: lieuCtrl.text,
                      dateNaissance: dateCtrl.text,
                      parente: parenteCtrl.text,
                    )
                  : await ApiService.ajouterMembre(
                      nom: nomCtrl.text,
                      postnom: postnomCtrl.text,
                      prenom: prenomCtrl.text,
                      lieuNaissance: lieuCtrl.text,
                      dateNaissance: dateCtrl.text,
                      parente: parenteCtrl.text,
                    );

              if (!dialogContext.mounted) return;
              setDialogState(() => saving = false);

              if (result.success) {
                Navigator.of(dialogContext).pop();
                if (!mounted) return;
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(result.message)));
                _reloadMembers();
              } else {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result.message),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
            }

            return AlertDialog(
              title: Text(isEdit ? 'Modifier un membre' : 'Ajouter un membre'),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 420,
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: nomCtrl,
                          decoration: const InputDecoration(labelText: 'Nom'),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Requis' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: postnomCtrl,
                          decoration: const InputDecoration(labelText: 'Postnom'),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Requis' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: prenomCtrl,
                          decoration: const InputDecoration(labelText: 'Prénom'),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Requis' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: lieuCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Lieu de naissance',
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Requis' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: dateCtrl,
                          decoration: InputDecoration(
                            labelText: 'Date de naissance (AAAA-MM-JJ)',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today_outlined),
                              onPressed: pickDate,
                            ),
                          ),
                          validator: (v) =>
                              RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(v?.trim() ?? '')
                                  ? null
                                  : 'Format AAAA-MM-JJ',
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: parenteCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Lien de parenté (Père, Mère, Frère, Sœur...)',
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Requis' : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving ? null : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Annuler'),
                ),
                FilledButton(
                  onPressed: saving ? null : save,
                  child: saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isEdit ? 'Enregistrer' : 'Ajouter'),
                ),
              ],
            );
          },
        );
      },
    );

    nomCtrl.dispose();
    postnomCtrl.dispose();
    prenomCtrl.dispose();
    lieuCtrl.dispose();
    dateCtrl.dispose();
    parenteCtrl.dispose();
  }

  Future<void> _confirmDelete(FamilleMembre membre) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Supprimer ${membre.nomComplet} (${membre.parente}) ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    final result = await ApiService.supprimerMembre(membre.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: result.success ? null : Theme.of(context).colorScheme.error,
      ),
    );
    if (result.success) _reloadMembers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher par nom, prénom, lieu ou parenté...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _reloadMembers(query: '');
                              },
                            )
                          : null,
                    ),
                    onChanged: (v) => _reloadMembers(query: v),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: 'Actualiser',
                  icon: const Icon(Icons.refresh),
                  onPressed: () => _reloadMembers(),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _parenteFilters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _parenteFilters[index];
                return ChoiceChip(
                  label: Text(filter),
                  selected: _selectedParente == filter,
                  onSelected: (_) => _reloadMembers(parente: filter),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _reloadMembers();
                await _membersFuture;
              },
              child: FutureBuilder<List<FamilleMembre>>(
                future: _membersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Erreur : ${snapshot.error}'),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: () => _reloadMembers(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Réessayer'),
                          ),
                        ],
                      ),
                    );
                  }
                  final members = snapshot.data ?? [];
                  if (members.isEmpty) {
                    return const Center(
                      child: Text('Aucun membre trouvé dans la base MySQL.'),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                    itemCount: members.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final m = members[index];
                      return Card(
                        child: ListTile(
                          onTap: () => _showMemberDetails(m),
                          leading: CircleAvatar(
                            child: Text(
                              m.nom.isNotEmpty ? m.nom[0].toUpperCase() : '?',
                            ),
                          ),
                          title: Text(
                            m.nomComplet,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${m.parente} • ${m.lieuNaissance} • ${m.dateNaissance}'
                            '${m.age != null ? ' (${m.age} ans)' : ''}',
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (action) {
                              if (action == 'edit') {
                                _openMemberDialog(membre: m);
                              } else if (action == 'delete') {
                                _confirmDelete(m);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 'edit', child: Text('Modifier')),
                              PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openMemberDialog(),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Ajouter'),
      ),
    );
  }
}
