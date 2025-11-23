import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

void main() {
  runApp(const ProviderScope(child: AjVerseApp()));
}

class AjVerseApp extends StatefulWidget {
  const AjVerseApp({super.key});

  @override
  State<AjVerseApp> createState() => _AjVerseAppState();
}

class _AjVerseAppState extends State<AjVerseApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aj Verse - Complete Notes App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ).copyWith(
          primary: const Color(0xFF6366F1),
          secondary: const Color(0xFFEC4899),
          tertiary: const Color(0xFF10B981),
          surface: const Color(0xFFFAFBFC),
          surfaceVariant: const Color(0xFFF3F4F6),
          background: const Color(0xFFFFFFFF),
          error: const Color(0xFFEF4444),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
          headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.25,
          ),
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.15,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.25,
            height: 1.4,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ).copyWith(
          primary: const Color(0xFF818CF8),
          secondary: const Color(0xFFF472B6),
          tertiary: const Color(0xFF34D399),
          surface: const Color(0xFF0F172A),
          surfaceVariant: const Color(0xFF1E293B),
          background: const Color(0xFF020617),
          error: const Color(0xFFF87171),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
          headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.25,
          ),
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.15,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.25,
            height: 1.4,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 3,
            shadowColor: Colors.black.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 6,
          shadowColor: Colors.black.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      themeMode: _themeMode,
      home: AjVerseHome(
        onThemeChanged: (ThemeMode themeMode) {
          setState(() {
            _themeMode = themeMode;
          });
        },
        currentThemeMode: _themeMode,
      ),
    );
  }
}

class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final String color;
  final List<String> tags;
  final bool isPinned;
  final bool isArchived;
  final bool isFavorite;
  final int priority; // 1-5 priority level
  final String category; // Work, Personal, Ideas, etc.
  final List<String> attachments; // File paths or URLs
  final bool hasReminder;
  final DateTime? reminderTime;
  final bool isLocked; // Password protected
  final String? password;
  final int wordCount;
  final int readTime; // Estimated reading time in minutes
  final Map<String, dynamic> metadata; // Extra data

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.color = '#FFFFFF',
    this.tags = const [],
    this.isPinned = false,
    this.isArchived = false,
    this.isFavorite = false,
    this.priority = 1,
    this.category = 'General',
    this.attachments = const [],
    this.hasReminder = false,
    this.reminderTime,
    this.isLocked = false,
    this.password,
    int? wordCount,
    int? readTime,
    Map<String, dynamic>? metadata,
  }) : wordCount = wordCount ?? _calculateWordCount(content),
       readTime = readTime ?? _calculateReadTime(content),
       metadata = metadata ?? {},
       modifiedAt = DateTime.now();

  static int _calculateWordCount(String content) {
    return content.trim().isEmpty ? 0 : content.trim().split(RegExp(r'\s+')).length;
  }

  static int _calculateReadTime(String content) {
    final words = _calculateWordCount(content);
    return (words / 200).ceil(); // Average reading speed: 200 words per minute
  }

  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? modifiedAt,
    String? color,
    List<String>? tags,
    bool? isPinned,
    bool? isArchived,
    bool? isFavorite,
    int? priority,
    String? category,
    List<String>? attachments,
    bool? hasReminder,
    DateTime? reminderTime,
    bool? isLocked,
    String? password,
    int? wordCount,
    int? readTime,
    Map<String, dynamic>? metadata,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      color: color ?? this.color,
      tags: tags ?? this.tags,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      isFavorite: isFavorite ?? this.isFavorite,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      attachments: attachments ?? this.attachments,
      hasReminder: hasReminder ?? this.hasReminder,
      reminderTime: reminderTime ?? this.reminderTime,
      isLocked: isLocked ?? this.isLocked,
      password: password ?? this.password,
      wordCount: wordCount ?? this.wordCount,
      readTime: readTime ?? this.readTime,
      metadata: metadata ?? this.metadata,
    );
  }
}

class AjVerseHome extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  final ThemeMode currentThemeMode;

  const AjVerseHome({
    super.key, 
    required this.onThemeChanged,
    required this.currentThemeMode,
  });

  @override
  State<AjVerseHome> createState() => _AjVerseHomeState();
}

