import 'dart:math' as math;

import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFFF7F2E1);
  static const panel = Color(0xFFF8F3E4);
  static const mainSurface = Color(0xFFFFFDF5);
  static const border = Color(0xFFDED7C5);
  static const text = Color(0xFF687985);
  static const textDark = Color(0xFF566A77);
  static const icon = Color(0xFF87949D);
  static const subtle = Color(0xFFEFE9D8);
  static const accent = Color(0xFFAA4C89);
  static const connectionDot = Color(0xFFB996ED);
}

class EstimatorDesktopPage extends StatefulWidget {
  const EstimatorDesktopPage({super.key});

  @override
  State<EstimatorDesktopPage> createState() => _EstimatorDesktopPageState();
}

class _EstimatorDesktopPageState extends State<EstimatorDesktopPage> {
  String selectedTable = '';
  bool visualTab = true;
  bool rightPanelExpanded = true;
  double leftSidebarWidth = 260;
  double rightPanelWidth = 360;

  final tables = const ['items', 'loas', 'rates'];

  static const _minLeftSidebarWidth = 180.0;
  static const _maxLeftSidebarWidth = 420.0;
  static const _minRightPanelWidth = 240.0;
  static const _maxRightPanelWidth = 560.0;
  static const _minMainAreaWidth = 320.0;
  static const _resizeHandleWidth = 8.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final rightWidth = rightPanelExpanded ? rightPanelWidth : 54.0;
          final maxLeftWidth = math.min(
            _maxLeftSidebarWidth,
            math.max(
              _minLeftSidebarWidth,
              constraints.maxWidth - rightWidth - _minMainAreaWidth - _resizeHandleWidth * 2,
            ),
          );
          final leftWidth = leftSidebarWidth.clamp(_minLeftSidebarWidth, maxLeftWidth).toDouble();
          final maxRightWidth = math.min(
            _maxRightPanelWidth,
            math.max(
              _minRightPanelWidth,
              constraints.maxWidth - leftWidth - _minMainAreaWidth - _resizeHandleWidth * 2,
            ),
          );
          final visibleRightWidth = rightPanelExpanded
              ? rightPanelWidth.clamp(_minRightPanelWidth, maxRightWidth).toDouble()
              : rightWidth;
          final topHeight = 74.0;

          return Column(
            children: [
              SizedBox(height: topHeight, child: _TopBar()),
              Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      width: leftWidth,
                      child: _LeftSidebar(
                        tables: tables,
                        selectedTable: selectedTable,
                        onSelectTable: (table) {
                          setState(() => selectedTable = table);
                        },
                      ),
                    ),
                    _ResizeHandle(
                      onDrag: (delta) {
                        setState(() {
                          leftSidebarWidth = (leftWidth + delta).clamp(_minLeftSidebarWidth, maxLeftWidth).toDouble();
                        });
                      },
                    ),
                    Expanded(child: _MainArea(selectedTable: selectedTable)),
                    if (rightPanelExpanded)
                      _ResizeHandle(
                        onDrag: (delta) {
                          setState(() {
                            rightPanelWidth = (visibleRightWidth - delta)
                                .clamp(_minRightPanelWidth, maxRightWidth)
                                .toDouble();
                          });
                        },
                      ),
                    SizedBox(
                      width: visibleRightWidth,
                      child: _RightPanel(
                        expanded: rightPanelExpanded,
                        visualTab: visualTab,
                        onToggleExpanded: () {
                          setState(() {
                            rightPanelExpanded = !rightPanelExpanded;
                          });
                        },
                        onTabChanged: (visual) {
                          setState(() => visualTab = visual);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ResizeHandle extends StatelessWidget {
  final ValueChanged<double> onDrag;

  const _ResizeHandle({required this.onDrag});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeLeftRight,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (details) => onDrag(details.delta.dx),
        child: SizedBox(
          width: _EstimatorDesktopPageState._resizeHandleWidth,
          child: Center(
            child: Container(width: 1, color: AppColors.border),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.panel,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          _TopMenuText('File'),
          _TopMenuText('Edit'),
          _TopMenuText('View'),
          _TopMenuText('Help'),
          const SizedBox(width: 14),
          const Icon(Icons.bolt_rounded, size: 16, color: Color(0xFF6D9FB5)),
          const SizedBox(width: 8),
          const Text(
            'Estimator Connection',
            style: TextStyle(fontSize: 13, color: AppColors.textDark, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 16),
          Icon(Icons.chevron_left_rounded, color: AppColors.icon, size: 18),
          const Spacer(),
          SizedBox(width: 340, height: 50, child: _CommandSearch()),
          const Spacer(),
          _ChangesBadge(),
          const SizedBox(width: 10),
          _ToolbarIcon(Icons.save_outlined),
          _ToolbarIcon(Icons.book_outlined),
          _ToolbarIcon(Icons.vertical_align_top_rounded),
          _ToolbarIcon(Icons.account_tree_outlined),
          _ToolbarIcon(Icons.diamond_outlined),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class _TopMenuText extends StatelessWidget {
  final String text;

  const _TopMenuText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Text(text, style: const TextStyle(fontSize: 13, color: Color(0xFF53616A))),
    );
  }
}

class _CommandSearch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFBF6E9),
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 19, color: AppColors.icon),
          const SizedBox(width: 10),
          const Expanded(
            child: Text('Search or run commands...', style: TextStyle(fontSize: 13, color: AppColors.text)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF0EBD9),
              border: Border.all(color: const Color(0xFFE0D7C4)),
              borderRadius: BorderRadius.circular(5),
            ),
            child: const Text('Ctrl+K', style: TextStyle(fontSize: 10, color: AppColors.text)),
          ),
        ],
      ),
    );
  }
}

