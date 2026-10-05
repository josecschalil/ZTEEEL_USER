import 'dart:math' as math;

import 'package:flutter/material.dart';

// Reference proportions: approximately 730 x 430, or 320 x 188 logical pixels.
// This recreates the layout and vector decorations, NOT the food photographs.
// Dark: supply a full-frame food photo as backgroundImage (or foodImage).
// White / gradient: supply a transparent PNG/WebP cutout as foodImage.
// Register your reference font in pubspec.yaml, then pass fontFamily to the rail.
// No flutter_svg dependency: decorative shapes are resolution-independent Paths.

enum OfferCardOption { dark, white, gradient }

@immutable
class OfferCardData {
  final String id;
  final String title;
  final String discount;
  final String restaurant;
  final String distance;
  final String category;
  final String timeLeft;
  final String subtitle;
  final String savings;
  final ImageProvider? foodImage;
  final ImageProvider? restaurantLogo;
  final OfferCardOption option;

  /// Full-frame photography, intended for the dark option.
  final ImageProvider? backgroundImage;
  final Alignment backgroundAlignment;
  final Alignment foodAlignment;

  const OfferCardData({
    required this.id,
    required this.title,
    required this.discount,
    required this.restaurant,
    this.distance = '',
    this.category = '',
    this.timeLeft = '',
    this.subtitle = '',
    this.savings = '',
    this.foodImage,
    this.restaurantLogo,
    this.option = OfferCardOption.dark,
    this.backgroundImage,
    this.backgroundAlignment = Alignment.centerRight,
    this.foodAlignment = Alignment.bottomRight,
  });
}

class OfferRail extends StatelessWidget {
  final List<OfferCardData> offers;
  final ValueChanged<OfferCardData>? onOfferTap;
  final VoidCallback? onSeeAll;
  final bool isLoading;
  final String title;
  final Color accentColor;
  final String? fontFamily;

  const OfferRail({
    super.key,
    required this.offers,
    this.onOfferTap,
    this.onSeeAll,
    this.isLoading = false,
    this.title = "Deals for You 🔥",
    this.accentColor = const Color(0xFFEE5B2B),
    this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading && offers.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(builder: (context, constraints) {
      final available = constraints.hasBoundedWidth
          ? constraints.maxWidth
          : MediaQuery.sizeOf(context).width;
      // Leave enough of the following card visible to imply horizontal scrolling.
      final width = math.min(340.0, math.max(1.0, available - 48));
      final s = width / 320;
      final height = isLoading
          ? 188 * s
          : offers.fold<double>(188 * s, (height, offer) => math.max(
                height, _requiredHeight(context, offer, width, fontFamily)));
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 10, 10),
          child: Row(children: [
            Expanded(child: Text(title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontFamily: fontFamily, fontSize: 18,
                    fontWeight: FontWeight.w700, letterSpacing: -0.35))),
            if (!isLoading && onSeeAll != null)
              TextButton(
                key: const ValueKey('home-see-all-deals'),
                onPressed: onSeeAll,
                style: TextButton.styleFrom(
                    foregroundColor: accentColor,
                    minimumSize: const Size(64, 44)),
                child: const Text('See all',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
          ]),
        ),
        SizedBox(
          // Four pixels provide space below the restrained shadow.
          height: height + 4,
          child: ListView.separated(
            key: const PageStorageKey('home-offers-rail'),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 4),
            itemCount: isLoading ? 3 : offers.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, index) => SizedBox(
              width: width,
              child: isLoading
                  ? const _OfferSkeletonCard()
                  : OfferCard(
                      key: ValueKey(offers[index].id),
                      offer: offers[index],
                      fontFamily: fontFamily,
                      onTap: onOfferTap == null
                          ? null : () => onOfferTap!(offers[index]),
                    ),
            ),
          ),
        ),
      ]);
    });
  }
}

