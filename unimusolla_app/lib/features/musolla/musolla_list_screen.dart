import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/musolla.dart';
import '../../providers/musolla_provider.dart';
import '../../widgets/app_states.dart';
import '../../widgets/musolla_card.dart';

class MusollaListScreen extends StatefulWidget {
  const MusollaListScreen({super.key});

  @override
  State<MusollaListScreen> createState() => _MusollaListScreenState();
}

class _MusollaListScreenState extends State<MusollaListScreen> {
  static const _blocks = [
    'All Blocks',
    'DKG 1',
    'DKG 2',
    'DKG 3',
    'DKG 4',
    'DKG 5',
    'DKG 6',
    'DKG 7',
  ];

  final _searchController = TextEditingController();
  String _query = '';
  String _selectedBlock = 'All Blocks';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<MusollaProvider>().loadList(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusollaProvider>();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'UniMusolla',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: const Color(0xFF004532),
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: const Color(0xFFF8F9FF),
        surfaceTintColor: const Color(0xFFF8F9FF),
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: .12),
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
            final musollas =
                provider.musollas.where((musolla) {
                  final text =
                      '${musolla.name} ${musolla.location} ${musolla.exactLocation}'
                          .toLowerCase();
                  final matchesQuery = _query.isEmpty || text.contains(_query);
                  final matchesBlock =
                      _selectedBlock == 'All Blocks' ||
                      _blockFor(musolla) == _selectedBlock;
                  return matchesQuery && matchesBlock;
                }).toList()..sort((a, b) {
                  final availability = b.available.toString().compareTo(
                    a.available.toString(),
                  );
                  if (availability != 0) return availability;
                  return a.name.toLowerCase().compareTo(b.name.toLowerCase());
                });

            return CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                  sliver: SliverToBoxAdapter(child: _searchPanel()),
                ),
                if (musollas.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.search_off_outlined,
                      title: 'No matching musollas',
                      message: 'Try another keyword or block filter.',
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverLayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.crossAxisExtent;
                        final columns = width >= 1040
                            ? 3
                            : width >= 680
                            ? 2
                            : 1;
                        return SliverGrid.builder(
                          itemCount: musollas.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: columns == 1 ? 1.04 : .92,
                              ),
                          itemBuilder: (context, index) => MusollaCard(
                            musolla: musollas[index],
                            onTap: () =>
                                context.push('/musolla/${musollas[index].id}'),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _searchPanel() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFBEC9C2).withValues(alpha: .5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: (value) =>
                  setState(() => _query = value.trim().toLowerCase()),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search Musollas...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF6F7973)),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                        icon: const Icon(Icons.close),
                        color: const Color(0xFF004532),
                      ),
                filled: true,
                fillColor: const Color(0xFFF8F9FF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFBEC9C2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFBEC9C2)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _blocks.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final block = _blocks[index];
                  final selected = block == _selectedBlock;
                  return ChoiceChip(
                    label: Text(block),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedBlock = block),
                    labelStyle: TextStyle(
                      color: selected
                          ? const Color(0xFF8BD6B7)
                          : const Color(0xFF3F4944),
                      fontWeight: FontWeight.w700,
                    ),
                    selectedColor: const Color(0xFF065F46),
                    backgroundColor: const Color(0xFFF8F9FF),
                    side: BorderSide(
                      color: selected
                          ? Colors.transparent
                          : const Color(0xFFBEC9C2),
                    ),
                    shape: const StadiumBorder(),
                    showCheckmark: false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _blockFor(Musolla musolla) {
    final source = '${musolla.location} ${musolla.name}'.trim();
    final dkgMatch = RegExp(
      r'\bDKG\s*\d+\b',
      caseSensitive: false,
    ).firstMatch(source);
    if (dkgMatch != null) {
      return dkgMatch.group(0)!.toUpperCase().replaceAll(RegExp(r'\s+'), ' ');
    }
    return '';
  }
}
