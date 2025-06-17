## 0.0.1

* TODO: Describe initial release.
* Added 
- fast_debounce
- fast_throttle
- fast_rate_limit
- fast_extension

## 0.0.2
* Added new number extensions:
  - `isBetween`: Check if a number is between two numbers
    ```dart
    5.isBetween(1, 10) // true
    5.isBetween(10, 1) // true
    5.5.isBetween(1, 10) // true
    ```
  - `isDivisibleBy`: Check if a number is divisible by another number
    ```dart
    10.isDivisibleBy(2) // true
    10.isDivisibleBy(3) // false
    (-10).isDivisibleBy(2) // true
    ```