class _AjVerseHomeState extends State<AjVerseHome> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoAnimation;
  late Animation<Offset> _textAnimation;
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  String _searchQuery = '';
  String _selectedFilter = 'All';
  bool _isGridView = true;
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSampleNotes();
  }

  void _loadSampleNotes() {
    setState(() {
      _notes = [
        Note(
          id: '1',
          title: '🚀 Welcome to Aj Verse Premium',
          content: 'This is an advanced notes app with incredible features! 🎨\n\n✨ **Premium Features:**\n• Word count & reading time tracking\n• Reminder system with notifications\n• Password protection for sensitive notes\n• File attachments support\n• Advanced metadata tracking\n• Beautiful animations and transitions\n\n🔥 **Try these features:**\n1. Click the theme toggle button (🌓☀️🌙)\n2. Create notes with reminders\n3. Set up password protection\n4. Check word counts and reading times\n5. Explore all the premium filters',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          color: '#E3F2FD',
          tags: ['welcome', 'tutorial', 'premium', 'features'],
          isPinned: true,
          isFavorite: true,
          priority: 5,
          category: 'Personal',
          hasReminder: true,
          reminderTime: DateTime.now().add(const Duration(hours: 1)),
          metadata: {'views': 15, 'lastEdited': 'recently'},
        ),
        Note(
          id: '2',
          title: '💼 Q4 2024 Business Strategy',
          content: '🎯 **Strategic Initiatives:**\n\n**Revenue Growth:**\n• Target: 35% YoY growth\n• Focus on enterprise clients\n• Expand to APAC region\n\n**Product Development:**\n• Launch AI-powered features\n• Mobile app revamp\n• API marketplace\n\n**Team Expansion:**\n• Hire 15 engineers\n• Build design team\n• Customer success department\n\n📊 **KPIs to Track:**\n- MRR: \$500K target\n- NPS: 70+ score\n- Churn: <2% monthly',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          color: '#F3E5F5',
          tags: ['business', 'strategy', 'Q4', 'planning'],
          isPinned: true,
          priority: 5,
          category: 'Work',
          hasReminder: true,
          reminderTime: DateTime.now().add(const Duration(days: 7)),
          metadata: {'importance': 'critical', 'stakeholders': ['CEO', 'CTO']},
        ),
        Note(
          id: '3',
          title: '🛒 Smart Shopping List AI',
          content: '🤖 **AI-Generated Shopping List:**\n\n**🥬 Fresh Produce:**\n• Organic spinach (2 bunches)\n• Cherry tomatoes (1 lb)\n• Avocados (3, ripe)\n• Bell peppers (assorted colors)\n\n**🥛 Dairy & Alternatives:**\n• Oat milk (barista blend)\n• Greek yogurt (plain)\n• Artisan cheese selection\n• Plant-based butter\n\n**🍖 Proteins:**\n• Wild-caught salmon (2 fillets)\n• Free-range chicken breasts\n• Beyond Meat burgers\n\n**🌾 Pantry Staples:**\n• Quinoa (organic)\n• Extra virgin olive oil\n• Himalayan pink salt\n\n💡 **Smart Tips:**\n- Buy seasonal produce for freshness\n- Check pantry before shopping\n- Use reusable bags',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          color: '#E8F5E8',
          tags: ['shopping', 'AI', 'groceries', 'smart'],
          priority: 3,
          category: 'Personal',
          metadata: {'estimatedCost': '\$85', 'store': 'Whole Foods'},
        ),
        Note(
          id: '4',
          title: '🔐 Password Protected Note',
          content: '🔒 **This is a secure note!**\n\nSensitive information here:\n• Bank account details\n• Personal passwords\n• Secret project ideas\n• Confidential business plans\n\n🛡️ **Security Features:**\n- AES-256 encryption\n- Biometric authentication\n- Auto-lock after 5 minutes\n- Secure backup\n\n💼 **Access Level:** Top Secret\n👤 **Authorized Personnel:** Admin only',
          createdAt: DateTime.now().subtract(const Duration(hours: 6)),
          color: '#FFF3E0',
          tags: ['secure', 'password', 'confidential'],
          isPinned: true,
          priority: 5,
          category: 'Work',
          isLocked: true,
          password: 'secret123',
          metadata: {'securityLevel': 'maximum', 'accessCount': 3},
        ),
        Note(
          id: '5',
          title: '📚 Flutter Development Roadmap 2024',
          content: '🚀 **Master Flutter Development:**\n\n## 📖 **Phase 1: Fundamentals (2-3 weeks)**\n• Dart language deep dive\n• Flutter widgets & state management\n• Layouts & responsive design\n• Navigation & routing\n\n## 🎨 **Phase 2: Intermediate (3-4 weeks)**\n• Provider & Riverpod state management\n• Firebase integration\n• REST APIs & GraphQL\n• Animations & transitions\n\n## 🔥 **Phase 3: Advanced (4-6 weeks)**\n• Custom widgets & painters\n• Performance optimization\n• Testing (unit, widget, integration)\n• CI/CD pipelines\n\n## 💎 **Phase 4: Expert (ongoing)**\n• Plugin development\n• Platform channels\n• Advanced animations\n• Architecture patterns\n\n📊 **Learning Resources:**\n- Flutter official docs\n- Flutter YouTube channel\n- Medium articles\n- GitHub projects',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          color: '#FCE4EC',
          tags: ['flutter', 'development', 'learning', 'roadmap'],
          isFavorite: true,
          priority: 4,
          category: 'Learning',
          hasReminder: true,
          reminderTime: DateTime.now().add(const Duration(days: 1)),
          metadata: {'difficulty': 'intermediate', 'timeCommitment': '3 months'},
        ),
        Note(
          id: '6',
          title: '🌍 Dream Travel Destinations 2024',
          content: '✈️ **Bucket List Adventures:**\n\n## 🏝️ **Tropical Paradises**\n🌺 **Bali, Indonesia**\n• Ubud rice terraces\n• Seminyak beaches\n• Traditional temples\n\n🏝️ **Maldives**\n• Overwater bungalows\n• Crystal clear waters\n• Dolphin watching\n\n## 🏛️ **Historical Wonders**\n🗼 **Rome, Italy**\n• Colosseum tour\n• Vatican City\n• Authentic pasta making\n\n🏛️ **Athens, Greece**\n• Acropolis at sunset\n• Island hopping\n• Mediterranean cuisine\n\n## 🏔️ **Mountain Escapes**\n🗻 **Swiss Alps**\n• Matterhorn hiking\n• Chocolate factory tours\n• Alpine train journeys\n\n🏔️ **Patagonia**\n• Glacier trekking\n• Wildlife photography\n• Eco-lodges\n\n💰 **Budget:** \$15,000 total\n📅 **Timeline:** 6 months adventure',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          color: '#E0F2F1',
          tags: ['travel', 'bucket-list', 'adventure', '2024'],
          priority: 3,
          category: 'Personal',
          metadata: {'totalCost': '\$15,000', 'duration': '6 months'},
        ),
        Note(
          id: '7',
          title: '🍳 Master Chef Cooking Collection',
          content: '👨‍🍳 **Gourmet Recipes Collection:**\n\n## 🥘 **Main Courses**\n**Beef Wellington**\n• Prime beef tenderloin\n• Mushroom duxelles\n• Puff pastry perfection\n• Wine reduction sauce\n\n**Lobster Risotto**\n• Fresh Maine lobster\n• Arborio rice\n• Saffron infusion\n• Parmesan crust\n\n## 🍰 **Desserts**\n**Chocolate Soufflé**\n• 70% dark chocolate\n• Egg whites whipped perfectly\n• Molten center\n• Vanilla bean ice cream\n\n**Crème Brûlée**\n• Vanilla bean custard\n• Caramelized sugar top\n• Fresh berry compote\n\n## 🥗 **Appetizers**\n**Scallops with Pancetta**\n• Pan-seared scallops\n• Crispy pancetta\n• Lemon butter sauce\n\n**Foie Gras Torchon**\n• Duck liver\n• Port wine reduction\n• Brioche toast points\n\n⭐ **Difficulty Level:** Advanced\n⏱️ **Prep Time:** Varies (30 min - 4 hours)',
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
          color: '#FFF8E1',
          tags: ['cooking', 'gourmet', 'recipes', 'chef'],
          isFavorite: true,
          priority: 2,
          category: 'Personal',
          metadata: {'skillLevel': 'advanced', 'servings': '4-6'},
        ),
        Note(
          id: '8',
          title: '💪 Fitness & Wellness Journey',
          content: '🏋️ **Holistic Health Plan 2024:**\n\n## 🏃 **Cardio Routine**\n**Monday/Wednesday/Friday:**\n• Morning run (5K)\n• HIIT training (20 min)\n• Cool-down stretching\n\n## 💪 **Strength Training**\n**Tuesday/Thursday/Saturday:**\n• Upper body (Mon/Thu)\n• Lower body (Tue/Fri)\n• Core workout (Wed/Sat)\n\n## 🧘 **Wellness Practices**\n**Daily:**\n• Morning meditation (15 min)\n• Gratitude journaling\n• 8 glasses of water\n• 7-8 hours sleep\n\n## 🥗 **Nutrition Plan**\n• High protein breakfast\n• Balanced lunch\n• Light dinner\n• Healthy snacks\n• Meal prep Sundays\n\n## 📊 **Progress Tracking**\n• Weight: Start 85kg → Target 75kg\n• Body fat: 20% → Target 12%\n• Muscle gain: +5kg lean mass\n• Endurance: 5K under 25 min\n\n🎯 **Goal Date:** June 2024\n💪 **Motivation:** Health & longevity',
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          color: '#FEE2E2',
          tags: ['fitness', 'health', 'wellness', '2024-goals'],
          priority: 4,
          category: 'Health',
          hasReminder: true,
          reminderTime: DateTime.now().add(const Duration(days: 30)),
          metadata: {'startWeight': '85kg', 'targetWeight': '75kg'},
        ),
      ];
      _filteredNotes = _notes;
    });
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _textAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));

    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _textController.forward();
    });
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _logoController.dispose();
    _textController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth < 900;
    
    final padding = isSmallScreen ? 12.0 : isMediumScreen ? 18.0 : 24.0;
    final headerSpacing = isSmallScreen ? 8.0 : 16.0;
    final logoSize = isSmallScreen ? 40.0 : 60.0;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with logo and title
              Row(
                children: [
                  ScaleTransition(
                    scale: _logoAnimation,
                    child: Container(
                      width: logoSize,
                      height: logoSize,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary,
                            colorScheme.secondary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.3),
                            blurRadius: isSmallScreen ? 8 : 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.note_alt_rounded,
                        size: isSmallScreen ? 20 : 32,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 8 : 16),
                  Expanded(
                    child: SlideTransition(
                      position: _textAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Aj Verse',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                          Text(
                            '${_filteredNotes.length} notes',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!isSmallScreen) ...[
                    IconButton(
                      onPressed: _showStatistics,
                      icon: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        child: const Icon(
                          Icons.analytics_rounded,
                          size: 18,
                        ),
                      ),
                      tooltip: 'View Statistics',
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      onPressed: _toggleTheme,
                      icon: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _getThemeIcon(),
                            style: TextStyle(fontSize: isSmallScreen ? 16 : 18),
                          ),
                        ),
                      ),
                      tooltip: _getThemeLabel(),
                      visualDensity: VisualDensity.compact,
                    ),
                  ] else ...[
                    // Compact header for small screens
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: _showStatistics,
                          icon: const Icon(Icons.analytics_rounded, size: 18),
                          visualDensity: VisualDensity.compact,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        ),
                        IconButton(
                          onPressed: _toggleTheme,
                          icon: Text(
                            _getThemeIcon(),
                            style: const TextStyle(fontSize: 16),
                          ),
                          visualDensity: VisualDensity.compact,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        ),
                      ],
                    ),
                  ],
                ],
              ),

              SizedBox(height: headerSpacing),

              // Search bar
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search notes...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: _clearSearch,
                            icon: const Icon(Icons.clear_rounded),
                            visualDensity: VisualDensity.compact,
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12 : 16,
                      vertical: isSmallScreen ? 8 : 12,
                    ),
                    hintStyle: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                  ),
                  style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                ),
              ),

              SizedBox(height: isSmallScreen ? 8 : 12),

              // Filter chips and view toggle
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['All', 'Pinned', 'Favorites', 'High Priority', 'Recent', 'Reminders', 'Locked', 'Categories'].map((filter) {
                          final isSelected = _selectedFilter == filter;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: FilterChip(
                              label: Text(
                                filter,
                                style: TextStyle(fontSize: isSmallScreen ? 10 : 12),
                              ),
                              selected: isSelected,
                              onSelected: (_) => _onFilterChanged(filter),
                              backgroundColor: colorScheme.surfaceVariant.withOpacity(0.3),
                              selectedColor: colorScheme.primary.withOpacity(0.2),
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? colorScheme.primary
                                    : colorScheme.onSurface,
                                fontSize: isSmallScreen ? 10 : 12,
                              ),
                              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 6 : 8, vertical: 4),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: _toggleViewMode,
                    icon: Icon(
                      _isGridView
                          ? Icons.view_list_rounded
                          : Icons.grid_view_rounded,
                      size: isSmallScreen ? 18 : 20,
                    ),
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),

              SizedBox(height: isSmallScreen ? 8 : 16),

              // Notes grid/list
              Expanded(
                child: _filteredNotes.isEmpty
                    ? _buildEmptyState()
                    : _isGridView
                        ? _buildNotesGrid()
                        : _buildNotesList(),
              ),

              // Action button
              SizedBox(height: isSmallScreen ? 8 : 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _createNote,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(
                    'Create New Note',
                    style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                  ),
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 16),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    minimumSize: Size(0, isSmallScreen ? 44 : 48),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_add_rounded,
            size: 80,
            color: colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No notes yet',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first note to get started',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesGrid() {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 600 ? 1 : screenWidth < 900 ? 2 : 3;
    final childAspectRatio = screenWidth < 600 ? 1.9 : screenWidth < 900 ? 1.7 : 1.6;
    
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: _filteredNotes.length,
      itemBuilder: (context, index) {
        final note = _filteredNotes[index];
        return _buildNoteCard(note);
      },
    );
  }

  Widget _buildNoteCard(Note note) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    Color backgroundColor = _parseColor(note.color);
    Color textColor = _getContrastColor(backgroundColor);
    
    // Responsive sizing
    final isSmallScreen = screenWidth < 600;
    final padding = isSmallScreen ? 8.0 : 12.0;
    final iconSize = isSmallScreen ? 10.0 : 12.0;
    final titleFontSize = isSmallScreen ? 11.0 : 13.0;
    final contentFontSize = isSmallScreen ? 9.0 : 10.0;
    final categoryFontSize = isSmallScreen ? 7.0 : 8.0;
    final statsFontSize = isSmallScreen ? 6.0 : 7.0;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _viewNote(note),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with indicators
                Row(
                  children: [
                    // Priority indicator
                    Container(
                      width: 2,
                      height: isSmallScreen ? 12 : 14,
                      decoration: BoxDecoration(
                        color: _getPriorityColor(note.priority),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        note.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          fontSize: titleFontSize,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Status icons - only show most important ones on small screens
                    if (note.isLocked)
                      Icon(
                        Icons.lock_rounded,
                        size: iconSize,
                        color: textColor.withOpacity(0.7),
                      ),
                    if (note.isLocked) const SizedBox(width: 1),
                    if (note.hasReminder && !isSmallScreen)
                      Icon(
                        Icons.alarm_rounded,
                        size: iconSize,
                        color: Colors.orange.withOpacity(0.8),
                      ),
                    if (note.hasReminder && !isSmallScreen) const SizedBox(width: 1),
                    if (note.isFavorite && !isSmallScreen)
                      Icon(
                        Icons.favorite_rounded,
                        size: iconSize,
                        color: Colors.red.withOpacity(0.8),
                      ),
                    if (note.isFavorite && !isSmallScreen) const SizedBox(width: 1),
                    if (note.isPinned)
                      Icon(
                        Icons.push_pin_rounded,
                        size: iconSize,
                        color: textColor.withOpacity(0.7),
                      ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 4 : 6),
                
                // Category badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: textColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    note.category,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: textColor.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                      fontSize: categoryFontSize,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                SizedBox(height: isSmallScreen ? 4 : 6),
                
                // Content
                Expanded(
                  child: Text(
                    note.content,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: textColor.withOpacity(0.8),
                      fontSize: contentFontSize,
                      height: 1.2,
                    ),
                    maxLines: isSmallScreen ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                // Tags - only show on larger screens
                if (note.tags.isNotEmpty && !isSmallScreen) ...[
                  SizedBox(height: 2),
                  Wrap(
                    spacing: 2,
                    runSpacing: 1,
                    children: note.tags.take(2).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                        decoration: BoxDecoration(
                          color: textColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tag,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: textColor.withOpacity(0.8),
                            fontSize: categoryFontSize,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                  ),
                ],
                
                SizedBox(height: 2),
                
                // Footer with stats - simplified on small screens
                Row(
                  children: [
                    // Word count and reading time
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.text_fields_rounded,
                            size: iconSize - 2,
                            color: textColor.withOpacity(0.6),
                          ),
                          const SizedBox(width: 1),
                          Flexible(
                            child: Text(
                              '${note.wordCount}w',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: textColor.withOpacity(0.6),
                                fontSize: statsFontSize,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!isSmallScreen) ...[
                            SizedBox(width: 2),
                            Icon(
                              Icons.schedule_rounded,
                              size: iconSize - 2,
                              color: textColor.withOpacity(0.6),
                            ),
                            const SizedBox(width: 1),
                            Flexible(
                              child: Text(
                                '${note.readTime}m',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: textColor.withOpacity(0.6),
                                  fontSize: statsFontSize,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Priority stars - smaller on small screens
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(isSmallScreen ? 3 : 5, (index) {
                        return Icon(
                          index < note.priority ? Icons.star : Icons.star_border,
                          size: isSmallScreen ? 5 : 6,
                          color: index < note.priority 
                              ? Colors.amber.withOpacity(0.8)
                              : textColor.withOpacity(0.3),
                        );
                      }),
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

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 5:
        return Colors.red;
      case 4:
        return Colors.orange;
      case 3:
        return Colors.yellow;
      case 2:
        return Colors.green;
      case 1:
      default:
        return Colors.blue;
    }
  }

  Widget _buildNotesList() {
    return ListView.builder(
      itemCount: _filteredNotes.length,
      itemBuilder: (context, index) {
        final note = _filteredNotes[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildNoteCard(note),
        );
      },
    );
  }

  void _onSearchChanged(String query) {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _searchQuery = query.toLowerCase();
          _filterNotes();
        });
      }
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _filterNotes();
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
      _filterNotes();
    });
  }

  void _filterNotes() {
    List<Note> filtered = _notes;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((note) {
        return note.title.toLowerCase().contains(_searchQuery) ||
               note.content.toLowerCase().contains(_searchQuery) ||
               note.tags.any((tag) => tag.toLowerCase().contains(_searchQuery)) ||
               note.category.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    // Apply category filter
    switch (_selectedFilter) {
      case 'Pinned':
        filtered = filtered.where((note) => note.isPinned).toList();
        break;
      case 'Favorites':
        filtered = filtered.where((note) => note.isFavorite).toList();
        break;
      case 'High Priority':
        filtered = filtered.where((note) => note.priority >= 4).toList();
        break;
      case 'Recent':
        filtered = filtered.where((note) {
          return DateTime.now().difference(note.createdAt).inDays <= 7;
        }).toList();
        break;
      case 'Reminders':
        filtered = filtered.where((note) => note.hasReminder).toList();
        break;
      case 'Locked':
        filtered = filtered.where((note) => note.isLocked).toList();
        break;
      case 'Categories':
        filtered = filtered.where((note) => note.category != 'General').toList();
        break;
      case 'All':
      default:
        // No additional filtering
        break;
    }

    // Sort: pinned notes first, then by priority, then by date
    filtered.sort((a, b) {
      // First sort by pinned status
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      
      // Then sort by priority (higher first)
      if (a.priority != b.priority) return b.priority.compareTo(a.priority);
      
      // Finally sort by date (newest first)
      return b.createdAt.compareTo(a.createdAt);
    });

    setState(() {
      _filteredNotes = filtered;
    });
  }

  void _toggleViewMode() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  void _showStatistics() {
    final totalNotes = _notes.length;
    final pinnedNotes = _notes.where((n) => n.isPinned).length;
    final favoriteNotes = _notes.where((n) => n.isFavorite).length;
    final totalWords = _notes.fold<int>(0, (sum, note) => sum + note.wordCount);
    final avgWords = totalNotes > 0 ? (totalWords / totalNotes).round() : 0;
    final totalReadTime = _notes.fold<int>(0, (sum, note) => sum + note.readTime);
    final categories = _notes.map((n) => n.category).toSet();
    final tags = _notes.expand((n) => n.tags).toSet();
    final lockedNotes = _notes.where((n) => n.isLocked).length;
    final reminderNotes = _notes.where((n) => n.hasReminder).length;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 500,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.analytics_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '📊 Aj Verse Analytics',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Main stats grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.6,
                  children: [
                    _buildStatCard('📝 Total Notes', totalNotes.toString(), Colors.blue),
                    _buildStatCard('📌 Pinned', pinnedNotes.toString(), Colors.orange),
                    _buildStatCard('❤️ Favorites', favoriteNotes.toString(), Colors.red),
                    _buildStatCard('🔒 Locked', lockedNotes.toString(), Colors.purple),
                    _buildStatCard('⏰ Reminders', reminderNotes.toString(), Colors.amber),
                    _buildStatCard('📖 Total Words', totalWords.toString(), Colors.green),
                    _buildStatCard('⏱️ Avg Words', avgWords.toString(), Colors.teal),
                    _buildStatCard('📚 Read Time', '${totalReadTime}min', Colors.indigo),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Organization stats
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🏷️ Organization',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Categories',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                                Text(
                                  '${categories.length}',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Unique Tags',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                                Text(
                                  '${tags.length}',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
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

  Widget _buildStatCard(String title, String value, Color color) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.bottomLeft,
              child: Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleTheme() {
    ThemeMode nextTheme;
    switch (widget.currentThemeMode) {
      case ThemeMode.system:
        nextTheme = ThemeMode.light;
        break;
      case ThemeMode.light:
        nextTheme = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        nextTheme = ThemeMode.system;
        break;
    }
    widget.onThemeChanged(nextTheme);
    
    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Switched to ${_getThemeLabel(nextTheme)}'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getThemeIcon() {
    switch (widget.currentThemeMode) {
      case ThemeMode.light:
        return '☀️';
      case ThemeMode.dark:
        return '🌙';
      case ThemeMode.system:
      default:
        return '🌓';
    }
  }

  String _getThemeLabel([ThemeMode? mode]) {
    final targetMode = mode ?? widget.currentThemeMode;
    switch (targetMode) {
      case ThemeMode.light:
        return 'Light Mode';
      case ThemeMode.dark:
        return 'Dark Mode';
      case ThemeMode.system:
      default:
        return 'System Theme';
    }
  }

  void _createNote() {
    showDialog(
      context: context,
      builder: (context) => CreateNoteDialog(
        onNoteCreated: (title, content, tags, color, category, priority, isFavorite) {
          setState(() {
            _notes.insert(0, Note(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: title,
              content: content,
              createdAt: DateTime.now(),
              color: color,
              tags: tags,
              category: category,
              priority: priority,
              isFavorite: isFavorite,
            ));
            _filterNotes();
          });
        },
      ),
    );
  }

  void _viewNote(Note note) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteDetailScreen(
          note: note,
          onNoteUpdated: _updateNote,
          onNoteDeleted: _deleteNote,
        ),
      ),
    );
  }

  void _updateNote(Note updatedNote) {
    setState(() {
      final index = _notes.indexWhere((note) => note.id == updatedNote.id);
      if (index != -1) {
        _notes[index] = updatedNote;
        _filterNotes();
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Note updated successfully!')),
    );
  }

  void _deleteNote(String noteId) {
    setState(() {
      _notes.removeWhere((note) => note.id == noteId);
      _filterNotes();
    });
    Navigator.of(context).pop(); // Close detail screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Note deleted successfully!')),
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.white;
    }
  }

  Color _getContrastColor(Color backgroundColor) {
    // Calculate luminance to determine if background is light or dark
    double luminance = (0.299 * backgroundColor.red + 
                      0.587 * backgroundColor.green + 
                      0.114 * backgroundColor.blue) / 255;
    
    // Return black for light backgrounds, white for dark backgrounds
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class CreateNoteDialog extends StatefulWidget {
  final Function(String title, String content, List<String> tags, String color, String category, int priority, bool isFavorite) onNoteCreated;

  const CreateNoteDialog({super.key, required this.onNoteCreated});

  @override
  State<CreateNoteDialog> createState() => _CreateNoteDialogState();
}

class _CreateNoteDialogState extends State<CreateNoteDialog> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagController = TextEditingController();
  List<String> _tags = [];
  String _selectedColor = '#FFFFFF';
  String _selectedCategory = 'General';
  int _selectedPriority = 1;
  bool _isFavorite = false;

  final List<String> _colorOptions = [
    '#FFFFFF', '#E3F2FD', '#F3E5F5', '#E8F5E8', 
    '#FFF3E0', '#FCE4EC', '#E0F2F1', '#FFF8E1',
    '#FEE2E2', '#DBEAFE', '#E9D5FF', '#D1FAE5',
    '#FEF3C7', '#FED7AA', '#FECACA', '#C7D2FE',
  ];

  final List<String> _categories = [
    'General', 'Work', 'Personal', 'Learning', 'Ideas', 'Shopping', 'Travel', 'Health'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _showCategorySelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Category',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: ListView(
                  shrinkWrap: true,
                  children: _categories.map((category) {
                    return ListTile(
                      title: Text(category),
                      trailing: _selectedCategory == category 
                          ? const Icon(Icons.check, color: Colors.blue)
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPrioritySelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Priority',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: ListView(
                  shrinkWrap: true,
                  children: List.generate(5, (index) {
                    final priority = index + 1;
                    return ListTile(
                      title: Row(
                        children: [
                          ...List.generate(priority, (i) => 
                            const Icon(Icons.star, size: 16, color: Colors.amber)
                          ),
                          const SizedBox(width: 8),
                          Text('Priority $priority'),
                        ],
                      ),
                      trailing: _selectedPriority == priority 
                          ? const Icon(Icons.check, color: Colors.blue)
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedPriority = priority;
                        });
                        Navigator.pop(context);
                      },
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      child: Container(
        width: 600,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create New Note',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              
              // Title field
              TextField(
                controller: _titleController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => FocusScope.of(context).nextFocus(),
              ),
              const SizedBox(height: 16),
              
              // Content field
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note_rounded),
                ),
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => FocusScope.of(context).unfocus(),
              ),
              const SizedBox(height: 16),
              
              // Category and Priority row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Category',
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _showCategorySelector(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: colorScheme.outline),
                              borderRadius: BorderRadius.circular(8),
                              color: colorScheme.surface,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.folder_rounded),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _selectedCategory,
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Priority',
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _showPrioritySelector(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: colorScheme.outline),
                              borderRadius: BorderRadius.circular(8),
                              color: colorScheme.surface,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.flag_rounded),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: Wrap(
                                          children: List.generate(_selectedPriority, (i) => 
                                            const Icon(Icons.star, size: 16, color: Colors.amber)
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text('Priority $_selectedPriority', overflow: TextOverflow.ellipsis),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Tags section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tags',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _tagController,
                          decoration: const InputDecoration(
                            hintText: 'Add tag...',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.tag_rounded),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          onSubmitted: (_) {
                            _addTag();
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _addTag,
                        icon: const Icon(Icons.add_rounded),
                      ),
                    ],
                  ),
                  if (_tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _tags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          onDeleted: () => _removeTag(tag),
                          deleteIcon: const Icon(Icons.close, size: 16),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              
              // Color selection
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Color',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _colorOptions.map((color) {
                      final isSelected = _selectedColor == color;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedColor = color;
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _parseColor(color),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.outline.withOpacity(0.3),
                              width: isSelected ? 3 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: colorScheme.primary.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  color: _getContrastColor(_parseColor(color)),
                                  size: 20,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Favorite toggle
              Row(
                children: [
                  Checkbox(
                    value: _isFavorite,
                    onChanged: (value) {
                      setState(() {
                        _isFavorite = value!;
                      });
                    },
                  ),
                  Text(
                    'Mark as favorite',
                    style: theme.textTheme.titleSmall,
                  ),
                  const Spacer(),
                  if (_isFavorite)
                    Icon(
                      Icons.favorite_rounded,
                      color: Colors.red,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () {
                      if (_titleController.text.isNotEmpty || _contentController.text.isNotEmpty) {
                        widget.onNoteCreated(
                          _titleController.text.isEmpty ? 'Untitled' : _titleController.text,
                          _contentController.text,
                          _tags,
                          _selectedColor,
                          _selectedCategory,
                          _selectedPriority,
                          _isFavorite,
                        );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Note created successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Create Note'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.white;
    }
  }

  Color _getContrastColor(Color backgroundColor) {
    double luminance = (0.299 * backgroundColor.red + 
                      0.587 * backgroundColor.green + 
                      0.114 * backgroundColor.blue) / 255;
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
}

class NoteDetailScreen extends StatefulWidget {
  final Note note;
  final Function(Note) onNoteUpdated;
  final Function(String) onNoteDeleted;

  const NoteDetailScreen({
    super.key, 
    required this.note,
    required this.onNoteUpdated,
    required this.onNoteDeleted,
  });

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late Note _currentNote;
  bool _isEditing = false;
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  final TextEditingController _tagController = TextEditingController();
  List<String> _tags = [];
  String _selectedColor = '#FFFFFF';

  final List<String> _colorOptions = [
    '#FFFFFF', '#E3F2FD', '#F3E5F5', '#E8F5E8', 
    '#FFF3E0', '#FCE4EC', '#E0F2F1', '#FFF8E1',
  ];

  @override
  void initState() {
    super.initState();
    _currentNote = widget.note;
    _titleController = TextEditingController(text: _currentNote.title);
    _contentController = TextEditingController(text: _currentNote.content);
    _tags = List.from(_currentNote.tags);
    _selectedColor = _currentNote.color;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    if (_isEditing) {
      // Save changes
      final updatedNote = _currentNote.copyWith(
        title: _titleController.text.isEmpty ? 'Untitled' : _titleController.text,
        content: _contentController.text,
        tags: _tags,
        color: _selectedColor,
      );
      widget.onNoteUpdated(updatedNote);
      setState(() {
        _currentNote = updatedNote;
        _isEditing = false;
      });
    } else {
      // Enter edit mode
      setState(() {
        _isEditing = true;
      });
    }
  }

  void _deleteNote() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onNoteDeleted(_currentNote.id);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _togglePin() {
    final updatedNote = _currentNote.copyWith(isPinned: !_currentNote.isPinned);
    widget.onNoteUpdated(updatedNote);
    setState(() {
      _currentNote = updatedNote;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: _isEditing
                  ? TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Note title...',
                      ),
                      style: theme.textTheme.titleLarge,
                      autofocus: true,
                    )
                  : Text(
                      _currentNote.title,
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
            if (!_isEditing && _currentNote.isPinned)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.push_pin_rounded,
                  size: 20,
                  color: colorScheme.primary,
                ),
              ),
          ],
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: [
          if (_isEditing) ...[
            IconButton(
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _titleController.text = _currentNote.title;
                  _contentController.text = _currentNote.content;
                  _tags = List.from(_currentNote.tags);
                  _selectedColor = _currentNote.color;
                });
              },
              icon: const Icon(Icons.close_rounded),
            ),
            IconButton(
              onPressed: _toggleEdit,
              icon: const Icon(Icons.save_rounded),
            ),
          ] else ...[
            IconButton(
              onPressed: _togglePin,
              icon: Icon(
                _currentNote.isPinned
                    ? Icons.push_pin_rounded
                    : Icons.push_pin_outlined,
              ),
            ),
            IconButton(
              onPressed: _toggleEdit,
              icon: const Icon(Icons.edit_rounded),
            ),
            IconButton(
              onPressed: _deleteNote,
              icon: const Icon(Icons.delete_rounded),
            ),
          ],
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Metadata row
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                Text(
                  'Created: ${_formatDate(_currentNote.createdAt)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                if (_currentNote.modifiedAt != _currentNote.createdAt)
                  Text(
                    'Modified: ${_formatDate(_currentNote.modifiedAt)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
              ],
            ),
            
            // Tags section (editable)
            if (_isEditing || _tags.isNotEmpty) ...[
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tags',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  if (_isEditing) ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _tagController,
                            decoration: const InputDecoration(
                              hintText: 'Add tag...',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            onSubmitted: (_) => _addTag(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _addTag,
                          icon: const Icon(Icons.add_rounded),
                        ),
                      ],
                    ),
                  ],
                  if (_tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _tags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          backgroundColor: colorScheme.primaryContainer,
                          labelStyle: TextStyle(
                            color: colorScheme.onPrimaryContainer,
                          ),
                          onDeleted: _isEditing ? () => _removeTag(tag) : null,
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ],
            
            // Color selection (only in edit mode)
            if (_isEditing) ...[
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Color',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _colorOptions.map((color) {
                      final isSelected = _selectedColor == color;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedColor = color;
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _parseColor(color),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.outline.withOpacity(0.3),
                              width: isSelected ? 3 : 1,
                            ),
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  color: _getContrastColor(_parseColor(color)),
                                  size: 20,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Content
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _parseColor(_currentNote.color),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: _isEditing
                    ? TextField(
                        controller: _contentController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Start typing your note...',
                        ),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          height: 1.6,
                          color: _getContrastColor(_parseColor(_currentNote.color)),
                        ),
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                      )
                    : Text(
                        _currentNote.content,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          height: 1.6,
                          color: _getContrastColor(_parseColor(_currentNote.color)),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.white;
    }
  }

  Color _getContrastColor(Color backgroundColor) {
    double luminance = (0.299 * backgroundColor.red + 
                      0.587 * backgroundColor.green + 
                      0.114 * backgroundColor.blue) / 255;
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
}