String _formatTitle(String rawTitle) {
  final title = rawTitle.trim();
  if (title.contains('\n')) return title;

  if (title.contains(' + ')) {
    final parts = title.split(' + ');
    if (parts.length == 2) {
      return '${parts[0]} +\n${parts[1]}';
    }
  }

  if (title.contains(' & ')) {
    final parts = title.split(' & ');
    if (parts.length == 2) {
      return '${parts[0]} &\n${parts[1]}';
    }
  }

  final words = title.split(RegExp(r'\s+'));
  if (words.length <= 2) {
    return title;
  }
  if (words.length == 3) {
    if (words[0].length + words[1].length <= 14) {
      return '${words[0]} ${words[1]}\n${words[2]}';
    } else {
      return '${words[0]}\n${words[1]} ${words[2]}';
    }
  }
  if (words.length == 4) {
    return '${words[0]} ${words[1]}\n${words[2]} ${words[3]}';
  }

  final mid = (words.length / 2).ceil();
  return '${words.take(mid).join(' ')}\n${words.skip(mid).take(2).join(' ')}';
}

String _formatSubtitle(String subtitle) {
  final clean = subtitle.trim();
  if (clean.isEmpty ||
      clean.toLowerCase() == 'special offer' ||
      clean.toLowerCase() == 'special discount on select orders') {
    return 'On selected items';
  }
  return clean;
}

TextStyle _titleStyle(double ts, Color color, String? fontFamily,
    [OfferCardOption option = OfferCardOption.dark]) => TextStyle(
    fontFamily: fontFamily, color: color,
    fontSize: (option == OfferCardOption.gradient ? 20.0 : 21.0) * ts,
    height: 1.05, fontWeight: FontWeight.w800, letterSpacing: -0.5 * ts);

double _textHeight(BuildContext context, String text, TextStyle style,
    double width, int lines) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: DefaultTextStyle.of(context).style.merge(style)),
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
    maxLines: lines,
    ellipsis: '…',
  )..layout(maxWidth: width);
  final height = painter.height;
  painter.dispose();
  return height;
}

double _requiredHeight(BuildContext context, OfferCardData offer,
    double width, String? family) {
  final s = width / 320;
  final ts = math.min(s, 1.0);
  final displayTitle = _formatTitle(offer.title);
  final displaySubtitle = _formatSubtitle(offer.subtitle);
  final titleHeight = _textHeight(context, displayTitle,
      _titleStyle(ts, Colors.black, family, offer.option), width * 0.58, 2);
  final subtitleHeight = 3 * s + _textHeight(
      context, displaySubtitle,
      TextStyle(fontFamily: family, fontSize: 11.0 * ts, height: 1.25, fontWeight: FontWeight.w500),
      width * 0.58, 1);
  final middleHeight = titleHeight + subtitleHeight;
  final nameHeight = _textHeight(context, offer.restaurant,
      TextStyle(fontFamily: family, fontSize: 13.5 * ts, height: 1.15, fontWeight: FontWeight.w800),
      width * 0.58 - 36 * s, 1);
  final metaHeight = offer.distance.isEmpty && offer.category.isEmpty ? 0.0
      : _textHeight(context, '1.2 km · Restaurant',
          TextStyle(fontFamily: family, fontSize: 9.5 * ts, height: 1.2, fontWeight: FontWeight.w500),
          width * 0.58 - 36 * s, 1) + 2 * s;
  final restaurantHeight = math.max(28 * s, nameHeight + metaHeight);
  final buttonHeight = 27 * s;
  final bottomSectionHeight = restaurantHeight + 8 * s + buttonHeight + 12 * s;
  final baseGap = 8 * s;
  return math.max(188 * s, (44 * s) + baseGap + middleHeight + baseGap + bottomSectionHeight);
}

/// Use a bounded height outside OfferRail; approximately width * 0.588.
/// The rail measures long titles and larger text and increases its height.
class OfferCard extends StatelessWidget {
  final OfferCardData offer;
  final VoidCallback? onTap;
  final String? fontFamily;

