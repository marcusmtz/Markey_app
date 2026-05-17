import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/routing/route_names.dart';
import '../../../vault/presentation/providers/vault_provider.dart';
import '../../domain/security_analyzer_service.dart';
import '../providers/security_provider.dart';
import '../widgets/security_score_chart.dart';
import '../widgets/security_category_card.dart';
import '../widgets/security_issue_card.dart';

/// Security analysis screen displaying vault security report
class SecurityAnalysisScreen extends StatefulWidget {
  const SecurityAnalysisScreen({super.key});

  @override
  State<SecurityAnalysisScreen> createState() => _SecurityAnalysisScreenState();
}

class _SecurityAnalysisScreenState extends State<SecurityAnalysisScreen> {
  @override
  void initState() {
    super.initState();
    // Analyze vault when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SecurityProvider>().analyzeVault();
    });
  }

  void _onRefresh() {
    context.read<SecurityProvider>().analyzeVault();
  }

  void _showIssuesByType(SecurityIssueType type, String title) {
    final provider = context.read<SecurityProvider>();
    final issues = provider.getIssuesByType(type);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _IssuesBottomSheet(title: title, issues: issues),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Analysis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _onRefresh,
            tooltip: 'Refresh Analysis',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
            tooltip: 'Information',
          ),
        ],
      ),
      body: Consumer<SecurityProvider>(
        builder: (context, provider, child) {
          if (provider.isAnalyzing) {
            return _buildShimmerLoading(theme);
          }

          if (provider.errorMessage != null) {
            return _buildErrorState(theme, provider.errorMessage!, _onRefresh);
          }

          if (!provider.hasReport) {
            return _buildEmptyState(theme);
          }

          final report = provider.report!;

          return RefreshIndicator(
            onRefresh: () async => _onRefresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Security Score Chart
                  Center(child: SecurityScoreChart(score: report.overallScore))
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1, 1),
                        duration: 600.ms,
                        curve: Curves.easeOutBack,
                      ),

                  const SizedBox(height: 32),

                  // Summary Text
                  Text(
                        _getSummaryText(report),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.8,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      )
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 400.ms)
                      .slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 32),

                  // Category Cards
                  Text(
                    'Security Issues',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: 16),

                  AnimationLimiter(
                    child: Column(
                      children: [
                        // Weak Passwords
                        AnimationConfiguration.staggeredList(
                          position: 0,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: SecurityCategoryCard(
                                  title: 'Weak Passwords',
                                  subtitle: 'Passwords that need strengthening',
                                  count: report.weakPasswords,
                                  icon: Icons.lock_open,
                                  color: Colors.orange,
                                  onTap: report.weakPasswords > 0
                                      ? () => _showIssuesByType(
                                          SecurityIssueType.weakPassword,
                                          'Weak Passwords',
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Duplicate Passwords
                        AnimationConfiguration.staggeredList(
                          position: 1,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: SecurityCategoryCard(
                                  title: 'Duplicate Passwords',
                                  subtitle: 'Passwords used multiple times',
                                  count: report.duplicatePasswords,
                                  icon: Icons.content_copy,
                                  color: Colors.red,
                                  onTap: report.duplicatePasswords > 0
                                      ? () => _showIssuesByType(
                                          SecurityIssueType.duplicatePassword,
                                          'Duplicate Passwords',
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Compromised Passwords
                        AnimationConfiguration.staggeredList(
                          position: 2,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: SecurityCategoryCard(
                                  title: 'Compromised Passwords',
                                  subtitle: 'Found in data breaches',
                                  count: report.compromisedPasswords,
                                  icon: Icons.warning,
                                  color: Colors.deepOrange,
                                  onTap: report.compromisedPasswords > 0
                                      ? () => _showIssuesByType(
                                          SecurityIssueType.compromisedPassword,
                                          'Compromised Passwords',
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Total Passwords Info
                        AnimationConfiguration.staggeredList(
                          position: 3,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: SecurityCategoryCard(
                                title: 'Total Passwords',
                                subtitle: 'Passwords in your vault',
                                count: report.totalPasswords,
                                icon: Icons.lock,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // All Issues Section
                  if (report.issues.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'All Issues',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error.withValues(
                              alpha: 0.2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${report.issues.length}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 600.ms),

                    const SizedBox(height: 16),

                    AnimationLimiter(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: report.issues.length,
                        itemBuilder: (context, index) {
                          final issue = report.issues[index];
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: SecurityIssueCard(
                                    issue: issue,
                                    onTap: () async {
                                      // Find the entry in the vault
                                      final vaultProvider = context
                                          .read<VaultProvider>();
                                      final entry = vaultProvider.entries
                                          .firstWhere(
                                            (e) => e.id == issue.entryId,
                                            orElse: () => throw Exception(
                                              'Entry not found',
                                            ),
                                          );

                                      // Navigate to entry detail
                                      await Navigator.of(context).pushNamed(
                                        RouteNames.entryDetail,
                                        arguments: EntryDetailArguments(
                                          entry: entry,
                                          heroTag: 'security_${entry.id}',
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getSummaryText(SecurityReport report) {
    if (report.totalPasswords == 0) {
      return 'Your vault is empty. Add some passwords to see security analysis.';
    }

    if (report.overallScore >= 80) {
      return 'Great job! Your passwords are secure. Keep up the good work!';
    } else if (report.overallScore >= 60) {
      return 'Your security is good, but there\'s room for improvement.';
    } else if (report.overallScore >= 40) {
      return 'Your passwords need attention. Consider strengthening weak passwords.';
    } else {
      return 'Your passwords are at risk. Please update weak and duplicate passwords immediately.';
    }
  }

  Widget _buildShimmerLoading(ThemeData theme) {
    return Shimmer.fromColors(
      baseColor: theme.brightness == Brightness.light
          ? Colors.grey[300]!
          : Colors.grey[700]!,
      highlightColor: theme.brightness == Brightness.light
          ? Colors.grey[100]!
          : Colors.grey[600]!,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Score chart placeholder
            Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 32),
            // Category cards placeholders
            ...List.generate(
              4,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    ThemeData theme,
    String message,
    VoidCallback onRetry,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('Error', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.security,
              size: 64,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text('No Analysis Available', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Tap the refresh button to analyze your vault security',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline),
            SizedBox(width: 12),
            Text('Security Score'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildScoreInfo(context, 'Excellent', Colors.green, '80-100'),
            const SizedBox(height: 8),
            _buildScoreInfo(context, 'Good', Colors.lightGreen, '60-79'),
            const SizedBox(height: 8),
            _buildScoreInfo(context, 'Fair', Colors.orange, '40-59'),
            const SizedBox(height: 8),
            _buildScoreInfo(context, 'Poor', Colors.red, '0-39'),
            const SizedBox(height: 16),
            Text(
              'Your security score is calculated based on password strength, duplicates, and compromised passwords.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreInfo(
    BuildContext context,
    String label,
    Color color,
    String range,
  ) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(range, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

/// Bottom sheet displaying filtered issues
class _IssuesBottomSheet extends StatelessWidget {
  final String title;
  final List<SecurityIssue> issues;

  const _IssuesBottomSheet({required this.title, required this.issues});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${issues.length}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Issues list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: issues.length,
                  itemBuilder: (context, index) {
                    final issue = issues[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SecurityIssueCard(
                        issue: issue,
                        onTap: () async {
                          // Find the entry in the vault
                          final vaultProvider = context.read<VaultProvider>();
                          final entry = vaultProvider.entries.firstWhere(
                            (e) => e.id == issue.entryId,
                            orElse: () => throw Exception('Entry not found'),
                          );

                          // Close bottom sheet
                          Navigator.of(context).pop();

                          // Navigate to entry detail
                          await Navigator.of(context).pushNamed(
                            RouteNames.entryDetail,
                            arguments: EntryDetailArguments(
                              entry: entry,
                              heroTag: 'security_${entry.id}',
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
