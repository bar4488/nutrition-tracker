class Computation<T> {
  T? _value;
  final T Function() _computation;

  Computation(this._computation);

  T getValue() {
    if (_value != null) return _value!;
    _value = _computation();
    return _value!;
  }
}
