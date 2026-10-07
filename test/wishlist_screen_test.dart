import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zteel_user/screens/FoodItemPage.dart';
import 'package:zteel_user/screens/WishlistScreen.dart';
import 'package:zteel_user/services/wishlist_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    WishlistService.setMockItems([]);
  });

  group('WishlistScreen Widget Tests', () {
    testWidgets('renders empty state when no items are wishlisted', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Wishlistscreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Wishlist'), findsAtLeast(1));
      expect(find.text('Your wishlist is empty'), findsOneWidget);
      expect(find.text('Explore Foods'), findsOneWidget);
    });

    testWidgets('renders wishlisted items with dynamic categories', (tester) async {
      final sampleItems = [
        const WishlistItem(
          id: 'item_1',
          restaurant: 'The Burger Foundry',
          name: 'Truffle Wagyu Double Smash',
          price: 16.50,
          category: 'burgers',
          tag: 'Bestseller',
          rating: 4.9,
          distance: 0.4,
        ),
        const WishlistItem(
          id: 'item_2',
          restaurant: 'Bella Napoli',
          name: 'Wood-Fired Margherita',
          price: 18.00,
          category: 'pizza',
          tag: 'Vegetarian',
          rating: 4.8,
          distance: 0.8,
        ),
      ];

      WishlistService.setMockItems(sampleItems);

      await tester.pumpWidget(
        const MaterialApp(
          home: Wishlistscreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Truffle Wagyu Double Smash'), findsOneWidget);
      expect(find.text('The Burger Foundry'), findsOneWidget);
      expect(find.text('Wood-Fired Margherita'), findsOneWidget);
      expect(find.text('Bella Napoli'), findsOneWidget);
      expect(find.text('All (2)'), findsOneWidget);
      expect(find.text('Burgers (1)'), findsOneWidget);
      expect(find.text('Pizza (1)'), findsOneWidget);
    });

    testWidgets('filters items via search query', (tester) async {
      final sampleItems = [
        const WishlistItem(
          id: 'item_1',
          restaurant: 'The Burger Foundry',
          name: 'Truffle Wagyu Double Smash',
          price: 16.50,
          category: 'burgers',
        ),
        const WishlistItem(
          id: 'item_2',
          restaurant: 'Bella Napoli',
          name: 'Wood-Fired Margherita',
          price: 18.00,
          category: 'pizza',
        ),
      ];

      WishlistService.setMockItems(sampleItems);

      await tester.pumpWidget(
        const MaterialApp(
          home: Wishlistscreen(),
        ),
      );
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'Margherita');
      await tester.pumpAndSettle();

      expect(find.text('Wood-Fired Margherita'), findsOneWidget);
      expect(find.text('Truffle Wagyu Double Smash'), findsNothing);
    });

    testWidgets('removes an item when tapping heart in WishlistScreen', (tester) async {
      final sampleItems = [
        const WishlistItem(
          id: 'item_1',
          restaurant: 'The Burger Foundry',
          name: 'Truffle Wagyu Double Smash',
          price: 16.50,
          category: 'burgers',
        ),
      ];

      WishlistService.setMockItems(sampleItems);

      await tester.pumpWidget(
        const MaterialApp(
          home: Wishlistscreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Truffle Wagyu Double Smash'), findsOneWidget);
      expect(find.text('₹16.50'), findsOneWidget);

      final heartBtn = find.byIcon(Icons.favorite_rounded).first;
      await tester.tap(heartBtn);
      await tester.pumpAndSettle();

      expect(WishlistService.items.isEmpty, isTrue);
      expect(find.text('Your wishlist is empty'), findsOneWidget);
    });

    testWidgets('shows back button when navigated from a parent screen and pops on tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const Wishlistscreen()),
                ),
                child: const Text('Open Wishlist'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open Wishlist
      await tester.tap(find.text('Open Wishlist'));
      await tester.pumpAndSettle();

      expect(find.text('Wishlist'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Open Wishlist'), findsOneWidget);
    });
  });

  group('FoodItemPage Wishlist Integration Tests', () {
    testWidgets('toggling favorite button in FoodItemPage updates WishlistService', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FoodItemPage(
            id: 'item_food_test',
            name: 'Crispy Paneer Burger',
            category: 'burgers',
            price: 9.99,
            description: 'Delicious crispy paneer patty with spicy mayo.',
            photos: [],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(WishlistService.isInWishlist('item_food_test'), isFalse);
      expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);

      // Tap favorite button
      await tester.tap(find.byIcon(Icons.favorite_border_rounded));
      await tester.pumpAndSettle();

      expect(WishlistService.isInWishlist('item_food_test'), isTrue);
      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);

      // Tap favorite button again to un-favorite
      await tester.tap(find.byIcon(Icons.favorite_rounded));
      await tester.pumpAndSettle();

      expect(WishlistService.isInWishlist('item_food_test'), isFalse);
      expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
    });
  });
}
