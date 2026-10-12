import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

void main() => runApp(const StudyDeckApp());

// ───────────────────────── THEME / COLORS ─────────────────────────
class AppColors {
  static const bg = Color(0xFF0B0F17);
  static const card = Color(0xFF151A25);
  static const card2 = Color(0xFF1D2330);
  static const yellow = Color(0xFFFFC72C);
  static const light = Color(0xFFF8F5EE);
  static const grey = Color(0xFF9AA3B2);
}

class StudyDeckApp extends StatelessWidget {
  const StudyDeckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyDeck',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.yellow,
          surface: AppColors.card,
        ),
        useMaterial3: true,
      ),
      home: const SignUpScreen(),
    );
  }
}

// ───────────────────────── SIMPLE IN-MEMORY DATA ─────────────────────────
class AuthStore {
  static String name = '';
  static String email = '';
  static String password = '';
  static bool get hasAccount => email.isNotEmpty;
}

class Course {
  final String code;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final int cards;
  const Course(this.code, this.title, this.subtitle, this.icon, this.color,
      this.cards);
}

const courses = <Course>[
  Course('DAA', 'Design & Analysis of Algorithms', 'Sorting, Greedy, DP, Graphs',
      Icons.account_tree_rounded, Color(0xFFFFC72C), 30),
  Course('MAD', 'Mobile App Development', 'Flutter, Widgets, State',
      Icons.phone_android_rounded, Color(0xFF4ADE80), 25),
  Course('WEB', 'Web Engineering', 'HTML, CSS, JS, Backend',
      Icons.language_rounded, Color(0xFF38BDF8), 28),
  Course('S&P', 'Statistics and Probability', 'Distributions, Hypothesis',
      Icons.bar_chart_rounded, Color(0xFFF472B6), 22),
  Course('COAL', 'Computer Organization & Assembly', 'CPU, Registers, 8086',
      Icons.memory_rounded, Color(0xFFA78BFA), 20),
  Course('OS', 'Operating Systems', 'Process, Memory, Scheduling',
      Icons.settings_suggest_rounded, Color(0xFFFB923C), 26),
];

class StudyItem {
  final String name;
  final String type; // pdf | file | note
  final String info;
  StudyItem(this.name, this.type, this.info);
}

// Notes/PDF list for each course
final Map<String, List<StudyItem>> courseItems = {
  for (final c in courses) c.code: <StudyItem>[],
};

String formatSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

// ───────────────────────── REUSABLE WIDGETS ─────────────────────────
class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 56});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.yellow,
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: [
          BoxShadow(
              color: AppColors.yellow.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Icon(Icons.layers_rounded, color: Colors.black, size: size * 0.55),
    );
  }
}

class YellowButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onTap;
  const YellowButton(
      {super.key, required this.text, required this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.yellow,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
            Text(text,
                style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class AuthField extends StatefulWidget {
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboard;
  const AuthField({
    super.key,
    required this.hint,
    required this.icon,
    required this.controller,
    this.isPassword = false,
    this.validator,
    this.keyboard = TextInputType.text,
  });

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  bool hidden = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: widget.controller,
        validator: widget.validator,
        keyboardType: widget.keyboard,
        obscureText: widget.isPassword && hidden,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: const TextStyle(color: AppColors.grey),
          prefixIcon: Icon(widget.icon, color: AppColors.yellow),
          suffixIcon: widget.isPassword
              ? IconButton(
            icon: Icon(
                hidden ? Icons.visibility_off : Icons.visibility,
                color: AppColors.grey),
            onPressed: () => setState(() => hidden = !hidden),
          )
              : null,
          filled: true,
          fillColor: AppColors.card,
          contentPadding:
          const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Colors.white10)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: AppColors.yellow, width: 1.5)),
        ),
      ),
    );
  }
}

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const AuthHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const AppLogo(size: 50),
            const SizedBox(width: 12),
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                      text: 'Study',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  TextSpan(
                      text: 'Deck',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.yellow)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 36),
        Text(title,
            style: const TextStyle(
                fontSize: 32, fontWeight: FontWeight.w800, height: 1.15)),
        const SizedBox(height: 8),
        Text(subtitle,
            style: const TextStyle(fontSize: 15, color: AppColors.grey)),
        const SizedBox(height: 28),
      ],
    );
  }
}

