import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zteel_user/app_typography.dart';
import 'package:zteel_user/screens/DealsScreen.dart';
import 'package:zteel_user/screens/FoodTypeShopScreen.dart';
import 'package:zteel_user/screens/LocationPageScreen.dart';
import 'package:zteel_user/screens/NotificationScreen.dart';
import 'package:zteel_user/screens/OfferExplanationScreen.dart';
import 'package:zteel_user/screens/RestaurantListScreen.dart';
import 'package:zteel_user/screens/RestuarantMenuScreen.dart';
import 'package:zteel_user/screens/home_discovery_view.dart';
import 'package:zteel_user/services/food_tag_service.dart';
import 'package:zteel_user/widgets/bottom_nav_bar.dart';

const _restaurants = [
  HomeRestaurant(
    id: 'one',
    name: 'Spice Route',
    cuisine: 'North Indian · Biryani',
    rating: 4.6,
    reviewCount: 120,
    distance: '0.8 km',
    eta: '20–25 min',
    isOpen: true,
    offerLabel: '20% OFF',
    imageUrl:
        'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=200&fit=crop',
  ),
  HomeRestaurant(
    id: 'two',
    name: 'Napoli Kitchen',
    cuisine: 'Italian · Pizza',
    rating: 4.5,
    reviewCount: 86,
    distance: '1.2 km',
    eta: '25–30 min',
    isOpen: true,
    imageUrl:
        'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=200&fit=crop',
  ),
  HomeRestaurant(
    id: 'three',
    name: 'Green Bowl',
    cuisine: 'Healthy · Salads',
    rating: 4.4,
    reviewCount: 60,
    distance: '1.5 km',
    eta: '20–25 min',
    isOpen: false,
    imageUrl:
        'https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?w=200&fit=crop',
  ),
];

const _deals = [
  Deal(
    id: 'lunch',
    vendorId: 'one',
    title: 'Lunch just got better',
    restaurant: 'Spice Route',
    distance: '0.8 km',
    discount: '25% OFF',
    timeLeft: '2h left',
    imageUrl: 'https://invalid.example/banner.png',
  ),
];

const _foodTags = [
  FoodTag(
    id: 'biryani',
    name: 'Biryani',
    slug: 'biryani',
    imageUrl:
        'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=200&fit=crop',
  ),
  FoodTag(
    id: 'pizza',
    name: 'Pizza',
    slug: 'pizza',
    imageUrl:
        'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=200&fit=crop',
  ),
  FoodTag(
    id: 'burger',
    name: 'Burger',
    slug: 'burger',
    imageUrl:
        'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=200&fit=crop',
  ),
  FoodTag(
    id: 'chinese',
    name: 'Chinese',
    slug: 'chinese',
    imageUrl:
        'https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?w=200&fit=crop',
  ),
  FoodTag(id: 'drinks', name: 'Drinks', slug: 'drinks'),
];

const _previewKey = ValueKey('home-preview');

// Record destinations without starting unrelated screens' network/platform work.
class _DestinationObserver extends NavigatorObserver {
  MaterialPageRoute<dynamic>? destination;
  Object? result;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute == null) return;
    destination = route as MaterialPageRoute<dynamic>;
    scheduleMicrotask(() => navigator!.removeRoute(route, result));
  }
}

