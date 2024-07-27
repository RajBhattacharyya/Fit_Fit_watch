import 'package:flutter/services.dart' show rootBundle;
import 'package:ml_algo/ml_algo.dart';
import 'package:ml_dataframe/ml_dataframe.dart';
import 'package:ml_preprocessing/ml_preprocessing.dart';
import 'package:path_provider/path_provider.dart';

void train() async {
  final rawCsvContent = await rootBundle.loadString('lib/data/datasets.csv');
  print(rawCsvContent);

  final samples = DataFrame.fromRawCsv(rawCsvContent, fieldDelimiter: ',')
      .dropSeries(names: ['ID']);
  print(samples.header);

  final pipeline = Pipeline(samples, [
    toIntegerLabels(columnNames: [ 'Health Status', 'Gender']),
  ]);
  final processed = pipeline.process(samples);
  print(processed);

  final splits = splitData(processed, [0.8]);
  final trainData = splits[0];
  final testData = splits[1];

 
  final model = LogisticRegressor(
    trainData,
    'Health Status',
    learningRateType: LearningRateType.constant,
   );

  final directory = await getApplicationDocumentsDirectory();
  final pathToFile = '${directory.path}/classifier.json';
  await model.saveAsJson(pathToFile);
  print(pathToFile);

  ///data/user/0/com.example.watch/app_flutter/classifier.json

  final error = model.assess(testData, MetricType.accuracy);
  print(error);

  print(model.predict(DataFrame([
    ["Age", "Gender", "Heart Rate", "Outside Temperature"],
    [80,1,80, 30],
  ])));
}
