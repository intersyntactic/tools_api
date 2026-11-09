import 'package:checked_json/checked_json.dart';

/// What a tool takes: the JSON Schema that tells the model the object to
/// send, and the reader that turns the object it sent into an [I].
///
/// One description, so the two cannot disagree. A field the schema names is
/// the field the reader reads, a constraint the schema shows the model is the
/// one the reader checks, and a field the schema does not name is refused
/// (`additionalProperties: false`), so the model learns a tool's rules from
/// its schema rather than by being refused.
///
/// Made from [Field]s by [field], [none] and [fields2] to [fields8], each
/// handing the fields' values, in order, to a function that makes the [I].
/// Dart has no type for "any number of fields", so the count is in the name.
final class Input<I> {
  Input._(List<Field<Object?>> fields, this._make)
    : _fields = List.unmodifiable(fields) {
    final names = <String>{};
    for (final f in _fields) {
      if (!names.add(f.name)) {
        throw ArgumentError.value(f.name, 'fields', 'is named twice');
      }
    }
  }

  final List<Field<Object?>> _fields;
  final I Function(List<Object?> values) _make;

  /// The JSON Schema of the object, built from the fields and frozen.
  late final JsonObject schema = JsonObject.of(_schema()).deepFrozen();

  Map<String, Object?> _schema() => {
    'type': 'object',
    'properties': {for (final f in _fields) f.name: f._property},
    'required': [
      for (final f in _fields)
        if (f._required) f.name,
    ],
    'additionalProperties': false,
  };

  /// [input] as an [I]. A [JsonFieldException] naming the first field that
  /// is missing, of the wrong kind, outside its constraints, or not one of
  /// this input's fields.
  I read(JsonObject input) => _readAt(input, '');

  I _readAt(JsonObject json, String at) {
    for (final k in json.keys) {
      if (!_fields.any((f) => f.name == k)) {
        throw JsonFieldException(
          _path(at, k),
          _fields.isEmpty
              ? 'a field here, which takes none'
              : 'one of ${_fields.map((f) => f.name).join(', ')}',
        );
      }
    }
    return _make([for (final f in _fields) f._readIn(json, _path(at, f.name))]);
  }

  /// An object with no fields, for a tool that takes nothing.
  static final none = Input<()>._(const [], (_) => ());

  /// One field, whose value is the input.
  static Input<A> field<A>(Field<A> a) => Input._([a], (v) => v[0] as A);

  static Input<I> fields2<A, B, I>(
    Field<A> a,
    Field<B> b,
    I Function(A, B) make,
  ) => Input._([a, b], (v) => make(v[0] as A, v[1] as B));

  static Input<I> fields3<A, B, C, I>(
    Field<A> a,
    Field<B> b,
    Field<C> c,
    I Function(A, B, C) make,
  ) => Input._([a, b, c], (v) => make(v[0] as A, v[1] as B, v[2] as C));

  static Input<I> fields4<A, B, C, D, I>(
    Field<A> a,
    Field<B> b,
    Field<C> c,
    Field<D> d,
    I Function(A, B, C, D) make,
  ) => Input._([
    a,
    b,
    c,
    d,
  ], (v) => make(v[0] as A, v[1] as B, v[2] as C, v[3] as D));

  static Input<I> fields5<A, B, C, D, E, I>(
    Field<A> a,
    Field<B> b,
    Field<C> c,
    Field<D> d,
    Field<E> e,
    I Function(A, B, C, D, E) make,
  ) => Input._([
    a,
    b,
    c,
    d,
    e,
  ], (v) => make(v[0] as A, v[1] as B, v[2] as C, v[3] as D, v[4] as E));

  static Input<I> fields6<A, B, C, D, E, F, I>(
    Field<A> a,
    Field<B> b,
    Field<C> c,
    Field<D> d,
    Field<E> e,
    Field<F> f,
    I Function(A, B, C, D, E, F) make,
  ) => Input._(
    [a, b, c, d, e, f],
    (v) =>
        make(v[0] as A, v[1] as B, v[2] as C, v[3] as D, v[4] as E, v[5] as F),
  );