  const OfferCard({super.key, required this.offer, this.onTap, this.fontFamily});

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: MediaQuery.textScalerOf(context)
            .clamp(minScaleFactor: 0.85, maxScaleFactor: 1.05),
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        final width = constraints.hasBoundedWidth ? constraints.maxWidth : 320.0;
        final height = constraints.hasBoundedHeight ? constraints.maxHeight
            : _requiredHeight(context, offer, width, fontFamily);
        final s = width / 320;
        final ts = math.min(s, 1.0);
        final p = _Palette.forOption(offer.option);
        final radius = BorderRadius.circular(22 * s);
        final metadata = [offer.distance, offer.category]
            .where((value) => value.trim().isNotEmpty).join(' • ');
        final nameHeight = _textHeight(context, offer.restaurant,
            TextStyle(fontFamily: fontFamily, fontSize: 13.5 * ts, height: 1.15, fontWeight: FontWeight.w800),
            width * 0.58 - 36 * s, 1);
        final metaHeight = metadata.isEmpty ? 0.0 : _textHeight(context, metadata,
            TextStyle(fontFamily: fontFamily, fontSize: 9.5 * ts, height: 1.2, fontWeight: FontWeight.w500),
            width * 0.58 - 36 * s, 1) + 2 * s;
        final restaurantHeight = math.max(28 * s, nameHeight + metaHeight);
        final buttonHeight = 27 * s;
        final buttonBottom = 12 * s;
        final restaurantBottom = buttonBottom + buttonHeight + 8 * s;
        final bottomSectionTop = height - (restaurantBottom + restaurantHeight);
        final headerBottom = 44 * s;

        final displayTitle = _formatTitle(offer.title);
        final displaySubtitle = _formatSubtitle(offer.subtitle);
        final titleHeight = _textHeight(context, displayTitle,
            _titleStyle(ts, p.foreground, fontFamily, offer.option), width * 0.58, 2);
        final subtitleHeight = 3 * s + _textHeight(
            context, displaySubtitle,
            TextStyle(fontFamily: fontFamily, fontSize: 11.0 * ts, height: 1.25, fontWeight: FontWeight.w500),
            width * 0.58, 1);
        final middleHeight = titleHeight + subtitleHeight;

        final availableSpace = math.max(0.0, bottomSectionTop - headerBottom);
        final middleGap = math.max(4 * s, (availableSpace - middleHeight) / 2);
        final middleTop = headerBottom + middleGap;

