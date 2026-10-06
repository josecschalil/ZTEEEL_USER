import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';
import 'cart_service.dart';

class RedemptionItem {
  final String id;
  final String menuItemId;
  final String name;
  final double unitPrice;
  final int quantity;
  final double lineSubtotal;
  final double lineDiscount;
  final double lineTotal;
  final bool isRewardItem;
  final String? imageUrl;
  final String note;
  final List<Map<String, dynamic>> components;

  const RedemptionItem({
    required this.id,
    required this.menuItemId,
    required this.name,
    required this.unitPrice,
    required this.quantity,
    required this.lineSubtotal,
    required this.lineDiscount,
    required this.lineTotal,
    this.isRewardItem = false,
    this.imageUrl,
    this.note = '',
    this.components = const [],
  });

  factory RedemptionItem.fromJson(Map<String, dynamic> json) {
    final rawImage = json['image']?.toString() ?? json['image_url']?.toString() ?? '';
    String? resolvedImage;
    if (rawImage.isNotEmpty) {
      resolvedImage = rawImage.startsWith('http://') || rawImage.startsWith('https://')
          ? rawImage
          : '${ApiConfig.baseUrl}${rawImage.startsWith('/') ? '' : '/'}$rawImage';
    }

    final components = <Map<String, dynamic>>[];
    if (json['components'] is List) {
      for (final c in (json['components'] as List).whereType<Map<String, dynamic>>()) {
        components.add(c);
      }
    }

    return RedemptionItem(
      id: json['id']?.toString() ?? '',
      menuItemId: json['menu_item_id']?.toString() ?? json['menu_item']?.toString() ?? '',
      name: json['item_name_snapshot']?.toString() ?? json['name']?.toString() ?? 'Dish',
      unitPrice: double.tryParse(json['unit_price_snapshot']?.toString() ?? json['unit_price']?.toString() ?? '0.0') ?? 0.0,
      quantity: int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      lineSubtotal: double.tryParse(json['line_subtotal']?.toString() ?? '0.0') ?? 0.0,
      lineDiscount: double.tryParse(json['line_discount']?.toString() ?? '0.0') ?? 0.0,
      lineTotal: double.tryParse(json['line_total']?.toString() ?? '0.0') ?? 0.0,
      isRewardItem: json['is_reward_item'] == true,
      imageUrl: resolvedImage,
      note: json['note']?.toString() ?? (json['is_reward_item'] == true ? 'Free Milestone Reward' : 'Standard serve'),
      components: components,
    );
  }
}

class RedemptionOffer {
  final String id;
  final String title;
  final double discountPercentage;
  final double qualifyingSubtotal;
  final double discountAmount;

  const RedemptionOffer({
    required this.id,
    required this.title,
    required this.discountPercentage,
    required this.qualifyingSubtotal,
    required this.discountAmount,
  });

  factory RedemptionOffer.fromJson(Map<String, dynamic> json) {
    return RedemptionOffer(
      id: json['id']?.toString() ?? json['offer_id']?.toString() ?? '',
      title: json['title_snapshot']?.toString() ?? json['title']?.toString() ?? 'Offer',
      discountPercentage: double.tryParse(json['percentage_snapshot']?.toString() ?? json['discount_percentage']?.toString() ?? '0.0') ?? 0.0,
      qualifyingSubtotal: double.tryParse(json['qualifying_subtotal']?.toString() ?? '0.0') ?? 0.0,
      discountAmount: double.tryParse(json['discount_amount']?.toString() ?? '0.0') ?? 0.0,
    );
  }
}

class RedemptionRewardSnapshot {
  final String milestoneName;
  final double thresholdAmount;
  final double discountAmount;
  final String giftItemName;
  final double? giftItemPrice;

  const RedemptionRewardSnapshot({
    required this.milestoneName,
    required this.thresholdAmount,
    required this.discountAmount,
    required this.giftItemName,
    this.giftItemPrice,
  });

  factory RedemptionRewardSnapshot.fromJson(Map<String, dynamic> json) {
    return RedemptionRewardSnapshot(
      milestoneName: json['name_snapshot']?.toString() ?? json['milestone_name']?.toString() ?? 'Milestone Reward',
      thresholdAmount: double.tryParse(json['threshold_amount_snapshot']?.toString() ?? '0.0') ?? 0.0,
      discountAmount: double.tryParse(json['discount_amount']?.toString() ?? '0.0') ?? 0.0,
      giftItemName: json['gift_item_name_snapshot']?.toString() ?? '',
      giftItemPrice: double.tryParse(json['gift_item_price_snapshot']?.toString() ?? ''),
    );
  }
}