class _ChangesBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EDDC),
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Changes', style: TextStyle(fontSize: 12, color: Color(0xFF858F94))),
          const SizedBox(width: 8),
          Container(
            width: 21,
            height: 21,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: Color(0xFFEAE5D9), shape: BoxShape.circle),
            child: const Text('0', style: TextStyle(fontSize: 10, color: Color(0xFF9AA1A4))),
          ),
        ],
      ),
    );
  }
}

class _ToolbarIcon extends StatelessWidget {
  final IconData icon;

  const _ToolbarIcon(this.icon);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7),
      child: Icon(icon, size: 18, color: AppColors.icon),
    );
  }
}

class _LeftSidebar extends StatelessWidget {
  final List<String> tables;
  final String selectedTable;
  final ValueChanged<String> onSelectTable;

  const _LeftSidebar({required this.tables, required this.selectedTable, required this.onSelectTable});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.panel,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                const Icon(Icons.storage_outlined, size: 17, color: AppColors.icon),
                const Spacer(),
                const Icon(Icons.refresh_rounded, size: 18, color: AppColors.icon),
                const SizedBox(width: 18),
                const Icon(Icons.add_rounded, size: 19, color: AppColors.icon),
                const SizedBox(width: 17),
                const Icon(Icons.search_rounded, size: 18, color: AppColors.icon),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.only(left: 55),
            child: Row(
              children: [
                Text(
                  'A-Z',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark),
                ),
                SizedBox(width: 24),
                Text('Tags', style: TextStyle(fontSize: 12, color: AppColors.text)),
              ],
            ),
          ),
          const SizedBox(height: 11),
          const Divider(indent: 55, endIndent: 174, height: 1, color: Color(0xFFBDC1BE)),
          const SizedBox(height: 18),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                for (final table in tables)
                  _TableTile(name: table, selected: selectedTable == table, onTap: () => onSelectTable(table)),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: Row(
              children: [
                Icon(Icons.home_outlined, size: 18, color: AppColors.icon),
                Spacer(),
                Icon(Icons.settings_outlined, size: 18, color: AppColors.icon),
                SizedBox(width: 24),
                CircleAvatar(
                  radius: 10,
                  backgroundColor: AppColors.accent,
                  child: Text(
                    'S',
                    style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TableTile extends StatelessWidget {
  final String name;
  final bool selected;
  final VoidCallback onTap;

  const _TableTile({required this.name, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFF0E9D8) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        hoverColor: const Color(0xFFF2ECDE),
        child: SizedBox(
          height: 42,
          child: Row(
            children: [
              const SizedBox(width: 20),
              const Icon(Icons.chevron_right_rounded, size: 15, color: AppColors.icon),
              const SizedBox(width: 12),
              const Icon(Icons.table_chart_outlined, size: 16, color: AppColors.icon),
              const SizedBox(width: 10),
              Text(name, style: const TextStyle(fontSize: 13, color: AppColors.text)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MainArea extends StatelessWidget {
  final String selectedTable;

  const _MainArea({required this.selectedTable});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.mainSurface,
      alignment: Alignment.center,
      child: selectedTable.isEmpty
          ? const Text('Select a table to view its data', style: TextStyle(fontSize: 14, color: Color(0xFF8998A1)))
          : _TablePreview(tableName: selectedTable),
    );
  }
}

class _TablePreview extends StatelessWidget {
  final String tableName;

  const _TablePreview({required this.tableName});

  @override
  Widget build(BuildContext context) {
    // Simple editable placeholder for the selected-table state.
    return SizedBox(
      width: 700,
      height: 250,
      child: Card(
        elevation: 0,
        color: const Color(0xFFFCF8EB),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tableName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark),
              ),
              const SizedBox(height: 14),
              const Text(
                'Table selected. Replace this widget with your editable '
                'data grid or table view.',
                style: TextStyle(fontSize: 13, color: AppColors.text),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RightPanel extends StatelessWidget {
  final bool expanded;
  final bool visualTab;
  final VoidCallback onToggleExpanded;
  final ValueChanged<bool> onTabChanged;

  const _RightPanel({
    required this.expanded,
    required this.visualTab,
    required this.onToggleExpanded,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (!expanded) {
      return Container(
        decoration: const BoxDecoration(
          color: AppColors.panel,
          border: Border(left: BorderSide(color: AppColors.border)),
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: IconButton(
            tooltip: 'Expand',
            onPressed: onToggleExpanded,
            icon: const Icon(Icons.chevron_left_rounded),
            color: AppColors.icon,
          ),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.panel,
        border: Border(left: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 26),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Pending Changes',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text),
                  ),
                ),
                IconButton(
                  tooltip: 'Collapse',
                  splashRadius: 17,
                  onPressed: onToggleExpanded,
                  icon: const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.icon),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Row(
              children: [
                _PanelTab(label: 'Visual', selected: visualTab, onTap: () => onTabChanged(true)),
                _PanelTab(label: 'SQL', selected: !visualTab, onTap: () => onTabChanged(false)),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                visualTab ? 'No pending changes' : 'SQL preview is empty',
                style: const TextStyle(fontSize: 14, color: Color(0xFF8998A1)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PanelTab({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFF0EADC) : Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: selected ? AppColors.textDark : AppColors.text,
              fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