// ───────────────────────── SCREEN 1: SIGN UP ─────────────────────────
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _signUp() {
    if (!_formKey.currentState!.validate()) return;
    AuthStore.name = _name.text.trim();
    AuthStore.email = _email.text.trim().toLowerCase();
    AuthStore.password = _pass.text;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account created! Please log in now.')),
    );
    // Go to the login screen after sign up
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AuthHeader(
                    title: 'Create your\naccount.',
                    subtitle: 'Study Smarter. Build Better.'),
                AuthField(
                  hint: 'Full name',
                  icon: Icons.person_outline,
                  controller: _name,
                  validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
                ),
                AuthField(
                  hint: 'Email',
                  icon: Icons.mail_outline,
                  controller: _email,
                  keyboard: TextInputType.emailAddress,
                  validator: (v) => (v == null || !v.contains('@'))
                      ? 'Enter a valid email'
                      : null,
                ),
                AuthField(
                  hint: 'Password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  controller: _pass,
                  validator: (v) => (v == null || v.length < 6)
                      ? 'At least 6 characters'
                      : null,
                ),
                AuthField(
                  hint: 'Confirm password',
                  icon: Icons.lock_reset,
                  isPassword: true,
                  controller: _confirm,
                  validator: (v) =>
                  v != _pass.text ? 'Passwords do not match' : null,
                ),
                const SizedBox(height: 10),
                YellowButton(
                    text: 'Sign Up',
                    icon: Icons.arrow_forward_rounded,
                    onTap: _signUp),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? ',
                        style: TextStyle(color: AppColors.grey)),
                    GestureDetector(
                      // If the user already has an account, go to the login screen
                      onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen())),
                      child: const Text('Login',
                          style: TextStyle(
                              color: AppColors.yellow,
                              fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── SCREEN 2: LOGIN ─────────────────────────
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;
    final ok = AuthStore.hasAccount &&
        _email.text.trim().toLowerCase() == AuthStore.email &&
        _pass.text == AuthStore.password;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(AuthStore.hasAccount
            ? 'Incorrect email or password'
            : 'Please create an account first (Sign Up)'),
      ));
      return;
    }
    // Go to the main (home) screen after login
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AuthHeader(
                    title: 'Welcome\nback!',
                    subtitle: 'Log in and keep your study streak going.'),
                AuthField(
                  hint: 'Email',
                  icon: Icons.mail_outline,
                  controller: _email,
                  keyboard: TextInputType.emailAddress,
                  validator: (v) => (v == null || !v.contains('@'))
                      ? 'Enter a valid email'
                      : null,
                ),
                AuthField(
                  hint: 'Password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  controller: _pass,
                  validator: (v) =>
                  (v == null || v.isEmpty) ? 'Enter your password' : null,
                ),
                const SizedBox(height: 10),
                YellowButton(
                    text: 'Login',
                    icon: Icons.login_rounded,
                    onTap: _login),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? ",
                        style: TextStyle(color: AppColors.grey)),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SignUpScreen())),
                      child: const Text('Sign Up',
                          style: TextStyle(
                              color: AppColors.yellow,
                              fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── SCREEN 3: HOME ─────────────────────────
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _soon(BuildContext context, String name) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$name coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    final userName = AuthStore.name.isEmpty ? 'Student' : AuthStore.name;
    final first = userName.split(' ').first;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar
              Row(
                children: [
                  const AppLogo(size: 44),
                  const SizedBox(width: 10),
                  const Text('StudyDeck',
                      style:
                      TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.yellow,
                    child: Text(first[0].toUpperCase(),
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                            fontSize: 18)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Hero
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFFFFC72C), Color(0xFFFFA800)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.yellow.withValues(alpha: 0.25),
                        blurRadius: 24,
                        offset: const Offset(0, 10)),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hi, $first 👋',
                              style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          const Text('Build better habits.\nMaster your goals.',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  height: 1.2)),
                          const SizedBox(height: 8),
                          const Text('Small cards. Big progress.',
                              style: TextStyle(color: Colors.black87)),
                        ],
                      ),
                    ),
                    Transform.rotate(
                      angle: -0.2,
                      child: Container(
                        width: 78,
                        height: 98,
                        decoration: BoxDecoration(
                            color: AppColors.bg,
                            borderRadius: BorderRadius.circular(18)),
                        child: const Icon(Icons.lightbulb_rounded,
                            color: AppColors.yellow, size: 40),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              // Progress
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white10)),
                child: Row(
                  children: [
                    SizedBox(
                      width: 96,
                      height: 96,
                      child: Stack(
                        alignment: Alignment.center,
                        children: const [
                          SizedBox(
                            width: 96,
                            height: 96,
                            child: CircularProgressIndicator(
                              value: 0.68,
                              strokeWidth: 9,
                              strokeCap: StrokeCap.round,
                              color: AppColors.yellow,
                              backgroundColor: Colors.white12,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('68%',
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900)),
                              Text('Completed',
                                  style: TextStyle(
                                      fontSize: 10, color: AppColors.grey)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        children: const [
                          _StatRow(Icons.check_circle, Colors.green, '136',
                              'Correct'),
                          SizedBox(height: 8),
                          _StatRow(
                              Icons.cancel, Colors.redAccent, '42', 'Incorrect'),
                          SizedBox(height: 8),
                          _StatRow(Icons.remove_circle, Colors.grey, '64',
                              'Remaining'),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.local_fire_department,
                                  color: AppColors.yellow),
                              SizedBox(width: 6),
                              Text('5 Day Streak',
                                  style:
                                  TextStyle(fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('Menu',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              _MenuTile(
                icon: Icons.home_rounded,
                title: 'Home',
                subtitle: 'Your learning hub',
                highlighted: true,
                onTap: () {},
              ),
              _MenuTile(
                icon: Icons.layers_rounded,
                title: 'My Decks',
                subtitle: 'View & manage your decks',
                // My Decks click -> next screen
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const MyDecksScreen())),
              ),
              _MenuTile(
                icon: Icons.add_rounded,
                title: 'Create Deck',
                subtitle: 'Build your own deck',
                onTap: () => _soon(context, 'Create Deck'),
              ),
              _MenuTile(
                icon: Icons.bar_chart_rounded,
                title: 'Statistics',
                subtitle: 'Track your progress',
                onTap: () => _soon(context, 'Statistics'),
              ),
              _MenuTile(
                icon: Icons.settings_rounded,
                title: 'Settings',
                subtitle: 'App preferences',
                onTap: () => _soon(context, 'Settings'),
              ),
              const SizedBox(height: 20),
              const _FlashPreview(),
              const SizedBox(height: 22),
              Center(
                child: TextButton.icon(
                  onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (r) => false),
                  icon: const Icon(Icons.logout, color: AppColors.grey),
                  label: const Text('Logout',
                      style: TextStyle(color: AppColors.grey)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  const _StatRow(this.icon, this.color, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        const Spacer(),
        Text(label, style: const TextStyle(color: AppColors.grey)),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool highlighted;
  final VoidCallback onTap;
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final fg = highlighted ? Colors.black : Colors.white;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: highlighted ? AppColors.yellow : AppColors.card,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: highlighted
                        ? Colors.black.withValues(alpha: 0.1)
                        : AppColors.yellow.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon,
                      color: highlighted ? Colors.black : AppColors.yellow),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                              color: fg,
                              fontSize: 16,
                              fontWeight: FontWeight.w800)),
                      Text(subtitle,
                          style: TextStyle(
                              color: highlighted
                                  ? Colors.black87
                                  : AppColors.grey,
                              fontSize: 12)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: fg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FlashPreview extends StatefulWidget {
  const _FlashPreview();

  @override
  State<_FlashPreview> createState() => _FlashPreviewState();
}

class _FlashPreviewState extends State<_FlashPreview> {
  bool showAnswer = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: Colors.white10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Core Concepts',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const Spacer(),
              const Text('Card 3 of 20',
                  style: TextStyle(color: AppColors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: 0.15,
              minHeight: 6,
              color: AppColors.yellow,
              backgroundColor: Colors.white12,
            ),
          ),
          const SizedBox(height: 14),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Container(
              key: ValueKey(showAnswer),
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                  color: AppColors.light,
                  borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                        color: AppColors.yellow,
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(showAnswer ? 'Back' : 'Front',
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    showAnswer
                        ? 'A stack is a linear data structure that follows the Last In, First Out (LIFO) principle. Push adds an element to the top; Pop removes the top element.'
                        : 'What is a stack in data structures?',
                    style: TextStyle(
                        color: const Color(0xFF0B0F17),
                        fontSize: showAnswer ? 14 : 20,
                        fontWeight:
                        showAnswer ? FontWeight.w500 : FontWeight.w800,
                        height: 1.4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          YellowButton(
            text: showAnswer ? 'Hide Answer' : 'Show Answer',
            icon: Icons.refresh_rounded,
            onTap: () => setState(() => showAnswer = !showAnswer),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── SCREEN 4: MY DECKS (6 COURSES GRID) ─────────────────────────
class MyDecksScreen extends StatelessWidget {
  const MyDecksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: const Text('My Decks',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select your course',
                  style: TextStyle(color: AppColors.grey)),
              const SizedBox(height: 14),
              Expanded(
                child: GridView.builder(
                  itemCount: courses.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.88,
                  ),
                  itemBuilder: (context, i) {
                    final c = courses[i];
                    final count = courseItems[c.code]!.length;
                    return InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => CourseDetailScreen(course: c)),
                      ).then((_) => (context as Element).markNeedsBuild()),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              c.color.withValues(alpha: 0.28),
                              AppColors.card,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: c.color.withValues(alpha: 0.45)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                  color: c.color,
                                  borderRadius: BorderRadius.circular(16)),
                              child: Icon(c.icon, color: Colors.black),
                            ),
                            const Spacer(),
                            Text(c.code,
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.w900)),
                            const SizedBox(height: 4),
                            Text(c.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: AppColors.grey, fontSize: 12)),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Text('${c.cards} cards',
                                    style: TextStyle(
                                        color: c.color,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12)),
                                const Spacer(),
                                if (count > 0)
                                  Row(children: [
                                    const Icon(Icons.attach_file,
                                        size: 14, color: AppColors.grey),
                                    Text('$count',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.grey)),
                                  ]),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── COURSE DETAIL + ADD NOTES / PDF ─────────────────────────
class CourseDetailScreen extends StatefulWidget {
  final Course course;
  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  List<StudyItem> get items => courseItems[widget.course.code]!;

  void _msg(String t) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  Future<void> _pickPdf() async {
    try {
      final res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (res == null || res.files.isEmpty) return;
      final f = res.files.first;
      setState(() => items.add(StudyItem(f.name, 'pdf', formatSize(f.size))));
      _msg('PDF added');
    } catch (e) {
      _msg('Could not select file: $e');
    }
  }

  Future<void> _pickNotesFile() async {
    try {
      final res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'doc', 'docx', 'ppt', 'pptx', 'jpg', 'png'],
      );
      if (res == null || res.files.isEmpty) return;
      final f = res.files.first;
      setState(() => items.add(StudyItem(f.name, 'file', formatSize(f.size))));
      _msg('Notes file added');
    } catch (e) {
      _msg('Could not select file: $e');
    }
  }

  Future<void> _writeNote() async {
    final title = TextEditingController();
    final body = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('New Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: title,
                decoration: const InputDecoration(hintText: 'Title')),
            const SizedBox(height: 10),
            TextField(
                controller: body,
                maxLines: 4,
                decoration: const InputDecoration(hintText: 'Write a note...')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save',
                  style: TextStyle(color: AppColors.yellow))),
        ],
      ),
    );
    if (saved == true && title.text.trim().isNotEmpty) {
      setState(() => items.add(StudyItem(title.text.trim(), 'note',
          body.text.trim().isEmpty ? 'Empty note' : body.text.trim())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.course;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text(c.code, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            // Course header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [c.color, c.color.withValues(alpha: 0.6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.title,
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.w900)),
                        const SizedBox(height: 6),
                        Text(c.subtitle,
                            style: const TextStyle(color: Colors.black87)),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            _Chip('${c.cards} cards'),
                            const SizedBox(width: 8),
                            _Chip('${items.length} files'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(c.icon, size: 56, color: Colors.black87),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text('Add Study Material',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _ActionBtn(
                        Icons.picture_as_pdf_rounded, 'Add PDF', _pickPdf)),
                const SizedBox(width: 10),
                Expanded(
                    child: _ActionBtn(
                        Icons.upload_file_rounded, 'Add File', _pickNotesFile)),
                const SizedBox(width: 10),
                Expanded(
                    child: _ActionBtn(
                        Icons.edit_note_rounded, 'Write Note', _writeNote)),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Your Notes & PDFs',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            if (items.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 36),
                decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white10)),
                child: const Column(
                  children: [
                    Icon(Icons.folder_open_rounded,
                        size: 46, color: AppColors.grey),
                    SizedBox(height: 10),
                    Text('No notes or PDFs yet',
                        style: TextStyle(color: AppColors.grey)),
                  ],
                ),
              ),
            ...List.generate(items.length, (i) {
              final it = items[i];
              final icon = it.type == 'pdf'
                  ? Icons.picture_as_pdf_rounded
                  : it.type == 'note'
                  ? Icons.sticky_note_2_rounded
                  : Icons.insert_drive_file_rounded;
              final color = it.type == 'pdf'
                  ? Colors.redAccent
                  : it.type == 'note'
                  ? AppColors.yellow
                  : Colors.lightBlueAccent;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white10)),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14)),
                      child: Icon(icon, color: color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(it.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                              const TextStyle(fontWeight: FontWeight.w700)),
                          Text(it.info,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: AppColors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: AppColors.grey),
                      onPressed: () => setState(() => items.removeAt(i)),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  const _Chip(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20)),
      child: Text(text,
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.w700, fontSize: 12)),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionBtn(this.icon, this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.yellow.withValues(alpha: 0.5))),
          child: Column(
            children: [
              Icon(icon, color: AppColors.yellow, size: 28),
              const SizedBox(height: 6),
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}