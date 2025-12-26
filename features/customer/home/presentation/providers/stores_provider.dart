import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../shared/models/store.dart';
import '../../../../../shared/models/category.dart';
import '../../data/repositories/stores_repository.dart';

// Repository Provider
final storesRepositoryProvider = Provider<StoresRepository>((ref) {
  return StoresRepository();
});

// Minimal state for stores list used by UI
class StoresState {
  final List<Store> stores;
  final bool isLoading;
  final String searchQuery;
  final String? selectedCategoryId;
  final String? error;
  final bool hasMore;

  StoresState({
    this.stores = const [],
    this.isLoading = false,
    this.searchQuery = '',
    this.selectedCategoryId,
    this.error,
    this.hasMore = true,
  });

  StoresState copyWith({
    List<Store>? stores,
    bool? isLoading,
    String? searchQuery,
    String? selectedCategoryId,
    String? error,
    bool? hasMore,
  }) {
    return StoresState(
      stores: stores ?? this.stores,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      error: error,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class StoresNotifier extends StateNotifier<StoresState> {
  final StoresRepository _repository;

  StoresNotifier(this._repository) : super(StoresState()) {
    loadStores();
  }

  Future<void> loadStores({bool refresh = false}) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final stores = await _repository.getStores(
        categoryId: state.selectedCategoryId,
        isActive: true,
        limit: 20,
        offset: refresh ? 0 : state.stores.length,
      );

      if (refresh) {
        state = state.copyWith(
          stores: stores,
          isLoading: false,
          hasMore: stores.length == 20,
        );
      } else {
        state = state.copyWith(
          stores: [...state.stores, ...stores],
          isLoading: false,
          hasMore: stores.length == 20,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await loadStores(refresh: true);
  }

  Future<void> loadMoreStores() async {
    if (!state.hasMore || state.isLoading) return;
    await loadStores();
  }

  Future<void> searchStores(String query) async {
    state = state.copyWith(searchQuery: query, isLoading: true, error: null);

    try {
      if (query.isEmpty) {
        // إذا كان البحث فارغاً، قم بتحميل المتاجر العادية
        await loadStores(refresh: true);
        return;
      }

      final stores = await _repository.searchStores(query);

      state = state.copyWith(
        stores: stores,
        isLoading: false,
        hasMore: false, // البحث لا يدعم pagination حالياً
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void filterByCategory(String? categoryId) {
    state = state.copyWith(selectedCategoryId: categoryId);
    loadStores(refresh: true);
  }
}

final storesProvider = StateNotifierProvider<StoresNotifier, StoresState>((ref) {
  return StoresNotifier(ref.watch(storesRepositoryProvider));
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repository = ref.watch(storesRepositoryProvider);
  return repository.getCategories();
});