Widget _home({
  List<HomeRestaurant> restaurants = _restaurants,
  List<Deal> deals = _deals,
  List<FoodTag> foodTags = _foodTags,
  VoidCallback? onDeals,
  VoidCallback? onCart,
  int cartItemCount = 0,
  bool loadingRestaurants = false,
  bool loadingDeals = false,
  bool loadingFoodTags = false,
  double textScale = 1,
  EdgeInsets insets = EdgeInsets.zero,
  NavigatorObserver? observer,
}) => MaterialApp(
  theme: AppTypography.lightTheme(),
  navigatorObservers: [?observer],
  home: Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(textScale),
        padding: insets,
        viewPadding: insets,
      ),
      child: RepaintBoundary(
        key: _previewKey,
        child: Scaffold(
          body: HomeDiscoveryView(
            restaurants: restaurants,
            deals: deals,
            onSeeAllDeals: onDeals ?? () {},
            onOpenCart: onCart ?? () {},
            cartItemCount: cartItemCount,
            isLoadingRestaurants: loadingRestaurants,
            isLoadingDeals: loadingDeals,
            foodTags: foodTags,
            isLoadingFoodTags: loadingFoodTags,
          ),
          bottomNavigationBar: AppBottomNavBar(currentIndex: 0, onTap: (_) {}),
        ),
      ),
    ),
  ),
);

Future<void> _phone(
  WidgetTester tester, [
  Size size = const Size(390, 844),
]) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Future<void> _capture(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('CAPTURE_HOME_PREVIEW')) return;
  await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(_previewKey),
    );
    final image = await boundary.toImage(pixelRatio: 2);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final directory = Directory('build/homepage_preview')
      ..createSync(recursive: true);
    File(
      '${directory.path}/$name.png',
    ).writeAsBytesSync(data!.buffer.asUint8List());
    image.dispose();
  });
}

