import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bwthw_project/nutrition/models/food_search_hit.dart';
import 'package:bwthw_project/nutrition/models/meal_entry.dart';
import 'package:bwthw_project/nutrition/nutrition_exceptions.dart';
import 'package:bwthw_project/nutrition/nutrition_service.dart';
import 'package:bwthw_project/state/meal_store.dart';
import 'package:bwthw_project/widgets/food_typeahead_field.dart';
import 'package:bwthw_project/widgets/macros_chips.dart';
import 'package:bwthw_project/widgets/totals_card.dart';

extension _StringExt on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}

class MealPage extends StatefulWidget {
  const MealPage({super.key, required this.username});

  final String username;

  @override
  State<MealPage> createState() => _MealPageState();
}

class _MealPageState extends State<MealPage> {
  late MealStore _store;
  late NutritionService _service;
  bool _initialized = false;
  String? _initError;

  final Map<String, TextEditingController> _qtyControllers =
      {}; //handling of quantity inputs

  @override
  void initState() {
    super.initState();
    _init();
  }

  //initialize with sharedpreferences data and create meal handling objects
  Future<void> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _store = MealStore(prefs: prefs, username: widget.username);
      _service = NutritionService();
      await _store.load();
      if (mounted) setState(() => _initialized = true);
    } catch (e) {
      if (mounted) setState(() => _initError = e.toString());
    }

    setState(() => _initialized = true);
  }

  @override
  void dispose() {
    for (final c in _qtyControllers.values) {
      c.dispose();
    }
    if (_initialized) _service.dispose();
    super.dispose();
  }

  Future<void> _onHitSelected(String entryId, FoodSearchHit hit) async {
    _store.updateEntry(entryId, (e) {
      e.foodName = hit.description;
      e.fdcId = hit.fdcId;
    });
    try {
      final detail = await _service.detail(hit.fdcId);
      _store.updateEntry(entryId, (e) => e.applyDetail(detail));
    } on NutritionAuthException catch (e) {
      _showSnackBar(e.message);
    } on NutritionRateLimitException catch (e) {
      _showSnackBar(e.message);
    } on NutritionTransportException catch (e) {
      _showSnackBar('Network error: ${e.cause}');
    } on NutritionSchemaException catch (e) {
      debugPrint('NutritionSchemaException: ${e.errors}');
      _showSnackBar(
        'Could not read nutrition data for this food. Try a different name.',
      );
    }
  }

  Future<void> _save() async {
    await _store.save();
    if (mounted) _showSnackBar('Saved!');
  }

  //handles user communication
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  //initialize page
  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      automaticallyImplyLeading: false,
      title: const Text('Meals')
    );
    //if there's an error in initiation, then retry initiation
    if (_initError != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Weekly Data'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 8),
              const Text('Could not load meal data.'),
              TextButton(
                onPressed: () => setState(() {
                  _initError = null;
                  _initialized = false;
                  _init();
                }),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    //if it's not initialized, wait for it to be
    if (!_initialized) {
      return Scaffold(
        appBar: appBar,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    //injecting state through the root of the page's tree
    return ChangeNotifierProvider.value(
      value: _store,
      child: Scaffold(
        appBar: appBar,
        body: _buildBody(),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () => Navigator.pop(context, "home"),
              ),
              IconButton(
                icon: const Icon(Icons.bar_chart),
                onPressed: () => Navigator.pop(context, "data"),
              ),
              ElevatedButton(onPressed: _save, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }

  //function to rebuild the function's body, returning a consumer for state updatability
  Widget _buildBody() {
    return Consumer<MealStore>(
      builder: (context, store, _) {
        final currentIds = store.entries.map((e) => e.id).toSet();
        _qtyControllers.keys
            .where((id) => !currentIds.contains(id))
            .toList()
            .forEach((id) {
              _qtyControllers[id]!.dispose();
              _qtyControllers.remove(id);
            });
        for (final entry in store.entries) {
          _qtyControllers.putIfAbsent(
            entry.id,
            () => TextEditingController(
              text: entry.quantity == 0.0 ? '' : entry.quantity.toString(),
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              _SlotDropdown(store: store),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: store.entries.length,
                itemBuilder: (context, index) {
                  final entry = store.entries[index];
                  return _MealEntryRow(
                    entry: entry,
                    index: index,
                    store: store,
                    service: _service,
                    qtyController: _qtyControllers[entry.id]!,
                    onHitSelected: _onHitSelected,
                    onError: _showSnackBar,
                  );
                },
              ),
              TotalsCard(store: store),
              _AddRowButton(store: store),
            ],
          ),
        );
      },
    );
  }
}

class _SlotDropdown extends StatelessWidget {
  const _SlotDropdown({required this.store});

  final MealStore store;

  @override
  Widget build(BuildContext context) {
    //horizontal chip selector, one chip per meal slot
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: MealSlot.values.map((slot) {
            final selected = slot == store.currentSlot;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(slot.name.capitalize()),
                selected: selected,
                showCheckmark: false,
                onSelected: (_) => store.selectSlot(slot),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

//handles addition of foods
class _AddRowButton extends StatelessWidget {
  const _AddRowButton({required this.store});

  final MealStore store;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton.icon(
        onPressed: store.addRow,
        icon: const Icon(Icons.add),
        label: const Text('Add food'),
      ),
    );
  }
}

//handles and shows single food row
class _MealEntryRow extends StatelessWidget {
  const _MealEntryRow({
    required this.entry,
    required this.index,
    required this.store,
    required this.service,
    required this.qtyController,
    required this.onHitSelected,
    required this.onError,
  });

  final MealEntry entry;
  final int index;
  final MealStore store;
  final NutritionService service;
  final TextEditingController qtyController;
  final Future<void> Function(String entryId, FoodSearchHit hit) onHitSelected;
  final void Function(String msg) onError;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Text(
                  'ENTRY ${index + 1}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Theme.of(context).colorScheme.error,
                  onPressed: () => store.removeRow(entry.id),
                ),
              ],
            ),
            // Food search
            FoodTypeaheadField(
              service: service,
              initialValue: entry.foodName,
              onHitSelected: (hit) => onHitSelected(entry.id, hit),
              onError: onError,
            ),
            const SizedBox(height: 8),
            // Quantity + unit row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: qtyController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Qty'),
                    onChanged: (v) {
                      store.updateEntry(entry.id, (e) {
                        e.quantity = double.tryParse(v) ?? 0;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<MealUnit>(
                  value: entry.unit,
                  items: MealUnit.values
                      .map(
                        (u) => DropdownMenuItem(
                          value: u,
                          enabled: u != MealUnit.piece || entry.pieceAvailable,
                          child: Text(
                            u.name,
                            style: u == MealUnit.piece && !entry.pieceAvailable
                                ? const TextStyle(color: Colors.grey)
                                : null,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (u) {
                    if (u != null) {
                      store.updateEntry(entry.id, (e) {
                        e.unit = u;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Macros chips
            MacrosChips(entry: entry),
          ],
        ),
      ),
    );
  }
}