class RedemptionSessionData {
  final String id;
  final String qrCode;
  final String? rawOrderNumber;
  final String status;
  final CartVendor? vendor;
  final double subtotal;
  final double itemDiscount;
  final double eligibleSubtotal;
  final double milestoneDiscount;
  final double totalDiscount;
  final double finalTotal;
  final List<RedemptionItem> items;
  final List<RedemptionOffer> appliedOffers;
  final RedemptionRewardSnapshot? rewardSnapshot;
  final DateTime? expiresAt;
  final DateTime? createdAt;
  final DateTime? confirmedAt;

  const RedemptionSessionData({
    required this.id,
    required this.qrCode,
    this.rawOrderNumber,
    required this.status,
    this.vendor,
    this.subtotal = 0.0,
    this.itemDiscount = 0.0,
    this.eligibleSubtotal = 0.0,
    this.milestoneDiscount = 0.0,
    this.totalDiscount = 0.0,
    this.finalTotal = 0.0,
    this.items = const [],
    this.appliedOffers = const [],
    this.rewardSnapshot,
    this.expiresAt,
    this.createdAt,
    this.confirmedAt,
  });

  String get orderNumber {
    if (rawOrderNumber != null && rawOrderNumber!.isNotEmpty) {
      return rawOrderNumber!.startsWith('#') ? rawOrderNumber! : '#$rawOrderNumber';
    }
    if (qrCode.isNotEmpty) {
      final clean = qrCode.replaceAll('-', '').toUpperCase();
      final code = clean.length >= 8 ? clean.substring(0, 8) : clean;
      return '#$code';
    }
    return '#C571267D';
  }

  bool get isExpired {
    final s = status.toLowerCase();
    if (s == 'expired' || s == 'cancelled') return true;
    if (s == 'pending' && expiresAt != null && expiresAt!.isBefore(DateTime.now())) {
      return true;
    }
    return false;
  }

  bool get isPending {
    final s = status.toLowerCase();
    if (s != 'pending') return false;
    return !isExpired;
  }

  bool get isConfirmed {
    final s = status.toLowerCase();
    return s == 'confirmed' || s == 'completed' || s == 'delivered';
  }

  bool get isCancelled => status.toLowerCase() == 'cancelled';

  factory RedemptionSessionData.fromJson(Map<String, dynamic> json) {
    CartVendor? vendor;
    if (json['vendor'] is Map<String, dynamic>) {
      vendor = CartVendor.fromJson(json['vendor']);
    }

    final items = <RedemptionItem>[];
    if (json['items'] is List) {
      for (final itm in (json['items'] as List).whereType<Map<String, dynamic>>()) {
        items.add(RedemptionItem.fromJson(itm));
      }
    }

    final offers = <RedemptionOffer>[];
    if (json['applied_offers'] is List) {
      for (final off in (json['applied_offers'] as List).whereType<Map<String, dynamic>>()) {
        offers.add(RedemptionOffer.fromJson(off));
      }
    }

    RedemptionRewardSnapshot? reward;
    if (json['reward_snapshot'] is Map<String, dynamic>) {
      reward = RedemptionRewardSnapshot.fromJson(json['reward_snapshot']);
    } else if (json['reward'] is Map<String, dynamic>) {
      reward = RedemptionRewardSnapshot.fromJson(json['reward']);
    }

    DateTime? expiresAt;
    if (json['expires_at'] != null) {
      expiresAt = DateTime.tryParse(json['expires_at'].toString());
    }

    DateTime? createdAt;
    if (json['created_at'] != null) {
      createdAt = DateTime.tryParse(json['created_at'].toString());
    }

    DateTime? confirmedAt;
    if (json['confirmed_at'] != null) {
      confirmedAt = DateTime.tryParse(json['confirmed_at'].toString());
    }

    return RedemptionSessionData(
      id: json['id']?.toString() ?? '',
      qrCode: json['qr_code']?.toString() ?? '',
      rawOrderNumber: json['order_number']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      vendor: vendor,
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0.0') ?? 0.0,
      itemDiscount: double.tryParse(json['item_discount']?.toString() ?? '0.0') ?? 0.0,
      eligibleSubtotal: double.tryParse(json['eligible_subtotal']?.toString() ?? '0.0') ?? 0.0,
      milestoneDiscount: double.tryParse(json['milestone_discount']?.toString() ?? '0.0') ?? 0.0,
      totalDiscount: double.tryParse(json['total_discount']?.toString() ?? '0.0') ?? 0.0,
      finalTotal: double.tryParse(json['final_total']?.toString() ?? '0.0') ?? 0.0,
      items: items,
      appliedOffers: offers,
      rewardSnapshot: reward,
      expiresAt: expiresAt,
      createdAt: createdAt,
      confirmedAt: confirmedAt,
    );
  }
}