        return SizedBox(
          width: width, height: height,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: const [BoxShadow(color: Color(0x14000000),
                  blurRadius: 5, offset: Offset(0, 2))],
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: Stack(fit: StackFit.expand, children: [
                DecoratedBox(decoration: BoxDecoration(
                    color: p.background, gradient: p.gradient)),
                _Artwork(offer: offer, scale: s),
                Positioned.fill(child: IgnorePointer(child: CustomPaint(
                    painter: _CardPatternPainter(offer.option)))),
                // Cutouts sit above the pattern, with their original alpha intact.
                if (offer.foodImage != null)
                  Positioned(
                    right: -70 * s,
                    bottom: -50 * s,
                    width: width * 1.3,
                    height: height * 1.3,
                    child: ExcludeSemantics(child: Image(
                      image: offer.foodImage!,
                      fit: BoxFit.contain,
                      alignment: offer.foodAlignment,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    )),
                  ),
                // Transparent Material is ABOVE the artwork, keeping tap feedback visible.
                Positioned.fill(child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    key: ValueKey('home-deal-${offer.id}'),
                    onTap: onTap,
                    borderRadius: radius,
                    splashColor: p.foreground.withValues(alpha: 0.10),
                    highlightColor: p.foreground.withValues(alpha: 0.04),
                    child: Stack(children: [
                      Positioned(top: 14 * s, left: 15 * s, right: 13 * s,
                        height: 30 * s,
                        child: _CardHeader(offer: offer, palette: p,
                            scale: s, textScale: ts, fontFamily: fontFamily)),
                      Positioned(
                        top: middleTop,
                        left: 18 * s,
                        width: width * 0.58,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              displayTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: _titleStyle(ts, p.foreground, fontFamily, offer.option),
                            ),
                            SizedBox(height: 3 * s),
                            Text(
                              displaySubtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: fontFamily,
                                color: p.foreground.withValues(alpha: 0.80),
                                fontSize: 11.0 * ts,
                                height: 1.25,
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.15 * ts,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 16 * s,
                        bottom: restaurantBottom,
                        width: width * 0.58,
                        height: restaurantHeight,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 28 * s,
                              height: 28 * s,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: p.foreground.withValues(alpha: 0.12),
                                border: Border.all(
                                  color: p.foreground.withValues(alpha: 0.22),
                                  width: 0.8 * s,
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: offer.restaurantLogo != null
                                  ? Image(
                                      image: offer.restaurantLogo!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => Center(
                                        child: Text(
                                          offer.restaurant.isNotEmpty
                                              ? offer.restaurant[0].toUpperCase()
                                              : 'R',
                                          style: TextStyle(
                                            fontFamily: fontFamily,
                                            fontSize: 13 * ts,
                                            fontWeight: FontWeight.w900,
                                            color: p.foreground,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: Text(
                                        offer.restaurant.isNotEmpty
                                            ? offer.restaurant[0].toUpperCase()
                                            : 'R',
                                        style: TextStyle(
                                          fontFamily: fontFamily,
                                          fontSize: 13 * ts,
                                          fontWeight: FontWeight.w900,
                                          color: p.foreground,
                                        ),
                                      ),
                                    ),
                            ),
                            SizedBox(width: 8 * s),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    offer.restaurant,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: fontFamily,
                                      color: p.foreground,
                                      fontSize: 13.5 * ts,
                                      fontWeight: FontWeight.w800,
                                      height: 1.15,
                                      letterSpacing: -0.2 * ts,
                                    ),
                                  ),
                                  if (metadata.isNotEmpty) ...[
                                    SizedBox(height: 2 * s),
                                    Row(
                                      children: [
                                        if (offer.distance.isNotEmpty) ...[
                                          Icon(
                                            Icons.location_on_rounded,
                                            size: 10 * s,
                                            color: p.secondary,
                                          ),
                                          SizedBox(width: 2 * s),
                                        ],
                                        Expanded(
                                          child: Text(
                                            metadata,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontFamily: fontFamily,
                                              color: p.secondary,
                                              fontSize: 9.5 * ts,
                                              fontWeight: FontWeight.w500,
                                              height: 1.2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 16 * s,
                        bottom: buttonBottom,
                        height: buttonHeight,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: p.ctaBackground,
                            gradient: p.ctaGradient,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: p.ctaBorder, width: 0.7 * s),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 11 * s),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  offer.savings.isEmpty ? 'View offer' : offer.savings,
                                  style: TextStyle(
                                    fontFamily: fontFamily,
                                    color: p.ctaText,
                                    fontSize: 11.0 * ts,
                                    fontWeight: FontWeight.w800,
                                    height: 1.15,
                                    letterSpacing: -0.2 * ts,
                                  ),
                                ),
                                SizedBox(width: 4 * s),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 13 * s,
                                  color: p.ctaText,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Border is inside the clip, so the white card keeps a clean edge.
                      Positioned.fill(child: IgnorePointer(child: DecoratedBox(
                        decoration: BoxDecoration(borderRadius: radius,
                            border: Border.all(color: p.border, width: 0.6 * s)),
                      ))),
                    ]),
                  ),
                )),
              ]),
            ),
          ),
        );
      }),
    );
  }
}

class _Artwork extends StatelessWidget {
  final OfferCardData offer;
  final double scale;
  const _Artwork({required this.offer, required this.scale});

  @override
  Widget build(BuildContext context) {
    final photo = offer.backgroundImage;
    if (photo == null) return const SizedBox.shrink();
    return Stack(fit: StackFit.expand, children: [
      ExcludeSemantics(child: Image(image: photo, fit: BoxFit.cover,
        alignment: offer.backgroundAlignment,
        errorBuilder: (_, _, _) => const SizedBox.shrink())),
      const DecoratedBox(decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.centerLeft,
          end: Alignment.centerRight, stops: [0, 0.35, 0.68, 1],
          colors: [Color(0xE60B0905), Color(0xB30B0905),
            Color(0x260B0905), Color(0x000B0905)]),
      )),
      const DecoratedBox(decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.bottomCenter,
          end: Alignment.topCenter, stops: [0, 0.35, 1],
          colors: [Color(0x66000000), Color(0x00000000), Color(0x00000000)]),
      )),
    ]);
  }
}

