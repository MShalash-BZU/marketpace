import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../shared/models/store.dart';
import '../../../../../shared/models/product.dart';
import '../../../../../shared/models/category.dart';

class StoresRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all stores
  Future<List<Store>> getStores({
    String? categoryId,
    String? townId,
    bool? isActive,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      dynamic query = _supabase
          .from('stores')
          .select('''
            id,
            name,
            town_id,
            address_text,
            category_id,
            owner_user_id,
            is_active,
            opening_hours_json,
            expected_prep_minutes,
            image_url,
            cover_image_url,
            created_at,
            categories!inner(name)
          ''');

      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }

      if (townId != null) {
        query = query.eq('town_id', townId);
      }

      if (isActive != null) {
        query = query.eq('is_active', isActive);
      }

      query = query.order('created_at', ascending: false).range(offset, offset + limit - 1);

      final response = await query;

      return (response as List)
          .map((json) {
            // Add category name to store json
            final storeJson = Map<String, dynamic>.from(json);
            if (json['categories'] != null) {
              storeJson['category_name'] = json['categories']['name'];
            }
            return Store.fromJson(storeJson);
          })
          .toList();
    } catch (e) {
      throw ServerException('Failed to fetch stores: ${e.toString()}');
    }
  }

  // Get store by ID
  Future<Store> getStoreById(String storeId) async {
    try {
      final response = await _supabase
          .from('stores')
          .select('''
            id,
            name,
            town_id,
            address_text,
            category_id,
            owner_user_id,
            is_active,
            opening_hours_json,
            expected_prep_minutes,
            image_url,
            cover_image_url,
            created_at,
            categories!inner(name)
          ''')
          .eq('id', storeId)
          .single();

      final storeJson = Map<String, dynamic>.from(response);
      if (response['categories'] != null) {
        storeJson['category_name'] = response['categories']['name'];
      }

      return Store.fromJson(storeJson);
    } catch (e) {
      throw ServerException('Failed to fetch store: ${e.toString()}');
    }
  }

  // Get products by store
  Future<List<Product>> getProductsByStore(
    String storeId, {
    String? categoryId,
    bool? isActive,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      dynamic query = _supabase
          .from('products')
          .select('''
            id,
            name,
            store_id,
            category_id,
            description,
            price,
            sku,
            stock_qty,
            low_stock_threshold,
            is_active,
            created_at
          ''')
          .eq('store_id', storeId);

      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }

      if (isActive != null) {
        query = query.eq('is_active', isActive);
      }

      query = query.order('created_at', ascending: false).range(offset, offset + limit - 1);

      final response = await query;

      // Get product images for each product
      final products = <Product>[];
      for (var json in response as List) {
        final productId = json['id'] as String;

        // Get images for this product
        final imagesResponse = await _supabase
            .from('product_images')
            .select('url')
            .eq('product_id', productId)
            .order('sort_order');

        final imageUrls = (imagesResponse as List)
            .map((img) => img['url'] as String)
            .toList();

        final productJson = Map<String, dynamic>.from(json);
        productJson['image_urls'] = imageUrls;

        products.add(Product.fromJson(productJson));
      }

      return products;
    } catch (e) {
      throw ServerException('Failed to fetch products: ${e.toString()}');
    }
  }

  // Get all categories
  Future<List<Category>> getCategories({bool? isActive}) async {
    try {
      var query = _supabase
          .from('categories')
          .select()
          .order('name');

      if (isActive != null) {
        query = (query as dynamic).eq('is_active', isActive);
      }

      final response = await query;

      return (response as List)
          .map((json) => Category.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException('Failed to fetch categories: ${e.toString()}');
    }
  }

  // Search stores
  Future<List<Store>> searchStores(String query) async {
    try {
      final response = await _supabase
          .from('stores')
          .select('''
            *,
            categories!inner(name)
          ''')
          .ilike('name', '%$query%')
          .eq('is_active', true)
          .limit(20);

      return (response as List)
          .map((json) {
            final storeJson = Map<String, dynamic>.from(json);
            if (json['categories'] != null) {
              storeJson['category_name'] = json['categories']['name'];
            }
            return Store.fromJson(storeJson);
          })
          .toList();
    } catch (e) {
      throw ServerException('Failed to search stores: ${e.toString()}');
    }
  }

  // Get featured/popular stores
  Future<List<Store>> getFeaturedStores({int limit = 10}) async {
    try {
      // For now, get stores with highest ratings
      // TODO: Add a 'is_featured' flag to stores table
      final response = await _supabase
          .from('stores')
          .select('''
            *,
            categories!inner(name)
          ''')
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) {
            final storeJson = Map<String, dynamic>.from(json);
            if (json['categories'] != null) {
              storeJson['category_name'] = json['categories']['name'];
            }
            return Store.fromJson(storeJson);
          })
          .toList();
    } catch (e) {
      throw ServerException('Failed to fetch featured stores: ${e.toString()}');
    }
  }
}