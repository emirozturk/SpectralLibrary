import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:spectral_library/Models/spect_file.dart';

class DrawPlotPage extends StatefulWidget {
  final List<SpectFile> selectedFiles;

  const DrawPlotPage({required this.selectedFiles, super.key});

  @override
  _DrawPlotPageState createState() => _DrawPlotPageState();
}

class _DrawPlotPageState extends State<DrawPlotPage> {
  final ScreenshotController _screenshotController = ScreenshotController();
  double _minScale = 1.0;
  double _maxScale = 5.0;
  double _currentScale = 1.0;

  @override
  Widget build(BuildContext context) {
    List<LineChartBarData> getLineBarsData() {
      final List<LineChartBarData> lineBarsData = [];
      final List<Color> colors = [
        Colors.blue,
        Colors.red,
        Colors.green,
        Colors.orange,
        Colors.purple,
        Colors.cyan,
        Colors.brown,
      ];

      for (int i = 0; i < widget.selectedFiles.length; i++) {
        final file = widget.selectedFiles[i];
        final List<FlSpot> spots =
            file.dataPoints.map((data) => FlSpot(data.x, data.y)).toList();

        lineBarsData.add(
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 2,
            color: colors[i % colors.length],
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        );
      }
      return lineBarsData;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Interactive Plot'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Screenshot(
              controller: _screenshotController,
              child: Container(
                color: Colors
                    .white, // Ensure a white background for the screenshot
                child: InteractiveViewer(
                  panEnabled: true,
                  scaleEnabled: true,
                  minScale: _minScale,
                  maxScale: _maxScale,
                  onInteractionUpdate: (details) {
                    setState(() {
                      _currentScale = details.scale;
                    });
                  },
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: LineChart(
                        LineChartData(
                          lineBarsData: getLineBarsData(),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true),
                            ),
                          ),
                          gridData: const FlGridData(show: true),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(color: Colors.black26),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _downloadPlot,
                  icon: const Icon(Icons.download),
                  label: const Text("Download Plot"),
                ),
                ElevatedButton.icon(
                  onPressed: _resetZoom,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Reset Zoom"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadPlot() async {
    try {
      final Uint8List? image = await _screenshotController.capture();
      if (image != null) {
        final directory = await getDownloadsDirectory();
        if (directory != null) {
          final imagePath =
              '${directory.path}/plot_${DateTime.now().millisecondsSinceEpoch}.png';
          final file = File(imagePath);
          await file.writeAsBytes(image);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Plot downloaded to: $imagePath')),
          );
        } else {
          throw Exception("Could not find the downloads directory.");
        }
      } else {
        throw Exception("Failed to capture the plot image.");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading plot: $e')),
      );
    }
  }

  void _resetZoom() {
    setState(() {
      _currentScale = 1.0;
      _minScale = 1.0;
      _maxScale = 5.0;
    });
  }
}
