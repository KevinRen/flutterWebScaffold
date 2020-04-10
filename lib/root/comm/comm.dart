
class Comm {
  static String mapToQuery(Map map) {
    List<String> _query = List();
    if (map.isNotEmpty) map.forEach((key, value) => _query.add('$key=$value'));
    return _query.length > 0 ? '?${_query.join('&')}' : '';
  }
}