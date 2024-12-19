import '../reactive_framework.dart';
import '../utils/dep_graph.dart';

void Function() deepPropagation(ReactiveFramework framework) {
  const len = 50;

  return framework.withBuild(() {
    final head = framework.signal(0);
    var current = head as ISignal<int>;

    for (int i = 0; i < len; i++) {
      final c = current;
      current = framework.computed(() => c.read() + 1);
    }

    final callCounter = Counter();

    framework.effect(() {
      current.read();
      callCounter.count++;
    });

    const iter = 50;

    return () {
      framework.withBatch(() {
        head.write(1);
      });

      callCounter.count = 0;
      for (int i = 0; i < iter; i++) {
        framework.withBatch(() {
          head.write(i);
        });
        assert(callCounter.count == i + 1);
        assert(current.read() == len + i);
      }
    };
  });
}
