import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zteel_user/services/food_tag_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('FoodTag JSON serialization and deserialization roundtrip', () {
    const original = FoodTag(
      id: 'biryani-tag',
      name: 'Biryani',
      slug: 'biryani',
      imageUrl: 'http://127.0.0.1:8000/media/biryani.png',
      matchingVendorCount: 14,
    );

    final json = original.toJson();
    expect(json['id'], 'biryani-tag');
    expect(json['name'], 'Biryani');
    expect(json['slug'], 'biryani');
    expect(json['image'], 'http://127.0.0.1:8000/media/biryani.png');
    expect(json['matching_vendor_count'], 14);

    final restored = FoodTag.fromJson(json);
    expect(restored.id, original.id);
    expect(restored.name, original.name);
    expect(restored.slug, original.slug);
    expect(restored.imageUrl, original.imageUrl);
    expect(restored.matchingVendorCount, original.matchingVendorCount);
  });

  test('FoodTagService loads cached tags from SharedPreferences', () async {
    final cachedData = [
      {
        'id': 'dessert-tag',
        'name': 'Desserts',
        'slug': 'desserts',
        'image': 'http://127.0.0.1:8000/media/dessert.png',
        'matching_vendor_count': 5,
      },
      {
        'id': 'burger-tag',
        'name': 'Burgers',
        'slug': 'burgers',
        'image': 'http://127.0.0.1:8000/media/burger.png',
        'matching_vendor_count': 8,
      },
    ];

    SharedPreferences.setMockInitialValues({
      'cached_food_tags_v1': jsonEncode(cachedData),
    });

    final tags = await FoodTagService.loadCachedFoodTags();
    expect(tags.length, 2);
    expect(tags[0].name, 'Desserts');
    expect(tags[1].name, 'Burgers');
    expect(FoodTagService.cachedFoodTags.length, 2);
  });
}
