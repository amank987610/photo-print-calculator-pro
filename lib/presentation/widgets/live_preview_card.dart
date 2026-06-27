import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/app_formatters.dart';
import '../../core/utils/calculator_engine.dart';
import '../../core/constants/app_constants.dart';

/// The "beautiful summary card" required by spec - shows every input +
/// derived value at a glance, updating live as the user types.
class LivePreviewCard extends StatelessWidget {
  final double width;
  final double height;
  final LengthUnit unit;
  final AreaResult area;
  final double rate;
  final double quantity;
  final bool gstEnabled;
  final double gstPercent;
  final PriceResult price;
  final String currencySymbol;

  const LivePreviewCard({
    super.key,
    required this.width,
    required this.height,
    required this.unit,
    required this.area,
    required this.rate,
    required this.quantity,
    required this.gstEnabled,
    required this.gstPercent,
    required this.price,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryNavy, Color(0xFF1565C0)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'LIVE PREVIEW',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${AppFormatters.decimal2(width)} x ${AppFormatters.decimal2(height)} ${unit.shortLabel}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _statTile('Sq. Inch', AppFormatters.decimal2(area.sqInch)),
              _divider(),
              _statTile('Sq. Feet', AppFormatters.decimal3(area.sqFeet)),
              _divider(),
              _statTile('Sq. Meter', AppFormatters.decimal3(area.sqMeter)),
            ],
          ),
          const SizedBox(height: 18),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.15)),
          const SizedBox(height: 16),
          _row('Rate / Sq.Ft', AppFormatters.currency(rate, currencySymbol)),
          const SizedBox(height: 6),
          _row('Quantity', AppFormatters.decimal2(quantity)),
          const SizedBox(height: 6),
          _row('Subtotal', AppFormatters.currency(price.subtotal, currencySymbol)),
          if (gstEnabled) ...[
            const SizedBox(height: 6),
            _row(
              'GST (${AppFormatters.decimal2(gstPercent)}%)',
              AppFormatters.currency(price.gstAmount, currencySymbol),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'GRAND TOTAL',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
              Text(
                AppFormatters.currency(price.grandTotal, currencySymbol),
                style: const TextStyle(
                  color: AppColors.accentOrange,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 36,
        color: Colors.white.withValues(alpha: 0.2),
        margin: const EdgeInsets.symmetric(horizontal: 10),
      );

  Widget _statTile(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
