import 'package:flutter/material.dart';
import 'package:blute_mobile/core/theme/app_colors.dart';
import 'package:blute_mobile/features/profile/data/user_remote_datasource.dart';
import 'package:blute_mobile/features/profile/data/models/partner_id_model.dart';

class PartnerIdsScreen extends StatefulWidget {
  const PartnerIdsScreen({super.key});

  @override
  State<PartnerIdsScreen> createState() => _PartnerIdsScreenState();
}

class _PartnerIdsScreenState extends State<PartnerIdsScreen> {
  final UserRemoteDataSource _userDataSource = UserRemoteDataSource();
  List<PartnerID> _partnerIds = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchPartnerIds();
  }

  Future<void> _fetchPartnerIds() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final ids = await _userDataSource.getPartnerIDs();
      setState(() {
        _partnerIds = ids;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deletePartnerId(String id) async {
    try {
      await _userDataSource.deletePartnerID(id);
      _fetchPartnerIds();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Partner ID deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Partner IDs',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: $_errorMessage'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchPartnerIds,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _partnerIds.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.badge_outlined,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Partner IDs added yet',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.pushNamed(
                        context,
                        '/add-partner-id',
                      );
                      if (result == true) {
                        _fetchPartnerIds();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Add Your First ID'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchPartnerIds,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _partnerIds.length,
                itemBuilder: (context, index) {
                  final pId = _partnerIds[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.badge,
                          color: AppColors.primary,
                        ),
                      ),
                      title: Text(
                        pId.platform,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            'ID: ${pId.partnerIdCode}',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                          ),
                          if (pId.idPhotoUrl != null) ...[
                            const SizedBox(height: 8),
                            const Text(
                              'Photo Verified',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () => _deletePartnerId(pId.id),
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: _partnerIds.isNotEmpty
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.pushNamed(
                  context,
                  '/add-partner-id',
                );
                if (result == true) {
                  _fetchPartnerIds();
                }
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