class RedemptionService {
  RedemptionService._();

  static Future<Map<String, String>> _headers() async {
    final auth = await AuthService.getAuthHeaders();
    return {
      'Content-Type': 'application/json',
      ...auth,
    };
  }

  /// Generates a real RedemptionSession from a specific vendor's cart or the active cart
  static Future<Map<String, dynamic>> generateRedemption({
    String? vendorId,
    String? idempotencyKey,
  }) async {
    try {
      final headers = await _headers();
      final body = <String, dynamic>{};
      if (idempotencyKey != null && idempotencyKey.isNotEmpty) {
        body['idempotency_key'] = idempotencyKey;
      }
      if (vendorId != null && vendorId.isNotEmpty) {
        body['vendor_id'] = vendorId;
      }

      final response = await http.post(
        Uri.parse(ApiConfig.redemptionGenerateUrl),
        headers: headers,
        body: jsonEncode(body),
      );

      dynamic decoded;
      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        // Reverse proxies and Django's DEBUG page return HTML for a 5xx. Do
        // not disguise that as a client-network failure; it is actionable for
        // support and points to the backend logs.
        return {
          'success': false,
          'error': response.statusCode >= 500
              ? 'Order service is temporarily unavailable (server error ${response.statusCode}). Please try again shortly.'
              : 'Order request failed (HTTP ${response.statusCode}).',
        };
      }
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decoded is Map<String, dynamic>) {
          final session = RedemptionSessionData.fromJson(decoded);
          // Clear only this vendor's basket if multi-vendor, or all if sole basket
          if (vendorId != null && vendorId.isNotEmpty) {
            await CartService.clearBasket(vendorId);
          } else if (session.vendor?.id.isNotEmpty == true) {
            await CartService.clearBasket(session.vendor!.id);
          } else {
            await CartService.clearCart();
          }
          return {'success': true, 'data': session};
        }
      }

      final msg = decoded is Map
          ? (decoded['message'] ?? decoded['detail'] ?? 'Failed to generate redemption code')
          : 'Failed to generate redemption code';
      return {'success': false, 'error': msg.toString()};
    } catch (e) {
      debugPrint('RedemptionService generateRedemption error: $e');
      return {
        'success': false,
        'error': 'Unable to reach the order service. Check your connection and try again.',
      };
    }
  }

  /// Generates separate RedemptionSessions for all active baskets
  static Future<Map<String, dynamic>> generateAllRedemptions() async {
    final baskets = CartService.allBaskets;
    if (baskets.isEmpty) {
      return {'success': false, 'error': 'Your cart is empty.'};
    }

    final createdSessions = <RedemptionSessionData>[];
    String? lastError;

    for (final basket in baskets) {
      final vId = basket.vendor?.id ?? '';
      final res = await generateRedemption(vendorId: vId);
      if (res['success'] == true && res['data'] is RedemptionSessionData) {
        createdSessions.add(res['data'] as RedemptionSessionData);
      } else {
        lastError = res['error']?.toString();
      }
    }

    if (createdSessions.isNotEmpty) {
      return {'success': true, 'sessions': createdSessions};
    }

    return {'success': false, 'error': lastError ?? 'Failed to create orders.'};
  }

  /// Fetches live details and state of a QR session
  static Future<RedemptionSessionData?> getQRDetail(String qrCode) async {
    try {
      final headers = await _headers();
      final response = await http.get(
        Uri.parse(ApiConfig.redemptionDetailUrl(qrCode)),
        headers: headers,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return RedemptionSessionData.fromJson(decoded);
        }
      }
    } catch (e) {
      debugPrint('RedemptionService getQRDetail error: $e');
    }
    return null;
  }

  /// Cancels a pending QR redemption session
  static Future<bool> cancelRedemption(String qrCode) async {
    try {
      final headers = await _headers();
      final response = await http.post(
        Uri.parse(ApiConfig.cancelRedemptionUrl(qrCode)),
        headers: headers,
      );

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      debugPrint('RedemptionService cancelRedemption error: $e');
      return false;
    }
  }

  /// Fetches customer redemption history (pending, completed, expired)
  static Future<List<RedemptionSessionData>> getCustomerRedemptions() async {
    try {
      final headers = await _headers();
      final response = await http.get(
        Uri.parse(ApiConfig.customerRedemptionsUrl),
        headers: headers,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded
              .whereType<Map<String, dynamic>>()
              .map((j) => RedemptionSessionData.fromJson(j))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('RedemptionService getCustomerRedemptions error: $e');
    }
    return [];
  }
}
