final class A {
  final int? value;

  A(this.value);
}

void main() {
  int? n = 3;
  int n2 = n == null ? 3 : n + 2; // as intended

  if (n != null) {
    int n2 = n; // as intended
  }

  A a = A(3);
  int b = a.value == null
      ? 3
      : a.value +
          2; // error Operator '+' cannot be called on 'int?' because it is potentially null

  if (a.value != null) {
    int b = a.value; // error
  }
}