class _CardHeader extends StatelessWidget {
  final OfferCardData offer;
  final _Palette palette;
  final double scale;
  final double textScale;
  final String? fontFamily;
  const _CardHeader({required this.offer, required this.palette,
      required this.scale, required this.textScale, this.fontFamily});

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
    final s = scale;
    final ts = textScale;
    final time = offer.timeLeft.isEmpty ? 'Limited time' : offer.timeLeft;
    final timePainter = TextPainter(
      text: TextSpan(text: time, style: TextStyle(fontFamily: fontFamily,
          fontSize: 10.0 * ts, fontWeight: FontWeight.w700)),
      textDirection: Directionality.of(context),
    )..layout();
    final timerWidth = math.min(108 * s, timePainter.width + 29 * s);
    timePainter.dispose();
    final badgePainter = TextPainter(
      text: TextSpan(text: offer.discount, style: TextStyle(fontFamily: fontFamily,
          fontSize: 18.0 * ts, fontWeight: FontWeight.w900)),
      textDirection: Directionality.of(context),
    )..layout();
    final badgeWidth = math.max(1.0, math.min(
        c.maxWidth - timerWidth - 17 * s, badgePainter.width + 23 * s));
    badgePainter.dispose();
    return Stack(clipBehavior: Clip.none, children: [
      Positioned(left: 0, top: 1 * s, width: badgeWidth, height: 30 * s,
        child: Transform.rotate(angle: -0.065,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10 * s),
            decoration: BoxDecoration(color: palette.badgeBackground,
              gradient: palette.badgeGradient,
              borderRadius: BorderRadius.circular(9 * s),
              border: Border.all(color: palette.badgeBorder, width: 0.5 * s)),
            alignment: Alignment.center,
            child: FittedBox(fit: BoxFit.scaleDown,
              child: Text(offer.discount, maxLines: 1,
                style: TextStyle(fontFamily: fontFamily, color: palette.badgeText,
                  fontSize: 18.0 * ts, height: 1, fontWeight: FontWeight.w900,
                  fontStyle: offer.option == OfferCardOption.white
                      ? FontStyle.normal : FontStyle.italic,
                  letterSpacing: -0.5 * ts))),
          ),
        ),
      ),
      Positioned(left: badgeWidth + 5 * s, top: -1 * s,
        width: 17 * s, height: 28 * s,
        child: IgnorePointer(child: CustomPaint(
          painter: _BurstPainter(palette.decoration))),
      ),
      Positioned(right: 0, top: 0, width: timerWidth, height: 26 * s,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8 * s),
          decoration: BoxDecoration(color: palette.timerBackground,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: palette.timerBorder, width: 0.7 * s)),
          child: FittedBox(fit: BoxFit.scaleDown,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.schedule_rounded, size: 13 * s, color: palette.timerText),
              SizedBox(width: 5 * s),
              Text(time, style: TextStyle(fontFamily: fontFamily,
                color: palette.timerText, fontSize: 10.0 * ts,
                fontWeight: FontWeight.w700, letterSpacing: -0.3 * ts)),
            ])),
        ),
      ),
    ]);
  });
}

/// Three hand-drawn rays; this is intentionally not an emoji or stock icon.
class _BurstPainter extends CustomPainter {
  final Color color;
  const _BurstPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 17, size.height / 28);
    final paint = Paint()..color = color..style = PaintingStyle.stroke
      ..strokeWidth = 3.1..strokeCap = StrokeCap.round;
    canvas.drawPath(Path()..moveTo(2, 7)..quadraticBezierTo(4, 4, 7, 2), paint);
    canvas.drawPath(Path()..moveTo(6, 14)..quadraticBezierTo(10, 13.8, 15, 14), paint);
    canvas.drawPath(Path()..moveTo(3, 21)..quadraticBezierTo(5, 23, 7, 25), paint);
    canvas.restore();
  }
  @override
  bool shouldRepaint(_BurstPainter oldDelegate) => color != oldDelegate.color;
}

/// Organic bands and outline droplets adapted across dark, white, and gradient themes.
class _CardPatternPainter extends CustomPainter {
  final OfferCardOption option;
  const _CardPatternPainter(this.option);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.scale(size.width / 320, size.height / 188);

    final Color band1Color;
    final Color band2Color;
    final Color band3Color;
    final Color inkColor;

