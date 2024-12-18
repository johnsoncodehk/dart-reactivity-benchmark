import 'config.dart';
import 'framework_type.dart';
import 'utils/bench_repeat.dart';
import 'utils/dep_graph.dart';
import 'utils/logger.dart';
import 'utils/perf_logging.dart';
import 'utils/perf_tests.dart';

Future<void> dynamicBench(FrameworkInfo info, {int testRepeats = 1}) async {
  final FrameworkInfo(:framework) = info;
  for (final config in perfTests) {
    final TestConfig(:iterations, :readFraction) = config;
    final counter = Counter();
    int runOnce() {
      try {
        final graph = makeGraph(framework, config, counter);
        return runGraph(graph, iterations, readFraction, framework);
      } catch (e) {
        logger.f('Error dynamicBench: ${framework.name}', error: e);
        return -1;
      }
    }

    // warm up
    runOnce();

    final timingResult = await fastestTest(testRepeats, () {
      counter.count = 0;
      final sum = runOnce();
      return TestResult(sum: sum, count: counter.count);
    });

    logPerfResult(perfRowStrings(framework.name, config, timingResult));
    verifyBenchResult(info, config, timingResult);
  }
}
