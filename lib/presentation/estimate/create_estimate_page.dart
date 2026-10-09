import 'dart:io';
import 'dart:math' as math;

import 'package:estimator/common/presentations/styles/theme.dart';
import 'package:estimator/common/utils/debouncer.dart';
import 'package:estimator/common/widgets/divider.dart';
import 'package:estimator/common_libs.dart';
import 'package:estimator/database/repository.dart';
import 'package:estimator/model/estimate_model.dart';
import 'package:estimator/model/item_model.dart';
import 'package:estimator/model/loa_model.dart';
import 'package:estimator/model/rate_model.dart';

import 'cubit/create_estimate_cubit.dart';

import 'package:excel_plus/excel_plus.dart' hide Border;
import 'package:path/path.dart' as p;

part 'widgets/item_picker.dart';

class CreateEstimatePage extends StatelessWidget {
  const CreateEstimatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => CreateEstimateCubit(), child: _CreateEstimatePageContent());
  }
}

class _CreateEstimatePageContent extends StatefulWidget {
  const _CreateEstimatePageContent({super.key});

  @override
  State<_CreateEstimatePageContent> createState() => _CreateEstimatePageContentState();
}

class _CreateEstimatePageContentState extends State<_CreateEstimatePageContent> {
  bool visualTab = true;
  double leftSidebarWidth = 260;
  double rightPanelWidth = 360;

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
          final rightWidth = rightPanelWidth;
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
          final visibleRightWidth = rightPanelWidth.clamp(_minRightPanelWidth, maxRightWidth).toDouble();

          return Column(
            children: <Widget>[
              _TopBar(),

              Expanded(
                child: Row(
                  children: [
                    SizedBox(width: leftWidth, child: _LeftSection()),

                    _ResizeHandle(
                      onDrag: (delta) {
                        setState(() {
                          leftSidebarWidth = (leftWidth + delta).clamp(_minLeftSidebarWidth, maxLeftWidth).toDouble();
                        });
                      },
                    ),

                    Expanded(
                      child: BlocBuilder<CreateEstimateCubit, CreateEstimateState>(
                        builder: (context, state) {
                          return _MainArea(selectedItem: state.selectedItem);
                        },
                      ),
                    ),

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
                        visualTab: visualTab,
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

class _TopBar extends StatelessWidget {
  const _TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          spacing: 16.0,
          children: <Widget>[
            Expanded(
              child: Text(
                'Provision of Centre of Excellence at Shop 29 B/APP-1, 29 B/App-II & Shop 20 Air Brake section at Carriage Complex',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // SizedBox(width: 340, height: 50, child: _CommandSearch()),
            _ChangesBadge(),
          ],
        ),
      ),
    );
  }
}

class _TopMenuText extends StatelessWidget {
  final String text;

  const _TopMenuText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text(text));
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
          width: _CreateEstimatePageContentState._resizeHandleWidth,
          child: Center(child: Container(width: 1, color: AppColors.border)),
        ),
      ),
    );
  }
}

class _LeftSection extends StatelessWidget {
  const _LeftSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CreateEstimateCubit>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Column(
        spacing: 16.0,
        children: <Widget>[
          // ~ Call to actions buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 4.0,
            children: <Widget>[
              Text('Items', style: TextStyle(color: context.theme.disabledColor)),
              Spacer(),
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(8.0)),
                      constraints: BoxConstraints(minWidth: 640.0, maxWidth: 640.0, minHeight: 500.0, maxHeight: 500.0),
                      child: _ItemPicker(),
                    ),
                  );
                },
                icon: const Icon(Icons.add_rounded, color: AppColors.icon),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.search_rounded, color: AppColors.icon),
              ),
            ],
          ),

          // ~ Items
          Expanded(
            child: BlocBuilder<CreateEstimateCubit, CreateEstimateState>(
              builder: (context, state) {
                final items = state.items;
                return ListView.separated(
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _ItemTileView(
                      item: item,
                      isSelected: state.selectedItem == item,
                      onTap: () => cubit.updateSelectedItem(item),
                    );
                  },
                  itemCount: items.length,
                  separatorBuilder: (context, index) => SizedBox(height: 8.0),
                );
              },
            ),
          ),

          // ~ Summery
          Row(
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
        ],
      ),
    );
  }
}

