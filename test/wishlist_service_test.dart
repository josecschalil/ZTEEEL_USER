import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zteel_user/services/wishlist_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    WishlistService.setMockItems([]);
  });

  group('WishlistItem model tests', () {
    test('serializes and deserializes correctly', () {
      final item = WishlistItem(
        id: 'dish_101',
        vendorId: 'vendor_5',
        restaurant: 'Burger Palace',
        name: 'Classic Smash Burger',
        price: 12.99,
        originalPrice: 15.99,
        imageUrl: 'https://example.com/burger.png',
        category: 'burgers',
        tag: 'Bestseller',
        rating: 4.8,
        distance: 1.5,
        description: 'Double beef patty with special sauce',
        createdAt: DateTime(2026, 1, 1),
      );

      final json = item.toJson();
      expect(json['id'], 'dish_101');
      expect(json['vendor_id'], 'vendor_5');
      expect(json['restaurant'], 'Burger Palace');
      expect(json['name'], 'Classic Smash Burger');
      expect(json['price'], 12.99);
      expect(json['original_price'], 15.99);
      expect(json['category'], 'burgers');

      final fromJson = WishlistItem.fromJson(json);
      expect(fromJson.id, 'dish_101');
      expect(fromJson.vendorId, 'vendor_5');
      expect(fromJson.restaurant, 'Burger Palace');
      expect(fromJson.name, 'Classic Smash Burger');
      expect(fromJson.price, 12.99);
      expect(fromJson.originalPrice, 15.99);
      expect(fromJson.hasDiscount, isTrue);
      expect(fromJson.savings, closeTo(3.0, 0.01));
    });

    test('handles fallback defaults and nulls gracefully', () {
      final fromJson = WishlistItem.fromJson({});
      expect(fromJson.id, '');
      expect(fromJson.name, 'Dish');
      expect(fromJson.restaurant, 'Restaurant');
      expect(fromJson.price, 0.0);
      expect(fromJson.hasDiscount, isFalse);
    });
  });

  group('WishlistService reactive state & persistence tests', () {
    test('addToWishlist updates notifiers and persists to SharedPreferences', () async {
      final item = const WishlistItem(
        id: 'dish_1',
        restaurant: 'Pizza Hub',
        name: 'Pepperoni Pizza',
        price: 14.50,
        category: 'pizza',
      );

      expect(WishlistService.isInWishlist('dish_1'), isFalse);
      expect(WishlistService.items.isEmpty, isTrue);

      final added = await WishlistService.addToWishlist(item);
      expect(added, isTrue);

      expect(WishlistService.isInWishlist('dish_1'), isTrue);
      expect(WishlistService.items.length, 1);
      expect(WishlistService.items.first.name, 'Pepperoni Pizza');
      expect(WishlistService.wishlistedItemIdsNotifier.value.contains('dish_1'), isTrue);

      // Verify SharedPreferences persistence
      final prefs = await SharedPreferences.getInstance();
      final savedRaw = prefs.getString('cached_wishlist_items_v1');
      expect(savedRaw, isNotNull);
      expect(savedRaw, contains('Pepperoni Pizza'));
    });

    test('removeFromWishlist updates notifiers and removes from cache', () async {
      final item1 = const WishlistItem(
        id: 'dish_1',
        restaurant: 'Pizza Hub',
        name: 'Pepperoni Pizza',
        price: 14.50,
      );
      final item2 = const WishlistItem(
        id: 'dish_2',
        restaurant: 'Taco Bar',
        name: 'Fish Tacos',
        price: 9.99,
      );

      await WishlistService.addToWishlist(item1);
      await WishlistService.addToWishlist(item2);
      expect(WishlistService.items.length, 2);

      final removed = await WishlistService.removeFromWishlist('dish_1');
      expect(removed, isTrue);
      expect(WishlistService.items.length, 1);
      expect(WishlistService.isInWishlist('dish_1'), isFalse);
      expect(WishlistService.isInWishlist('dish_2'), isTrue);
    });

    test('toggleWishlist toggles between add and remove', () async {
      final item = const WishlistItem(
        id: 'dish_toggle',
        restaurant: 'Sushi House',
        name: 'Salmon Roll',
        price: 8.50,
      );

      // 1. First toggle should add
      final firstResult = await WishlistService.toggleWishlist(item);
      expect(firstResult, isTrue);
      expect(WishlistService.isInWishlist('dish_toggle'), isTrue);

      // 2. Second toggle should remove
      final secondResult = await WishlistService.toggleWishlist(item);
      expect(secondResult, isFalse);
      expect(WishlistService.isInWishlist('dish_toggle'), isFalse);
    });

    test('clearWishlist empties the list and clears preferences', () async {
      final item = const WishlistItem(
        id: 'dish_clear',
        restaurant: 'Bakery',
        name: 'Croissant',
        price: 3.50,
      );

      await WishlistService.addToWishlist(item);
      expect(WishlistService.items.isNotEmpty, isTrue);

      await WishlistService.clearWishlist();
      expect(WishlistService.items.isEmpty, isTrue);
      expect(WishlistService.wishlistedItemIdsNotifier.value.isEmpty, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('cached_wishlist_items_v1'), isNull);
    });
  });
}
