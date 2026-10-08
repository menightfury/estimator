import 'dart:io';

import 'package:estimator/common/utils/debouncer.dart';
import 'package:estimator/common_libs.dart' hide Border, BorderStyle;
import 'package:estimator/database/repository.dart';
import 'package:estimator/model/estimate_model.dart';
import 'package:estimator/model/item_model.dart';
import 'package:estimator/model/loa_model.dart';
import 'package:estimator/model/rate_model.dart';
import 'package:excel_plus/excel_plus.dart';
import 'package:path/path.dart' as p;

part 'widgets/item_picker.dart';

class CreateEstimatePage extends StatelessWidget {
  const CreateEstimatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Estimate Page')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 16.0,
          children: <Widget>[
            Expanded(
              child: Row(
                spacing: 16.0,
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: _LeftSection(
                      // items: _items,
                      // isSearching: _isSearching,
                      // hasQuery: _query.isNotEmpty,
                      // error: _searchError,
                    ),
                  ),
                  Expanded(flex: 3, child: _RightSection()),
                ],
              ),
            ),
            ElevatedButton(onPressed: exportToExcel, child: const Text('Export to Excel')),
          ],
        ),
      ),
    );
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
    estSheet.merge(
      CellIndex.indexByString('A1'),
      CellIndex.indexByString('A3'),
      customValue: TextCellValue('Sl.\nNo.'),
    );
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
}

class _LeftSection extends StatelessWidget {
  const _LeftSection(
    // {required this.items, required this.isSearching, required this.hasQuery, this.error}
  );

  // final List<ItemInDb> items;
  // final bool isSearching;
  // final bool hasQuery;
  // final String? error;

  @override
  Widget build(BuildContext context) {
    // if (error != null) {
    //   return Center(child: Text(error!, textAlign: TextAlign.center));
    // }
    // if (isSearching) {
    //   return const Center(child: CircularProgressIndicator());
    // }
    // if (items.isEmpty) {
    //   return Center(child: Text(hasQuery ? 'No matching items' : 'Type to search items'));
    // }

    return Column(
      children: <Widget>[
        ListTile(
          title: Text('Items'),
          subtitle: Text('12 items'),
          trailing: IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    child: Padding(padding: const EdgeInsets.all(8.0), child: _ItemSearch()),
                  );
                },
              );
            },
            icon: Icon(Icons.add_rounded),
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: 5,
            itemBuilder: (context, index) {
              final item = 'Item ${index + 1}';
              return ListTile(
                title: Text(item),
                subtitle: Text(item),
                tileColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              );
            },
            separatorBuilder: (_, _) => SizedBox(height: 8.0),
          ),
        ),
      ],
    );
  }
}

class _RightSection extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8.0,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Column(
            spacing: 8.0,
            children: <Widget>[
              TextField(decoration: InputDecoration(hintText: 'Description'), maxLines: 10),
              Row(
                spacing: 8.0,
                children: <Widget>[
                  Expanded(
                    child: TextField(decoration: InputDecoration(hintText: 'Quantity')),
                  ),
                  Expanded(
                    child: TextField(decoration: InputDecoration(hintText: 'Unit')),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(flex: 3, child: _RateSection()),
      ],
    );
  }
}

class _RateSection extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 10,
      itemBuilder: (context, index) {
        final item = 'Rate $index';
        return CheckboxListTile(
          value: false,
          onChanged: (value) {},
          title: Text(item),
          subtitle: Text(item),
          tileColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          controlAffinity: ListTileControlAffinity.leading,
        );
      },
      separatorBuilder: (_, _) => SizedBox(height: 8.0),
    );
  }
}