class _ItemTileView extends StatelessWidget {
  final EstimateItem item;
  final bool isSelected;
  final VoidCallback? onTap;

  const _ItemTileView({required this.item, required this.isSelected, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? const Color(0xFFF0E9D8) : Colors.transparent,
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
              Text(item.item.name, style: const TextStyle(fontSize: 13, color: AppColors.text)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MainArea extends StatelessWidget {
  final EstimateItem? selectedItem;

  const _MainArea({this.selectedItem});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.mainSurface,
      alignment: Alignment.center,
      child: selectedItem == null
          ? const Text('Select a table to view its data', style: TextStyle(fontSize: 14, color: Color(0xFF8998A1)))
          : _TablePreview(tableName: selectedItem!.item.description),
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
  final bool visualTab;
  final ValueChanged<bool> onTabChanged;

  const _RightPanel({required this.visualTab, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 26),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            'Pending Changes',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text),
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

void exportToExcel() async {
  // Dummy data
  final estimate = Estimate(
    id: 'this-is-dummy-estimate',
    number: 'KPA/EG/26-27/01/DSE/CAP/PH-42/CWMLS dated 07.10.2025',
    name: 'Provision of Centre of Excellence at Shop 29 B/APP-1, 29 B/App-II & Shop 20 Air Brake section at Carriage Complex',
    items: <EstimateItem>[
      EstimateItem(
        id: '8649df70-bd8e-11f1-a76a-37da4ed8df4d',
        item: EstimatorItem(
          id: '8649df70-bd8e-11f1-a76a-37da4ed8df4d',
          name: 'HT 11kV cable: 3 x 150sqmm',
          description: 'Supply of XLPE insulated, PVC outer sheathed, galvanized steel wire armoured HT 3 core 150 sq.mm Aluminum conductor cable of 11kV grade having ISI marked & conforming to IS:7098 (Part-2) of latest amendment',
          unit: 'mtr',
        ),
        description: 'Supply of XLPE insulated, PVC outer sheathed, galvanized steel wire armoured HT 3 core 150 sq.mm Aluminum conductor cable of 11kV grade having ISI marked & conforming to IS:7098 (Part-2) of latest amendment',
        quantity: 500,
        rates: <EstimatorRate>[
          EstimatorRate(
            id: 'rate-id-1',
            item: EstimatorItem(
              id: '8649df70-bd8e-11f1-a76a-37da4ed8df4d',
              name: 'HT 11kV cable: 3 x 150sqmm',
              description: 'Supply of XLPE insulated, PVC outer sheathed, galvanized steel wire armoured HT 3 core 150 sq.mm Aluminum conductor cable of 11kV grade having ISI marked & conforming to IS:7098 (Part-2) of latest amendment',
              unit: 'mtr',
            ),
            loa: EstimatorLoa(
              id: 'a961c2e0-bd91-11f1-a76a-37da4ed8df4d',
              number: 'GEMC-511687787515390',
              date: DateTime.fromMillisecondsSinceEpoch(1788134400 * 1000),
            ),
            materialTenderRate: 1450,
          ),

          EstimatorRate(
            id: 'rate-id-2',
            item: EstimatorItem(
              id: '8649df70-bd8e-11f1-a76a-37da4ed8df4d',
              name: 'HT 11kV cable: 3 x 150sqmm',
              description: 'Supply of XLPE insulated, PVC outer sheathed, galvanized steel wire armoured HT 3 core 150 sq.mm Aluminum conductor cable of 11kV grade having ISI marked & conforming to IS:7098 (Part-2) of latest amendment',
              unit: 'mtr',
            ),
            loa: EstimatorLoa(
              id: 'da873e40-bd91-11f1-a76a-37da4ed8df4d',
              number: 'GEMC-511687752505249',
              date: DateTime.fromMillisecondsSinceEpoch(1788134400 * 1000),
            ),
            materialTenderRate: 1450,
          ),

          EstimatorRate(
            id: 'rate-id-3',
            item: EstimatorItem(
              id: '8649df70-bd8e-11f1-a76a-37da4ed8df4d',
              name: 'HT 11kV cable: 3 x 150sqmm',
              description: 'Supply of XLPE insulated, PVC outer sheathed, galvanized steel wire armoured HT 3 core 150 sq.mm Aluminum conductor cable of 11kV grade having ISI marked & conforming to IS:7098 (Part-2) of latest amendment',
              unit: 'mtr',
            ),
            loa: EstimatorLoa(
              id: 'e5b136e0-bd91-11f1-a76a-37da4ed8df4d',
              number: 'GEMC-511687733447515',
              date: DateTime.fromMillisecondsSinceEpoch(1776211200 * 1000),
            ),
            materialTenderRate: 1450,
          ),
        ],
      ),
    ],
  );

  // Excel related
  final excel = Excel.createExcel()..rename('Sheet1', 'Est'); // a new workbook with one default sheet
  // final cellstyle = CellStyle(
  //   leftBorder: Border(borderStyle: BorderStyle.Thin),
  //   rightBorder: Border(borderStyle: BorderStyle.Thin),
  //   topBorder: Border(borderStyle: BorderStyle.Medium),
  //   bottomBorder: Border(borderStyle: BorderStyle.Medium, borderColorHex: ExcelColor.red),
  // );
  final estSheet = excel['Est'];

  // ~ Header Row
  estSheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('A3'), customValue: TextCellValue('Sl.\nNo.'));
  estSheet.merge(
    CellIndex.indexByString('B1'),
    CellIndex.indexByString('B3'),
    customValue: TextCellValue('Description'),
  );
  estSheet.merge(CellIndex.indexByString('C1'), CellIndex.indexByString('C3'), customValue: TextCellValue('Qnty'));
  estSheet.merge(CellIndex.indexByString('D1'), CellIndex.indexByString('D3'), customValue: TextCellValue('Unit'));
  estSheet.merge(
    CellIndex.indexByString('E1'),
    CellIndex.indexByString('E3'),
    customValue: TextCellValue('Unit Rate\nincluding\nGST (Rs.)'),
  );
  estSheet.merge(
    CellIndex.indexByString('F1'),
    CellIndex.indexByString('H1'),
    customValue: TextCellValue('Total Cost including GST (Rs.)'),
  );
  estSheet.merge(CellIndex.indexByString('F2'), CellIndex.indexByString('F3'), customValue: TextCellValue('Cash'));
  estSheet.merge(CellIndex.indexByString('G2'), CellIndex.indexByString('H2'), customValue: TextCellValue('Stores'));
  estSheet.updateCell(CellIndex.indexByString('G3'), TextCellValue('Purchase'));
  estSheet.updateCell(CellIndex.indexByString('H3'), TextCellValue('Stock'));
  estSheet.merge(
    CellIndex.indexByString('I1'),
    CellIndex.indexByString('I3'),
    customValue: TextCellValue('Grand Total\nincluding GST\n(Rs.)'),
  );
  estSheet.merge(
    CellIndex.indexByString('J1'),
    CellIndex.indexByString('L3'),
    customValue: TextCellValue('Rate Reference'),
  );

  // ~ Items
  final items = estimate.items;
  int rowIndex = 8;

  for (int i = 0; i < items.length; i++) {
    final item = items[i];
    final rates = item.rates;

    // Sl. No.
    estSheet.updateCell(CellIndex.indexByString('A$rowIndex'), IntCellValue(1)); // TODO:
    // Qnty
    estSheet.updateCell(CellIndex.indexByString('C$rowIndex'), DoubleCellValue(item.quantity));

    if (rates.length > 1) {
      final endRowIndex = rowIndex + rates.length + 1;
      // Sl. No.
      estSheet.merge(CellIndex.indexByString('A$rowIndex'), CellIndex.indexByString('A$endRowIndex'));
      // Description
      estSheet.merge(
        CellIndex.indexByString('B$rowIndex'),
        CellIndex.indexByString('B$endRowIndex'),
        customValue: TextCellValue(item.description),
      );
      // Qnty
      estSheet.merge(CellIndex.indexByString('C$rowIndex'), CellIndex.indexByString('C$endRowIndex'));
      // Unit
      estSheet.merge(
        CellIndex.indexByString('D$rowIndex'),
        CellIndex.indexByString('D$endRowIndex'),
        customValue: TextCellValue(item.item.unit),
      );
      // Rate
      estSheet.merge(
        CellIndex.indexByString('E$rowIndex'),
        CellIndex.indexByString('E$endRowIndex'),
        customValue: FormulaCellValue('L$endRowIndex'),
      );
      // Grand total
      estSheet.merge(
        CellIndex.indexByString('I$rowIndex'),
        CellIndex.indexByString('I$endRowIndex'),
        customValue: FormulaCellValue('IF(ISBLANK(C$rowIndex), "", ROUND(C$rowIndex * E$rowIndex, 2))'),
      );
      // Rates
      estSheet.updateCell(CellIndex.indexByString('K$rowIndex'), TextCellValue('LOA/PO No.'));
      estSheet.updateCell(CellIndex.indexByString('L$rowIndex'), TextCellValue('Rate'));
      for (int j = 0; j < rates.length; j++) {
        final rate = rates[j];
        final rateIndex = rowIndex + j + 1;
        estSheet.updateCell(CellIndex.indexByString('J$rateIndex'), TextCellValue('a)'));
        estSheet.updateCell(
          CellIndex.indexByString('K$rateIndex'),
          TextCellValue('${rate.loa.number} dated ${rate.loa.date.toReadable()}'),
        );
        estSheet.updateCell(
          CellIndex.indexByString('L$rateIndex'),
          DoubleCellValue(rate.materialTenderRate ?? rate.labourTenderRate ?? 0),
        );
      }
      estSheet.merge(
        CellIndex.indexByString('J$endRowIndex'),
        CellIndex.indexByString('K$endRowIndex'),
        customValue: TextCellValue('Average Rate'),
      );
      estSheet.updateCell(
        CellIndex.indexByString('L$endRowIndex'),
        FormulaCellValue('ROUND(AVERAGE(L${rowIndex + 1}:L${endRowIndex - 1}),2)'),
      );

      rowIndex = endRowIndex + 1;
    } else {
      rowIndex += 1;
    }
  }

  // sheet.updateCell(CellIndex.indexByString('B1'), IntCellValue(42));
  // sheet.updateCell(CellIndex.indexByString('D1'), BoolCellValue(true));
  // sheet.updateCell(CellIndex.indexByString('E1'), DateCellValue(year: 2026, month: 6, day: 9));
  // sheet.updateCell(CellIndex.indexByString('F1'), TimeCellValue(hour: 9, minute: 30, second: 0));
  // sheet.updateCell(
  //   CellIndex.indexByString('G1'),
  //   DateTimeCellValue(year: 2026, month: 6, day: 9, hour: 9, minute: 30),
  // );
  // sheet.updateCell(CellIndex.indexByString('H1'), FormulaCellValue('SUM(B1:C1)'));
  // sheet.updateCell(CellIndex.indexByString('C1'), DoubleCellValue(3.14));
  // sheet.cell(CellIndex.indexByString('I1')).setFormula('AVERAGE(B1:C1)');

  String? path = await FilePicker.getDirectoryPath();
  if (path == null || path.isEmpty) {
    return null;
  }
  final destFile = File(p.join(path, 'estimator-${DateTime.now().toUtc().millisecondsSinceEpoch}.xlsx'));

  destFile.writeAsBytesSync(excel.save()!);
}
