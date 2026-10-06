import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zteel_user/app_typography.dart';
import 'package:zteel_user/screens/FoodTypeShopScreen.dart';
import 'package:zteel_user/screens/dashboard.dart';
import 'package:zteel_user/screens/home_discovery_view.dart';
import 'package:zteel_user/services/cart_service.dart';
import 'package:zteel_user/services/food_tag_service.dart';
import 'package:zteel_user/widgets/bottom_nav_bar.dart';
import 'package:zteel_user/widgets/shimmer_loading.dart';

// Only images use this client; backend requests use MockClient below.
class _ImageOverrides extends HttpOverrides {
  final List<int> bytes;
  _ImageOverrides(this.bytes);
  @override
  HttpClient createHttpClient(SecurityContext? context) => _ImageClient(bytes);
}

class _ImageClient implements HttpClient {
  final List<int> bytes;
  _ImageClient(this.bytes);
  @override
  set autoUncompress(bool value) {}
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _ImageRequest(bytes);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ImageRequest implements HttpClientRequest {
  final List<int> bytes;
  _ImageRequest(this.bytes);
  @override
  Future<HttpClientResponse> close() async => _ImageResponse(bytes);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ImageResponse extends Stream<List<int>> implements HttpClientResponse {
  final List<int> bytes;
  _ImageResponse(this.bytes);
  @override
  int get statusCode => HttpStatus.ok;
  @override
  int get contentLength => bytes.length;
  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;
  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) => Stream.value(bytes).listen(
    onData,
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _vendor = {
  'id': 'live-vendor',
  'business_name': 'Live Kitchen',
  'cuisines': ['Indian'],
  'is_open_now': true,
  'rating': 4.5,
  'cover_image': '/media/live-kitchen.jpg',
};

http.Response _json(Object value) => http.Response(
  jsonEncode(value),
  200,
  headers: {'content-type': 'application/json'},
);

MockClient _backend(Future<http.Response> offers) => MockClient((
  request,
) async {
  if (request.url.path == '/api/v1/offers/feed/') return offers;
  if (request.url.path == '/api/v1/food-tags/') {
    return _json({
      'results': [
        {
          'id': 'pizza-tag',
          'name': 'Pizza',
          'slug': 'pizza',
          'image': '/media/food_tags/pizza.jpg',
          'matching_vendor_count': 2,
        },
        {
          'id': 'momos-tag',
          'name': 'Momos',
          'slug': 'momos',
          'image': null,
          'matching_vendor_count': 1,
        },
      ],
    });
  }
  if (request.url.path == '/api/v1/vendors/') {
    return _json({
      'results': [_vendor],
    });
  }
  if (request.url.path == '/api/v1/food-tags/pizza-tag/vendors/') {
    return _json({
      'count': 1,
      'results': [
        {
          'id': 'live-vendor',
          'business_name': 'Live Kitchen',
          'matching_item_count': 2,
          'lowest_matching_item_price': '199.00',
          'distance_km': '1.2',
          'best_offer': {'title': 'Pizza saving', 'discount_percentage': '20'},
        },
      ],
    });
  }
  if (request.url.path == '/api/v1/food-tags/pizza-tag/offers/') {
    return _json({
      'results': [
        {
          'vendor': {'id': 'live-vendor', 'business_name': 'Live Kitchen'},
          'item': {'id': 'pizza-1', 'name': 'Margherita Pizza'},
          'offer': {
            'id': 'pizza-offer',
            'title': 'Pizza saving',
            'discount_percentage': '20',
          },
        },
        {
          'vendor': {'id': 'live-vendor', 'business_name': 'Live Kitchen'},
          'item': {'id': 'pizza-2', 'name': 'Veggie Pizza'},
          'offer': {
            'id': 'pizza-offer',
            'title': 'Pizza saving',
            'discount_percentage': '20',
          },
        },
      ],
    });
  }
  if (request.url.path == '/api/v1/vendors/live-vendor/food-tags/pizza-tag/') {
    return _json({
      'results': [
        {
          'id': 'pizza-1',
          'name': 'Margherita Pizza',
          'description': 'Tomato and mozzarella',
          'price': '249.00',
        },
        {
          'id': 'pizza-2',
          'name': 'Veggie Pizza',
          'description': 'Loaded vegetables',
          'price': '279.00',
        },
      ],
    });
  }
  return _json({'results': []});
});

Widget _dashboard() => MaterialApp(
  theme: AppTypography.lightTheme(),
  home: const HomeDiscoveryScreen(),
);

CartData _basket(int quantity) => CartData(
  vendor: const CartVendor(id: 'live-vendor', businessName: 'Live Kitchen'),
  items: [
    CartItemModel(
      id: 'item',
      menuItemId: 'dish',
      name: 'Lunch',
      itemType: 'menu_item',
      quantity: quantity,
      unitPrice: 0,
      subtotal: 0,
      lineDiscount: 0,
      lineTotal: 0,
    ),
  ],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final font = FontLoader('Manrope')
      ..addFont(rootBundle.load('assets/fonts/Manrope-VariableFont_wght.ttf'));
    await font.load();
  });
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    CartService.basketsNotifier.value = {};
    CartService.cartNotifier.value = null;
    final bytes = (await rootBundle.load(
      'assets/images/home/home_food_banner.png',
    )).buffer.asUint8List();
    HttpOverrides.global = _ImageOverrides(bytes);
  });
  tearDown(() {
    HttpOverrides.global = null;
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    CartService.basketsNotifier.value = {};
    CartService.cartNotifier.value = null;
  });

  testWidgets(
    'Dashboard loads all live offers, reacts to baskets, and retains Home scrolling',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final response = Completer<http.Response>();
      await http.runWithClient(() async {
        await tester.pumpWidget(_dashboard());
        var home = tester.widget<HomeDiscoveryView>(
          find.byType(HomeDiscoveryView),
        );
        expect(home.isLoadingDeals, isTrue);
        expect(home.deals, isEmpty);
        response.complete(
          _json({
            'results': List.generate(
              5,
              (i) => {
                'id': '$i',
                'vendor': i.isEven ? 'live-vendor' : _vendor,
                'title': 'Live offer $i',
                'discount_percentage': 20,
              },
            ),
          }),
        );
        await tester.pumpAndSettle();
        home = tester.widget<HomeDiscoveryView>(find.byType(HomeDiscoveryView));
        expect(home.isLoadingDeals, isFalse);
        expect(home.isLoadingRestaurants, isFalse);
        expect(home.isLoadingFoodTags, isFalse);
        expect(home.foodTags.map((tag) => tag.name), ['Pizza', 'Momos']);
        expect(
          home.foodTags.first.imageUrl,
          'http://68.233.116.23:8000/media/food_tags/pizza.jpg',
        );
        expect(home.deals, hasLength(5));
        expect(
          home.deals.every((deal) => deal.vendorId == 'live-vendor'),
          isTrue,
        );
        expect(
          home.deals.every(
            (deal) => deal.restaurantImage!.endsWith('/media/live-kitchen.jpg'),
          ),
          isTrue,
        );
        expect(find.text('There are 5 food offers near you.'), findsOneWidget);

        CartService.basketsNotifier.value = {'live-vendor': _basket(3)};
        await tester.pump();
        expect(
          tester
              .widget<HomeDiscoveryView>(find.byType(HomeDiscoveryView))
              .cartItemCount,
          3,
        );
        await tester.tap(find.byKey(const ValueKey('home-cart')));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<AppBottomNavBar>(find.byType(AppBottomNavBar))
              .currentIndex,
          3,
        );
        await tester.tap(find.byKey(const ValueKey('bottom-nav-0')));
        await tester.pumpAndSettle();

        final feed = find.byKey(const PageStorageKey('home-discovery-feed'));
        await tester.drag(feed, const Offset(0, -240));
        await tester.pumpAndSettle();
        final scrollable = find
            .descendant(of: feed, matching: find.byType(Scrollable))
            .first;
        final before = tester
            .state<ScrollableState>(scrollable)
            .position
            .pixels;
        expect(before, greaterThan(0));
        await tester.tap(find.byKey(const ValueKey('bottom-nav-1')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('bottom-nav-0')));
        await tester.pumpAndSettle();
        expect(
          tester.state<ScrollableState>(scrollable).position.pixels,
          before,
        );
        CartService.basketsNotifier.value = {'live-vendor': _basket(4)};
        await tester.pump();
        expect(
          tester.state<ScrollableState>(scrollable).position.pixels,
          before,
        );
        expect(
          tester
              .widget<HomeDiscoveryView>(find.byType(HomeDiscoveryView))
              .cartItemCount,
          4,
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        await tester.pump();
      }, () => _backend(response.future));
    },
  );

  test('FoodTagService fetches only the selected tag vendors', () async {
    await http.runWithClient(() async {
      final vendors = await FoodTagService.fetchTagVendors('pizza-tag');
      expect(vendors, hasLength(1));
      expect(vendors.single['business_name'], 'Live Kitchen');
      expect(vendors.single['matching_item_count'], 2);
    }, () => _backend(Future.value(_json({'results': []}))));
  });

  test('FoodTagService fetches tag offers and vendor tag items', () async {
    await http.runWithClient(() async {
      final offers = await FoodTagService.fetchTagOffers('pizza-tag');
      final items = await FoodTagService.fetchVendorTagItems(
        'live-vendor',
        'pizza-tag',
      );
      expect(offers, hasLength(2));
      expect(offers.first['offer']['id'], 'pizza-offer');
      expect(items.map((item) => item['name']), [
        'Margherita Pizza',
        'Veggie Pizza',
      ]);
    }, () => _backend(Future.value(_json({'results': []}))));
  });

  testWidgets(
    'A food tag shows live offers, vendors, and matching vendor items',
    (tester) async {
      await http.runWithClient(() async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTypography.lightTheme(),
            home: const FoodTypeShopsScreen(
              foodType: 'Pizza',
              foodTagId: 'pizza-tag',
            ),
          ),
        );
        expect(find.byType(ShimmerLoading), findsWidgets);
        await tester.pumpAndSettle();
        expect(find.text('Pizza offers'), findsOneWidget);
        // Two backend item rows share one offer, so the offer rail has one card.
        expect(find.text('Live Kitchen'), findsNWidgets(2));
        expect(find.text('2 matching items'), findsOneWidget);
        expect(find.text('20% OFF'), findsNWidgets(2));
        expect(find.text('Napoli\'s Pizzeria'), findsNothing);
        await tester.tap(find.text('Live Kitchen').last);
        await tester.pumpAndSettle();
        expect(find.text('Pizza items'), findsOneWidget);
        expect(find.text('Margherita Pizza'), findsOneWidget);
        expect(find.text('Veggie Pizza'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }, () => _backend(Future.value(_json({'results': []}))));
    },
  );

  testWidgets(
    'An empty live feed finishes loading without inserting sample offers',
    (tester) async {
      await http.runWithClient(() async {
        await tester.pumpWidget(_dashboard());
        await tester.pumpAndSettle();
        final home = tester.widget<HomeDiscoveryView>(
          find.byType(HomeDiscoveryView),
        );
        expect(home.isLoadingDeals, isFalse);
        expect(home.deals, isEmpty);
        expect(find.text('Discover your next favorite meal.'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        await tester.pump();
      }, () => _backend(Future.value(_json({'results': []}))));
    },
  );
}