    switch (option) {
      case OfferCardOption.dark:
        band1Color = const Color(0x1CFFFFFF);
        band2Color = const Color(0x18FFBA39);
        band3Color = const Color(0x30000000);
        inkColor = const Color(0x65FFC266);
        break;
      case OfferCardOption.white:
        band1Color = const Color(0x40FFD8C2);
        band2Color = const Color(0x30FFE8D6);
        band3Color = const Color(0x25F5BE9E);
        inkColor = const Color(0x95FF5A36);
        break;
      case OfferCardOption.gradient:
        band1Color = const Color(0x32FFB541);
        band2Color = const Color(0x20FFD161);
        band3Color = const Color(0x30C81545);
        inkColor = const Color(0xFFFDF7EC);
        break;
    }

    final bands = Paint()..color = band1Color;
    canvas.drawPath(Path()..moveTo(210, -15)
      ..cubicTo(245, 8, 208, 31, 235, 54)
      ..cubicTo(282, 83, 234, 115, 260, 145)
      ..cubicTo(279, 167, 282, 183, 272, 205)
      ..lineTo(340, 205)..lineTo(340, -15)..close(), bands);
    bands.color = band2Color;
    canvas.drawPath(Path()..moveTo(78, -10)
      ..cubicTo(39, 18, 96, 31, 67, 57)
      ..cubicTo(36, 91, 93, 113, 65, 147)
      ..cubicTo(50, 163, 87, 179, 73, 203)
      ..lineTo(128, 203)..cubicTo(142, 172, 117, 164, 135, 141)
      ..cubicTo(166, 104, 117, 88, 153, 55)
      ..cubicTo(180, 29, 135, 13, 163, -10)..close(), bands);
    bands.color = band3Color;
    canvas.drawPath(Path()..moveTo(-10, 20)
      ..cubicTo(35, 5, 58, 20, 49, 42)
      ..cubicTo(24, 75, 64, 103, 22, 130)
      ..cubicTo(-2, 146, 18, 169, 8, 205)
      ..lineTo(-10, 205)..close(), bands);
    final ink = Paint()..color = inkColor
      ..style = PaintingStyle.stroke..strokeWidth = 2.1
      ..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;
    // Curved closed Paths
    canvas.drawPath(Path()..moveTo(257, 65)
      ..cubicTo(252, 70, 254, 64, 257, 58)
      ..cubicTo(263, 47, 267, 57, 257, 65)..close(), ink);
    canvas.drawPath(Path()..moveTo(260, 71)
      ..cubicTo(264, 65, 278, 61, 273, 66)
      ..cubicTo(269, 70, 261, 73, 260, 71)..close(), ink);
    canvas.drawPath(Path()..moveTo(168, 146)
      ..cubicTo(162, 140, 153, 121, 157, 127)
      ..cubicTo(161, 132, 173, 146, 168, 146)..close(), ink);
    canvas.drawPath(Path()..moveTo(164, 148)
      ..cubicTo(154, 148, 150, 144, 149, 142)
      ..cubicTo(155, 145, 162, 146, 164, 148)..close(), ink);
    canvas.restore();
  }
  @override
  bool shouldRepaint(_CardPatternPainter oldDelegate) => option != oldDelegate.option;
}

class _Palette {
  final Color background, foreground, secondary, border;
  final Color badgeBackground, badgeText, badgeBorder, decoration;
  final Color timerBackground, timerText, timerBorder;
  final Color ctaBackground, ctaText, ctaBorder, logoBackground, logoBorder;
  final Gradient? gradient, badgeGradient, ctaGradient;
  const _Palette({required this.background, required this.foreground,
    required this.secondary, required this.border, required this.badgeBackground,
    required this.badgeText, required this.badgeBorder, required this.decoration,
    required this.timerBackground, required this.timerText, required this.timerBorder,
    required this.ctaBackground, required this.ctaText, required this.ctaBorder,
    required this.logoBackground, required this.logoBorder,
    this.gradient, this.badgeGradient, this.ctaGradient});

