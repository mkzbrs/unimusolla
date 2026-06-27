import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/musolla_provider.dart';
import '../../widgets/app_states.dart';
import '../../widgets/musolla_card.dart';

class MusollaListScreen extends StatefulWidget {
  const MusollaListScreen({super.key});

  @override
  State<MusollaListScreen> createState() => _MusollaListScreenState();
}

class _MusollaListScreenState extends State<MusollaListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<MusollaProvider>().loadList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusollaProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Musolla'),
        actions: [
          IconButton(
            onPressed: () => context.push('/search'),
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: provider.loadList,
        child: Builder(
          builder: (_) {
            if (provider.loading && provider.musollas.isEmpty)
              return const SkeletonList();
            if (provider.error != null && provider.musollas.isEmpty) {
              return ListView(
                children: [
                  SizedBox(
                    height: 480,
                    child: ErrorState(
                      message: provider.error!,
                      onRetry: provider.loadList,
                    ),
                  ),
                ],
              );
            }
            if (provider.musollas.isEmpty) {
              return const EmptyState(
                icon: Icons.mosque_outlined,
                title: 'No musollas yet',
                message: 'Approved musollas will appear here.',
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.musollas.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => MusollaCard(
                musolla: provider.musollas[index],
                onTap: () =>
                    context.push('/musolla/${provider.musollas[index].id}'),
              ),
            );
          },
        ),
      ),
    );
  }
}
