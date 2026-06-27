import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/musolla_provider.dart';
import '../../widgets/app_states.dart';
import '../../widgets/musolla_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusollaProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Search Musolla')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                labelText: 'Search by name or location',
              ),
              onChanged: _onChanged,
            ),
          ),
          Expanded(
            child: Builder(
              builder: (_) {
                if (provider.loading) return const SkeletonList();
                if (_controller.text.trim().isEmpty) {
                  return const EmptyState(
                    icon: Icons.search,
                    title: 'Start searching',
                    message: 'Type a musolla name or campus location.',
                  );
                }
                if (provider.searchResults.isEmpty) {
                  return const EmptyState(
                    icon: Icons.search_off,
                    title: 'No result',
                    message: 'Try a different keyword.',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.searchResults.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => MusollaCard(
                    musolla: provider.searchResults[index],
                    onTap: () => context.push(
                      '/musolla/${provider.searchResults[index].id}',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 350),
      () => context.read<MusollaProvider>().search(value),
    );
  }
}