  static Input<I> fields7<A, B, C, D, E, F, G, I>(
    Field<A> a,
    Field<B> b,
    Field<C> c,
    Field<D> d,
    Field<E> e,
    Field<F> f,
    Field<G> g,
    I Function(A, B, C, D, E, F, G) make,
  ) => Input._(
    [a, b, c, d, e, f, g],
    (v) => make(
      v[0] as A,
      v[1] as B,
      v[2] as C,
      v[3] as D,
      v[4] as E,
      v[5] as F,
      v[6] as G,
    ),
  );

  static Input<I> fields8<A, B, C, D, E, F, G, H, I>(
    Field<A> a,
    Field<B> b,
    Field<C> c,
    Field<D> d,
    Field<E> e,
    Field<F> f,
    Field<G> g,
    Field<H> h,
    I Function(A, B, C, D, E, F, G, H) make,
  ) => Input._(
    [a, b, c, d, e, f, g, h],
    (v) => make(
      v[0] as A,
      v[1] as B,
      v[2] as C,
      v[3] as D,
      v[4] as E,
      v[5] as F,
      v[6] as G,
      v[7] as H,
    ),
  );
}

/// One field of an object: its name, the [Schema] of its value, and what the
/// model is told about it.
///
/// Required as made by the constructor. [Field.optional] reads an absent or
/// null field as null; [Field.orDefault] reads it as a value the schema also
/// shows the model.
final class Field<T> {
  Field(this.name, Schema<T> schema, {String? description})
    : _property = {...schema._json, 'description': ?description},
      _required = true,
      _readPresent = schema._read,
      _readAbsent = ((at) => throw JsonFieldException(at, schema._wanted));

  Field._(
    this.name,
    this._property,
    this._required,
    this._readPresent,
    this._readAbsent,
  );

  /// A field the model may leave out, read as null when it does.
  static Field<T?> optional<T>(
    String name,
    Schema<T> schema, {
    String? description,
  }) => Field._(
    name,
    {...schema._json, 'description': ?description},
    false,
    schema._read,
    (_) => null,
  );

  /// A field the model may leave out, read as [value] when it does. The
  /// schema shows the model [value] as the field's `default`.
  static Field<T> orDefault<T>(
    String name,
    Schema<T> schema,
    T value, {
    String? description,
  }) {
    final write =
        schema._write ??
        (throw ArgumentError.value(
          name,
          'name',
          'is an object, which has no JSON form for a default',
        ));
    return Field._(
      name,
      {...schema._json, 'description': ?description, 'default': write(value)},
      false,
      schema._read,
      (_) => value,
    );
  }

  final String name;
  final Map<String, Object?> _property;
  final bool _required;
  final T Function(Object? value, String at) _readPresent;
  final T Function(String at) _readAbsent;

  T _readIn(JsonObject json, String at) => switch (json.raw(name)) {
    null => _readAbsent(at),
    final value => _readPresent(value, at),
  };
}

/// One JSON value: the JSON Schema that describes it and the reader that
/// turns such a value into a [T].
///
/// Made only by its static methods, each named for its JSON Schema type and
/// taking JSON Schema's own names for its constraints, which the reader
/// checks as well.
final class Schema<T> {
  Schema._(this._json, this._wanted, this._read, this._write);

  final Map<String, Object?> _json;

  /// What a value must be, as a phrase: `an integer from 1`.
  final String _wanted;
  final T Function(Object? value, String at) _read;

  /// The value as JSON, for a default; null for an object, which has none.
  final Object? Function(T value)? _write;

  /// A string, [minLength] to [maxLength] characters long.
  static Schema<String> string({int? minLength, int? maxLength}) {
    final wanted = switch ((minLength, maxLength)) {
      (null, null) => 'a string',
      (final lo?, null) => 'a string of at least $lo ${_chars(lo)}',
      (null, final hi?) => 'a string of at most $hi ${_chars(hi)}',
      (final lo?, final hi?) => 'a string of $lo to $hi characters',
    };
    return Schema._(
      {'type': 'string', 'minLength': ?minLength, 'maxLength': ?maxLength},
      wanted,
      (v, at) => switch (v) {
        final String s when _within(s.runes.length, minLength, maxLength) => s,
        _ => throw JsonFieldException(at, wanted),
      },
      (s) => s,
    );
  }