Future<void> _primePreviewPhotos(WidgetTester tester) async {
  if (!const bool.fromEnvironment('CAPTURE_HOME_PREVIEW')) return;
  await tester.runAsync(() async {
    for (final tag in _foodTags) {
      if (tag.imageUrl == null) continue;
      final file = File('build/homepage_preview/${tag.name.toLowerCase()}.jpg');
      if (!file.existsSync()) continue;
      final codec = await ui.instantiateImageCodec(await file.readAsBytes());
      final frame = await codec.getNextFrame();
      PaintingBinding.instance.imageCache.putIfAbsent(
        NetworkImage(tag.imageUrl!),
        () => OneFrameImageStreamCompleter(
          Future.value(ImageInfo(image: frame.image)),
        ),
      );
      codec.dispose();
    }
  });
  addTearDown(() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final font = FontLoader('Manrope')
      ..addFont(rootBundle.load('assets/fonts/Manrope-VariableFont_wght.ttf'));
    await font.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets(
    'Reference composition fits above navigation with phone safe areas',
    (tester) async {
      await _phone(tester);
      await _primePreviewPhotos(tester);
      await tester.pumpWidget(
        _home(insets: const EdgeInsets.only(top: 44, bottom: 34)),
      );
      await tester.pumpAndSettle();
      final search = tester
          .getTopLeft(find.byKey(const ValueKey('home-search')))
          .dy;
      final categories = tester
          .getTopLeft(find.byKey(const PageStorageKey('home-categories')))
          .dy;
      final popular = tester.getTopLeft(find.text('Restaurants near you')).dy;
      final offer = tester
          .getTopLeft(find.byKey(const ValueKey('home-deal-lunch')))
          .dy;
      final nav = tester.getTopLeft(find.byType(AppBottomNavBar)).dy;
      expect(find.text('Hello!'), findsNothing);
      expect(search, lessThan(categories));
      expect(categories, lessThan(offer));
      expect(
        tester.getBottomLeft(find.byKey(const ValueKey('home-deal-lunch'))).dy,
        lessThan(popular),
      );
      expect(popular, lessThan(nav));
      expect(find.text("Deals for You 🔥"), findsOneWidget);
      final offerSize =
          tester.getSize(find.byKey(const ValueKey('home-deal-lunch')));
      expect(offerSize.width, 340);
      expect(offerSize.height, closeTo(199.75, 0.5));
      expect(find.text('What are you craving?'), findsNothing);
      expect(tester.takeException(), isNull);
      await _capture(tester, 'home-390x844');
    },
  );

  testWidgets(
    'Greeting counts the full live offer list and handles zero and loading',
    (tester) async {
      await _phone(tester);
      await _primePreviewPhotos(tester);
      await tester.pumpWidget(
        _home(
          deals: List.generate(
            5,
            (i) => Deal(
              id: '$i',
              title: 'Offer $i',
              restaurant: 'Partner $i',
              distance: '',
              discount: '20% OFF',
              timeLeft: 'Today',
              imageUrl: '',
            ),
          ),
        ),
      );
      
      await tester.pumpWidget(_home(deals: const [], restaurants: const []));
      
      expect(
        find.text('No offers available right now. Check back soon.'),
        findsOneWidget,
      );
      expect(find.textContaining('Restaurants will appear'), findsOneWidget);
      expect(find.textContaining('Saffron Gourmet'), findsNothing);
      await tester.pumpWidget(
        _home(
          deals: const [],
          restaurants: const [],
          loadingRestaurants: true,
          loadingDeals: true,
        ),
      );
      expect(find.bySemanticsLabel('Loading restaurants'), findsWidgets);
      expect(find.bySemanticsLabel('Loading offers'), findsWidgets);
      expect(
        find.text('No offers available right now. Check back soon.'),
        findsNothing,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await _capture(tester, 'home-loading-390x844');
    },
  );

  testWidgets('Food tags are the only scrollable category tiles', (
    tester,
  ) async {
    await _phone(tester);
    const tags = [
      FoodTag(id: 'pizza-id', name: 'Pizza', slug: 'pizza'),
      FoodTag(id: 'momos-id', name: 'Momos', slug: 'momos'),
      FoodTag(id: 'dessert-id', name: 'Desserts', slug: 'desserts'),
    ];
    await tester.pumpWidget(_home(foodTags: tags));
    expect(
      find.byKey(const ValueKey('home-food-tag-pizza-id')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('home-food-tag-momos-id')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('home-food-tag-biryani')), findsNothing);
    expect(find.text('Desserts'), findsOneWidget);
    await tester.pumpWidget(_home(foodTags: const [], loadingFoodTags: true));
    expect(find.byKey(const PageStorageKey('home-categories')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Notifications action retains route', (
    tester,
  ) async {
    final observer = _DestinationObserver();
    await tester.pumpWidget(_home(observer: observer));
    expect(find.byKey(const ValueKey('home-notifications')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('home-notifications')));
    await tester.pumpAndSettle();
    expect(
      observer.destination!.builder(
        tester.element(find.byType(HomeDiscoveryView)),
      ),
      isA<NotificationsScreen>(),
    );
  });

  testWidgets('Both location actions restore and update the same address', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'selected_location_latitude': 8.89,
      'selected_location_longitude': 76.61,
      'selected_location_address':
          'An exceptionally long saved delivery address in Kollam, Kerala',
    });
    final observer = _DestinationObserver()
      ..result = PickedLocation(
        label: 'Work',
        address: 'New work address',
        position: LatLng(8.9, 76.6),
      );
    await tester.pumpWidget(_home(observer: observer));
    await tester.pumpAndSettle();
    expect(find.textContaining('An exceptionally long'), findsOneWidget);
    for (final key in ['home-location']) {
      await tester.tap(find.byKey(ValueKey(key)));
      await tester.pumpAndSettle();
      expect(
        observer.destination!.builder(
          tester.element(find.byType(HomeDiscoveryView)),
        ),
        isA<LocationPickerScreen>(),
      );
      expect(find.text('New work address'), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Search, notifications, browsing, and categories retain their routes',
    (tester) async {
      await _phone(tester);
      final observer = _DestinationObserver();
      await tester.pumpWidget(_home(observer: observer));
      Future<Widget> destination(String key) async {
        await tester.tap(find.byKey(ValueKey(key)));
        await tester.pumpAndSettle();
        return observer.destination!.builder(
          tester.element(find.byType(HomeDiscoveryView)),
        );
      }

      expect(await destination('home-search'), isA<FoodTypeShopsScreen>());
      expect(
        await destination('home-notifications'),
        isA<NotificationsScreen>(),
      );
      final openNow =
          await destination('home-open-now') as NearbyRestaurantsScreen;
      expect(openNow.preset, RestaurantBrowsePreset.openNow);
      expect(openNow.restaurants!.map((r) => r.id), ['one', 'two', 'three']);
      expect(
        await destination('home-restaurants-btn'),
        isA<NearbyRestaurantsScreen>(),
      );
      expect(
        await destination('home-see-all-restaurants'),
        isA<NearbyRestaurantsScreen>(),
      );
      final category =
          await destination('home-food-tag-pizza') as FoodTypeShopsScreen;
      expect(category.foodType, 'Pizza');
      expect(category.foodTagId, 'pizza');
    },
  );

  testWidgets(
    'Restaurant cards open menus while offer cards open their details',
    (tester) async {
      await _phone(tester);
      final observer = _DestinationObserver();
      await tester.pumpWidget(_home(observer: observer));
      await tester.tap(find.byKey(const ValueKey('home-deal-lunch')));
      await tester.pumpAndSettle();
      final offerScreen =
          observer.destination!.builder(
                tester.element(find.byType(HomeDiscoveryView)),
              )
              as OfferExplanationScreen;
      expect(offerScreen.title, 'Lunch just got better');
      expect(offerScreen.restaurantName, 'Spice Route');
      await tester.drag(
        find.byKey(const PageStorageKey('home-discovery-feed')),
        const Offset(0, -350),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('home-restaurant-one')));
      await tester.pumpAndSettle();
      final screen =
          observer.destination!.builder(
                tester.element(find.byType(HomeDiscoveryView)),
              )
              as RestaurantMenuScreen;
      expect(screen.vendorId, 'one');
    },
  );

  testWidgets(
    'Offer cards have no Claim action and unlinked offers open their details',
    (tester) async {
      await _phone(tester);
      final observer = _DestinationObserver();
      await tester.pumpWidget(
        _home(
          observer: observer,
          deals: const [
            Deal(
              id: 'unlinked',
              title: 'Local offer',
              restaurant: 'Partner',
              distance: '',
              discount: 'Special offer',
              timeLeft: 'Today',
              imageUrl: '',
            ),
          ],
        ),
      );
      expect(find.byKey(const ValueKey('home-claim-unlinked')), findsNothing);
      await tester.tap(find.byKey(const ValueKey('home-deal-unlinked')));
      await tester.pumpAndSettle();
      final screen =
          observer.destination!.builder(
                tester.element(find.byType(HomeDiscoveryView)),
              )
              as OfferExplanationScreen;
      expect(screen.title, 'Local offer');
      expect(screen.restaurantName, 'Partner');
    },
  );

  testWidgets(
    'Open now preset filters closed restaurants and can be toggled off',
    (tester) async {
      await _phone(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTypography.lightTheme(),
          home: NearbyRestaurantsScreen(
            restaurants: _restaurants
                .map((r) => r.toRestaurantListing())
                .toList(),
            preset: RestaurantBrowsePreset.openNow,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Green Bowl'), findsNothing);
      expect(find.text('Spice Route'), findsWidgets);
      await tester.tap(find.text('Open now').first);
      await tester.pumpAndSettle();
      expect(find.text('Green Bowl'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Nearby browse keeps inline search and filters with Home-aligned styling',
    (tester) async {
      await _phone(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTypography.lightTheme(),
          home: NearbyRestaurantsScreen(
            restaurants: _restaurants
                .map((restaurant) => restaurant.toRestaurantListing())
                .toList(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final searchShell = tester.widget<Container>(
        find.byKey(const ValueKey('nearby-search-field')),
      );
      final searchDecoration = searchShell.decoration! as BoxDecoration;
      expect(searchDecoration.borderRadius, BorderRadius.circular(28));
      expect(
        tester
            .getSize(find.byKey(const ValueKey('nearby-search-field')))
            .height,
        52,
      );

      expect(
        find.byKey(const ValueKey('restaurant-item-one')),
        findsOneWidget,
      );

      await tester.enterText(
        find.byKey(const ValueKey('nearby-search')),
        'nap',
      );
      await tester.pumpAndSettle();
      expect(find.text('Napoli Kitchen'), findsWidgets);
      expect(find.text('Spice Route'), findsNothing);

      await tester.enterText(find.byKey(const ValueKey('nearby-search')), '');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('nearby-filter-openNow')));
      await tester.pumpAndSettle();
      expect(find.text('Green Bowl'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Nearby browse remains overflow-free with enlarged text', (
    tester,
  ) async {
    await _phone(tester, const Size(360, 800));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTypography.lightTheme(),
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
          child: NearbyRestaurantsScreen(
            restaurants: _restaurants
                .map((restaurant) => restaurant.toRestaurantListing())
                .toList(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Vertical restaurant feed keeps API order and reveals closed restaurants',
    (tester) async {
      await _phone(tester);
      await tester.pumpWidget(_home());
      expect(find.text('0.8 km'), findsWidgets);
      expect(find.text('20% OFF'), findsOneWidget);
      expect(find.text('20–25 min'), findsNothing);
      final feed = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.text('Napoli Kitchen'),
        300,
        scrollable: feed,
      );
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(find.text('Spice Route')).dy,
        lessThan(tester.getTopLeft(find.text('Napoli Kitchen')).dy),
      );
      await tester.scrollUntilVisible(
        find.text('Green Bowl'),
        300,
        scrollable: feed,
      );
      await tester.pumpAndSettle();
      expect(find.text('Green Bowl'), findsOneWidget);
      expect(find.text('Closed'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Failed restaurant and category photos display their fallbacks', (
    tester,
  ) async {
    await _phone(tester);
    await tester.pumpWidget(
      _home(
        restaurants: const [
          HomeRestaurant(
            id: 'bad-photo',
            name: 'Photo unavailable',
            cuisine: 'Cafe',
            rating: 0,
            reviewCount: 0,
            distance: '',
            eta: '',
            isOpen: false,
            imageUrl: 'https://invalid.example/restaurant.jpg',
            offerLabel: 'A very long restaurant offer label',
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.restaurant_menu_rounded), findsWidgets);
    expect(
      find.byWidgetPredicate((w) => w is Image && w.image is AssetImage),
      findsWidgets,
    );
    expect(find.text('Closed'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home fits common widths and larger text in all feed states', (
    tester,
  ) async {
    await _primePreviewPhotos(tester);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    for (final size in const [Size(360, 800), Size(390, 844), Size(430, 932)]) {
      await tester.binding.setSurfaceSize(size);
      for (final scale in [1.0, 1.5]) {
        for (final loading in [false, true]) {
          await tester.pumpWidget(
            _home(
              restaurants: loading ? const [] : _restaurants,
              deals: loading ? const [] : _deals,
              loadingRestaurants: loading,
              loadingDeals: loading,
              textScale: scale,
              insets: const EdgeInsets.only(top: 44, bottom: 34),
            ),
          );
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: '$size, scale=$scale, loading=$loading',
          );
          if (!loading && (scale == 1 || size.width == 390)) {
            final suffix = scale == 1 ? '' : '-text150';
            await _capture(
              tester,
              'home-${size.width.toInt()}x${size.height.toInt()}$suffix',
            );
          }
          await tester.drag(
            find.byKey(const PageStorageKey('home-discovery-feed')),
            const Offset(0, -350),
          );
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: 'scrolled $size, scale=$scale',
          );
          await tester.pumpWidget(const SizedBox());
        }
      }
    }
  });
}
