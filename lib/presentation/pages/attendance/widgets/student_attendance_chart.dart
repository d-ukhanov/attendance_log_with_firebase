// Flutter imports:
// Project imports:
import 'package:attendance_log_with_firebase/core/domain/models/student.dart';

// Package imports:
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class StudentAttendanceChart extends StatelessWidget {
  final List<charts.Series<StudentStates, String>> seriesList;
  final bool animate;

  const StudentAttendanceChart(this.seriesList, {required this.animate});

  factory StudentAttendanceChart.withSampleData(dataOfStudent) {
    return StudentAttendanceChart(
      _createSampleData(dataOfStudent),
      animate: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return charts.PieChart<String>(
      seriesList,
      animate: animate,
      defaultRenderer: charts.ArcRendererConfig(
        arcWidth: 15,
        arcRendererDecorators: [
          charts.ArcLabelDecorator(
            showLeaderLines: false,
            outsideLabelStyleSpec: const charts.TextStyleSpec(fontSize: 18),
            labelPosition: charts.ArcLabelPosition.outside,
          )
        ],
      ),
      behaviors: [
        charts.DatumLegend(
          position: charts.BehaviorPosition.bottom,
          outsideJustification: charts.OutsideJustification.middleDrawArea,
          horizontalFirst: false,
          cellPadding: const EdgeInsets.only(right: 4.0, bottom: 10.0),
          showMeasures: true,
          desiredMaxColumns: 1,
          desiredMaxRows: 3,
          legendDefaultMeasure: charts.LegendDefaultMeasure.firstValue,
          measureFormatter: (num? value) {
            return value == null ? '-' : '$value';
          },
          entryTextStyle: const charts.TextStyleSpec(
            color: charts.MaterialPalette.black,
            fontFamily: 'Roboto',
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  static List<charts.Series<StudentStates, String>> _createSampleData(
    dataOfStudent,
  ) {
    final List<StudentStates> data = [];
    data.addAll(dataOfStudent);

    return [
      charts.Series<StudentStates, String>(
        id: 'States',
        domainFn: (StudentStates state, _) => state.typeState,
        measureFn: (StudentStates state, _) => state.countStates,
        colorFn: (StudentStates state, _) => state.color,
        labelAccessorFn: (StudentStates state, _) =>
            state.countStates.toString(),
        data: data,
      )
    ];
  }
}
