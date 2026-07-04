import 'dart:async';

import 'package:flutter/material.dart';

import 'package:bwthw_project/nutrition/models/food_search_hit.dart';
import 'package:bwthw_project/nutrition/nutrition_exceptions.dart';
import 'package:bwthw_project/nutrition/nutrition_service.dart';

//food entry widget, used to handle food changes in meal_page
class FoodTypeaheadField extends StatefulWidget {
  const FoodTypeaheadField({
    super.key,
    required this.service,
    required this.onHitSelected,
    this.initialValue = '',
    this.onError,
    this.debounceDuration = const Duration(milliseconds: 1500), //ensures automatic refresh after 3 seconds
  });

  final NutritionService service;
  final void Function(FoodSearchHit hit) onHitSelected; //callback for function initiation
  final String initialValue;
  final void Function(String message)? onError;
  final Duration debounceDuration;
  @override

  State<FoodTypeaheadField> createState() => _FoodTypeaheadFieldState();
}

class _FoodTypeaheadFieldState extends State<FoodTypeaheadField> {
  late final TextEditingController _controller;

  Timer? _debounceTimer;
  List<FoodSearchHit> _hits = [];
  bool _loading = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  //on change resets timer and reinstates it, if length is under 3 characters do nothing to spare tokens
  void _onChanged(String value) {
    _debounceTimer?.cancel();
    if (value.trim().length < 2) {
      setState(() {
        _hits = [];
        _errorText = null;
        _loading = false;
      });
      return;
    }
    _debounceTimer = Timer(widget.debounceDuration, () => _search(value));  //reinstates the timer
  }


  Future<void> _search(String query) async {
    setState(() {
      _loading = true;
      _errorText = null;
    });

    //attempts to retrieve the entry for the query, otherwise throws errors
    try {
      final results = await widget.service.search(query);
      if (!mounted) return;
      setState(() {
        _hits = results;
        _loading = false;
      });
    } on NutritionAuthException catch (e) {
      _handleError(e.message);
    } on NutritionRateLimitException catch (e) {
      _handleError(e.message);
    } on NutritionTransportException catch (e) {
      _handleError('Network error: ${e.cause}');
    } on NutritionSchemaException catch (e) {
      _handleError('Unexpected response from USDA: ${e.errors.first}');
    } catch (e) {
      _handleError('Unknown error: $e');
    }
  }

  //if any search error happens, return a feedback message for UX
  void _handleError(String message) {
    if (!mounted) return;
    setState(() {
      _hits = [];
      _loading = false;
      _errorText = message;
    });
    widget.onError?.call(message);
  }

  //if the food is chosen from the dropdown, saves it in the textField and nulls the dropdown
  void _onHitTapped(FoodSearchHit hit) {
    _debounceTimer?.cancel();
    _controller.text = hit.description;
    setState(() {
      _hits = [];
      _errorText = null;
      _loading = false;
    });
    widget.onHitSelected(hit);
  }

  //showing the widget in the page
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, //minimize space usage
      crossAxisAlignment: CrossAxisAlignment.stretch, //fill needed space
      children: [
        //handles live changes to the textField and returns query results from USDA database
        TextField(
          controller: _controller,
          onChanged: _onChanged,
          decoration: InputDecoration(
            labelText: 'Search food…',
            hintText: 'e.g. chicken breast',
            errorText: _errorText,

            //if it's loading, displays a circular indicator
            suffixIcon: _loading
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
          ),
        ),
        //if there are hits for the query, makes them appear as a dropdown
        if (_hits.isNotEmpty)
          Material(
            elevation: 4,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(14),
              bottomRight: Radius.circular(14),
            ),
            clipBehavior: Clip.antiAlias,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _hits.length,
              itemBuilder: (context, index) {
                final hit = _hits[index];
                return ListTile(
                  dense: true,
                  title: Text(
                    hit.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    hit.dataType,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                  ),
                  onTap: () => _onHitTapped(hit),
                );
              },
            ),
          ),
      ],
    );
  }
}
