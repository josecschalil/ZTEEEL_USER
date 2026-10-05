import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zteel_user/app_colors.dart';
import 'package:zteel_user/app_typography.dart';
import 'package:zteel_user/screens/FoodTypeShopScreen.dart';
import 'package:zteel_user/screens/home_discovery_view.dart';
import 'package:zteel_user/services/food_tag_service.dart';
import 'package:zteel_user/widgets/category_row.dart';

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _TestHttpClient();
}

class _TestHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _TestHttpRequest();
  @override
  dynamic noSuchMethod(Invocation invocation) {}
}

class _TestHttpRequest implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() async => _TestHttpResponse();
  @override
  dynamic noSuchMethod(Invocation invocation) {}
}

class _TestHttpResponse implements HttpClientResponse {
  static final _kTransparentImage = Uint8List.fromList([
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
    0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
    0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
    0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
    0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
    0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
  ]);

  @override
  int get statusCode => HttpStatus.ok;
  @override
  int get contentLength => _kTransparentImage.length;
  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;
  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) =>
      Stream.value(_kTransparentImage).listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );
  @override
  dynamic noSuchMethod(Invocation invocation) {}
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  const foodTags = [
    FoodTag(id: 'pizza-id', name: 'Pizza', slug: 'pizza'),
    FoodTag(id: 'burger-id', name: 'Burger', slug: 'burger'),
    FoodTag(id: 'biryani-id', name: 'Biryani', slug: 'biryani'),
  ];

  Widget buildApp() {
    return MaterialApp(
      theme: AppTypography.lightTheme(),
      home: Scaffold(
        body: HomeDiscoveryView(
          restaurants: const [],
          deals: const [],
          foodTags: foodTags,
          onSeeAllDeals: () {},
          onOpenCart: () {},
        ),
      ),
    );
  }

  testWidgets(
    'Search bar and food tags use Hero widgets on Home screen',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Verify Hero widgets exist on Home screen
      final searchHero = find.byWidgetPredicate(
        (w) => w is Hero && w.tag == 'discovery_search_bar_hero',
      );
      expect(searchHero, findsOneWidget);

      final tagsHero = find.byWidgetPredicate(
        (w) => w is Hero && w.tag == 'discovery_food_tags_hero',
      );
      expect(tagsHero, findsOneWidget);

      // Verify CategoryRow photo tiles are rendered on Home
      expect(find.byType(CategoryRow), findsOneWidget);
      expect(find.text('Pizza'), findsOneWidget);
      expect(find.text('Burger'), findsOneWidget);
      expect(find.text('Biryani'), findsOneWidget);
    },
  );

  testWidgets(
    'Tapping search bar smoothly moves search and tags to top, showing "Searching in" header',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Tap on the home search bar
      await tester.tap(find.byKey(const ValueKey('home-search')));
      await tester.pumpAndSettle();

      // Verify destination is FoodTypeShopsScreen
      expect(find.byType(FoodTypeShopsScreen), findsOneWidget);

      // Verify top header shows "Searching in"
      expect(find.text('Searching in'), findsOneWidget);

      // Verify search bar Hero tag is in FoodTypeShopsScreen
      final searchHero = find.byWidgetPredicate(
        (w) => w is Hero && w.tag == 'discovery_search_bar_hero',
      );
      expect(searchHero, findsOneWidget);

      // Verify food tags Hero tag is in FoodTypeShopsScreen
      final tagsHero = find.byWidgetPredicate(
        (w) => w is Hero && w.tag == 'discovery_food_tags_hero',
      );
      expect(tagsHero, findsOneWidget);

      // Verify category items match Home screen tiles
      expect(find.byType(CategoryRow), findsOneWidget);
      expect(find.text('Pizza'), findsOneWidget);
      expect(find.text('Burger'), findsOneWidget);
      expect(find.text('Biryani'), findsOneWidget);
    },
  );

  testWidgets(
    'Tapping a food tag on Home opens search with that tag highlighted in orange',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Tap 'Pizza' food tag
      await tester.tap(find.byKey(const ValueKey('home-food-tag-pizza-id')));
      await tester.pumpAndSettle();

      expect(find.byType(FoodTypeShopsScreen), findsOneWidget);
      expect(find.text('Searching in'), findsOneWidget);

      // Verify Pizza text is bold orange
      final pizzaText = tester.widget<Text>(find.descendant(
        of: find.byKey(const ValueKey('home-food-tag-pizza-id')),
        matching: find.text('Pizza'),
      ));
      expect(pizzaText.style?.color, AppColors.orange);
      expect(pizzaText.style?.fontWeight, FontWeight.w800);

      // Tap 'Burger' food tag on the search screen
      await tester.tap(find.byKey(const ValueKey('home-food-tag-burger-id')));
      await tester.pumpAndSettle();

      // Verify Burger text is bold orange and Pizza is unselected
      final burgerText = tester.widget<Text>(find.descendant(
        of: find.byKey(const ValueKey('home-food-tag-burger-id')),
        matching: find.text('Burger'),
      ));
      expect(burgerText.style?.color, AppColors.orange);
      expect(burgerText.style?.fontWeight, FontWeight.w800);

      final unselectedPizzaText = tester.widget<Text>(find.descendant(
        of: find.byKey(const ValueKey('home-food-tag-pizza-id')),
        matching: find.text('Pizza'),
      ));
      expect(unselectedPizzaText.style?.color, AppColors.toneFF2F2F2F);
    },
  );
}