  static _Palette forOption(OfferCardOption option) {
    switch (option) {
      case OfferCardOption.dark:
        return const _Palette(
          background: Color(0xFF141311),
          foreground: Color(0xFFFAFAF7),
          secondary: Color(0xFFD4D0C8),
          border: Color(0x22FFFFFF),
          badgeBackground: Color(0xFFFF482E),
          badgeText: Color(0xFFFFF9ED),
          badgeBorder: Color(0x25FFFFFF),
          decoration: Color(0xFFFFBA39),
          timerBackground: Color(0x4D2B2620),
          timerText: Color(0xFFF8F7F2),
          timerBorder: Color(0x40C1B19A),
          ctaBackground: Color(0xFF1F3320),
          ctaText: Color(0xFFA3E58C),
          ctaBorder: Color(0xFF4C6240),
          logoBackground: Color(0xFF2E3326),
          logoBorder: Color(0x55FFFFFF),
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [Color(0xFF0F0E0D), Color(0xFF1D1A16), Color(0xFF2E2922)],
            stops: [0, 0.55, 1.0],
          ),
          badgeGradient: LinearGradient(colors: [Color(0xFFFF5534), Color(0xFFFF4028)]),
          ctaGradient: LinearGradient(colors: [Color(0xFF1E3A20), Color(0xFF112613)]),
        );
      case OfferCardOption.white:
        return const _Palette(
          background: Color(0xFFFFF9F3),
          foreground: Color(0xFF240B06),
          secondary: Color(0xFF825D52),
          border: Color(0xFFEEE5DC),
          badgeBackground: Color(0xFFFFD7CA),
          badgeText: Color(0xFFA81109),
          badgeBorder: Colors.transparent,
          decoration: Color(0xFFFF6244),
          timerBackground: Color(0xFFFFEAE1),
          timerText: Color(0xFFBA140E),
          timerBorder: Color(0xFFFFD1C4),
          ctaBackground: Color(0xFFDDEFD0),
          ctaText: Color(0xFF084C38),
          ctaBorder: Colors.transparent,
          logoBackground: Color(0xFFF0E3D7),
          logoBorder: Color(0xFFE1D4C8),
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [Color(0xFFFFF4EC), Color(0xFFFFFBF7), Color(0xFFFFEDE1)],
            stops: [0, 0.55, 1.0],
          ),
          badgeGradient: LinearGradient(colors: [Color(0xFFFFDCD0), Color(0xFFFFD3C6)]),
        );
      case OfferCardOption.gradient:
        return const _Palette(
          background: Color(0xFFF1473F),
          foreground: Color(0xFFFFFCF5),
          secondary: Color(0xFFFFF6E9),
          border: Color(0x16FFFFFF),
          badgeBackground: Color(0xFFFFF4E7),
          badgeText: Color(0xFFDD1744),
          badgeBorder: Color(0xAAFFFFFF),
          decoration: Color(0xFFFFF7E8),
          timerBackground: Color(0xBB7A120D),
          timerText: Color(0xFFFFF7EF),
          timerBorder: Color(0x16FFFFFF),
          ctaBackground: Color(0xFF790D0C),
          ctaText: Color(0xFFFFDDC9),
          ctaBorder: Color(0x1877080F),
          logoBackground: Color(0xFF176347),
          logoBorder: Color(0x33FFFFFF),
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [Color(0xFFD71D49), Color(0xFFFF5539), Color(0xFFFFA348)],
            stops: [0, 0.53, 1],
          ),
          ctaGradient: LinearGradient(colors: [Color(0xFF8F101D), Color(0xFF721009)]),
        );
    }
  }
}

class _OfferSkeletonCard extends StatelessWidget {
  const _OfferSkeletonCard();
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Loading offers',
    child: LayoutBuilder(builder: (context, c) {
      final s = c.maxWidth / 320;
      return DecoratedBox(
        decoration: BoxDecoration(color: const Color(0xFFF1EFEC),
            borderRadius: BorderRadius.circular(22 * s)),
        child: Stack(children: [
          Positioned(top: 15 * s, left: 15 * s, child: _bar(120 * s, 32 * s)),
          Positioned(top: 60 * s, left: 18 * s, child: _bar(170 * s, 20 * s)),
          Positioned(top: 85 * s, left: 18 * s, child: _bar(130 * s, 20 * s)),
          Positioned(bottom: 49 * s, left: 18 * s, child: _bar(144 * s, 24 * s)),
          Positioned(bottom: 8 * s, left: 15 * s, child: _bar(126 * s, 28 * s)),
        ]),
      );
    }),
  );
  Widget _bar(double width, double height) => Container(width: width, height: height,
    decoration: BoxDecoration(color: const Color(0xFFE4E0DB),
        borderRadius: BorderRadius.circular(7)));
}