import 'package:flutter/material.dart';

import '../models/race_result.dart';
import '../theme/app_theme.dart';

const _posWidth = 30.0;
const _timeWidth = 96.0;
const _ptsWidth = 30.0;

/// La clasificación completa de una carrera: POS · PILOTO · TIEMPO · PTS.
class ResultTable extends StatelessWidget {
  const ResultTable({super.key, required this.results});

  final List<RaceResult> results;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.avatar),
      ),
      child: Column(
        children: [
          const _HeaderRow(),
          for (final r in results) _ResultRow(result: r),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.9,
      color: AppColors.textMuted,
    );
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: const Row(
        spacing: 8,
        children: [
          SizedBox(
            width: _posWidth,
            child: Text('POS', style: style),
          ),
          Expanded(child: Text('PILOTO', style: style)),
          SizedBox(
            width: _timeWidth,
            child: Text('TIEMPO', textAlign: TextAlign.right, style: style),
          ),
          SizedBox(
            width: _ptsWidth,
            child: Text('PTS', textAlign: TextAlign.right, style: style),
          ),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.result});

  final RaceResult result;

  @override
  Widget build(BuildContext context) {
    final r = result;
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.avatar)),
      ),
      child: Row(
        spacing: 8,
        children: [
          SizedBox(
            width: _posWidth,
            child: Text(
              r.positionText,
              maxLines: 1,
              softWrap: false,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Row(
              spacing: 8,
              children: [
                Container(
                  width: 3,
                  height: 28,
                  decoration: BoxDecoration(
                    color: teamColor(r.teamId),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.driverName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        r.teamName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: _timeWidth,
            child: Text(
              r.time ?? r.status,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: r.time == null
                    ? AppColors.textMuted
                    : AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(
            width: _ptsWidth,
            child: Text(
              r.pointsLabel,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
