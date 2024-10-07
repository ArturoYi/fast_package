import 'package:fast_package/fast_package.dart';
import 'package:flutter/material.dart';

class DebounceExample extends StatefulWidget {
  const DebounceExample({super.key});

  @override
  State<DebounceExample> createState() => _DebounceExampleState();
}

class _DebounceExampleState extends State<DebounceExample> {
  int count = 0;
  int countOnExecute = 0;
  int countOnAfter = 0;
  int countReateLimtOnExecute = 0;
  int countReateLimtOnAfter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          Container(
            height: 1,
            width: double.infinity,
            color: Colors.black,
            margin: const EdgeInsets.only(bottom: 16, top: 16),
          ),
          const SizedBox(
            child: Center(
              child: Text("debounce example"),
            ),
          ),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => FastDebounce.debounce(
                  tag: 'removeCount',
                  duration: const Duration(seconds: 1),
                  onExecute: () {
                    setState(() {
                      count--;
                    });
                  },
                ),
                icon: const Icon(
                  Icons.remove,
                ),
                label: const Text(
                  "1",
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    "$count",
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => FastDebounce.debounce(
                  tag: 'addCount',
                  duration: const Duration(seconds: 1),
                  onExecute: () {
                    setState(() {
                      count++;
                    });
                  },
                ),
                icon: const Icon(
                  Icons.add,
                ),
                label: const Text(
                  "1",
                ),
              ),
            ],
          ),
          Container(
            height: 1,
            width: double.infinity,
            color: Colors.black,
            margin: const EdgeInsets.only(bottom: 16, top: 16),
          ),
          const SizedBox(
            child: Center(
              child: Text("throttle example onExecute"),
            ),
          ),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => FastThrottle.throttle(
                  tag: 'removeCountThrottle',
                  duration: const Duration(seconds: 1),
                  onExecute: () {
                    setState(() {
                      countOnExecute--;
                    });
                  },
                ),
                icon: const Icon(
                  Icons.remove,
                ),
                label: const Text(
                  "1 onExecute",
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    "$countOnExecute",
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => FastThrottle.throttle(
                  tag: 'addCountThrottle',
                  duration: const Duration(seconds: 1),
                  onExecute: () {
                    setState(() {
                      countOnExecute++;
                    });
                  },
                ),
                icon: const Icon(
                  Icons.add,
                ),
                label: const Text(
                  "1 onExecute",
                ),
              ),
            ],
          ),
          Container(
            height: 1,
            width: double.infinity,
            color: Colors.black,
            margin: const EdgeInsets.only(bottom: 16, top: 16),
          ),
          const SizedBox(
            child: Center(
              child: Text("throttle example onAfter"),
            ),
          ),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => FastThrottle.throttle(
                  tag: 'removeCountThrottleOnAfter',
                  duration: const Duration(seconds: 1),
                  onExecute: () {},
                  onAfter: () {
                    setState(() {
                      countOnAfter--;
                    });
                  },
                ),
                icon: const Icon(
                  Icons.remove,
                ),
                label: const Text(
                  "1 onExecute",
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    "$countOnAfter",
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => FastThrottle.throttle(
                  tag: 'addCountThrottleOnAfter',
                  duration: const Duration(seconds: 1),
                  onExecute: () {},
                  onAfter: () {
                    setState(() {
                      countOnAfter++;
                    });
                  },
                ),
                icon: const Icon(
                  Icons.add,
                ),
                label: const Text(
                  "1 onExecute",
                ),
              ),
            ],
          ),
          Container(
            height: 1,
            width: double.infinity,
            color: Colors.black,
            margin: const EdgeInsets.only(bottom: 16, top: 16),
          ),
          const SizedBox(
            child: Center(
              child: Text("ratelimit example onExecute"),
            ),
          ),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => FastRateLimit.rateLimit(
                  tag: 'addCountRateLimitOnExecute',
                  duration: const Duration(seconds: 1),
                  onExecute: () {
                    setState(() {
                      countReateLimtOnExecute--;
                    });
                  },
                  onAfter: () {},
                ),
                icon: const Icon(
                  Icons.add,
                ),
                label: const Text(
                  "1 onExecute",
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    "$countReateLimtOnExecute",
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => FastRateLimit.rateLimit(
                  tag: 'addCountRateLimitOnExecute',
                  duration: const Duration(seconds: 1),
                  onExecute: () {
                    setState(() {
                      countReateLimtOnExecute++;
                    });
                  },
                  onAfter: () {},
                ),
                icon: const Icon(
                  Icons.add,
                ),
                label: const Text(
                  "1 onExecute",
                ),
              ),
            ],
          ),
          Container(
            height: 1,
            width: double.infinity,
            color: Colors.black,
            margin: const EdgeInsets.only(bottom: 16, top: 16),
          ),
          const SizedBox(
            child: Center(
              child: Text("ratelimit example onAfter"),
            ),
          ),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => FastRateLimit.rateLimit(
                  tag: 'addCountRateLimitOnAfter',
                  duration: const Duration(seconds: 1),
                  onExecute: () {},
                  onAfter: () {
                    setState(() {
                      countReateLimtOnAfter--;
                    });
                  },
                ),
                icon: const Icon(
                  Icons.add,
                ),
                label: const Text(
                  "1 onExecute",
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    "$countReateLimtOnAfter",
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => FastRateLimit.rateLimit(
                  tag: 'addCountRateLimitOnAfter',
                  duration: const Duration(seconds: 1),
                  onExecute: () {},
                  onAfter: () {
                    setState(() {
                      countReateLimtOnAfter++;
                    });
                  },
                ),
                icon: const Icon(
                  Icons.add,
                ),
                label: const Text(
                  "1 onExecute",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