  /// A whole number from [minimum] to [maximum], as [wholeNumber] reads one.
  static Schema<int> integer({int? minimum, int? maximum}) {
    final wanted = _ranged('an integer', minimum, maximum);
    return Schema._(
      {'type': 'integer', 'minimum': ?minimum, 'maximum': ?maximum},
      wanted,
      (v, at) => switch (wholeNumber(v)) {
        final n? when _within(n, minimum, maximum) => n,
        _ => throw JsonFieldException(at, wanted),
      },
      (n) => n,
    );
  }

  /// A finite number from [minimum] to [maximum].
  static Schema<num> number({num? minimum, num? maximum}) {
    final wanted = _ranged('a finite number', minimum, maximum);
    return Schema._(
      {'type': 'number', 'minimum': ?minimum, 'maximum': ?maximum},
      wanted,
      (v, at) => switch (v) {
        final num n when n.isFinite && _within(n, minimum, maximum) => n,
        _ => throw JsonFieldException(at, wanted),
      },
      (n) => n,
    );
  }

  static Schema<bool> boolean() => Schema._(
    {'type': 'boolean'},
    'true or false',
    (v, at) => switch (v) {
      final bool b => b,
      _ => throw JsonFieldException(at, 'true or false'),
    },
    (b) => b,
  );

  /// One of [values], sent as its [Enum.name].
  static Schema<E> choice<E extends Enum>(List<E> values) {
    final wanted = 'one of ${values.map((e) => e.name).join(', ')}';
    return Schema._(
      {
        'type': 'string',
        'enum': [for (final e in values) e.name],
      },
      wanted,
      (v, at) =>
          values.where((e) => e.name == v).firstOrNull ??
          (throw JsonFieldException(at, wanted)),
      (e) => e.name,
    );
  }

  /// A list of [items], [minItems] to [maxItems] long.
  static Schema<List<E>> list<E>(
    Schema<E> items, {
    int? minItems,
    int? maxItems,
  }) {
    final wanted = switch ((minItems, maxItems)) {
      (null, null) => 'a list',
      (final lo?, null) => 'a list of at least $lo ${_items(lo)}',
      (null, final hi?) => 'a list of at most $hi ${_items(hi)}',
      (final lo?, final hi?) => 'a list of $lo to $hi items',
    };
    final write = items._write;
    return Schema._(
      {
        'type': 'array',
        'items': items._json,
        'minItems': ?minItems,
        'maxItems': ?maxItems,
      },
      wanted,
      (v, at) => switch (v) {
        final List<Object?> l when _within(l.length, minItems, maxItems) =>
          List.unmodifiable([
            for (final (i, x) in l.indexed) items._read(x, '$at[$i]'),
          ]),
        _ => throw JsonFieldException(at, wanted),
      },
      write == null ? null : (l) => [for (final x in l) write(x)],
    );
  }

  /// An object of [fields], read as theirs.
  static Schema<V> object<V>(Input<V> fields) => Schema._(
    fields._schema(),
    'an object',
    (v, at) => fields._readAt(
      JsonObject.parse(v) ?? (throw JsonFieldException(at, 'an object')),
      at,
    ),
    null,
  );
}

String _path(String at, String name) => at.isEmpty ? name : '$at.$name';

bool _within(num n, num? lo, num? hi) =>
    (lo == null || n >= lo) && (hi == null || n <= hi);

String _ranged(String what, num? lo, num? hi) => switch ((lo, hi)) {
  (null, null) => what,
  (final lo?, null) => '$what from $lo',
  (null, final hi?) => '$what up to $hi',
  (final lo?, final hi?) => '$what from $lo to $hi',
};

String _chars(int n) => n == 1 ? 'character' : 'characters';

String _items(int n) => n == 1 ? 'item' : 'items';
