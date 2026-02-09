import 'package:flutter/material.dart';
import 'package:blute_mobile/core/theme/app_colors.dart';
import 'package:blute_mobile/features/contests/presentation/widgets/contest_home_tab.dart';
import 'package:blute_mobile/features/contests/presentation/widgets/contest_team_tab.dart';
import 'package:blute_mobile/features/contests/presentation/widgets/contest_leaderboard_tab.dart';
import 'package:blute_mobile/features/contests/presentation/widgets/contest_matches_tab.dart';
import 'package:blute_mobile/features/gigs/data/gig_model.dart';

class ContestDetailsScreen extends StatefulWidget {
  final Gig? gig;
  const ContestDetailsScreen({super.key, this.gig});

  @override
  State<ContestDetailsScreen> createState() => _ContestDetailsScreenState();
}

class _ContestDetailsScreenState extends State<ContestDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging ||
          _tabController.animation!.value == _tabController.index) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve arguments if needed
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final title = widget.gig?.title ?? args?['name'] ?? 'Cricket Championship';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title, style: Theme.of(context).appBarTheme.titleTextStyle),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            color: AppColors.background,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: Colors.transparent,
              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
              dividerColor: Colors.transparent,
              tabs: [
                _buildTab('Home', 0),
                _buildTab('Team', 1),
                _buildTab('Leaderboard', 2),
                _buildTab('Matches', 3),
              ],
              onTap: (index) {
                setState(() {});
              },
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Form teams and compete in delivery-based cricket',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                ContestHomeTab(
                  onNavigateToTeam: () => _tabController.animateTo(1),
                  onNavigateToLeaderboard: () => _tabController.animateTo(2),
                ),
                const ContestTeamTab(),
                const ContestLeaderboardTab(),
                const ContestMatchesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    final isSelected = _tabController.index == index;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: isSelected ? null : Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          if (isSelected && index == 0) ...[
            const Icon(Icons.home, size: 16, color: Colors.white),
            const SizedBox(width: 4),
          ],
          if (isSelected && index == 1) ...[
            const Icon(Icons.people, size: 16, color: Colors.white),
            const SizedBox(width: 4),
          ],
          if (isSelected && index == 2) ...[
            const Icon(Icons.emoji_events, size: 16, color: Colors.white),
            const SizedBox(width: 4),
          ],
          if (isSelected && index == 3) ...[
            const Icon(Icons.sports_cricket, size: 16, color: Colors.white),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
