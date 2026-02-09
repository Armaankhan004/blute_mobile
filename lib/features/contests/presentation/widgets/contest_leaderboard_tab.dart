import 'package:flutter/material.dart';
import 'package:blute_mobile/core/theme/app_colors.dart';

class ContestLeaderboardTab extends StatelessWidget {
  const ContestLeaderboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Team Rankings',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            itemBuilder: (context, index) {
              return _buildRankingItem(index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRankingItem(int index) {
    final rankings = [
      {
        'rank': 1,
        'team': 'Delivery Kings',
        'players': 3,
        'wins': '2/3',
        'runs': 379,
        'deliveries': 57,
      },
      {
        'rank': 2,
        'team': 'Speed Demons',
        'players': 2,
        'wins': '1/3',
        'runs': 240,
        'deliveries': 45,
      },
      {
        'rank': 3,
        'team': 'Road Warriors',
        'players': 4,
        'wins': '0/3',
        'runs': 185,
        'deliveries': 38,
      },
      {
        'rank': 4,
        'team': 'City Express',
        'players': 3,
        'wins': '1/3',
        'runs': 150,
        'deliveries': 32,
      },
      {
        'rank': 5,
        'team': 'Night  Riders',
        'players': 2,
        'wins': '0/3',
        'runs': 120,
        'deliveries': 28,
      },
    ];

    final item = rankings[index];
    final isTopRank = index == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isTopRank
            ? AppColors.primary.withOpacity(0.05)
            : AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTopRank
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.border,
        ),
        boxShadow: [
          if (!isTopRank)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isTopRank ? AppColors.primary : AppColors.surface,
            radius: 16,
            child: Text(
              '${item['rank']}',
              style: TextStyle(
                color: isTopRank ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['team'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item['players']} players • ${item['wins']} wins • ${item['deliveries']} deliveries',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item['runs']}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.textPrimary,
                ),
              ),
              const Text(
                'runs',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
