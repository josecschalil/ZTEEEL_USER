import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class CartVendor {
  final String id;
  final String businessName;
  final String? coverImage;
  final String? cuisine;

  const CartVendor({
    required this.id,
    required this.businessName,
    this.coverImage,
    this.cuisine,
  });

  factory CartVendor.fromJson(Map<String, dynamic> json) {
    final rawImage = json['cover_image']?.toString() ?? json['image']?.toString() ?? json['icon_image']?.toString() ?? '';
    String? resolvedImage;
    if (rawImage.isNotEmpty) {
      resolvedImage = rawImage.startsWith('http://') || rawImage.startsWith('https://')
          ? rawImage
          : '${ApiConfig.baseUrl}${rawImage.startsWith('/') ? '' : '/'}$rawImage';
    }

    return CartVendor(
      id: json['id']?.toString() ?? '',
      businessName: json['business_name']?.toString() ?? 'Restaurant',
      coverImage: resolvedImage,
      cuisine: json['cuisine']?.toString() ?? json['category']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'business_name': businessName,
    'cover_image': coverImage,
    'cuisine': cuisine,
  };
}

class CartItemModel {
  final String id;
  final String menuItemId;
  final String name;
  final String itemType;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final double lineDiscount;
  final double lineTotal;
  final String? imageUrl;
  final String? description;

  const CartItemModel({
    required this.id,
    required this.menuItemId,
    required this.name,
    required this.itemType,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    required this.lineDiscount,
    required this.lineTotal,
    this.imageUrl,
    this.description,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final rawImage = json['image']?.toString() ?? json['image_url']?.toString() ?? '';
    String? resolvedImage;
    if (rawImage.isNotEmpty) {
      resolvedImage = rawImage.startsWith('http://') || rawImage.startsWith('https://')
          ? rawImage
          : '${ApiConfig.baseUrl}${rawImage.startsWith('/') ? '' : '/'}$rawImage';
    }

    final q = int.tryParse(json['quantity']?.toString() ?? '1') ?? 1;
    final uPrice = double.tryParse(json['unit_price']?.toString() ?? '0.0') ?? 0.0;
    final sub = double.tryParse(json['subtotal']?.toString() ?? '${uPrice * q}') ?? (uPrice * q);
    final disc = double.tryParse(json['line_discount']?.toString() ?? '0.0') ?? 0.0;
    final tot = double.tryParse(json['line_total']?.toString() ?? '${sub - disc}') ?? (sub - disc);

    return CartItemModel(
      id: json['id']?.toString() ?? json['menu_item_id']?.toString() ?? '',
      menuItemId: json['menu_item_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Dish',
      itemType: json['item_type']?.toString() ?? 'dish',
      quantity: q,
      unitPrice: uPrice,
      subtotal: sub,
      lineDiscount: disc,
      lineTotal: tot,
      imageUrl: resolvedImage,
      description: json['description']?.toString(),
    );
  }

  CartItemModel copyWith({
    String? id,
    String? menuItemId,
    String? name,
    String? itemType,
    int? quantity,
    double? unitPrice,
    double? subtotal,
    double? lineDiscount,
    double? lineTotal,
    String? imageUrl,
    String? description,
  }) {
    final newQty = quantity ?? this.quantity;
    final newUnitPrice = unitPrice ?? this.unitPrice;
    final newSubtotal = subtotal ?? (newUnitPrice * newQty);
    final newDisc = lineDiscount ?? this.lineDiscount;
    final newTotal = lineTotal ?? (newSubtotal - newDisc);

    return CartItemModel(
      id: id ?? this.id,
      menuItemId: menuItemId ?? this.menuItemId,
      name: name ?? this.name,
      itemType: itemType ?? this.itemType,
      quantity: newQty,
      unitPrice: newUnitPrice,
      subtotal: newSubtotal,
      lineDiscount: newDisc,
      lineTotal: newTotal,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
    );
  }
}

class RewardOption {
  final String id;
  final String menuItemId;
  final String name;
  final double price;
  final String? imageUrl;

  const RewardOption({
    required this.id,
    required this.menuItemId,
    required this.name,
    required this.price,
    this.imageUrl,
  });

  factory RewardOption.fromJson(Map<String, dynamic> json) {
    final rawImage = json['image']?.toString() ?? json['image_url']?.toString() ?? '';
    String? resolvedImage;
    if (rawImage.isNotEmpty) {
      resolvedImage = rawImage.startsWith('http://') || rawImage.startsWith('https://')
          ? rawImage
          : '${ApiConfig.baseUrl}${rawImage.startsWith('/') ? '' : '/'}$rawImage';
    }

    return RewardOption(
      id: json['id']?.toString() ?? '',
      menuItemId: json['menu_item_id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['item_name']?.toString() ?? 'Reward Item',
      price: double.tryParse(json['price']?.toString() ?? '0.0') ?? 0.0,
      imageUrl: resolvedImage,
    );
  }
}

class CartMilestone {
  final String id;
  final String name;
  final double thresholdAmount;
  final String discountType;
  final double discountValue;
  final double? maxDiscount;
  final bool hasFreeItem;
  final List<RewardOption> rewardOptions;

  const CartMilestone({
    required this.id,
    required this.name,
    required this.thresholdAmount,
    required this.discountType,
    required this.discountValue,
    this.maxDiscount,
    this.hasFreeItem = false,
    this.rewardOptions = const [],
  });

  factory CartMilestone.fromJson(Map<String, dynamic> json) {
    final options = <RewardOption>[];
    if (json['options'] is List) {
      for (final opt in (json['options'] as List).whereType<Map<String, dynamic>>()) {
        options.add(RewardOption.fromJson(opt));
      }
    } else if (json['reward_options'] is List) {
      for (final opt in (json['reward_options'] as List).whereType<Map<String, dynamic>>()) {
        options.add(RewardOption.fromJson(opt));
      }
    }

    return CartMilestone(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['title']?.toString() ?? 'Milestone Reward',
      thresholdAmount: double.tryParse(json['threshold_amount']?.toString() ?? json['spend_amount']?.toString() ?? '0.0') ?? 0.0,
      discountType: json['discount_type']?.toString() ?? 'percentage',
      discountValue: double.tryParse(json['discount_value']?.toString() ?? '0.0') ?? 0.0,
      maxDiscount: double.tryParse(json['max_discount']?.toString() ?? ''),
      hasFreeItem: json['has_free_item'] == true || json['discount_type'] == 'free_item',
      rewardOptions: options,
    );
  }
}

class CartReward {
  final CartMilestone? milestone;
  final CartMilestone? nextMilestone;
  final RewardOption? selectedOption;
  final List<RewardOption> availableOptions;
  final double amountToNext;

  const CartReward({
    this.milestone,
    this.nextMilestone,
    this.selectedOption,
    this.availableOptions = const [],
    this.amountToNext = 0.0,
  });

  factory CartReward.fromJson(Map<String, dynamic> json) {
    CartMilestone? milestone;
    if (json['milestone'] is Map<String, dynamic>) {
      milestone = CartMilestone.fromJson(json['milestone']);
    } else if (json['applied_milestone'] is Map<String, dynamic>) {
      milestone = CartMilestone.fromJson(json['applied_milestone']);
    }

    CartMilestone? nextMilestone;
    if (json['next_milestone'] is Map<String, dynamic>) {
      nextMilestone = CartMilestone.fromJson(json['next_milestone']);
    }

    RewardOption? selectedOption;
    if (json['selected_option'] is Map<String, dynamic>) {
      selectedOption = RewardOption.fromJson(json['selected_option']);
    } else if (json['selected_reward_option'] is Map<String, dynamic>) {
      selectedOption = RewardOption.fromJson(json['selected_reward_option']);
    }

    final available = <RewardOption>[];
    if (json['available_options'] is List) {
      for (final opt in (json['available_options'] as List).whereType<Map<String, dynamic>>()) {
        available.add(RewardOption.fromJson(opt));
      }
    }

    final amountToNext = double.tryParse(json['amount_to_next']?.toString() ?? json['spend_more_amount']?.toString() ?? '0.0') ?? 0.0;

    return CartReward(
      milestone: milestone,
      nextMilestone: nextMilestone,
      selectedOption: selectedOption,
      availableOptions: available,
      amountToNext: amountToNext,
    );
  }
}

class CartData {
  final CartVendor? vendor;
  final List<CartItemModel> items;
  final double subtotal;
  final double itemDiscount;
  final double eligibleSubtotal;
  final double milestoneDiscount;
  final double totalDiscount;
  final double finalTotal;
  final CartReward? reward;
  final List<CartMilestone> milestones;
  final CartMilestone? appliedMilestone;
  final CartMilestone? nextMilestone;

  const CartData({
    this.vendor,
    this.items = const [],
    this.subtotal = 0.0,
    this.itemDiscount = 0.0,
    this.eligibleSubtotal = 0.0,
    this.milestoneDiscount = 0.0,
    this.totalDiscount = 0.0,
    this.finalTotal = 0.0,
    this.reward,
    this.milestones = const [],
    this.appliedMilestone,
    this.nextMilestone,
  });

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
  int get totalItemCount => items.fold(0, (sum, i) => sum + i.quantity);

  factory CartData.fromJson(Map<String, dynamic> json) {
    CartVendor? vendor;
    if (json['vendor'] is Map<String, dynamic>) {
      vendor = CartVendor.fromJson(json['vendor']);
    }

    final items = <CartItemModel>[];
    if (json['items'] is List) {
      for (final itm in (json['items'] as List).whereType<Map<String, dynamic>>()) {
        items.add(CartItemModel.fromJson(itm));
      }
    }

    CartReward? reward;
    if (json['reward'] is Map<String, dynamic>) {
      reward = CartReward.fromJson(json['reward']);
    } else {
      reward = CartReward.fromJson(json);
    }

    final milestones = <CartMilestone>[];
    if (json['milestones'] is List) {
      for (final m in (json['milestones'] as List).whereType<Map<String, dynamic>>()) {
        milestones.add(CartMilestone.fromJson(m));
      }
    }

    CartMilestone? appliedMilestone;
    if (json['applied_milestone'] is Map<String, dynamic>) {
      appliedMilestone = CartMilestone.fromJson(json['applied_milestone']);
    } else if (reward.milestone != null) {
      appliedMilestone = reward.milestone;
    }

    CartMilestone? nextMilestone;
    if (json['next_milestone'] is Map<String, dynamic>) {
      nextMilestone = CartMilestone.fromJson(json['next_milestone']);
    } else if (reward.nextMilestone != null) {
      nextMilestone = reward.nextMilestone;
    }

    return CartData(
      vendor: vendor,
      items: items,
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0.0') ?? 0.0,
      itemDiscount: double.tryParse(json['item_discount']?.toString() ?? '0.0') ?? 0.0,
      eligibleSubtotal: double.tryParse(json['eligible_subtotal']?.toString() ?? '0.0') ?? 0.0,
      milestoneDiscount: double.tryParse(json['milestone_discount']?.toString() ?? '0.0') ?? 0.0,
      totalDiscount: double.tryParse(json['total_discount']?.toString() ?? '0.0') ?? 0.0,
      finalTotal: double.tryParse(json['final_total']?.toString() ?? '0.0') ?? 0.0,
      reward: reward,
      milestones: milestones,
      appliedMilestone: appliedMilestone,
      nextMilestone: nextMilestone,
    );
  }

  CartData copyWith({
    CartVendor? vendor,
    List<CartItemModel>? items,
    double? subtotal,
    double? itemDiscount,
    double? eligibleSubtotal,
    double? milestoneDiscount,
    double? totalDiscount,
    double? finalTotal,
    CartReward? reward,
    List<CartMilestone>? milestones,
    CartMilestone? appliedMilestone,
    CartMilestone? nextMilestone,
  }) {
    return CartData(
      vendor: vendor ?? this.vendor,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      itemDiscount: itemDiscount ?? this.itemDiscount,
      eligibleSubtotal: eligibleSubtotal ?? this.eligibleSubtotal,
      milestoneDiscount: milestoneDiscount ?? this.milestoneDiscount,
      totalDiscount: totalDiscount ?? this.totalDiscount,
      finalTotal: finalTotal ?? this.finalTotal,
      reward: reward ?? this.reward,
      milestones: milestones ?? this.milestones,
      appliedMilestone: appliedMilestone ?? this.appliedMilestone,
      nextMilestone: nextMilestone ?? this.nextMilestone,
    );
  }

  /// Recalculates line totals and summary for local items
  CartData recalculated() {
    double sub = 0;
    double disc = 0;
    for (final itm in items) {
      sub += itm.unitPrice * itm.quantity;
      disc += itm.lineDiscount;
    }
    final tot = (sub - disc - milestoneDiscount).clamp(0.0, double.infinity);
    return copyWith(
      subtotal: sub,
      itemDiscount: disc,
      totalDiscount: disc + milestoneDiscount,
      finalTotal: tot,
    );
  }
}

class CartService {
  CartService._();

  // Every account transition advances this value.  Responses from requests
  // started for an earlier account must never repopulate the new account's
  // in-memory cart.
  static int _stateGeneration = 0;

  /// Map of vendorId -> CartData representing individual shop baskets
  static final ValueNotifier<Map<String, CartData>> basketsNotifier =
      ValueNotifier<Map<String, CartData>>({});

  /// Primary / active cart notifier for single-cart access
  static final ValueNotifier<CartData?> cartNotifier = ValueNotifier<CartData?>(null);

  /// All active baskets
  static List<CartData> get allBaskets =>
      basketsNotifier.value.values.where((b) => b.isNotEmpty).toList();

  /// Gets a specific vendor's basket
  static CartData? getBasket(String? vendorId) {
    if (vendorId == null || vendorId.isEmpty) return currentCart;
    return basketsNotifier.value[vendorId];
  }

  static CartData? get currentCart =>
      cartNotifier.value ?? (allBaskets.isNotEmpty ? allBaskets.first : null);

  static int get totalBasketsCount => allBaskets.length;
  static int get grandTotalItemCount => allBaskets.fold(0, (sum, b) => sum + b.totalItemCount);
  static double get grandSubtotal => allBaskets.fold(0.0, (sum, b) => sum + b.subtotal);
  static double get grandSavings => allBaskets.fold(0.0, (sum, b) => sum + b.totalDiscount);
  static double get grandTotal => allBaskets.fold(0.0, (sum, b) => sum + b.finalTotal);

  static Future<Map<String, String>> _headers() async {
    final auth = await AuthService.getAuthHeaders();
    return {
      'Content-Type': 'application/json',
      ...auth,
    };
  }

  /// Internal helper to update a basket and broadcast
  static void _updateBasket(String vendorId, CartData data) {
    final map = Map<String, CartData>.from(basketsNotifier.value);
    if (data.isEmpty) {
      map.remove(vendorId);
    } else {
      map[vendorId] = data;
    }
    basketsNotifier.value = map;
    cartNotifier.value = map[vendorId] ?? (map.isNotEmpty ? map.values.first : null);
  }

  /// Discards only process-local cart state.
  ///
  /// Call this whenever authentication changes. It deliberately does not make
  /// a DELETE request, because the cart belongs to the account currently held
  /// by the backend, not to the device session being closed.
  static void resetLocalState() {
    _stateGeneration++;
    basketsNotifier.value = {};
    cartNotifier.value = null;
  }

  static void _replaceFromServer(CartData data) {
    final vendorId = data.vendor?.id ?? '';
    if (vendorId.isEmpty || data.isEmpty) {
      basketsNotifier.value = {};
      cartNotifier.value = null;
      return;
    }
    basketsNotifier.value = {vendorId: data};
    cartNotifier.value = data;
  }

  /// Fetches the user's active cart from backend and replaces local state.
  static Future<CartData?> fetchCart() async {
    final requestGeneration = _stateGeneration;
    try {
      final headers = await _headers();
      if (requestGeneration != _stateGeneration) return null;
      if (!headers.containsKey('Authorization')) {
        if (requestGeneration == _stateGeneration) resetLocalState();
        return const CartData();
      }

      final response = await http.get(
        Uri.parse(ApiConfig.cartUrl),
        headers: headers,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final data = CartData.fromJson(decoded);
          if (requestGeneration != _stateGeneration) return null;
          _replaceFromServer(data);
          return data;
        }
      }
    } catch (e) {
      debugPrint('CartService fetchCart error: $e');
    }
    return currentCart;
  }

  /// Adds a menu item to a vendor's basket. Supports multi-vendor baskets simultaneously.
  static Future<Map<String, dynamic>> addItem({
    required String menuItemId,
    int quantity = 1,
    String? vendorId,
    String? vendorName,
    String? vendorCoverImage,
    String? itemName,
    double? unitPrice,
    double? discountedPrice,
    String? itemImage,
    String? itemDescription,
  }) async {
    final vId = vendorId ?? currentCart?.vendor?.id ?? '';
    final vName = vendorName ?? currentCart?.vendor?.businessName ?? 'Restaurant';

    // 1. Instantly update or create local basket for this vendor
    if (vId.isNotEmpty) {
      final existingBasket = basketsNotifier.value[vId] ?? CartData(
        vendor: CartVendor(
          id: vId,
          businessName: vName,
          coverImage: vendorCoverImage,
        ),
        items: const [],
      );

      final existingIndex = existingBasket.items.indexWhere((i) => i.menuItemId == menuItemId);
      final updatedItems = List<CartItemModel>.from(existingBasket.items);

      final price = unitPrice ?? (discountedPrice ?? 0.0);
      final disc = (discountedPrice != null && unitPrice != null && unitPrice > discountedPrice)
          ? (unitPrice - discountedPrice)
          : 0.0;

      if (existingIndex >= 0) {
        final existingItem = updatedItems[existingIndex];
        final newQty = existingItem.quantity + quantity;
        updatedItems[existingIndex] = existingItem.copyWith(
          quantity: newQty,
          subtotal: price * newQty,
          lineDiscount: disc * newQty,
          lineTotal: (price - disc) * newQty,
        );
      } else {
        updatedItems.add(
          CartItemModel(
            id: menuItemId,
            menuItemId: menuItemId,
            name: itemName ?? 'Dish',
            itemType: 'dish',
            quantity: quantity,
            unitPrice: price,
            subtotal: price * quantity,
            lineDiscount: disc * quantity,
            lineTotal: (price - disc) * quantity,
            imageUrl: itemImage,
            description: itemDescription,
          ),
        );
      }

      final newBasket = existingBasket.copyWith(items: updatedItems).recalculated();
      _updateBasket(vId, newBasket);
    }

    // 2. Synchronize with backend
    try {
      final headers = await _headers();
      final response = await http.post(
        Uri.parse(ApiConfig.cartItemsUrl),
        headers: headers,
        body: jsonEncode({
          'menu_item_id': menuItemId,
          'quantity': quantity,
        }),
      );

      if (response.statusCode == 409) {
        return {'success': false, 'conflict': true};
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final data = CartData.fromJson(decoded);
          if (data.vendor?.id.isNotEmpty == true) {
            _updateBasket(data.vendor!.id, data);
          } else if (vId.isNotEmpty) {
            _updateBasket(vId, data);
          } else {
            cartNotifier.value = data;
          }
          return {'success': true, 'data': data};
        }
      }
    } catch (e) {
      debugPrint('CartService addItem network sync: $e');
    }

    final basket = getBasket(vId);
    return {'success': true, 'data': basket};
  }

  /// Sets exact quantity of an item in a specific vendor basket
  static Future<CartData?> setItemQuantity({
    required String vendorId,
    required String menuItemId,
    required int targetQuantity,
    String? itemName,
    double? unitPrice,
    double? discountedPrice,
    String? itemImage,
  }) async {
    if (targetQuantity <= 0) {
      return removeItem(menuItemId, vendorId: vendorId);
    }

    final existingBasket = basketsNotifier.value[vendorId] ?? CartData(
      vendor: CartVendor(id: vendorId, businessName: 'Restaurant'),
      items: const [],
    );

    final existingIndex = existingBasket.items.indexWhere((i) => i.menuItemId == menuItemId || i.id == menuItemId);
    final updatedItems = List<CartItemModel>.from(existingBasket.items);

    final price = unitPrice ?? (discountedPrice ?? 0.0);
    final disc = (discountedPrice != null && unitPrice != null && unitPrice > discountedPrice)
        ? (unitPrice - discountedPrice)
        : 0.0;

    String? actualCartItemId;
    if (existingIndex >= 0) {
      final existingItem = updatedItems[existingIndex];
      actualCartItemId = existingItem.id;
      updatedItems[existingIndex] = existingItem.copyWith(
        quantity: targetQuantity,
        subtotal: (existingItem.unitPrice > 0 ? existingItem.unitPrice : price) * targetQuantity,
        lineDiscount: disc * targetQuantity,
        lineTotal: ((existingItem.unitPrice > 0 ? existingItem.unitPrice : price) - disc) * targetQuantity,
      );
    } else {
      updatedItems.add(
        CartItemModel(
          id: menuItemId,
          menuItemId: menuItemId,
          name: itemName ?? 'Dish',
          itemType: 'dish',
          quantity: targetQuantity,
          unitPrice: price,
          subtotal: price * targetQuantity,
          lineDiscount: disc * targetQuantity,
          lineTotal: (price - disc) * targetQuantity,
          imageUrl: itemImage,
        ),
      );
    }

    final newBasket = existingBasket.copyWith(items: updatedItems).recalculated();
    _updateBasket(vendorId, newBasket);

    try {
      final headers = await _headers();
      if (actualCartItemId != null && actualCartItemId.isNotEmpty && actualCartItemId != menuItemId) {
        final response = await http.patch(
          Uri.parse(ApiConfig.cartItemUrl(actualCartItemId)),
          headers: headers,
          body: jsonEncode({'quantity': targetQuantity}),
        );
        if (response.statusCode >= 200 && response.statusCode < 300) {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) {
            final data = CartData.fromJson(decoded);
            if (data.vendor?.id.isNotEmpty == true) {
              _updateBasket(data.vendor!.id, data);
            }
            return data;
          }
        }
      } else {
        final response = await http.post(
          Uri.parse(ApiConfig.cartItemsUrl),
          headers: headers,
          body: jsonEncode({
            'menu_item_id': menuItemId,
            'quantity': targetQuantity,
          }),
        );
        if (response.statusCode >= 200 && response.statusCode < 300) {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) {
            final data = CartData.fromJson(decoded);
            if (data.vendor?.id.isNotEmpty == true) {
              _updateBasket(data.vendor!.id, data);
            }
            return data;
          }
        }
      }
    } catch (e) {
      debugPrint('CartService setItemQuantity error: $e');
    }

    return newBasket;
  }

  /// Updates quantity of an existing cart line item
  static Future<CartData?> updateQuantity({
    required String cartItemId,
    required int quantity,
    String? vendorId,
  }) async {
    if (quantity <= 0) {
      return removeItem(cartItemId, vendorId: vendorId);
    }

    String targetVendorId = vendorId ?? '';
    String actualCartItemId = cartItemId;
    for (final entry in basketsNotifier.value.entries) {
      final match = entry.value.items.where((i) => i.id == cartItemId || i.menuItemId == cartItemId).firstOrNull;
      if (match != null) {
        if (targetVendorId.isEmpty) targetVendorId = entry.key;
        actualCartItemId = match.id.isNotEmpty ? match.id : cartItemId;
        break;
      }
    }

    if (targetVendorId.isNotEmpty) {
      final basket = basketsNotifier.value[targetVendorId];
      if (basket != null) {
        final updatedItems = basket.items.map((i) {
          if (i.id == cartItemId || i.menuItemId == cartItemId) {
            final unitPrice = i.unitPrice;
            return i.copyWith(
              quantity: quantity,
              subtotal: unitPrice * quantity,
              lineTotal: (unitPrice - (i.quantity > 0 ? (i.lineDiscount / i.quantity) : 0.0)) * quantity,
            );
          }
          return i;
        }).toList();

        final newBasket = basket.copyWith(items: updatedItems).recalculated();
        _updateBasket(targetVendorId, newBasket);
      }
    }

    try {
      final headers = await _headers();
      final response = await http.patch(
        Uri.parse(ApiConfig.cartItemUrl(actualCartItemId)),
        headers: headers,
        body: jsonEncode({'quantity': quantity}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final data = CartData.fromJson(decoded);
          if (data.vendor?.id.isNotEmpty == true) {
            _updateBasket(data.vendor!.id, data);
          } else if (targetVendorId.isNotEmpty) {
            _updateBasket(targetVendorId, data);
          } else {
            cartNotifier.value = data;
          }
          return data;
        }
      }
    } catch (e) {
      debugPrint('CartService updateQuantity error: $e');
    }
    return getBasket(targetVendorId) ?? currentCart;
  }

  /// Removes an item from a specific basket or active cart
  static Future<CartData?> removeItem(String cartItemId, {String? vendorId}) async {
    String targetVendorId = vendorId ?? '';
    String actualCartItemId = cartItemId;
    for (final entry in basketsNotifier.value.entries) {
      final match = entry.value.items.where((i) => i.id == cartItemId || i.menuItemId == cartItemId).firstOrNull;
      if (match != null) {
        if (targetVendorId.isEmpty) targetVendorId = entry.key;
        actualCartItemId = match.id.isNotEmpty ? match.id : cartItemId;
        break;
      }
    }

    if (targetVendorId.isNotEmpty) {
      final basket = basketsNotifier.value[targetVendorId];
      if (basket != null) {
        final updatedItems = basket.items
            .where((i) => i.id != cartItemId && i.menuItemId != cartItemId)
            .toList();

        final newBasket = basket.copyWith(items: updatedItems).recalculated();
        _updateBasket(targetVendorId, newBasket);
      }
    }

    try {
      final headers = await _headers();
      await http.delete(
        Uri.parse(ApiConfig.cartItemUrl(actualCartItemId)),
        headers: headers,
      );
    } catch (e) {
      debugPrint('CartService removeItem error: $e');
    }
    return getBasket(targetVendorId);
  }

  /// Clears an individual shop's basket
  static Future<bool> clearBasket(String vendorId) async {
    final map = Map<String, CartData>.from(basketsNotifier.value);
    map.remove(vendorId);
    basketsNotifier.value = map;
    cartNotifier.value = map.isNotEmpty ? map.values.first : null;
    return true;
  }

  /// Clears all baskets
  static Future<bool> clearCart() async {
    resetLocalState();

    try {
      final headers = await _headers();
      await http.delete(
        Uri.parse(ApiConfig.cartUrl),
        headers: headers,
      );
      return true;
    } catch (e) {
      debugPrint('CartService clearCart error: $e');
    }
    return true;
  }

  /// Selects a milestone free gift reward option for a vendor's basket
  static Future<CartData?> selectRewardOption(String rewardOptionId, {String? vendorId}) async {
    final vId = vendorId ?? currentCart?.vendor?.id ?? '';
    try {
      final headers = await _headers();
      final response = await http.put(
        Uri.parse(ApiConfig.cartRewardSelectionUrl),
        headers: headers,
        body: jsonEncode({'reward_option_id': rewardOptionId}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final data = CartData.fromJson(decoded);
          if (data.vendor?.id.isNotEmpty == true) {
            _updateBasket(data.vendor!.id, data);
          }
          return data;
        }
      }
    } catch (e) {
      debugPrint('CartService selectRewardOption error: $e');
    }
    return getBasket(vId) ?? currentCart;
  }

  /// Clears selected milestone reward option for a vendor's basket
  static Future<CartData?> clearRewardOption({String? vendorId}) async {
    final vId = vendorId ?? currentCart?.vendor?.id ?? '';
    try {
      final headers = await _headers();
      final response = await http.delete(
        Uri.parse(ApiConfig.cartRewardSelectionUrl),
        headers: headers,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final data = CartData.fromJson(decoded);
          if (data.vendor?.id.isNotEmpty == true) {
            _updateBasket(data.vendor!.id, data);
          }
          return data;
        }
      }
    } catch (e) {
      debugPrint('CartService clearRewardOption error: $e');
    }
    return getBasket(vId) ?? currentCart;
  }
}

