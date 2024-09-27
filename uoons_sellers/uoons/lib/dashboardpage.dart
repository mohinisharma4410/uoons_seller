import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DashboardPage extends StatelessWidget {
  final List<String> labels1 = ['Total', 'Placed', 'Pending', 'Shipped', 'Successful'];
  final List<double> values1 = [90, 30, 20, 25, 15];

  final List<String> labels2 = ['Total', 'Placed', 'Pending', 'Shipped', 'Successful'];
  final List<double> values2 = [80, 40, 10, 15, 5];

  final List<String> labels3 = ['Total', 'Placed', 'Pending', 'Shipped', 'Successful'];
  final List<double> values3 = [70, 35, 25, 20, 10];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analytics'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 20),
            Text(
              'COD vs Pre-paid',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Container(
              height: 300,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: GestureDetector(
                  onTapUp: (TapUpDetails details) {
                    final RenderBox renderBox = context.findRenderObject() as RenderBox;
                    final dynamic value = details.localPosition.dx;
                    final dynamic index = (value / (renderBox.size.width / labels1.length)).floor();
                    final double tappedValue = values1[index];

                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(labels1[index]),
                          content: Text('Value: $tappedValue'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Close'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Container(
                    width: 600,
                    child: SfCartesianChart(
                      primaryXAxis: CategoryAxis(),
                      series: <ChartSeries>[
                        BarSeries<ChartData, String>(
                          dataSource: getChartData(labels1, values1),
                          xValueMapper: (ChartData data, _) => data.label,
                          yValueMapper: (ChartData data, _) => data.value,
                          pointColorMapper: (ChartData data, _) => getGradientColor(data.label),
                          animationDuration: 2000, // Animation duration in milliseconds
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Views on each product',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Column(
              children: [
                Container(
                  height: 300,
                  child: SfCircularChart(
                    series: <CircularSeries>[
                      DoughnutSeries<ChartData, String>(
                        dataSource: getChartData(labels2, values2),
                        xValueMapper: (ChartData data, _) => data.label,
                        yValueMapper: (ChartData data, _) => data.value,
                        pointColorMapper: (ChartData data, _) => getDoughnutColor(data.label),
                        dataLabelSettings: DataLabelSettings(isVisible: true),
                        animationDuration: 2000, // Animation duration in milliseconds
                        selectionBehavior: SelectionBehavior(enable: true),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                DataTable(
                  columns: [
                    DataColumn(label: Text('Item')),
                    DataColumn(label: Text('Color')),
                  ],
                  rows: [
                    DataRow(cells: [
                      DataCell(Text('Total')),
                      DataCell(Container(
                        width: 20,
                        height: 20,
                        color: getDoughnutColor('Total'),
                      )),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Placed')),
                      DataCell(Container(
                        width: 20,
                        height: 20,
                        color: getDoughnutColor('Placed'),
                      )),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Pending')),
                      DataCell(Container(
                        width: 20,
                        height: 20,
                        color: getDoughnutColor('Pending'),
                      )),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Shipped')),
                      DataCell(Container(
                        width: 20,
                        height: 20,
                        color: getDoughnutColor('Shipped'),
                      )),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Successful')),
                      DataCell(Container(
                        width: 20,
                        height: 20,
                        color: getDoughnutColor('Successful'),
                      )),
                    ]),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Product Sales',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Container(
              height: 300,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  width: 600,
                  child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(),
                    series: <ChartSeries>[
                      BarSeries<ChartData, String>(
                        dataSource: getChartData(labels3, values3),
                        xValueMapper: (ChartData data, _) => data.label,
                        yValueMapper: (ChartData data, _) => data.value,
                        animationDuration: 2000, // Animation duration in milliseconds
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<ChartData> getChartData(List<String> labels, List<double> values) {
    List<ChartData> chartData = [];
    for (int i = 0; i < labels.length; i++) {
      chartData.add(ChartData(labels[i], values[i]));
    }
    return chartData;
  }

  Color getDoughnutColor(String label) {
    switch (label) {
      case 'Total':
        return Colors.purple.shade900; // Default color if no gradient is available
      case 'Placed':
        return Colors.deepOrange.shade900;
      case 'Pending':
        return Colors.red.shade900;
      case 'Shipped':
        return Colors.blue.shade900;
      case 'Successful':
        return Colors.green.shade900;
      default:
        return Colors.grey;
    }
  }

  Color applyGradient(Color startColor, Color endColor, double value) {
    return Color.lerp(startColor, endColor, value)!;
  }

  // This method will provide gradient colors for each segment
  Color getGradientColor(String label) {
    List<List<Color>> gradientColors = [
      [Color.fromARGB(255, 255, 129, 3), Color.fromARGB(255, 253, 253, 66)], // Gradient colors for Column Chart
    ];

    // Always return the gradient color for the Column Chart
    return applyGradient(gradientColors[0][0], gradientColors[0][1], 0.5);
  }
}

class ChartData {
  ChartData(this.label, this.value);
  final String label;
  final double value;
}
